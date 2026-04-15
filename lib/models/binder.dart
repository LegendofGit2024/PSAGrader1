import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'card.dart' show TimestampConverter;

part 'binder.freezed.dart';
part 'binder.g.dart';

enum BinderType { binder, box, case_, display }

@freezed
abstract class Binder with _$Binder {
  const factory Binder({
    required String id,
    @JsonKey(name: 'owner_uid') required String ownerUid,
    required String name,
    required BinderType type,

    /// Total card slots (for occupancy tracking)
    int? capacity,

    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'created_at') @TimestampConverter() DateTime? createdAt,
  }) = _Binder;

  factory Binder.fromJson(Map<String, dynamic> json) =>
      _$BinderFromJson(json);

  factory Binder.fromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
    data['id'] = doc.id;
    return Binder.fromJson(data);
  }

  static Map<String, dynamic> toFirestore(Binder binder) =>
      binder.toJson()..remove('id');
}
