import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../providers/forecast_provider.dart';
import '../../theme/app_theme.dart';

/// 1-year price projection tile showing the formula inputs and final number.
class ProjectionTile extends StatelessWidget {
  const ProjectionTile({super.key, required this.projection});
  final ProjectionResult projection;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final isUp = projection.projectedPrice1Y >= projection.currentPrice;
    final color = isUp ? AppColors.success : AppColors.danger;
    final sign  = isUp ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                '1-YEAR PROJECTION',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              _SentimentBadge(multiplier: projection.sentimentMultiplier),
            ],
          ),
          const SizedBox(height: 10),

          // Projected value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmt.format(projection.projectedPrice1Y),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                  height: 1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$sign${projection.returnPct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'from ${fmt.format(projection.currentPrice)} today',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textDisabled),
          ),
          const SizedBox(height: 12),

          // Formula breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _FormulaRow(
                  label: 'Set CAGR',
                  value:
                      '${(projection.cagr * 100).toStringAsFixed(0)}% / yr',
                  hint: projection.setId,
                ),
                const SizedBox(height: 6),
                _FormulaRow(
                  label: 'Sentiment ×',
                  value:
                      '${projection.sentimentMultiplier.toStringAsFixed(2)}',
                  hint: _sentimentLabel(projection.sentimentMultiplier),
                ),
                const Divider(color: AppColors.border, height: 12),
                _FormulaRow(
                  label: 'Effective rate',
                  value:
                      '${((projection.cagr * projection.sentimentMultiplier) * 100).toStringAsFixed(1)}%',
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sentimentLabel(double m) {
    if (m >= 1.4) return 'Very Bullish';
    if (m >= 1.15) return 'Bullish';
    if (m >= 0.85) return 'Neutral';
    if (m >= 0.6) return 'Bearish';
    return 'Very Bearish';
  }
}

class _FormulaRow extends StatelessWidget {
  const _FormulaRow({
    required this.label,
    required this.value,
    this.hint,
    this.bold = false,
  });
  final String label;
  final String value;
  final String? hint;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              if (hint != null)
                Text(
                  hint!,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textDisabled),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 13 : 12,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: bold ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SentimentBadge extends StatelessWidget {
  const _SentimentBadge({required this.multiplier});
  final double multiplier;

  @override
  Widget build(BuildContext context) {
    final isBull = multiplier >= 1.0;
    final color = isBull ? AppColors.success : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isBull ? '📈' : '📉',
              style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            isBull ? 'Bullish' : 'Bearish',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
