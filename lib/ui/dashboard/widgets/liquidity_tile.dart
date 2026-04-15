import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/collection_provider.dart';
import '../../theme/app_theme.dart';

/// 1×1 bento tile: Liquidity Score (A+/A/B/C/D/F) with colour gauge.
class LiquidityTile extends ConsumerWidget {
  const LiquidityTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(portfolioStatsProvider);

    return _BentoTile(
      child: statsAsync.when(
        loading: () => const Center(child: _LoadingDot()),
        error: (_, __) => const SizedBox.shrink(),
        data: (stats) {
          // Use the liquidity score from collection_provider
          final score = _computeLiquidityScore(stats);
          final grade = liquidityGrade(score);
          return _LiquidityBody(grade: grade, score: score);
        },
      ),
    );
  }

  double _computeLiquidityScore(PortfolioStats stats) {
    if (stats.totalItems == 0) return 0;
    final slabRatio = stats.totalItems > 0
        ? stats.slabCount / stats.totalItems
        : 0.0;
    // Slabs are generally more liquid than raw (easier to price)
    return (slabRatio * 0.6 + 0.4).clamp(0.0, 1.0);
  }
}

class _LiquidityBody extends StatelessWidget {
  const _LiquidityBody({required this.grade, required this.score});
  final String grade;
  final double score;

  Color _gradeColor(String g) => switch (g) {
        'A+' || 'A' => AppColors.success,
        'B'         => AppColors.accentSoft,
        'C'         => AppColors.warning,
        _           => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(grade);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIQUIDITY',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textDisabled,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Text(
          grade,
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -2,
            height: 1,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: score,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cash-out speed',
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _BentoTile extends StatelessWidget {
  const _BentoTile({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _LoadingDot extends StatelessWidget {
  const _LoadingDot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
