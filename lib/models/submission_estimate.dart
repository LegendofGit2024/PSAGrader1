import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'card.dart' show DocumentReferenceConverter, TimestampConverter;
import 'collection_item.dart' show Grader, RawCondition;

part 'submission_estimate.freezed.dart';
part 'submission_estimate.g.dart';

// ---------------------------------------------------------------------------
// Input parameters provided by the user
// ---------------------------------------------------------------------------

@freezed
abstract class EstimateInputs with _$EstimateInputs {
  const factory EstimateInputs({
    @JsonKey(name: 'current_condition') required RawCondition currentCondition,
    required Grader grader,
    @JsonKey(name: 'grading_fee') required double gradingFee,
    @JsonKey(name: 'shipping_cost') required double shippingCost,
  }) = _EstimateInputs;

  factory EstimateInputs.fromJson(Map<String, dynamic> json) =>
      _$EstimateInputsFromJson(json);
}

// ---------------------------------------------------------------------------
// Computed outputs
//
// Net Profit = (Market Value × 0.86) − (Cost Basis + Grading Fee + Shipping)
// Break-Even Grade = the minimum grade at which Net Profit >= 0
// ---------------------------------------------------------------------------

@freezed
abstract class EstimateOutputs with _$EstimateOutputs {
  const factory EstimateOutputs({
    @JsonKey(name: 'projected_grade') required double projectedGrade,
    @JsonKey(name: 'market_value_at_grade') required double marketValueAtGrade,
    @JsonKey(name: 'net_profit') required double netProfit,
    @JsonKey(name: 'break_even_grade') required double breakEvenGrade,
  }) = _EstimateOutputs;

  factory EstimateOutputs.fromJson(Map<String, dynamic> json) =>
      _$EstimateOutputsFromJson(json);

  /// Core ROI formula — applied in Cloud Function and mirrored here for
  /// instant client-side preview before the Function returns.
  static double calculateNetProfit({
    required double marketValue,
    required double costBasis,
    required double gradingFee,
    required double shippingCost,
  }) =>
      (marketValue * 0.86) - (costBasis + gradingFee + shippingCost);
}

// ---------------------------------------------------------------------------
// Root SubmissionEstimate document  (/submission_estimates/{estimateId})
// ---------------------------------------------------------------------------

@freezed
abstract class SubmissionEstimate with _$SubmissionEstimate {
  const factory SubmissionEstimate({
    required String id,
    @JsonKey(name: 'user_uid') required String userUid,

    /// Reference to /cards/{cardId}
    @JsonKey(name: 'card_ref') @DocumentReferenceConverter() required DocumentReference cardRef,

    required EstimateInputs inputs,
    EstimateOutputs? outputs,

    @JsonKey(name: 'created_at') @TimestampConverter() DateTime? createdAt,
  }) = _SubmissionEstimate;

  factory SubmissionEstimate.fromJson(Map<String, dynamic> json) =>
      _$SubmissionEstimateFromJson(json);

  factory SubmissionEstimate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubmissionEstimate.fromJson(data).copyWith(id: doc.id);
  }

  static Map<String, dynamic> toFirestore(SubmissionEstimate est) =>
      est.toJson()..remove('id');
}
