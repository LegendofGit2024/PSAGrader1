import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/card.dart';
import '../models/collection_item.dart';
import '../models/submission_estimate.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart' show currentUidProvider;
import 'connect_provider.dart' show publishSubmissionEvent;

export '../models/collection_item.dart' show Grader, RawCondition;
export '../models/submission_estimate.dart';

part 'submission_provider.g.dart';

// ---------------------------------------------------------------------------
// Formula constants (2026 baseline)
// ---------------------------------------------------------------------------

/// eBay / marketplace seller fee (13.25% + $0.40 flat)
const kSellerFeePct  = 0.1325;
const kSellerFeeFlat = 0.40;

/// USD → GBP exchange rate (updated via Remote Config in production)
const kUsdToGbp = 0.79;

/// Grade multiplier curve vs PSA 10 eBay baseline
final kGradeCurve = <double, double>{
  10.0: 1.00, 9.5: 0.72, 9.0: 0.55, 8.5: 0.42, 8.0: 0.32,
  7.5: 0.25,  7.0: 0.20, 6.5: 0.15, 6.0: 0.12, 5.0: 0.08,
  4.0: 0.06,  3.0: 0.04, 2.0: 0.03, 1.0: 0.02,
};

/// Market value multipliers — a PSA 10 = 1.0×; other graders trade at a discount.
/// CGC Pristine 10 gets an extra 1.1× on top of the base.
const Map<Grader, double> kGraderMultipliers = {
  Grader.psa: 1.00,
  Grader.bgs: 0.875,
  Grader.cgc: 0.875,   // Pristine 10 handled separately (+10%)
  Grader.tag: 0.80,
  Grader.ace: 0.75,    // UK market uses 0.90×; toggled via currency mode
  Grader.ark: 0.75,
  Grader.egc: 0.70,
};

// ---------------------------------------------------------------------------
// Grader fee tables
// ---------------------------------------------------------------------------

/// [Grader] → { tier label → fee in native currency }
const Map<Grader, Map<String, double>> kGraderFees = {
  Grader.psa: {'Value': 25, 'Economy': 20, 'Regular': 50, 'WalkThrough': 150},
  Grader.bgs: {'Standard': 30, 'Express': 75, 'Premium': 150},
  Grader.cgc: {'Standard': 25, 'Express': 65, 'WalkThrough': 150},
  Grader.tag: {'Standard': 20, 'Express': 50},
  Grader.ace: {'Standard': 15, 'Express': 35},   // GBP
  Grader.ark: {'Standard': 18, 'Express': 45},
  Grader.egc: {'Standard': 15, 'Express': 40},
};

const Map<Grader, double> kDefaultFees = {
  Grader.psa: 25, Grader.bgs: 30, Grader.cgc: 25,
  Grader.tag: 20, Grader.ace: 15, Grader.ark: 18, Grader.egc: 15,
};

/// Default domestic shipping + insurance per grader
const Map<Grader, double> kDefaultShipping = {
  Grader.psa: 30, Grader.bgs: 30, Grader.cgc: 30,
  Grader.tag: 15, Grader.ace: 12, // £12
  Grader.ark: 20, Grader.egc: 15,
};

/// Currency symbol per grader
const Map<Grader, String> kGraderCurrency = {
  Grader.psa: 'USD', Grader.bgs: 'USD', Grader.cgc: 'USD',
  Grader.tag: 'USD', Grader.ace: 'GBP',
  Grader.ark: 'USD', Grader.egc: 'USD',
};

/// Whether a grader uses the UK market multiplier (ACE when in GBP mode)
bool isUkGrader(Grader g) => g == Grader.ace;

// ---------------------------------------------------------------------------
// Vintage set detection (affects probable grade badge)
// ---------------------------------------------------------------------------

const _vintagePrefixes = {
  'base', 'jungle', 'fossil', 'team-rocket', 'gym', 'neo',
  'e-card', 'legendary-collection', 'expedition',
};

bool isVintageSet(String setId) =>
    _vintagePrefixes.any((p) => setId.toLowerCase().startsWith(p));

/// "Probable Grade" = what the card is most likely to receive
double probableGrade(String setId) => isVintageSet(setId) ? 8.0 : 9.0;

// ---------------------------------------------------------------------------
// Gem Rate
// ---------------------------------------------------------------------------

/// Gem Rate = PSA 10s / total pop.  Returns null if pop data unavailable.
double? gemRate(PsaPop? pop) {
  if (pop == null || pop.totalPop == null || pop.totalPop! == 0) return null;
  final grade10s = pop.pop10 ?? 0;
  return grade10s / pop.totalPop!;
}

// ---------------------------------------------------------------------------
// Core ROI formula (2026 adjusted)
// ---------------------------------------------------------------------------

class RoiEngine {
  /// Net Profit = (Market Value × (1 − sellerFeePct)) − sellerFeeFlat
  ///              − (Cost Basis + Grading Fee + Shipping)
  static double netProfit({
    required double marketValue,
    required double costBasis,
    required double gradingFee,
    required double shippingCost,
    double sellerFeePct = kSellerFeePct,
    double sellerFeeFlat = kSellerFeeFlat,
  }) =>
      (marketValue * (1 - sellerFeePct)) -
      sellerFeeFlat -
      (costBasis + gradingFee + shippingCost);

  /// Break-even: lowest grade where netProfit ≥ 0
  static double? breakEvenGrade({
    required Map<double, double> gradePriceMap,
    required double costBasis,
    required double gradingFee,
    required double shippingCost,
  }) {
    final grades = gradePriceMap.keys.toList()..sort();
    for (final g in grades) {
      final price = gradePriceMap[g]!;
      if (netProfit(
            marketValue: price,
            costBasis: costBasis,
            gradingFee: gradingFee,
            shippingCost: shippingCost,
          ) >=
          0) return g;
    }
    return null;
  }

  /// Net profit for every grade in the map
  static Map<double, double> profitByGrade({
    required Map<double, double> gradePriceMap,
    required double costBasis,
    required double gradingFee,
    required double shippingCost,
  }) =>
      {
        for (final e in gradePriceMap.entries)
          e.key: netProfit(
            marketValue: e.value,
            costBasis: costBasis,
            gradingFee: gradingFee,
            shippingCost: shippingCost,
          )
      };

  /// Verdict based on break-even grade:
  ///   GREEN (go)   — break-even < 8  → even a grade 8 is profitable
  ///   YELLOW (risk) — break-even = 9  → profitable only at 9+
  ///   RED (stop)   — break-even = 10 or null → only profitable at gem mint / never
  static SubmitVerdict verdict({required double? breakEvenGrade}) {
    if (breakEvenGrade == null || breakEvenGrade >= 10) return SubmitVerdict.stop;
    if (breakEvenGrade <= 8) return SubmitVerdict.go;
    return SubmitVerdict.risk; // 8 < beg < 10
  }
}

enum SubmitVerdict { go, risk, stop }

// ---------------------------------------------------------------------------
// Break-even risk label (for matrix table)
// ---------------------------------------------------------------------------

enum BreakEvenRisk { veryLow, low, medium, high, extreme }

BreakEvenRisk breakEvenRisk(double? beg) {
  if (beg == null) return BreakEvenRisk.extreme;
  if (beg <= 7) return BreakEvenRisk.veryLow;
  if (beg <= 8) return BreakEvenRisk.low;
  if (beg <= 9) return BreakEvenRisk.medium;
  if (beg < 10) return BreakEvenRisk.high;
  return BreakEvenRisk.extreme;
}

String breakEvenRiskLabel(BreakEvenRisk r) => switch (r) {
      BreakEvenRisk.veryLow => 'Very Low',
      BreakEvenRisk.low     => 'Low',
      BreakEvenRisk.medium  => 'Medium',
      BreakEvenRisk.high    => 'High',
      BreakEvenRisk.extreme => 'Extreme',
    };

// ---------------------------------------------------------------------------
// Per-grader ROI result (one row in the matrix table)
// ---------------------------------------------------------------------------

class GraderROIResult {
  const GraderROIResult({
    required this.grader,
    required this.tier,
    required this.gradingFee,
    required this.currency,
    required this.shippingCost,
    required this.marketValueAtTarget,
    this.marketValueAtGrade9,
    required this.netProfitAtTarget,
    this.netProfitAtGrade9,
    this.breakEvenGrade,
    required this.risk,
    this.gradePriceMap = const {},
    this.profitByGrade = const {},
  });

  final Grader grader;
  final String tier;
  final double gradingFee;

  /// 'USD' or 'GBP'
  final String currency;
  final double shippingCost;

  /// Market value at the user's selected target grade (8/9/10)
  final double marketValueAtTarget;

  /// Market value if card comes back a 9 (for "Calculate for the 9" toggle)
  final double? marketValueAtGrade9;

  final double netProfitAtTarget;
  final double? netProfitAtGrade9;
  final double? breakEvenGrade;
  final BreakEvenRisk risk;

  /// Full grade→price map (used by single-grader chart)
  final Map<double, double> gradePriceMap;
  final Map<double, double> profitByGrade;
}

// ---------------------------------------------------------------------------
// User input state
// ---------------------------------------------------------------------------

class EstimatorInput {
  const EstimatorInput({
    this.cardId,
    this.costBasis = 0,
    this.targetGrade = 10,
    this.isManualMode = false,
    this.calculateForNine = false,
    this.showUkPrices = false,
    this.psaClubMember = false,
    this.tagDigitalReport = false,
    this.aceColorMatchLabel = AceLabelUpgrade.none,
    this.cgcPristineMode = false,
  });

  final String? cardId;
  final double costBasis;

  /// Target grade for the matrix: 8, 9, or 10
  final double targetGrade;

  final bool isManualMode;

  /// "Calculate for the 9" toggle
  final bool calculateForNine;

  /// Show ACE in GBP / use UK market multiplier
  final bool showUkPrices;

  /// PSA Collectors Club member — reduces PSA fee by $5/card
  final bool psaClubMember;

  /// TAG Digital Grading Report add-on (+$5)
  final bool tagDigitalReport;

  /// ACE label upgrade
  final AceLabelUpgrade aceColorMatchLabel;

  /// CGC Pristine 10 mode — applies 1.1× premium to CGC grade 10 price
  final bool cgcPristineMode;

  EstimatorInput copyWith({
    String? cardId,
    double? costBasis,
    double? targetGrade,
    bool? isManualMode,
    bool? calculateForNine,
    bool? showUkPrices,
    bool? psaClubMember,
    bool? tagDigitalReport,
    AceLabelUpgrade? aceColorMatchLabel,
    bool? cgcPristineMode,
  }) =>
      EstimatorInput(
        cardId: cardId ?? this.cardId,
        costBasis: costBasis ?? this.costBasis,
        targetGrade: targetGrade ?? this.targetGrade,
        isManualMode: isManualMode ?? this.isManualMode,
        calculateForNine: calculateForNine ?? this.calculateForNine,
        showUkPrices: showUkPrices ?? this.showUkPrices,
        psaClubMember: psaClubMember ?? this.psaClubMember,
        tagDigitalReport: tagDigitalReport ?? this.tagDigitalReport,
        aceColorMatchLabel: aceColorMatchLabel ?? this.aceColorMatchLabel,
        cgcPristineMode: cgcPristineMode ?? this.cgcPristineMode,
      );
}

enum AceLabelUpgrade {
  none,
  colorMatch,  // +£1
  aceLabel,    // +£3
}

double aceLabelFee(AceLabelUpgrade upgrade) => switch (upgrade) {
      AceLabelUpgrade.none       => 0,
      AceLabelUpgrade.colorMatch => 1,
      AceLabelUpgrade.aceLabel   => 3,
    };

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class EstimatorInputNotifier extends _$EstimatorInputNotifier {
  @override
  EstimatorInput build() => const EstimatorInput();

  void setCard(String cardId) => state = state.copyWith(cardId: cardId);
  void setCostBasis(double v) => state = state.copyWith(costBasis: v);
  void setTargetGrade(double v) => state = state.copyWith(targetGrade: v);
  void toggleManualMode() =>
      state = state.copyWith(isManualMode: !state.isManualMode);
  void toggleCalculateForNine() =>
      state = state.copyWith(calculateForNine: !state.calculateForNine);
  void toggleUkPrices() =>
      state = state.copyWith(showUkPrices: !state.showUkPrices);
  void togglePsaClub() =>
      state = state.copyWith(psaClubMember: !state.psaClubMember);
  void toggleTagReport() =>
      state = state.copyWith(tagDigitalReport: !state.tagDigitalReport);
  void setAceLabel(AceLabelUpgrade v) =>
      state = state.copyWith(aceColorMatchLabel: v);
  void toggleCgcPristine() =>
      state = state.copyWith(cgcPristineMode: !state.cgcPristineMode);
}

// ---------------------------------------------------------------------------
// Resolved card
// ---------------------------------------------------------------------------

@riverpod
Future<CardDocument?> estimatorCard(Ref ref) {
  final cardId = ref.watch(estimatorInputProvider).cardId;
  if (cardId == null || cardId.isEmpty) return Future.value(null);
  return ref.watch(firestoreServiceProvider).getCard(cardId);
}

// ---------------------------------------------------------------------------
// Grade price map for a specific grader
// ---------------------------------------------------------------------------

Map<double, double> _buildGradePriceMap({
  required double base,
  required Grader grader,
  required bool cgcPristine,
  required bool ukMode,
}) {
  final multiplier = isUkGrader(grader) && ukMode
      ? 0.90
      : kGraderMultipliers[grader] ?? 1.0;

  return {
    for (final e in kGradeCurve.entries)
      e.key: () {
        double price = base * e.value * multiplier;
        // CGC Pristine 10 premium
        if (grader == Grader.cgc && cgcPristine && e.key == 10) {
          price *= 1.10;
        }
        // ACE: convert to GBP if needed
        if (isUkGrader(grader)) price *= kUsdToGbp;
        return price;
      }(),
  };
}

// ---------------------------------------------------------------------------
// Per-grader ROI result
// ---------------------------------------------------------------------------

GraderROIResult _computeGraderROI({
  required CardDocument card,
  required Grader grader,
  required EstimatorInput input,
}) {
  final base = card.pricing.ebayUs?.lastSoldNm ?? 0;
  final currency = isUkGrader(grader) ? 'GBP' : 'USD';

  // Fee calculation with add-ons
  double fee = kDefaultFees[grader] ?? 20;
  if (grader == Grader.psa && input.psaClubMember) fee -= 5;
  if (grader == Grader.tag && input.tagDigitalReport) fee += 5;
  if (grader == Grader.ace) fee += aceLabelFee(input.aceColorMatchLabel);

  double shipping = kDefaultShipping[grader] ?? 20;

  // Cost basis — convert to GBP for ACE if needed
  double costBasis = input.costBasis;
  if (isUkGrader(grader)) costBasis *= kUsdToGbp;

  final priceMap = _buildGradePriceMap(
    base: base,
    grader: grader,
    cgcPristine: input.cgcPristineMode,
    ukMode: input.showUkPrices,
  );

  final profitMap = RoiEngine.profitByGrade(
    gradePriceMap: priceMap,
    costBasis: costBasis,
    gradingFee: fee,
    shippingCost: shipping,
  );

  final beg = RoiEngine.breakEvenGrade(
    gradePriceMap: priceMap,
    costBasis: costBasis,
    gradingFee: fee,
    shippingCost: shipping,
  );

  final targetPrice = priceMap[input.targetGrade] ?? 0;
  final grade9Price = priceMap[9.0];

  return GraderROIResult(
    grader: grader,
    tier: grader == Grader.psa
        ? (input.psaClubMember ? 'Value (Club)' : 'Value')
        : grader == Grader.tag && input.tagDigitalReport
            ? 'Standard + Report'
            : grader == Grader.ace &&
                    input.aceColorMatchLabel != AceLabelUpgrade.none
                ? 'Standard + Label'
                : 'Standard',
    gradingFee: fee,
    currency: currency,
    shippingCost: shipping,
    marketValueAtTarget: targetPrice,
    marketValueAtGrade9: grade9Price,
    netProfitAtTarget: profitMap[input.targetGrade] ?? 0,
    netProfitAtGrade9:
        grade9Price != null ? profitMap[9.0] : null,
    breakEvenGrade: beg,
    risk: breakEvenRisk(beg),
    gradePriceMap: priceMap,
    profitByGrade: profitMap,
  );
}

// ---------------------------------------------------------------------------
// Full matrix result (all graders)
// ---------------------------------------------------------------------------

class MatrixResult {
  const MatrixResult({
    required this.input,
    required this.card,
    required this.rows,
    required this.gemRate,
    required this.probableGrade,
  });

  final EstimatorInput input;
  final CardDocument card;
  final List<GraderROIResult> rows;
  final double? gemRate;
  final double probableGrade;

  /// Best grader by net profit at target grade
  GraderROIResult? get bestGrader {
    if (rows.isEmpty) return null;
    return rows.reduce(
        (a, b) => a.netProfitAtTarget >= b.netProfitAtTarget ? a : b);
  }

  /// Overall verdict based on best grader's break-even
  SubmitVerdict get verdict =>
      RoiEngine.verdict(breakEvenGrade: bestGrader?.breakEvenGrade);
}

@riverpod
Future<MatrixResult?> submissionMatrix(Ref ref) async {
  final input = ref.watch(estimatorInputProvider);
  if (input.cardId == null || input.cardId!.isEmpty) return null;

  final card = await ref.watch(estimatorCardProvider.future);
  if (card == null) return null;

  final rows = Grader.values
      .map((g) => _computeGraderROI(card: card, grader: g, input: input))
      .toList();

  return MatrixResult(
    input: input,
    card: card,
    rows: rows,
    gemRate: gemRate(card.psaPop),
    probableGrade: probableGrade(card.meta.setId),
  );
}

// ---------------------------------------------------------------------------
// Save estimate
// ---------------------------------------------------------------------------

@riverpod
class SaveEstimate extends _$SaveEstimate {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> save(MatrixResult result) async {
    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    final fs = ref.read(firestoreServiceProvider);
    final best = result.bestGrader;
    if (best == null) return;

    final inputs = EstimateInputs(
      currentCondition: RawCondition.nm,
      grader: best.grader,
      gradingFee: best.gradingFee,
      shippingCost: best.shippingCost,
    );

    final outputs = EstimateOutputs(
      projectedGrade: result.input.targetGrade,
      marketValueAtGrade: best.marketValueAtTarget,
      netProfit: best.netProfitAtTarget,
      breakEvenGrade: best.breakEvenGrade ?? 0,
    );

    state = await AsyncValue.guard(() async {
      await fs.saveEstimate(SubmissionEstimate(
        id: '',
        userUid: uid,
        cardRef: FirestoreService.cardRef(result.card.id),
        inputs: inputs,
        outputs: outputs,
        createdAt: DateTime.now(),
      ));

      // Publish to the Connect activity feed (fire-and-forget; never block save)
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        publishSubmissionEvent(
          uid: uid,
          displayName: fbUser.displayName ?? 'Collector',
          avatarUrl: fbUser.photoURL,
          cardName: result.card.meta.name,
          graderLabel: best.grader.name.toUpperCase(),
          estimatedValue: best.marketValueAtTarget,
        ).ignore();
      }
    });
  }
}
