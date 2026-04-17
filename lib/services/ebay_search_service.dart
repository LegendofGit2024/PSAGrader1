import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/card.dart';

/// Maximum eBay searches a single user may trigger per [_windowSeconds].
const _maxSearches     = 5;
const _windowSeconds   = 60;

// ---------------------------------------------------------------------------
// EbaySearchService
// ---------------------------------------------------------------------------
//
// Responsibilities:
//   1. Rate-limit guard — prevents a single user from spamming the Cloud
//      Function (and burning eBay API quota). Tracks search timestamps in
//      memory with a 60-second sliding window.
//
//   2. Search request writer — creates search_requests/{uid}_{cardId} in
//      Firestore, which triggers the onSearchRequest Cloud Function.
//
//   3. Request stream — exposes a Stream<bool> for whether a request is
//      currently in-flight.  The Cloud Function deletes the document when
//      it finishes, so exists==false means "done".
//
// Usage:
//   final svc = EbaySearchService();
//   if (!svc.canSearch) { /* show cooldown message */ return; }
//   await svc.triggerSearch(card: myCard);
//   // Then StreamBuilder on svc.searchActiveStream(card.id)
// ---------------------------------------------------------------------------

class EbaySearchService {
  EbaySearchService({
    FirebaseFirestore? firestore,
    FirebaseAuth?      auth,
  })  : _db   = firestore ?? FirebaseFirestore.instance,
        _auth = auth      ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth      _auth;

  /// Sliding-window timestamps of this user's recent searches.
  final List<DateTime> _timestamps = [];

  // ── Rate limiter ──────────────────────────────────────────────────────────

  /// Purge entries older than the window.
  void _purge() {
    final cutoff = DateTime.now().subtract(
      const Duration(seconds: _windowSeconds),
    );
    _timestamps.removeWhere((t) => t.isBefore(cutoff));
  }

  /// True if the user has not exhausted their per-minute quota.
  bool get canSearch {
    _purge();
    return _timestamps.length < _maxSearches;
  }

  /// How many searches the user can still trigger in the current window.
  int get remainingSearches {
    _purge();
    return (_maxSearches - _timestamps.length).clamp(0, _maxSearches);
  }

  /// Seconds until the oldest search leaves the window (0 when canSearch).
  int get secondsUntilReset {
    _purge();
    if (_timestamps.isEmpty) return 0;
    final oldest = _timestamps.first;
    final elapsed = DateTime.now().difference(oldest).inSeconds;
    return (_windowSeconds - elapsed).clamp(0, _windowSeconds);
  }

  // ── Firestore helpers ─────────────────────────────────────────────────────

  /// The document ID used for a given card's search request.
  /// Format: "{uid}_{cardId}" — deterministic so we can stream it by ID.
  String requestDocId(String cardId) {
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    return '${uid}_$cardId';
  }

  /// Reference to this user's in-flight request for [cardId], if any.
  DocumentReference<Map<String, dynamic>> _requestRef(String cardId) =>
      _db.collection('search_requests').doc(requestDocId(cardId));

  // ── Trigger ───────────────────────────────────────────────────────────────

  /// Write a search_request document to Firestore.
  ///
  /// The onSearchRequest Cloud Function picks this up, runs the eBay fetch,
  /// writes pricing to cards/{cardId}, and deletes this document when done.
  ///
  /// Throws [SearchRateLimitException] if the user is over their quota.
  /// Throws [SearchUnauthenticatedException] if no user is signed in.
  Future<void> triggerSearch(CardDocument card) async {
    final user = _auth.currentUser;
    if (user == null) throw const SearchUnauthenticatedException();
    if (!canSearch)   throw SearchRateLimitException(secondsUntilReset);

    _timestamps.add(DateTime.now());

    await _requestRef(card.id).set({
      'card_id':    card.id,
      'name':       card.meta.name,
      'set_id':     card.meta.setId,
      'number':     card.meta.setNumber,
      'user_id':    user.uid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // ── Stream ────────────────────────────────────────────────────────────────

  /// Emits `true` while the Cloud Function is running (request doc exists),
  /// and `false` once it has been deleted (job finished or was never started).
  Stream<bool> searchActiveStream(String cardId) => _requestRef(cardId)
      .snapshots()
      .map((snap) => snap.exists);
}

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

class SearchRateLimitException implements Exception {
  const SearchRateLimitException(this.secondsUntilReset);
  final int secondsUntilReset;

  @override
  String toString() =>
      'Rate limit reached. Try again in $secondsUntilReset seconds '
      '(max $_maxSearches searches per $_windowSeconds s).';
}

class SearchUnauthenticatedException implements Exception {
  const SearchUnauthenticatedException();

  @override
  String toString() => 'User must be signed in to trigger an eBay search.';
}
