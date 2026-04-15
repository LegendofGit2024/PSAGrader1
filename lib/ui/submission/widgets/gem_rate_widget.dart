import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/card.dart';
import '../../../providers/submission_provider.dart';
import '../../theme/app_theme.dart';

/// Displays PSA population data with:
///  • Total pop / Pop 10 / Pop 9 counts
///  • Gem Rate bar (pop_10 / total_pop) with colour coding
///  • Probable-grade badge
class GemRateWidget extends StatelessWidget {
  const GemRateWidget({super.key, required this.card});

  final CardDocument card;

  @override
  Widget build(BuildContext context) {
    final pop = card.psaPop;
    final rate = gemRate(pop);
    final probable = probableGrade(card.meta.setId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  size: 15, color: AppColors.accent),
              const SizedBox(width: 6),
              const Text(
                'PSA Population Report',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _ProbableGradeBadge(grade: probable),
            ],
          ),
          const SizedBox(height: 12),

          if (pop == null)
            const Text(
              'No PSA pop data available',
              style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
            )
          else ...[
            // Pop counts row
            Row(
              children: [
                _PopStat(
                    label: 'Total Pop',
                    value: pop.totalPop ?? 0,
                    color: AppColors.textSecondary),
                const SizedBox(width: 16),
                _PopStat(
                    label: 'PSA 10',
                    value: pop.pop10 ?? 0,
                    color: AppColors.accent),
                const SizedBox(width: 16),
                _PopStat(
                    label: 'PSA 9',
                    value: pop.pop9 ?? 0,
                    color: AppColors.accentSoft),
              ],
            ),
            const SizedBox(height: 12),

            // Gem Rate bar
            _GemRateBar(rate: rate),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ---------------------------------------------------------------------------
// Gem Rate bar
// ---------------------------------------------------------------------------

class _GemRateBar extends StatelessWidget {
  const _GemRateBar({required this.rate});
  final double? rate;

  Color _barColor(double r) {
    if (r >= 0.20) return AppColors.success;
    if (r >= 0.10) return AppColors.accent;
    if (r >= 0.05) return AppColors.warning;
    return AppColors.danger;
  }

  String _label(double r) {
    if (r >= 0.20) return 'High gem rate — strong sub candidate';
    if (r >= 0.10) return 'Decent gem rate — worth considering';
    if (r >= 0.05) return 'Low gem rate — proceed with caution';
    return 'Very low gem rate — high risk';
  }

  @override
  Widget build(BuildContext context) {
    if (rate == null) return const SizedBox.shrink();
    final r = rate!;
    final color = _barColor(r);
    final pct = (r * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gem Rate (PSA 10)',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: r.clamp(0.0, 1.0),
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _label(r),
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textDisabled,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Probable grade badge
// ---------------------------------------------------------------------------

class _ProbableGradeBadge extends StatelessWidget {
  const _ProbableGradeBadge({required this.grade});
  final double grade;

  @override
  Widget build(BuildContext context) {
    final isNine = grade == 9.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNine
            ? AppColors.accentSoft.withOpacity(0.15)
            : AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isNine
              ? AppColors.accentSoft.withOpacity(0.4)
              : AppColors.accent.withOpacity(0.4),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Probable ',
              style: TextStyle(
                fontSize: 10,
                color: isNine ? AppColors.accentSoft : AppColors.accent,
              ),
            ),
            TextSpan(
              text: grade.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isNine ? AppColors.accentSoft : AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pop stat cell
// ---------------------------------------------------------------------------

class _PopStat extends StatelessWidget {
  const _PopStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 10, color: AppColors.textDisabled),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
