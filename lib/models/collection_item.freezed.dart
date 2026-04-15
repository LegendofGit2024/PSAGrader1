// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Subgrades {

 double get centering; double get corners; double get edges; double get surface;
/// Create a copy of Subgrades
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubgradesCopyWith<Subgrades> get copyWith => _$SubgradesCopyWithImpl<Subgrades>(this as Subgrades, _$identity);

  /// Serializes this Subgrades to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Subgrades&&(identical(other.centering, centering) || other.centering == centering)&&(identical(other.corners, corners) || other.corners == corners)&&(identical(other.edges, edges) || other.edges == edges)&&(identical(other.surface, surface) || other.surface == surface));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,centering,corners,edges,surface);

@override
String toString() {
  return 'Subgrades(centering: $centering, corners: $corners, edges: $edges, surface: $surface)';
}


}

/// @nodoc
abstract mixin class $SubgradesCopyWith<$Res>  {
  factory $SubgradesCopyWith(Subgrades value, $Res Function(Subgrades) _then) = _$SubgradesCopyWithImpl;
@useResult
$Res call({
 double centering, double corners, double edges, double surface
});




}
/// @nodoc
class _$SubgradesCopyWithImpl<$Res>
    implements $SubgradesCopyWith<$Res> {
  _$SubgradesCopyWithImpl(this._self, this._then);

  final Subgrades _self;
  final $Res Function(Subgrades) _then;

/// Create a copy of Subgrades
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? centering = null,Object? corners = null,Object? edges = null,Object? surface = null,}) {
  return _then(_self.copyWith(
centering: null == centering ? _self.centering : centering // ignore: cast_nullable_to_non_nullable
as double,corners: null == corners ? _self.corners : corners // ignore: cast_nullable_to_non_nullable
as double,edges: null == edges ? _self.edges : edges // ignore: cast_nullable_to_non_nullable
as double,surface: null == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Subgrades].
extension SubgradesPatterns on Subgrades {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Subgrades value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Subgrades() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Subgrades value)  $default,){
final _that = this;
switch (_that) {
case _Subgrades():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Subgrades value)?  $default,){
final _that = this;
switch (_that) {
case _Subgrades() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double centering,  double corners,  double edges,  double surface)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Subgrades() when $default != null:
return $default(_that.centering,_that.corners,_that.edges,_that.surface);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double centering,  double corners,  double edges,  double surface)  $default,) {final _that = this;
switch (_that) {
case _Subgrades():
return $default(_that.centering,_that.corners,_that.edges,_that.surface);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double centering,  double corners,  double edges,  double surface)?  $default,) {final _that = this;
switch (_that) {
case _Subgrades() when $default != null:
return $default(_that.centering,_that.corners,_that.edges,_that.surface);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Subgrades implements Subgrades {
  const _Subgrades({required this.centering, required this.corners, required this.edges, required this.surface});
  factory _Subgrades.fromJson(Map<String, dynamic> json) => _$SubgradesFromJson(json);

@override final  double centering;
@override final  double corners;
@override final  double edges;
@override final  double surface;

/// Create a copy of Subgrades
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubgradesCopyWith<_Subgrades> get copyWith => __$SubgradesCopyWithImpl<_Subgrades>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubgradesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Subgrades&&(identical(other.centering, centering) || other.centering == centering)&&(identical(other.corners, corners) || other.corners == corners)&&(identical(other.edges, edges) || other.edges == edges)&&(identical(other.surface, surface) || other.surface == surface));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,centering,corners,edges,surface);

@override
String toString() {
  return 'Subgrades(centering: $centering, corners: $corners, edges: $edges, surface: $surface)';
}


}

/// @nodoc
abstract mixin class _$SubgradesCopyWith<$Res> implements $SubgradesCopyWith<$Res> {
  factory _$SubgradesCopyWith(_Subgrades value, $Res Function(_Subgrades) _then) = __$SubgradesCopyWithImpl;
@override @useResult
$Res call({
 double centering, double corners, double edges, double surface
});




}
/// @nodoc
class __$SubgradesCopyWithImpl<$Res>
    implements _$SubgradesCopyWith<$Res> {
  __$SubgradesCopyWithImpl(this._self, this._then);

  final _Subgrades _self;
  final $Res Function(_Subgrades) _then;

/// Create a copy of Subgrades
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? centering = null,Object? corners = null,Object? edges = null,Object? surface = null,}) {
  return _then(_Subgrades(
centering: null == centering ? _self.centering : centering // ignore: cast_nullable_to_non_nullable
as double,corners: null == corners ? _self.corners : corners // ignore: cast_nullable_to_non_nullable
as double,edges: null == edges ? _self.edges : edges // ignore: cast_nullable_to_non_nullable
as double,surface: null == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$SlabCondition {

 Grader get grader;@JsonKey(name: 'cert_number') String get certNumber; double get grade;/// ACE "Color Match Labels" — used as a value variable in pricing logic
@JsonKey(name: 'label_color') String? get labelColor;/// Only populated for BGS / CGC
 Subgrades? get subgrades;
/// Create a copy of SlabCondition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlabConditionCopyWith<SlabCondition> get copyWith => _$SlabConditionCopyWithImpl<SlabCondition>(this as SlabCondition, _$identity);

  /// Serializes this SlabCondition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlabCondition&&(identical(other.grader, grader) || other.grader == grader)&&(identical(other.certNumber, certNumber) || other.certNumber == certNumber)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.labelColor, labelColor) || other.labelColor == labelColor)&&(identical(other.subgrades, subgrades) || other.subgrades == subgrades));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,grader,certNumber,grade,labelColor,subgrades);

@override
String toString() {
  return 'SlabCondition(grader: $grader, certNumber: $certNumber, grade: $grade, labelColor: $labelColor, subgrades: $subgrades)';
}


}

/// @nodoc
abstract mixin class $SlabConditionCopyWith<$Res>  {
  factory $SlabConditionCopyWith(SlabCondition value, $Res Function(SlabCondition) _then) = _$SlabConditionCopyWithImpl;
@useResult
$Res call({
 Grader grader,@JsonKey(name: 'cert_number') String certNumber, double grade,@JsonKey(name: 'label_color') String? labelColor, Subgrades? subgrades
});


$SubgradesCopyWith<$Res>? get subgrades;

}
/// @nodoc
class _$SlabConditionCopyWithImpl<$Res>
    implements $SlabConditionCopyWith<$Res> {
  _$SlabConditionCopyWithImpl(this._self, this._then);

  final SlabCondition _self;
  final $Res Function(SlabCondition) _then;

/// Create a copy of SlabCondition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? grader = null,Object? certNumber = null,Object? grade = null,Object? labelColor = freezed,Object? subgrades = freezed,}) {
  return _then(_self.copyWith(
grader: null == grader ? _self.grader : grader // ignore: cast_nullable_to_non_nullable
as Grader,certNumber: null == certNumber ? _self.certNumber : certNumber // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as double,labelColor: freezed == labelColor ? _self.labelColor : labelColor // ignore: cast_nullable_to_non_nullable
as String?,subgrades: freezed == subgrades ? _self.subgrades : subgrades // ignore: cast_nullable_to_non_nullable
as Subgrades?,
  ));
}
/// Create a copy of SlabCondition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubgradesCopyWith<$Res>? get subgrades {
    if (_self.subgrades == null) {
    return null;
  }

  return $SubgradesCopyWith<$Res>(_self.subgrades!, (value) {
    return _then(_self.copyWith(subgrades: value));
  });
}
}


/// Adds pattern-matching-related methods to [SlabCondition].
extension SlabConditionPatterns on SlabCondition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlabCondition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlabCondition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlabCondition value)  $default,){
final _that = this;
switch (_that) {
case _SlabCondition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlabCondition value)?  $default,){
final _that = this;
switch (_that) {
case _SlabCondition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Grader grader, @JsonKey(name: 'cert_number')  String certNumber,  double grade, @JsonKey(name: 'label_color')  String? labelColor,  Subgrades? subgrades)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlabCondition() when $default != null:
return $default(_that.grader,_that.certNumber,_that.grade,_that.labelColor,_that.subgrades);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Grader grader, @JsonKey(name: 'cert_number')  String certNumber,  double grade, @JsonKey(name: 'label_color')  String? labelColor,  Subgrades? subgrades)  $default,) {final _that = this;
switch (_that) {
case _SlabCondition():
return $default(_that.grader,_that.certNumber,_that.grade,_that.labelColor,_that.subgrades);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Grader grader, @JsonKey(name: 'cert_number')  String certNumber,  double grade, @JsonKey(name: 'label_color')  String? labelColor,  Subgrades? subgrades)?  $default,) {final _that = this;
switch (_that) {
case _SlabCondition() when $default != null:
return $default(_that.grader,_that.certNumber,_that.grade,_that.labelColor,_that.subgrades);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SlabCondition implements SlabCondition {
  const _SlabCondition({required this.grader, @JsonKey(name: 'cert_number') required this.certNumber, required this.grade, @JsonKey(name: 'label_color') this.labelColor, this.subgrades});
  factory _SlabCondition.fromJson(Map<String, dynamic> json) => _$SlabConditionFromJson(json);

@override final  Grader grader;
@override@JsonKey(name: 'cert_number') final  String certNumber;
@override final  double grade;
/// ACE "Color Match Labels" — used as a value variable in pricing logic
@override@JsonKey(name: 'label_color') final  String? labelColor;
/// Only populated for BGS / CGC
@override final  Subgrades? subgrades;

/// Create a copy of SlabCondition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlabConditionCopyWith<_SlabCondition> get copyWith => __$SlabConditionCopyWithImpl<_SlabCondition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlabConditionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlabCondition&&(identical(other.grader, grader) || other.grader == grader)&&(identical(other.certNumber, certNumber) || other.certNumber == certNumber)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.labelColor, labelColor) || other.labelColor == labelColor)&&(identical(other.subgrades, subgrades) || other.subgrades == subgrades));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,grader,certNumber,grade,labelColor,subgrades);

@override
String toString() {
  return 'SlabCondition(grader: $grader, certNumber: $certNumber, grade: $grade, labelColor: $labelColor, subgrades: $subgrades)';
}


}

/// @nodoc
abstract mixin class _$SlabConditionCopyWith<$Res> implements $SlabConditionCopyWith<$Res> {
  factory _$SlabConditionCopyWith(_SlabCondition value, $Res Function(_SlabCondition) _then) = __$SlabConditionCopyWithImpl;
@override @useResult
$Res call({
 Grader grader,@JsonKey(name: 'cert_number') String certNumber, double grade,@JsonKey(name: 'label_color') String? labelColor, Subgrades? subgrades
});


@override $SubgradesCopyWith<$Res>? get subgrades;

}
/// @nodoc
class __$SlabConditionCopyWithImpl<$Res>
    implements _$SlabConditionCopyWith<$Res> {
  __$SlabConditionCopyWithImpl(this._self, this._then);

  final _SlabCondition _self;
  final $Res Function(_SlabCondition) _then;

/// Create a copy of SlabCondition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? grader = null,Object? certNumber = null,Object? grade = null,Object? labelColor = freezed,Object? subgrades = freezed,}) {
  return _then(_SlabCondition(
grader: null == grader ? _self.grader : grader // ignore: cast_nullable_to_non_nullable
as Grader,certNumber: null == certNumber ? _self.certNumber : certNumber // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as double,labelColor: freezed == labelColor ? _self.labelColor : labelColor // ignore: cast_nullable_to_non_nullable
as String?,subgrades: freezed == subgrades ? _self.subgrades : subgrades // ignore: cast_nullable_to_non_nullable
as Subgrades?,
  ));
}

/// Create a copy of SlabCondition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubgradesCopyWith<$Res>? get subgrades {
    if (_self.subgrades == null) {
    return null;
  }

  return $SubgradesCopyWith<$Res>(_self.subgrades!, (value) {
    return _then(_self.copyWith(subgrades: value));
  });
}
}


/// @nodoc
mixin _$ItemCondition {

 ConditionType get type;/// Populated when type == ConditionType.raw
@JsonKey(name: 'raw_condition') RawCondition? get rawCondition;/// Populated when type == ConditionType.slab
 SlabCondition? get slab;
/// Create a copy of ItemCondition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemConditionCopyWith<ItemCondition> get copyWith => _$ItemConditionCopyWithImpl<ItemCondition>(this as ItemCondition, _$identity);

  /// Serializes this ItemCondition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemCondition&&(identical(other.type, type) || other.type == type)&&(identical(other.rawCondition, rawCondition) || other.rawCondition == rawCondition)&&(identical(other.slab, slab) || other.slab == slab));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,rawCondition,slab);

@override
String toString() {
  return 'ItemCondition(type: $type, rawCondition: $rawCondition, slab: $slab)';
}


}

/// @nodoc
abstract mixin class $ItemConditionCopyWith<$Res>  {
  factory $ItemConditionCopyWith(ItemCondition value, $Res Function(ItemCondition) _then) = _$ItemConditionCopyWithImpl;
@useResult
$Res call({
 ConditionType type,@JsonKey(name: 'raw_condition') RawCondition? rawCondition, SlabCondition? slab
});


$SlabConditionCopyWith<$Res>? get slab;

}
/// @nodoc
class _$ItemConditionCopyWithImpl<$Res>
    implements $ItemConditionCopyWith<$Res> {
  _$ItemConditionCopyWithImpl(this._self, this._then);

  final ItemCondition _self;
  final $Res Function(ItemCondition) _then;

/// Create a copy of ItemCondition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? rawCondition = freezed,Object? slab = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConditionType,rawCondition: freezed == rawCondition ? _self.rawCondition : rawCondition // ignore: cast_nullable_to_non_nullable
as RawCondition?,slab: freezed == slab ? _self.slab : slab // ignore: cast_nullable_to_non_nullable
as SlabCondition?,
  ));
}
/// Create a copy of ItemCondition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlabConditionCopyWith<$Res>? get slab {
    if (_self.slab == null) {
    return null;
  }

  return $SlabConditionCopyWith<$Res>(_self.slab!, (value) {
    return _then(_self.copyWith(slab: value));
  });
}
}


/// Adds pattern-matching-related methods to [ItemCondition].
extension ItemConditionPatterns on ItemCondition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemCondition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemCondition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemCondition value)  $default,){
final _that = this;
switch (_that) {
case _ItemCondition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemCondition value)?  $default,){
final _that = this;
switch (_that) {
case _ItemCondition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConditionType type, @JsonKey(name: 'raw_condition')  RawCondition? rawCondition,  SlabCondition? slab)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemCondition() when $default != null:
return $default(_that.type,_that.rawCondition,_that.slab);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConditionType type, @JsonKey(name: 'raw_condition')  RawCondition? rawCondition,  SlabCondition? slab)  $default,) {final _that = this;
switch (_that) {
case _ItemCondition():
return $default(_that.type,_that.rawCondition,_that.slab);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConditionType type, @JsonKey(name: 'raw_condition')  RawCondition? rawCondition,  SlabCondition? slab)?  $default,) {final _that = this;
switch (_that) {
case _ItemCondition() when $default != null:
return $default(_that.type,_that.rawCondition,_that.slab);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemCondition implements ItemCondition {
  const _ItemCondition({required this.type, @JsonKey(name: 'raw_condition') this.rawCondition, this.slab});
  factory _ItemCondition.fromJson(Map<String, dynamic> json) => _$ItemConditionFromJson(json);

@override final  ConditionType type;
/// Populated when type == ConditionType.raw
@override@JsonKey(name: 'raw_condition') final  RawCondition? rawCondition;
/// Populated when type == ConditionType.slab
@override final  SlabCondition? slab;

/// Create a copy of ItemCondition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemConditionCopyWith<_ItemCondition> get copyWith => __$ItemConditionCopyWithImpl<_ItemCondition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemConditionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemCondition&&(identical(other.type, type) || other.type == type)&&(identical(other.rawCondition, rawCondition) || other.rawCondition == rawCondition)&&(identical(other.slab, slab) || other.slab == slab));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,rawCondition,slab);

@override
String toString() {
  return 'ItemCondition(type: $type, rawCondition: $rawCondition, slab: $slab)';
}


}

/// @nodoc
abstract mixin class _$ItemConditionCopyWith<$Res> implements $ItemConditionCopyWith<$Res> {
  factory _$ItemConditionCopyWith(_ItemCondition value, $Res Function(_ItemCondition) _then) = __$ItemConditionCopyWithImpl;
@override @useResult
$Res call({
 ConditionType type,@JsonKey(name: 'raw_condition') RawCondition? rawCondition, SlabCondition? slab
});


@override $SlabConditionCopyWith<$Res>? get slab;

}
/// @nodoc
class __$ItemConditionCopyWithImpl<$Res>
    implements _$ItemConditionCopyWith<$Res> {
  __$ItemConditionCopyWithImpl(this._self, this._then);

  final _ItemCondition _self;
  final $Res Function(_ItemCondition) _then;

/// Create a copy of ItemCondition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? rawCondition = freezed,Object? slab = freezed,}) {
  return _then(_ItemCondition(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConditionType,rawCondition: freezed == rawCondition ? _self.rawCondition : rawCondition // ignore: cast_nullable_to_non_nullable
as RawCondition?,slab: freezed == slab ? _self.slab : slab // ignore: cast_nullable_to_non_nullable
as SlabCondition?,
  ));
}

/// Create a copy of ItemCondition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlabConditionCopyWith<$Res>? get slab {
    if (_self.slab == null) {
    return null;
  }

  return $SlabConditionCopyWith<$Res>(_self.slab!, (value) {
    return _then(_self.copyWith(slab: value));
  });
}
}


/// @nodoc
mixin _$Acquisition {

@JsonKey(name: 'cost_basis') double get costBasis;@JsonKey(name: 'acquired_date')@TimestampConverter() DateTime get acquiredDate; String? get source;
/// Create a copy of Acquisition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcquisitionCopyWith<Acquisition> get copyWith => _$AcquisitionCopyWithImpl<Acquisition>(this as Acquisition, _$identity);

  /// Serializes this Acquisition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Acquisition&&(identical(other.costBasis, costBasis) || other.costBasis == costBasis)&&(identical(other.acquiredDate, acquiredDate) || other.acquiredDate == acquiredDate)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,costBasis,acquiredDate,source);

@override
String toString() {
  return 'Acquisition(costBasis: $costBasis, acquiredDate: $acquiredDate, source: $source)';
}


}

/// @nodoc
abstract mixin class $AcquisitionCopyWith<$Res>  {
  factory $AcquisitionCopyWith(Acquisition value, $Res Function(Acquisition) _then) = _$AcquisitionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'cost_basis') double costBasis,@JsonKey(name: 'acquired_date')@TimestampConverter() DateTime acquiredDate, String? source
});




}
/// @nodoc
class _$AcquisitionCopyWithImpl<$Res>
    implements $AcquisitionCopyWith<$Res> {
  _$AcquisitionCopyWithImpl(this._self, this._then);

  final Acquisition _self;
  final $Res Function(Acquisition) _then;

/// Create a copy of Acquisition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? costBasis = null,Object? acquiredDate = null,Object? source = freezed,}) {
  return _then(_self.copyWith(
costBasis: null == costBasis ? _self.costBasis : costBasis // ignore: cast_nullable_to_non_nullable
as double,acquiredDate: null == acquiredDate ? _self.acquiredDate : acquiredDate // ignore: cast_nullable_to_non_nullable
as DateTime,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Acquisition].
extension AcquisitionPatterns on Acquisition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Acquisition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Acquisition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Acquisition value)  $default,){
final _that = this;
switch (_that) {
case _Acquisition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Acquisition value)?  $default,){
final _that = this;
switch (_that) {
case _Acquisition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'cost_basis')  double costBasis, @JsonKey(name: 'acquired_date')@TimestampConverter()  DateTime acquiredDate,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Acquisition() when $default != null:
return $default(_that.costBasis,_that.acquiredDate,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'cost_basis')  double costBasis, @JsonKey(name: 'acquired_date')@TimestampConverter()  DateTime acquiredDate,  String? source)  $default,) {final _that = this;
switch (_that) {
case _Acquisition():
return $default(_that.costBasis,_that.acquiredDate,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'cost_basis')  double costBasis, @JsonKey(name: 'acquired_date')@TimestampConverter()  DateTime acquiredDate,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _Acquisition() when $default != null:
return $default(_that.costBasis,_that.acquiredDate,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Acquisition implements Acquisition {
  const _Acquisition({@JsonKey(name: 'cost_basis') required this.costBasis, @JsonKey(name: 'acquired_date')@TimestampConverter() required this.acquiredDate, this.source});
  factory _Acquisition.fromJson(Map<String, dynamic> json) => _$AcquisitionFromJson(json);

@override@JsonKey(name: 'cost_basis') final  double costBasis;
@override@JsonKey(name: 'acquired_date')@TimestampConverter() final  DateTime acquiredDate;
@override final  String? source;

/// Create a copy of Acquisition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcquisitionCopyWith<_Acquisition> get copyWith => __$AcquisitionCopyWithImpl<_Acquisition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcquisitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Acquisition&&(identical(other.costBasis, costBasis) || other.costBasis == costBasis)&&(identical(other.acquiredDate, acquiredDate) || other.acquiredDate == acquiredDate)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,costBasis,acquiredDate,source);

@override
String toString() {
  return 'Acquisition(costBasis: $costBasis, acquiredDate: $acquiredDate, source: $source)';
}


}

/// @nodoc
abstract mixin class _$AcquisitionCopyWith<$Res> implements $AcquisitionCopyWith<$Res> {
  factory _$AcquisitionCopyWith(_Acquisition value, $Res Function(_Acquisition) _then) = __$AcquisitionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'cost_basis') double costBasis,@JsonKey(name: 'acquired_date')@TimestampConverter() DateTime acquiredDate, String? source
});




}
/// @nodoc
class __$AcquisitionCopyWithImpl<$Res>
    implements _$AcquisitionCopyWith<$Res> {
  __$AcquisitionCopyWithImpl(this._self, this._then);

  final _Acquisition _self;
  final $Res Function(_Acquisition) _then;

/// Create a copy of Acquisition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? costBasis = null,Object? acquiredDate = null,Object? source = freezed,}) {
  return _then(_Acquisition(
costBasis: null == costBasis ? _self.costBasis : costBasis // ignore: cast_nullable_to_non_nullable
as double,acquiredDate: null == acquiredDate ? _self.acquiredDate : acquiredDate // ignore: cast_nullable_to_non_nullable
as DateTime,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ItemLocation {

/// Human-readable: "Binder A, Page 1, Slot 3"
@JsonKey(name: 'location_tag') String get locationTag;/// Reference to /binders/{binderId}
@JsonKey(name: 'binder_id')@NullableDocumentReferenceConverter() DocumentReference? get binderId;@JsonKey(name: 'slot_index') int? get slotIndex;
/// Create a copy of ItemLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemLocationCopyWith<ItemLocation> get copyWith => _$ItemLocationCopyWithImpl<ItemLocation>(this as ItemLocation, _$identity);

  /// Serializes this ItemLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemLocation&&(identical(other.locationTag, locationTag) || other.locationTag == locationTag)&&(identical(other.binderId, binderId) || other.binderId == binderId)&&(identical(other.slotIndex, slotIndex) || other.slotIndex == slotIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationTag,binderId,slotIndex);

@override
String toString() {
  return 'ItemLocation(locationTag: $locationTag, binderId: $binderId, slotIndex: $slotIndex)';
}


}

/// @nodoc
abstract mixin class $ItemLocationCopyWith<$Res>  {
  factory $ItemLocationCopyWith(ItemLocation value, $Res Function(ItemLocation) _then) = _$ItemLocationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'location_tag') String locationTag,@JsonKey(name: 'binder_id')@NullableDocumentReferenceConverter() DocumentReference? binderId,@JsonKey(name: 'slot_index') int? slotIndex
});




}
/// @nodoc
class _$ItemLocationCopyWithImpl<$Res>
    implements $ItemLocationCopyWith<$Res> {
  _$ItemLocationCopyWithImpl(this._self, this._then);

  final ItemLocation _self;
  final $Res Function(ItemLocation) _then;

/// Create a copy of ItemLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationTag = null,Object? binderId = freezed,Object? slotIndex = freezed,}) {
  return _then(_self.copyWith(
locationTag: null == locationTag ? _self.locationTag : locationTag // ignore: cast_nullable_to_non_nullable
as String,binderId: freezed == binderId ? _self.binderId : binderId // ignore: cast_nullable_to_non_nullable
as DocumentReference?,slotIndex: freezed == slotIndex ? _self.slotIndex : slotIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemLocation].
extension ItemLocationPatterns on ItemLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemLocation value)  $default,){
final _that = this;
switch (_that) {
case _ItemLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemLocation value)?  $default,){
final _that = this;
switch (_that) {
case _ItemLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'location_tag')  String locationTag, @JsonKey(name: 'binder_id')@NullableDocumentReferenceConverter()  DocumentReference? binderId, @JsonKey(name: 'slot_index')  int? slotIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemLocation() when $default != null:
return $default(_that.locationTag,_that.binderId,_that.slotIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'location_tag')  String locationTag, @JsonKey(name: 'binder_id')@NullableDocumentReferenceConverter()  DocumentReference? binderId, @JsonKey(name: 'slot_index')  int? slotIndex)  $default,) {final _that = this;
switch (_that) {
case _ItemLocation():
return $default(_that.locationTag,_that.binderId,_that.slotIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'location_tag')  String locationTag, @JsonKey(name: 'binder_id')@NullableDocumentReferenceConverter()  DocumentReference? binderId, @JsonKey(name: 'slot_index')  int? slotIndex)?  $default,) {final _that = this;
switch (_that) {
case _ItemLocation() when $default != null:
return $default(_that.locationTag,_that.binderId,_that.slotIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemLocation implements ItemLocation {
  const _ItemLocation({@JsonKey(name: 'location_tag') required this.locationTag, @JsonKey(name: 'binder_id')@NullableDocumentReferenceConverter() this.binderId, @JsonKey(name: 'slot_index') this.slotIndex});
  factory _ItemLocation.fromJson(Map<String, dynamic> json) => _$ItemLocationFromJson(json);

/// Human-readable: "Binder A, Page 1, Slot 3"
@override@JsonKey(name: 'location_tag') final  String locationTag;
/// Reference to /binders/{binderId}
@override@JsonKey(name: 'binder_id')@NullableDocumentReferenceConverter() final  DocumentReference? binderId;
@override@JsonKey(name: 'slot_index') final  int? slotIndex;

/// Create a copy of ItemLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemLocationCopyWith<_ItemLocation> get copyWith => __$ItemLocationCopyWithImpl<_ItemLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemLocation&&(identical(other.locationTag, locationTag) || other.locationTag == locationTag)&&(identical(other.binderId, binderId) || other.binderId == binderId)&&(identical(other.slotIndex, slotIndex) || other.slotIndex == slotIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationTag,binderId,slotIndex);

@override
String toString() {
  return 'ItemLocation(locationTag: $locationTag, binderId: $binderId, slotIndex: $slotIndex)';
}


}

/// @nodoc
abstract mixin class _$ItemLocationCopyWith<$Res> implements $ItemLocationCopyWith<$Res> {
  factory _$ItemLocationCopyWith(_ItemLocation value, $Res Function(_ItemLocation) _then) = __$ItemLocationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'location_tag') String locationTag,@JsonKey(name: 'binder_id')@NullableDocumentReferenceConverter() DocumentReference? binderId,@JsonKey(name: 'slot_index') int? slotIndex
});




}
/// @nodoc
class __$ItemLocationCopyWithImpl<$Res>
    implements _$ItemLocationCopyWith<$Res> {
  __$ItemLocationCopyWithImpl(this._self, this._then);

  final _ItemLocation _self;
  final $Res Function(_ItemLocation) _then;

/// Create a copy of ItemLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationTag = null,Object? binderId = freezed,Object? slotIndex = freezed,}) {
  return _then(_ItemLocation(
locationTag: null == locationTag ? _self.locationTag : locationTag // ignore: cast_nullable_to_non_nullable
as String,binderId: freezed == binderId ? _self.binderId : binderId // ignore: cast_nullable_to_non_nullable
as DocumentReference?,slotIndex: freezed == slotIndex ? _self.slotIndex : slotIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ItemFlags {

@JsonKey(name: 'for_sale') bool get forSale; bool get wishlist;@JsonKey(name: 'submission_pending') bool get submissionPending;
/// Create a copy of ItemFlags
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemFlagsCopyWith<ItemFlags> get copyWith => _$ItemFlagsCopyWithImpl<ItemFlags>(this as ItemFlags, _$identity);

  /// Serializes this ItemFlags to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemFlags&&(identical(other.forSale, forSale) || other.forSale == forSale)&&(identical(other.wishlist, wishlist) || other.wishlist == wishlist)&&(identical(other.submissionPending, submissionPending) || other.submissionPending == submissionPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,forSale,wishlist,submissionPending);

@override
String toString() {
  return 'ItemFlags(forSale: $forSale, wishlist: $wishlist, submissionPending: $submissionPending)';
}


}

/// @nodoc
abstract mixin class $ItemFlagsCopyWith<$Res>  {
  factory $ItemFlagsCopyWith(ItemFlags value, $Res Function(ItemFlags) _then) = _$ItemFlagsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'for_sale') bool forSale, bool wishlist,@JsonKey(name: 'submission_pending') bool submissionPending
});




}
/// @nodoc
class _$ItemFlagsCopyWithImpl<$Res>
    implements $ItemFlagsCopyWith<$Res> {
  _$ItemFlagsCopyWithImpl(this._self, this._then);

  final ItemFlags _self;
  final $Res Function(ItemFlags) _then;

/// Create a copy of ItemFlags
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? forSale = null,Object? wishlist = null,Object? submissionPending = null,}) {
  return _then(_self.copyWith(
forSale: null == forSale ? _self.forSale : forSale // ignore: cast_nullable_to_non_nullable
as bool,wishlist: null == wishlist ? _self.wishlist : wishlist // ignore: cast_nullable_to_non_nullable
as bool,submissionPending: null == submissionPending ? _self.submissionPending : submissionPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemFlags].
extension ItemFlagsPatterns on ItemFlags {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemFlags value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemFlags() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemFlags value)  $default,){
final _that = this;
switch (_that) {
case _ItemFlags():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemFlags value)?  $default,){
final _that = this;
switch (_that) {
case _ItemFlags() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'for_sale')  bool forSale,  bool wishlist, @JsonKey(name: 'submission_pending')  bool submissionPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemFlags() when $default != null:
return $default(_that.forSale,_that.wishlist,_that.submissionPending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'for_sale')  bool forSale,  bool wishlist, @JsonKey(name: 'submission_pending')  bool submissionPending)  $default,) {final _that = this;
switch (_that) {
case _ItemFlags():
return $default(_that.forSale,_that.wishlist,_that.submissionPending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'for_sale')  bool forSale,  bool wishlist, @JsonKey(name: 'submission_pending')  bool submissionPending)?  $default,) {final _that = this;
switch (_that) {
case _ItemFlags() when $default != null:
return $default(_that.forSale,_that.wishlist,_that.submissionPending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemFlags implements ItemFlags {
  const _ItemFlags({@JsonKey(name: 'for_sale') this.forSale = false, this.wishlist = false, @JsonKey(name: 'submission_pending') this.submissionPending = false});
  factory _ItemFlags.fromJson(Map<String, dynamic> json) => _$ItemFlagsFromJson(json);

@override@JsonKey(name: 'for_sale') final  bool forSale;
@override@JsonKey() final  bool wishlist;
@override@JsonKey(name: 'submission_pending') final  bool submissionPending;

/// Create a copy of ItemFlags
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemFlagsCopyWith<_ItemFlags> get copyWith => __$ItemFlagsCopyWithImpl<_ItemFlags>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemFlagsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemFlags&&(identical(other.forSale, forSale) || other.forSale == forSale)&&(identical(other.wishlist, wishlist) || other.wishlist == wishlist)&&(identical(other.submissionPending, submissionPending) || other.submissionPending == submissionPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,forSale,wishlist,submissionPending);

@override
String toString() {
  return 'ItemFlags(forSale: $forSale, wishlist: $wishlist, submissionPending: $submissionPending)';
}


}

/// @nodoc
abstract mixin class _$ItemFlagsCopyWith<$Res> implements $ItemFlagsCopyWith<$Res> {
  factory _$ItemFlagsCopyWith(_ItemFlags value, $Res Function(_ItemFlags) _then) = __$ItemFlagsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'for_sale') bool forSale, bool wishlist,@JsonKey(name: 'submission_pending') bool submissionPending
});




}
/// @nodoc
class __$ItemFlagsCopyWithImpl<$Res>
    implements _$ItemFlagsCopyWith<$Res> {
  __$ItemFlagsCopyWithImpl(this._self, this._then);

  final _ItemFlags _self;
  final $Res Function(_ItemFlags) _then;

/// Create a copy of ItemFlags
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? forSale = null,Object? wishlist = null,Object? submissionPending = null,}) {
  return _then(_ItemFlags(
forSale: null == forSale ? _self.forSale : forSale // ignore: cast_nullable_to_non_nullable
as bool,wishlist: null == wishlist ? _self.wishlist : wishlist // ignore: cast_nullable_to_non_nullable
as bool,submissionPending: null == submissionPending ? _self.submissionPending : submissionPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CollectionItem {

 String get id;/// Reference to /cards/{cardId}
@JsonKey(name: 'card_ref')@DocumentReferenceConverter() DocumentReference get cardRef; Acquisition get acquisition; ItemCondition get condition; ItemLocation get location; ItemFlags get flags;
/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionItemCopyWith<CollectionItem> get copyWith => _$CollectionItemCopyWithImpl<CollectionItem>(this as CollectionItem, _$identity);

  /// Serializes this CollectionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.cardRef, cardRef) || other.cardRef == cardRef)&&(identical(other.acquisition, acquisition) || other.acquisition == acquisition)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.location, location) || other.location == location)&&(identical(other.flags, flags) || other.flags == flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cardRef,acquisition,condition,location,flags);

@override
String toString() {
  return 'CollectionItem(id: $id, cardRef: $cardRef, acquisition: $acquisition, condition: $condition, location: $location, flags: $flags)';
}


}

/// @nodoc
abstract mixin class $CollectionItemCopyWith<$Res>  {
  factory $CollectionItemCopyWith(CollectionItem value, $Res Function(CollectionItem) _then) = _$CollectionItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'card_ref')@DocumentReferenceConverter() DocumentReference cardRef, Acquisition acquisition, ItemCondition condition, ItemLocation location, ItemFlags flags
});


$AcquisitionCopyWith<$Res> get acquisition;$ItemConditionCopyWith<$Res> get condition;$ItemLocationCopyWith<$Res> get location;$ItemFlagsCopyWith<$Res> get flags;

}
/// @nodoc
class _$CollectionItemCopyWithImpl<$Res>
    implements $CollectionItemCopyWith<$Res> {
  _$CollectionItemCopyWithImpl(this._self, this._then);

  final CollectionItem _self;
  final $Res Function(CollectionItem) _then;

/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cardRef = null,Object? acquisition = null,Object? condition = null,Object? location = null,Object? flags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cardRef: null == cardRef ? _self.cardRef : cardRef // ignore: cast_nullable_to_non_nullable
as DocumentReference,acquisition: null == acquisition ? _self.acquisition : acquisition // ignore: cast_nullable_to_non_nullable
as Acquisition,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ItemCondition,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as ItemLocation,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as ItemFlags,
  ));
}
/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AcquisitionCopyWith<$Res> get acquisition {
  
  return $AcquisitionCopyWith<$Res>(_self.acquisition, (value) {
    return _then(_self.copyWith(acquisition: value));
  });
}/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemConditionCopyWith<$Res> get condition {
  
  return $ItemConditionCopyWith<$Res>(_self.condition, (value) {
    return _then(_self.copyWith(condition: value));
  });
}/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemLocationCopyWith<$Res> get location {
  
  return $ItemLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemFlagsCopyWith<$Res> get flags {
  
  return $ItemFlagsCopyWith<$Res>(_self.flags, (value) {
    return _then(_self.copyWith(flags: value));
  });
}
}


/// Adds pattern-matching-related methods to [CollectionItem].
extension CollectionItemPatterns on CollectionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionItem value)  $default,){
final _that = this;
switch (_that) {
case _CollectionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionItem value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'card_ref')@DocumentReferenceConverter()  DocumentReference cardRef,  Acquisition acquisition,  ItemCondition condition,  ItemLocation location,  ItemFlags flags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionItem() when $default != null:
return $default(_that.id,_that.cardRef,_that.acquisition,_that.condition,_that.location,_that.flags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'card_ref')@DocumentReferenceConverter()  DocumentReference cardRef,  Acquisition acquisition,  ItemCondition condition,  ItemLocation location,  ItemFlags flags)  $default,) {final _that = this;
switch (_that) {
case _CollectionItem():
return $default(_that.id,_that.cardRef,_that.acquisition,_that.condition,_that.location,_that.flags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'card_ref')@DocumentReferenceConverter()  DocumentReference cardRef,  Acquisition acquisition,  ItemCondition condition,  ItemLocation location,  ItemFlags flags)?  $default,) {final _that = this;
switch (_that) {
case _CollectionItem() when $default != null:
return $default(_that.id,_that.cardRef,_that.acquisition,_that.condition,_that.location,_that.flags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionItem implements CollectionItem {
  const _CollectionItem({required this.id, @JsonKey(name: 'card_ref')@DocumentReferenceConverter() required this.cardRef, required this.acquisition, required this.condition, required this.location, required this.flags});
  factory _CollectionItem.fromJson(Map<String, dynamic> json) => _$CollectionItemFromJson(json);

@override final  String id;
/// Reference to /cards/{cardId}
@override@JsonKey(name: 'card_ref')@DocumentReferenceConverter() final  DocumentReference cardRef;
@override final  Acquisition acquisition;
@override final  ItemCondition condition;
@override final  ItemLocation location;
@override final  ItemFlags flags;

/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionItemCopyWith<_CollectionItem> get copyWith => __$CollectionItemCopyWithImpl<_CollectionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.cardRef, cardRef) || other.cardRef == cardRef)&&(identical(other.acquisition, acquisition) || other.acquisition == acquisition)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.location, location) || other.location == location)&&(identical(other.flags, flags) || other.flags == flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cardRef,acquisition,condition,location,flags);

@override
String toString() {
  return 'CollectionItem(id: $id, cardRef: $cardRef, acquisition: $acquisition, condition: $condition, location: $location, flags: $flags)';
}


}

/// @nodoc
abstract mixin class _$CollectionItemCopyWith<$Res> implements $CollectionItemCopyWith<$Res> {
  factory _$CollectionItemCopyWith(_CollectionItem value, $Res Function(_CollectionItem) _then) = __$CollectionItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'card_ref')@DocumentReferenceConverter() DocumentReference cardRef, Acquisition acquisition, ItemCondition condition, ItemLocation location, ItemFlags flags
});


@override $AcquisitionCopyWith<$Res> get acquisition;@override $ItemConditionCopyWith<$Res> get condition;@override $ItemLocationCopyWith<$Res> get location;@override $ItemFlagsCopyWith<$Res> get flags;

}
/// @nodoc
class __$CollectionItemCopyWithImpl<$Res>
    implements _$CollectionItemCopyWith<$Res> {
  __$CollectionItemCopyWithImpl(this._self, this._then);

  final _CollectionItem _self;
  final $Res Function(_CollectionItem) _then;

/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cardRef = null,Object? acquisition = null,Object? condition = null,Object? location = null,Object? flags = null,}) {
  return _then(_CollectionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cardRef: null == cardRef ? _self.cardRef : cardRef // ignore: cast_nullable_to_non_nullable
as DocumentReference,acquisition: null == acquisition ? _self.acquisition : acquisition // ignore: cast_nullable_to_non_nullable
as Acquisition,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ItemCondition,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as ItemLocation,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as ItemFlags,
  ));
}

/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AcquisitionCopyWith<$Res> get acquisition {
  
  return $AcquisitionCopyWith<$Res>(_self.acquisition, (value) {
    return _then(_self.copyWith(acquisition: value));
  });
}/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemConditionCopyWith<$Res> get condition {
  
  return $ItemConditionCopyWith<$Res>(_self.condition, (value) {
    return _then(_self.copyWith(condition: value));
  });
}/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemLocationCopyWith<$Res> get location {
  
  return $ItemLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemFlagsCopyWith<$Res> get flags {
  
  return $ItemFlagsCopyWith<$Res>(_self.flags, (value) {
    return _then(_self.copyWith(flags: value));
  });
}
}

// dart format on
