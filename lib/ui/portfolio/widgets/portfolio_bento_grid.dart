import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/card.dart';
import '../../../models/collection_item.dart';
import '../../../providers/collection_provider.dart';
import '../../theme/app_theme.dart';

/// Bento grid — 4 modular tiles laid out as 2 columns, 2 rows:
///
///  ┌──────────────────┬──────────┐
///  │   Crown Jewel    │ Top      │
///  │   (2×2 = full   │ Gainer   │
///  │    left col)     ├──────────┤
///  │                  │ Liquidity│
///  ├─────────────────────────────┤
///  │   Allocation Donut (2×1)    │
///  └─────────────────────────────┘
class PortfolioBentoGrid extends ConsumerWidget {
  const PortfolioBentoGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valuationAsync = ref.watch(portfolioValuationProvider);
    final statsAsync = ref.watch(portfolioStatsProvider);

    return valuationAsync.when(
      loading: () => _BentoSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (val) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            // Crown Jewel — spans 1 col × 2 rows (tall left tile)
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: CrownJewelTile(
                item: val.crownJewelItem,
                card: val.crownJewelCard,
                value: val.crownJewelCard != null
                    ? itemMarketValue(val.crownJewelItem!, val.crownJewelCard!)
                    : null,
              ),
            ),
            // Top Gainer — 1×1 top-right
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: TopGainerTile(
                item: val.topGainerItem,
                card: val.topGainerCard,
              ),
            ),
            // Liquidity Gauge — 1×1 bottom-right
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: LiquidityGaugeTile(score: val.liquidityScore),
            ),
            // Allocation Donut — spans full width (2×1)
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: statsAsync.when(
                loading: () => _TileSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (s) => AllocationDonutTile(stats: s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Crown Jewel tile — 2×2, holo shimmer + scroll-reactive tilt
// ---------------------------------------------------------------------------

class CrownJewelTile extends StatefulWidget {
  const CrownJewelTile({
    super.key,
    this.item,
    this.card,
    this.value,
  });
  final CollectionItem? item;
  final CardDocument? card;
  final double? value;

  @override
  State<CrownJewelTile> createState() => _CrownJewelTileState();
}

class _CrownJewelTileState extends State<CrownJewelTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _holoCtrl;
  late Animation<double> _holoAnim;

  @override
  void initState() {
    super.initState();
    _holoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _holoAnim = Tween<double>(begin: 0, end: 1).animate(_holoCtrl);
  }

  @override
  void dispose() {
    _holoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.card == null || widget.item == null) {
      return _EmptyCrownTile();
    }

    final slab = widget.item!.condition.slab;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return GestureDetector(
      onTap: () => context.push('/portfolio/card/${widget.item!.id}'),
      child: AnimatedBuilder(
        animation: _holoAnim,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.25 +
                  0.25 * math.sin(_holoAnim.value * 2 * math.pi)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(
                    0.08 + 0.08 * math.sin(_holoAnim.value * 2 * math.pi)),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Card image
              CachedNetworkImage(
                imageUrl: widget.card!.meta.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: AppColors.surfaceVariant,
                  child: Container(color: AppColors.surface),
                ),
              ),

              // Holo shimmer overlay — scrolls diagonally
              AnimatedBuilder(
                animation: _holoAnim,
                builder: (_, __) => Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (rect) => LinearGradient(
                      begin: Alignment(
                        -1.5 + 3.0 * _holoAnim.value,
                        -1.5 + 3.0 * _holoAnim.value,
                      ),
                      end: Alignment(
                        -0.5 + 3.0 * _holoAnim.value,
                        -0.5 + 3.0 * _holoAnim.value,
                      ),
                      colors: const [
                        Colors.transparent,
                        Color(0x26FFFFFF),
                        Color(0x18E8C547),
                        Color(0x264A9EFF),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.3, 0.5, 0.7, 1],
                    ).createShader(rect),
                    blendMode: BlendMode.srcOver,
                    child: Container(color: Colors.white),
                  ),
                ),
              ),

              // Bottom gradient + info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 28, 12, 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xE6000000)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(19),
                      bottomRight: Radius.circular(19),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              size: 12, color: AppColors.accent),
                          SizedBox(width: 4),
                          Text(
                            'CROWN JEWEL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.card!.meta.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (slab != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${slab.grader.name.toUpperCase()} ${slab.grade}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (widget.value != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          fmt.format(widget.value),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _EmptyCrownTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_outlined,
                size: 32, color: AppColors.textDisabled),
            SizedBox(height: 8),
            Text('Add your first card',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Allocation Donut tile — 2×1 wide
// ---------------------------------------------------------------------------

class AllocationDonutTile extends StatelessWidget {
  const AllocationDonutTile({super.key, required this.stats});
  final PortfolioStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.totalItems;
    if (total == 0) return _TileSkeleton();

    final slabPct = total > 0 ? stats.slabCount / total : 0.0;
    final rawPct = total > 0 ? stats.rawCount / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 80,
            height: 80,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 24,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    value: slabPct,
                    color: AppColors.accent,
                    radius: 16,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: rawPct,
                    color: AppColors.accentSoft,
                    radius: 14,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ALLOCATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDisabled,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  color: AppColors.accent,
                  label: 'Slabs',
                  value: '${(slabPct * 100).toStringAsFixed(0)}%',
                  count: stats.slabCount,
                ),
                const SizedBox(height: 6),
                _LegendRow(
                  color: AppColors.accentSoft,
                  label: 'Raw',
                  value: '${(rawPct * 100).toStringAsFixed(0)}%',
                  count: stats.rawCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.count,
  });
  final Color color;
  final String label;
  final String value;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
        const SizedBox(width: 4),
        Text('($count)',
            style: const TextStyle(
                fontSize: 10, color: AppColors.textDisabled)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Top Gainer tile — 1×1
// ---------------------------------------------------------------------------

class TopGainerTile extends StatelessWidget {
  const TopGainerTile({super.key, this.item, this.card});
  final CollectionItem? item;
  final CardDocument? card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item != null
          ? () => context.push('/portfolio/card/${item!.id}')
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: card == null
            ? _EmptyMini(icon: Icons.trending_up_rounded, label: 'Top Gainer')
            : ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: card!.meta.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xDD000000)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.trending_up_rounded,
                                    size: 10, color: AppColors.success),
                                SizedBox(width: 3),
                                Text('TOP GAINER',
                                    style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.success,
                                        letterSpacing: 0.5)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card!.meta.name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Liquidity Gauge tile — 1×1, letter grade A+ to F
// ---------------------------------------------------------------------------

class LiquidityGaugeTile extends StatelessWidget {
  const LiquidityGaugeTile({super.key, required this.score});
  final double score;

  Color get _gradeColor {
    final g = liquidityGrade(score);
    return switch (g) {
      'A+' => AppColors.success,
      'A'  => const Color(0xFF84CC16),
      'B'  => AppColors.warning,
      'C'  => const Color(0xFFEF4444),
      _    => AppColors.textDisabled,
    };
  }

  @override
  Widget build(BuildContext context) {
    final grade = liquidityGrade(score);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LIQUIDITY',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.textDisabled,
                letterSpacing: 1.0,
              ),
            ),
            Center(
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: _gradeColor,
                  height: 1,
                ),
              ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),
            ),
            // Mini progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(_gradeColor),
                minHeight: 4,
              ),
            ),
            Text(
              '${(score * 100).toStringAsFixed(0)}% liquid',
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared skeleton + empty helpers
// ---------------------------------------------------------------------------

class _BentoSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceVariant,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      width: 140,
                      height: 114,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 140,
                      height: 114,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 108,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceVariant,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _EmptyMini extends StatelessWidget {
  const _EmptyMini({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: AppColors.textDisabled),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textDisabled),
            textAlign: TextAlign.center),
      ],
    );
  }
}
