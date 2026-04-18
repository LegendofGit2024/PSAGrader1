import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/binder.dart';
import '../models/card.dart';
import '../models/collection_item.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

part 'collection_provider.g.dart';

// ---------------------------------------------------------------------------
// Collection items — live stream
// ---------------------------------------------------------------------------

@riverpod
Stream<List<CollectionItem>> collection(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(firestoreServiceProvider).watchCollection(uid);
}

// ---------------------------------------------------------------------------
// Per-item stream (for detail screen)
// ---------------------------------------------------------------------------

@riverpod
Future<CollectionItem?> collectionItem(Ref ref, String itemId) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(firestoreServiceProvider).getItem(uid, itemId);
}

// ---------------------------------------------------------------------------
// Binders — live stream
// ---------------------------------------------------------------------------

@riverpod
Stream<List<Binder>> binders(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(firestoreServiceProvider).watchBinders(uid);
}

// ---------------------------------------------------------------------------
// Collection filtered by binder
// ---------------------------------------------------------------------------

@riverpod
AsyncValue<List<CollectionItem>> binderItems(Ref ref, String binderId) {
  final allAsync = ref.watch(collectionProvider);
  return allAsync.whenData(
      (items) => items.where((i) => i.location.binderId?.id == binderId).toList());
}

// ---------------------------------------------------------------------------
// Resolved card for a collection item (joins card_ref → CardDocument)
// ---------------------------------------------------------------------------

@riverpod
Future<CardDocument?> resolvedCard(Ref ref, String cardId) =>
    ref.watch(firestoreServiceProvider).getCard(cardId);

// ---------------------------------------------------------------------------
// Market value helpers
// ---------------------------------------------------------------------------

/// Best available market price for a single item given its condition.
///
/// Priority order:
///   Slab  → graded.psa10 → graded.psa9 → graded.psa8
///           → raw.lastSold → legacy lastSoldNm
///   Raw   → raw.lastSold → TCGPlayer by condition → legacy lastSoldNm
double? itemMarketValue(CollectionItem item, CardDocument card) {
  final ebay = card.pricing.ebayUs;

  if (item.condition.type == ConditionType.slab) {
    // Use the most relevant graded price for the slab's grade
    final graded = ebay?.graded;
    return graded?.psa10
        ?? graded?.psa9
        ?? graded?.psa8
        ?? ebay?.raw?.lastSold
        ?? ebay?.lastSoldNm;
  }

  // Raw card — prefer live eBay raw median, then TCGPlayer by condition
  final rawPrice = ebay?.raw?.lastSold ?? ebay?.lastSoldNm;
  if (rawPrice != null) return rawPrice;

  final cond = item.condition.rawCondition;
  final p = card.pricing.tcgplayerUs;
  if (p == null || cond == null) return null;
  return switch (cond) {
    RawCondition.nm  => p.marketNm,
    RawCondition.lp  => p.marketLp,
    RawCondition.mp  => p.marketMp,
    RawCondition.hp  => p.marketHp,
    RawCondition.dmg => p.marketDmg,
  };
}

// ---------------------------------------------------------------------------
// Portfolio stats (extended for Bento grid + Dashboard)
// ---------------------------------------------------------------------------

@riverpod
AsyncValue<PortfolioStats> portfolioStats(Ref ref) {
  final allAsync = ref.watch(collectionProvider);
  return allAsync.whenData((items) {
    final totalCost =
        items.fold<double>(0, (s, i) => s + i.acquisition.costBasis);
    final slabItems =
        items.where((i) => i.condition.type == ConditionType.slab).toList();
    final rawItems =
        items.where((i) => i.condition.type == ConditionType.raw).toList();

    final graderBreakdown = <Grader, int>{};
    for (final item in slabItems) {
      final g = item.condition.slab?.grader;
      if (g != null) graderBreakdown[g] = (graderBreakdown[g] ?? 0) + 1;
    }

    return PortfolioStats(
      totalItems: items.length,
      rawCount: rawItems.length,
      slabCount: slabItems.length,
      totalCostBasis: totalCost,
      graderBreakdown: graderBreakdown,
    );
  });
}

// ---------------------------------------------------------------------------
// Total market value (resolves all cards — cached via Riverpod)
// ---------------------------------------------------------------------------

@riverpod
Future<PortfolioValuation> portfolioValuation(Ref ref) async {
  final items = await ref.watch(collectionProvider.future);
  final fs = ref.watch(firestoreServiceProvider);

  double totalMarket = 0;
  double totalCost = 0;
  CollectionItem? crownJewelItem;
  CardDocument? crownJewelCard;
  double crownJewelValue = 0;

  CollectionItem? topGainerItem;
  CardDocument? topGainerCard;
  double topGainerDelta = 0; // % 24h change

  for (final item in items) {
    final card = await fs.getCard(item.cardRef.id);
    if (card == null) continue;

    final market = itemMarketValue(item, card);
    // Fall back to cost basis when no live pricing is available yet
    final effectiveValue = market ?? item.acquisition.costBasis;
    totalCost += item.acquisition.costBasis;
    totalMarket += effectiveValue;
    if (true) {
      // Crown Jewel = highest current effective value
      if (effectiveValue > crownJewelValue) {
        crownJewelValue = effectiveValue;
        crownJewelItem = item;
        crownJewelCard = card;
      }
      // Top Gainer — uses eBay 7d volume as a proxy until real 24h delta is available
      final vol = card.pricing.ebayUs?.volume7d ?? 0;
      if (vol > topGainerDelta && effectiveValue > 0) {
        topGainerDelta = vol.toDouble();
        topGainerItem = item;
        topGainerCard = card;
      }
    }
  }

  // Liquidity score: PSA 9/10 slabs of popular sets are most liquid
  final liquidityScore = _calculateLiquidity(items);

  return PortfolioValuation(
    totalMarketValue: totalMarket,
    totalCostBasis: totalCost,
    unrealizedGains: totalMarket - totalCost,
    liquidityScore: liquidityScore,
    crownJewelItem: crownJewelItem,
    crownJewelCard: crownJewelCard,
    topGainerItem: topGainerItem,
    topGainerCard: topGainerCard,
  );
}

/// Liquidity scoring:
/// A+ (0.90–1.0): Mostly high-grade PSA slabs with fresh eBay data
/// A  (0.75–0.89)
/// B  (0.55–0.74)
/// C  (0.35–0.54)
/// D  (0.15–0.34)
/// F  (<0.15): Mostly ungraded, no market data
double _calculateLiquidity(List<CollectionItem> items) {
  if (items.isEmpty) return 0;
  double score = 0;
  for (final item in items) {
    if (item.condition.type == ConditionType.slab) {
      final grade = item.condition.slab?.grade ?? 0;
      if (grade >= 9.5) score += 1.0;
      else if (grade >= 9.0) score += 0.8;
      else if (grade >= 8.0) score += 0.55;
      else score += 0.3;
    } else {
      final cond = item.condition.rawCondition;
      if (cond == RawCondition.nm) score += 0.5;
      else if (cond == RawCondition.lp) score += 0.35;
      else score += 0.15;
    }
  }
  return (score / items.length).clamp(0.0, 1.0);
}

String liquidityGrade(double score) {
  if (score >= 0.90) return 'A+';
  if (score >= 0.75) return 'A';
  if (score >= 0.55) return 'B';
  if (score >= 0.35) return 'C';
  if (score >= 0.15) return 'D';
  return 'F';
}

// ---------------------------------------------------------------------------
// All-Time High tracking (stored in Firestore under users/{uid}/stats)
// ---------------------------------------------------------------------------

@riverpod
Future<double> allTimeHigh(Ref ref) async {
  final uid = ref.watch(currentUidProvider);
  final fs = ref.watch(firestoreServiceProvider);
  return fs.getAllTimeHigh(uid);
}

// ---------------------------------------------------------------------------
// Missing Piece alert — finds sets where user owns N-1 cards
// ---------------------------------------------------------------------------

@riverpod
Future<List<MissingPieceAlert>> missingPieceAlerts(Ref ref) async {
  final items = await ref.watch(collectionProvider.future);
  final fs = ref.watch(firestoreServiceProvider);

  // Group owned cards by set_id
  final setOwnership = <String, Set<String>>{};
  for (final item in items) {
    final card = await fs.getCard(item.cardRef.id);
    if (card == null) continue;
    setOwnership.putIfAbsent(card.meta.setId, () => {}).add(card.meta.setNumber);
  }

  final alerts = <MissingPieceAlert>[];
  for (final entry in setOwnership.entries) {
    final setCards = await fs.getSetCards(entry.key);
    if (setCards.isEmpty) continue;
    final total = setCards.length;
    final owned = entry.value.length;
    if (owned == total - 1) {
      final missing = setCards.firstWhere(
        (c) => !entry.value.contains(c.meta.setNumber),
        orElse: () => setCards.first,
      );
      alerts.add(MissingPieceAlert(
        setId: entry.key,
        ownedCount: owned,
        totalCount: total,
        missingCard: missing,
      ));
    }
  }
  return alerts;
}

// ---------------------------------------------------------------------------
// Market correlation — Vintage vs Modern portfolio weighting
// ---------------------------------------------------------------------------

@riverpod
Future<MarketCorrelation> marketCorrelation(Ref ref) async {
  final items = await ref.watch(collectionProvider.future);
  final fs = ref.watch(firestoreServiceProvider);

  int vintageCount = 0; // sets released before 2003
  int modernCount = 0;

  const vintageSetPrefixes = {
    'base', 'jungle', 'fossil', 'team-rocket', 'gym', 'neo', 'e-card',
    'legendary-collection', 'expedition'
  };

  for (final item in items) {
    final card = await fs.getCard(item.cardRef.id);
    if (card == null) continue;
    final setId = card.meta.setId.toLowerCase();
    final isVintage =
        vintageSetPrefixes.any((prefix) => setId.startsWith(prefix));
    if (isVintage) vintageCount++; else modernCount++;
  }

  final total = vintageCount + modernCount;
  return MarketCorrelation(
    vintagePct: total > 0 ? vintageCount / total : 0,
    modernPct: total > 0 ? modernCount / total : 0,
    dominantMarket: vintageCount >= modernCount ? 'Vintage' : 'Modern',
  );
}

// ---------------------------------------------------------------------------
// Value objects
// ---------------------------------------------------------------------------

class PortfolioStats {
  const PortfolioStats({
    required this.totalItems,
    required this.rawCount,
    required this.slabCount,
    required this.totalCostBasis,
    required this.graderBreakdown,
  });
  final int totalItems;
  final int rawCount;
  final int slabCount;
  final double totalCostBasis;
  final Map<Grader, int> graderBreakdown;
}

class PortfolioValuation {
  const PortfolioValuation({
    required this.totalMarketValue,
    required this.totalCostBasis,
    required this.unrealizedGains,
    required this.liquidityScore,
    this.crownJewelItem,
    this.crownJewelCard,
    this.topGainerItem,
    this.topGainerCard,
  });
  final double totalMarketValue;
  final double totalCostBasis;
  final double unrealizedGains;
  final double liquidityScore;
  final CollectionItem? crownJewelItem;
  final CardDocument? crownJewelCard;
  final CollectionItem? topGainerItem;
  final CardDocument? topGainerCard;

  bool get isUp => unrealizedGains > 0;
  double get roiPct =>
      totalCostBasis > 0 ? (unrealizedGains / totalCostBasis) * 100 : 0;
}

class MissingPieceAlert {
  const MissingPieceAlert({
    required this.setId,
    required this.ownedCount,
    required this.totalCount,
    required this.missingCard,
  });
  final String setId;
  final int ownedCount;
  final int totalCount;
  final CardDocument missingCard;
}

class MarketCorrelation {
  const MarketCorrelation({
    required this.vintagePct,
    required this.modernPct,
    required this.dominantMarket,
  });
  final double vintagePct;
  final double modernPct;
  final String dominantMarket;
}

// ---------------------------------------------------------------------------
// CRUD mutations
// ---------------------------------------------------------------------------

@riverpod
class CollectionMutations extends _$CollectionMutations {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> addItem(CollectionItem item) async {
    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    try {
      final id = await ref.read(firestoreServiceProvider).addItem(uid, item);
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow; // Propagate so the UI try/catch can show the error snackbar
    }
  }

  Future<void> updateItem(CollectionItem item) async {
    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    state = await AsyncValue.guard(
      () => ref.read(firestoreServiceProvider).updateItem(uid, item),
    );
  }

  Future<void> deleteItem(String itemId) async {
    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    state = await AsyncValue.guard(
      () => ref.read(firestoreServiceProvider).deleteItem(uid, itemId),
    );
  }
}

@riverpod
class BinderMutations extends _$BinderMutations {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> addBinder(Binder binder) async {
    state = const AsyncLoading();
    return AsyncValue.guard(
      () => ref.read(firestoreServiceProvider).addBinder(binder),
    ).then((v) {
      state =
          v.hasError ? AsyncError(v.error!, v.stackTrace!) : const AsyncData(null);
      return v.asData?.value;
    });
  }

  Future<void> updateBinder(Binder binder) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firestoreServiceProvider).updateBinder(binder),
    );
  }

  Future<void> deleteBinder(String binderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firestoreServiceProvider).deleteBinder(binderId),
    );
  }
}
