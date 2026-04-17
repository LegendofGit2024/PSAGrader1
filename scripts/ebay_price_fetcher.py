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
import re
import statistics
import sys
import time
from datetime import datetime, timezone
from enum import Enum
from typing import Any

import requests

log = logging.getLogger("ebay_fetcher")

# ---------------------------------------------------------------------------
# Fetch mode
# ---------------------------------------------------------------------------

class FetchMode(str, Enum):
    RAW    = "raw"     # ungraded card only
    GRADED = "graded"  # slabbed/graded only
    BOTH   = "both"    # run both queries (default for enrich_with_ebay_price)

# ---------------------------------------------------------------------------
# Grading classifier — scored hierarchy
#
# Rule: a grade NUMBER is only meaningful when a grading COMPANY (or a
# recognised semantic phrase like "GEM MINT") appears nearby.
# "looks like a 10" or "Grade 10 potential" must NEVER reach psa10.
#
# Bucket priority:
#   psa10  → PSA/CGC/BGS/ACE 10, GEM MINT, GEM 10, GEM-MT
#   psa9   → PSA/CGC 9, MINT 9
#   psa8   → PSA/CGC 8, NM-MT 8
#   other  → grading company present but grade unclear → DISCARDED
#   None   → no grading company at all → DISCARDED
#
# Patterns are tried in priority order — first match wins.
# ---------------------------------------------------------------------------

_GRADE_PATTERNS: list[tuple[re.Pattern, str]] = [
    # ── PSA 10 bucket ────────────────────────────────────────────────────
    (re.compile(r'\bPSA\s*10\b',             re.IGNORECASE), 'psa10'),
    (re.compile(r'\bCGC\s*10\b',             re.IGNORECASE), 'psa10'),
    (re.compile(r'\bBGS\s*10\b',             re.IGNORECASE), 'psa10'),
    (re.compile(r'\bACE\s*10\b',             re.IGNORECASE), 'psa10'),
    (re.compile(r'\bSGC\s*10\b',             re.IGNORECASE), 'psa10'),
    # Semantic equivalents (no number required)
    (re.compile(r'\bGEM\s*-?\s*MINT\b',      re.IGNORECASE), 'psa10'),
    (re.compile(r'\bGEM\s*10\b',             re.IGNORECASE), 'psa10'),
    (re.compile(r'\bGEM\s*-?\s*MT\b',        re.IGNORECASE), 'psa10'),
    (re.compile(r'\bBGS\s*9\.5\b',           re.IGNORECASE), 'psa10'),  # BGS 9.5 = gem equiv

    # ── PSA 9 bucket ─────────────────────────────────────────────────────
    (re.compile(r'\bPSA\s*9\b(?!\s*[\.\d])', re.IGNORECASE), 'psa9'),   # PSA 9 but not PSA 9.5
    (re.compile(r'\bCGC\s*9\b(?!\s*[\.\d])', re.IGNORECASE), 'psa9'),
    (re.compile(r'\bBGS\s*9\b(?!\s*[\.\d])', re.IGNORECASE), 'psa9'),
    (re.compile(r'\bSGC\s*9\b(?!\s*[\.\d])', re.IGNORECASE), 'psa9'),
    (re.compile(r'\bMINT\s*9\b',             re.IGNORECASE), 'psa9'),

    # ── PSA 8 bucket ─────────────────────────────────────────────────────
    (re.compile(r'\bPSA\s*8\b',              re.IGNORECASE), 'psa8'),
    (re.compile(r'\bCGC\s*8\b',              re.IGNORECASE), 'psa8'),
    (re.compile(r'\bBGS\s*8\b',              re.IGNORECASE), 'psa8'),
    (re.compile(r'\bSGC\s*8\b',              re.IGNORECASE), 'psa8'),
    (re.compile(r'\bNM\s*-?\s*MT\s*8\b',     re.IGNORECASE), 'psa8'),
    (re.compile(r'\bNM\s*MT\s*8\b',          re.IGNORECASE), 'psa8'),
    (re.compile(r'\bNMMT\s*8\b',             re.IGNORECASE), 'psa8'),
]

# Catch-all: grading company present but grade doesn't match any bucket
_GRADING_COMPANY_REGEX = re.compile(
    r'\b(PSA|CGC|BGS|ACE|SGC)\b', re.IGNORECASE
)


def classify_title(title: str) -> str | None:
    """
    Score and classify an eBay title using the grade hierarchy.

    Returns:
        'psa10'  — grade 10 / GEM MINT equivalents
        'psa9'   — grade 9 / MINT 9
        'psa8'   — grade 8 / NM-MT 8
        'other'  — grading company found but grade unclear (safe to discard)
        None     — no grading company found at all (not a graded listing)

    NEVER defaults an ambiguous title to psa10.
    """
    for pattern, bucket in _GRADE_PATTERNS:
        if pattern.search(title):
            return bucket
    # Company present but no clear grade — discard rather than guess
    if _GRADING_COMPANY_REGEX.search(title):
        return 'other'
    return None  # not a graded listing


def is_valid_graded_title(title: str) -> bool:
    """True if the title belongs to a graded listing (any grade)."""
    return classify_title(title) not in (None, 'other')

# ---------------------------------------------------------------------------
# eBay Browse API
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
    card_name:      str,
    set_name:       str,
    number:         str,
    rarity:         str = "",
    specialty_tags: list[str] | None = None,
    mode:           FetchMode = FetchMode.RAW,
) -> str:
    """
    Construct the eBay keyword string for the given FetchMode.

    RAW mode    →  adds (raw, ungraded, nm, near mint)  and  -psa -cgc -bgs -graded -slab
    GRADED mode →  adds (psa, cgc, bgs, graded, slab)   and  -raw -ungraded

    Examples:
        RAW    → "Base Set Charizard 4 (holo, raw, ungraded, nm) -psa -cgc -bgs -graded -slab -lot -digital -code"
        GRADED → "Base Set Charizard 4 (holo, psa, cgc, bgs, graded) -raw -ungraded -lot -digital -code"
    """
    parts: list[str] = []

    # Normalise raw set ID (e.g. "base1") to a human-readable name so the
    # eBay query uses "Base Set" rather than the API code.
    resolved_set = _SET_ID_TO_NAME.get(set_name.strip(), set_name.strip())
    if resolved_set:
        # Quote-wrap the set name so eBay treats it as an exact phrase.
        parts.append(f'"{resolved_set}"')
        # Append set-specific exclusions to prevent cross-set contamination.
        excl = _SET_EXCLUSIONS.get(resolved_set, "")
        if excl:
            parts.append(excl)
        # Year anchor for the original 1999 Base Set to surface vintage listings
        # and push Celebrations / Classic Collection reprints out of results.
        if resolved_set == "Base Set":
            parts.append("1999")

    parts.append(card_name.strip())
    if number:
        parts.append(number.strip())

    # Variant hint from rarity
    rarity_lower = rarity.lower()
    variant_hint = next(
        (kw for key, kw in _RARITY_KEYWORDS.items() if key in rarity_lower), ""
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

    if mode == FetchMode.RAW:
        # Raw: include condition hints, hard-exclude all grading companies
        raw_hints = ["raw", "ungraded", "nm", "near mint"]
        all_hints = list(dict.fromkeys(filter(None, [variant_hint] + tag_hints + raw_hints)))
        if all_hints:
            parts.append(f"({', '.join(all_hints)})")
        parts.append("-psa -cgc -bgs -graded -slab -cert")
        parts.append("-lot -bundle -digital -code -keychain")

    # GRADED queries are handled by build_graded_query() below — this branch
    # is only reached for RAW or BOTH (BOTH delegates to raw + graded separately).

    return " ".join(parts)


def build_graded_query(
    card_name:      str,
    set_name:       str,
    number:         str,
    specialty_tags: list[str] | None = None,
    tier:           int = 1,
) -> str:
    """
    Build a graded-specific eBay query.

    Tier 1 (primary):  "{set} {name} {number} PSA 10 -lot -bundle -digital"
    Tier 2 (fallback): "{set} {name} {number} graded  -lot -bundle -digital"

    Specialty tags (1st edition, shadowless) are appended before the grade term
    so eBay sees them as must-include context.
    """
    parts: list[str] = []

    resolved_set = _SET_ID_TO_NAME.get(set_name.strip(), set_name.strip())
    if resolved_set:
        parts.append(f'"{resolved_set}"')
        excl = _SET_EXCLUSIONS.get(resolved_set, "")
        if excl:
            parts.append(excl)
        # "1999" year anchor for the original Base Set to push results toward
        # the vintage market and away from modern reprints/Celebrations.
        if resolved_set == "Base Set":
            parts.append("1999")

    parts.append(card_name.strip())
    if number:
        parts.append(number.strip())

    # Specialty context
    if specialty_tags:
        if "1st_edition" in specialty_tags:
            parts.append("\"1st edition\"")
        if "shadowless" in specialty_tags:
            parts.append("shadowless")
        if "japanese" in specialty_tags:
            parts.append("japanese")

    # Grade term — kept as plain words (not parenthetical) so eBay treats
    # them as required rather than optional OR terms.
    if tier == 1:
        parts.append("PSA 10")
    else:
        parts.append("graded")

    parts.append("-lot -bundle -digital -code -keychain")
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

    # ── Debug output — paste the URL into a browser to verify results ──────
    print(f"  DEBUG URL  : {resp.url}")

    if not resp.ok:
        try:
            err_body = resp.json()
            log.error("eBay Browse API %s — %s", resp.status_code, err_body)
        except Exception:
            log.error("eBay Browse API %s — %s", resp.status_code, resp.text[:400])
        resp.raise_for_status()

    data  = resp.json()
    total = data.get("total", 0)
    print(f"  DEBUG TOTAL: {total} results found by eBay")

    return data.get("itemSummaries", [])


def fetch_graded_with_fallback(
    card_name:      str,
    set_name:       str,
    number:         str,
    client_id:      str,
    client_secret:  str,
    specialty_tags: list[str] | None = None,
    max_results:    int = _MAX_RESULTS,
) -> tuple[list[dict], str, int]:
    """
    Two-tier graded fetch.

    Tier 1: '"{set}" {exclusions} {name} {number} PSA 10 -lot -bundle -digital'
    Tier 2: '"{set}" {exclusions} {name} {number} graded  -lot -bundle -digital'
            (tried only when tier 1 returns 0 results)

    Returns (items, query_used, tier_used).
    """
    q1    = build_graded_query(card_name, set_name, number, specialty_tags, tier=1)
    items = fetch_sold_listings(q1, client_id, client_secret, max_results)

    if items:
        return items, q1, 1

    print("  Tier 1 returned 0 — trying fallback query …")
    q2    = build_graded_query(card_name, set_name, number, specialty_tags, tier=2)
    items = fetch_sold_listings(q2, client_id, client_secret, max_results)
    return items, q2, 2


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


def extract_graded_prices(
    items:    list[dict],
    verbose:  bool = True,
    set_name: str  = "",
) -> dict:
    """
    Score each eBay item title using the grade hierarchy and bucket prices.

    Rules:
    - validate_set_in_title() discards titles contaminated by rival sets
      (e.g. "Base Set 2" results when fetching for "Base Set").
    - Each title is classified by classify_title() — first regex match wins.
    - 'other' titles (company present, grade unclear) are DISCARDED.
    - None titles (no grading company) are DISCARDED.
    - Shipping is stripped from every price before bucketing.
    - detect_base_set_subvariant() labels each result as 1st_edition,
      shadowless, or unlimited for the Base Set sub-variant breakdown.

    Returns:
        {
          'psa10': [...], 'psa9': [...], 'psa8': [...], 'other': [...],
          'subvariants': {
              '1st_edition': {'psa10': [...], 'psa9': [...], 'psa8': [...]},
              'shadowless':  {'psa10': [...], 'psa9': [...], 'psa8': [...]},
              'unlimited':   {'psa10': [...], 'psa9': [...], 'psa8': [...]},
          }
        }
        All lists are newest-first (API sort: newlyListed).
    """
    buckets: dict = {
        "psa10": [], "psa9": [], "psa8": [], "other": [],
        "subvariants": {
            "1st_edition": {"psa10": [], "psa9": [], "psa8": []},
            "shadowless":  {"psa10": [], "psa9": [], "psa8": []},
            "unlimited":   {"psa10": [], "psa9": [], "psa8": []},
        },
    }

    # Resolve raw set ID to human name so blocklist lookup works consistently.
    resolved_set = _SET_ID_TO_NAME.get(set_name.strip(), set_name.strip())

    for item in items:
        title  = item.get("title", "").strip()

        # ── Set contamination guard ────────────────────────────────────────
        if resolved_set and not validate_set_in_title(title, resolved_set):
            if verbose:
                print(f'  DISCARD (wrong set "{resolved_set}"): "{title[:70]}"')
            else:
                log.debug("DISCARD (wrong set %s): %s", resolved_set, title[:70])
            continue

        bucket = classify_title(title)

        # ── Hard discard ─────────────────────────────────────────────────
        if bucket is None:
            log.debug("SKIP (no grading company): %s", title[:70])
            continue
        if bucket == "other":
            if verbose:
                print(f'  DISCARD (grade unclear): "{title[:70]}"')
            else:
                log.debug("DISCARD (grade unclear): %s", title[:70])
            continue

        # ── Price extraction ──────────────────────────────────────────────
        try:
            item_price = float(item["price"]["value"])
        except (KeyError, TypeError, ValueError):
            continue

        shipping = 0.0
        try:
            opts = item.get("shippingOptions", [])
            if opts:
                shipping = float(
                    opts[0].get("shippingCost", {}).get("value", 0)
                )
        except (TypeError, ValueError):
            pass

        net = round(item_price - shipping, 2)
        if net < 0:
            continue

        buckets[bucket].append(net)

        # ── Sub-variant detection ─────────────────────────────────────────
        subvariant = detect_base_set_subvariant(title)
        if bucket in buckets["subvariants"].get(subvariant, {}):
            buckets["subvariants"][subvariant][bucket].append(net)

        # ── Real-time classification printout ────────────────────────────
        if verbose:
            label_map = {
                "psa10": "PSA 10 / GEM",
                "psa9":  "PSA 9",
                "psa8":  "PSA 8",
            }
            sv_label = {
                "1st_edition": "  [1st Edition]",
                "shadowless":  "  [Shadowless]",
                "unlimited":   "",
            }.get(subvariant, "")
            print(f'  Found: "{title[:75]}"')
            print(f"  -> Classified as: {label_map.get(bucket, bucket)}{sv_label}")
            print(f"  -> Price: ${net:,.2f}")
            print(f"  {'-'*50}")

    return buckets


def median_of_last_n(prices: list[float], n: int = _MEDIAN_SAMPLE) -> float | None:
    """Return the median of the last (most recent) n prices."""
    sample = prices[:n]   # API returns newest first (newlyListed sort)
    if not sample:
        return None
    return statistics.median(sample)


# ---------------------------------------------------------------------------
# Firestore helpers
# ---------------------------------------------------------------------------

def update_firestore_raw(
    db, card_id: str, median_price: float, collection: str = "cards"
) -> None:
    """Write pricing.ebay_us.raw.last_sold + last_updated to Firestore."""
    from google.cloud.firestore_v1 import SERVER_TIMESTAMP  # type: ignore

    ref = db.collection(collection).document(card_id)
    ref.set(
        {
            "pricing": {
                "ebay_us": {
                    "raw": {
                        "last_sold":    round(median_price, 2),
                        "last_updated": SERVER_TIMESTAMP,
                    }
                }
            }
        },
        merge=True,
    )
    log.info("  [%s] RAW median = $%.2f → Firestore updated", card_id, median_price)


def update_firestore_graded(
    db,
    card_id:     str,
    psa10:       float | None,
    psa9:        float | None,
    psa8:        float | None = None,
    collection:  str = "cards",
    subvariants: dict | None = None,
) -> None:
    """
    Write pricing.ebay_us.graded.{psa10, psa9, psa8, last_updated} to Firestore.
    Only writes fields that have a value — preserves any existing fields.

    If subvariants is provided (from extract_graded_prices), also writes:
        pricing.ebay_us.graded.subvariants.{1st_edition,shadowless,unlimited}.{psa10,psa9,psa8}
    """
    from google.cloud.firestore_v1 import SERVER_TIMESTAMP  # type: ignore

    graded: dict = {"last_updated": SERVER_TIMESTAMP}
    if psa10 is not None:
        graded["psa10"] = round(psa10, 2)
    if psa9 is not None:
        graded["psa9"]  = round(psa9,  2)
    if psa8 is not None:
        graded["psa8"]  = round(psa8,  2)

    # Sub-variant breakdown (Base Set: 1st edition / shadowless / unlimited)
    if subvariants:
        sv_map: dict = {}
        for variant_key, grade_prices in subvariants.items():
            sv_entry: dict = {}
            for grade_key, prices in grade_prices.items():
                med = median_of_last_n(prices)
                if med is not None:
                    sv_entry[grade_key] = round(med, 2)
            if sv_entry:
                sv_map[variant_key] = sv_entry
        if sv_map:
            graded["subvariants"] = sv_map

    ref = db.collection(collection).document(card_id)
    ref.set({"pricing": {"ebay_us": {"graded": graded}}}, merge=True)

    parts = [
        f"PSA10=${psa10:.2f}" if psa10 is not None else None,
        f"PSA9=${psa9:.2f}"   if psa9  is not None else None,
        f"PSA8=${psa8:.2f}"   if psa8  is not None else None,
    ]
    log.info(
        "  [%s] GRADED %s → Firestore updated",
        card_id,
        ", ".join(p for p in parts if p) or "no data",
    )


def flag_high_scarcity(
    db,
    card_id:    str,
    mode:       FetchMode = FetchMode.BOTH,
    collection: str = "cards",
) -> None:
    """
    eBay returned 0 sold results.
    Adds 'high_scarcity' tag and writes null prices with a scarcity note.
    """
    from google.cloud.firestore_v1 import ArrayUnion, SERVER_TIMESTAMP  # type: ignore

    ebay_update: dict = {}
    if mode in (FetchMode.RAW, FetchMode.BOTH):
        ebay_update["raw"] = {"last_sold": None, "last_updated": SERVER_TIMESTAMP}
    if mode in (FetchMode.GRADED, FetchMode.BOTH):
        ebay_update["graded"] = {"psa10": None, "psa9": None, "last_updated": SERVER_TIMESTAMP}

    ref = db.collection(collection).document(card_id)
    ref.set(
        {
            "meta": {
                "specialty_tags": ArrayUnion(["high_scarcity"]),
                "scarcity_note":  "High Scarcity: Manual Verification Required",
            },
            "pricing": {"ebay_us": ebay_update},
        },
        merge=True,
    )
    log.warning("  [%s] 0 results (%s) → High Scarcity flagged", card_id, mode.value)


# ---------------------------------------------------------------------------
# Top-level enrichment function (called by kaggle_import.py)
# ---------------------------------------------------------------------------

def enrich_with_ebay_price(
    doc:           dict,
    client_id:     str,
    client_secret: str,
    mode:          FetchMode = FetchMode.BOTH,
) -> dict:
    """
    Fetch eBay sold prices for a card and inject the result into the doc dict
    before it is written to Firestore by kaggle_import.py.

    Runs RAW and/or GRADED queries depending on mode and writes results to:
        pricing.ebay_us.raw.last_sold
        pricing.ebay_us.graded.psa10
        pricing.ebay_us.graded.psa9
    """
    meta   = doc.get("meta", {})
    name   = meta.get("name", "")
    set_id = meta.get("set_id", "")
    number = meta.get("set_number", "")
    rarity = meta.get("variant", "")
    tags   = meta.get("specialty_tags", [])
    now    = datetime.now(timezone.utc).isoformat()

    doc.setdefault("pricing", {}).setdefault("ebay_us", {})
    ebay = doc["pricing"]["ebay_us"]

    def _fetch(m: FetchMode) -> list[dict]:
        q = build_query(name, set_id, number, rarity, tags, mode=m)
        log.debug("eBay [%s] query: %s", m.value, q)
        try:
            return fetch_sold_listings(q, client_id, client_secret)
        except Exception as exc:
            log.debug("eBay API error [%s] for '%s': %s", m.value, name, exc)
            return []

    # ── RAW ───────────────────────────────────────────────────────────────
    if mode in (FetchMode.RAW, FetchMode.BOTH):
        items  = _fetch(FetchMode.RAW)
        prices = extract_prices(items)
        median = median_of_last_n(prices)
        if median is not None:
            ebay["raw"] = {"last_sold": round(median, 2), "last_updated": now}
            log.info("  %-38s  RAW=$%.2f", name[:38], median)
        else:
            ebay["raw"] = {"last_sold": None, "last_updated": now}
            log.warning("  %-38s  RAW=0 results", name[:38])

    # ── GRADED (two-tier fallback) ─────────────────────────────────────────
    if mode in (FetchMode.GRADED, FetchMode.BOTH):
        items, graded_q, tier = fetch_graded_with_fallback(
            name, set_id, number, client_id, client_secret, tags
        )
        log.debug("eBay graded (tier %d): %s", tier, graded_q)
        buckets = extract_graded_prices(items, verbose=False, set_name=set_id)
        psa10   = median_of_last_n(buckets["psa10"])
        psa9    = median_of_last_n(buckets["psa9"])
        psa8    = median_of_last_n(buckets["psa8"])
        graded: dict = {"last_updated": now}
        if psa10 is not None:
            graded["psa10"] = round(psa10, 2)
        if psa9 is not None:
            graded["psa9"]  = round(psa9,  2)
        if psa8 is not None:
            graded["psa8"]  = round(psa8,  2)
        # Sub-variant breakdown (populated when set_id is Base Set / WotC era)
        sv_map: dict = {}
        for variant_key, grade_prices in buckets.get("subvariants", {}).items():
            sv_entry: dict = {}
            for grade_key, prices in grade_prices.items():
                med = median_of_last_n(prices)
                if med is not None:
                    sv_entry[grade_key] = round(med, 2)
            if sv_entry:
                sv_map[variant_key] = sv_entry
        if sv_map:
            graded["subvariants"] = sv_map
        ebay["graded"] = graded
        log.info(
            "  %-34s  PSA10=%s  PSA9=%s  PSA8=%s  (tier %d)",
            name[:34],
            f"${psa10:.2f}" if psa10 else "—",
            f"${psa9:.2f}"  if psa9  else "—",
            f"${psa8:.2f}"  if psa8  else "—",
            tier,
        )

    # ── Scarcity flag ─────────────────────────────────────────────────────
    raw_sold    = ebay.get("raw",    {}).get("last_sold")
    graded_data = ebay.get("graded", {})
    has_any_price = raw_sold is not None or graded_data.get("psa10") or graded_data.get("psa9")

    if not has_any_price:
        doc["meta"].setdefault("specialty_tags", [])
        if "high_scarcity" not in doc["meta"]["specialty_tags"]:
            doc["meta"]["specialty_tags"].append("high_scarcity")
        doc["meta"]["scarcity_note"] = "High Scarcity: Manual Verification Required"
        log.warning("  %-38s  No prices found → high_scarcity", name[:38])

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


# ---------------------------------------------------------------------------
# Set contamination — exclusions and title validation
# ---------------------------------------------------------------------------

# When searching for a specific set, append these exclusion terms so eBay
# doesn't return cards from other sets that share the same card number.
_SET_EXCLUSIONS: dict[str, str] = {
    # Original WotC Base Set — exclude rival WotC sets AND 2021 Celebrations reprints.
    "Base Set": (
        '-"Base Set 2" -"Legendary Collection" -LC'
        ' -Classic -Celebrations -25th -Anniversary -Reprint'
    ),
    "Base Set 2":           '-"Legendary Collection" -"Team Rocket"',
    "Legendary Collection": '-"Base Set 2" -"Base Set"',
    "Team Rocket":          '-"Base Set" -"Base Set 2" -"Legendary Collection"',
    "Jungle":               '-"Base Set" -"Fossil"',
    "Fossil":               '-"Jungle" -"Base Set"',
}

# After fetching, discard any eBay title that contains these phrases for the
# given set — catches listings that slip past the query exclusions.
_SET_TITLE_BLOCKLIST: dict[str, list[str]] = {
    # Original 1999 WotC Base Set — hard-discard anything that looks like a
    # rival WotC set or a 2021 Celebrations / Classic Collection reprint.
    "Base Set": [
        "base set 2",
        "legendary collection",
        "legendary coll",
        " lc ",           # "LC" abbreviation surrounded by spaces
        "celebrations",   # 2021 Pokémon 25th anniversary reprint set
        "classic",        # "Classic Collection" subset of Celebrations
        "25th",           # anniversary sub-branding
        "anniversary",    # catches "25th Anniversary" and similar
    ],
    "Base Set 2": [
        "legendary collection",
    ],
}


def validate_set_in_title(title: str, set_name: str) -> bool:
    """
    Return True only if the title is NOT contaminated by a rival set.

    Call this after fetching eBay results to discard cross-set pollution
    that slipped past the query exclusions.
    """
    blocklist = _SET_TITLE_BLOCKLIST.get(set_name, [])
    title_lower = title.lower()
    for phrase in blocklist:
        if phrase.lower() in title_lower:
            return False
    return True


# ---------------------------------------------------------------------------
# Base Set sub-variant detection
# ---------------------------------------------------------------------------

_1ST_EDITION_RE = re.compile(
    r'\b1st\s*(?:edition|ed\.?)\b',
    re.IGNORECASE,
)
_SHADOWLESS_RE = re.compile(
    r'\bshadowless\b',
    re.IGNORECASE,
)


def detect_base_set_subvariant(title: str) -> str:
    """
    Detect the Base Set sub-variant printed in an eBay listing title.

    Returns:
        '1st_edition'  — title contains "1st Edition" / "1st Ed"
        'shadowless'   — title contains "Shadowless"
        'unlimited'    — neither marker found (standard unlimited print)

    Only meaningful for Base Set / early WotC-era cards.
    """
    if _1ST_EDITION_RE.search(title):
        return '1st_edition'
    if _SHADOWLESS_RE.search(title):
        return 'shadowless'
    return 'unlimited'


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
        "--mode",
        choices=["raw", "graded", "both"],
        default="both",
        help="Which prices to fetch: raw, graded, or both (default: both)",
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
    mode:          FetchMode = FetchMode.BOTH,
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
                name   = name_override or meta.get("name",       "")
                set_id = set_override  or meta.get("set_id",     "")
                number = num_override  or meta.get("set_number", "")
                rarity = rar_override  or meta.get("variant",    "")
                tags   = meta.get("specialty_tags", [])
            else:
                log.warning("Card not in Firestore — falling back to card ID parsing")

        if not set_id or not number:
            parsed_set, parsed_num = _parse_card_id(card_id)
            set_id = set_id or _SET_ID_TO_NAME.get(parsed_set, parsed_set)
            number = number or parsed_num

    print(f"\nCard   : {name or card_id}  [{card_id}]  mode={mode.value}")

    def _run_mode(m: FetchMode) -> None:
        if m == FetchMode.GRADED:
            # Graded uses its own two-tier builder — skip build_query
            items = []  # populated inside the GRADED branch below
        else:
            q     = build_query(name, set_id, number, rarity, tags, mode=m)
            print(f"Query [{m.value:6}]: {q}")
            items = fetch_sold_listings(q, client_id, client_secret)

        if m == FetchMode.RAW:
            prices = extract_prices(items)
            median = median_of_last_n(prices)
            print(f"  Prices : {[f'${p:.2f}' for p in prices[:5]]}")
            if median is not None:
                print(f"  Median : ${median:.2f}")
                if not dry_run:
                    update_firestore_raw(db, card_id, median, collection)
            else:
                print("  Median : N/A — 0 results")
                if not dry_run:
                    flag_high_scarcity(db, card_id, FetchMode.RAW, collection)

        elif m == FetchMode.GRADED:
            items, graded_q, tier = fetch_graded_with_fallback(
                name, set_id, number, client_id, client_secret, tags
            )
            print(f"  Query used (tier {tier}): {graded_q}")
            # verbose=True → prints classification for each item in real-time
            buckets = extract_graded_prices(items, verbose=True, set_name=set_id)
            psa10   = median_of_last_n(buckets["psa10"])
            psa9    = median_of_last_n(buckets["psa9"])
            psa8    = median_of_last_n(buckets["psa8"])
            print()
            print(f"  ── Grade Summary ──────────────────────────────────")
            print(f"  PSA10 median : {'$'+f'{psa10:.2f}' if psa10 else 'N/A'}  ({len(buckets['psa10'])} sales)")
            print(f"  PSA9  median : {'$'+f'{psa9:.2f}'  if psa9  else 'N/A'}  ({len(buckets['psa9'])} sales)")
            print(f"  PSA8  median : {'$'+f'{psa8:.2f}'  if psa8  else 'N/A'}  ({len(buckets['psa8'])} sales)")
            print(f"  Discarded    : {len(buckets['other'])} titles (grade unclear)")
            # Sub-variant breakdown (non-empty only)
            sv = buckets.get("subvariants", {})
            has_sv = any(
                any(prices for prices in gp.values())
                for gp in sv.values()
            )
            if has_sv:
                print(f"  ── Sub-variant Breakdown ──────────────────────────")
                for sv_key, gp in sv.items():
                    sv_label = {"1st_edition": "1st Edition", "shadowless": "Shadowless", "unlimited": "Unlimited"}.get(sv_key, sv_key)
                    p10 = median_of_last_n(gp.get("psa10", []))
                    p9  = median_of_last_n(gp.get("psa9",  []))
                    p8  = median_of_last_n(gp.get("psa8",  []))
                    if p10 or p9 or p8:
                        print(f"  {sv_label:14} PSA10={'$'+f'{p10:.2f}' if p10 else 'N/A':<10}  PSA9={'$'+f'{p9:.2f}' if p9 else 'N/A':<10}  PSA8={'$'+f'{p8:.2f}' if p8 else 'N/A'}")
            if psa10 or psa9 or psa8:
                if not dry_run:
                    update_firestore_graded(
                        db, card_id, psa10, psa9, psa8, collection,
                        subvariants=buckets.get("subvariants"),
                    )
            else:
                print("  No graded results on either tier")
                if not dry_run:
                    flag_high_scarcity(db, card_id, FetchMode.GRADED, collection)

            # Grading Alpha insight
            if psa10 and name:
                raw_field = (
                    (db.collection(collection).document(card_id).get().to_dict() or {})
                    .get("pricing", {}).get("ebay_us", {}).get("raw", {}).get("last_sold")
                    if db else None
                )
                if raw_field:
                    alpha = psa10 - raw_field
                    print(f"  ★ Grading Alpha: PSA10 ${psa10:.2f} - Raw ${raw_field:.2f} = ${alpha:.2f}")

    if mode == FetchMode.BOTH:
        _run_mode(FetchMode.RAW)
        _run_mode(FetchMode.GRADED)
    else:
        _run_mode(mode)

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

    cid     = args.ebay_client_id
    csecret = args.ebay_client_secret
    mode    = FetchMode(args.mode)

    if args.card_id:
        _process_single(
            db, args.card_id, cid, csecret, args.collection, args.dry_run,
            mode=mode,
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
                _process_single(db, card_id, cid, csecret, args.collection, args.dry_run, mode=mode)
            except Exception as exc:
                log.error("  Failed: %s", exc)

            time.sleep(args.delay)

    log.info("Done.")


if __name__ == "__main__":
    main()
