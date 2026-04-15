// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_estimate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EstimateInputs _$EstimateInputsFromJson(Map<String, dynamic> json) =>
    _EstimateInputs(
      currentCondition: $enumDecode(
        _$RawConditionEnumMap,
        json['current_condition'],
      ),
      grader: $enumDecode(_$GraderEnumMap, json['grader']),
      gradingFee: (json['grading_fee'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
    );

Map<String, dynamic> _$EstimateInputsToJson(_EstimateInputs instance) =>
    <String, dynamic>{
      'current_condition': _$RawConditionEnumMap[instance.currentCondition]!,
      'grader': _$GraderEnumMap[instance.grader]!,
      'grading_fee': instance.gradingFee,
      'shipping_cost': instance.shippingCost,
    };

const _$RawConditionEnumMap = {
  RawCondition.nm: 'nm',
  RawCondition.lp: 'lp',
  RawCondition.mp: 'mp',
  RawCondition.hp: 'hp',
  RawCondition.dmg: 'dmg',
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

_EstimateOutputs _$EstimateOutputsFromJson(Map<String, dynamic> json) =>
    _EstimateOutputs(
      projectedGrade: (json['projected_grade'] as num).toDouble(),
      marketValueAtGrade: (json['market_value_at_grade'] as num).toDouble(),
      netProfit: (json['net_profit'] as num).toDouble(),
      breakEvenGrade: (json['break_even_grade'] as num).toDouble(),
    );

Map<String, dynamic> _$EstimateOutputsToJson(_EstimateOutputs instance) =>
    <String, dynamic>{
      'projected_grade': instance.projectedGrade,
      'market_value_at_grade': instance.marketValueAtGrade,
      'net_profit': instance.netProfit,
      'break_even_grade': instance.breakEvenGrade,
    };

_SubmissionEstimate _$SubmissionEstimateFromJson(Map<String, dynamic> json) =>
    _SubmissionEstimate(
      id: json['id'] as String,
      userUid: json['user_uid'] as String,
      cardRef: const DocumentReferenceConverter().fromJson(
        json['card_ref'] as Object,
      ),
      inputs: EstimateInputs.fromJson(json['inputs'] as Map<String, dynamic>),
      outputs: json['outputs'] == null
          ? null
          : EstimateOutputs.fromJson(json['outputs'] as Map<String, dynamic>),
      createdAt: const TimestampConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$SubmissionEstimateToJson(_SubmissionEstimate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_uid': instance.userUid,
      'card_ref': const DocumentReferenceConverter().toJson(instance.cardRef),
      'inputs': instance.inputs,
      'outputs': instance.outputs,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
    };
