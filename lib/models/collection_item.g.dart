// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Subgrades _$SubgradesFromJson(Map<String, dynamic> json) => _Subgrades(
  centering: (json['centering'] as num).toDouble(),
  corners: (json['corners'] as num).toDouble(),
  edges: (json['edges'] as num).toDouble(),
  surface: (json['surface'] as num).toDouble(),
);

Map<String, dynamic> _$SubgradesToJson(_Subgrades instance) =>
    <String, dynamic>{
      'centering': instance.centering,
      'corners': instance.corners,
      'edges': instance.edges,
      'surface': instance.surface,
    };

_SlabCondition _$SlabConditionFromJson(Map<String, dynamic> json) =>
    _SlabCondition(
      grader: $enumDecode(_$GraderEnumMap, json['grader']),
      certNumber: json['cert_number'] as String,
      grade: (json['grade'] as num).toDouble(),
      labelColor: json['label_color'] as String?,
      subgrades: json['subgrades'] == null
          ? null
          : Subgrades.fromJson(json['subgrades'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SlabConditionToJson(_SlabCondition instance) =>
    <String, dynamic>{
      'grader': _$GraderEnumMap[instance.grader]!,
      'cert_number': instance.certNumber,
      'grade': instance.grade,
      'label_color': instance.labelColor,
      'subgrades': instance.subgrades,
    };

const _$GraderEnumMap = {
  Grader.psa: 'psa',
  Grader.bgs: 'bgs',
  Grader.cgc: 'cgc',
  Grader.tag: 'tag',
  Grader.ace: 'ace',
  Grader.ark: 'ark',
  Grader.egc: 'egc',
};

_ItemCondition _$ItemConditionFromJson(Map<String, dynamic> json) =>
    _ItemCondition(
      type: $enumDecode(_$ConditionTypeEnumMap, json['type']),
      rawCondition: $enumDecodeNullable(
        _$RawConditionEnumMap,
        json['raw_condition'],
      ),
      slab: json['slab'] == null
          ? null
          : SlabCondition.fromJson(json['slab'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ItemConditionToJson(_ItemCondition instance) =>
    <String, dynamic>{
      'type': _$ConditionTypeEnumMap[instance.type]!,
      'raw_condition': _$RawConditionEnumMap[instance.rawCondition],
      'slab': instance.slab,
    };

const _$ConditionTypeEnumMap = {
  ConditionType.raw: 'raw',
  ConditionType.slab: 'slab',
};

const _$RawConditionEnumMap = {
  RawCondition.nm: 'nm',
  RawCondition.lp: 'lp',
  RawCondition.mp: 'mp',
  RawCondition.hp: 'hp',
  RawCondition.dmg: 'dmg',
};

_Acquisition _$AcquisitionFromJson(Map<String, dynamic> json) => _Acquisition(
  costBasis: (json['cost_basis'] as num).toDouble(),
  acquiredDate: DateTime.parse(json['acquired_date'] as String),
  source: json['source'] as String?,
);

Map<String, dynamic> _$AcquisitionToJson(_Acquisition instance) =>
    <String, dynamic>{
      'cost_basis': instance.costBasis,
      'acquired_date': instance.acquiredDate.toIso8601String(),
      'source': instance.source,
    };

_ItemLocation _$ItemLocationFromJson(Map<String, dynamic> json) =>
    _ItemLocation(
      locationTag: json['location_tag'] as String,
      binderId: const NullableDocumentReferenceConverter().fromJson(
        json['binder_id'],
      ),
      slotIndex: (json['slot_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ItemLocationToJson(_ItemLocation instance) =>
    <String, dynamic>{
      'location_tag': instance.locationTag,
      'binder_id': const NullableDocumentReferenceConverter().toJson(
        instance.binderId,
      ),
      'slot_index': instance.slotIndex,
    };

_ItemFlags _$ItemFlagsFromJson(Map<String, dynamic> json) => _ItemFlags(
  forSale: json['for_sale'] as bool? ?? false,
  wishlist: json['wishlist'] as bool? ?? false,
  submissionPending: json['submission_pending'] as bool? ?? false,
);

Map<String, dynamic> _$ItemFlagsToJson(_ItemFlags instance) =>
    <String, dynamic>{
      'for_sale': instance.forSale,
      'wishlist': instance.wishlist,
      'submission_pending': instance.submissionPending,
    };

_CollectionItem _$CollectionItemFromJson(Map<String, dynamic> json) =>
    _CollectionItem(
      id: json['id'] as String,
      cardRef: const DocumentReferenceConverter().fromJson(
        json['card_ref'] as Object,
      ),
      acquisition: Acquisition.fromJson(
        json['acquisition'] as Map<String, dynamic>,
      ),
      condition: ItemCondition.fromJson(
        json['condition'] as Map<String, dynamic>,
      ),
      location: ItemLocation.fromJson(json['location'] as Map<String, dynamic>),
      flags: ItemFlags.fromJson(json['flags'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CollectionItemToJson(_CollectionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'card_ref': const DocumentReferenceConverter().toJson(instance.cardRef),
      'acquisition': instance.acquisition,
      'condition': instance.condition,
      'location': instance.location,
      'flags': instance.flags,
    };
