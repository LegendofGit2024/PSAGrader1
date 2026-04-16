"""
Kaggle Pokémon TCG Dataset → Firestore Importer
================================================
Reads a Kaggle-sourced Pokémon TCG CSV and batch-writes every card into
Firestore under the `cards/{cardId}` path used by Slab Stack.

Specialty-tag logic
-------------------
If the card name (or set name) contains any of these phrases, the card is
tagged automatically in `meta.specialty_tags`:

  'japanese'   → 'japanese'
  '1st edition' → '1st_edition'
  'error'      → 'error'
  'shadowless'  → 'shadowless'
  'promo'      → 'promo'

Usage
-----
1. Install dependencies:
       pip install firebase-admin pandas tqdm

2. Download your Kaggle dataset (e.g. "Pokemon TCG Cards" or similar) and
   note the CSV path.

3. Place your Firebase service-account key JSON at one of:
   - ./service-account.json          (project root)
   - $GOOGLE_APPLICATION_CREDENTIALS (env var)

4. Run:
       python scripts/kaggle_import.py \
           --csv path/to/pokemon_cards.csv \
           --batch-size 400 \
           --dry-run

   Remove --dry-run to actually write to Firestore.

Column mapping
--------------
The script tries to auto-detect columns from common Kaggle dataset schemas.
Override any mapping with --col-<field> <column_name> flags.

Supported source schemas:
  * "Pokemon Card Dataset" by Kaggle user lambdaofgod
    (id, name, supertype, subtypes, hp, types, set, number, rarity, artist,
     flavorText, nationalPokedexNumbers, legalities, images.small,
     images.large, tcgplayer.prices.*, cardmarket.prices.*)
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
# Optional firebase-admin import (skip in dry-run without it installed)
# ---------------------------------------------------------------------------

try:
    import firebase_admin
    from firebase_admin import credentials, firestore

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
# Specialty tag rules  (pattern → tag)
# ---------------------------------------------------------------------------

SPECIALTY_RULES: list[tuple[re.Pattern, str]] = [
    (re.compile(r"japanese", re.IGNORECASE), "japanese"),
    (re.compile(r"1st\s*edition", re.IGNORECASE), "1st_edition"),
    (re.compile(r"\berror\b", re.IGNORECASE), "error"),
    (re.compile(r"shadowless", re.IGNORECASE), "shadowless"),
    (re.compile(r"\bpromo\b", re.IGNORECASE), "promo"),
]


def compute_specialty_tags(name: str, set_name: str = "", rarity: str = "") -> list[str]:
    """Return deduplicated list of specialty tags that apply to this card."""
    haystack = f"{name} {set_name} {rarity}"
    tags: list[str] = []
    for pattern, tag in SPECIALTY_RULES:
        if pattern.search(haystack):
            tags.append(tag)
    return tags


# ---------------------------------------------------------------------------
# Column detection helpers
# ---------------------------------------------------------------------------

_COLUMN_ALIASES: dict[str, list[str]] = {
    "id":         ["id", "card_id", "cardId"],
    "name":       ["name", "card_name", "cardName"],
    "set_id":     ["set_id", "setId", "set.id", "set"],
    "set_name":   ["set_name", "setName", "set.name"],
    "number":     ["number", "card_number", "cardNumber", "num"],
    "rarity":     ["rarity"],
    "image_small":["images.small", "image_small", "imageSmall", "smallImage"],
    "image_large":["images.large", "image_large", "imageLarge", "largeImage"],
    "language":   ["language", "lang"],
    # TCGPlayer prices
    "tcg_nm":     ["tcgplayer.prices.normal.market",
                   "tcgplayer_nm", "tcg_market_nm", "price_nm"],
    "tcg_holofoil":["tcgplayer.prices.holofoil.market",
                    "tcgplayer_holo", "tcg_market_holo"],
    # Cardmarket prices
    "cm_trend":   ["cardmarket.prices.averageSellPrice",
                   "cardmarket_trend", "cm_avg_sell"],
}


def _find_col(df: pd.DataFrame, field: str, override: str | None) -> str | None:
    """Return the actual column name in df for the logical field."""
    if override and override in df.columns:
        return override
    for alias in _COLUMN_ALIASES.get(field, []):
        if alias in df.columns:
            return alias
    return None


def _get(row: pd.Series, col: str | None, default: Any = None) -> Any:
    if col is None:
        return default
    val = row.get(col, default)
    if pd.isna(val):
        return default
    return val


# ---------------------------------------------------------------------------
# Row → Firestore document
# ---------------------------------------------------------------------------

def row_to_doc(
    row: pd.Series,
    cols: dict[str, str | None],
    language_default: str,
) -> tuple[str, dict]:
    """Convert a CSV row to (card_id, firestore_doc_dict)."""

    # --- IDs ---
    card_id: str = str(_get(row, cols["id"], "")).strip()
    if not card_id:
        card_id = str(uuid.uuid4())

    name: str    = str(_get(row, cols["name"],    "Unknown")).strip()
    set_id: str  = str(_get(row, cols["set_id"],  "")).strip()
    set_name: str = str(_get(row, cols["set_name"], "")).strip()
    number: str  = str(_get(row, cols["number"],  "")).strip()
    rarity: str  = str(_get(row, cols["rarity"],  "")).strip()
    image_url: str = str(_get(row, cols["image_large"],
                              _get(row, cols["image_small"], ""))).strip()
    lang_raw: str = str(_get(row, cols["language"], language_default)).strip().lower()
    language: str = lang_raw if lang_raw in ("en", "jp", "kr", "zh") else "en"

    # --- Specialty tags ---
    specialty_tags = compute_specialty_tags(name, set_name, rarity)

    # --- Pricing ---
    tcg_nm:    float | None = _try_float(_get(row, cols["tcg_nm"]))
    tcg_holo:  float | None = _try_float(_get(row, cols["tcg_holofoil"]))
    cm_trend:  float | None = _try_float(_get(row, cols["cm_trend"]))

    price_nm = tcg_nm or tcg_holo  # prefer normal-market, fall back to holo

    doc: dict = {
        # id is stored in the document key, not the body — but we include it
        # for the fromJson path used by CardDocument.fromFirestore.
        "id": card_id,
        "meta": {
            "name":           name,
            "set_id":         set_id,
            "set_number":     number,
            "language":       language,
            "variant":        rarity,
            "image_url":      image_url,
            "specialty_tags": specialty_tags,
        },
        "pricing": {
            **(
                {
                    "tcgplayer_us": {
                        "market_nm": price_nm,
                        "updated_at": None,
                    }
                }
                if price_nm is not None
                else {}
            ),
            **(
                {
                    "cardmarket_eu": {
                        "trend_price": cm_trend,
                        "updated_at": None,
                    }
                }
                if cm_trend is not None
                else {}
            ),
        },
    }

    return card_id, doc


def _try_float(val: Any) -> float | None:
    try:
        f = float(val)
        return f if f >= 0 else None
    except (TypeError, ValueError):
        return None


# ---------------------------------------------------------------------------
# Firestore batch writer
# ---------------------------------------------------------------------------

def write_batches(
    db,  # firestore.Client
    docs: list[tuple[str, dict]],
    batch_size: int,
    collection: str,
) -> None:
    total = len(docs)
    written = 0
    for i in tqdm(range(0, total, batch_size), desc="Writing batches"):
        batch = db.batch()
        chunk = docs[i : i + batch_size]
        for card_id, doc in chunk:
            ref = db.collection(collection).document(card_id)
            # merge=True so we don't wipe existing pricing data
            batch.set(ref, doc, merge=True)
        batch.commit()
        written += len(chunk)
        log.info("Committed %d / %d documents", written, total)
        # Firestore quota: ~1 write/s sustained; batches help but add small sleep
        time.sleep(0.2)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Import Kaggle Pokémon TCG CSV into Firestore."
    )
    p.add_argument("--csv", required=True, help="Path to input CSV file")
    p.add_argument(
        "--service-account",
        default=os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", "service-account.json"),
        help="Path to Firebase service-account JSON (default: ./service-account.json)",
    )
    p.add_argument(
        "--collection", default="cards", help="Firestore collection (default: cards)"
    )
    p.add_argument(
        "--batch-size", type=int, default=400,
        help="Documents per Firestore batch (max 500, default: 400)"
    )
    p.add_argument(
        "--language-default", default="en",
        choices=["en", "jp", "kr", "zh"],
        help="Language to assign when the CSV has no language column"
    )
    p.add_argument(
        "--dry-run", action="store_true",
        help="Parse and preview the first 10 rows without writing to Firestore"
    )
    p.add_argument(
        "--limit", type=int, default=0,
        help="Only import the first N rows (0 = all)"
    )
    # Column overrides
    for field in _COLUMN_ALIASES:
        p.add_argument(
            f"--col-{field.replace('_', '-')}",
            default=None,
            metavar="COLUMN",
            help=f"Override column name for '{field}'"
        )
    return p


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    # --- Load CSV ---
    csv_path = Path(args.csv)
    if not csv_path.exists():
        log.error("CSV not found: %s", csv_path)
        sys.exit(1)

    log.info("Reading %s …", csv_path)
    df = pd.read_csv(csv_path, low_memory=False)
    log.info("Loaded %d rows, %d columns", len(df), len(df.columns))

    if args.limit > 0:
        df = df.head(args.limit)
        log.info("Limited to first %d rows", args.limit)

    # --- Resolve columns ---
    cols: dict[str, str | None] = {}
    for field in _COLUMN_ALIASES:
        cli_key = f"col_{field}"
        override = getattr(args, cli_key, None)
        resolved = _find_col(df, field, override)
        cols[field] = resolved
        if resolved:
            log.info("  %-14s → %s", field, resolved)
        else:
            log.warning("  %-14s → (not found — will use default)", field)

    # --- Convert rows ---
    log.info("Converting rows …")
    docs: list[tuple[str, dict]] = []
    errors = 0
    for _, row in tqdm(df.iterrows(), total=len(df), desc="Parsing"):
        try:
            card_id, doc = row_to_doc(row, cols, args.language_default)
            docs.append((card_id, doc))
        except Exception as exc:  # noqa: BLE001
            log.debug("Row error: %s", exc)
            errors += 1

    log.info(
        "Converted %d rows (%d errors skipped)",
        len(docs), errors,
    )

    # Specialty tag summary
    tag_counts: dict[str, int] = {}
    for _, doc in docs:
        for tag in doc["meta"]["specialty_tags"]:
            tag_counts[tag] = tag_counts.get(tag, 0) + 1
    if tag_counts:
        log.info("Specialty tags found: %s", json.dumps(tag_counts))

    # --- Dry run preview ---
    if args.dry_run:
        log.info("DRY RUN — first 10 documents:")
        for card_id, doc in docs[:10]:
            print(f"\n  [{card_id}]")
            print(f"    name:           {doc['meta']['name']}")
            print(f"    set_id:         {doc['meta']['set_id']}")
            print(f"    language:       {doc['meta']['language']}")
            print(f"    specialty_tags: {doc['meta']['specialty_tags']}")
            pricing = doc.get("pricing", {})
            if "tcgplayer_us" in pricing:
                print(f"    tcg_nm:         {pricing['tcgplayer_us']['market_nm']}")
            if "cardmarket_eu" in pricing:
                print(f"    cm_trend:       {pricing['cardmarket_eu']['trend_price']}")
        log.info("Dry run complete. Re-run without --dry-run to write to Firestore.")
        return

    # --- Firebase init ---
    if not _FIREBASE_AVAILABLE:
        log.error(
            "firebase-admin is not installed. Run: pip install firebase-admin"
        )
        sys.exit(1)

    sa_path = Path(args.service_account)
    if not sa_path.exists():
        log.error(
            "Service-account file not found: %s\n"
            "Set GOOGLE_APPLICATION_CREDENTIALS or use --service-account",
            sa_path,
        )
        sys.exit(1)

    if not firebase_admin._apps:  # avoid re-initialising in interactive sessions
        cred = credentials.Certificate(str(sa_path))
        firebase_admin.initialize_app(cred)

    db = firestore.client()
    log.info(
        "Writing %d documents to Firestore collection '%s' …",
        len(docs), args.collection,
    )
    write_batches(db, docs, batch_size=args.batch_size, collection=args.collection)
    log.info("Import complete.")


if __name__ == "__main__":
    main()
