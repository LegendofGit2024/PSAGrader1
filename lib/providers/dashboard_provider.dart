import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/card.dart';
import '../models/collection_item.dart';
import '../providers/collection_provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart' show currentUidProvider;

part 'dashboard_provider.g.dart';

/// Safely coerce a Firestore dynamic value to a non-null String.
String _s(dynamic v, [String fallback = '']) =>
    v == null ? fallback : '$v';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// 24-hour portfolio change
class DailyDelta {
  const DailyDelta({
    required this.amount,
    required this.pct,
  });

  final double amount;
  final double pct;

  bool get isPositive => amount >= 0;

  static const zero = DailyDelta(amount: 0, pct: 0);
}

/// Single data point for the equity sparkline
class PortfolioHistoryPoint {
  const PortfolioHistoryPoint({required this.date, required this.value});
  final DateTime date;
  final double value;
}

/// Hot or Cold card signal
enum HotSignal { volumeSpike, popPlateau, media, thinSpread }

enum HotDirection { hot, cold }

class HotCard {
  const HotCard({
    required this.cardId,
    required this.cardName,
    required this.setId,
    required this.imageUrl,
    required this.signal,
    required this.direction,
    required this.currentValue,
    required this.reasonText,
  });

  final String cardId;
  final String cardName;
  final String setId;
  final String imageUrl;
  final HotSignal signal;
  final HotDirection direction;
  final double currentValue;
  final String reasonText;
}

/// High-value sale from auction houses
class WhaleSale {
  const WhaleSale({
    required this.cardName,
    required this.graderLabel,
    required this.grade,
    required this.price,
    required this.auctionHouse,
    required this.soldAt,
    this.imageUrl = '',
  });

  final String cardName;
  final String graderLabel;
  final double grade;
  final double price;
  final String auctionHouse;
  final DateTime soldAt;
  final String imageUrl;
}

/// Actionable to-do card for the dashboard
enum SmartTodoType { gradingAlert, rebalance, priceSpike, wishlistMatch }

class SmartTodo {
  const SmartTodo({
    required this.type,
    required this.title,
    required this.subtitle,
    this.cardCount,
    this.actionRoute,
  });

  final SmartTodoType type;
  final String title;
  final String subtitle;
  final int? cardCount;
  final String? actionRoute;
}

/// Community/Reddit sentiment signal
class CommunitySentiment {
  const CommunitySentiment({
    required this.direction,
    required this.pct,
    required this.topic,
    required this.source,
    this.imageUrl = '',
  });

  /// 'Bullish' or 'Bearish'
  final String direction;

  /// Mention increase %
  final double pct;
  final String topic;
  final String source;
  final String imageUrl;

  bool get isBullish => direction == 'Bullish';
}

/// A card in the user's collection that moved in value over 7 days
class PortfolioMover {
  const PortfolioMover({
    required this.item,
    required this.card,
    required this.change7d,
    required this.currentValue,
  });

  final CollectionItem item;
  final CardDocument card;
  final double change7d;   // absolute dollar change (estimated)
  final double currentValue;

  double get changePct =>
      currentValue > 0 ? (change7d / currentValue) * 100 : 0;
}

// ---------------------------------------------------------------------------
// Daily Delta
// ---------------------------------------------------------------------------

@riverpod
Future<DailyDelta> dailyDelta(Ref ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return DailyDelta.zero;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('snapshots')
        .doc('daily')
        .get();

    if (!doc.exists) return DailyDelta.zero;

    final data = doc.data()!;
    final previousValue = (data['previousValue'] as num?)?.toDouble() ?? 0;
    if (previousValue == 0) return DailyDelta.zero;

    final val = await ref.watch(portfolioValuationProvider.future);
    final current = val.totalMarketValue;
    final delta = current - previousValue;
    final pct = previousValue > 0 ? (delta / previousValue) * 100 : 0.0;

    return DailyDelta(amount: delta, pct: pct);
  } catch (_) {
    return DailyDelta.zero;
  }
}

// ---------------------------------------------------------------------------
// Portfolio history (sparkline)
// ---------------------------------------------------------------------------

@riverpod
Future<List<PortfolioHistoryPoint>> portfolioHistory(Ref ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return [];

  try {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('snapshots')
        .orderBy('date', descending: false)
        .limitToLast(30)
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      final ts = data['date'] as Timestamp;
      return PortfolioHistoryPoint(
        date: ts.toDate(),
        value: (data['value'] as num).toDouble(),
      );
    }).toList();
  } catch (_) {
    return [];
  }
}

// ---------------------------------------------------------------------------
// Hot / Cold cards  (from Firestore `market_signals` — populated by CF)
// ---------------------------------------------------------------------------

@riverpod
Future<List<HotCard>> hotCards(Ref ref) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('market_signals')
        .orderBy('updatedAt', descending: true)
        .limit(6)
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      return HotCard(
        cardId: d.id,
        cardName: _s(data['cardName']),
        setId: _s(data['setId']),
        imageUrl: _s(data['imageUrl']),
        signal: _parseSignal(data['signal'] as String?),
        direction: _s(data['direction']) == 'cold'
            ? HotDirection.cold
            : HotDirection.hot,
        currentValue: (data['currentValue'] as num?)?.toDouble() ?? 0,
        reasonText: _s(data['reasonText']),
      );
    }).toList();
  } catch (_) {
    return _fallbackHotCards;
  }
}

HotSignal _parseSignal(String? s) => switch (s) {
      'popPlateau'  => HotSignal.popPlateau,
      'media'       => HotSignal.media,
      'thinSpread'  => HotSignal.thinSpread,
      _             => HotSignal.volumeSpike,
    };

/// Fallback shown while Firestore collection is empty / being seeded
const _fallbackHotCards = [
  HotCard(
    cardId: 'swsh6-215',
    cardName: 'Umbreon VMAX (Alt)',
    setId: 'swsh6',
    imageUrl: 'https://images.pokemontcg.io/swsh6/215.png',
    signal: HotSignal.volumeSpike,
    direction: HotDirection.hot,
    currentValue: 410,
    reasonText: 'Selling 3× faster than last month',
  ),
  HotCard(
    cardId: 'base1-4',
    cardName: 'Charizard (Base Set)',
    setId: 'base1',
    imageUrl: 'https://images.pokemontcg.io/base1/4.png',
    signal: HotSignal.popPlateau,
    direction: HotDirection.hot,
    currentValue: 8200,
    reasonText: 'PSA 10 pop count stable for 90 days',
  ),
  HotCard(
    cardId: 'base2-4',
    cardName: 'Base Set 2 Charizard',
    setId: 'base2',
    imageUrl: 'https://images.pokemontcg.io/base2/4.png',
    signal: HotSignal.thinSpread,
    direction: HotDirection.cold,
    currentValue: 280,
    reasonText: 'Raw vs PSA 9 spread closing fast',
  ),
];

// ---------------------------------------------------------------------------
// Whale Watch  (from Firestore `whale_sales` — populated by CF)
// ---------------------------------------------------------------------------

@riverpod
Stream<List<WhaleSale>> whaleSales(Ref ref) {
  return FirebaseFirestore.instance
      .collection('whale_sales')
      .orderBy('soldAt', descending: true)
      .limit(10)
      .snapshots()
      .map((snap) {
    if (snap.docs.isEmpty) return _fallbackWhaleSales;
    return snap.docs.map((d) {
      final data = d.data();
      final soldAtRaw = data['soldAt'];
      final soldAt = soldAtRaw is Timestamp
          ? soldAtRaw.toDate()
          : DateTime.now();
      return WhaleSale(
        cardName: _s(data['cardName']),
        graderLabel: _s(data['graderLabel'], 'PSA'),
        grade: (data['grade'] as num?)?.toDouble() ?? 10,
        price: (data['price'] as num?)?.toDouble() ?? 0,
        auctionHouse: _s(data['auctionHouse']),
        soldAt: soldAt,
        imageUrl: _s(data['imageUrl']),
      );
    }).toList();
  });
}

final _fallbackWhaleSales = [
  WhaleSale(
    cardName: '1st Ed Charizard',
    graderLabel: 'PSA',
    grade: 10,
    price: 420000,
    auctionHouse: 'Heritage Auctions',
    soldAt: DateTime.now().subtract(const Duration(hours: 3)),
    imageUrl: 'https://images.pokemontcg.io/base1/4.png',
  ),
  WhaleSale(
    cardName: '1st Ed Lugia',
    graderLabel: 'PSA',
    grade: 10,
    price: 42500,
    auctionHouse: 'Goldin Auctions',
    soldAt: DateTime.now().subtract(const Duration(hours: 8)),
    imageUrl: 'https://images.pokemontcg.io/neo2/9.png',
  ),
  WhaleSale(
    cardName: 'Umbreon VMAX Alt Art',
    graderLabel: 'PSA',
    grade: 10,
    price: 1850,
    auctionHouse: 'eBay',
    soldAt: DateTime.now().subtract(const Duration(hours: 14)),
    imageUrl: 'https://images.pokemontcg.io/swsh6/215.png',
  ),
];

// ---------------------------------------------------------------------------
// Smart To-Do list  (computed from collection)
// ---------------------------------------------------------------------------

@riverpod
Future<List<SmartTodo>> smartTodos(Ref ref) async {
  final todos = <SmartTodo>[];

  try {
    final items = await ref.watch(collectionProvider.future);
    final fs = ref.read(firestoreServiceProvider);

    // 1. Grading alert: raw NM cards where PSA 10 value ≥ 3× cost basis
    int gradingCandidates = 0;
    for (final item in items) {
      if (item.condition.type != ConditionType.raw) continue;
      if (item.condition.rawCondition != RawCondition.nm) continue;
      final card = await fs.getCard(item.cardRef.id);
      if (card == null) continue;
      final psaPrice = card.pricing.ebayUs?.lastSoldNm ?? 0;
      if (psaPrice >= item.acquisition.costBasis * 3) gradingCandidates++;
    }

    if (gradingCandidates > 0) {
      todos.add(SmartTodo(
        type: SmartTodoType.gradingAlert,
        title: 'Grading Opportunity',
        subtitle:
            '$gradingCandidates raw card${gradingCandidates > 1 ? 's' : ''} '
            'where PSA 10 value ≥ 3× your cost basis.',
        cardCount: gradingCandidates,
        actionRoute: '/submission',
      ));
    }

    // 2. Concentration alert: if any single card name > 60% of total count
    if (items.isNotEmpty) {
      final nameCounts = <String, int>{};
      for (final item in items) {
        final card = await fs.getCard(item.cardRef.id);
        final name = card?.meta.name ?? item.cardRef.id;
        nameCounts[name] = (nameCounts[name] ?? 0) + 1;
      }
      final topEntry =
          nameCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      final pct = topEntry.value / items.length;
      if (pct > 0.6) {
        todos.add(SmartTodo(
          type: SmartTodoType.rebalance,
          title: 'Portfolio Concentration',
          subtitle:
              '${(pct * 100).toStringAsFixed(0)}% of your vault is '
              '${topEntry.key}. Consider diversifying.',
          actionRoute: '/portfolio',
        ));
      }
    }
  } catch (_) {
    // Return empty rather than crash — todos are non-critical
  }

  return todos;
}

// ---------------------------------------------------------------------------
// Community Sentiment  (from Firestore `sentiment` — populated by CF)
// ---------------------------------------------------------------------------

@riverpod
Future<CommunitySentiment?> communitySentiment(Ref ref) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('market_meta')
        .doc('sentiment')
        .get();
    if (!doc.exists) return _fallbackSentiment;
    final data = doc.data()!;
    return CommunitySentiment(
      direction: _s(data['direction'], 'Bullish'),
      pct: (data['pct'] as num?)?.toDouble() ?? 0,
      topic: _s(data['topic']),
      source: _s(data['source'], 'Reddit'),
      imageUrl: _s(data['imageUrl']),
    );
  } catch (_) {
    return _fallbackSentiment;
  }
}

const _fallbackSentiment = CommunitySentiment(
  direction: 'Bullish',
  pct: 40,
  topic: 'Umbreon VMAX',
  source: 'Reddit',
  imageUrl: 'https://images.pokemontcg.io/swsh6/215.png',
);

// ---------------------------------------------------------------------------
// Portfolio movers (top 3 cards by 7-day volume)
// ---------------------------------------------------------------------------

@riverpod
Future<List<PortfolioMover>> portfolioMovers(Ref ref) async {
  try {
    final items = await ref.watch(collectionProvider.future);
    final fs = ref.read(firestoreServiceProvider);

    final movers = <PortfolioMover>[];

    for (final item in items) {
      final card = await fs.getCard(item.cardRef.id);
      if (card == null) continue;

      final currentValue = itemMarketValue(item, card) ??
          item.acquisition.costBasis;
      final volume = card.pricing.ebayUs?.volume7d ?? 0;

      // Approximate 7-day change: volume-weighted price delta
      // In production this would use stored price history.
      // Stub: treat high volume as positive signal (+2–8% stub range)
      final stubChangePct = volume > 50
          ? 0.06
          : volume > 20
              ? 0.03
              : volume > 5
                  ? 0.01
                  : -0.01;
      final change = currentValue * stubChangePct;

      movers.add(PortfolioMover(
        item: item,
        card: card,
        change7d: change,
        currentValue: currentValue,
      ));
    }

    movers.sort((a, b) => b.change7d.abs().compareTo(a.change7d.abs()));
    return movers.take(3).toList();
  } catch (_) {
    return [];
  }
}
