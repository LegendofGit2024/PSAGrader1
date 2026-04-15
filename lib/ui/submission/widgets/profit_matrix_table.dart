import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/collection_item.dart';
import '../../../providers/submission_provider.dart';
import '../../theme/app_theme.dart';

/// Horizontally-scrollable multi-grader profit comparison table.
///
/// Columns: Grader | Grade Fee | Shipping | Market Value | Net Profit | Risk
/// The row for the "best grader" (highest net profit at target) is highlighted.
class ProfitMatrixTable extends StatelessWidget {
  const ProfitMatrixTable({
    super.key,
    required this.rows,
    required this.targetGrade,
    required this.calculateForNine,
    this.bestGrader,
  });

  final List<GraderROIResult> rows;
  final double targetGrade;
  final bool calculateForNine;
  final Grader? bestGrader;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Icon(Icons.table_chart_rounded,
                size: 15, color: AppColors.accent),
            const SizedBox(width: 6),
            const Text(
              'Profit Matrix',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            _TargetGradeChip(grade: targetGrade),
          ],
        ),
        const SizedBox(height: 10),

        // Scrollable table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column headers
              _HeaderRow(calculateForNine: calculateForNine),
              const SizedBox(height: 4),
              // Data rows
              ...rows.asMap().entries.map((e) => _DataRow(
                    key: ValueKey(e.value.grader),
                    result: e.value,
                    isBest: e.value.grader == bestGrader,
                    calculateForNine: calculateForNine,
                    delay: Duration(milliseconds: 60 * e.key),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header row
// ---------------------------------------------------------------------------

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.calculateForNine});
  final bool calculateForNine;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderCell('Grader', width: 80),
        _HeaderCell('Fee', width: 64, align: TextAlign.right),
        _HeaderCell('Ship', width: 56, align: TextAlign.right),
        _HeaderCell('Market', width: 80, align: TextAlign.right),
        _HeaderCell('Profit', width: 80, align: TextAlign.right),
        if (calculateForNine)
          _HeaderCell('Profit@9', width: 80, align: TextAlign.right),
        _HeaderCell('Risk', width: 72, align: TextAlign.center),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(
    this.label, {
    required this.width,
    this.align = TextAlign.left,
  });
  final String label;
  final double width;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textDisabled,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data row
// ---------------------------------------------------------------------------

class _DataRow extends StatelessWidget {
  const _DataRow({
    super.key,
    required this.result,
    required this.isBest,
    required this.calculateForNine,
    required this.delay,
  });

  final GraderROIResult result;
  final bool isBest;
  final bool calculateForNine;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final profitColor = result.netProfitAtTarget >= 0
        ? AppColors.success
        : AppColors.danger;

    final profit9Color = result.netProfitAtGrade9 != null
        ? (result.netProfitAtGrade9! >= 0
            ? AppColors.success
            : AppColors.danger)
        : AppColors.textDisabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isBest
            ? AppColors.accent.withOpacity(0.08)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBest ? AppColors.accent.withOpacity(0.3) : AppColors.border,
          width: isBest ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Grader name + best badge
          SizedBox(
            width: 80,
            child: Row(
              children: [
                _GraderDot(result.grader),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _graderLabel(result.grader),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isBest ? FontWeight.w800 : FontWeight.w600,
                          color: isBest
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        result.currency,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fee
          _NumCell(
            value: result.gradingFee,
            width: 64,
            currency: result.currency,
            color: AppColors.textSecondary,
          ),

          // Shipping
          _NumCell(
            value: result.shippingCost,
            width: 56,
            currency: result.currency,
            color: AppColors.textSecondary,
          ),

          // Market value at target
          _NumCell(
            value: result.marketValueAtTarget,
            width: 80,
            currency: result.currency,
            color: AppColors.textPrimary,
            bold: true,
          ),

          // Net profit at target
          _NumCell(
            value: result.netProfitAtTarget,
            width: 80,
            currency: result.currency,
            color: profitColor,
            bold: true,
            showSign: true,
          ),

          // Profit at grade 9 (conditional)
          if (calculateForNine)
            _NumCell(
              value: result.netProfitAtGrade9 ?? 0,
              width: 80,
              currency: result.currency,
              color: result.netProfitAtGrade9 != null
                  ? profit9Color
                  : AppColors.textDisabled,
              showSign: true,
            ),

          // Risk chip
          SizedBox(
            width: 72,
            child: Center(
              child: _RiskChip(risk: result.risk),
            ),
          ),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 250.ms).slideX(begin: -0.03, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Numeric cell
// ---------------------------------------------------------------------------

class _NumCell extends StatelessWidget {
  const _NumCell({
    required this.value,
    required this.width,
    required this.currency,
    required this.color,
    this.bold = false,
    this.showSign = false,
  });

  final double value;
  final double width;
  final String currency;
  final Color color;
  final bool bold;
  final bool showSign;

  String _fmt(double v) {
    final sign = (showSign && v >= 0) ? '+' : '';
    final symbol = currency == 'GBP' ? '£' : '\$';
    return '$sign$symbol${v.abs().toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        _fmt(value),
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Risk chip
// ---------------------------------------------------------------------------

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.risk});
  final BreakEvenRisk risk;

  Color _color() => switch (risk) {
        BreakEvenRisk.veryLow => AppColors.success,
        BreakEvenRisk.low     => AppColors.success,
        BreakEvenRisk.medium  => AppColors.warning,
        BreakEvenRisk.high    => AppColors.danger,
        BreakEvenRisk.extreme => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        breakEvenRiskLabel(risk),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Target grade chip (header accessory)
// ---------------------------------------------------------------------------

class _TargetGradeChip extends StatelessWidget {
  const _TargetGradeChip({required this.grade});
  final double grade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Text(
        'Target: ${grade.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grader colour dot
// ---------------------------------------------------------------------------

class _GraderDot extends StatelessWidget {
  const _GraderDot(this.grader);
  final Grader grader;

  Color _color() => switch (grader) {
        Grader.psa => const Color(0xFF3B82F6),
        Grader.bgs => const Color(0xFF8B5CF6),
        Grader.cgc => const Color(0xFFF97316),
        Grader.tag => const Color(0xFF10B981),
        Grader.ace => const Color(0xFFEC4899),
        Grader.ark => const Color(0xFFEF4444),
        Grader.egc => const Color(0xFF06B6D4),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: _color(),
        shape: BoxShape.circle,
      ),
    );
  }
}

String _graderLabel(Grader g) => switch (g) {
      Grader.psa => 'PSA',
      Grader.bgs => 'BGS',
      Grader.cgc => 'CGC',
      Grader.tag => 'TAG',
      Grader.ace => 'ACE',
      Grader.ark => 'ARK',
      Grader.egc => 'EGC',
    };
