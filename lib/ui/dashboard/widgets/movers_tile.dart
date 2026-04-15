import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

/// Full-width bento tile: Top 3 portfolio movers in the last 7 days.
class MoversTile extends ConsumerWidget {
  const MoversTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moversAsync = ref.watch(portfolioMoversProvider);

    return _BentoTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              const Text(
                '7-DAY MOVERS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              const Text(
                'Your collection',
                style: TextStyle(fontSize: 9, color: AppColors.textDisabled),
              ),
            ],
          ),
          const SizedBox(height: 10),

          moversAsync.when(
            loading: () => Column(
              children: List.generate(3,
                  (_) => const _ShimmerRow()),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (movers) {
              if (movers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Add cards to your vault to track movers.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textDisabled),
                  ),
                );
              }
              return Column(
                children: movers
                    .asMap()
                    .entries
                    .map((e) => _MoverRow(
                          mover: e.value,
                          rank: e.key + 1,
                          delay: Duration(milliseconds: (60 * e.key).toInt()),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoverRow extends StatelessWidget {
  const _MoverRow({
    required this.mover,
    required this.rank,
    required this.delay,
  });
  final PortfolioMover mover;
  final int rank;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final isUp = mover.change7d >= 0;
    final color = isUp ? AppColors.success : AppColors.danger;
    final sign = isUp ? '+' : '';

    return GestureDetector(
      onTap: () => context.push('/portfolio/card/${mover.item.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 20,
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Card image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: mover.card.meta.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: mover.card.meta.imageUrl,
                      width: 30,
                      height: 42,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 30,
                      height: 42,
                      color: AppColors.surface,
                      child: const Icon(Icons.style_rounded,
                          size: 14, color: AppColors.textDisabled),
                    ),
            ),
            const SizedBox(width: 10),

            // Card info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mover.card.meta.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${mover.card.meta.setId}  ·  '
                    '${mover.item.condition.type.name.toUpperCase()}',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Value + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmt.format(mover.currentValue),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '$sign${mover.changePct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideX(begin: -0.02, end: 0);
  }
}

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

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
