import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'card.dart'
    show DocumentReferenceConverter, NullableDocumentReferenceConverter, TimestampConverter;

part 'collection_item.freezed.dart';
part 'collection_item.g.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum ConditionType { raw, slab }

enum RawCondition { nm, lp, mp, hp, dmg }

enum Grader { psa, bgs, cgc, tag, ace, ark, egc }

// ---------------------------------------------------------------------------
// Slab sub-grades  (BGS / CGC only)
// ---------------------------------------------------------------------------

@freezed
abstract class Subgrades with _$Subgrades {
  const factory Subgrades({
    required double centering,
    required double corners,
    required double edges,
    required double surface,
  }) = _Subgrades;

  factory Subgrades.fromJson(Map<String, dynamic> json) =>
      _$SubgradesFromJson(json);
}

// ---------------------------------------------------------------------------
// Slab condition
// ---------------------------------------------------------------------------

@freezed
abstract class SlabCondition with _$SlabCondition {
  const factory SlabCondition({
    required Grader grader,
    @JsonKey(name: 'cert_number') required String certNumber,
    required double grade,

    /// ACE "Color Match Labels" — used as a value variable in pricing logic
    @JsonKey(name: 'label_color') String? labelColor,

    /// Only populated for BGS / CGC
    Subgrades? subgrades,
  }) = _SlabCondition;

  factory SlabCondition.fromJson(Map<String, dynamic> json) =>
      _$SlabConditionFromJson(json);
}

// ---------------------------------------------------------------------------
// Condition  (discriminated union via conditionType)
// ---------------------------------------------------------------------------

@freezed
abstract class ItemCondition with _$ItemCondition {
  const factory ItemCondition({
    required ConditionType type,

    /// Populated when type == ConditionType.raw
    @JsonKey(name: 'raw_condition') RawCondition? rawCondition,

    /// Populated when type == ConditionType.slab
    SlabCondition? slab,
  }) = _ItemCondition;

  factory ItemCondition.fromJson(Map<String, dynamic> json) =>
      _$ItemConditionFromJson(json);
}

// ---------------------------------------------------------------------------
// Acquisition details
// ---------------------------------------------------------------------------

@freezed
abstract class Acquisition with _$Acquisition {
  const factory Acquisition({
    @JsonKey(name: 'cost_basis') required double costBasis,
    @JsonKey(name: 'acquired_date') @TimestampConverter() required DateTime acquiredDate,
    String? source,
  }) = _Acquisition;

  factory Acquisition.fromJson(Map<String, dynamic> json) =>
      _$AcquisitionFromJson(json);
}

// ---------------------------------------------------------------------------
// Physical location
// ---------------------------------------------------------------------------

@freezed
abstract class ItemLocation with _$ItemLocation {
  const factory ItemLocation({
    /// Human-readable: "Binder A, Page 1, Slot 3"
    @JsonKey(name: 'location_tag') required String locationTag,

    /// Reference to /binders/{binderId}
    @JsonKey(name: 'binder_id') @NullableDocumentReferenceConverter() DocumentReference? binderId,

    @JsonKey(name: 'slot_index') int? slotIndex,
  }) = _ItemLocation;

  factory ItemLocation.fromJson(Map<String, dynamic> json) =>
      _$ItemLocationFromJson(json);

  static Map<String, dynamic> toFirestore(ItemLocation loc) => {
        'location_tag': loc.locationTag,
        if (loc.binderId != null) 'binder_id': loc.binderId,
        if (loc.slotIndex != null) 'slot_index': loc.slotIndex,
      };
}

// ---------------------------------------------------------------------------
// Item flags
// ---------------------------------------------------------------------------

@freezed
abstract class ItemFlags with _$ItemFlags {
  const factory ItemFlags({
    @JsonKey(name: 'for_sale') @Default(false) bool forSale,
    @Default(false) bool wishlist,
    @JsonKey(name: 'submission_pending') @Default(false) bool submissionPending,
  }) = _ItemFlags;

  factory ItemFlags.fromJson(Map<String, dynamic> json) =>
      _$ItemFlagsFromJson(json);
}

// ---------------------------------------------------------------------------
// Root CollectionItem document
// (/user_collection/{userId}/items/{itemId})
// ---------------------------------------------------------------------------

@freezed
abstract class CollectionItem with _$CollectionItem {
  const factory CollectionItem({
    required String id,

    /// Reference to /cards/{cardId}
    @JsonKey(name: 'card_ref') @DocumentReferenceConverter() required DocumentReference cardRef,

    required Acquisition acquisition,
    required ItemCondition condition,
    required ItemLocation location,
    required ItemFlags flags,
  }) = _CollectionItem;

  factory CollectionItem.fromJson(Map<String, dynamic> json) =>
      _$CollectionItemFromJson(json);

  factory CollectionItem.fromFirestore(DocumentSnapshot doc) {
    final raw = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);

    // ── Acquisition ──────────────────────────────────────────────────────────
    // Normalise acquired_date: old documents stored a native Firestore Timestamp;
    // new documents store an ISO-8601 string. The generated fromJson always calls
    // DateTime.parse(... as String), so convert any Timestamp first.
    final acq = raw['acquisition'];
    if (acq is Map) {
      final acqMap = Map<String, dynamic>.from(acq);
      final d = acqMap['acquired_date'];
      if (d is Timestamp) {
        acqMap['acquired_date'] = d.toDate().toIso8601String();
      }
      acqMap['acquired_date'] ??= DateTime.now().toIso8601String();
      acqMap['cost_basis'] ??= 0.0;
      raw['acquisition'] = acqMap;
    } else {
      raw['acquisition'] = <String, dynamic>{
        'cost_basis': 0.0,
        'acquired_date': DateTime.now().toIso8601String(),
      };
    }

    // ── Location ─────────────────────────────────────────────────────────────
    // location_tag is required String — default if missing to avoid cast error.
    final loc = raw['location'];
    if (loc is Map) {
      final locMap = Map<String, dynamic>.from(loc);
      locMap['location_tag'] ??= 'Unorganized';
      raw['location'] = locMap;
    } else {
      raw['location'] = <String, dynamic>{'location_tag': 'Unorganized'};
    }

    // ── Condition ─────────────────────────────────────────────────────────────
    // cert_number is required String inside SlabCondition.
    final cond = raw['condition'];
    if (cond is Map) {
      final condMap = Map<String, dynamic>.from(cond);
      condMap['type'] ??= 'raw';
      final slab = condMap['slab'];
      if (slab is Map) {
        final slabMap = Map<String, dynamic>.from(slab);
        slabMap['cert_number'] ??= '';
        slabMap['grader']      ??= 'psa';
        slabMap['grade']       ??= 10.0;
        condMap['slab'] = slabMap;
      }
      raw['condition'] = condMap;
    } else {
      raw['condition'] = <String, dynamic>{'type': 'raw'};
    }

    // ── Flags ─────────────────────────────────────────────────────────────────
    if (raw['flags'] == null) {
      raw['flags'] = <String, dynamic>{
        'for_sale': false,
        'wishlist': false,
        'submission_pending': false,
      };
    }

    // Inject the doc ID — toFirestore strips it so it is never stored.
    raw['id'] = doc.id;
    return CollectionItem.fromJson(raw);
  }

  /// Builds a plain Map with only Firestore-native types (String, num, bool,
  /// Timestamp, DocumentReference).  The freezed toJson() embeds nested Dart
  /// objects on Flutter web which the Firestore JS SDK rejects as
  /// "unsupported field value".
  static Map<String, dynamic> toFirestore(CollectionItem item) {
    final slab = item.condition.slab;
    final subgrades = slab?.subgrades;

    return {
      // DocumentReference is a native Firestore type — fine as-is.
      'card_ref': item.cardRef,
      'acquisition': <String, dynamic>{
        'cost_basis': item.acquisition.costBasis,
        // Store as ISO-8601 string — the generated fromJson uses
        // DateTime.parse(... as String), NOT the TimestampConverter.
        'acquired_date': item.acquisition.acquiredDate.toIso8601String(),
        if (item.acquisition.source != null) 'source': item.acquisition.source,
      },
      'condition': <String, dynamic>{
        'type': item.condition.type.name,
        if (item.condition.rawCondition != null)
          'raw_condition': item.condition.rawCondition!.name,
        if (slab != null)
          'slab': <String, dynamic>{
            'grader': slab.grader.name,
            'cert_number': slab.certNumber,
            'grade': slab.grade,
            if (slab.labelColor != null) 'label_color': slab.labelColor,
            if (subgrades != null)
              'subgrades': <String, dynamic>{
                'centering': subgrades.centering,
                'corners': subgrades.corners,
                'edges': subgrades.edges,
                'surface': subgrades.surface,
              },
          },
      },
      'location': ItemLocation.toFirestore(item.location),
      'flags': <String, dynamic>{
        'for_sale': item.flags.forSale,
        'wishlist': item.flags.wishlist,
        'submission_pending': item.flags.submissionPending,
      },
    };
  }
}
