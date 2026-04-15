// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'binder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Binder {

 String get id;@JsonKey(name: 'owner_uid') String get ownerUid; String get name; BinderType get type;/// Total card slots (for occupancy tracking)
 int? get capacity;@JsonKey(name: 'cover_image_url') String? get coverImageUrl;@JsonKey(name: 'created_at')@TimestampConverter() DateTime? get createdAt;
/// Create a copy of Binder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BinderCopyWith<Binder> get copyWith => _$BinderCopyWithImpl<Binder>(this as Binder, _$identity);

  /// Serializes this Binder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Binder&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerUid,name,type,capacity,coverImageUrl,createdAt);

@override
String toString() {
  return 'Binder(id: $id, ownerUid: $ownerUid, name: $name, type: $type, capacity: $capacity, coverImageUrl: $coverImageUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BinderCopyWith<$Res>  {
  factory $BinderCopyWith(Binder value, $Res Function(Binder) _then) = _$BinderCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'owner_uid') String ownerUid, String name, BinderType type, int? capacity,@JsonKey(name: 'cover_image_url') String? coverImageUrl,@JsonKey(name: 'created_at')@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$BinderCopyWithImpl<$Res>
    implements $BinderCopyWith<$Res> {
  _$BinderCopyWithImpl(this._self, this._then);

  final Binder _self;
  final $Res Function(Binder) _then;

/// Create a copy of Binder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerUid = null,Object? name = null,Object? type = null,Object? capacity = freezed,Object? coverImageUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BinderType,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Binder].
extension BinderPatterns on Binder {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Binder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Binder() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Binder value)  $default,){
final _that = this;
switch (_that) {
case _Binder():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Binder value)?  $default,){
final _that = this;
switch (_that) {
case _Binder() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_uid')  String ownerUid,  String name,  BinderType type,  int? capacity, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'created_at')@TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Binder() when $default != null:
return $default(_that.id,_that.ownerUid,_that.name,_that.type,_that.capacity,_that.coverImageUrl,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_uid')  String ownerUid,  String name,  BinderType type,  int? capacity, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'created_at')@TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Binder():
return $default(_that.id,_that.ownerUid,_that.name,_that.type,_that.capacity,_that.coverImageUrl,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'owner_uid')  String ownerUid,  String name,  BinderType type,  int? capacity, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'created_at')@TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Binder() when $default != null:
return $default(_that.id,_that.ownerUid,_that.name,_that.type,_that.capacity,_that.coverImageUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Binder implements Binder {
  const _Binder({required this.id, @JsonKey(name: 'owner_uid') required this.ownerUid, required this.name, required this.type, this.capacity, @JsonKey(name: 'cover_image_url') this.coverImageUrl, @JsonKey(name: 'created_at')@TimestampConverter() this.createdAt});
  factory _Binder.fromJson(Map<String, dynamic> json) => _$BinderFromJson(json);

@override final  String id;
@override@JsonKey(name: 'owner_uid') final  String ownerUid;
@override final  String name;
@override final  BinderType type;
/// Total card slots (for occupancy tracking)
@override final  int? capacity;
@override@JsonKey(name: 'cover_image_url') final  String? coverImageUrl;
@override@JsonKey(name: 'created_at')@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of Binder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BinderCopyWith<_Binder> get copyWith => __$BinderCopyWithImpl<_Binder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BinderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Binder&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerUid,name,type,capacity,coverImageUrl,createdAt);

@override
String toString() {
  return 'Binder(id: $id, ownerUid: $ownerUid, name: $name, type: $type, capacity: $capacity, coverImageUrl: $coverImageUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BinderCopyWith<$Res> implements $BinderCopyWith<$Res> {
  factory _$BinderCopyWith(_Binder value, $Res Function(_Binder) _then) = __$BinderCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'owner_uid') String ownerUid, String name, BinderType type, int? capacity,@JsonKey(name: 'cover_image_url') String? coverImageUrl,@JsonKey(name: 'created_at')@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$BinderCopyWithImpl<$Res>
    implements _$BinderCopyWith<$Res> {
  __$BinderCopyWithImpl(this._self, this._then);

  final _Binder _self;
  final $Res Function(_Binder) _then;

/// Create a copy of Binder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerUid = null,Object? name = null,Object? type = null,Object? capacity = freezed,Object? coverImageUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_Binder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BinderType,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
