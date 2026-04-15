// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Binder _$BinderFromJson(Map<String, dynamic> json) => _Binder(
  id: json['id'] as String,
  ownerUid: json['owner_uid'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$BinderTypeEnumMap, json['type']),
  capacity: (json['capacity'] as num?)?.toInt(),
  coverImageUrl: json['cover_image_url'] as String?,
  createdAt: const TimestampConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$BinderToJson(_Binder instance) => <String, dynamic>{
  'id': instance.id,
  'owner_uid': instance.ownerUid,
  'name': instance.name,
  'type': _$BinderTypeEnumMap[instance.type]!,
  'capacity': instance.capacity,
  'cover_image_url': instance.coverImageUrl,
  'created_at': const TimestampConverter().toJson(instance.createdAt),
};

const _$BinderTypeEnumMap = {
  BinderType.binder: 'binder',
  BinderType.box: 'box',
  BinderType.case_: 'case_',
  BinderType.display: 'display',
};
