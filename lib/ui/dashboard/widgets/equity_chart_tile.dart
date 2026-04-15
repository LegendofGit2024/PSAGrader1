import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/collection_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

/// 2×2 bento tile: Portfolio Equity + area sparkline + Daily Delta badge.
class EquityChartTile extends ConsumerWidget {
  const EquityChartTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valAsync = ref.watch(portfolioValuationProvider);
    final deltaAsync = ref.watch(dailyDeltaProvider);
    final historyAsync = ref.watch(portfolioHistoryProvider);

    return _BentoTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'PORTFOLIO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              deltaAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (delta) => _DeltaChip(delta: delta),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Big value
          valAsync.when(
            loading: () => const _ShimmerText(width: 160, height: 36),
            error: (_, __) => const SizedBox.shrink(),
            data: (val) => _EquityValue(value: val.totalMarketValue),
          ),

          // Projected label
          const SizedBox(height: 4),
          valAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (val) => _ProjectedRow(currentValue: val.totalMarketValue),
          ),

          const Spacer(),

          // Sparkline
          SizedBox(
            height: 64,
            child: historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (history) => _SparkLine(
                history: history,
                fallbackValue: valAsync.asData?.value?.totalMarketValue ?? 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Big equity number
// ---------------------------------------------------------------------------

class _EquityValue extends StatelessWidget {
  const _EquityValue({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return Text(
      fmt.format(value),
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 1,
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Projected 1-year row (+12% stub)
// ---------------------------------------------------------------------------

class _ProjectedRow extends StatelessWidget {
  const _ProjectedRow({required this.currentValue});
  final double currentValue;

  @override
  Widget build(BuildContext context) {
    const growthRate = 0.12;
    final projected = currentValue * (1 + growthRate);
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Row(
      children: [
        const Icon(Icons.trending_up_rounded,
            size: 12, color: AppColors.success),
        const SizedBox(width: 4),
        Text(
          '${fmt.format(projected)} projected (1Y)',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Daily delta chip
// ---------------------------------------------------------------------------

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});
  final DailyDelta delta;

  @override
  Widget build(BuildContext context) {
    if (delta.amount == 0) return const SizedBox.shrink();

    final color = delta.isPositive ? AppColors.success : AppColors.danger;
    final sign = delta.isPositive ? '+' : '';
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$sign${fmt.format(delta.amount)} (${sign}${delta.pct.toStringAsFixed(1)}%)',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Area sparkline
// ---------------------------------------------------------------------------

class _SparkLine extends StatelessWidget {
  const _SparkLine({required this.history, required this.fallbackValue});

  final List<PortfolioHistoryPoint> history;
  final double fallbackValue;

  List<FlSpot> _buildSpots() {
    if (history.isEmpty) {
      // Generate a simple upward stub curve if no history
      final base = fallbackValue > 0 ? fallbackValue : 1000;
      final rng = math.Random(42);
      return List.generate(12, (i) {
        final noise = (rng.nextDouble() - 0.4) * base * 0.02;
        final trend = base * (0.88 + i * 0.01);
        return FlSpot(i.toDouble(), trend + noise);
      });
    }
    return history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    final minY = spots.map((s) => s.y).reduce(math.min) * 0.98;
    final maxY = spots.map((s) => s.y).reduce(math.max) * 1.02;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.accent.withOpacity(0.8),
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accent.withOpacity(0.18),
                  AppColors.accent.withOpacity(0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 500),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bento tile container
// ---------------------------------------------------------------------------

class _BentoTile extends StatelessWidget {
  const _BentoTile({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _ShimmerText extends StatelessWidget {
  const _ShimmerText({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
