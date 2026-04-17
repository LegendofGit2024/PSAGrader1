"""
eBay Sold-Listings Price Fetcher
=================================
Uses the eBay Browse API (buy/browse/v1/item_summary/search) with OAuth2
Client Credentials to pull recent sold prices for a Pokémon card, strips
shipping, takes the median of the 5 most recent sales, and writes to Firestore.

Setup
-----
1. Go to https://developer.ebay.com → your application
2. Copy:  Client ID  (App ID)   → EBAY_CLIENT_ID
          Client Secret (Cert)  → EBAY_CLIENT_SECRET

Set as environment variables (PowerShell):
      $env:EBAY_CLIENT_ID     = "NathanRo-s-PRD-f84c0e5fe-7b2339df"
      $env:EBAY_CLIENT_SECRET = "PRD-xxxxxxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-xxxx"

Or permanently:
      [System.Environment]::SetEnvironmentVariable("EBAY_CLIENT_ID","NathanRo-s-PRD-f84c0e5fe-7b2339df","User")
      [System.Environment]::SetEnvironmentVariable("EBAY_CLIENT_SECRET","your-secret-here","User")

Usage (PowerShell)
------------------
  # Dry run — no Firestore needed:
  python scripts\\ebay_price_fetcher.py --card-id "base1-4" --name "Charizard" --set "Base Set" --number "4" --rarity "Rare Holo" --dry-run

  # Single card with Firestore update:
  python scripts\\ebay_price_fetcher.py --card-id "base1-4" --service-account "service-account.json"

  # Price every card in Firestore:
  python scripts\\ebay_price_fetcher.py --all --service-account "service-account.json"

Architecture
------------
  get_oauth_token()     → Client Credentials grant → Bearer token (cached 2h)
  build_query()         → constructs the eBay keyword string
  fetch_sold_listings() → Browse API item_summary/search with lastSoldDate filter
  extract_prices()      → strips shipping, returns list[float]
  median_of_last_n()    → median of the 5 most recent prices
  enrich_with_ebay_price() → top-level enrichment used by kaggle_import.py
  update_firestore()    → writes pricing.ebay_us + updated_at to Firestore
  flag_high_scarcity()  → adds "high_scarcity" tag when eBay returns 0 results
"""

from __future__ import annotations

import argparse
import base64
import logging
import os
import statistics
import sys
import time
from datetime import datetime, timezone
from typing import Any

import requests

log = logging.getLogger("ebay_fetcher")

# ---------------------------------------------------------------------------
# eBay Browse API  (replaces legacy Finding API)
# ---------------------------------------------------------------------------

_BROWSE_API_URL  = "https://api.ebay.com/buy/browse/v1/item_summary/search"
_OAUTH_TOKEN_URL = "https://api.ebay.com/identity/v1/oauth2/token"
_OAUTH_SCOPE     = "https://api.ebay.com/oauth/api_scope"
_MAX_RESULTS     = 10   # fetch 10, take median of last 5
_MEDIAN_SAMPLE   = 5

# ---------------------------------------------------------------------------
# OAuth2 token cache  (tokens last 7 200 s / 2 hours)
# ---------------------------------------------------------------------------

_token_cache: dict[str, Any] = {"token": None, "expires_at": 0.0}


def get_oauth_token(client_id: str, client_secret: str) -> str:
    """
    Obtain a Bearer token via the Client Credentials grant.
    Result is cached in-process for the token's lifetime (≈2 hours).
    """
    now = time.time()
    if _token_cache["token"] and now < _token_cache["expires_at"] - 60:
        return _token_cache["token"]   # type: ignore[return-value]

    credentials_str = f"{client_id}:{client_secret}"
    b64 = base64.b64encode(credentials_str.encode()).decode()

    resp = requests.post(
        _OAUTH_TOKEN_URL,
        headers={
            "Authorization": f"Basic {b64}",
            "Content-Type":  "application/x-www-form-urlencoded",
        },
        data={
            "grant_type": "client_credentials",
            "scope":      _OAUTH_SCOPE,
        },
        timeout=15,
    )

    if not resp.ok:
        log.error("OAuth token request failed %s: %s", resp.status_code, resp.text[:300])
        resp.raise_for_status()

    data = resp.json()
    token: str        = data["access_token"]
    expires_in: float = float(data.get("expires_in", 7200))

    _token_cache["token"]      = token
    _token_cache["expires_at"] = now + expires_in
    log.debug("OAuth token obtained, expires in %ds", int(expires_in))
    return token

# Rarity hints we inject into the query to surface the right variant
_RARITY_KEYWORDS: dict[str, str] = {
    "holo rare":       "holo",
    "rare holo":       "holo",
    "rare holo ex":    "holo ex",
    "rare holo gx":    "holo gx",
    "rare holo v":     "holo v",
    "rare holo vmax":  "holo vmax",
    "rare holo vstar": "holo vstar",
    "rare ultra":      "ultra rare",
    "rare secret":     "secret rare",
    "reverse holo":    "reverse holo",
    "amazing rare":    "amazing rare",
    "legend":          "legend",
    "promo":           "promo",
}


# ---------------------------------------------------------------------------
# Query builder
# ---------------------------------------------------------------------------

def build_query(
    card_name: str,
    set_name:  str,
    number:    str,
    rarity:    str = "",
    specialty_tags: list[str] | None = None,
) -> str:
    """
    Construct the eBay keyword string.

    Format:
        {set_name} {card_name} {number} ({variant_hint}) -lot -digital -code

    Examples:
        "Base Set Charizard 4/102 holo -lot -digital -code"
        "Fossil Gengar 1st edition holo -lot -digital -code"
    """
    parts: list[str] = []

    # Set + card name + number
    if set_name:
        parts.append(set_name.strip())
    parts.append(card_name.strip())
    if number:
        parts.append(number.strip())

    # Variant hint from rarity string
    rarity_lower = rarity.lower()
    variant_hint = next(
        (kw for key, kw in _RARITY_KEYWORDS.items() if key in rarity_lower),
        "",
    )

    # Specialty tag hints
    tag_hints: list[str] = []
    if specialty_tags:
        if "1st_edition" in specialty_tags:
            tag_hints.append("1st edition")
        if "shadowless" in specialty_tags:
            tag_hints.append("shadowless")
        if "japanese" in specialty_tags:
            tag_hints.append("japanese")
        if "error" in specialty_tags:
            tag_hints.append("error")

    # Combine variant and tag hints into a parenthetical OR group
    hints = list(dict.fromkeys(filter(None, [variant_hint] + tag_hints)))
    if hints:
        parts.append(f"({', '.join(hints)})")

    # Hard exclusions — eliminates lots, digital/code cards
    parts.append("-lot -digital -code -bundle -collection")

    return " ".join(parts)


# ---------------------------------------------------------------------------
# eBay Browse API client
# ---------------------------------------------------------------------------

def fetch_sold_listings(
    query:         str,
    client_id:     str,
    client_secret: str,
    max_results:   int = _MAX_RESULTS,
) -> list[dict]:
    """
    Search eBay Browse API for recent sold listings.

    Uses:
      GET https://api.ebay.com/buy/browse/v1/item_summary/search
          ?q=<query>
          &filter=conditions:{NEW|USED},lastSoldDate:[2024-01-01T00:00:00Z..2026-12-31T23:59:59Z]
          &sort=newlyListed
          &limit=<max_results>

    Returns a list of itemSummary dicts.
    Raises requests.HTTPError on non-2xx status.
    """
    token = get_oauth_token(client_id, client_secret)

    # Date window — last 2 years up to end of current year
    filter_str = (
        "conditions:{NEW|USED},"
        "lastSoldDate:[2024-01-01T00:00:00Z..2026-12-31T23:59:59Z]"
    )

    params: dict[str, str | int] = {
        "q":      query,
        "filter": filter_str,
        "sort":   "newlyListed",
        "limit":  max_results,
    }

    headers = {
        "Authorization":           f"Bearer {token}",
        "X-EBAY-C-MARKETPLACE-ID": "EBAY_US",
        "Content-Type":            "application/json",
    }

    resp = requests.get(_BROWSE_API_URL, params=params, headers=headers, timeout=15)

    if not resp.ok:
        try:
            err_body = resp.json()
            log.error("eBay Browse API %s — %s", resp.status_code, err_body)
        except Exception:
            log.error("eBay Browse API %s — %s", resp.status_code, resp.text[:400])
        resp.raise_for_status()

    data = resp.json()
    return data.get("itemSummaries", [])


# ---------------------------------------------------------------------------
# Price extraction  (Browse API response shape)
# ---------------------------------------------------------------------------

def extract_prices(items: list[dict]) -> list[float]:
    """
    Extract net price (item price minus shipping) from Browse API itemSummaries.
    Returns a list of floats, newest first, only non-negative values.
    """
    prices: list[float] = []

    for item in items:
        # Item sale price
        try:
            item_price = float(item["price"]["value"])
        except (KeyError, TypeError, ValueError):
            continue

        # Shipping — free shipping = 0, take first option if present
        shipping = 0.0
        try:
            shipping_options = item.get("shippingOptions", [])
            if shipping_options:
                shipping = float(
                    shipping_options[0].get("shippingCost", {}).get("value", 0)
                )
        except (TypeError, ValueError):
            shipping = 0.0

        net = item_price - shipping
        if net >= 0:
            prices.append(net)

    return prices


def median_of_last_n(prices: list[float], n: int = _MEDIAN_SAMPLE) -> float | None:
    """Return the median of the last (most recent) n prices."""
    sample = prices[:n]   # API returns newest first (EndTimeSoonest)
    if not sample:
        return None
    return statistics.median(sample)


# ---------------------------------------------------------------------------
# Firestore helpers
# ---------------------------------------------------------------------------

def update_firestore(db, card_id: str, median_price: float, collection: str = "cards") -> None:
    """Write pricing.ebay_us.last_sold_nm + updated_at to Firestore."""
    from google.cloud.firestore_v1 import SERVER_TIMESTAMP  # type: ignore

    ref = db.collection(collection).document(card_id)
    ref.set(
        {
            "pricing": {
                "ebay_us": {
                    "last_sold_nm": round(median_price, 2),
                    "updated_at":   SERVER_TIMESTAMP,
                }
            }
        },
        merge=True,
    )
    log.info("  [%s] eBay median = $%.2f → Firestore updated", card_id, median_price)


def flag_high_scarcity(db, card_id: str, collection: str = "cards") -> None:
    """
    eBay returned 0 sold results — card is too rare to price automatically.
    - Adds 'high_scarcity' to meta.specialty_tags
    - Sets pricing.ebay_us.last_sold_nm = None
    - Sets a human-readable scarcity_note field
    """
    from google.cloud.firestore_v1 import ArrayUnion, SERVER_TIMESTAMP  # type: ignore

    ref = db.collection(collection).document(card_id)
    ref.set(
        {
            "meta": {
                "specialty_tags": ArrayUnion(["high_scarcity"]),
                "scarcity_note":  "High Scarcity: Manual Verification Required",
            },
            "pricing": {
                "ebay_us": {
                    "last_sold_nm": None,
                    "updated_at":   SERVER_TIMESTAMP,
                }
            },
        },
        merge=True,
    )
    log.warning(
        "  [%s] 0 eBay results → flagged 'High Scarcity: Manual Verification Required'",
        card_id,
    )


# ---------------------------------------------------------------------------
# Top-level enrichment function (called by kaggle_import.py)
# ---------------------------------------------------------------------------

def enrich_with_ebay_price(doc: dict, client_id: str, client_secret: str) -> dict:
    """
    Fetch eBay sold prices for a card and inject the result into the doc dict
    in-place (before it is written to Firestore).

    Does NOT write to Firestore directly — kaggle_import.py handles that via
    batch.set() so this function just enriches the dict.
    """
    meta   = doc.get("meta", {})
    name   = meta.get("name", "")
    set_id = meta.get("set_id", "")      # e.g. "base1"
    number = meta.get("set_number", "")
    rarity = meta.get("variant", "")
    tags   = meta.get("specialty_tags", [])

    query  = build_query(name, set_id, number, rarity, tags)
    log.debug("eBay query: %s", query)

    try:
        items  = fetch_sold_listings(query, client_id, client_secret)
        prices = extract_prices(items)
        median = median_of_last_n(prices)
    except Exception as exc:
        log.debug("eBay API error for '%s': %s", name, exc)
        median = None

    now_iso = datetime.now(timezone.utc).isoformat()

    if median is not None:
        doc.setdefault("pricing", {})["ebay_us"] = {
            "last_sold_nm": round(median, 2),
            "updated_at":   now_iso,
        }
        log.info("  %-40s  eBay median = $%.2f", name[:40], median)
    else:
        # Flag scarcity — kaggle_import will write this to Firestore via merge
        doc.setdefault("meta", {}).setdefault("specialty_tags", [])
        if "high_scarcity" not in doc["meta"]["specialty_tags"]:
            doc["meta"]["specialty_tags"].append("high_scarcity")
        doc["meta"]["scarcity_note"] = "High Scarcity: Manual Verification Required"
        doc.setdefault("pricing", {})["ebay_us"] = {
            "last_sold_nm": None,
            "updated_at":   now_iso,
        }
        log.warning("  %-40s  0 eBay results → high_scarcity", name[:40])

    return doc


# ---------------------------------------------------------------------------
# Standalone CLI
# ---------------------------------------------------------------------------

def _parse_card_id(card_id: str) -> tuple[str, str]:
    """
    Derive a best-guess set_id and number from a pokemontcg.io card ID.
    e.g. "base1-4"  → ("base1", "4")
         "swsh1-25" → ("swsh1", "25")
    Returns ("", "") if the format is unrecognised.
    """
    parts = card_id.rsplit("-", 1)
    if len(parts) == 2:
        return parts[0], parts[1]
    return "", ""


# Human-readable set names for the most common set IDs so the eBay query
# is descriptive rather than a raw code like "base1".
_SET_ID_TO_NAME: dict[str, str] = {
    "base1":    "Base Set",
    "base2":    "Jungle",
    "base3":    "Fossil",
    "base4":    "Base Set 2",
    "base5":    "Team Rocket",
    "base6":    "Legendary Collection",
    "gym1":     "Gym Heroes",
    "gym2":     "Gym Challenge",
    "neo1":     "Neo Genesis",
    "neo2":     "Neo Discovery",
    "neo3":     "Neo Revelation",
    "neo4":     "Neo Destiny",
    "ecard1":   "Expedition Base Set",
    "ecard2":   "Aquapolis",
    "ecard3":   "Skyridge",
    "swsh1":    "Sword & Shield",
    "swsh2":    "Rebel Clash",
    "swsh3":    "Darkness Ablaze",
    "swsh4":    "Vivid Voltage",
    "swsh5":    "Battle Styles",
    "swsh6":    "Chilling Reign",
    "swsh7":    "Evolving Skies",
    "swsh8":    "Fusion Strike",
    "swsh9":    "Brilliant Stars",
    "swsh10":   "Astral Radiance",
    "swsh11":   "Lost Origin",
    "swsh12":   "Silver Tempest",
    "sv1":      "Scarlet & Violet",
    "sv2":      "Paldea Evolved",
    "sv3":      "Obsidian Flames",
    "sv4":      "Paradox Rift",
    "sv5":      "Temporal Forces",
    "sv6":      "Twilight Masquerade",
    "sv7":      "Stellar Crown",
}


def _build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Fetch eBay sold prices and update Firestore.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    group = p.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--card-id",
        help='Firestore / pokemontcg.io card ID, e.g. "base1-4"',
    )
    group.add_argument(
        "--all",
        action="store_true",
        help="Process every document in the Firestore collection",
    )
    p.add_argument(
        "--collection", default="cards",
        help="Firestore collection (default: cards)",
    )
    p.add_argument(
        "--service-account",
        default=os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", "service-account.json"),
    )
    p.add_argument(
        "--ebay-client-id",
        default=os.environ.get("EBAY_CLIENT_ID", os.environ.get("EBAY_APP_ID", "")),
        help="eBay Client ID / App ID (or set EBAY_CLIENT_ID env var)",
    )
    p.add_argument(
        "--ebay-client-secret",
        default=os.environ.get("EBAY_CLIENT_SECRET", ""),
        help="eBay Client Secret / Cert ID (or set EBAY_CLIENT_SECRET env var)",
    )
    p.add_argument(
        "--delay", type=float, default=0.5,
        help="Seconds between eBay API calls when using --all (default: 0.5)",
    )
    p.add_argument(
        "--dry-run", action="store_true",
        help="Print query and result — do not write to Firestore",
    )
    # Manual overrides — lets you test without Firestore data
    p.add_argument("--name",   default="", help="Card name override, e.g. Charizard")
    p.add_argument("--set",    default="", help="Set name override, e.g. 'Base Set'")
    p.add_argument("--number", default="", help="Card number override, e.g. 4")
    p.add_argument("--rarity", default="", help="Rarity override, e.g. 'Rare Holo'")
    return p


def _process_single(
    db,
    card_id:       str,
    client_id:     str,
    client_secret: str,
    collection:    str,
    dry_run:       bool,
    name_override: str = "",
    set_override:  str = "",
    num_override:  str = "",
    rar_override:  str = "",
) -> None:
    # ── Pull meta from Firestore (skip if manual overrides supplied) ───────
    name   = name_override
    set_id = set_override
    number = num_override
    rarity = rar_override
    tags: list[str] = []

    if not (name_override and set_override):
        if db is not None:
            doc_ref  = db.collection(collection).document(card_id)
            snapshot = doc_ref.get()
            if snapshot.exists:
                data   = snapshot.to_dict() or {}
                meta   = data.get("meta", {})
                name   = name_override  or meta.get("name",       "")
                set_id = set_override   or meta.get("set_id",     "")
                number = num_override   or meta.get("set_number", "")
                rarity = rar_override   or meta.get("variant",    "")
                tags   = meta.get("specialty_tags", [])
            else:
                log.warning("Card not in Firestore — falling back to card ID parsing")

        # Last resort: parse the card ID itself (e.g. "base1-4" → set=base1, num=4)
        if not set_id or not number:
            parsed_set, parsed_num = _parse_card_id(card_id)
            set_id = set_id or _SET_ID_TO_NAME.get(parsed_set, parsed_set)
            number = number or parsed_num

    query = build_query(name, set_id, number, rarity, tags)
    print(f"\nCard   : {name or card_id}  [{card_id}]")
    print(f"Query  : {query}")

    items  = fetch_sold_listings(query, client_id, client_secret)
    prices = extract_prices(items)
    median = median_of_last_n(prices)

    print(f"Sales  : {len(items)} found,  prices extracted: {[f'${p:.2f}' for p in prices]}")

    if median is not None:
        print(f"Median : ${median:.2f}  (of last {min(len(prices), _MEDIAN_SAMPLE)})")
        if not dry_run:
            update_firestore(db, card_id, median, collection)
    else:
        print("Median : N/A — 0 sold results → would flag as High Scarcity")
        if not dry_run:
            flag_high_scarcity(db, card_id, collection)

    if dry_run:
        print("(dry run — Firestore not updated)")


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s  %(levelname)-8s  %(message)s",
        datefmt="%H:%M:%S",
    )

    parser = _build_parser()
    args   = parser.parse_args()

    if not args.ebay_client_id:
        log.error(
            "No eBay Client ID provided.\n"
            "  $env:EBAY_CLIENT_ID = 'NathanRo-s-PRD-f84c0e5fe-7b2339df'\n"
            "  or use:  --ebay-client-id NathanRo-s-PRD-f84c0e5fe-7b2339df"
        )
        sys.exit(1)

    if not args.ebay_client_secret:
        log.error(
            "No eBay Client Secret provided.\n"
            "  Find it at developer.ebay.com → your app → 'Client Secret' (Cert ID)\n"
            "  $env:EBAY_CLIENT_SECRET = 'PRD-your-secret-here'\n"
            "  or use:  --ebay-client-secret PRD-your-secret-here"
        )
        sys.exit(1)

    # ── Firebase init (skipped for dry-run with manual --name/--set) ───────
    has_manual_meta = bool(args.name and args.set)
    db = None

    if not (args.dry_run and has_manual_meta):
        try:
            import firebase_admin
            from firebase_admin import credentials, firestore as fb_firestore
        except ImportError:
            log.error("firebase-admin not installed.  Run: pip install firebase-admin")
            sys.exit(1)

        from pathlib import Path as _Path
        sa_path = _Path(args.service_account)
        if not sa_path.exists():
            if args.dry_run:
                log.warning(
                    "service-account.json not found — running in query-only mode "
                    "(no Firestore lookup, using --name/--set/--number overrides or card ID parsing)"
                )
            else:
                log.error(
                    "Service-account file not found: %s\n"
                    "Download from Firebase Console → Project Settings → Service Accounts",
                    sa_path,
                )
                sys.exit(1)
        else:
            import firebase_admin  # noqa: F811
            from firebase_admin import credentials, firestore as fb_firestore  # noqa: F811
            if not firebase_admin._apps:
                cred = credentials.Certificate(str(sa_path))
                firebase_admin.initialize_app(cred)
            db = fb_firestore.client()

    cid    = args.ebay_client_id
    csecret = args.ebay_client_secret

    if args.card_id:
        _process_single(
            db, args.card_id, cid, csecret, args.collection, args.dry_run,
            name_override=args.name,
            set_override=args.set,
            num_override=args.number,
            rar_override=args.rarity,
        )
    else:
        if db is None:
            log.error("--all requires a valid service-account.json")
            sys.exit(1)
        log.info("Streaming all documents from '%s' …", args.collection)
        docs = list(db.collection(args.collection).stream())
        log.info("Found %d documents", len(docs))

        for i, snap in enumerate(docs, 1):
            card_id = snap.id
            log.info("[%d/%d] %s", i, len(docs), card_id)
            try:
                _process_single(db, card_id, cid, csecret, args.collection, args.dry_run)
            except Exception as exc:
                log.error("  Failed: %s", exc)

            # Browse API rate limit is generous but add a small delay
            time.sleep(args.delay)

    log.info("Done.")


if __name__ == "__main__":
    main()
