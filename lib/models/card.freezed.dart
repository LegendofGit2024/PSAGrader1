// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EbayRawPrice {

@JsonKey(name: 'last_sold') double? get lastSold;@JsonKey(name: 'last_updated')@TimestampConverter() DateTime? get lastUpdated;
/// Create a copy of EbayRawPrice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EbayRawPriceCopyWith<EbayRawPrice> get copyWith => _$EbayRawPriceCopyWithImpl<EbayRawPrice>(this as EbayRawPrice, _$identity);

  /// Serializes this EbayRawPrice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EbayRawPrice&&(identical(other.lastSold, lastSold) || other.lastSold == lastSold)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastSold,lastUpdated);

@override
String toString() {
  return 'EbayRawPrice(lastSold: $lastSold, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $EbayRawPriceCopyWith<$Res>  {
  factory $EbayRawPriceCopyWith(EbayRawPrice value, $Res Function(EbayRawPrice) _then) = _$EbayRawPriceCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'last_sold') double? lastSold,@JsonKey(name: 'last_updated')@TimestampConverter() DateTime? lastUpdated
});




}
/// @nodoc
class _$EbayRawPriceCopyWithImpl<$Res>
    implements $EbayRawPriceCopyWith<$Res> {
  _$EbayRawPriceCopyWithImpl(this._self, this._then);

  final EbayRawPrice _self;
  final $Res Function(EbayRawPrice) _then;

/// Create a copy of EbayRawPrice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lastSold = freezed,Object? lastUpdated = freezed,}) {
  return _then(_self.copyWith(
lastSold: freezed == lastSold ? _self.lastSold : lastSold // ignore: cast_nullable_to_non_nullable
as double?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EbayRawPrice].
extension EbayRawPricePatterns on EbayRawPrice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EbayRawPrice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EbayRawPrice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EbayRawPrice value)  $default,){
final _that = this;
switch (_that) {
case _EbayRawPrice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EbayRawPrice value)?  $default,){
final _that = this;
switch (_that) {
case _EbayRawPrice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'last_sold')  double? lastSold, @JsonKey(name: 'last_updated')@TimestampConverter()  DateTime? lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EbayRawPrice() when $default != null:
return $default(_that.lastSold,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'last_sold')  double? lastSold, @JsonKey(name: 'last_updated')@TimestampConverter()  DateTime? lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _EbayRawPrice():
return $default(_that.lastSold,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'last_sold')  double? lastSold, @JsonKey(name: 'last_updated')@TimestampConverter()  DateTime? lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _EbayRawPrice() when $default != null:
return $default(_that.lastSold,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EbayRawPrice implements EbayRawPrice {
  const _EbayRawPrice({@JsonKey(name: 'last_sold') this.lastSold, @JsonKey(name: 'last_updated')@TimestampConverter() this.lastUpdated});
  factory _EbayRawPrice.fromJson(Map<String, dynamic> json) => _$EbayRawPriceFromJson(json);

@override@JsonKey(name: 'last_sold') final  double? lastSold;
@override@JsonKey(name: 'last_updated')@TimestampConverter() final  DateTime? lastUpdated;

/// Create a copy of EbayRawPrice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EbayRawPriceCopyWith<_EbayRawPrice> get copyWith => __$EbayRawPriceCopyWithImpl<_EbayRawPrice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EbayRawPriceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EbayRawPrice&&(identical(other.lastSold, lastSold) || other.lastSold == lastSold)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastSold,lastUpdated);

@override
String toString() {
  return 'EbayRawPrice(lastSold: $lastSold, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$EbayRawPriceCopyWith<$Res> implements $EbayRawPriceCopyWith<$Res> {
  factory _$EbayRawPriceCopyWith(_EbayRawPrice value, $Res Function(_EbayRawPrice) _then) = __$EbayRawPriceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'last_sold') double? lastSold,@JsonKey(name: 'last_updated')@TimestampConverter() DateTime? lastUpdated
});




}
/// @nodoc
class __$EbayRawPriceCopyWithImpl<$Res>
    implements _$EbayRawPriceCopyWith<$Res> {
  __$EbayRawPriceCopyWithImpl(this._self, this._then);

  final _EbayRawPrice _self;
  final $Res Function(_EbayRawPrice) _then;

/// Create a copy of EbayRawPrice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lastSold = freezed,Object? lastUpdated = freezed,}) {
  return _then(_EbayRawPrice(
lastSold: freezed == lastSold ? _self.lastSold : lastSold // ignore: cast_nullable_to_non_nullable
as double?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EbaySubvariantPrices {

 double? get psa10; double? get psa9; double? get psa8;
/// Create a copy of EbaySubvariantPrices
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EbaySubvariantPricesCopyWith<EbaySubvariantPrices> get copyWith => _$EbaySubvariantPricesCopyWithImpl<EbaySubvariantPrices>(this as EbaySubvariantPrices, _$identity);

  /// Serializes this EbaySubvariantPrices to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EbaySubvariantPrices&&(identical(other.psa10, psa10) || other.psa10 == psa10)&&(identical(other.psa9, psa9) || other.psa9 == psa9)&&(identical(other.psa8, psa8) || other.psa8 == psa8));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,psa10,psa9,psa8);

@override
String toString() {
  return 'EbaySubvariantPrices(psa10: $psa10, psa9: $psa9, psa8: $psa8)';
}


}

/// @nodoc
abstract mixin class $EbaySubvariantPricesCopyWith<$Res>  {
  factory $EbaySubvariantPricesCopyWith(EbaySubvariantPrices value, $Res Function(EbaySubvariantPrices) _then) = _$EbaySubvariantPricesCopyWithImpl;
@useResult
$Res call({
 double? psa10, double? psa9, double? psa8
});




}
/// @nodoc
class _$EbaySubvariantPricesCopyWithImpl<$Res>
    implements $EbaySubvariantPricesCopyWith<$Res> {
  _$EbaySubvariantPricesCopyWithImpl(this._self, this._then);

  final EbaySubvariantPrices _self;
  final $Res Function(EbaySubvariantPrices) _then;

/// Create a copy of EbaySubvariantPrices
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? psa10 = freezed,Object? psa9 = freezed,Object? psa8 = freezed,}) {
  return _then(_self.copyWith(
psa10: freezed == psa10 ? _self.psa10 : psa10 // ignore: cast_nullable_to_non_nullable
as double?,psa9: freezed == psa9 ? _self.psa9 : psa9 // ignore: cast_nullable_to_non_nullable
as double?,psa8: freezed == psa8 ? _self.psa8 : psa8 // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [EbaySubvariantPrices].
extension EbaySubvariantPricesPatterns on EbaySubvariantPrices {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EbaySubvariantPrices value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EbaySubvariantPrices() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EbaySubvariantPrices value)  $default,){
final _that = this;
switch (_that) {
case _EbaySubvariantPrices():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EbaySubvariantPrices value)?  $default,){
final _that = this;
switch (_that) {
case _EbaySubvariantPrices() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? psa10,  double? psa9,  double? psa8)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EbaySubvariantPrices() when $default != null:
return $default(_that.psa10,_that.psa9,_that.psa8);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? psa10,  double? psa9,  double? psa8)  $default,) {final _that = this;
switch (_that) {
case _EbaySubvariantPrices():
return $default(_that.psa10,_that.psa9,_that.psa8);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? psa10,  double? psa9,  double? psa8)?  $default,) {final _that = this;
switch (_that) {
case _EbaySubvariantPrices() when $default != null:
return $default(_that.psa10,_that.psa9,_that.psa8);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EbaySubvariantPrices implements EbaySubvariantPrices {
  const _EbaySubvariantPrices({this.psa10, this.psa9, this.psa8});
  factory _EbaySubvariantPrices.fromJson(Map<String, dynamic> json) => _$EbaySubvariantPricesFromJson(json);

@override final  double? psa10;
@override final  double? psa9;
@override final  double? psa8;

/// Create a copy of EbaySubvariantPrices
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EbaySubvariantPricesCopyWith<_EbaySubvariantPrices> get copyWith => __$EbaySubvariantPricesCopyWithImpl<_EbaySubvariantPrices>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EbaySubvariantPricesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EbaySubvariantPrices&&(identical(other.psa10, psa10) || other.psa10 == psa10)&&(identical(other.psa9, psa9) || other.psa9 == psa9)&&(identical(other.psa8, psa8) || other.psa8 == psa8));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,psa10,psa9,psa8);

@override
String toString() {
  return 'EbaySubvariantPrices(psa10: $psa10, psa9: $psa9, psa8: $psa8)';
}


}

/// @nodoc
abstract mixin class _$EbaySubvariantPricesCopyWith<$Res> implements $EbaySubvariantPricesCopyWith<$Res> {
  factory _$EbaySubvariantPricesCopyWith(_EbaySubvariantPrices value, $Res Function(_EbaySubvariantPrices) _then) = __$EbaySubvariantPricesCopyWithImpl;
@override @useResult
$Res call({
 double? psa10, double? psa9, double? psa8
});




}
/// @nodoc
class __$EbaySubvariantPricesCopyWithImpl<$Res>
    implements _$EbaySubvariantPricesCopyWith<$Res> {
  __$EbaySubvariantPricesCopyWithImpl(this._self, this._then);

  final _EbaySubvariantPrices _self;
  final $Res Function(_EbaySubvariantPrices) _then;

/// Create a copy of EbaySubvariantPrices
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? psa10 = freezed,Object? psa9 = freezed,Object? psa8 = freezed,}) {
  return _then(_EbaySubvariantPrices(
psa10: freezed == psa10 ? _self.psa10 : psa10 // ignore: cast_nullable_to_non_nullable
as double?,psa9: freezed == psa9 ? _self.psa9 : psa9 // ignore: cast_nullable_to_non_nullable
as double?,psa8: freezed == psa8 ? _self.psa8 : psa8 // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$EbayGradedPrice {

/// Median of PSA 10 / CGC 10 / BGS 10 / GEM MINT recent sales.
 double? get psa10;/// Median of PSA 9 / MINT 9 recent sales.
 double? get psa9;/// Median of PSA 8 / NM-MT 8 recent sales.
 double? get psa8;@JsonKey(name: 'last_updated')@TimestampConverter() DateTime? get lastUpdated;/// Base Set sub-variant breakdown — only populated for WotC-era cards.
/// Keys: '1st_edition', 'shadowless', 'unlimited'
@JsonKey(name: 'subvariants') Map<String, EbaySubvariantPrices> get subvariants;
/// Create a copy of EbayGradedPrice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EbayGradedPriceCopyWith<EbayGradedPrice> get copyWith => _$EbayGradedPriceCopyWithImpl<EbayGradedPrice>(this as EbayGradedPrice, _$identity);

  /// Serializes this EbayGradedPrice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EbayGradedPrice&&(identical(other.psa10, psa10) || other.psa10 == psa10)&&(identical(other.psa9, psa9) || other.psa9 == psa9)&&(identical(other.psa8, psa8) || other.psa8 == psa8)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&const DeepCollectionEquality().equals(other.subvariants, subvariants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,psa10,psa9,psa8,lastUpdated,const DeepCollectionEquality().hash(subvariants));

@override
String toString() {
  return 'EbayGradedPrice(psa10: $psa10, psa9: $psa9, psa8: $psa8, lastUpdated: $lastUpdated, subvariants: $subvariants)';
}


}

/// @nodoc
abstract mixin class $EbayGradedPriceCopyWith<$Res>  {
  factory $EbayGradedPriceCopyWith(EbayGradedPrice value, $Res Function(EbayGradedPrice) _then) = _$EbayGradedPriceCopyWithImpl;
@useResult
$Res call({
 double? psa10, double? psa9, double? psa8,@JsonKey(name: 'last_updated')@TimestampConverter() DateTime? lastUpdated,@JsonKey(name: 'subvariants') Map<String, EbaySubvariantPrices> subvariants
});




}
/// @nodoc
class _$EbayGradedPriceCopyWithImpl<$Res>
    implements $EbayGradedPriceCopyWith<$Res> {
  _$EbayGradedPriceCopyWithImpl(this._self, this._then);

  final EbayGradedPrice _self;
  final $Res Function(EbayGradedPrice) _then;

/// Create a copy of EbayGradedPrice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? psa10 = freezed,Object? psa9 = freezed,Object? psa8 = freezed,Object? lastUpdated = freezed,Object? subvariants = null,}) {
  return _then(_self.copyWith(
psa10: freezed == psa10 ? _self.psa10 : psa10 // ignore: cast_nullable_to_non_nullable
as double?,psa9: freezed == psa9 ? _self.psa9 : psa9 // ignore: cast_nullable_to_non_nullable
as double?,psa8: freezed == psa8 ? _self.psa8 : psa8 // ignore: cast_nullable_to_non_nullable
as double?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,subvariants: null == subvariants ? _self.subvariants : subvariants // ignore: cast_nullable_to_non_nullable
as Map<String, EbaySubvariantPrices>,
  ));
}

}


/// Adds pattern-matching-related methods to [EbayGradedPrice].
extension EbayGradedPricePatterns on EbayGradedPrice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EbayGradedPrice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EbayGradedPrice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EbayGradedPrice value)  $default,){
final _that = this;
switch (_that) {
case _EbayGradedPrice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EbayGradedPrice value)?  $default,){
final _that = this;
switch (_that) {
case _EbayGradedPrice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? psa10,  double? psa9,  double? psa8, @JsonKey(name: 'last_updated')@TimestampConverter()  DateTime? lastUpdated, @JsonKey(name: 'subvariants')  Map<String, EbaySubvariantPrices> subvariants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EbayGradedPrice() when $default != null:
return $default(_that.psa10,_that.psa9,_that.psa8,_that.lastUpdated,_that.subvariants);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? psa10,  double? psa9,  double? psa8, @JsonKey(name: 'last_updated')@TimestampConverter()  DateTime? lastUpdated, @JsonKey(name: 'subvariants')  Map<String, EbaySubvariantPrices> subvariants)  $default,) {final _that = this;
switch (_that) {
case _EbayGradedPrice():
return $default(_that.psa10,_that.psa9,_that.psa8,_that.lastUpdated,_that.subvariants);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? psa10,  double? psa9,  double? psa8, @JsonKey(name: 'last_updated')@TimestampConverter()  DateTime? lastUpdated, @JsonKey(name: 'subvariants')  Map<String, EbaySubvariantPrices> subvariants)?  $default,) {final _that = this;
switch (_that) {
case _EbayGradedPrice() when $default != null:
return $default(_that.psa10,_that.psa9,_that.psa8,_that.lastUpdated,_that.subvariants);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EbayGradedPrice implements EbayGradedPrice {
  const _EbayGradedPrice({this.psa10, this.psa9, this.psa8, @JsonKey(name: 'last_updated')@TimestampConverter() this.lastUpdated, @JsonKey(name: 'subvariants') final  Map<String, EbaySubvariantPrices> subvariants = const {}}): _subvariants = subvariants;
  factory _EbayGradedPrice.fromJson(Map<String, dynamic> json) => _$EbayGradedPriceFromJson(json);

/// Median of PSA 10 / CGC 10 / BGS 10 / GEM MINT recent sales.
@override final  double? psa10;
/// Median of PSA 9 / MINT 9 recent sales.
@override final  double? psa9;
/// Median of PSA 8 / NM-MT 8 recent sales.
@override final  double? psa8;
@override@JsonKey(name: 'last_updated')@TimestampConverter() final  DateTime? lastUpdated;
/// Base Set sub-variant breakdown — only populated for WotC-era cards.
/// Keys: '1st_edition', 'shadowless', 'unlimited'
 final  Map<String, EbaySubvariantPrices> _subvariants;
/// Base Set sub-variant breakdown — only populated for WotC-era cards.
/// Keys: '1st_edition', 'shadowless', 'unlimited'
@override@JsonKey(name: 'subvariants') Map<String, EbaySubvariantPrices> get subvariants {
  if (_subvariants is EqualUnmodifiableMapView) return _subvariants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_subvariants);
}


/// Create a copy of EbayGradedPrice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EbayGradedPriceCopyWith<_EbayGradedPrice> get copyWith => __$EbayGradedPriceCopyWithImpl<_EbayGradedPrice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EbayGradedPriceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EbayGradedPrice&&(identical(other.psa10, psa10) || other.psa10 == psa10)&&(identical(other.psa9, psa9) || other.psa9 == psa9)&&(identical(other.psa8, psa8) || other.psa8 == psa8)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&const DeepCollectionEquality().equals(other._subvariants, _subvariants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,psa10,psa9,psa8,lastUpdated,const DeepCollectionEquality().hash(_subvariants));

@override
String toString() {
  return 'EbayGradedPrice(psa10: $psa10, psa9: $psa9, psa8: $psa8, lastUpdated: $lastUpdated, subvariants: $subvariants)';
}


}

/// @nodoc
abstract mixin class _$EbayGradedPriceCopyWith<$Res> implements $EbayGradedPriceCopyWith<$Res> {
  factory _$EbayGradedPriceCopyWith(_EbayGradedPrice value, $Res Function(_EbayGradedPrice) _then) = __$EbayGradedPriceCopyWithImpl;
@override @useResult
$Res call({
 double? psa10, double? psa9, double? psa8,@JsonKey(name: 'last_updated')@TimestampConverter() DateTime? lastUpdated,@JsonKey(name: 'subvariants') Map<String, EbaySubvariantPrices> subvariants
});




}
/// @nodoc
class __$EbayGradedPriceCopyWithImpl<$Res>
    implements _$EbayGradedPriceCopyWith<$Res> {
  __$EbayGradedPriceCopyWithImpl(this._self, this._then);

  final _EbayGradedPrice _self;
  final $Res Function(_EbayGradedPrice) _then;

/// Create a copy of EbayGradedPrice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? psa10 = freezed,Object? psa9 = freezed,Object? psa8 = freezed,Object? lastUpdated = freezed,Object? subvariants = null,}) {
  return _then(_EbayGradedPrice(
psa10: freezed == psa10 ? _self.psa10 : psa10 // ignore: cast_nullable_to_non_nullable
as double?,psa9: freezed == psa9 ? _self.psa9 : psa9 // ignore: cast_nullable_to_non_nullable
as double?,psa8: freezed == psa8 ? _self.psa8 : psa8 // ignore: cast_nullable_to_non_nullable
as double?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,subvariants: null == subvariants ? _self._subvariants : subvariants // ignore: cast_nullable_to_non_nullable
as Map<String, EbaySubvariantPrices>,
  ));
}


}


/// @nodoc
mixin _$EbayUsPricing {

/// Split pricing: raw vs graded (set by ebay_price_fetcher.py).
 EbayRawPrice? get raw; EbayGradedPrice? get graded;/// Legacy flat fields — kept for backward compatibility with older documents.
@JsonKey(name: 'last_sold_nm') double? get lastSoldNm;@JsonKey(name: 'last_sold_lp') double? get lastSoldLp;@JsonKey(name: 'volume_7d') int? get volume7d;@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of EbayUsPricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EbayUsPricingCopyWith<EbayUsPricing> get copyWith => _$EbayUsPricingCopyWithImpl<EbayUsPricing>(this as EbayUsPricing, _$identity);

  /// Serializes this EbayUsPricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EbayUsPricing&&(identical(other.raw, raw) || other.raw == raw)&&(identical(other.graded, graded) || other.graded == graded)&&(identical(other.lastSoldNm, lastSoldNm) || other.lastSoldNm == lastSoldNm)&&(identical(other.lastSoldLp, lastSoldLp) || other.lastSoldLp == lastSoldLp)&&(identical(other.volume7d, volume7d) || other.volume7d == volume7d)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,raw,graded,lastSoldNm,lastSoldLp,volume7d,updatedAt);

@override
String toString() {
  return 'EbayUsPricing(raw: $raw, graded: $graded, lastSoldNm: $lastSoldNm, lastSoldLp: $lastSoldLp, volume7d: $volume7d, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EbayUsPricingCopyWith<$Res>  {
  factory $EbayUsPricingCopyWith(EbayUsPricing value, $Res Function(EbayUsPricing) _then) = _$EbayUsPricingCopyWithImpl;
@useResult
$Res call({
 EbayRawPrice? raw, EbayGradedPrice? graded,@JsonKey(name: 'last_sold_nm') double? lastSoldNm,@JsonKey(name: 'last_sold_lp') double? lastSoldLp,@JsonKey(name: 'volume_7d') int? volume7d,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});


$EbayRawPriceCopyWith<$Res>? get raw;$EbayGradedPriceCopyWith<$Res>? get graded;

}
/// @nodoc
class _$EbayUsPricingCopyWithImpl<$Res>
    implements $EbayUsPricingCopyWith<$Res> {
  _$EbayUsPricingCopyWithImpl(this._self, this._then);

  final EbayUsPricing _self;
  final $Res Function(EbayUsPricing) _then;

/// Create a copy of EbayUsPricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? raw = freezed,Object? graded = freezed,Object? lastSoldNm = freezed,Object? lastSoldLp = freezed,Object? volume7d = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
raw: freezed == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as EbayRawPrice?,graded: freezed == graded ? _self.graded : graded // ignore: cast_nullable_to_non_nullable
as EbayGradedPrice?,lastSoldNm: freezed == lastSoldNm ? _self.lastSoldNm : lastSoldNm // ignore: cast_nullable_to_non_nullable
as double?,lastSoldLp: freezed == lastSoldLp ? _self.lastSoldLp : lastSoldLp // ignore: cast_nullable_to_non_nullable
as double?,volume7d: freezed == volume7d ? _self.volume7d : volume7d // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of EbayUsPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EbayRawPriceCopyWith<$Res>? get raw {
    if (_self.raw == null) {
    return null;
  }

  return $EbayRawPriceCopyWith<$Res>(_self.raw!, (value) {
    return _then(_self.copyWith(raw: value));
  });
}/// Create a copy of EbayUsPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EbayGradedPriceCopyWith<$Res>? get graded {
    if (_self.graded == null) {
    return null;
  }

  return $EbayGradedPriceCopyWith<$Res>(_self.graded!, (value) {
    return _then(_self.copyWith(graded: value));
  });
}
}


/// Adds pattern-matching-related methods to [EbayUsPricing].
extension EbayUsPricingPatterns on EbayUsPricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EbayUsPricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EbayUsPricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EbayUsPricing value)  $default,){
final _that = this;
switch (_that) {
case _EbayUsPricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EbayUsPricing value)?  $default,){
final _that = this;
switch (_that) {
case _EbayUsPricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EbayRawPrice? raw,  EbayGradedPrice? graded, @JsonKey(name: 'last_sold_nm')  double? lastSoldNm, @JsonKey(name: 'last_sold_lp')  double? lastSoldLp, @JsonKey(name: 'volume_7d')  int? volume7d, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EbayUsPricing() when $default != null:
return $default(_that.raw,_that.graded,_that.lastSoldNm,_that.lastSoldLp,_that.volume7d,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EbayRawPrice? raw,  EbayGradedPrice? graded, @JsonKey(name: 'last_sold_nm')  double? lastSoldNm, @JsonKey(name: 'last_sold_lp')  double? lastSoldLp, @JsonKey(name: 'volume_7d')  int? volume7d, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EbayUsPricing():
return $default(_that.raw,_that.graded,_that.lastSoldNm,_that.lastSoldLp,_that.volume7d,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EbayRawPrice? raw,  EbayGradedPrice? graded, @JsonKey(name: 'last_sold_nm')  double? lastSoldNm, @JsonKey(name: 'last_sold_lp')  double? lastSoldLp, @JsonKey(name: 'volume_7d')  int? volume7d, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EbayUsPricing() when $default != null:
return $default(_that.raw,_that.graded,_that.lastSoldNm,_that.lastSoldLp,_that.volume7d,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EbayUsPricing implements EbayUsPricing {
  const _EbayUsPricing({this.raw, this.graded, @JsonKey(name: 'last_sold_nm') this.lastSoldNm, @JsonKey(name: 'last_sold_lp') this.lastSoldLp, @JsonKey(name: 'volume_7d') this.volume7d, @JsonKey(name: 'updated_at')@TimestampConverter() this.updatedAt});
  factory _EbayUsPricing.fromJson(Map<String, dynamic> json) => _$EbayUsPricingFromJson(json);

/// Split pricing: raw vs graded (set by ebay_price_fetcher.py).
@override final  EbayRawPrice? raw;
@override final  EbayGradedPrice? graded;
/// Legacy flat fields — kept for backward compatibility with older documents.
@override@JsonKey(name: 'last_sold_nm') final  double? lastSoldNm;
@override@JsonKey(name: 'last_sold_lp') final  double? lastSoldLp;
@override@JsonKey(name: 'volume_7d') final  int? volume7d;
@override@JsonKey(name: 'updated_at')@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of EbayUsPricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EbayUsPricingCopyWith<_EbayUsPricing> get copyWith => __$EbayUsPricingCopyWithImpl<_EbayUsPricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EbayUsPricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EbayUsPricing&&(identical(other.raw, raw) || other.raw == raw)&&(identical(other.graded, graded) || other.graded == graded)&&(identical(other.lastSoldNm, lastSoldNm) || other.lastSoldNm == lastSoldNm)&&(identical(other.lastSoldLp, lastSoldLp) || other.lastSoldLp == lastSoldLp)&&(identical(other.volume7d, volume7d) || other.volume7d == volume7d)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,raw,graded,lastSoldNm,lastSoldLp,volume7d,updatedAt);

@override
String toString() {
  return 'EbayUsPricing(raw: $raw, graded: $graded, lastSoldNm: $lastSoldNm, lastSoldLp: $lastSoldLp, volume7d: $volume7d, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EbayUsPricingCopyWith<$Res> implements $EbayUsPricingCopyWith<$Res> {
  factory _$EbayUsPricingCopyWith(_EbayUsPricing value, $Res Function(_EbayUsPricing) _then) = __$EbayUsPricingCopyWithImpl;
@override @useResult
$Res call({
 EbayRawPrice? raw, EbayGradedPrice? graded,@JsonKey(name: 'last_sold_nm') double? lastSoldNm,@JsonKey(name: 'last_sold_lp') double? lastSoldLp,@JsonKey(name: 'volume_7d') int? volume7d,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});


@override $EbayRawPriceCopyWith<$Res>? get raw;@override $EbayGradedPriceCopyWith<$Res>? get graded;

}
/// @nodoc
class __$EbayUsPricingCopyWithImpl<$Res>
    implements _$EbayUsPricingCopyWith<$Res> {
  __$EbayUsPricingCopyWithImpl(this._self, this._then);

  final _EbayUsPricing _self;
  final $Res Function(_EbayUsPricing) _then;

/// Create a copy of EbayUsPricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? raw = freezed,Object? graded = freezed,Object? lastSoldNm = freezed,Object? lastSoldLp = freezed,Object? volume7d = freezed,Object? updatedAt = freezed,}) {
  return _then(_EbayUsPricing(
raw: freezed == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as EbayRawPrice?,graded: freezed == graded ? _self.graded : graded // ignore: cast_nullable_to_non_nullable
as EbayGradedPrice?,lastSoldNm: freezed == lastSoldNm ? _self.lastSoldNm : lastSoldNm // ignore: cast_nullable_to_non_nullable
as double?,lastSoldLp: freezed == lastSoldLp ? _self.lastSoldLp : lastSoldLp // ignore: cast_nullable_to_non_nullable
as double?,volume7d: freezed == volume7d ? _self.volume7d : volume7d // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of EbayUsPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EbayRawPriceCopyWith<$Res>? get raw {
    if (_self.raw == null) {
    return null;
  }

  return $EbayRawPriceCopyWith<$Res>(_self.raw!, (value) {
    return _then(_self.copyWith(raw: value));
  });
}/// Create a copy of EbayUsPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EbayGradedPriceCopyWith<$Res>? get graded {
    if (_self.graded == null) {
    return null;
  }

  return $EbayGradedPriceCopyWith<$Res>(_self.graded!, (value) {
    return _then(_self.copyWith(graded: value));
  });
}
}


/// @nodoc
mixin _$TcgplayerUsPricing {

@JsonKey(name: 'market_nm') double? get marketNm;@JsonKey(name: 'market_lp') double? get marketLp;@JsonKey(name: 'market_mp') double? get marketMp;@JsonKey(name: 'market_hp') double? get marketHp;@JsonKey(name: 'market_dmg') double? get marketDmg;@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of TcgplayerUsPricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TcgplayerUsPricingCopyWith<TcgplayerUsPricing> get copyWith => _$TcgplayerUsPricingCopyWithImpl<TcgplayerUsPricing>(this as TcgplayerUsPricing, _$identity);

  /// Serializes this TcgplayerUsPricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TcgplayerUsPricing&&(identical(other.marketNm, marketNm) || other.marketNm == marketNm)&&(identical(other.marketLp, marketLp) || other.marketLp == marketLp)&&(identical(other.marketMp, marketMp) || other.marketMp == marketMp)&&(identical(other.marketHp, marketHp) || other.marketHp == marketHp)&&(identical(other.marketDmg, marketDmg) || other.marketDmg == marketDmg)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,marketNm,marketLp,marketMp,marketHp,marketDmg,updatedAt);

@override
String toString() {
  return 'TcgplayerUsPricing(marketNm: $marketNm, marketLp: $marketLp, marketMp: $marketMp, marketHp: $marketHp, marketDmg: $marketDmg, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TcgplayerUsPricingCopyWith<$Res>  {
  factory $TcgplayerUsPricingCopyWith(TcgplayerUsPricing value, $Res Function(TcgplayerUsPricing) _then) = _$TcgplayerUsPricingCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'market_nm') double? marketNm,@JsonKey(name: 'market_lp') double? marketLp,@JsonKey(name: 'market_mp') double? marketMp,@JsonKey(name: 'market_hp') double? marketHp,@JsonKey(name: 'market_dmg') double? marketDmg,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$TcgplayerUsPricingCopyWithImpl<$Res>
    implements $TcgplayerUsPricingCopyWith<$Res> {
  _$TcgplayerUsPricingCopyWithImpl(this._self, this._then);

  final TcgplayerUsPricing _self;
  final $Res Function(TcgplayerUsPricing) _then;

/// Create a copy of TcgplayerUsPricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? marketNm = freezed,Object? marketLp = freezed,Object? marketMp = freezed,Object? marketHp = freezed,Object? marketDmg = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
marketNm: freezed == marketNm ? _self.marketNm : marketNm // ignore: cast_nullable_to_non_nullable
as double?,marketLp: freezed == marketLp ? _self.marketLp : marketLp // ignore: cast_nullable_to_non_nullable
as double?,marketMp: freezed == marketMp ? _self.marketMp : marketMp // ignore: cast_nullable_to_non_nullable
as double?,marketHp: freezed == marketHp ? _self.marketHp : marketHp // ignore: cast_nullable_to_non_nullable
as double?,marketDmg: freezed == marketDmg ? _self.marketDmg : marketDmg // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TcgplayerUsPricing].
extension TcgplayerUsPricingPatterns on TcgplayerUsPricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TcgplayerUsPricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TcgplayerUsPricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TcgplayerUsPricing value)  $default,){
final _that = this;
switch (_that) {
case _TcgplayerUsPricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TcgplayerUsPricing value)?  $default,){
final _that = this;
switch (_that) {
case _TcgplayerUsPricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'market_nm')  double? marketNm, @JsonKey(name: 'market_lp')  double? marketLp, @JsonKey(name: 'market_mp')  double? marketMp, @JsonKey(name: 'market_hp')  double? marketHp, @JsonKey(name: 'market_dmg')  double? marketDmg, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TcgplayerUsPricing() when $default != null:
return $default(_that.marketNm,_that.marketLp,_that.marketMp,_that.marketHp,_that.marketDmg,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'market_nm')  double? marketNm, @JsonKey(name: 'market_lp')  double? marketLp, @JsonKey(name: 'market_mp')  double? marketMp, @JsonKey(name: 'market_hp')  double? marketHp, @JsonKey(name: 'market_dmg')  double? marketDmg, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TcgplayerUsPricing():
return $default(_that.marketNm,_that.marketLp,_that.marketMp,_that.marketHp,_that.marketDmg,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'market_nm')  double? marketNm, @JsonKey(name: 'market_lp')  double? marketLp, @JsonKey(name: 'market_mp')  double? marketMp, @JsonKey(name: 'market_hp')  double? marketHp, @JsonKey(name: 'market_dmg')  double? marketDmg, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TcgplayerUsPricing() when $default != null:
return $default(_that.marketNm,_that.marketLp,_that.marketMp,_that.marketHp,_that.marketDmg,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TcgplayerUsPricing implements TcgplayerUsPricing {
  const _TcgplayerUsPricing({@JsonKey(name: 'market_nm') this.marketNm, @JsonKey(name: 'market_lp') this.marketLp, @JsonKey(name: 'market_mp') this.marketMp, @JsonKey(name: 'market_hp') this.marketHp, @JsonKey(name: 'market_dmg') this.marketDmg, @JsonKey(name: 'updated_at')@TimestampConverter() this.updatedAt});
  factory _TcgplayerUsPricing.fromJson(Map<String, dynamic> json) => _$TcgplayerUsPricingFromJson(json);

@override@JsonKey(name: 'market_nm') final  double? marketNm;
@override@JsonKey(name: 'market_lp') final  double? marketLp;
@override@JsonKey(name: 'market_mp') final  double? marketMp;
@override@JsonKey(name: 'market_hp') final  double? marketHp;
@override@JsonKey(name: 'market_dmg') final  double? marketDmg;
@override@JsonKey(name: 'updated_at')@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of TcgplayerUsPricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TcgplayerUsPricingCopyWith<_TcgplayerUsPricing> get copyWith => __$TcgplayerUsPricingCopyWithImpl<_TcgplayerUsPricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TcgplayerUsPricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TcgplayerUsPricing&&(identical(other.marketNm, marketNm) || other.marketNm == marketNm)&&(identical(other.marketLp, marketLp) || other.marketLp == marketLp)&&(identical(other.marketMp, marketMp) || other.marketMp == marketMp)&&(identical(other.marketHp, marketHp) || other.marketHp == marketHp)&&(identical(other.marketDmg, marketDmg) || other.marketDmg == marketDmg)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,marketNm,marketLp,marketMp,marketHp,marketDmg,updatedAt);

@override
String toString() {
  return 'TcgplayerUsPricing(marketNm: $marketNm, marketLp: $marketLp, marketMp: $marketMp, marketHp: $marketHp, marketDmg: $marketDmg, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TcgplayerUsPricingCopyWith<$Res> implements $TcgplayerUsPricingCopyWith<$Res> {
  factory _$TcgplayerUsPricingCopyWith(_TcgplayerUsPricing value, $Res Function(_TcgplayerUsPricing) _then) = __$TcgplayerUsPricingCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'market_nm') double? marketNm,@JsonKey(name: 'market_lp') double? marketLp,@JsonKey(name: 'market_mp') double? marketMp,@JsonKey(name: 'market_hp') double? marketHp,@JsonKey(name: 'market_dmg') double? marketDmg,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$TcgplayerUsPricingCopyWithImpl<$Res>
    implements _$TcgplayerUsPricingCopyWith<$Res> {
  __$TcgplayerUsPricingCopyWithImpl(this._self, this._then);

  final _TcgplayerUsPricing _self;
  final $Res Function(_TcgplayerUsPricing) _then;

/// Create a copy of TcgplayerUsPricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? marketNm = freezed,Object? marketLp = freezed,Object? marketMp = freezed,Object? marketHp = freezed,Object? marketDmg = freezed,Object? updatedAt = freezed,}) {
  return _then(_TcgplayerUsPricing(
marketNm: freezed == marketNm ? _self.marketNm : marketNm // ignore: cast_nullable_to_non_nullable
as double?,marketLp: freezed == marketLp ? _self.marketLp : marketLp // ignore: cast_nullable_to_non_nullable
as double?,marketMp: freezed == marketMp ? _self.marketMp : marketMp // ignore: cast_nullable_to_non_nullable
as double?,marketHp: freezed == marketHp ? _self.marketHp : marketHp // ignore: cast_nullable_to_non_nullable
as double?,marketDmg: freezed == marketDmg ? _self.marketDmg : marketDmg // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CardmarketEuPricing {

@JsonKey(name: 'trend_price') double? get trendPrice;@JsonKey(name: 'avg_sell_1d') double? get avgSell1d;@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of CardmarketEuPricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardmarketEuPricingCopyWith<CardmarketEuPricing> get copyWith => _$CardmarketEuPricingCopyWithImpl<CardmarketEuPricing>(this as CardmarketEuPricing, _$identity);

  /// Serializes this CardmarketEuPricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardmarketEuPricing&&(identical(other.trendPrice, trendPrice) || other.trendPrice == trendPrice)&&(identical(other.avgSell1d, avgSell1d) || other.avgSell1d == avgSell1d)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trendPrice,avgSell1d,updatedAt);

@override
String toString() {
  return 'CardmarketEuPricing(trendPrice: $trendPrice, avgSell1d: $avgSell1d, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CardmarketEuPricingCopyWith<$Res>  {
  factory $CardmarketEuPricingCopyWith(CardmarketEuPricing value, $Res Function(CardmarketEuPricing) _then) = _$CardmarketEuPricingCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'trend_price') double? trendPrice,@JsonKey(name: 'avg_sell_1d') double? avgSell1d,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$CardmarketEuPricingCopyWithImpl<$Res>
    implements $CardmarketEuPricingCopyWith<$Res> {
  _$CardmarketEuPricingCopyWithImpl(this._self, this._then);

  final CardmarketEuPricing _self;
  final $Res Function(CardmarketEuPricing) _then;

/// Create a copy of CardmarketEuPricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trendPrice = freezed,Object? avgSell1d = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
trendPrice: freezed == trendPrice ? _self.trendPrice : trendPrice // ignore: cast_nullable_to_non_nullable
as double?,avgSell1d: freezed == avgSell1d ? _self.avgSell1d : avgSell1d // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardmarketEuPricing].
extension CardmarketEuPricingPatterns on CardmarketEuPricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardmarketEuPricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardmarketEuPricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardmarketEuPricing value)  $default,){
final _that = this;
switch (_that) {
case _CardmarketEuPricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardmarketEuPricing value)?  $default,){
final _that = this;
switch (_that) {
case _CardmarketEuPricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'trend_price')  double? trendPrice, @JsonKey(name: 'avg_sell_1d')  double? avgSell1d, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardmarketEuPricing() when $default != null:
return $default(_that.trendPrice,_that.avgSell1d,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'trend_price')  double? trendPrice, @JsonKey(name: 'avg_sell_1d')  double? avgSell1d, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CardmarketEuPricing():
return $default(_that.trendPrice,_that.avgSell1d,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'trend_price')  double? trendPrice, @JsonKey(name: 'avg_sell_1d')  double? avgSell1d, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CardmarketEuPricing() when $default != null:
return $default(_that.trendPrice,_that.avgSell1d,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardmarketEuPricing implements CardmarketEuPricing {
  const _CardmarketEuPricing({@JsonKey(name: 'trend_price') this.trendPrice, @JsonKey(name: 'avg_sell_1d') this.avgSell1d, @JsonKey(name: 'updated_at')@TimestampConverter() this.updatedAt});
  factory _CardmarketEuPricing.fromJson(Map<String, dynamic> json) => _$CardmarketEuPricingFromJson(json);

@override@JsonKey(name: 'trend_price') final  double? trendPrice;
@override@JsonKey(name: 'avg_sell_1d') final  double? avgSell1d;
@override@JsonKey(name: 'updated_at')@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of CardmarketEuPricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardmarketEuPricingCopyWith<_CardmarketEuPricing> get copyWith => __$CardmarketEuPricingCopyWithImpl<_CardmarketEuPricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardmarketEuPricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardmarketEuPricing&&(identical(other.trendPrice, trendPrice) || other.trendPrice == trendPrice)&&(identical(other.avgSell1d, avgSell1d) || other.avgSell1d == avgSell1d)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trendPrice,avgSell1d,updatedAt);

@override
String toString() {
  return 'CardmarketEuPricing(trendPrice: $trendPrice, avgSell1d: $avgSell1d, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CardmarketEuPricingCopyWith<$Res> implements $CardmarketEuPricingCopyWith<$Res> {
  factory _$CardmarketEuPricingCopyWith(_CardmarketEuPricing value, $Res Function(_CardmarketEuPricing) _then) = __$CardmarketEuPricingCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'trend_price') double? trendPrice,@JsonKey(name: 'avg_sell_1d') double? avgSell1d,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$CardmarketEuPricingCopyWithImpl<$Res>
    implements _$CardmarketEuPricingCopyWith<$Res> {
  __$CardmarketEuPricingCopyWithImpl(this._self, this._then);

  final _CardmarketEuPricing _self;
  final $Res Function(_CardmarketEuPricing) _then;

/// Create a copy of CardmarketEuPricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trendPrice = freezed,Object? avgSell1d = freezed,Object? updatedAt = freezed,}) {
  return _then(_CardmarketEuPricing(
trendPrice: freezed == trendPrice ? _self.trendPrice : trendPrice // ignore: cast_nullable_to_non_nullable
as double?,avgSell1d: freezed == avgSell1d ? _self.avgSell1d : avgSell1d // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$YuyuteiJpPricing {

@JsonKey(name: 'buy_price') double? get buyPrice;@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of YuyuteiJpPricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$YuyuteiJpPricingCopyWith<YuyuteiJpPricing> get copyWith => _$YuyuteiJpPricingCopyWithImpl<YuyuteiJpPricing>(this as YuyuteiJpPricing, _$identity);

  /// Serializes this YuyuteiJpPricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is YuyuteiJpPricing&&(identical(other.buyPrice, buyPrice) || other.buyPrice == buyPrice)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,buyPrice,updatedAt);

@override
String toString() {
  return 'YuyuteiJpPricing(buyPrice: $buyPrice, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $YuyuteiJpPricingCopyWith<$Res>  {
  factory $YuyuteiJpPricingCopyWith(YuyuteiJpPricing value, $Res Function(YuyuteiJpPricing) _then) = _$YuyuteiJpPricingCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'buy_price') double? buyPrice,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$YuyuteiJpPricingCopyWithImpl<$Res>
    implements $YuyuteiJpPricingCopyWith<$Res> {
  _$YuyuteiJpPricingCopyWithImpl(this._self, this._then);

  final YuyuteiJpPricing _self;
  final $Res Function(YuyuteiJpPricing) _then;

/// Create a copy of YuyuteiJpPricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? buyPrice = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
buyPrice: freezed == buyPrice ? _self.buyPrice : buyPrice // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [YuyuteiJpPricing].
extension YuyuteiJpPricingPatterns on YuyuteiJpPricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _YuyuteiJpPricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _YuyuteiJpPricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _YuyuteiJpPricing value)  $default,){
final _that = this;
switch (_that) {
case _YuyuteiJpPricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _YuyuteiJpPricing value)?  $default,){
final _that = this;
switch (_that) {
case _YuyuteiJpPricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'buy_price')  double? buyPrice, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _YuyuteiJpPricing() when $default != null:
return $default(_that.buyPrice,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'buy_price')  double? buyPrice, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _YuyuteiJpPricing():
return $default(_that.buyPrice,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'buy_price')  double? buyPrice, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _YuyuteiJpPricing() when $default != null:
return $default(_that.buyPrice,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _YuyuteiJpPricing implements YuyuteiJpPricing {
  const _YuyuteiJpPricing({@JsonKey(name: 'buy_price') this.buyPrice, @JsonKey(name: 'updated_at')@TimestampConverter() this.updatedAt});
  factory _YuyuteiJpPricing.fromJson(Map<String, dynamic> json) => _$YuyuteiJpPricingFromJson(json);

@override@JsonKey(name: 'buy_price') final  double? buyPrice;
@override@JsonKey(name: 'updated_at')@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of YuyuteiJpPricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$YuyuteiJpPricingCopyWith<_YuyuteiJpPricing> get copyWith => __$YuyuteiJpPricingCopyWithImpl<_YuyuteiJpPricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$YuyuteiJpPricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _YuyuteiJpPricing&&(identical(other.buyPrice, buyPrice) || other.buyPrice == buyPrice)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,buyPrice,updatedAt);

@override
String toString() {
  return 'YuyuteiJpPricing(buyPrice: $buyPrice, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$YuyuteiJpPricingCopyWith<$Res> implements $YuyuteiJpPricingCopyWith<$Res> {
  factory _$YuyuteiJpPricingCopyWith(_YuyuteiJpPricing value, $Res Function(_YuyuteiJpPricing) _then) = __$YuyuteiJpPricingCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'buy_price') double? buyPrice,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$YuyuteiJpPricingCopyWithImpl<$Res>
    implements _$YuyuteiJpPricingCopyWith<$Res> {
  __$YuyuteiJpPricingCopyWithImpl(this._self, this._then);

  final _YuyuteiJpPricing _self;
  final $Res Function(_YuyuteiJpPricing) _then;

/// Create a copy of YuyuteiJpPricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? buyPrice = freezed,Object? updatedAt = freezed,}) {
  return _then(_YuyuteiJpPricing(
buyPrice: freezed == buyPrice ? _self.buyPrice : buyPrice // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CardPricing {

@JsonKey(name: 'ebay_us') EbayUsPricing? get ebayUs;@JsonKey(name: 'tcgplayer_us') TcgplayerUsPricing? get tcgplayerUs;@JsonKey(name: 'cardmarket_eu') CardmarketEuPricing? get cardmarketEu;@JsonKey(name: 'yuyutei_jp') YuyuteiJpPricing? get yuyuteiJp;
/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardPricingCopyWith<CardPricing> get copyWith => _$CardPricingCopyWithImpl<CardPricing>(this as CardPricing, _$identity);

  /// Serializes this CardPricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardPricing&&(identical(other.ebayUs, ebayUs) || other.ebayUs == ebayUs)&&(identical(other.tcgplayerUs, tcgplayerUs) || other.tcgplayerUs == tcgplayerUs)&&(identical(other.cardmarketEu, cardmarketEu) || other.cardmarketEu == cardmarketEu)&&(identical(other.yuyuteiJp, yuyuteiJp) || other.yuyuteiJp == yuyuteiJp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ebayUs,tcgplayerUs,cardmarketEu,yuyuteiJp);

@override
String toString() {
  return 'CardPricing(ebayUs: $ebayUs, tcgplayerUs: $tcgplayerUs, cardmarketEu: $cardmarketEu, yuyuteiJp: $yuyuteiJp)';
}


}

/// @nodoc
abstract mixin class $CardPricingCopyWith<$Res>  {
  factory $CardPricingCopyWith(CardPricing value, $Res Function(CardPricing) _then) = _$CardPricingCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ebay_us') EbayUsPricing? ebayUs,@JsonKey(name: 'tcgplayer_us') TcgplayerUsPricing? tcgplayerUs,@JsonKey(name: 'cardmarket_eu') CardmarketEuPricing? cardmarketEu,@JsonKey(name: 'yuyutei_jp') YuyuteiJpPricing? yuyuteiJp
});


$EbayUsPricingCopyWith<$Res>? get ebayUs;$TcgplayerUsPricingCopyWith<$Res>? get tcgplayerUs;$CardmarketEuPricingCopyWith<$Res>? get cardmarketEu;$YuyuteiJpPricingCopyWith<$Res>? get yuyuteiJp;

}
/// @nodoc
class _$CardPricingCopyWithImpl<$Res>
    implements $CardPricingCopyWith<$Res> {
  _$CardPricingCopyWithImpl(this._self, this._then);

  final CardPricing _self;
  final $Res Function(CardPricing) _then;

/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ebayUs = freezed,Object? tcgplayerUs = freezed,Object? cardmarketEu = freezed,Object? yuyuteiJp = freezed,}) {
  return _then(_self.copyWith(
ebayUs: freezed == ebayUs ? _self.ebayUs : ebayUs // ignore: cast_nullable_to_non_nullable
as EbayUsPricing?,tcgplayerUs: freezed == tcgplayerUs ? _self.tcgplayerUs : tcgplayerUs // ignore: cast_nullable_to_non_nullable
as TcgplayerUsPricing?,cardmarketEu: freezed == cardmarketEu ? _self.cardmarketEu : cardmarketEu // ignore: cast_nullable_to_non_nullable
as CardmarketEuPricing?,yuyuteiJp: freezed == yuyuteiJp ? _self.yuyuteiJp : yuyuteiJp // ignore: cast_nullable_to_non_nullable
as YuyuteiJpPricing?,
  ));
}
/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EbayUsPricingCopyWith<$Res>? get ebayUs {
    if (_self.ebayUs == null) {
    return null;
  }

  return $EbayUsPricingCopyWith<$Res>(_self.ebayUs!, (value) {
    return _then(_self.copyWith(ebayUs: value));
  });
}/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TcgplayerUsPricingCopyWith<$Res>? get tcgplayerUs {
    if (_self.tcgplayerUs == null) {
    return null;
  }

  return $TcgplayerUsPricingCopyWith<$Res>(_self.tcgplayerUs!, (value) {
    return _then(_self.copyWith(tcgplayerUs: value));
  });
}/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardmarketEuPricingCopyWith<$Res>? get cardmarketEu {
    if (_self.cardmarketEu == null) {
    return null;
  }

  return $CardmarketEuPricingCopyWith<$Res>(_self.cardmarketEu!, (value) {
    return _then(_self.copyWith(cardmarketEu: value));
  });
}/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$YuyuteiJpPricingCopyWith<$Res>? get yuyuteiJp {
    if (_self.yuyuteiJp == null) {
    return null;
  }

  return $YuyuteiJpPricingCopyWith<$Res>(_self.yuyuteiJp!, (value) {
    return _then(_self.copyWith(yuyuteiJp: value));
  });
}
}


/// Adds pattern-matching-related methods to [CardPricing].
extension CardPricingPatterns on CardPricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardPricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardPricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardPricing value)  $default,){
final _that = this;
switch (_that) {
case _CardPricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardPricing value)?  $default,){
final _that = this;
switch (_that) {
case _CardPricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'ebay_us')  EbayUsPricing? ebayUs, @JsonKey(name: 'tcgplayer_us')  TcgplayerUsPricing? tcgplayerUs, @JsonKey(name: 'cardmarket_eu')  CardmarketEuPricing? cardmarketEu, @JsonKey(name: 'yuyutei_jp')  YuyuteiJpPricing? yuyuteiJp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardPricing() when $default != null:
return $default(_that.ebayUs,_that.tcgplayerUs,_that.cardmarketEu,_that.yuyuteiJp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'ebay_us')  EbayUsPricing? ebayUs, @JsonKey(name: 'tcgplayer_us')  TcgplayerUsPricing? tcgplayerUs, @JsonKey(name: 'cardmarket_eu')  CardmarketEuPricing? cardmarketEu, @JsonKey(name: 'yuyutei_jp')  YuyuteiJpPricing? yuyuteiJp)  $default,) {final _that = this;
switch (_that) {
case _CardPricing():
return $default(_that.ebayUs,_that.tcgplayerUs,_that.cardmarketEu,_that.yuyuteiJp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'ebay_us')  EbayUsPricing? ebayUs, @JsonKey(name: 'tcgplayer_us')  TcgplayerUsPricing? tcgplayerUs, @JsonKey(name: 'cardmarket_eu')  CardmarketEuPricing? cardmarketEu, @JsonKey(name: 'yuyutei_jp')  YuyuteiJpPricing? yuyuteiJp)?  $default,) {final _that = this;
switch (_that) {
case _CardPricing() when $default != null:
return $default(_that.ebayUs,_that.tcgplayerUs,_that.cardmarketEu,_that.yuyuteiJp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardPricing implements CardPricing {
  const _CardPricing({@JsonKey(name: 'ebay_us') this.ebayUs, @JsonKey(name: 'tcgplayer_us') this.tcgplayerUs, @JsonKey(name: 'cardmarket_eu') this.cardmarketEu, @JsonKey(name: 'yuyutei_jp') this.yuyuteiJp});
  factory _CardPricing.fromJson(Map<String, dynamic> json) => _$CardPricingFromJson(json);

@override@JsonKey(name: 'ebay_us') final  EbayUsPricing? ebayUs;
@override@JsonKey(name: 'tcgplayer_us') final  TcgplayerUsPricing? tcgplayerUs;
@override@JsonKey(name: 'cardmarket_eu') final  CardmarketEuPricing? cardmarketEu;
@override@JsonKey(name: 'yuyutei_jp') final  YuyuteiJpPricing? yuyuteiJp;

/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardPricingCopyWith<_CardPricing> get copyWith => __$CardPricingCopyWithImpl<_CardPricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardPricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardPricing&&(identical(other.ebayUs, ebayUs) || other.ebayUs == ebayUs)&&(identical(other.tcgplayerUs, tcgplayerUs) || other.tcgplayerUs == tcgplayerUs)&&(identical(other.cardmarketEu, cardmarketEu) || other.cardmarketEu == cardmarketEu)&&(identical(other.yuyuteiJp, yuyuteiJp) || other.yuyuteiJp == yuyuteiJp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ebayUs,tcgplayerUs,cardmarketEu,yuyuteiJp);

@override
String toString() {
  return 'CardPricing(ebayUs: $ebayUs, tcgplayerUs: $tcgplayerUs, cardmarketEu: $cardmarketEu, yuyuteiJp: $yuyuteiJp)';
}


}

/// @nodoc
abstract mixin class _$CardPricingCopyWith<$Res> implements $CardPricingCopyWith<$Res> {
  factory _$CardPricingCopyWith(_CardPricing value, $Res Function(_CardPricing) _then) = __$CardPricingCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ebay_us') EbayUsPricing? ebayUs,@JsonKey(name: 'tcgplayer_us') TcgplayerUsPricing? tcgplayerUs,@JsonKey(name: 'cardmarket_eu') CardmarketEuPricing? cardmarketEu,@JsonKey(name: 'yuyutei_jp') YuyuteiJpPricing? yuyuteiJp
});


@override $EbayUsPricingCopyWith<$Res>? get ebayUs;@override $TcgplayerUsPricingCopyWith<$Res>? get tcgplayerUs;@override $CardmarketEuPricingCopyWith<$Res>? get cardmarketEu;@override $YuyuteiJpPricingCopyWith<$Res>? get yuyuteiJp;

}
/// @nodoc
class __$CardPricingCopyWithImpl<$Res>
    implements _$CardPricingCopyWith<$Res> {
  __$CardPricingCopyWithImpl(this._self, this._then);

  final _CardPricing _self;
  final $Res Function(_CardPricing) _then;

/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ebayUs = freezed,Object? tcgplayerUs = freezed,Object? cardmarketEu = freezed,Object? yuyuteiJp = freezed,}) {
  return _then(_CardPricing(
ebayUs: freezed == ebayUs ? _self.ebayUs : ebayUs // ignore: cast_nullable_to_non_nullable
as EbayUsPricing?,tcgplayerUs: freezed == tcgplayerUs ? _self.tcgplayerUs : tcgplayerUs // ignore: cast_nullable_to_non_nullable
as TcgplayerUsPricing?,cardmarketEu: freezed == cardmarketEu ? _self.cardmarketEu : cardmarketEu // ignore: cast_nullable_to_non_nullable
as CardmarketEuPricing?,yuyuteiJp: freezed == yuyuteiJp ? _self.yuyuteiJp : yuyuteiJp // ignore: cast_nullable_to_non_nullable
as YuyuteiJpPricing?,
  ));
}

/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EbayUsPricingCopyWith<$Res>? get ebayUs {
    if (_self.ebayUs == null) {
    return null;
  }

  return $EbayUsPricingCopyWith<$Res>(_self.ebayUs!, (value) {
    return _then(_self.copyWith(ebayUs: value));
  });
}/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TcgplayerUsPricingCopyWith<$Res>? get tcgplayerUs {
    if (_self.tcgplayerUs == null) {
    return null;
  }

  return $TcgplayerUsPricingCopyWith<$Res>(_self.tcgplayerUs!, (value) {
    return _then(_self.copyWith(tcgplayerUs: value));
  });
}/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardmarketEuPricingCopyWith<$Res>? get cardmarketEu {
    if (_self.cardmarketEu == null) {
    return null;
  }

  return $CardmarketEuPricingCopyWith<$Res>(_self.cardmarketEu!, (value) {
    return _then(_self.copyWith(cardmarketEu: value));
  });
}/// Create a copy of CardPricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$YuyuteiJpPricingCopyWith<$Res>? get yuyuteiJp {
    if (_self.yuyuteiJp == null) {
    return null;
  }

  return $YuyuteiJpPricingCopyWith<$Res>(_self.yuyuteiJp!, (value) {
    return _then(_self.copyWith(yuyuteiJp: value));
  });
}
}


/// @nodoc
mixin _$PsaPop {

@JsonKey(name: 'total_pop') int? get totalPop;@JsonKey(name: 'pop_10') int? get pop10;@JsonKey(name: 'pop_9') int? get pop9;@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of PsaPop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PsaPopCopyWith<PsaPop> get copyWith => _$PsaPopCopyWithImpl<PsaPop>(this as PsaPop, _$identity);

  /// Serializes this PsaPop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PsaPop&&(identical(other.totalPop, totalPop) || other.totalPop == totalPop)&&(identical(other.pop10, pop10) || other.pop10 == pop10)&&(identical(other.pop9, pop9) || other.pop9 == pop9)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalPop,pop10,pop9,updatedAt);

@override
String toString() {
  return 'PsaPop(totalPop: $totalPop, pop10: $pop10, pop9: $pop9, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PsaPopCopyWith<$Res>  {
  factory $PsaPopCopyWith(PsaPop value, $Res Function(PsaPop) _then) = _$PsaPopCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_pop') int? totalPop,@JsonKey(name: 'pop_10') int? pop10,@JsonKey(name: 'pop_9') int? pop9,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$PsaPopCopyWithImpl<$Res>
    implements $PsaPopCopyWith<$Res> {
  _$PsaPopCopyWithImpl(this._self, this._then);

  final PsaPop _self;
  final $Res Function(PsaPop) _then;

/// Create a copy of PsaPop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalPop = freezed,Object? pop10 = freezed,Object? pop9 = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
totalPop: freezed == totalPop ? _self.totalPop : totalPop // ignore: cast_nullable_to_non_nullable
as int?,pop10: freezed == pop10 ? _self.pop10 : pop10 // ignore: cast_nullable_to_non_nullable
as int?,pop9: freezed == pop9 ? _self.pop9 : pop9 // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PsaPop].
extension PsaPopPatterns on PsaPop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PsaPop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PsaPop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PsaPop value)  $default,){
final _that = this;
switch (_that) {
case _PsaPop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PsaPop value)?  $default,){
final _that = this;
switch (_that) {
case _PsaPop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_pop')  int? totalPop, @JsonKey(name: 'pop_10')  int? pop10, @JsonKey(name: 'pop_9')  int? pop9, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PsaPop() when $default != null:
return $default(_that.totalPop,_that.pop10,_that.pop9,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_pop')  int? totalPop, @JsonKey(name: 'pop_10')  int? pop10, @JsonKey(name: 'pop_9')  int? pop9, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PsaPop():
return $default(_that.totalPop,_that.pop10,_that.pop9,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_pop')  int? totalPop, @JsonKey(name: 'pop_10')  int? pop10, @JsonKey(name: 'pop_9')  int? pop9, @JsonKey(name: 'updated_at')@TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PsaPop() when $default != null:
return $default(_that.totalPop,_that.pop10,_that.pop9,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PsaPop implements PsaPop {
  const _PsaPop({@JsonKey(name: 'total_pop') this.totalPop, @JsonKey(name: 'pop_10') this.pop10, @JsonKey(name: 'pop_9') this.pop9, @JsonKey(name: 'updated_at')@TimestampConverter() this.updatedAt});
  factory _PsaPop.fromJson(Map<String, dynamic> json) => _$PsaPopFromJson(json);

@override@JsonKey(name: 'total_pop') final  int? totalPop;
@override@JsonKey(name: 'pop_10') final  int? pop10;
@override@JsonKey(name: 'pop_9') final  int? pop9;
@override@JsonKey(name: 'updated_at')@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of PsaPop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PsaPopCopyWith<_PsaPop> get copyWith => __$PsaPopCopyWithImpl<_PsaPop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PsaPopToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PsaPop&&(identical(other.totalPop, totalPop) || other.totalPop == totalPop)&&(identical(other.pop10, pop10) || other.pop10 == pop10)&&(identical(other.pop9, pop9) || other.pop9 == pop9)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalPop,pop10,pop9,updatedAt);

@override
String toString() {
  return 'PsaPop(totalPop: $totalPop, pop10: $pop10, pop9: $pop9, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PsaPopCopyWith<$Res> implements $PsaPopCopyWith<$Res> {
  factory _$PsaPopCopyWith(_PsaPop value, $Res Function(_PsaPop) _then) = __$PsaPopCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_pop') int? totalPop,@JsonKey(name: 'pop_10') int? pop10,@JsonKey(name: 'pop_9') int? pop9,@JsonKey(name: 'updated_at')@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$PsaPopCopyWithImpl<$Res>
    implements _$PsaPopCopyWith<$Res> {
  __$PsaPopCopyWithImpl(this._self, this._then);

  final _PsaPop _self;
  final $Res Function(_PsaPop) _then;

/// Create a copy of PsaPop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalPop = freezed,Object? pop10 = freezed,Object? pop9 = freezed,Object? updatedAt = freezed,}) {
  return _then(_PsaPop(
totalPop: freezed == totalPop ? _self.totalPop : totalPop // ignore: cast_nullable_to_non_nullable
as int?,pop10: freezed == pop10 ? _self.pop10 : pop10 // ignore: cast_nullable_to_non_nullable
as int?,pop9: freezed == pop9 ? _self.pop9 : pop9 // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CardMeta {

 String get name;@JsonKey(name: 'set_id') String get setId;@JsonKey(name: 'set_number') String get setNumber;@JsonKey(name: 'language')@JsonKey(unknownEnumValue: CardLanguage.en) CardLanguage get language; String get variant;@JsonKey(name: 'image_url') String get imageUrl;/// Specialty classification tags (e.g. 'japanese', '1st_edition', 'error').
/// Applied automatically by the Kaggle importer and editable in-app.
@JsonKey(name: 'specialty_tags') List<String> get specialtyTags;/// Base Set sub-variant for WotC-era cards: '1st_edition', 'shadowless',
/// or 'unlimited'. Null for sets that have no sub-variant distinction.
@JsonKey(name: 'sub_variant') String? get subVariant;
/// Create a copy of CardMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardMetaCopyWith<CardMeta> get copyWith => _$CardMetaCopyWithImpl<CardMeta>(this as CardMeta, _$identity);

  /// Serializes this CardMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardMeta&&(identical(other.name, name) || other.name == name)&&(identical(other.setId, setId) || other.setId == setId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.language, language) || other.language == language)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.specialtyTags, specialtyTags)&&(identical(other.subVariant, subVariant) || other.subVariant == subVariant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,setId,setNumber,language,variant,imageUrl,const DeepCollectionEquality().hash(specialtyTags),subVariant);

@override
String toString() {
  return 'CardMeta(name: $name, setId: $setId, setNumber: $setNumber, language: $language, variant: $variant, imageUrl: $imageUrl, specialtyTags: $specialtyTags, subVariant: $subVariant)';
}


}

/// @nodoc
abstract mixin class $CardMetaCopyWith<$Res>  {
  factory $CardMetaCopyWith(CardMeta value, $Res Function(CardMeta) _then) = _$CardMetaCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(name: 'set_id') String setId,@JsonKey(name: 'set_number') String setNumber,@JsonKey(name: 'language')@JsonKey(unknownEnumValue: CardLanguage.en) CardLanguage language, String variant,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'specialty_tags') List<String> specialtyTags,@JsonKey(name: 'sub_variant') String? subVariant
});




}
/// @nodoc
class _$CardMetaCopyWithImpl<$Res>
    implements $CardMetaCopyWith<$Res> {
  _$CardMetaCopyWithImpl(this._self, this._then);

  final CardMeta _self;
  final $Res Function(CardMeta) _then;

/// Create a copy of CardMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? setId = null,Object? setNumber = null,Object? language = null,Object? variant = null,Object? imageUrl = null,Object? specialtyTags = null,Object? subVariant = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,setId: null == setId ? _self.setId : setId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as CardLanguage,variant: null == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,specialtyTags: null == specialtyTags ? _self.specialtyTags : specialtyTags // ignore: cast_nullable_to_non_nullable
as List<String>,subVariant: freezed == subVariant ? _self.subVariant : subVariant // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardMeta].
extension CardMetaPatterns on CardMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardMeta value)  $default,){
final _that = this;
switch (_that) {
case _CardMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardMeta value)?  $default,){
final _that = this;
switch (_that) {
case _CardMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'set_id')  String setId, @JsonKey(name: 'set_number')  String setNumber, @JsonKey(name: 'language')@JsonKey(unknownEnumValue: CardLanguage.en)  CardLanguage language,  String variant, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'specialty_tags')  List<String> specialtyTags, @JsonKey(name: 'sub_variant')  String? subVariant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardMeta() when $default != null:
return $default(_that.name,_that.setId,_that.setNumber,_that.language,_that.variant,_that.imageUrl,_that.specialtyTags,_that.subVariant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'set_id')  String setId, @JsonKey(name: 'set_number')  String setNumber, @JsonKey(name: 'language')@JsonKey(unknownEnumValue: CardLanguage.en)  CardLanguage language,  String variant, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'specialty_tags')  List<String> specialtyTags, @JsonKey(name: 'sub_variant')  String? subVariant)  $default,) {final _that = this;
switch (_that) {
case _CardMeta():
return $default(_that.name,_that.setId,_that.setNumber,_that.language,_that.variant,_that.imageUrl,_that.specialtyTags,_that.subVariant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(name: 'set_id')  String setId, @JsonKey(name: 'set_number')  String setNumber, @JsonKey(name: 'language')@JsonKey(unknownEnumValue: CardLanguage.en)  CardLanguage language,  String variant, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'specialty_tags')  List<String> specialtyTags, @JsonKey(name: 'sub_variant')  String? subVariant)?  $default,) {final _that = this;
switch (_that) {
case _CardMeta() when $default != null:
return $default(_that.name,_that.setId,_that.setNumber,_that.language,_that.variant,_that.imageUrl,_that.specialtyTags,_that.subVariant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardMeta implements CardMeta {
  const _CardMeta({required this.name, @JsonKey(name: 'set_id') required this.setId, @JsonKey(name: 'set_number') required this.setNumber, @JsonKey(name: 'language')@JsonKey(unknownEnumValue: CardLanguage.en) required this.language, required this.variant, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'specialty_tags') final  List<String> specialtyTags = const [], @JsonKey(name: 'sub_variant') this.subVariant}): _specialtyTags = specialtyTags;
  factory _CardMeta.fromJson(Map<String, dynamic> json) => _$CardMetaFromJson(json);

@override final  String name;
@override@JsonKey(name: 'set_id') final  String setId;
@override@JsonKey(name: 'set_number') final  String setNumber;
@override@JsonKey(name: 'language')@JsonKey(unknownEnumValue: CardLanguage.en) final  CardLanguage language;
@override final  String variant;
@override@JsonKey(name: 'image_url') final  String imageUrl;
/// Specialty classification tags (e.g. 'japanese', '1st_edition', 'error').
/// Applied automatically by the Kaggle importer and editable in-app.
 final  List<String> _specialtyTags;
/// Specialty classification tags (e.g. 'japanese', '1st_edition', 'error').
/// Applied automatically by the Kaggle importer and editable in-app.
@override@JsonKey(name: 'specialty_tags') List<String> get specialtyTags {
  if (_specialtyTags is EqualUnmodifiableListView) return _specialtyTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialtyTags);
}

/// Base Set sub-variant for WotC-era cards: '1st_edition', 'shadowless',
/// or 'unlimited'. Null for sets that have no sub-variant distinction.
@override@JsonKey(name: 'sub_variant') final  String? subVariant;

/// Create a copy of CardMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardMetaCopyWith<_CardMeta> get copyWith => __$CardMetaCopyWithImpl<_CardMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardMeta&&(identical(other.name, name) || other.name == name)&&(identical(other.setId, setId) || other.setId == setId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.language, language) || other.language == language)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._specialtyTags, _specialtyTags)&&(identical(other.subVariant, subVariant) || other.subVariant == subVariant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,setId,setNumber,language,variant,imageUrl,const DeepCollectionEquality().hash(_specialtyTags),subVariant);

@override
String toString() {
  return 'CardMeta(name: $name, setId: $setId, setNumber: $setNumber, language: $language, variant: $variant, imageUrl: $imageUrl, specialtyTags: $specialtyTags, subVariant: $subVariant)';
}


}

/// @nodoc
abstract mixin class _$CardMetaCopyWith<$Res> implements $CardMetaCopyWith<$Res> {
  factory _$CardMetaCopyWith(_CardMeta value, $Res Function(_CardMeta) _then) = __$CardMetaCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(name: 'set_id') String setId,@JsonKey(name: 'set_number') String setNumber,@JsonKey(name: 'language')@JsonKey(unknownEnumValue: CardLanguage.en) CardLanguage language, String variant,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'specialty_tags') List<String> specialtyTags,@JsonKey(name: 'sub_variant') String? subVariant
});




}
/// @nodoc
class __$CardMetaCopyWithImpl<$Res>
    implements _$CardMetaCopyWith<$Res> {
  __$CardMetaCopyWithImpl(this._self, this._then);

  final _CardMeta _self;
  final $Res Function(_CardMeta) _then;

/// Create a copy of CardMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? setId = null,Object? setNumber = null,Object? language = null,Object? variant = null,Object? imageUrl = null,Object? specialtyTags = null,Object? subVariant = freezed,}) {
  return _then(_CardMeta(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,setId: null == setId ? _self.setId : setId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as CardLanguage,variant: null == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,specialtyTags: null == specialtyTags ? _self._specialtyTags : specialtyTags // ignore: cast_nullable_to_non_nullable
as List<String>,subVariant: freezed == subVariant ? _self.subVariant : subVariant // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CardDocument {

 String get id; CardMeta get meta; CardPricing get pricing;@JsonKey(name: 'psa_pop') PsaPop? get psaPop;
/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardDocumentCopyWith<CardDocument> get copyWith => _$CardDocumentCopyWithImpl<CardDocument>(this as CardDocument, _$identity);

  /// Serializes this CardDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.psaPop, psaPop) || other.psaPop == psaPop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,meta,pricing,psaPop);

@override
String toString() {
  return 'CardDocument(id: $id, meta: $meta, pricing: $pricing, psaPop: $psaPop)';
}


}

/// @nodoc
abstract mixin class $CardDocumentCopyWith<$Res>  {
  factory $CardDocumentCopyWith(CardDocument value, $Res Function(CardDocument) _then) = _$CardDocumentCopyWithImpl;
@useResult
$Res call({
 String id, CardMeta meta, CardPricing pricing,@JsonKey(name: 'psa_pop') PsaPop? psaPop
});


$CardMetaCopyWith<$Res> get meta;$CardPricingCopyWith<$Res> get pricing;$PsaPopCopyWith<$Res>? get psaPop;

}
/// @nodoc
class _$CardDocumentCopyWithImpl<$Res>
    implements $CardDocumentCopyWith<$Res> {
  _$CardDocumentCopyWithImpl(this._self, this._then);

  final CardDocument _self;
  final $Res Function(CardDocument) _then;

/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? meta = null,Object? pricing = null,Object? psaPop = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as CardMeta,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as CardPricing,psaPop: freezed == psaPop ? _self.psaPop : psaPop // ignore: cast_nullable_to_non_nullable
as PsaPop?,
  ));
}
/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardMetaCopyWith<$Res> get meta {
  
  return $CardMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardPricingCopyWith<$Res> get pricing {
  
  return $CardPricingCopyWith<$Res>(_self.pricing, (value) {
    return _then(_self.copyWith(pricing: value));
  });
}/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PsaPopCopyWith<$Res>? get psaPop {
    if (_self.psaPop == null) {
    return null;
  }

  return $PsaPopCopyWith<$Res>(_self.psaPop!, (value) {
    return _then(_self.copyWith(psaPop: value));
  });
}
}


/// Adds pattern-matching-related methods to [CardDocument].
extension CardDocumentPatterns on CardDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardDocument value)  $default,){
final _that = this;
switch (_that) {
case _CardDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardDocument value)?  $default,){
final _that = this;
switch (_that) {
case _CardDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CardMeta meta,  CardPricing pricing, @JsonKey(name: 'psa_pop')  PsaPop? psaPop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardDocument() when $default != null:
return $default(_that.id,_that.meta,_that.pricing,_that.psaPop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CardMeta meta,  CardPricing pricing, @JsonKey(name: 'psa_pop')  PsaPop? psaPop)  $default,) {final _that = this;
switch (_that) {
case _CardDocument():
return $default(_that.id,_that.meta,_that.pricing,_that.psaPop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CardMeta meta,  CardPricing pricing, @JsonKey(name: 'psa_pop')  PsaPop? psaPop)?  $default,) {final _that = this;
switch (_that) {
case _CardDocument() when $default != null:
return $default(_that.id,_that.meta,_that.pricing,_that.psaPop);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardDocument implements CardDocument {
  const _CardDocument({required this.id, required this.meta, required this.pricing, @JsonKey(name: 'psa_pop') this.psaPop});
  factory _CardDocument.fromJson(Map<String, dynamic> json) => _$CardDocumentFromJson(json);

@override final  String id;
@override final  CardMeta meta;
@override final  CardPricing pricing;
@override@JsonKey(name: 'psa_pop') final  PsaPop? psaPop;

/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardDocumentCopyWith<_CardDocument> get copyWith => __$CardDocumentCopyWithImpl<_CardDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.psaPop, psaPop) || other.psaPop == psaPop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,meta,pricing,psaPop);

@override
String toString() {
  return 'CardDocument(id: $id, meta: $meta, pricing: $pricing, psaPop: $psaPop)';
}


}

/// @nodoc
abstract mixin class _$CardDocumentCopyWith<$Res> implements $CardDocumentCopyWith<$Res> {
  factory _$CardDocumentCopyWith(_CardDocument value, $Res Function(_CardDocument) _then) = __$CardDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, CardMeta meta, CardPricing pricing,@JsonKey(name: 'psa_pop') PsaPop? psaPop
});


@override $CardMetaCopyWith<$Res> get meta;@override $CardPricingCopyWith<$Res> get pricing;@override $PsaPopCopyWith<$Res>? get psaPop;

}
/// @nodoc
class __$CardDocumentCopyWithImpl<$Res>
    implements _$CardDocumentCopyWith<$Res> {
  __$CardDocumentCopyWithImpl(this._self, this._then);

  final _CardDocument _self;
  final $Res Function(_CardDocument) _then;

/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? meta = null,Object? pricing = null,Object? psaPop = freezed,}) {
  return _then(_CardDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as CardMeta,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as CardPricing,psaPop: freezed == psaPop ? _self.psaPop : psaPop // ignore: cast_nullable_to_non_nullable
as PsaPop?,
  ));
}

/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardMetaCopyWith<$Res> get meta {
  
  return $CardMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardPricingCopyWith<$Res> get pricing {
  
  return $CardPricingCopyWith<$Res>(_self.pricing, (value) {
    return _then(_self.copyWith(pricing: value));
  });
}/// Create a copy of CardDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PsaPopCopyWith<$Res>? get psaPop {
    if (_self.psaPop == null) {
    return null;
  }

  return $PsaPopCopyWith<$Res>(_self.psaPop!, (value) {
    return _then(_self.copyWith(psaPop: value));
  });
}
}

// dart format on
