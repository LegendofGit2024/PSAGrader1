"""
eBay Sold-Listings Price Fetcher
=================================
Uses the eBay Finding API (findCompletedItems) to pull the last N sold
prices for a Pokémon card, strips shipping, takes the median of the 5 most
recent sales, and writes the result to Firestore.

Setup
-----
1. Create a free eBay developer account: https://developer.ebay.com
2. Create an application → copy the Production App ID (Client ID).
3. Set it as an environment variable:
      $env:EBAY_APP_ID = "YourApp-xxxx-PRD-xxxxx-xxxxxxxx"   # PowerShell
      export EBAY_APP_ID="YourApp-xxxx-PRD-xxxxx-xxxxxxxx"   # bash/zsh

Usage (PowerShell)
------------------
  # Price a single card by Firestore / pokemontcg.io ID:
  python scripts\\ebay_price_fetcher.py --card-id "base1-4"

  # Price every card in Firestore (slow — eBay rate-limits to ~5 000 calls/day):
  python scripts\\ebay_price_fetcher.py --all

  # Dry run (prints query and result, does not write to Firestore):
  python scripts\\ebay_price_fetcher.py --card-id "base1-4" --dry-run

Architecture
------------
  build_query()         → constructs the eBay keyword string
  fetch_sold_listings() → calls eBay Finding API, returns raw item list
  extract_prices()      → strips shipping, returns list[float]
  median_of_last_n()    → median of the 5 most recent prices
  enrich_with_ebay_price() → top-level function used by kaggle_import.py
  update_firestore()    → writes pricing.ebay_us + lastUpdated to Firestore
  flag_high_scarcity()  → adds "high_scarcity" tag when eBay returns 0 results
"""

from __future__ import annotations

import argparse
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
# eBay Finding API
# ---------------------------------------------------------------------------

_FINDING_API_URL = "https://svcs.ebay.com/services/search/FindingService/v1"
_MAX_RESULTS     = 10   # fetch 10, take median of last 5
_MEDIAN_SAMPLE   = 5

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
# eBay Finding API client
# ---------------------------------------------------------------------------

def fetch_sold_listings(
    query:    str,
    app_id:   str,
    max_results: int = _MAX_RESULTS,
) -> list[dict]:
    """
    Call findCompletedItems with SoldItemsOnly=true.
    Returns the raw list of item dicts from the API response.
    Raises requests.HTTPError on non-2xx status.
    """
    params: dict[str, str | int] = {
        "OPERATION-NAME":        "findCompletedItems",
        "SERVICE-VERSION":       "1.0.0",
        "SECURITY-APPNAME":      app_id,
        "RESPONSE-DATA-FORMAT":  "JSON",
        "REST-PAYLOAD":          "",
        "keywords":              query,
        # Filter 0: sold items only
        "itemFilter(0).name":    "SoldItemsOnly",
        "itemFilter(0).value":   "true",
        # Filter 1: exclude auction bids (fixed-price + BIN gives cleaner comps)
        # Comment this out if you want auction comps too.
        # "itemFilter(1).name":  "ListingType",
        # "itemFilter(1).value": "FixedPrice",
        "sortOrder":             "EndTimeSoonest",
        "paginationInput.entriesPerPage": max_results,
        "paginationInput.pageNumber":     1,
    }

    resp = requests.get(_FINDING_API_URL, params=params, timeout=10)
    resp.raise_for_status()
    data = resp.json()

    try:
        search_result = (
            data
            ["findCompletedItemsResponse"][0]
            ["searchResult"][0]
        )
        return search_result.get("item", [])
    except (KeyError, IndexError, TypeError):
        return []


# ---------------------------------------------------------------------------
# Price extraction
# ---------------------------------------------------------------------------

def extract_prices(items: list[dict]) -> list[float]:
    """
    For each eBay item extract: item_price - shipping_cost.
    Returns a list of floats (only non-negative values included).
    """
    prices: list[float] = []

    for item in items:
        try:
            # Item sale price
            raw_price = (
                item["sellingStatus"][0]["currentPrice"][0]["__value__"]
            )
            item_price = float(raw_price)
        except (KeyError, IndexError, TypeError, ValueError):
            continue

        # Shipping cost (0 if free or unavailable)
        try:
            raw_ship = (
                item["shippingInfo"][0]
                    ["shippingServiceCost"][0]
                    ["__value__"]
            )
            shipping = float(raw_ship)
        except (KeyError, IndexError, TypeError, ValueError):
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

def enrich_with_ebay_price(doc: dict, app_id: str) -> dict:
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
        items  = fetch_sold_listings(query, app_id)
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
        "--ebay-app-id",
        default=os.environ.get("EBAY_APP_ID", ""),
        help="eBay developer App ID (or set EBAY_APP_ID env var)",
    )
    p.add_argument(
        "--delay", type=float, default=0.5,
        help="Seconds between eBay API calls when using --all (default: 0.5)",
    )
    p.add_argument(
        "--dry-run", action="store_true",
        help="Print query and result — do not write to Firestore",
    )
    return p


def _process_single(
    db,
    card_id:    str,
    app_id:     str,
    collection: str,
    dry_run:    bool,
) -> None:
    # Fetch card meta from Firestore
    doc_ref  = db.collection(collection).document(card_id)
    snapshot = doc_ref.get()
    if not snapshot.exists:
        log.error("Card not found in Firestore: %s", card_id)
        return

    data   = snapshot.to_dict() or {}
    meta   = data.get("meta", {})
    name   = meta.get("name", "")
    set_id = meta.get("set_id", "")
    number = meta.get("set_number", "")
    rarity = meta.get("variant", "")
    tags   = meta.get("specialty_tags", [])

    query  = build_query(name, set_id, number, rarity, tags)
    print(f"\nCard   : {name}  [{card_id}]")
    print(f"Query  : {query}")

    items  = fetch_sold_listings(query, app_id)
    prices = extract_prices(items)
    median = median_of_last_n(prices)

    print(f"Sales  : {len(items)} found,  prices extracted: {[f'${p:.2f}' for p in prices]}")

    if median is not None:
        print(f"Median : ${median:.2f}  (of last {min(len(prices), _MEDIAN_SAMPLE)})")
        if not dry_run:
            update_firestore(db, card_id, median, collection)
    else:
        print("Median : N/A — 0 sold results")
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

    if not args.ebay_app_id:
        log.error(
            "No eBay App ID provided.  Set EBAY_APP_ID env var or use --ebay-app-id."
        )
        sys.exit(1)

    # Firebase init
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore as fb_firestore
    except ImportError:
        log.error("firebase-admin not installed.  Run: pip install firebase-admin")
        sys.exit(1)

    sa_path = __import__("pathlib").Path(args.service_account)
    if not sa_path.exists() and not args.dry_run:
        log.error("Service-account file not found: %s", sa_path)
        sys.exit(1)

    if not firebase_admin._apps:
        cred = credentials.Certificate(str(sa_path))
        firebase_admin.initialize_app(cred)

    db = fb_firestore.client()

    if args.card_id:
        _process_single(db, args.card_id, args.ebay_app_id, args.collection, args.dry_run)
    else:
        # --all: stream every doc in the collection
        log.info("Streaming all documents from '%s' …", args.collection)
        docs = list(db.collection(args.collection).stream())
        log.info("Found %d documents", len(docs))

        for i, snap in enumerate(docs, 1):
            card_id = snap.id
            log.info("[%d/%d] %s", i, len(docs), card_id)
            try:
                _process_single(
                    db, card_id, args.ebay_app_id, args.collection, args.dry_run
                )
            except Exception as exc:
                log.error("  Failed: %s", exc)

            # Respect eBay rate limit (~5 000 calls/day = ~1 per 17 s)
            time.sleep(args.delay)

    log.info("Done.")


if __name__ == "__main__":
    main()
