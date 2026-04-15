// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submission_estimate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstimateInputs {

@JsonKey(name: 'current_condition') RawCondition get currentCondition; Grader get grader;@JsonKey(name: 'grading_fee') double get gradingFee;@JsonKey(name: 'shipping_cost') double get shippingCost;
/// Create a copy of EstimateInputs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimateInputsCopyWith<EstimateInputs> get copyWith => _$EstimateInputsCopyWithImpl<EstimateInputs>(this as EstimateInputs, _$identity);

  /// Serializes this EstimateInputs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstimateInputs&&(identical(other.currentCondition, currentCondition) || other.currentCondition == currentCondition)&&(identical(other.grader, grader) || other.grader == grader)&&(identical(other.gradingFee, gradingFee) || other.gradingFee == gradingFee)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentCondition,grader,gradingFee,shippingCost);

@override
String toString() {
  return 'EstimateInputs(currentCondition: $currentCondition, grader: $grader, gradingFee: $gradingFee, shippingCost: $shippingCost)';
}


}

/// @nodoc
abstract mixin class $EstimateInputsCopyWith<$Res>  {
  factory $EstimateInputsCopyWith(EstimateInputs value, $Res Function(EstimateInputs) _then) = _$EstimateInputsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_condition') RawCondition currentCondition, Grader grader,@JsonKey(name: 'grading_fee') double gradingFee,@JsonKey(name: 'shipping_cost') double shippingCost
});




}
/// @nodoc
class _$EstimateInputsCopyWithImpl<$Res>
    implements $EstimateInputsCopyWith<$Res> {
  _$EstimateInputsCopyWithImpl(this._self, this._then);

  final EstimateInputs _self;
  final $Res Function(EstimateInputs) _then;

/// Create a copy of EstimateInputs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentCondition = null,Object? grader = null,Object? gradingFee = null,Object? shippingCost = null,}) {
  return _then(_self.copyWith(
currentCondition: null == currentCondition ? _self.currentCondition : currentCondition // ignore: cast_nullable_to_non_nullable
as RawCondition,grader: null == grader ? _self.grader : grader // ignore: cast_nullable_to_non_nullable
as Grader,gradingFee: null == gradingFee ? _self.gradingFee : gradingFee // ignore: cast_nullable_to_non_nullable
as double,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EstimateInputs].
extension EstimateInputsPatterns on EstimateInputs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstimateInputs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstimateInputs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstimateInputs value)  $default,){
final _that = this;
switch (_that) {
case _EstimateInputs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstimateInputs value)?  $default,){
final _that = this;
switch (_that) {
case _EstimateInputs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_condition')  RawCondition currentCondition,  Grader grader, @JsonKey(name: 'grading_fee')  double gradingFee, @JsonKey(name: 'shipping_cost')  double shippingCost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstimateInputs() when $default != null:
return $default(_that.currentCondition,_that.grader,_that.gradingFee,_that.shippingCost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_condition')  RawCondition currentCondition,  Grader grader, @JsonKey(name: 'grading_fee')  double gradingFee, @JsonKey(name: 'shipping_cost')  double shippingCost)  $default,) {final _that = this;
switch (_that) {
case _EstimateInputs():
return $default(_that.currentCondition,_that.grader,_that.gradingFee,_that.shippingCost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_condition')  RawCondition currentCondition,  Grader grader, @JsonKey(name: 'grading_fee')  double gradingFee, @JsonKey(name: 'shipping_cost')  double shippingCost)?  $default,) {final _that = this;
switch (_that) {
case _EstimateInputs() when $default != null:
return $default(_that.currentCondition,_that.grader,_that.gradingFee,_that.shippingCost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EstimateInputs implements EstimateInputs {
  const _EstimateInputs({@JsonKey(name: 'current_condition') required this.currentCondition, required this.grader, @JsonKey(name: 'grading_fee') required this.gradingFee, @JsonKey(name: 'shipping_cost') required this.shippingCost});
  factory _EstimateInputs.fromJson(Map<String, dynamic> json) => _$EstimateInputsFromJson(json);

@override@JsonKey(name: 'current_condition') final  RawCondition currentCondition;
@override final  Grader grader;
@override@JsonKey(name: 'grading_fee') final  double gradingFee;
@override@JsonKey(name: 'shipping_cost') final  double shippingCost;

/// Create a copy of EstimateInputs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstimateInputsCopyWith<_EstimateInputs> get copyWith => __$EstimateInputsCopyWithImpl<_EstimateInputs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EstimateInputsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstimateInputs&&(identical(other.currentCondition, currentCondition) || other.currentCondition == currentCondition)&&(identical(other.grader, grader) || other.grader == grader)&&(identical(other.gradingFee, gradingFee) || other.gradingFee == gradingFee)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentCondition,grader,gradingFee,shippingCost);

@override
String toString() {
  return 'EstimateInputs(currentCondition: $currentCondition, grader: $grader, gradingFee: $gradingFee, shippingCost: $shippingCost)';
}


}

/// @nodoc
abstract mixin class _$EstimateInputsCopyWith<$Res> implements $EstimateInputsCopyWith<$Res> {
  factory _$EstimateInputsCopyWith(_EstimateInputs value, $Res Function(_EstimateInputs) _then) = __$EstimateInputsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_condition') RawCondition currentCondition, Grader grader,@JsonKey(name: 'grading_fee') double gradingFee,@JsonKey(name: 'shipping_cost') double shippingCost
});




}
/// @nodoc
class __$EstimateInputsCopyWithImpl<$Res>
    implements _$EstimateInputsCopyWith<$Res> {
  __$EstimateInputsCopyWithImpl(this._self, this._then);

  final _EstimateInputs _self;
  final $Res Function(_EstimateInputs) _then;

/// Create a copy of EstimateInputs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentCondition = null,Object? grader = null,Object? gradingFee = null,Object? shippingCost = null,}) {
  return _then(_EstimateInputs(
currentCondition: null == currentCondition ? _self.currentCondition : currentCondition // ignore: cast_nullable_to_non_nullable
as RawCondition,grader: null == grader ? _self.grader : grader // ignore: cast_nullable_to_non_nullable
as Grader,gradingFee: null == gradingFee ? _self.gradingFee : gradingFee // ignore: cast_nullable_to_non_nullable
as double,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$EstimateOutputs {

@JsonKey(name: 'projected_grade') double get projectedGrade;@JsonKey(name: 'market_value_at_grade') double get marketValueAtGrade;@JsonKey(name: 'net_profit') double get netProfit;@JsonKey(name: 'break_even_grade') double get breakEvenGrade;
/// Create a copy of EstimateOutputs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimateOutputsCopyWith<EstimateOutputs> get copyWith => _$EstimateOutputsCopyWithImpl<EstimateOutputs>(this as EstimateOutputs, _$identity);

  /// Serializes this EstimateOutputs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstimateOutputs&&(identical(other.projectedGrade, projectedGrade) || other.projectedGrade == projectedGrade)&&(identical(other.marketValueAtGrade, marketValueAtGrade) || other.marketValueAtGrade == marketValueAtGrade)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.breakEvenGrade, breakEvenGrade) || other.breakEvenGrade == breakEvenGrade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectedGrade,marketValueAtGrade,netProfit,breakEvenGrade);

@override
String toString() {
  return 'EstimateOutputs(projectedGrade: $projectedGrade, marketValueAtGrade: $marketValueAtGrade, netProfit: $netProfit, breakEvenGrade: $breakEvenGrade)';
}


}

/// @nodoc
abstract mixin class $EstimateOutputsCopyWith<$Res>  {
  factory $EstimateOutputsCopyWith(EstimateOutputs value, $Res Function(EstimateOutputs) _then) = _$EstimateOutputsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'projected_grade') double projectedGrade,@JsonKey(name: 'market_value_at_grade') double marketValueAtGrade,@JsonKey(name: 'net_profit') double netProfit,@JsonKey(name: 'break_even_grade') double breakEvenGrade
});




}
/// @nodoc
class _$EstimateOutputsCopyWithImpl<$Res>
    implements $EstimateOutputsCopyWith<$Res> {
  _$EstimateOutputsCopyWithImpl(this._self, this._then);

  final EstimateOutputs _self;
  final $Res Function(EstimateOutputs) _then;

/// Create a copy of EstimateOutputs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectedGrade = null,Object? marketValueAtGrade = null,Object? netProfit = null,Object? breakEvenGrade = null,}) {
  return _then(_self.copyWith(
projectedGrade: null == projectedGrade ? _self.projectedGrade : projectedGrade // ignore: cast_nullable_to_non_nullable
as double,marketValueAtGrade: null == marketValueAtGrade ? _self.marketValueAtGrade : marketValueAtGrade // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,breakEvenGrade: null == breakEvenGrade ? _self.breakEvenGrade : breakEvenGrade // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EstimateOutputs].
extension EstimateOutputsPatterns on EstimateOutputs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstimateOutputs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstimateOutputs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstimateOutputs value)  $default,){
final _that = this;
switch (_that) {
case _EstimateOutputs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstimateOutputs value)?  $default,){
final _that = this;
switch (_that) {
case _EstimateOutputs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'projected_grade')  double projectedGrade, @JsonKey(name: 'market_value_at_grade')  double marketValueAtGrade, @JsonKey(name: 'net_profit')  double netProfit, @JsonKey(name: 'break_even_grade')  double breakEvenGrade)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstimateOutputs() when $default != null:
return $default(_that.projectedGrade,_that.marketValueAtGrade,_that.netProfit,_that.breakEvenGrade);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'projected_grade')  double projectedGrade, @JsonKey(name: 'market_value_at_grade')  double marketValueAtGrade, @JsonKey(name: 'net_profit')  double netProfit, @JsonKey(name: 'break_even_grade')  double breakEvenGrade)  $default,) {final _that = this;
switch (_that) {
case _EstimateOutputs():
return $default(_that.projectedGrade,_that.marketValueAtGrade,_that.netProfit,_that.breakEvenGrade);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'projected_grade')  double projectedGrade, @JsonKey(name: 'market_value_at_grade')  double marketValueAtGrade, @JsonKey(name: 'net_profit')  double netProfit, @JsonKey(name: 'break_even_grade')  double breakEvenGrade)?  $default,) {final _that = this;
switch (_that) {
case _EstimateOutputs() when $default != null:
return $default(_that.projectedGrade,_that.marketValueAtGrade,_that.netProfit,_that.breakEvenGrade);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EstimateOutputs implements EstimateOutputs {
  const _EstimateOutputs({@JsonKey(name: 'projected_grade') required this.projectedGrade, @JsonKey(name: 'market_value_at_grade') required this.marketValueAtGrade, @JsonKey(name: 'net_profit') required this.netProfit, @JsonKey(name: 'break_even_grade') required this.breakEvenGrade});
  factory _EstimateOutputs.fromJson(Map<String, dynamic> json) => _$EstimateOutputsFromJson(json);

@override@JsonKey(name: 'projected_grade') final  double projectedGrade;
@override@JsonKey(name: 'market_value_at_grade') final  double marketValueAtGrade;
@override@JsonKey(name: 'net_profit') final  double netProfit;
@override@JsonKey(name: 'break_even_grade') final  double breakEvenGrade;

/// Create a copy of EstimateOutputs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstimateOutputsCopyWith<_EstimateOutputs> get copyWith => __$EstimateOutputsCopyWithImpl<_EstimateOutputs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EstimateOutputsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstimateOutputs&&(identical(other.projectedGrade, projectedGrade) || other.projectedGrade == projectedGrade)&&(identical(other.marketValueAtGrade, marketValueAtGrade) || other.marketValueAtGrade == marketValueAtGrade)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.breakEvenGrade, breakEvenGrade) || other.breakEvenGrade == breakEvenGrade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectedGrade,marketValueAtGrade,netProfit,breakEvenGrade);

@override
String toString() {
  return 'EstimateOutputs(projectedGrade: $projectedGrade, marketValueAtGrade: $marketValueAtGrade, netProfit: $netProfit, breakEvenGrade: $breakEvenGrade)';
}


}

/// @nodoc
abstract mixin class _$EstimateOutputsCopyWith<$Res> implements $EstimateOutputsCopyWith<$Res> {
  factory _$EstimateOutputsCopyWith(_EstimateOutputs value, $Res Function(_EstimateOutputs) _then) = __$EstimateOutputsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'projected_grade') double projectedGrade,@JsonKey(name: 'market_value_at_grade') double marketValueAtGrade,@JsonKey(name: 'net_profit') double netProfit,@JsonKey(name: 'break_even_grade') double breakEvenGrade
});




}
/// @nodoc
class __$EstimateOutputsCopyWithImpl<$Res>
    implements _$EstimateOutputsCopyWith<$Res> {
  __$EstimateOutputsCopyWithImpl(this._self, this._then);

  final _EstimateOutputs _self;
  final $Res Function(_EstimateOutputs) _then;

/// Create a copy of EstimateOutputs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectedGrade = null,Object? marketValueAtGrade = null,Object? netProfit = null,Object? breakEvenGrade = null,}) {
  return _then(_EstimateOutputs(
projectedGrade: null == projectedGrade ? _self.projectedGrade : projectedGrade // ignore: cast_nullable_to_non_nullable
as double,marketValueAtGrade: null == marketValueAtGrade ? _self.marketValueAtGrade : marketValueAtGrade // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,breakEvenGrade: null == breakEvenGrade ? _self.breakEvenGrade : breakEvenGrade // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$SubmissionEstimate {

 String get id;@JsonKey(name: 'user_uid') String get userUid;/// Reference to /cards/{cardId}
@JsonKey(name: 'card_ref')@DocumentReferenceConverter() DocumentReference get cardRef; EstimateInputs get inputs; EstimateOutputs? get outputs;@JsonKey(name: 'created_at')@TimestampConverter() DateTime? get createdAt;
/// Create a copy of SubmissionEstimate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmissionEstimateCopyWith<SubmissionEstimate> get copyWith => _$SubmissionEstimateCopyWithImpl<SubmissionEstimate>(this as SubmissionEstimate, _$identity);

  /// Serializes this SubmissionEstimate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmissionEstimate&&(identical(other.id, id) || other.id == id)&&(identical(other.userUid, userUid) || other.userUid == userUid)&&(identical(other.cardRef, cardRef) || other.cardRef == cardRef)&&(identical(other.inputs, inputs) || other.inputs == inputs)&&(identical(other.outputs, outputs) || other.outputs == outputs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userUid,cardRef,inputs,outputs,createdAt);

@override
String toString() {
  return 'SubmissionEstimate(id: $id, userUid: $userUid, cardRef: $cardRef, inputs: $inputs, outputs: $outputs, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SubmissionEstimateCopyWith<$Res>  {
  factory $SubmissionEstimateCopyWith(SubmissionEstimate value, $Res Function(SubmissionEstimate) _then) = _$SubmissionEstimateCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_uid') String userUid,@JsonKey(name: 'card_ref')@DocumentReferenceConverter() DocumentReference cardRef, EstimateInputs inputs, EstimateOutputs? outputs,@JsonKey(name: 'created_at')@TimestampConverter() DateTime? createdAt
});


$EstimateInputsCopyWith<$Res> get inputs;$EstimateOutputsCopyWith<$Res>? get outputs;

}
/// @nodoc
class _$SubmissionEstimateCopyWithImpl<$Res>
    implements $SubmissionEstimateCopyWith<$Res> {
  _$SubmissionEstimateCopyWithImpl(this._self, this._then);

  final SubmissionEstimate _self;
  final $Res Function(SubmissionEstimate) _then;

/// Create a copy of SubmissionEstimate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userUid = null,Object? cardRef = null,Object? inputs = null,Object? outputs = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userUid: null == userUid ? _self.userUid : userUid // ignore: cast_nullable_to_non_nullable
as String,cardRef: null == cardRef ? _self.cardRef : cardRef // ignore: cast_nullable_to_non_nullable
as DocumentReference,inputs: null == inputs ? _self.inputs : inputs // ignore: cast_nullable_to_non_nullable
as EstimateInputs,outputs: freezed == outputs ? _self.outputs : outputs // ignore: cast_nullable_to_non_nullable
as EstimateOutputs?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SubmissionEstimate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstimateInputsCopyWith<$Res> get inputs {
  
  return $EstimateInputsCopyWith<$Res>(_self.inputs, (value) {
    return _then(_self.copyWith(inputs: value));
  });
}/// Create a copy of SubmissionEstimate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstimateOutputsCopyWith<$Res>? get outputs {
    if (_self.outputs == null) {
    return null;
  }

  return $EstimateOutputsCopyWith<$Res>(_self.outputs!, (value) {
    return _then(_self.copyWith(outputs: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubmissionEstimate].
extension SubmissionEstimatePatterns on SubmissionEstimate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmissionEstimate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmissionEstimate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmissionEstimate value)  $default,){
final _that = this;
switch (_that) {
case _SubmissionEstimate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmissionEstimate value)?  $default,){
final _that = this;
switch (_that) {
case _SubmissionEstimate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_uid')  String userUid, @JsonKey(name: 'card_ref')@DocumentReferenceConverter()  DocumentReference cardRef,  EstimateInputs inputs,  EstimateOutputs? outputs, @JsonKey(name: 'created_at')@TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmissionEstimate() when $default != null:
return $default(_that.id,_that.userUid,_that.cardRef,_that.inputs,_that.outputs,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_uid')  String userUid, @JsonKey(name: 'card_ref')@DocumentReferenceConverter()  DocumentReference cardRef,  EstimateInputs inputs,  EstimateOutputs? outputs, @JsonKey(name: 'created_at')@TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SubmissionEstimate():
return $default(_that.id,_that.userUid,_that.cardRef,_that.inputs,_that.outputs,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_uid')  String userUid, @JsonKey(name: 'card_ref')@DocumentReferenceConverter()  DocumentReference cardRef,  EstimateInputs inputs,  EstimateOutputs? outputs, @JsonKey(name: 'created_at')@TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SubmissionEstimate() when $default != null:
return $default(_that.id,_that.userUid,_that.cardRef,_that.inputs,_that.outputs,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubmissionEstimate implements SubmissionEstimate {
  const _SubmissionEstimate({required this.id, @JsonKey(name: 'user_uid') required this.userUid, @JsonKey(name: 'card_ref')@DocumentReferenceConverter() required this.cardRef, required this.inputs, this.outputs, @JsonKey(name: 'created_at')@TimestampConverter() this.createdAt});
  factory _SubmissionEstimate.fromJson(Map<String, dynamic> json) => _$SubmissionEstimateFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_uid') final  String userUid;
/// Reference to /cards/{cardId}
@override@JsonKey(name: 'card_ref')@DocumentReferenceConverter() final  DocumentReference cardRef;
@override final  EstimateInputs inputs;
@override final  EstimateOutputs? outputs;
@override@JsonKey(name: 'created_at')@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of SubmissionEstimate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmissionEstimateCopyWith<_SubmissionEstimate> get copyWith => __$SubmissionEstimateCopyWithImpl<_SubmissionEstimate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmissionEstimateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmissionEstimate&&(identical(other.id, id) || other.id == id)&&(identical(other.userUid, userUid) || other.userUid == userUid)&&(identical(other.cardRef, cardRef) || other.cardRef == cardRef)&&(identical(other.inputs, inputs) || other.inputs == inputs)&&(identical(other.outputs, outputs) || other.outputs == outputs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userUid,cardRef,inputs,outputs,createdAt);

@override
String toString() {
  return 'SubmissionEstimate(id: $id, userUid: $userUid, cardRef: $cardRef, inputs: $inputs, outputs: $outputs, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SubmissionEstimateCopyWith<$Res> implements $SubmissionEstimateCopyWith<$Res> {
  factory _$SubmissionEstimateCopyWith(_SubmissionEstimate value, $Res Function(_SubmissionEstimate) _then) = __$SubmissionEstimateCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_uid') String userUid,@JsonKey(name: 'card_ref')@DocumentReferenceConverter() DocumentReference cardRef, EstimateInputs inputs, EstimateOutputs? outputs,@JsonKey(name: 'created_at')@TimestampConverter() DateTime? createdAt
});


@override $EstimateInputsCopyWith<$Res> get inputs;@override $EstimateOutputsCopyWith<$Res>? get outputs;

}
/// @nodoc
class __$SubmissionEstimateCopyWithImpl<$Res>
    implements _$SubmissionEstimateCopyWith<$Res> {
  __$SubmissionEstimateCopyWithImpl(this._self, this._then);

  final _SubmissionEstimate _self;
  final $Res Function(_SubmissionEstimate) _then;

/// Create a copy of SubmissionEstimate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userUid = null,Object? cardRef = null,Object? inputs = null,Object? outputs = freezed,Object? createdAt = freezed,}) {
  return _then(_SubmissionEstimate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userUid: null == userUid ? _self.userUid : userUid // ignore: cast_nullable_to_non_nullable
as String,cardRef: null == cardRef ? _self.cardRef : cardRef // ignore: cast_nullable_to_non_nullable
as DocumentReference,inputs: null == inputs ? _self.inputs : inputs // ignore: cast_nullable_to_non_nullable
as EstimateInputs,outputs: freezed == outputs ? _self.outputs : outputs // ignore: cast_nullable_to_non_nullable
as EstimateOutputs?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SubmissionEstimate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstimateInputsCopyWith<$Res> get inputs {
  
  return $EstimateInputsCopyWith<$Res>(_self.inputs, (value) {
    return _then(_self.copyWith(inputs: value));
  });
}/// Create a copy of SubmissionEstimate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstimateOutputsCopyWith<$Res>? get outputs {
    if (_self.outputs == null) {
    return null;
  }

  return $EstimateOutputsCopyWith<$Res>(_self.outputs!, (value) {
    return _then(_self.copyWith(outputs: value));
  });
}
}

// dart format on
