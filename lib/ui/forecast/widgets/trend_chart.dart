import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../providers/forecast_provider.dart';
import '../../theme/app_theme.dart';

/// 30-day price line chart with a glowing accent line and card-image overlay.
///
/// The signal colour (green=buy / amber=hold / red=sell) tints both the
/// glow and the area fill so the whole chart communicates sentiment at a glance.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.history,
    required this.signal,
    this.height = 180,
  });

  final List<PricePoint> history;
  final ForecastSignal signal;
  final double height;

  Color get _signalColor => switch (signal) {
        ForecastSignal.buy  => AppColors.success,
        ForecastSignal.hold => AppColors.warning,
        ForecastSignal.sell => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();

    final prices   = history.map((p) => p.price).toList();
    final rawMin   = prices.reduce(math.min);
    final rawMax   = prices.reduce(math.max);
    // Ensure spread is never zero — fl_chart asserts interval > 0
    final spread   = math.max(rawMax - rawMin, rawMax * 0.02 + 1.0);
    final minPrice = rawMin - spread * 0.06;
    final maxPrice = rawMax + spread * 0.06;
    final color   = _signalColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.6), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '30-DAY PRICE TREND',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textDisabled,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            _PriceChangeBadge(history: history, color: color),
          ],
        ),
        const SizedBox(height: 10),

        // Chart
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: minPrice,
              maxY: maxPrice,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxPrice - minPrice) / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.border.withOpacity(0.5),
                  strokeWidth: 0.8,
                  dashArray: [4, 6],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    interval: (maxPrice - minPrice) / 4,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        _fmtPrice(v),
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: (spots.length / 4).ceilToDouble(),
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= history.length) {
                        return const SizedBox.shrink();
                      }
                      final date = history[idx].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat('MMM d').format(date),
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceVariant,
                  getTooltipItems: (spots) => spots.map((s) {
                    final idx = s.spotIndex;
                    final date = idx < history.length
                        ? DateFormat('MMM d').format(history[idx].date)
                        : '';
                    return LineTooltipItem(
                      '$date\n',
                      const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: '\$${s.y.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.25,
                  color: color,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, _) =>
                        spot.x == spots.last.x,
                    getDotPainter: (_, __, ___, ____) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeColor: AppColors.background,
                          strokeWidth: 2,
                        ),
                  ),
                  shadow: Shadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 12,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withOpacity(0.16),
                        color.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }

  String _fmtPrice(double v) {
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
    return '\$${v.toStringAsFixed(0)}';
  }
}

// ---------------------------------------------------------------------------
// Price change badge (first→last)
// ---------------------------------------------------------------------------

class _PriceChangeBadge extends StatelessWidget {
  const _PriceChangeBadge({required this.history, required this.color});
  final List<PricePoint> history;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) return const SizedBox.shrink();
    final first = history.first.price;
    final last  = history.last.price;
    final pct   = first > 0 ? ((last - first) / first) * 100 : 0.0;
    final sign  = pct >= 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$sign${pct.toStringAsFixed(1)}% (30d)',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
