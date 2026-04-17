/**
 * eBay on-demand price fetcher — Cloud Function
 * ================================================
 * Triggered when a Flutter client writes to search_requests/{requestId}.
 *
 * Flow:
 *   1. Cache check  — if cards/{cardId}.pricing.ebay_us was updated < 24 h ago,
 *      skip eBay entirely and just delete the request document.
 *   2. eBay fetch   — OAuth2 Browse API, raw + graded queries with all filters
 *      ported from scripts/ebay_price_fetcher.py.
 *   3. Write        — pricing.ebay_us.raw + pricing.ebay_us.graded (+ subvariants)
 *      are merged into cards/{cardId} via Admin SDK.
 *   4. Cleanup      — request document is deleted so the Flutter StreamBuilder
 *      knows the job is complete.
 *
 * Secrets required (set via Firebase CLI):
 *   firebase functions:secrets:set EBAY_CLIENT_ID
 *   firebase functions:secrets:set EBAY_CLIENT_SECRET
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import axios from "axios";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const BROWSE_API_URL  = "https://api.ebay.com/buy/browse/v1/item_summary/search";
const OAUTH_TOKEN_URL = "https://api.ebay.com/identity/v1/oauth2/token";
const OAUTH_SCOPE     = "https://api.ebay.com/oauth/api_scope";

const MAX_RESULTS   = 10;
const MEDIAN_SAMPLE = 5;

/** 24 hours — do not re-fetch eBay if data is fresher than this. */
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

// ---------------------------------------------------------------------------
// Secrets
// ---------------------------------------------------------------------------

export const EBAY_CLIENT_ID     = functions.params.defineSecret("EBAY_CLIENT_ID");
export const EBAY_CLIENT_SECRET = functions.params.defineSecret("EBAY_CLIENT_SECRET");

// ---------------------------------------------------------------------------
// OAuth2 token cache (lives in function memory between warm invocations)
// ---------------------------------------------------------------------------

let _cachedToken     = "";
let _tokenExpiresAt  = 0;

async function getOAuthToken(clientId: string, clientSecret: string): Promise<string> {
  const now = Date.now();
  if (_cachedToken && now < _tokenExpiresAt - 60_000) return _cachedToken;

  const b64  = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
  const resp = await axios.post(
    OAUTH_TOKEN_URL,
    `grant_type=client_credentials&scope=${encodeURIComponent(OAUTH_SCOPE)}`,
    {
      headers: {
        "Authorization": `Basic ${b64}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      timeout: 15_000,
    },
  );

  _cachedToken    = resp.data.access_token as string;
  _tokenExpiresAt = now + (Number(resp.data.expires_in ?? 7200) * 1000);
  return _cachedToken;
}

// ---------------------------------------------------------------------------
// Set ID → human-readable name
// ---------------------------------------------------------------------------

const SET_ID_TO_NAME: Record<string, string> = {
  base1: "Base Set",   base2: "Jungle",      base3: "Fossil",
  base4: "Base Set 2", base5: "Team Rocket",  base6: "Legendary Collection",
  gym1:  "Gym Heroes", gym2:  "Gym Challenge",
  neo1:  "Neo Genesis", neo2: "Neo Discovery",
  neo3:  "Neo Revelation", neo4: "Neo Destiny",
  swsh1: "Sword & Shield", swsh2: "Rebel Clash",
  swsh3: "Darkness Ablaze", swsh4: "Vivid Voltage",
  sv1:   "Scarlet & Violet", sv2: "Paldea Evolved",
  sv3:   "Obsidian Flames",  sv4: "Paradox Rift",
};

// ---------------------------------------------------------------------------
// Set exclusions (appended to query to prevent cross-set contamination)
// ---------------------------------------------------------------------------

const SET_EXCLUSIONS: Record<string, string> = {
  "Base Set": (
    '-"Base Set 2" -"Legendary Collection" -LC' +
    " -Classic -Celebrations -25th -Anniversary -Reprint"
  ),
  "Base Set 2":           '-"Legendary Collection" -"Team Rocket"',
  "Legendary Collection": '-"Base Set 2" -"Base Set"',
  "Team Rocket":          '-"Base Set" -"Base Set 2" -"Legendary Collection"',
  "Jungle":               '-"Base Set" -"Fossil"',
  "Fossil":               '-"Jungle" -"Base Set"',
};

// ---------------------------------------------------------------------------
// Hard exclusions — appended to EVERY query
// ---------------------------------------------------------------------------

const HARD_EXCLUSIONS =
  "-lot -bundle -digital -code -keychain -sticker -pin -jumbo -online";

// ---------------------------------------------------------------------------
// Post-fetch title blocklists
// ---------------------------------------------------------------------------

const UNIVERSAL_TITLE_BLOCKLIST = [
  "keychain", "key chain", "keychains", "sticker", "pin badge",
  "jumbo card", "jumbo pack",
];

const SET_TITLE_BLOCKLIST: Record<string, string[]> = {
  "Base Set": [
    "base set 2", "legendary collection", "legendary coll", " lc ",
    "celebrations", "classic", "25th", "anniversary",
  ],
  "Base Set 2": ["legendary collection"],
};

function validateTitle(title: string, resolvedSet: string): boolean {
  const lower = title.toLowerCase();
  for (const phrase of UNIVERSAL_TITLE_BLOCKLIST) {
    if (lower.includes(phrase)) return false;
  }
  for (const phrase of (SET_TITLE_BLOCKLIST[resolvedSet] ?? [])) {
    if (lower.includes(phrase.toLowerCase())) return false;
  }
  return true;
}

// ---------------------------------------------------------------------------
// Grade classification — priority-ordered regex patterns
// ---------------------------------------------------------------------------

type GradeBucket = "psa10" | "psa9" | "psa8" | "other";

const GRADE_PATTERNS: [RegExp, GradeBucket][] = [
  [/\bPSA\s*10\b/i,           "psa10"],
  [/\bCGC\s*10\b/i,           "psa10"],
  [/\bBGS\s*10\b/i,           "psa10"],
  [/\bACE\s*10\b/i,           "psa10"],
  [/\bSGC\s*10\b/i,           "psa10"],
  [/\bGEM\s*-?\s*MINT\b/i,    "psa10"],
  [/\bGEM\s*10\b/i,           "psa10"],
  [/\bGEM\s*-?\s*MT\b/i,      "psa10"],
  [/\bBGS\s*9\.5\b/i,         "psa10"],
  [/\bPSA\s*9\b(?!\s*[\.\d])/i, "psa9"],
  [/\bCGC\s*9\b(?!\s*[\.\d])/i, "psa9"],
  [/\bBGS\s*9\b(?!\s*[\.\d])/i, "psa9"],
  [/\bSGC\s*9\b(?!\s*[\.\d])/i, "psa9"],
  [/\bMINT\s*9\b/i,           "psa9"],
  [/\bPSA\s*8\b/i,            "psa8"],
  [/\bCGC\s*8\b/i,            "psa8"],
  [/\bBGS\s*8\b/i,            "psa8"],
  [/\bSGC\s*8\b/i,            "psa8"],
  [/\bNM\s*-?\s*MT\s*8\b/i,  "psa8"],
];

const GRADING_COMPANY_RE = /\b(PSA|CGC|BGS|ACE|SGC)\b/i;

function classifyTitle(title: string): GradeBucket | null {
  for (const [pattern, bucket] of GRADE_PATTERNS) {
    if (pattern.test(title)) return bucket;
  }
  if (GRADING_COMPANY_RE.test(title)) return "other";
  return null;
}

// ---------------------------------------------------------------------------
// Base Set sub-variant detection
// ---------------------------------------------------------------------------

const FIRST_EDITION_RE = /\b1st\s*(?:edition|ed\.?)\b/i;
const SHADOWLESS_RE    = /\bshadowless\b/i;

function detectSubvariant(title: string): "1st_edition" | "shadowless" | "unlimited" {
  if (FIRST_EDITION_RE.test(title)) return "1st_edition";
  if (SHADOWLESS_RE.test(title))    return "shadowless";
  return "unlimited";
}

// ---------------------------------------------------------------------------
// Query builders
// ---------------------------------------------------------------------------

function resolveSet(setId: string): string {
  return SET_ID_TO_NAME[setId.trim()] ?? setId.trim();
}

function buildRawQuery(
  cardName: string,
  setId: string,
  number: string,
): string {
  const set  = resolveSet(setId);
  const excl = SET_EXCLUSIONS[set] ?? "";
  const yearAnchor = set === "Base Set" ? " 1999" : "";
  const parts: string[] = [];
  if (set) parts.push(`"${set}"`);
  if (excl) parts.push(excl);
  parts.push(cardName.trim());
  if (number) parts.push(number.trim());
  parts.push(`(raw, ungraded, nm, near mint)${yearAnchor}`);
  parts.push("-psa -cgc -bgs -graded -slab -cert");
  parts.push(HARD_EXCLUSIONS);
  return parts.join(" ");
}

function buildGradedQuery(
  cardName: string,
  setId: string,
  number: string,
  tier: 1 | 2,
): string {
  const set  = resolveSet(setId);
  const excl = SET_EXCLUSIONS[set] ?? "";
  const yearAnchor = set === "Base Set" ? " 1999" : "";
  const parts: string[] = [];
  if (set) parts.push(`"${set}"`);
  if (excl) parts.push(excl);
  if (yearAnchor) parts.push("1999");
  parts.push(cardName.trim());
  if (number) parts.push(number.trim());
  parts.push(tier === 1 ? "PSA 10" : "graded");
  parts.push(HARD_EXCLUSIONS);
  return parts.join(" ");
}

// ---------------------------------------------------------------------------
// eBay Browse API fetch
// ---------------------------------------------------------------------------

async function fetchSoldListings(
  query: string,
  clientId: string,
  clientSecret: string,
): Promise<Record<string, unknown>[]> {
  const token = await getOAuthToken(clientId, clientSecret);
  const resp  = await axios.get(BROWSE_API_URL, {
    params: {
      q:      query,
      filter: "conditions:{NEW|USED},lastSoldDate:[2024-01-01T00:00:00Z..2026-12-31T23:59:59Z]",
      sort:   "newlyListed",
      limit:  MAX_RESULTS,
    },
    headers: {
      "Authorization":           `Bearer ${token}`,
      "X-EBAY-C-MARKETPLACE-ID": "EBAY_US",
      "Content-Type":            "application/json",
    },
    timeout: 20_000,
  });
  return (resp.data?.itemSummaries as Record<string, unknown>[]) ?? [];
}

// ---------------------------------------------------------------------------
// Price extraction helpers
// ---------------------------------------------------------------------------

function netPrice(item: Record<string, unknown>): number | null {
  try {
    const itemPrice = parseFloat((item.price as any)?.value ?? "0");
    let shipping = 0;
    const opts = (item.shippingOptions as any[])?.[0];
    if (opts) shipping = parseFloat(opts?.shippingCost?.value ?? "0");
    const net = itemPrice - shipping;
    return net >= 0 ? net : null;
  } catch {
    return null;
  }
}

function extractRawPrices(items: Record<string, unknown>[]): number[] {
  return items.flatMap((item) => {
    const p = netPrice(item);
    return p !== null ? [p] : [];
  });
}

interface GradeBuckets {
  psa10: number[];
  psa9:  number[];
  psa8:  number[];
  other: number[];
  subvariants: {
    "1st_edition": { psa10: number[]; psa9: number[]; psa8: number[] };
    shadowless:    { psa10: number[]; psa9: number[]; psa8: number[] };
    unlimited:     { psa10: number[]; psa9: number[]; psa8: number[] };
  };
}

function extractGradedPrices(
  items: Record<string, unknown>[],
  setId: string,
): GradeBuckets {
  const resolved = resolveSet(setId);
  const buckets: GradeBuckets = {
    psa10: [], psa9: [], psa8: [], other: [],
    subvariants: {
      "1st_edition": { psa10: [], psa9: [], psa8: [] },
      shadowless:    { psa10: [], psa9: [], psa8: [] },
      unlimited:     { psa10: [], psa9: [], psa8: [] },
    },
  };

  for (const item of items) {
    const title = ((item.title as string) ?? "").trim();

    if (!validateTitle(title, resolved)) continue;

    const bucket = classifyTitle(title);
    if (bucket === null || bucket === "other") continue;

    const price = netPrice(item);
    if (price === null) continue;

    buckets[bucket].push(price);

    const sv = detectSubvariant(title);
    buckets.subvariants[sv][bucket].push(price);
  }

  return buckets;
}

function medianOfLastN(prices: number[], n = MEDIAN_SAMPLE): number | null {
  const sample = prices.slice(0, n);
  if (sample.length === 0) return null;
  const sorted = [...sample].sort((a, b) => a - b);
  const mid    = Math.floor(sorted.length / 2);
  return sorted.length % 2 !== 0
    ? sorted[mid]
    : (sorted[mid - 1] + sorted[mid]) / 2;
}

// ---------------------------------------------------------------------------
// Cloud Function — onSearchRequest
// ---------------------------------------------------------------------------

export const onSearchRequest = functions
  .runWith({
    secrets:        [EBAY_CLIENT_ID, EBAY_CLIENT_SECRET],
    timeoutSeconds: 60,
    memory:         "512MB",
  })
  .firestore.document("search_requests/{requestId}")
  .onCreate(async (snap, context) => {
    const data      = snap.data() as Record<string, string>;
    const cardId    = data.card_id   ?? "";
    const cardName  = data.name      ?? "";
    const setId     = data.set_id    ?? "";
    const number    = data.number    ?? "";
    const requestId = context.params.requestId;

    if (!cardId || !cardName) {
      functions.logger.warn(`[${requestId}] Missing card_id or name — deleting`);
      await snap.ref.delete();
      return;
    }

    const db      = admin.firestore();
    const cardRef = db.collection("cards").doc(cardId);

    // ── 1. Cache check ──────────────────────────────────────────────────────
    try {
      const cardSnap = await cardRef.get();
      if (cardSnap.exists) {
        const rawUpdated = cardSnap.data()?.pricing?.ebay_us?.raw?.last_updated;
        if (rawUpdated) {
          const updatedAt = rawUpdated.toDate ? rawUpdated.toDate() : new Date(rawUpdated);
          if (Date.now() - updatedAt.getTime() < CACHE_TTL_MS) {
            functions.logger.info(`[${cardId}] Cache hit (< 24 h) — skipping eBay`);
            await snap.ref.delete();
            return;
          }
        }
      }
    } catch (err) {
      functions.logger.warn(`[${cardId}] Cache check failed`, err);
    }

    // ── 2. Fetch from eBay ──────────────────────────────────────────────────
    const clientId     = EBAY_CLIENT_ID.value();
    const clientSecret = EBAY_CLIENT_SECRET.value();

    try {
      // ── RAW ──
      let rawMedian: number | null = null;
      try {
        const rawQuery = buildRawQuery(cardName, setId, number);
        functions.logger.info(`[${cardId}] RAW query: ${rawQuery}`);
        const rawItems  = await fetchSoldListings(rawQuery, clientId, clientSecret);
        const rawPrices = extractRawPrices(rawItems);
        rawMedian       = medianOfLastN(rawPrices);
        functions.logger.info(`[${cardId}] RAW median: ${rawMedian ?? "none"} (${rawPrices.length} results)`);
      } catch (err) {
        functions.logger.warn(`[${cardId}] RAW fetch error`, err);
      }

      // ── GRADED (two-tier fallback) ──
      let gradedItems: Record<string, unknown>[] = [];
      let gradedQuery = buildGradedQuery(cardName, setId, number, 1);
      functions.logger.info(`[${cardId}] GRADED tier-1 query: ${gradedQuery}`);
      try {
        gradedItems = await fetchSoldListings(gradedQuery, clientId, clientSecret);
        if (gradedItems.length === 0) {
          gradedQuery = buildGradedQuery(cardName, setId, number, 2);
          functions.logger.info(`[${cardId}] GRADED tier-2 query: ${gradedQuery}`);
          gradedItems = await fetchSoldListings(gradedQuery, clientId, clientSecret);
        }
      } catch (err) {
        functions.logger.warn(`[${cardId}] GRADED fetch error`, err);
      }

      const buckets = extractGradedPrices(gradedItems, setId);
      const psa10   = medianOfLastN(buckets.psa10);
      const psa9    = medianOfLastN(buckets.psa9);
      const psa8    = medianOfLastN(buckets.psa8);
      functions.logger.info(
        `[${cardId}] GRADED — PSA10: ${psa10} PSA9: ${psa9} PSA8: ${psa8}`,
      );

      // Sub-variant map (populated for Base Set cards)
      const subvariants: Record<string, Record<string, number>> = {};
      for (const [svKey, gradeData] of Object.entries(buckets.subvariants)) {
        const entry: Record<string, number> = {};
        const sv10 = medianOfLastN(gradeData.psa10);
        const sv9  = medianOfLastN(gradeData.psa9);
        const sv8  = medianOfLastN(gradeData.psa8);
        if (sv10 !== null) entry.psa10 = sv10;
        if (sv9  !== null) entry.psa9  = sv9;
        if (sv8  !== null) entry.psa8  = sv8;
        if (Object.keys(entry).length > 0) subvariants[svKey] = entry;
      }

      // ── 3. Write pricing to cards/{cardId} ──────────────────────────────
      const now      = admin.firestore.FieldValue.serverTimestamp();
      const update: Record<string, unknown> = {};

      if (rawMedian !== null) {
        update["pricing.ebay_us.raw.last_sold"]    = rawMedian;
        update["pricing.ebay_us.raw.last_updated"] = now;
      }

      const gradedData: Record<string, unknown> = { last_updated: now };
      if (psa10 !== null) gradedData.psa10 = psa10;
      if (psa9  !== null) gradedData.psa9  = psa9;
      if (psa8  !== null) gradedData.psa8  = psa8;
      if (Object.keys(subvariants).length > 0) gradedData.subvariants = subvariants;
      update["pricing.ebay_us.graded"] = gradedData;

      await cardRef.set(update, { merge: true });
      functions.logger.info(`[${cardId}] Pricing written to Firestore`);

    } catch (err) {
      functions.logger.error(`[${cardId}] eBay enrichment failed`, err);
    }

    // ── 4. Delete the request to signal completion to Flutter ─────────────
    await snap.ref.delete();
    functions.logger.info(`[${requestId}] Request deleted — job complete`);
  });
