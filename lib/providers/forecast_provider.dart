import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/card.dart';
import '../models/collection_item.dart';
import '../providers/collection_provider.dart';
import '../services/firestore_service.dart';

part 'forecast_provider.g.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Heat Index thresholds
const kHeatHot  = 1.5;
const kHeatCold = 0.5;

/// Supply squeeze thresholds
const kListingDropPct   = 0.20; // ≥20% fewer active listings WoW
const kPopGrowthMax     = 0.01; // PSA 10 pop growth < 1%

/// Overheat thresholds
const kPriceJump14d     = 0.30; // >30% price jump in 14 days
const kNewSellerRatio   = 0.35; // >35% listings from accounts <90 days old

/// Historical CAGR per set prefix (rough market estimates)
const Map<String, double> kSetCagr = {
  'base'       : 0.28,
  'jungle'     : 0.22,
  'fossil'     : 0.20,
  'team-rocket': 0.18,
  'neo'        : 0.24,
  'gym'        : 0.16,
  'sv'         : 0.15, // Scarlet & Violet era
  'swsh'       : 0.14, // Sword & Shield
  'sm'         : 0.12, // Sun & Moon
  'xy'         : 0.13,
  'bw'         : 0.11,
};

double cagrForSet(String setId) {
  final lower = setId.toLowerCase();
  for (final entry in kSetCagr.entries) {
    if (lower.startsWith(entry.key)) return entry.value;
  }
  return 0.12; // default
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum ForecastSignal { buy, hold, sell }

enum WhyIcon { highVelocity, lowSupply, popPlateau, overheating, flippers, steady }

class WhyTag {
  const WhyTag({required this.icon, required this.label});
  final WhyIcon icon;
  final String label;
}

class HeatResult {
  const HeatResult({
    required this.index,
    required this.salesVelocity,
    required this.priceDelta7d,
  });
  final double index;
  final double salesVelocity;
  final double priceDelta7d;

  bool get isHot  => index > kHeatHot;
  bool get isCold => index < kHeatCold;

  String get label => isHot ? 'HEATING UP' : isCold ? 'COOLING DOWN' : 'STABLE';
}

class SignalResult {
  const SignalResult({
    required this.signal,
    required this.confidence,
    required this.reasoning,
    required this.whyTags,
  });
  final ForecastSignal signal;

  /// 0.0–1.0
  final double confidence;
  final String reasoning;
  final List<WhyTag> whyTags;
}

class ProjectionResult {
  const ProjectionResult({
    required this.currentPrice,
    required this.projectedPrice1Y,
    required this.cagr,
    required this.sentimentMultiplier,
    required this.setId,
    this.scarcityMultiplier = 1.0,
    this.velocityMultiplier = 1.0,
    this.ageFactor = 1.0,
    this.projectionPoints = const [],
    this.projectionPoints5y = const [],
    this.projectionPoints10y = const [],
  });

  final double currentPrice;
  final double projectedPrice1Y;
  final double cagr;
  final double sentimentMultiplier;
  final String setId;

  /// PSA 10 scarcity bonus: 1.0 (not scarce) → 1.5 (very scarce)
  final double scarcityMultiplier;

  /// Volume confidence: 0.9 (illiquid) → 1.2 (high volume)
  final double velocityMultiplier;

  /// Set age / out-of-print long-term lift: 1.0 or 1.15 (vintage)
  final double ageFactor;

  /// 13 monthly price points (month 0 = now, month 12 = projected)
  final List<ProjectionPoint> projectionPoints;

  /// 61-point monthly projection curve for 5 years
  final List<ProjectionPoint> projectionPoints5y;

  /// 121-point monthly projection curve for 10 years
  final List<ProjectionPoint> projectionPoints10y;

  double get returnPct =>
      currentPrice > 0
          ? ((projectedPrice1Y - currentPrice) / currentPrice) * 100
          : 0;
}

/// A single point on the 12-month projected price curve
class ProjectionPoint {
  const ProjectionPoint({required this.month, required this.price});
  final int month;      // 0 = now, 12 = 1 year out
  final double price;
}

/// 30-day price history point (loaded from Firestore price_history collection)
class PricePoint {
  const PricePoint({required this.date, required this.price});
  final DateTime date;
  final double price;
}

/// S&P 500 benchmark comparison
class BenchmarkComparison {
  const BenchmarkComparison({
    required this.cardReturn1Y,
    required this.sp500Return1Y,
    required this.cardName,
  });
  final double cardReturn1Y;
  final double sp500Return1Y;
  final String cardName;

  bool get beatsMarket => cardReturn1Y > sp500Return1Y;
  double get alpha => cardReturn1Y - sp500Return1Y;
}

/// Full forecast for a single card
class CardForecast {
  const CardForecast({
    required this.card,
    required this.heat,
    required this.signal,
    required this.projection,
    required this.priceHistory,
    required this.benchmark,
  });

  final CardDocument card;
  final HeatResult heat;
  final SignalResult signal;
  final ProjectionResult projection;
  final List<PricePoint> priceHistory;
  final BenchmarkComparison benchmark;
}

// ---------------------------------------------------------------------------
// Forecast Engine
// ---------------------------------------------------------------------------

class ForecastEngine {
  // ── Heat Index ────────────────────────────────────────────────────────────
  // Heat Index = (Sales Velocity × 0.6) + (Price Delta 7d × 0.4)
  // Sales Velocity: volume24h / (volume30d / 30)  — ratio vs daily avg
  // Price Delta:    (currentPrice - price7dAgo) / price7dAgo

  static HeatResult computeHeat({
    required double volume24h,
    required double volume30d,
    required double currentPrice,
    required double price7dAgo,
  }) {
    final dailyAvg = volume30d > 0 ? volume30d / 30 : 1;
    final velocity = dailyAvg > 0 ? volume24h / dailyAvg : 1.0;
    final delta    = price7dAgo > 0
        ? (currentPrice - price7dAgo) / price7dAgo
        : 0.0;

    // Normalise delta to roughly same scale as velocity (both ~0–2 range)
    final normDelta = (delta * 10).clamp(-2.0, 2.0);
    final index = (velocity * 0.6) + (normDelta * 0.4);

    return HeatResult(
      index: index,
      salesVelocity: velocity,
      priceDelta7d: delta,
    );
  }

  // ── Buy/Hold/Sell signal ──────────────────────────────────────────────────

  static SignalResult computeSignal({
    required double listingDropWoW,     // positive = fewer listings
    required double popGrowthRate,      // fractional, e.g. 0.005 = 0.5%
    required double priceJump14d,       // fractional, e.g. 0.35 = 35%
    required double newSellerRatio,     // fraction of listings from new sellers
    required HeatResult heat,
  }) {
    final tags  = <WhyTag>[];
    var buyScore  = 0.0;
    var sellScore = 0.0;

    // ── Buy signals ─────────────────────────────────────────────────────────
    if (listingDropWoW >= kListingDropPct) {
      buyScore += 0.4;
      tags.add(const WhyTag(
        icon: WhyIcon.lowSupply,
        label: 'Low Supply',
      ));
    }
    if (popGrowthRate < kPopGrowthMax) {
      buyScore += 0.3;
      tags.add(const WhyTag(
        icon: WhyIcon.popPlateau,
        label: 'Pop Plateau',
      ));
    }
    if (heat.isHot) {
      buyScore += 0.2;
      tags.add(const WhyTag(
        icon: WhyIcon.highVelocity,
        label: 'High Velocity',
      ));
    }

    // ── Sell signals ─────────────────────────────────────────────────────────
    if (priceJump14d >= kPriceJump14d) {
      sellScore += 0.5;
      tags.add(const WhyTag(
        icon: WhyIcon.overheating,
        label: 'Overheating',
      ));
    }
    if (newSellerRatio >= kNewSellerRatio) {
      sellScore += 0.4;
      tags.add(const WhyTag(
        icon: WhyIcon.flippers,
        label: 'Flipper Influx',
      ));
    }

    if (tags.isEmpty) {
      tags.add(const WhyTag(icon: WhyIcon.steady, label: 'Steady'));
    }

    final ForecastSignal signal;
    final double confidence;
    final String reasoning;

    if (sellScore > buyScore && sellScore >= 0.4) {
      signal     = ForecastSignal.sell;
      confidence = sellScore.clamp(0.0, 1.0);
      reasoning  = priceJump14d >= kPriceJump14d
          ? 'Market is showing signs of overheating. Short-term flippers are '
            'entering; high probability of a 10–15% correction.'
          : 'Elevated sell pressure detected. Consider taking partial profits.';
    } else if (buyScore >= 0.4) {
      signal     = ForecastSignal.buy;
      confidence = buyScore.clamp(0.0, 1.0);
      reasoning  = listingDropWoW >= kListingDropPct
          ? 'Supply on secondary markets is drying up while grading volume has '
            'plateaued. Historically, this precedes a price jump.'
          : 'Demand is rising while supply tightens. Strong accumulation window.';
    } else {
      signal     = ForecastSignal.hold;
      confidence = 0.5;
      reasoning  = 'No strong directional signal. Market is balanced — '
                   'hold your position and monitor for changes.';
    }

    return SignalResult(
      signal: signal,
      confidence: confidence,
      reasoning: reasoning,
      whyTags: tags,
    );
  }

  // ── 1-Year Projection ────────────────────────────────────────────────────
  // Adjusted annual return = base CAGR × scarcity × velocity × age × sentiment
  // sentimentMultiplier: 0.5 (bearish) → 1.5 (very bullish)

  static ProjectionResult computeProjection({
    required double currentPrice,
    required String setId,
    required double sentimentMultiplier,
    PsaPop? psaPop,
    double? volume7d,
  }) {
    final baseCagr = cagrForSet(setId);
    final scarcity = computeScarcityMultiplier(psaPop);
    final velocity = computeVelocityMultiplier(volume7d);
    final age      = computeAgeFactor(setId);

    // Adjusted annual return = base CAGR × all multipliers × sentiment
    final adjustedReturn =
        baseCagr * scarcity * velocity * age * sentimentMultiplier;

    final projected = currentPrice * (1.0 + adjustedReturn);

    final points = generateProjectionPoints(
      currentPrice: currentPrice,
      annualReturn: adjustedReturn,
    );
    final points5y = generateProjectionPoints(
      currentPrice: currentPrice,
      annualReturn: adjustedReturn,
      years: 5,
    );
    final points10y = generateProjectionPoints(
      currentPrice: currentPrice,
      annualReturn: adjustedReturn,
      years: 10,
    );

    return ProjectionResult(
      currentPrice:        currentPrice,
      projectedPrice1Y:    projected,
      cagr:                baseCagr,
      sentimentMultiplier: sentimentMultiplier,
      setId:               setId,
      scarcityMultiplier:  scarcity,
      velocityMultiplier:  velocity,
      ageFactor:           age,
      projectionPoints:    points,
      projectionPoints5y:  points5y,
      projectionPoints10y: points10y,
    );
  }

  // ── S&P 500 benchmark comparison ─────────────────────────────────────────
  // S&P 500 annualised return stub — in production pulled from a free index API
  static const _sp500Cagr = 0.105; // ~10.5% historical average

  static BenchmarkComparison computeBenchmark({
    required String cardName,
    required double projectedReturnPct,
  }) {
    return BenchmarkComparison(
      cardName: cardName,
      cardReturn1Y: projectedReturnPct,
      sp500Return1Y: _sp500Cagr * 100,
    );
  }

  // ── Scarcity Multiplier ───────────────────────────────────────────────────
  // Low PSA 10 % of total pop → higher scarcity → bigger upside multiplier
  // Range: 1.0 (not scarce / no data) → 1.5 (very scarce)
  static double computeScarcityMultiplier(PsaPop? psaPop) {
    if (psaPop == null) return 1.0;
    final total = psaPop.totalPop ?? 0;
    final pop10 = psaPop.pop10 ?? 0;
    if (total == 0) return 1.0;
    final psa10Ratio = (pop10 / total).clamp(0.0, 1.0);
    // Invert: low ratio = high scarcity
    return 1.0 + (1.0 - psa10Ratio) * 0.5;
  }

  // ── Velocity Multiplier ───────────────────────────────────────────────────
  // Higher weekly eBay volume → more confidence in price → small upside boost
  // Range: 0.90 (no data / illiquid) → 1.20 (50+ sales/week)
  static double computeVelocityMultiplier(double? volume7d) {
    if (volume7d == null || volume7d <= 0) return 0.90;
    final norm = (volume7d / 50.0).clamp(0.0, 1.0);
    return 0.90 + norm * 0.30;
  }

  // ── Age / Out-of-Print Factor ─────────────────────────────────────────────
  // Vintage sets (Base Set era through Neo / ex) get a long-term growth lift
  // modelled as 1.05^estimatedAge, capped at 1.15 lift.
  static double computeAgeFactor(String setId) {
    const _vintageSetPrefixes = [
      'base', 'jungle', 'fossil', 'team-rocket', 'neo',
      'gym', 'legend', 'ex', 'dp', 'hgss', 'bw',
    ];
    final lower = setId.toLowerCase();
    for (final prefix in _vintageSetPrefixes) {
      if (lower.startsWith(prefix)) return 1.15;
    }
    return 1.0;
  }

  // ── Projection Curve ──────────────────────────────────────────────────────
  /// Generates monthly projection points for [years] years.
  /// Returns (years × 12 + 1) points: month 0 = now, last = end of projection.
  static List<ProjectionPoint> generateProjectionPoints({
    required double currentPrice,
    required double annualReturn,
    int years = 1,
  }) {
    final totalMonths = years * 12;
    final points = <ProjectionPoint>[];
    for (int m = 0; m <= totalMonths; m++) {
      final factor = _pow(1.0 + annualReturn, m / 12.0);
      points.add(ProjectionPoint(month: m, price: currentPrice * factor));
    }
    return points;
  }

  static double _pow(double base, double exp) {
    if (exp == 0) return 1.0;
    // dart:math pow returns num — use explicit cast
    return math.pow(base, exp).toDouble();
  }
}

// ---------------------------------------------------------------------------
// Sentiment multiplier helper (from dashboard_provider market_meta)
// ---------------------------------------------------------------------------

Future<double> _fetchSentimentMultiplier() async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('market_meta')
        .doc('sentiment')
        .get();
    if (!doc.exists) return 1.0;
    final pct = (doc.data()?['pct'] as num?)?.toDouble() ?? 0;
    final direction = doc.data()?['direction'] as String? ?? 'Bullish';
    // Map mention pct to 0.5–1.5 range
    final normalized = (pct / 100).clamp(0.0, 1.0);
    return direction == 'Bullish'
        ? 1.0 + normalized * 0.5
        : 1.0 - normalized * 0.5;
  } catch (_) {
    return 1.0;
  }
}

// ---------------------------------------------------------------------------
// Price history loader
// ---------------------------------------------------------------------------

Future<List<PricePoint>> _fetchPriceHistory(String cardId) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('cards')
        .doc(cardId)
        .collection('price_history')
        .orderBy('date', descending: false)
        .limitToLast(30)
        .get();

    if (snap.docs.isNotEmpty) {
      return snap.docs.map((d) {
        final ts = d.data()['date'] as Timestamp;
        return PricePoint(
          date: ts.toDate(),
          price: (d.data()['price'] as num).toDouble(),
        );
      }).toList();
    }
  } catch (_) {}

  // Stub: generate a realistic 30-day curve from current price
  return [];
}

/// Generates a realistic stub price history for [days] days back from now.
/// Uses a seeded Brownian-motion style random walk so prices actually vary.
List<PricePoint> generateStubHistory(double currentPrice, {int days = 30}) {
  if (currentPrice <= 0) currentPrice = 10.0;
  final now = DateTime.now();
  final points = <PricePoint>[];

  // Daily volatility: ~1.5% for stable cards, more for cheaper ones
  final dailyVol = math.max(currentPrice * 0.015, 0.5);

  // Start price: drift back from current based on set CAGR (~0.12/year default)
  final dailyDrift = 0.12 / 365;
  double p = currentPrice / math.pow(1 + dailyDrift, days.toDouble());

  // Simple LCG seeded on card price for determinism per card
  int seed = (currentPrice * 1000).toInt() & 0xFFFFFFFF;
  double nextRand() {
    seed = (seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    return (seed / 0xFFFFFFFF) - 0.5; // -0.5 to 0.5
  }

  for (int i = days; i >= 0; i--) {
    final noise = nextRand() * dailyVol * 2;
    final drift = p * dailyDrift;
    p = math.max(p + drift + noise, currentPrice * 0.1);
    points.add(PricePoint(
      date: now.subtract(Duration(days: i)),
      price: double.parse(p.toStringAsFixed(2)),
    ));
  }
  // Force last point to be exactly currentPrice
  if (points.isNotEmpty) {
    points[points.length - 1] = PricePoint(date: now, price: currentPrice);
  }
  return points;
}

// ---------------------------------------------------------------------------
// Market stats loader (active listings, pop growth, new-seller ratio)
// From Firestore `market_stats/{cardId}` — written by Cloud Functions
// ---------------------------------------------------------------------------

class _MarketStats {
  const _MarketStats({
    required this.listingDropWoW,
    required this.popGrowthRate,
    required this.priceJump14d,
    required this.newSellerRatio,
    required this.volume24h,
    required this.volume30d,
    required this.price7dAgo,
  });

  final double listingDropWoW;
  final double popGrowthRate;
  final double priceJump14d;
  final double newSellerRatio;
  final double volume24h;
  final double volume30d;
  final double price7dAgo;

  factory _MarketStats.fallback(double currentPrice) => _MarketStats(
        listingDropWoW: 0.10,
        popGrowthRate: 0.008,
        priceJump14d: 0.05,
        newSellerRatio: 0.15,
        volume24h: 2,
        volume30d: 45,
        price7dAgo: currentPrice * 0.97,
      );
}

Future<_MarketStats> _fetchMarketStats(String cardId, double price) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('market_stats')
        .doc(cardId)
        .get();
    if (!doc.exists) return _MarketStats.fallback(price);
    final d = doc.data()!;
    return _MarketStats(
      listingDropWoW:  (d['listingDropWoW']  as num?)?.toDouble() ?? 0,
      popGrowthRate:   (d['popGrowthRate']   as num?)?.toDouble() ?? 0,
      priceJump14d:    (d['priceJump14d']    as num?)?.toDouble() ?? 0,
      newSellerRatio:  (d['newSellerRatio']  as num?)?.toDouble() ?? 0,
      volume24h:       (d['volume24h']       as num?)?.toDouble() ?? 0,
      volume30d:       (d['volume30d']       as num?)?.toDouble() ?? 0,
      price7dAgo:      (d['price7dAgo']      as num?)?.toDouble() ?? price,
    );
  } catch (_) {
    return _MarketStats.fallback(price);
  }
}

// ---------------------------------------------------------------------------
// Per-card forecast provider
// ---------------------------------------------------------------------------

@riverpod
Future<CardForecast> cardForecast(Ref ref, String cardId) async {
  final fs  = ref.read(firestoreServiceProvider);
  final card = await fs.getCard(cardId);
  if (card == null) throw Exception('Card $cardId not found');

  final currentPrice = card.pricing.ebayUs?.lastSoldNm ?? 0;
  final stats        = await _fetchMarketStats(cardId, currentPrice);
  final sentiment    = await _fetchSentimentMultiplier();

  var history = await _fetchPriceHistory(cardId);
  if (history.isEmpty) history = generateStubHistory(currentPrice, days: 30);

  final heat = ForecastEngine.computeHeat(
    volume24h:    stats.volume24h,
    volume30d:    stats.volume30d,
    currentPrice: currentPrice,
    price7dAgo:   stats.price7dAgo,
  );

  final signal = ForecastEngine.computeSignal(
    listingDropWoW:  stats.listingDropWoW,
    popGrowthRate:   stats.popGrowthRate,
    priceJump14d:    stats.priceJump14d,
    newSellerRatio:  stats.newSellerRatio,
    heat:            heat,
  );

  final projection = ForecastEngine.computeProjection(
    currentPrice:        currentPrice,
    setId:               card.meta.setId,
    sentimentMultiplier: sentiment,
    psaPop:              card.psaPop,
    volume7d:            card.pricing.ebayUs?.volume7d?.toDouble(),
  );

  final benchmark = ForecastEngine.computeBenchmark(
    cardName:           card.meta.name,
    projectedReturnPct: projection.returnPct,
  );

  return CardForecast(
    card:         card,
    heat:         heat,
    signal:       signal,
    projection:   projection,
    priceHistory: history,
    benchmark:    benchmark,
  );
}

// ---------------------------------------------------------------------------
// Portfolio-wide forecast — top movers in collection
// ---------------------------------------------------------------------------

@riverpod
Future<List<CardForecast>> portfolioForecasts(Ref ref) async {
  final items = await ref.watch(collectionProvider.future);
  // Limit to 10 for performance; sorted by market value descending
  final fs = ref.read(firestoreServiceProvider);

  final resolved = <({CollectionItem item, CardDocument card, double price})>[];
  for (final item in items.take(20)) {
    final card = await fs.getCard(item.cardRef.id);
    if (card == null) continue;
    final price = card.pricing.ebayUs?.lastSoldNm ?? 0;
    resolved.add((item: item, card: card, price: price));
  }
  resolved.sort((a, b) => b.price.compareTo(a.price));

  final forecasts = <CardForecast>[];
  for (final r in resolved.take(10)) {
    try {
      final f = await ref.watch(cardForecastProvider(r.card.id).future);
      forecasts.add(f);
    } catch (_) {
      continue;
    }
  }
  return forecasts;
}

// ---------------------------------------------------------------------------
// Search state for the Forecast search bar
// ---------------------------------------------------------------------------

@riverpod
class ForecastSearchQuery extends _$ForecastSearchQuery {
  @override
  String build() => '';

  void set(String q) => state = q;
}

@riverpod
Future<List<CardDocument>> forecastSearchResults(Ref ref) async {
  final q = ref.watch(forecastSearchQueryProvider);
  if (q.length < 2) return [];
  return ref.read(firestoreServiceProvider).searchCards(nameQuery: q);
}
