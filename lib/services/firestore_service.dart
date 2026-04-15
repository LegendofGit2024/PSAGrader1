import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/binder.dart';
import '../models/card.dart';
import '../models/collection_item.dart';
import '../models/submission_estimate.dart';

part 'firestore_service.g.dart';

// ---------------------------------------------------------------------------
// Collection path constants — single source of truth
// ---------------------------------------------------------------------------

abstract class _Col {
  static const cards = 'cards';
  static const sets = 'sets';
  static const userCollection = 'user_collection';
  static const items = 'items';
  static const binders = 'binders';
  static const submissionEstimates = 'submission_estimates';
  static const users = 'users';
  static const wishlist = 'wishlist';
  static const submissions = 'submissions';
}

// ---------------------------------------------------------------------------
// FirestoreService
// ---------------------------------------------------------------------------

class FirestoreService {
  FirestoreService(this._db);

  final FirebaseFirestore _db;

  // ------------------------------------------------------------------
  // Cards
  // ------------------------------------------------------------------

  /// Creates or updates only the meta fields of /cards/{cardId}.
  ///
  /// Builds a plain Map manually rather than going through toJson() —
  /// the freezed-generated serialiser returns nested Dart objects on Flutter
  /// web which Firestore rejects as "unsupported field value".
  /// Using merge:true means any existing pricing rows are never touched.
  Future<void> upsertCard(CardDocument card) {
    final data = <String, dynamic>{
      'meta': <String, dynamic>{
        'name': card.meta.name,
        'set_id': card.meta.setId,
        'set_number': card.meta.setNumber,
        'language': card.meta.language.name, // 'en' | 'jp' | 'kr' | 'zh'
        'variant': card.meta.variant,
        'image_url': card.meta.imageUrl,
      },
    };
    return _db
        .collection(_Col.cards)
        .doc(card.id)
        .set(data, SetOptions(merge: true));
  }

  Future<CardDocument?> getCard(String cardId) async {
    final doc = await _db.collection(_Col.cards).doc(cardId).get();
    if (!doc.exists) return null;
    return CardDocument.fromFirestore(doc);
  }

  Stream<CardDocument?> watchCard(String cardId) => _db
      .collection(_Col.cards)
      .doc(cardId)
      .snapshots()
      .map((s) => s.exists ? CardDocument.fromFirestore(s) : null);

  Future<List<CardDocument>> searchCards({
    String? nameQuery,
    String? setId,
    CardLanguage? language,
    int limit = 20,
  }) async {
    Query query = _db.collection(_Col.cards);
    if (setId != null) query = query.where('meta.set_id', isEqualTo: setId);
    if (language != null) {
      query = query.where('meta.language',
          isEqualTo: language.name.toUpperCase());
    }
    // Name prefix search (Firestore doesn't support full-text; use Algolia for prod)
    if (nameQuery != null && nameQuery.isNotEmpty) {
      query = query
          .where('meta.name', isGreaterThanOrEqualTo: nameQuery)
          .where('meta.name', isLessThan: '${nameQuery}z');
    }
    final snap = await query.limit(limit).get();
    return snap.docs.map(CardDocument.fromFirestore).toList();
  }

  // ------------------------------------------------------------------
  // Collection items
  // ------------------------------------------------------------------

  CollectionReference _itemsRef(String uid) => _db
      .collection(_Col.userCollection)
      .doc(uid)
      .collection(_Col.items);

  Stream<List<CollectionItem>> watchCollection(String uid) => _itemsRef(uid)
      .orderBy('acquisition.acquired_date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(CollectionItem.fromFirestore).toList());

  Future<List<CollectionItem>> getCollection(String uid) async {
    final snap = await _itemsRef(uid)
        .orderBy('acquisition.acquired_date', descending: true)
        .get();
    return snap.docs.map(CollectionItem.fromFirestore).toList();
  }

  Future<CollectionItem?> getItem(String uid, String itemId) async {
    final doc = await _itemsRef(uid).doc(itemId).get();
    if (!doc.exists) return null;
    return CollectionItem.fromFirestore(doc);
  }

  Future<String> addItem(String uid, CollectionItem item) async {
    final ref = await _itemsRef(uid)
        .add(CollectionItem.toFirestore(item));
    return ref.id;
  }

  Future<void> updateItem(String uid, CollectionItem item) =>
      _itemsRef(uid).doc(item.id).update(CollectionItem.toFirestore(item));

  Future<void> deleteItem(String uid, String itemId) =>
      _itemsRef(uid).doc(itemId).delete();

  // ------------------------------------------------------------------
  // Binders
  // ------------------------------------------------------------------

  Stream<List<Binder>> watchBinders(String uid) => _db
      .collection(_Col.binders)
      .where('owner_uid', isEqualTo: uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Binder.fromFirestore).toList());

  Future<String> addBinder(Binder binder) async {
    final ref = await _db
        .collection(_Col.binders)
        .add(Binder.toFirestore(binder));
    return ref.id;
  }

  Future<void> updateBinder(Binder binder) => _db
      .collection(_Col.binders)
      .doc(binder.id)
      .update(Binder.toFirestore(binder));

  Future<void> deleteBinder(String binderId) =>
      _db.collection(_Col.binders).doc(binderId).delete();

  // ------------------------------------------------------------------
  // Submission estimates
  // ------------------------------------------------------------------

  Future<String> saveEstimate(SubmissionEstimate estimate) async {
    final ref = await _db
        .collection(_Col.submissionEstimates)
        .add(SubmissionEstimate.toFirestore(estimate));
    return ref.id;
  }

  Future<void> updateEstimateOutputs(
    String estimateId,
    EstimateOutputs outputs,
  ) =>
      _db.collection(_Col.submissionEstimates).doc(estimateId).update({
        'outputs': outputs.toJson(),
      });

  Stream<List<SubmissionEstimate>> watchRecentEstimates(
    String uid, {
    int limit = 10,
  }) =>
      _db
          .collection(_Col.submissionEstimates)
          .where('user_uid', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) => s.docs.map(SubmissionEstimate.fromFirestore).toList());

  // ------------------------------------------------------------------
  // Static reference helpers (used by providers without a service instance)
  // ------------------------------------------------------------------

  static DocumentReference cardRef(String cardId) =>
      FirebaseFirestore.instance.collection('cards').doc(cardId);

  Future<double> getAllTimeHigh(String uid) async {
    final doc = await _db.collection('users').doc(uid).collection('stats').doc('portfolio').get();
    if (!doc.exists) return 0;
    return (doc.data()?['all_time_high'] as num?)?.toDouble() ?? 0;
  }

  Future<void> updateAllTimeHigh(String uid, double value) =>
      _db.collection('users').doc(uid).collection('stats').doc('portfolio').set(
        {'all_time_high': value},
        SetOptions(merge: true),
      );

  Future<List<CardDocument>> getSetCards(String setId) async {
    final snap = await _db
        .collection('cards')
        .where('meta.set_id', isEqualTo: setId)
        .get();
    return snap.docs.map(CardDocument.fromFirestore).toList();
  }

  // ------------------------------------------------------------------
  // Portfolio summary (aggregated — used by Dashboard)
  // ------------------------------------------------------------------

  /// Returns total cost basis across the user's collection.
  /// For market value totals, computed client-side by joining with live prices.
  Future<Map<String, dynamic>> getPortfolioSummary(String uid) async {
    final items = await getCollection(uid);
    final totalCostBasis = items.fold<double>(
      0.0,
      (sum, i) => sum + i.acquisition.costBasis,
    );
    return {
      'total_items': items.length,
      'raw_count': items.where((i) => i.condition.type == ConditionType.raw).length,
      'slab_count': items.where((i) => i.condition.type == ConditionType.slab).length,
      'total_cost_basis': totalCostBasis,
    };
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
  final db = FirebaseFirestore.instance;
  // Enable offline persistence (event-ready / offline-first)
  db.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  return db;
}

@Riverpod(keepAlive: true)
FirestoreService firestoreService(Ref ref) =>
    FirestoreService(ref.watch(firebaseFirestoreProvider));
