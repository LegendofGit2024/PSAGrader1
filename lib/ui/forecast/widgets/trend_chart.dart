import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../providers/forecast_provider.dart';
import '../../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Tab definitions
// ---------------------------------------------------------------------------

enum _ChartMode { historical, projection }

class _HistoricalTab {
  const _HistoricalTab(this.label, this.days);
  final String label;
  final int days;
}

class _ProjectionTab {
  const _ProjectionTab(this.label, this.years);
  final String label;
  final int years;
}

const _historicalTabs = [
  _HistoricalTab('30D', 30),
  _HistoricalTab('3M',  90),
  _HistoricalTab('6M',  180),
  _HistoricalTab('1Y',  365),
  _HistoricalTab('5Y',  1825),
];

const _projectionTabs = [
  _ProjectionTab('1Y',  1),
  _ProjectionTab('5Y',  5),
  _ProjectionTab('10Y', 10),
];

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// Unified toggleable price chart for the Forecast screen.
///
/// Two modes — Historical (past prices) and Projection (future estimates) —
/// each with multiple time-period buttons. Both modes use the same fl_chart
/// LineChart underneath with consistent styling.
class UnifiedPriceChart extends StatefulWidget {
  const UnifiedPriceChart({
    super.key,
    required this.forecast,
    this.height = 220,
  });

  final CardForecast forecast;
  final double height;

  @override
  State<UnifiedPriceChart> createState() => _UnifiedPriceChartState();
}

class _UnifiedPriceChartState extends State<UnifiedPriceChart> {
  _ChartMode _mode = _ChartMode.historical;
  int _histIdx = 0;   // index into _historicalTabs
  int _projIdx = 0;   // index into _projectionTabs

  Color get _signalColor => switch (widget.forecast.signal.signal) {
        ForecastSignal.buy  => AppColors.success,
        ForecastSignal.hold => AppColors.warning,
        ForecastSignal.sell => AppColors.danger,
      };

  // ── Data helpers ──────────────────────────────────────────────────────────

  List<FlSpot> _historicalSpots(int days) {
    final currentPrice =
        widget.forecast.card.pricing.ebayUs?.lastSoldNm ?? 0.0;
    final history =
        generateStubHistory(currentPrice, days: days);
    return history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();
  }

  List<DateTime> _historicalDates(int days) {
    final currentPrice =
        widget.forecast.card.pricing.ebayUs?.lastSoldNm ?? 0.0;
    return generateStubHistory(currentPrice, days: days)
        .map((p) => p.date)
        .toList();
  }

  List<FlSpot> _projectionSpots(int years) {
    final points = switch (years) {
      5  => widget.forecast.projection.projectionPoints5y,
      10 => widget.forecast.projection.projectionPoints10y,
      _  => widget.forecast.projection.projectionPoints,
    };
    if (points.isEmpty) return [];
    return points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();
  }

  // ── Chart data ────────────────────────────────────────────────────────────

  (List<FlSpot>, String Function(double, int)) _chartData() {
    if (_mode == _ChartMode.historical) {
      final days = _historicalTabs[_histIdx].days;
      final spots = _historicalSpots(days);
      final dates = _historicalDates(days);
      final fmt = days <= 90 ? 'MMM d' : 'MMM yy';
      String label(double v, int total) {
        final idx = v.toInt();
        if (idx < 0 || idx >= dates.length) return '';
        return DateFormat(fmt).format(dates[idx]);
      }
      return (spots, label);
    } else {
      final years = _projectionTabs[_projIdx].years;
      final spots = _projectionSpots(years);
      String label(double v, int total) {
        final m = v.toInt();
        if (m == 0) return 'Now';
        if (years == 1) return '${m}M';
        // For 5y/10y show year labels at 12-month intervals
        if (m % 12 == 0) return '${m ~/ 12}Y';
        return '';
      }
      return (spots, label);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final color = _mode == _ChartMode.projection
        ? widget.forecast.projection.returnPct >= 0
            ? AppColors.success
            : AppColors.danger
        : _signalColor;

    final (spots, labelFn) = _chartData();

    if (spots.isEmpty) return const SizedBox.shrink();

    final prices = spots.map((s) => s.y).toList();
    final rawMin = prices.reduce(math.min);
    final rawMax = prices.reduce(math.max);
    final spread = math.max(rawMax - rawMin, rawMax * 0.02 + 1.0);
    final minY = rawMin - spread * 0.06;
    final maxY = rawMax + spread * 0.06;
    final interval = math.max((maxY - minY) / 4, 0.01);

    // How many x-axis ticks to show
    final xInterval = math.max((spots.length / 4).ceilToDouble(), 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mode toggle (Historical / Projection) ──────────────────────────
        Row(
          children: [
            _ModeButton(
              label: 'Historical',
              active: _mode == _ChartMode.historical,
              onTap: () => setState(() => _mode = _ChartMode.historical),
            ),
            const SizedBox(width: 8),
            _ModeButton(
              label: 'Projection',
              active: _mode == _ChartMode.projection,
              onTap: () => setState(() => _mode = _ChartMode.projection),
              color: AppColors.accent,
            ),
            const Spacer(),
            _ChangeBadge(spots: spots, color: color,
                isProjection: _mode == _ChartMode.projection),
          ],
        ),
        const SizedBox(height: 10),

        // ── Period pills ───────────────────────────────────────────────────
        SizedBox(
          height: 28,
          child: _mode == _ChartMode.historical
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _historicalTabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => _PeriodPill(
                    label: _historicalTabs[i].label,
                    active: _histIdx == i,
                    onTap: () => setState(() => _histIdx = i),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _projectionTabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => _PeriodPill(
                    label: _projectionTabs[i].label,
                    active: _projIdx == i,
                    onTap: () => setState(() => _projIdx = i),
                    color: AppColors.accent,
                  ),
                ),
        ),
        const SizedBox(height: 12),

        // ── Chart ──────────────────────────────────────────────────────────
        SizedBox(
          height: widget.height,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.border.withOpacity(0.45),
                  strokeWidth: 0.7,
                  dashArray: [4, 6],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 54,
                    interval: interval,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        _fmtPrice(v),
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textDisabled),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: xInterval,
                    getTitlesWidget: (v, meta) {
                      final lbl = labelFn(v, spots.length);
                      if (lbl.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(lbl,
                            style: const TextStyle(
                                fontSize: 8,
                                color: AppColors.textDisabled)),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceVariant,
                  getTooltipItems: (touchedSpots) =>
                      touchedSpots.map((s) {
                    final lbl = labelFn(s.x, spots.length);
                    return LineTooltipItem(
                      '${lbl.isNotEmpty ? lbl : ''}\n',
                      const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: _fmtPrice(s.y),
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
                        spot.x == spots.last.x || spot.x == spots.first.x,
                    getDotPainter: (_, __, ___, ____) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeColor: AppColors.background,
                          strokeWidth: 2,
                        ),
                  ),
                  shadow: Shadow(
                      color: color.withOpacity(0.3), blurRadius: 12),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.0),
                      ],
                    ),
                  ),
                  // Dashed line for projection mode
                  dashArray: _mode == _ChartMode.projection
                      ? [6, 4]
                      : null,
                ),
              ],
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          ),
        ),

        // ── Projection disclaimer ─────────────────────────────────────────
        if (_mode == _ChartMode.projection) ...[
          const SizedBox(height: 8),
          const Text(
            'Dashed line = estimated projection based on historical CAGR × market factors. Not financial advice.',
            style: TextStyle(
                fontSize: 9,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  String _fmtPrice(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
    return '\$${v.toStringAsFixed(0)}';
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.color = AppColors.success,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label chart mode${active ? ', selected' : ''}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? color.withOpacity(0.5) : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? color : AppColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.active,
    required this.onTap,
    this.color = AppColors.success,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label period${active ? ', selected' : ''}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.12) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? color.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? color : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({
    required this.spots,
    required this.color,
    required this.isProjection,
  });
  final List<FlSpot> spots;
  final Color color;
  final bool isProjection;

  @override
  Widget build(BuildContext context) {
    if (spots.length < 2) return const SizedBox.shrink();
    final first = spots.first.y;
    final last = spots.last.y;
    final pct = first > 0 ? ((last - first) / first) * 100 : 0.0;
    final sign = pct >= 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$sign${pct.toStringAsFixed(1)}%${isProjection ? ' est.' : ''}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
