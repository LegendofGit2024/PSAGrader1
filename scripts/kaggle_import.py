"""
Kaggle Pokémon TCG Dataset → Firestore Importer
================================================
Hardened for the Priyam Choksi "Pokemon Cards" Kaggle dataset
(pokemontcg.io API data dump).  Also works with any CSV that has an `id`
column using the pokemontcg.io card-ID format (e.g. "base1-4").

Column layout expected (Priyam Choksi dataset)
----------------------------------------------
id                                  ← becomes the Firestore document ID
name
number
rarity
set.id
set.name
images.small
images.large                        ← stored as meta.image_url
tcgplayer.prices.normal.market
tcgplayer.prices.holofoil.market
cardmarket.prices.averageSellPrice

Specialty-tag auto-detection
-----------------------------
  "japanese"    → specialty_tags: ["japanese"]
  "1st edition" → specialty_tags: ["1st_edition"]
  "error"       → specialty_tags: ["error"]
  "shadowless"  → specialty_tags: ["shadowless"]
  "promo"       → specialty_tags: ["promo"]

Usage (PowerShell)
------------------
  # Dry run — prints first 10 rows, no Firestore writes:
  python scripts\\kaggle_import.py --csv "C:\\Users\\natha\\Downloads\\dataset 1 pokemon core\\pokemon-cards.csv" --dry-run

  # Full import with eBay price fetch:
  python scripts\\kaggle_import.py --csv "C:\\Users\\natha\\Downloads\\dataset 1 pokemon core\\pokemon-cards.csv" --service-account "service-account.json" --fetch-ebay

  # Import only (no eBay):
  python scripts\\kaggle_import.py --csv "C:\\Users\\natha\\Downloads\\dataset 1 pokemon core\\pokemon-cards.csv" --service-account "service-account.json"

  # Preview columns detected in your CSV:
  python scripts\\kaggle_import.py --csv "C:\\Users\\natha\\Downloads\\dataset 1 pokemon core\\pokemon-cards.csv" --show-columns
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import sys
import time
import uuid
from pathlib import Path
from typing import Any

import pandas as pd
from tqdm import tqdm

# ---------------------------------------------------------------------------
# Optional firebase-admin
# ---------------------------------------------------------------------------
try:
    import firebase_admin
    from firebase_admin import credentials, firestore as fb_firestore
    _FIREBASE_AVAILABLE = True
except ImportError:
    _FIREBASE_AVAILABLE = False

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("kaggle_import")

# ---------------------------------------------------------------------------
# Priyam Choksi column mapping
# Lists are tried in order — first match wins.
# ---------------------------------------------------------------------------
_COLUMN_ALIASES: dict[str, list[str]] = {
    # Firestore doc ID — MUST be the pokemontcg.io id (e.g. "base1-4")
    "id":            ["id", "card_id", "cardId"],
    "name":          ["name", "card_name", "cardName"],
    "set_id":        ["set.id", "set_id", "setId", "set"],
    "set_name":      ["set.name", "set_name", "setName"],
    "number":        ["number", "card_number", "cardNumber", "num"],
    "rarity":        ["rarity"],
    # Images — images.large is the pokemontcg.io column name
    "image_large":   ["images.large", "image_large", "imageLarge",
                      "largeImageUrl", "large_image_url"],
    "image_small":   ["images.small", "image_small", "imageSmall",
                      "smallImageUrl", "small_image_url"],
    "language":      ["language", "lang"],
    # TCGPlayer pricing
    "tcg_nm":        ["tcgplayer.prices.normal.market",
                      "tcgplayer_nm", "tcg_market_nm"],
    "tcg_holofoil":  ["tcgplayer.prices.holofoil.market",
                      "tcgplayer_holo", "tcg_market_holo"],
    "tcg_1sted":     ["tcgplayer.prices.1stEditionHolofoil.market",
                      "tcgplayer.prices.1stEditionNormal.market"],
    # Cardmarket pricing
    "cm_trend":      ["cardmarket.prices.averageSellPrice",
                      "cardmarket.prices.trendPrice",
                      "cardmarket_trend", "cm_avg_sell"],
}

# ---------------------------------------------------------------------------
# Specialty tag rules
# ---------------------------------------------------------------------------
SPECIALTY_RULES: list[tuple[re.Pattern, str]] = [
    (re.compile(r"japanese",     re.IGNORECASE), "japanese"),
    (re.compile(r"1st\s*edition",re.IGNORECASE), "1st_edition"),
    (re.compile(r"\berror\b",    re.IGNORECASE), "error"),
    (re.compile(r"shadowless",   re.IGNORECASE), "shadowless"),
    (re.compile(r"\bpromo\b",    re.IGNORECASE), "promo"),
]


def compute_specialty_tags(name: str, set_name: str = "", rarity: str = "") -> list[str]:
    haystack = f"{name} {set_name} {rarity}"
    return [tag for pat, tag in SPECIALTY_RULES if pat.search(haystack)]


# ---------------------------------------------------------------------------
# Column resolution
# ---------------------------------------------------------------------------

def resolve_columns(
    df: pd.DataFrame,
    overrides: dict[str, str | None],
) -> dict[str, str | None]:
    """Return {logical_field: actual_df_column} for every field."""
    resolved: dict[str, str | None] = {}
    for field, aliases in _COLUMN_ALIASES.items():
        # CLI override takes priority
        override = overrides.get(field)
        if override and override in df.columns:
            resolved[field] = override
            log.info("  %-14s → %s  (override)", field, override)
            continue
        # Auto-detect from alias list
        match = next((a for a in aliases if a in df.columns), None)
        resolved[field] = match
        if match:
            log.info("  %-14s → %s", field, match)
        else:
            log.warning("  %-14s → (not found)", field)
    return resolved


def _get(row: pd.Series, col: str | None, default: Any = None) -> Any:
    if col is None:
        return default
    val = row.get(col, default)
    return default if (isinstance(val, float) and pd.isna(val)) else val


def _try_float(val: Any) -> float | None:
    try:
        f = float(val)
        return f if f >= 0 else None
    except (TypeError, ValueError):
        return None


# ---------------------------------------------------------------------------
# Row → Firestore document
# ---------------------------------------------------------------------------

def row_to_doc(
    row: pd.Series,
    cols: dict[str, str | None],
    language_default: str,
) -> tuple[str, dict]:
    """
    Returns (card_id, doc_dict).

    card_id  ← the value of the 'id' column (e.g. "base1-4").
               This becomes the Firestore /cards/{card_id} document ID.
               If the column is missing or blank a UUID is generated, but
               that should never happen with the Priyam Choksi dataset.

    doc_dict ← exactly the shape expected by CardDocument.fromFirestore()
               in the Flutter app (snake_case field names under meta/pricing).
    """
    # ── Identity ──────────────────────────────────────────────────────────
    card_id = str(_get(row, cols["id"], "")).strip()
    if not card_id or card_id.lower() in ("nan", "none", ""):
        card_id = str(uuid.uuid4())
        log.debug("Missing id — generated UUID %s", card_id)

    name      = str(_get(row, cols["name"],     "Unknown")).strip()
    set_id    = str(_get(row, cols["set_id"],   "")).strip()
    set_name  = str(_get(row, cols["set_name"], "")).strip()
    number    = str(_get(row, cols["number"],   "")).strip()
    rarity    = str(_get(row, cols["rarity"],   "")).strip()

    # ── Image URL ─────────────────────────────────────────────────────────
    # Prefer images.large → images.small → empty string
    # Stored as meta.image_url (JsonKey in CardMeta), which the Flutter app
    # reads as CardMeta.imageUrl.  The TcgCard.largeImageUrl field is only
    # used for the in-memory search result model, not Firestore.
    image_url = (
        str(_get(row, cols["image_large"], None) or
            _get(row, cols["image_small"], "") or "")
        .strip()
    )

    # ── Language ──────────────────────────────────────────────────────────
    lang_raw  = str(_get(row, cols["language"], language_default)).strip().lower()
    language  = lang_raw if lang_raw in ("en", "jp", "kr", "zh") else "en"

    # ── Specialty tags ────────────────────────────────────────────────────
    specialty_tags = compute_specialty_tags(name, set_name, rarity)

    # ── Pricing ───────────────────────────────────────────────────────────
    tcg_nm   = _try_float(_get(row, cols["tcg_nm"]))
    tcg_holo = _try_float(_get(row, cols["tcg_holofoil"]))
    tcg_1st  = _try_float(_get(row, cols["tcg_1sted"]))
    cm_trend = _try_float(_get(row, cols["cm_trend"]))

    # Best TCGPlayer price: prefer 1st-edition > holofoil > normal
    best_tcg = tcg_1st or tcg_holo or tcg_nm

    pricing: dict = {}
    if best_tcg is not None:
        pricing["tcgplayer_us"] = {"market_nm": best_tcg, "updated_at": None}
    if cm_trend is not None:
        pricing["cardmarket_eu"] = {"trend_price": cm_trend, "updated_at": None}

    # ── Assemble document ─────────────────────────────────────────────────
    doc: dict = {
        # NOTE: 'id' is included here so CardDocument.fromFirestore() can read
        # it via fromJson.  toFirestore() strips it before writing (the doc ID
        # IS the Firestore document key, not a field on the document body).
        "id": card_id,
        "meta": {
            "name":           name,
            "set_id":         set_id,
            "set_number":     number,
            "language":       language,
            "variant":        rarity,
            "image_url":      image_url,   # ← maps to CardMeta.imageUrl
            "specialty_tags": specialty_tags,
        },
        "pricing": pricing,
    }

    return card_id, doc


# ---------------------------------------------------------------------------
# Firestore writer
# ---------------------------------------------------------------------------

def write_batches(
    db,
    docs: list[tuple[str, dict]],
    batch_size: int,
    collection: str,
    fetch_ebay: bool,
    ebay_app_id: str,
) -> None:
    from scripts.ebay_price_fetcher import enrich_with_ebay_price  # lazy import

    total   = len(docs)
    written = 0

    for i in tqdm(range(0, total, batch_size), desc="Writing batches"):
        batch = db.batch()
        chunk = docs[i: i + batch_size]

        for card_id, doc in chunk:
            if fetch_ebay:
                doc = enrich_with_ebay_price(doc, ebay_app_id)

            ref = db.collection(collection).document(card_id)
            # merge=True preserves any existing fields (e.g. PSA pop data)
            batch.set(ref, doc, merge=True)

        batch.commit()
        written += len(chunk)
        log.info("Committed %d / %d", written, total)
        time.sleep(0.2)   # stay inside Firestore sustained-write quota


def write_batches_no_ebay(
    db,
    docs: list[tuple[str, dict]],
    batch_size: int,
    collection: str,
) -> None:
    total   = len(docs)
    written = 0

    for i in tqdm(range(0, total, batch_size), desc="Writing batches"):
        batch = db.batch()
        for card_id, doc in docs[i: i + batch_size]:
            ref = db.collection(collection).document(card_id)
            batch.set(ref, doc, merge=True)
        batch.commit()
        written += len(i, i + batch_size).__len__()  # noqa — handled below
        written = i + batch_size if i + batch_size < total else total
        log.info("Committed %d / %d", written, total)
        time.sleep(0.2)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

_DEFAULT_CSV = (
    r"C:\Users\natha\Downloads\dataset 1 pokemon core\pokemon-cards.csv"
)


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Import Priyam Choksi Pokémon TCG CSV into Firestore.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument(
        "--csv",
        default=_DEFAULT_CSV,
        help=f"Path to CSV file (default: {_DEFAULT_CSV})",
    )
    p.add_argument(
        "--service-account",
        default=os.environ.get(
            "GOOGLE_APPLICATION_CREDENTIALS", "service-account.json"
        ),
        help="Firebase service-account JSON path",
    )
    p.add_argument(
        "--collection", default="cards",
        help="Firestore collection name (default: cards)",
    )
    p.add_argument(
        "--batch-size", type=int, default=400,
        help="Docs per Firestore batch — max 500 (default: 400)",
    )
    p.add_argument(
        "--language-default", default="en",
        choices=["en", "jp", "kr", "zh"],
        help="Language tag when the CSV has no language column (default: en)",
    )
    p.add_argument(
        "--limit", type=int, default=0,
        help="Only import the first N rows — 0 means all (default: 0)",
    )
    p.add_argument(
        "--dry-run", action="store_true",
        help="Parse CSV and print preview without writing to Firestore",
    )
    p.add_argument(
        "--show-columns", action="store_true",
        help="Print every column name in the CSV then exit",
    )
    p.add_argument(
        "--fetch-ebay", action="store_true",
        help="Fetch eBay sold prices and store median in pricing.ebay_us",
    )
    p.add_argument(
        "--ebay-app-id",
        default=os.environ.get("EBAY_APP_ID", ""),
        help="eBay developer App ID (or set EBAY_APP_ID env var)",
    )
    # Per-field column overrides
    for field in _COLUMN_ALIASES:
        p.add_argument(
            f"--col-{field.replace('_', '-')}",
            dest=f"col_{field}",
            default=None,
            metavar="COLUMN",
            help=f"Override detected column for '{field}'",
        )
    return p


def main() -> None:
    parser = build_parser()
    args   = parser.parse_args()

    # ── Load CSV ──────────────────────────────────────────────────────────
    csv_path = Path(args.csv)
    if not csv_path.exists():
        log.error("CSV not found: %s", csv_path)
        sys.exit(1)

    log.info("Reading %s …", csv_path)
    df = pd.read_csv(csv_path, low_memory=False)
    log.info("Loaded %d rows × %d columns", len(df), len(df.columns))

    if args.show_columns:
        print("\nColumns in your CSV:")
        for col in sorted(df.columns):
            print(f"  {col}")
        return

    if args.limit > 0:
        df = df.head(args.limit)
        log.info("Capped at first %d rows", args.limit)

    # ── Resolve columns ───────────────────────────────────────────────────
    log.info("Resolving column mapping …")
    overrides = {
        field: getattr(args, f"col_{field}", None)
        for field in _COLUMN_ALIASES
    }
    cols = resolve_columns(df, overrides)

    if cols["id"] is None:
        log.error(
            "No 'id' column found — cannot create Firestore document IDs. "
            "Use --col-id <column_name> to specify it."
        )
        sys.exit(1)

    # ── Parse rows ────────────────────────────────────────────────────────
    log.info("Parsing rows …")
    docs: list[tuple[str, dict]] = []
    errors = 0
    for _, row in tqdm(df.iterrows(), total=len(df), desc="Parsing"):
        try:
            docs.append(row_to_doc(row, cols, args.language_default))
        except Exception as exc:
            log.debug("Row parse error: %s", exc)
            errors += 1

    log.info("Parsed %d docs (%d errors skipped)", len(docs), errors)

    # Specialty tag summary
    tag_counts: dict[str, int] = {}
    for _, doc in docs:
        for tag in doc["meta"]["specialty_tags"]:
            tag_counts[tag] = tag_counts.get(tag, 0) + 1
    if tag_counts:
        log.info("Specialty tags detected: %s", json.dumps(tag_counts, indent=2))

    # ── Dry-run preview ───────────────────────────────────────────────────
    if args.dry_run:
        print("\n── DRY RUN PREVIEW (first 10 documents) ──\n")
        for card_id, doc in docs[:10]:
            m = doc["meta"]
            p = doc.get("pricing", {})
            print(f"  Firestore ID  : {card_id}")
            print(f"  name          : {m['name']}")
            print(f"  set_id        : {m['set_id']}")
            print(f"  set_number    : {m['set_number']}")
            print(f"  language      : {m['language']}")
            print(f"  image_url     : {m['image_url'][:80]}…" if len(m['image_url']) > 80 else f"  image_url     : {m['image_url']}")
            print(f"  specialty_tags: {m['specialty_tags']}")
            if "tcgplayer_us" in p:
                print(f"  tcg price     : ${p['tcgplayer_us']['market_nm']:.2f}")
            if "cardmarket_eu" in p:
                print(f"  cm trend      : €{p['cardmarket_eu']['trend_price']:.2f}")
            print()
        log.info("Dry run done.  Remove --dry-run to write to Firestore.")
        return

    # ── Firebase init ─────────────────────────────────────────────────────
    if not _FIREBASE_AVAILABLE:
        log.error("firebase-admin not installed.  Run: pip install firebase-admin")
        sys.exit(1)

    sa_path = Path(args.service_account)
    if not sa_path.exists():
        log.error(
            "Service-account file not found: %s\n"
            "Download it from Firebase Console → Project Settings → Service Accounts",
            sa_path,
        )
        sys.exit(1)

    if not firebase_admin._apps:
        cred = credentials.Certificate(str(sa_path))
        firebase_admin.initialize_app(cred)

    db = fb_firestore.client()

    # ── eBay validation ───────────────────────────────────────────────────
    if args.fetch_ebay and not args.ebay_app_id:
        log.error(
            "--fetch-ebay requires an eBay App ID.  "
            "Set EBAY_APP_ID env var or use --ebay-app-id."
        )
        sys.exit(1)

    # ── Write ─────────────────────────────────────────────────────────────
    log.info(
        "Writing %d documents to '%s'%s …",
        len(docs),
        args.collection,
        " + fetching eBay prices" if args.fetch_ebay else "",
    )

    total   = len(docs)
    written = 0

    for i in tqdm(range(0, total, args.batch_size), desc="Batches"):
        batch = db.batch()
        chunk = docs[i: i + args.batch_size]

        for card_id, doc in chunk:
            if args.fetch_ebay:
                try:
                    from ebay_price_fetcher import enrich_with_ebay_price
                    doc = enrich_with_ebay_price(doc, args.ebay_app_id)
                except Exception as ebay_err:
                    log.debug("eBay fetch failed for %s: %s", card_id, ebay_err)

            ref = db.collection(args.collection).document(card_id)
            batch.set(ref, doc, merge=True)

        batch.commit()
        written = min(i + args.batch_size, total)
        log.info("  %d / %d committed", written, total)
        time.sleep(0.2)

    log.info("Import complete.  %d documents written.", total)


if __name__ == "__main__":
    main()
