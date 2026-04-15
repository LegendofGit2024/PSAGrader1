import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/card.dart';
import '../models/collection_item.dart';
import '../providers/collection_provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart' show currentUidProvider;

part 'connect_provider.g.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// A single entry in the Submission Activity Feed.
class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.uid,
    required this.displayName,
    required this.avatarUrl,
    required this.cardName,
    required this.graderLabel,
    required this.estimatedValue,
    required this.createdAt,
    this.reactions = const {},
  });

  final String id;
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final String cardName;
  final String graderLabel;
  final double estimatedValue;
  final DateTime createdAt;

  /// reaction type → count
  final Map<String, int> reactions;
}

enum ActivityReaction { fire, rocket, gem }

extension ActivityReactionExt on ActivityReaction {
  String get emoji => switch (this) {
        ActivityReaction.fire   => '🔥',
        ActivityReaction.rocket => '🚀',
        ActivityReaction.gem    => '💎',
      };
  String get key => name; // 'fire' | 'rocket' | 'gem'
}

/// A friend / followed user.
class FriendProfile {
  const FriendProfile({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.gemAccuracyPct,
    this.hasTradeMatch = false,
    this.tradeMatchCount = 0,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;

  /// 0.0 – 1.0 gem accuracy (nullable = no data yet)
  final double? gemAccuracyPct;

  /// True if they have something in their vault that I want
  final bool hasTradeMatch;
  final int tradeMatchCount;
}

/// A single gem-accuracy leaderboard entry.
class GemLeaderEntry {
  const GemLeaderEntry({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.predictions,
    required this.correct,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final int predictions;
  final int correct;

  double get accuracyPct =>
      predictions > 0 ? correct / predictions : 0;
}

/// Portfolio DNA comparison (my vault vs a friend's).
class PortfolioDna {
  const PortfolioDna({
    required this.sharedCards,
    required this.myExtraInvestmentPct,  // positive = I invest more
    required this.cardsOnFriendWishlist,
    required this.friendDisplayName,
  });

  final List<String> sharedCards; // card names
  final double myExtraInvestmentPct;
  final int cardsOnFriendWishlist;
  final String friendDisplayName;

  List<String> get dnaLines {
    final lines = <String>[];

    if (sharedCards.isNotEmpty) {
      lines.add('You both own the ${sharedCards.first}.');
    } else {
      lines.add('No overlapping cards with $friendDisplayName yet.');
    }

    if (myExtraInvestmentPct > 0) {
      lines.add(
          'You are ${myExtraInvestmentPct.toStringAsFixed(0)}% more '
          'invested in Japanese promos than $friendDisplayName.');
    }

    if (cardsOnFriendWishlist > 0) {
      lines.add(
          'You hold $cardsOnFriendWishlist card'
          '${cardsOnFriendWishlist > 1 ? 's' : ''} '
          '$friendDisplayName has on their wishlist.');
    }

    return lines;
  }
}

/// A trade-match between this user and a friend.
class TradeMatch {
  const TradeMatch({
    required this.friend,
    required this.matchedCards,
  });

  final FriendProfile friend;
  final List<CardDocument> matchedCards;
}

// ---------------------------------------------------------------------------
// Activity Feed  (real-time stream)
// ---------------------------------------------------------------------------

@riverpod
Stream<List<ActivityEvent>> activityFeed(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();

  // Show the 50 most recent events from all users the current user follows.
  // In production, filter by following list using array-contains.
  return FirebaseFirestore.instance
      .collection('activity_feed')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map((d) {
            final data = d.data();
            final ts = data['createdAt'];
            return ActivityEvent(
              id: d.id,
              uid: data['uid'] as String? ?? '',
              displayName: data['displayName'] as String? ?? 'Unknown',
              avatarUrl: data['avatarUrl'] as String?,
              cardName: data['cardName'] as String? ?? '',
              graderLabel: data['graderLabel'] as String? ?? 'PSA',
              estimatedValue:
                  (data['estimatedValue'] as num?)?.toDouble() ?? 0,
              createdAt: ts is Timestamp
                  ? ts.toDate()
                  : DateTime.now(),
              reactions: Map<String, int>.from(
                  (data['reactions'] as Map?)?.map(
                        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
                      ) ??
                      {}),
            );
          }).toList());
}

// ---------------------------------------------------------------------------
// Add a reaction to an activity event
// ---------------------------------------------------------------------------

@riverpod
class ReactToEvent extends _$ReactToEvent {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> react(String eventId, ActivityReaction reaction) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection('activity_feed')
          .doc(eventId)
          .update({
        'reactions.${reaction.key}': FieldValue.increment(1),
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// ---------------------------------------------------------------------------
// Publish a submission event (called from SaveEstimate notifier)
// ---------------------------------------------------------------------------

Future<void> publishSubmissionEvent({
  required String uid,
  required String displayName,
  String? avatarUrl,
  required String cardName,
  required String graderLabel,
  required double estimatedValue,
}) async {
  await FirebaseFirestore.instance.collection('activity_feed').add({
    'uid': uid,
    'displayName': displayName,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    'cardName': cardName,
    'graderLabel': graderLabel,
    'estimatedValue': estimatedValue,
    'createdAt': FieldValue.serverTimestamp(),
    'reactions': {'fire': 0, 'rocket': 0, 'gem': 0},
  });
}

// ---------------------------------------------------------------------------
// Friends list
// ---------------------------------------------------------------------------

@riverpod
Future<List<FriendProfile>> friends(Ref ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return [];

  try {
    // Following list lives at /users/{uid}/following/{friendUid}
    final followingSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    final myWishlist = await _fetchWishlist(uid);
    final tradeMatches = await ref.watch(tradeMatchesProvider.future);

    final profiles = <FriendProfile>[];

    for (final doc in followingSnap.docs) {
      final friendUid = doc.id;
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .get();
      if (!profileDoc.exists) continue;

      final data = profileDoc.data()!;
      final match = tradeMatches.where((t) => t.friend.uid == friendUid);
      final matchCount = match.isEmpty ? 0 : match.first.matchedCards.length;

      // Gem accuracy from leaderboard subcollection
      final gemDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .collection('gem_stats')
          .doc('summary')
          .get();

      double? gemPct;
      if (gemDoc.exists) {
        final gd = gemDoc.data()!;
        final total = (gd['predictions'] as num?)?.toInt() ?? 0;
        final correct = (gd['correct'] as num?)?.toInt() ?? 0;
        if (total > 0) gemPct = correct / total;
      }

      profiles.add(FriendProfile(
        uid: friendUid,
        displayName: data['displayName'] as String? ?? 'User',
        avatarUrl: data['avatarUrl'] as String?,
        gemAccuracyPct: gemPct,
        hasTradeMatch: matchCount > 0,
        tradeMatchCount: matchCount,
      ));
    }

    return profiles;
  } catch (_) {
    return [];
  }
}

Future<List<String>> _fetchWishlist(String uid) async {
  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('wishlist')
      .get();
  return snap.docs.map((d) => d.id).toList();
}

// ---------------------------------------------------------------------------
// Gem Accuracy Leaderboard
// ---------------------------------------------------------------------------

@riverpod
Future<List<GemLeaderEntry>> gemLeaderboard(Ref ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return [];

  try {
    final followingSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    final friendUids = followingSnap.docs.map((d) => d.id).toList()
      ..add(uid); // include self

    final entries = <GemLeaderEntry>[];

    for (final fUid in friendUids) {
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(fUid)
          .get();
      if (!profileDoc.exists) continue;
      final profileData = profileDoc.data()!;

      final gemDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(fUid)
          .collection('gem_stats')
          .doc('summary')
          .get();

      final predictions = gemDoc.exists
          ? (gemDoc.data()!['predictions'] as num?)?.toInt() ?? 0
          : 0;
      final correct = gemDoc.exists
          ? (gemDoc.data()!['correct'] as num?)?.toInt() ?? 0
          : 0;

      entries.add(GemLeaderEntry(
        uid: fUid,
        displayName: profileData['displayName'] as String? ?? 'User',
        avatarUrl: profileData['avatarUrl'] as String?,
        predictions: predictions,
        correct: correct,
      ));
    }

    entries.sort((a, b) => b.accuracyPct.compareTo(a.accuracyPct));
    return entries;
  } catch (_) {
    return [];
  }
}

// ---------------------------------------------------------------------------
// Trade Matches
// ---------------------------------------------------------------------------

@riverpod
Future<List<TradeMatch>> tradeMatches(Ref ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return [];

  try {
    final myWishlistIds = await _fetchWishlist(uid);
    if (myWishlistIds.isEmpty) return [];

    final followingSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    final fs = ref.read(firestoreServiceProvider);
    final matches = <TradeMatch>[];

    for (final doc in followingSnap.docs) {
      final friendUid = doc.id;

      // Get friend's public "for sale" items
      final friendItemsSnap = await FirebaseFirestore.instance
          .collection('user_collection')
          .doc(friendUid)
          .collection('items')
          .where('flags.forSale', isEqualTo: true)
          .get();

      final matchedCards = <CardDocument>[];

      for (final itemDoc in friendItemsSnap.docs) {
        final cardId = itemDoc.data()['cardRef'] is DocumentReference
            ? (itemDoc.data()['cardRef'] as DocumentReference).id
            : itemDoc.data()['cardRefId'] as String? ?? '';

        if (myWishlistIds.contains(cardId)) {
          final card = await fs.getCard(cardId);
          if (card != null) matchedCards.add(card);
        }
      }

      if (matchedCards.isNotEmpty) {
        final profileDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendUid)
            .get();
        final profileData = profileDoc.data() ?? {};

        matches.add(TradeMatch(
          friend: FriendProfile(
            uid: friendUid,
            displayName:
                profileData['displayName'] as String? ?? 'User',
            avatarUrl: profileData['avatarUrl'] as String?,
            hasTradeMatch: true,
            tradeMatchCount: matchedCards.length,
          ),
          matchedCards: matchedCards,
        ));
      }
    }

    return matches;
  } catch (_) {
    return [];
  }
}

// ---------------------------------------------------------------------------
// Portfolio DNA comparison
// ---------------------------------------------------------------------------

@riverpod
Future<PortfolioDna?> portfolioDna(
  Ref ref,
  String friendUid,
) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;

  try {
    final fs = ref.read(firestoreServiceProvider);

    // My items
    final myItems = await ref.watch(collectionProvider.future);

    // Friend's public items
    final friendItemsSnap = await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(friendUid)
        .collection('items')
        .get();

    final friendCardIds = friendItemsSnap.docs.map((d) {
      final ref = d.data()['cardRef'];
      return ref is DocumentReference ? ref.id : '';
    }).toSet();

    // My wishlist to check overlap
    final friendWishlistIds =
        await _fetchWishlist(friendUid);

    // Shared cards
    final myCardIds = myItems.map((i) => i.cardRef.id).toSet();
    final sharedIds = myCardIds.intersection(friendCardIds);

    final sharedNames = <String>[];
    for (final id in sharedIds.take(2)) {
      final card = await fs.getCard(id);
      if (card != null) sharedNames.add(card.meta.name);
    }

    // Cards I own that friend wants
    final iHaveWanted =
        myCardIds.intersection(friendWishlistIds.toSet()).length;

    // Japanese promo stub delta
    final myJpCount = myItems
        .where((i) => i.cardRef.id.toLowerCase().contains('jp'))
        .length;
    final friendJpCount = friendItemsSnap.docs
        .where((d) =>
            (d.data()['cardRefId'] as String? ?? '').toLowerCase().contains('jp'))
        .length;
    final jpDelta = myItems.isNotEmpty && friendItemsSnap.docs.isNotEmpty
        ? ((myJpCount / myItems.length) -
                (friendJpCount / friendItemsSnap.docs.length)) *
            100
        : 0.0;

    // Friend name
    final profileDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendUid)
        .get();
    final friendName =
        profileDoc.data()?['displayName'] as String? ?? 'your friend';

    return PortfolioDna(
      sharedCards: sharedNames,
      myExtraInvestmentPct: jpDelta.clamp(0, 100),
      cardsOnFriendWishlist: iHaveWanted,
      friendDisplayName: friendName,
    );
  } catch (_) {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Record a gem result (called when user logs a returned grade)
// ---------------------------------------------------------------------------

@riverpod
class LogGemResult extends _$LogGemResult {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> log({
    required String cardName,
    required double predictedGrade,
    required double actualGrade,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    state = const AsyncLoading();
    try {
      final isCorrect = predictedGrade == actualGrade;
      final batch = FirebaseFirestore.instance.batch();

      // Append to results log
      final logRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('gem_results')
          .doc();

      batch.set(logRef, {
        'cardName': cardName,
        'predicted': predictedGrade,
        'actual': actualGrade,
        'correct': isCorrect,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment summary counters
      final summaryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('gem_stats')
          .doc('summary');

      batch.set(
        summaryRef,
        {
          'predictions': FieldValue.increment(1),
          if (isCorrect) 'correct': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
