import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../providers/submission_provider.dart';
import '../../theme/app_theme.dart';

/// Bar chart showing Net Profit (USD) for every grade that has price data.
///
/// Bars are colored green (profit ≥ 0) or red (loss).
/// The projected grade bar is highlighted in gold.
/// The break-even grade is annotated with a dashed threshold line at y = 0.
class GradeRoiChart extends StatelessWidget {
  const GradeRoiChart({
    super.key,
    required this.profitByGrade,
    required this.projectedGrade,
    this.breakEvenGrade,
  });

  final Map<double, double> profitByGrade;
  final double projectedGrade;
  final double? breakEvenGrade;

  @override
  Widget build(BuildContext context) {
    if (profitByGrade.isEmpty) return const SizedBox.shrink();

    // Sort grades ascending for display
    final grades = profitByGrade.keys.toList()..sort();
    final profits = grades.map((g) => profitByGrade[g]!).toList();

    final maxAbs = profits.fold<double>(
      0,
      (m, v) => v.abs() > m ? v.abs() : m,
    );
    final yRange = maxAbs == 0 ? 100.0 : maxAbs * 1.3;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: -yRange,
          maxY: yRange,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yRange / 3,
            getDrawingHorizontalLine: (v) => FlLine(
              color: v == 0
                  ? AppColors.textSecondary.withOpacity(0.5)
                  : AppColors.border.withOpacity(0.4),
              strokeWidth: v == 0 ? 1.5 : 0.8,
              dashArray: v == 0 ? null : [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: yRange / 3,
                getTitlesWidget: (v, meta) => Text(
                  _formatY(v),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final grade = grades[v.toInt()];
                  final label = grade == grade.truncateToDouble()
                      ? grade.toInt().toString()
                      : grade.toString();
                  final isProjected = grade == projectedGrade;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isProjected ? 11 : 10,
                        fontWeight: isProjected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isProjected
                            ? AppColors.accent
                            : AppColors.textDisabled,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(grades.length, (i) {
            final grade = grades[i];
            final profit = profits[i];
            final isProjected = grade == projectedGrade;
            final isBreakEven = grade == breakEvenGrade;

            Color barColor;
            if (isProjected) {
              barColor = AppColors.accent;
            } else if (profit >= 0) {
              barColor = AppColors.success.withOpacity(0.7);
            } else {
              barColor = AppColors.danger.withOpacity(0.6);
            }

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: profit,
                  width: isProjected ? 14 : 10,
                  color: barColor,
                  borderRadius: profit >= 0
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        )
                      : const BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: isProjected,
                    toY: yRange,
                    fromY: -yRange,
                    color: AppColors.accent.withOpacity(0.06),
                  ),
                ),
              ],
              // Break-even grade annotation dot
              showingTooltipIndicators: isBreakEven ? [0] : [],
            );
          }),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceVariant,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final grade = grades[groupIndex];
                final profit = rod.toY;
                final label = grade == grade.truncateToDouble()
                    ? grade.toInt().toString()
                    : grade.toString();
                return BarTooltipItem(
                  'Grade $label\n',
                  const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '${profit >= 0 ? '+' : ''}\$${profit.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: profit >= 0
                            ? AppColors.success
                            : AppColors.danger,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatY(double v) {
    if (v == 0) return '\$0';
    final abs = v.abs();
    if (abs >= 1000) return '${v >= 0 ? '' : '-'}\$${(abs / 1000).toStringAsFixed(1)}k';
    return '${v >= 0 ? '+' : '-'}\$${abs.toStringAsFixed(0)}';
  }
}
