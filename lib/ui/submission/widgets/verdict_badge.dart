import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../providers/submission_provider.dart';
import '../../theme/app_theme.dart';

/// Decision verdict card for the Submission Estimator V2.
///
/// Three verdicts:
///   GO   (green) — break-even ≤ 8, profitable even on a rough grade
///   RISK (amber) — break-even = 9, need at least a 9 to profit
///   STOP (red)   — break-even = 10 or null, only viable at gem mint / never
///
/// When gem rate ≥ 20% and verdict is GO, a gold Gem-10 glow is applied.
class VerdictBadge extends StatelessWidget {
  const VerdictBadge({
    super.key,
    required this.matrix,
  });

  final MatrixResult matrix;

  bool get _isGemCandidate =>
      (matrix.gemRate ?? 0) >= 0.20 &&
      matrix.verdict == SubmitVerdict.go;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VerdictHeader(
          verdict: matrix.verdict,
          gemCandidate: _isGemCandidate,
        ),
        const SizedBox(height: 12),
        _BestGraderSummary(matrix: matrix),
        if (matrix.bestGrader?.breakEvenGrade != null) ...[
          const SizedBox(height: 10),
          _BreakEvenLine(
            breakEvenGrade: matrix.bestGrader!.breakEvenGrade!,
            targetGrade: matrix.input.targetGrade,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Verdict header
// ---------------------------------------------------------------------------

class _VerdictHeader extends StatefulWidget {
  const _VerdictHeader({
    required this.verdict,
    required this.gemCandidate,
  });
  final SubmitVerdict verdict;
  final bool gemCandidate;

  @override
  State<_VerdictHeader> createState() => _VerdictHeaderState();
}

class _VerdictHeaderState extends State<_VerdictHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.gemCandidate) _glowCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_VerdictHeader old) {
    super.didUpdateWidget(old);
    if (widget.gemCandidate && !old.gemCandidate) {
      _glowCtrl.repeat(reverse: true);
    } else if (!widget.gemCandidate && old.gemCandidate) {
      _glowCtrl.stop();
      _glowCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Color get _bgColor => switch (widget.verdict) {
        SubmitVerdict.go   => AppColors.success.withOpacity(0.12),
        SubmitVerdict.risk => AppColors.warning.withOpacity(0.12),
        SubmitVerdict.stop => AppColors.danger.withOpacity(0.10),
      };

  Color get _borderColor => switch (widget.verdict) {
        SubmitVerdict.go   => AppColors.success.withOpacity(0.40),
        SubmitVerdict.risk => AppColors.warning.withOpacity(0.40),
        SubmitVerdict.stop => AppColors.danger.withOpacity(0.30),
      };

  Color get _textColor => switch (widget.verdict) {
        SubmitVerdict.go   => AppColors.success,
        SubmitVerdict.risk => AppColors.warning,
        SubmitVerdict.stop => AppColors.danger,
      };

  IconData get _icon => switch (widget.verdict) {
        SubmitVerdict.go   => Icons.rocket_launch_rounded,
        SubmitVerdict.risk => Icons.balance_rounded,
        SubmitVerdict.stop => Icons.block_rounded,
      };

  String get _label => switch (widget.verdict) {
        SubmitVerdict.go   => 'GO',
        SubmitVerdict.risk => 'RISK',
        SubmitVerdict.stop => 'STOP',
      };

  String get _subtitle => switch (widget.verdict) {
        SubmitVerdict.go =>
          widget.gemCandidate
              ? 'Strong ROI + high gem rate — prime submission candidate.'
              : 'Strong ROI — profitable even at grade 8.',
        SubmitVerdict.risk =>
          'Thin margin — needs a 9 or better to cover costs.',
        SubmitVerdict.stop =>
          'Does not break even at projected grade. Raw exit may be better.',
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, child) {
        final glowOpacity = widget.gemCandidate
            ? 0.3 + _glowCtrl.value * 0.4
            : 0.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1.5),
            boxShadow: widget.gemCandidate
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(glowOpacity),
                      blurRadius: 24,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Icon(_icon, color: _textColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _label,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: _textColor,
                        letterSpacing: 1,
                      ),
                    ),
                    if (widget.gemCandidate) ...[
                      const SizedBox(width: 8),
                      _GemCandidateBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textColor.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
  }
}

// ---------------------------------------------------------------------------
// Gem candidate badge (shown when gem rate ≥ 20% and verdict = GO)
// ---------------------------------------------------------------------------

class _GemCandidateBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.85),
            AppColors.accent,
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded, size: 10, color: AppColors.background),
          SizedBox(width: 3),
          Text(
            'GEM CANDIDATE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.background,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Best-grader financial summary
// ---------------------------------------------------------------------------

class _BestGraderSummary extends StatelessWidget {
  const _BestGraderSummary({required this.matrix});
  final MatrixResult matrix;

  String _sym(String currency) => currency == 'GBP' ? '£' : '\$';

  @override
  Widget build(BuildContext context) {
    final best = matrix.bestGrader;
    if (best == null) return const SizedBox.shrink();

    final sym = _sym(best.currency);
    final totalCost =
        matrix.input.costBasis + best.gradingFee + best.shippingCost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best grader label
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  size: 13, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'Best: ${best.grader.name.toUpperCase()} — ${best.tier}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _FinRow(
            label: 'Cost Basis',
            value: '$sym${matrix.input.costBasis.toStringAsFixed(2)}',
          ),
          _FinRow(
            label: 'Grading Fee',
            value: '$sym${best.gradingFee.toStringAsFixed(2)}',
          ),
          _FinRow(
            label: 'Shipping',
            value: '$sym${best.shippingCost.toStringAsFixed(2)}',
          ),
          const _DividerLine(),
          _FinRow(
            label: 'Total Outlay',
            value: '$sym${totalCost.toStringAsFixed(2)}',
            bold: true,
          ),
          const SizedBox(height: 8),
          _FinRow(
            label:
                'Market Value (Grade ${matrix.input.targetGrade.toStringAsFixed(0)})',
            value: '$sym${best.marketValueAtTarget.toStringAsFixed(2)}',
          ),
          _FinRow(
            label: 'After Fees (13.25% + ${sym}0.40)',
            value:
                '$sym${(best.marketValueAtTarget * (1 - kSellerFeePct) - kSellerFeeFlat).toStringAsFixed(2)}',
            dimmed: true,
          ),
          const _DividerLine(),
          _FinRow(
            label: 'Net Profit',
            value:
                '${best.netProfitAtTarget >= 0 ? '+' : ''}$sym${best.netProfitAtTarget.toStringAsFixed(2)}',
            bold: true,
            valueColor: best.netProfitAtTarget >= 0
                ? AppColors.success
                : AppColors.danger,
          ),

          // Grade 9 row (calculate-for-9 toggle)
          if (matrix.input.calculateForNine &&
              best.netProfitAtGrade9 != null) ...[
            const SizedBox(height: 6),
            _FinRow(
              label: 'Profit if Grade 9',
              value:
                  '${best.netProfitAtGrade9! >= 0 ? '+' : ''}$sym${best.netProfitAtGrade9!.toStringAsFixed(2)}',
              valueColor: best.netProfitAtGrade9! >= 0
                  ? AppColors.success
                  : AppColors.danger,
            ),
          ],
        ],
      ),
    );
  }
}

class _FinRow extends StatelessWidget {
  const _FinRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.dimmed = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final bool bold;
  final bool dimmed;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: dimmed ? AppColors.textDisabled : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ??
                  (dimmed ? AppColors.textDisabled : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Divider(color: AppColors.border, height: 1),
      );
}

// ---------------------------------------------------------------------------
// Break-even annotation
// ---------------------------------------------------------------------------

class _BreakEvenLine extends StatelessWidget {
  const _BreakEvenLine({
    required this.breakEvenGrade,
    required this.targetGrade,
  });

  final double breakEvenGrade;
  final double targetGrade;

  @override
  Widget build(BuildContext context) {
    final cleared = targetGrade >= breakEvenGrade;
    final beg = breakEvenGrade == breakEvenGrade.truncateToDouble()
        ? breakEvenGrade.toInt().toString()
        : breakEvenGrade.toString();
    final tg = targetGrade == targetGrade.truncateToDouble()
        ? targetGrade.toInt().toString()
        : targetGrade.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            cleared
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            size: 16,
            color: cleared ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                children: [
                  const TextSpan(text: 'Break-even at '),
                  TextSpan(
                    text: 'Grade $beg',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: cleared
                        ? ' — target Grade $tg clears it.'
                        : ' — target Grade $tg does not reach it.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
