import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/forecast_provider.dart';
import '../../theme/app_theme.dart';

/// S&P 500 comparison toggle tile.
///
/// When toggled ON, shows a dual bar chart: card projected return vs S&P 500
/// annualised average, making it immediately obvious whether the card "beats
/// the market".
class Sp500CompareTile extends ConsumerStatefulWidget {
  const Sp500CompareTile({super.key, required this.benchmark});
  final BenchmarkComparison benchmark;

  @override
  ConsumerState<Sp500CompareTile> createState() => _Sp500CompareTileState();
}

class _Sp500CompareTileState extends ConsumerState<Sp500CompareTile> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
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
          // Toggle header
          Row(
            children: [
              const Text(
                'COMPARE TO S&P 500',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
                activeColor: AppColors.accent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),

          if (_enabled) ...[
            const SizedBox(height: 12),
            _CompareBody(benchmark: widget.benchmark),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Toggle to see how this card stacks up against the stock market.',
              style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompareBody extends StatelessWidget {
  const _CompareBody({required this.benchmark});
  final BenchmarkComparison benchmark;

  @override
  Widget build(BuildContext context) {
    final cardPct  = benchmark.cardReturn1Y;
    final sp500Pct = benchmark.sp500Return1Y;
    final beats    = benchmark.beatsMarket;
    final alphaColor = beats ? AppColors.success : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alpha headline
        Row(
          children: [
            Text(
              beats ? '🏆' : '📊',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: beats
                          ? '${benchmark.cardName} beats the market '
                          : '${benchmark.cardName} trails the market ',
                    ),
                    TextSpan(
                      text: beats
                          ? 'by +${benchmark.alpha.toStringAsFixed(1)}%'
                          : 'by ${benchmark.alpha.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: alphaColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Bar chart
        SizedBox(
          height: 120,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              minY: 0,
              maxY: (cardPct > sp500Pct ? cardPct : sp500Pct) * 1.3,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) {
                      final label = v == 0
                          ? _truncate(benchmark.cardName, 10)
                          : 'S&P 500';
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                _bar(0, cardPct,  AppColors.accent),
                _bar(1, sp500Pct, AppColors.accentSoft),
              ],
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceVariant,
                  getTooltipItem: (group, _, rod, __) {
                    final label =
                        group.x == 0 ? 'Card' : 'S&P 500';
                    return BarTooltipItem(
                      '$label\n',
                      const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: '+${rod.toY.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.accent),
            const SizedBox(width: 4),
            const Text('Card (1Y proj)',
                style: TextStyle(
                    fontSize: 10, color: AppColors.textDisabled)),
            const SizedBox(width: 16),
            _LegendDot(color: AppColors.accentSoft),
            const SizedBox(width: 4),
            const Text('S&P 500 (hist. avg)',
                style: TextStyle(
                    fontSize: 10, color: AppColors.textDisabled)),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  BarChartGroupData _bar(int x, double y, Color color) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            color: color,
            width: 36,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );

  String _truncate(String s, int n) =>
      s.length > n ? '${s.substring(0, n)}…' : s;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
