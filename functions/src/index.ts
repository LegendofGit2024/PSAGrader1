import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import axios from "axios";
import * as cheerio from "cheerio";

admin.initializeApp();
const db = admin.firestore();

// ---------------------------------------------------------------------------
// Secrets — set via:  firebase functions:secrets:set EBAY_TOKEN
// ---------------------------------------------------------------------------
const EBAY_TOKEN   = functions.params.defineSecret("EBAY_TOKEN");
const TCG_TOKEN    = functions.params.defineSecret("TCG_TOKEN");
const CMK_APP_TOKEN = functions.params.defineSecret("CMK_APP_TOKEN");
const PSA_API_KEY  = functions.params.defineSecret("PSA_API_KEY");

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface PricingData {
  ebay_us?: {
    last_sold_nm?: number;
    last_sold_lp?: number;
    volume_7d?: number;
    updated_at: admin.firestore.Timestamp;
  };
  tcgplayer_us?: {
    market_nm?: number;
    market_lp?: number;
    market_mp?: number;
    market_hp?: number;
    market_dmg?: number;
    updated_at: admin.firestore.Timestamp;
  };
  cardmarket_eu?: {
    trend_price?: number;
    avg_sell_1d?: number;
    updated_at: admin.firestore.Timestamp;
  };
  yuyutei_jp?: {
    buy_price?: number;
    updated_at: admin.firestore.Timestamp;
  };
}

interface RoiRequest {
  cardId: string;
  costBasis: number;
  grader: string;
  gradingFee: number;
  shippingCost: number;
  projectedGrade: number;
}

// ---------------------------------------------------------------------------
// Utility: Net Profit formula
// ---------------------------------------------------------------------------

function netProfit(
  marketValue: number,
  costBasis: number,
  gradingFee: number,
  shippingCost: number,
): number {
  return marketValue * 0.86 - (costBasis + gradingFee + shippingCost);
}

// Grade discount multiplier curve vs eBay PSA 10 baseline
const GRADE_CURVE: Record<number, number> = {
  10:  1.00,
  9.5: 0.72,
  9:   0.55,
  8.5: 0.42,
  8:   0.32,
  7.5: 0.25,
  7:   0.20,
  6.5: 0.15,
  6:   0.12,
  5:   0.08,
  4:   0.06,
  3:   0.04,
  2:   0.03,
  1:   0.02,
};

// ---------------------------------------------------------------------------
// 1. Scheduled: eBay + TCGplayer price fetch (every 6 hours)
// ---------------------------------------------------------------------------

export const scheduledPriceFetch = functions
  .runWith({ secrets: [EBAY_TOKEN, TCG_TOKEN], timeoutSeconds: 540, memory: "512MB" })
  .pubsub.schedule("every 6 hours")
  .onRun(async () => {
    const cardsSnap = await db.collection("cards").get();
    const batch = db.batch();

    for (const doc of cardsSnap.docs) {
      const pricing: Partial<PricingData> = {};

      // -- eBay Browse API: last sold NM --
      try {
        const query = encodeURIComponent(doc.data().meta?.name ?? doc.id);
        const resp = await axios.get(
          `https://api.ebay.com/buy/browse/v1/item_summary/search?q=${query}&filter=buyingOptions:{FIXED_PRICE},conditionIds:{3000}&sort=endTimeSoonest&limit=5`,
          {
            headers: {
              Authorization: `Bearer ${EBAY_TOKEN.value()}`,
              "X-EBAY-C-MARKETPLACE-ID": "EBAY_US",
            },
          },
        );
        const items = resp.data?.itemSummaries ?? [];
        const prices: number[] = items
          .map((i: any) => parseFloat(i?.price?.value ?? "0"))
          .filter((p: number) => p > 0);

        if (prices.length > 0) {
          pricing.ebay_us = {
            last_sold_nm: prices[0],
            volume_7d: prices.length,
            updated_at: admin.firestore.Timestamp.now(),
          };
        }
      } catch (e) {
        functions.logger.warn(`eBay fetch failed for ${doc.id}`, e);
      }

      // -- TCGplayer market prices by condition --
      try {
        const skuId = doc.data().tcgplayer_sku_id;
        if (skuId) {
          const resp = await axios.get(
            `https://api.tcgplayer.com/pricing/sku/${skuId}`,
            { headers: { Authorization: `Bearer ${TCG_TOKEN.value()}` } },
          );
          const results = resp.data?.results ?? [];
          const byCondition: Record<string, number> = {};
          for (const r of results) {
            byCondition[r.condition] = r.marketPrice;
          }
          pricing.tcgplayer_us = {
            market_nm:  byCondition["Near Mint"],
            market_lp:  byCondition["Lightly Played"],
            market_mp:  byCondition["Moderately Played"],
            market_hp:  byCondition["Heavily Played"],
            market_dmg: byCondition["Damaged"],
            updated_at: admin.firestore.Timestamp.now(),
          };
        }
      } catch (e) {
        functions.logger.warn(`TCGplayer fetch failed for ${doc.id}`, e);
      }

      if (Object.keys(pricing).length > 0) {
        batch.update(doc.ref, { pricing });
      }
    }

    await batch.commit();
    functions.logger.info(`Price fetch complete for ${cardsSnap.size} cards`);
  });

// ---------------------------------------------------------------------------
// 2. Scheduled: Cardmarket EU prices (every 6 hours, offset by 1h)
// ---------------------------------------------------------------------------

export const scheduledCardmarketFetch = functions
  .runWith({ secrets: [CMK_APP_TOKEN], timeoutSeconds: 540, memory: "512MB" })
  .pubsub.schedule("every 6 hours")
  .onRun(async () => {
    const cardsSnap = await db
      .collection("cards")
      .where("meta.language", "in", ["EN", "DE", "FR", "IT", "ES"])
      .get();

    const batch = db.batch();

    for (const doc of cardsSnap.docs) {
      const cmkId = doc.data().cardmarket_id;
      if (!cmkId) continue;

      try {
        // OAuth 1.0a signature is handled by a helper in production;
        // simplified here — replace with full HMAC-SHA1 signing.
        const resp = await axios.get(
          `https://api.cardmarket.com/ws/v2.0/products/${cmkId}`,
          {
            headers: {
              Authorization: `Bearer ${CMK_APP_TOKEN.value()}`,
            },
          },
        );
        const p = resp.data?.product?.priceGuide ?? {};
        batch.update(doc.ref, {
          "pricing.cardmarket_eu": {
            trend_price: p.TREND ?? null,
            avg_sell_1d: p.AVG1 ?? null,
            updated_at: admin.firestore.Timestamp.now(),
          },
        });
      } catch (e) {
        functions.logger.warn(`Cardmarket fetch failed for ${doc.id}`, e);
      }
    }

    await batch.commit();
    functions.logger.info("Cardmarket fetch complete");
  });

// ---------------------------------------------------------------------------
// 3. Scheduled: Yuyutei JP scraper (every 6 hours)
// ---------------------------------------------------------------------------

export const yuyuteiScraper = functions
  .runWith({ timeoutSeconds: 300, memory: "256MB" })
  .pubsub.schedule("every 6 hours")
  .onRun(async () => {
    const cardsSnap = await db
      .collection("cards")
      .where("meta.language", "==", "JP")
      .where("yuyutei_url", "!=", null)
      .get();

    const batch = db.batch();

    for (const doc of cardsSnap.docs) {
      const url: string = doc.data().yuyutei_url;
      if (!url) continue;

      try {
        const resp = await axios.get(url, {
          headers: { "Accept-Language": "ja", "User-Agent": "Mozilla/5.0" },
          timeout: 8000,
        });
        const $ = cheerio.load(resp.data as string);

        // Yuyutei buy price is in the .unit_price element (¥ + number)
        const rawPrice = $(".unit_price").first().text().trim();
        const jpyMatch = rawPrice.match(/[¥￥]?([\d,]+)/);
        const buyPrice = jpyMatch
          ? parseInt(jpyMatch[1].replace(/,/g, ""), 10)
          : null;

        if (buyPrice) {
          batch.update(doc.ref, {
            "pricing.yuyutei_jp": {
              buy_price: buyPrice,
              updated_at: admin.firestore.Timestamp.now(),
            },
          });
        }
      } catch (e) {
        functions.logger.warn(`Yuyutei scrape failed for ${doc.id}`, e);
      }
    }

    await batch.commit();
    functions.logger.info("Yuyutei scrape complete");
  });

// ---------------------------------------------------------------------------
// 4. Scheduled: PSA population report sync (daily)
// ---------------------------------------------------------------------------

export const psaPopSync = functions
  .runWith({ secrets: [PSA_API_KEY], timeoutSeconds: 300, memory: "256MB" })
  .pubsub.schedule("every 24 hours")
  .onRun(async () => {
    const cardsSnap = await db
      .collection("cards")
      .where("psa_set_id", "!=", null)
      .get();

    const batch = db.batch();

    for (const doc of cardsSnap.docs) {
      const setId = doc.data().psa_set_id;
      if (!setId) continue;

      try {
        const resp = await axios.get(
          `https://api.psacard.com/publicapi/pop/GetPopReportBySeries?seriesId=${setId}`,
          { headers: { Authorization: `Bearer ${PSA_API_KEY.value()}` } },
        );
        const items = resp.data?.PSASet?.PSACards ?? [];
        const cardNumber = doc.data().meta?.set_number;
        const match = items.find((i: any) => i.CardNumber === cardNumber);

        if (match) {
          batch.update(doc.ref, {
            psa_pop: {
              total_pop: match.TotalPopulation ?? 0,
              pop_10:    match.Pop10 ?? 0,
              pop_9:     match.Pop9 ?? 0,
              updated_at: admin.firestore.Timestamp.now(),
            },
          });
        }
      } catch (e) {
        functions.logger.warn(`PSA pop sync failed for ${doc.id}`, e);
      }
    }

    await batch.commit();
    functions.logger.info("PSA pop sync complete");
  });

// ---------------------------------------------------------------------------
// 5. HTTPS Callable: Calculate submission ROI
//
// Called on-demand from the client for accurate server-side calculation.
// Returns full grade→profit map and verdict.
// ---------------------------------------------------------------------------

export const calculateSubmissionROI = functions
  .runWith({ timeoutSeconds: 30 })
  .https.onCall(async (data: RoiRequest, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required",
      );
    }

    const { cardId, costBasis, gradingFee, shippingCost, projectedGrade } = data;

    if (!cardId || costBasis == null || gradingFee == null || shippingCost == null) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "cardId, costBasis, gradingFee, and shippingCost are required",
      );
    }

    const cardDoc = await db.collection("cards").doc(cardId).get();
    if (!cardDoc.exists) {
      throw new functions.https.HttpsError("not-found", `Card ${cardId} not found`);
    }

    const basePrice: number = cardDoc.data()?.pricing?.ebay_us?.last_sold_nm ?? 0;
    if (basePrice === 0) {
      return { error: "No eBay pricing data available for this card" };
    }

    // Build grade price map
    const gradePriceMap: Record<number, number> = {};
    for (const [gradeStr, mult] of Object.entries(GRADE_CURVE)) {
      gradePriceMap[parseFloat(gradeStr)] = basePrice * mult;
    }

    // Build profit map
    const profitByGrade: Record<number, number> = {};
    for (const [gradeStr, price] of Object.entries(gradePriceMap)) {
      profitByGrade[parseFloat(gradeStr)] = netProfit(
        price,
        costBasis,
        gradingFee,
        shippingCost,
      );
    }

    // Find break-even grade (lowest grade where profit ≥ 0)
    const grades = Object.keys(GRADE_CURVE)
      .map(Number)
      .sort((a, b) => a - b);

    let breakEvenGrade: number | null = null;
    for (const g of grades) {
      if ((profitByGrade[g] ?? -Infinity) >= 0) {
        breakEvenGrade = g;
        break;
      }
    }

    const projectedProfit = profitByGrade[projectedGrade] ?? 0;
    const verdict =
      breakEvenGrade === null
        ? "SKIP"
        : projectedGrade < breakEvenGrade
        ? "SKIP"
        : projectedProfit >= 50
        ? "SUBMIT"
        : "MARGINAL";

    // Persist the estimate
    await db.collection("submission_estimates").add({
      user_uid: context.auth.uid,
      card_ref: db.collection("cards").doc(cardId),
      inputs: {
        grader: data.grader,
        grading_fee: gradingFee,
        shipping_cost: shippingCost,
        cost_basis: costBasis,
      },
      outputs: {
        projected_grade: projectedGrade,
        market_value_at_grade: gradePriceMap[projectedGrade] ?? 0,
        net_profit: projectedProfit,
        break_even_grade: breakEvenGrade ?? 0,
      },
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      gradePriceMap,
      profitByGrade,
      breakEvenGrade,
      verdict,
      projectedNetProfit: projectedProfit,
      projectedMarketValue: gradePriceMap[projectedGrade] ?? 0,
    };
  });

// ---------------------------------------------------------------------------
// 6. HTTP: Seed market_signals (dev/admin only — protect behind auth check)
// ---------------------------------------------------------------------------

export const seedMarketSignals = functions
  .runWith({ timeoutSeconds: 60 })
  .https.onRequest(async (req, res) => {
    // Minimal auth guard: require a secret header in dev
    if (req.headers["x-admin-secret"] !== process.env.ADMIN_SECRET) {
      res.status(403).send("Forbidden");
      return;
    }

    const signals = [
      {
        cardId: "umbreon-vmax-sv",
        name: "Umbreon VMAX",
        setId: "sv",
        signal: "volumeSpike",
        direction: "hot",
        reason: "24h sales volume 3.2× above 30-day average",
        imageUrl: "",
        currentPrice: 480,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        cardId: "charizard-base-4",
        name: "Charizard Base Set",
        setId: "base",
        signal: "thinSpread",
        direction: "hot",
        reason: "Only 12 PSA 10s listed — historically thin supply",
        imageUrl: "",
        currentPrice: 9800,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        cardId: "base-set-2-charizard",
        name: "Charizard Base Set 2",
        setId: "base",
        signal: "popPlateau",
        direction: "cold",
        reason: "PSA 10 pop growth under 0.5% this quarter",
        imageUrl: "",
        currentPrice: 420,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        cardId: "pikachu-illustrator",
        name: "Pikachu Illustrator",
        setId: "promo",
        signal: "media",
        direction: "hot",
        reason: "Featured in major media coverage this week",
        imageUrl: "",
        currentPrice: 380000,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    ];

    const batch = db.batch();
    for (const s of signals) {
      batch.set(db.collection("market_signals").doc(s.cardId), s);
    }
    await batch.commit();

    res.json({ seeded: signals.length });
  });

// ---------------------------------------------------------------------------
// 7. HTTP: Seed whale_sales
// ---------------------------------------------------------------------------

export const seedWhaleSales = functions
  .runWith({ timeoutSeconds: 60 })
  .https.onRequest(async (req, res) => {
    if (req.headers["x-admin-secret"] !== process.env.ADMIN_SECRET) {
      res.status(403).send("Forbidden");
      return;
    }

    const sales = [
      {
        cardName: "Charizard Base Set PSA 10",
        grader: "PSA",
        grade: 10,
        salePrice: 420000,
        platform: "Heritage Auctions",
        saleDate: admin.firestore.Timestamp.fromDate(new Date("2025-11-14")),
        imageUrl: "",
      },
      {
        cardName: "Pikachu Illustrator CGC 10",
        grader: "CGC",
        grade: 10,
        salePrice: 900000,
        platform: "Goldin",
        saleDate: admin.firestore.Timestamp.fromDate(new Date("2025-10-02")),
        imageUrl: "",
      },
      {
        cardName: "Umbreon VMAX Alt Art PSA 10",
        grader: "PSA",
        grade: 10,
        salePrice: 3800,
        platform: "eBay",
        saleDate: admin.firestore.Timestamp.fromDate(new Date("2026-01-08")),
        imageUrl: "",
      },
      {
        cardName: "Tropical Wind Trophy PSA 8",
        grader: "PSA",
        grade: 8,
        salePrice: 65000,
        platform: "PWCC",
        saleDate: admin.firestore.Timestamp.fromDate(new Date("2025-12-20")),
        imageUrl: "",
      },
    ];

    const batch = db.batch();
    for (const s of sales) {
      batch.set(db.collection("whale_sales").doc(), s);
    }
    await batch.commit();

    res.json({ seeded: sales.length });
  });

// ---------------------------------------------------------------------------
// 8. HTTP: Seed market_meta/sentiment
// ---------------------------------------------------------------------------

export const seedSentiment = functions
  .runWith({ timeoutSeconds: 30 })
  .https.onRequest(async (req, res) => {
    if (req.headers["x-admin-secret"] !== process.env.ADMIN_SECRET) {
      res.status(403).send("Forbidden");
      return;
    }

    await db.collection("market_meta").doc("sentiment").set({
      direction: "Bullish",
      pct: 40,
      hotCard: "Umbreon VMAX",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({ ok: true });
  });

// ---------------------------------------------------------------------------
// 9. Scheduled: Snapshot portfolio values (daily at midnight UTC)
//
// For each user who has a sub-collection 'user_collection/{uid}/items',
// sums the current eBay NM price × 1 for each item and writes a dated
// snapshot to /users/{uid}/snapshots/{date}.
// ---------------------------------------------------------------------------

export const snapshotPortfolioValues = functions
  .runWith({ timeoutSeconds: 540, memory: "512MB" })
  .pubsub.schedule("every 24 hours")
  .onRun(async () => {
    // List all users with collections
    const usersSnap = await db.collection("user_collection").listDocuments();
    const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

    for (const userRef of usersSnap) {
      const uid = userRef.id;
      const itemsSnap = await db
        .collection("user_collection")
        .doc(uid)
        .collection("items")
        .get();

      if (itemsSnap.empty) continue;

      let totalValue = 0;
      let itemCount = 0;

      for (const itemDoc of itemsSnap.docs) {
        const data = itemDoc.data();
        const cardRef = data.card_ref as admin.firestore.DocumentReference;
        if (!cardRef) continue;

        try {
          const cardDoc = await cardRef.get();
          const price: number =
            cardDoc.data()?.pricing?.ebay_us?.last_sold_nm ?? 0;
          totalValue += price;
          itemCount++;
        } catch (_) {
          // Skip unavailable cards
        }
      }

      if (itemCount === 0) continue;

      await db
        .collection("users")
        .doc(uid)
        .collection("snapshots")
        .doc(today)
        .set({
          totalValue,
          itemCount,
          date: admin.firestore.Timestamp.fromDate(new Date(today)),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }

    functions.logger.info(`Portfolio snapshots written for ${usersSnap.length} users`);
  });
