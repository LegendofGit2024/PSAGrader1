import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../providers/forecast_provider.dart';
import '../../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Period descriptors
// ---------------------------------------------------------------------------

class _HistPeriod {
  const _HistPeriod(this.label, this.days);
  final String label;
  final int days;

  static const d30 = _HistPeriod('30D', 30);
  static const m3  = _HistPeriod('3M',  90);
  static const m6  = _HistPeriod('6M',  180);
  static const y1  = _HistPeriod('1Y',  365);
  static const y5  = _HistPeriod('5Y',  1825);

  static const all = [d30, m3, m6, y1, y5];
}

class _ProjPeriod {
  const _ProjPeriod(this.label, this.years);
  final String label;
  final int years;

  static const y1  = _ProjPeriod('1Y',  1);
  static const y5  = _ProjPeriod('5Y',  5);
  static const y10 = _ProjPeriod('10Y', 10);

  static const all = [y1, y5, y10];
}

enum _ChartMode { historical, projected }

// ---------------------------------------------------------------------------
// UnifiedPriceChart
// ---------------------------------------------------------------------------

/// Single interactive chart replacing the old 30-day trend + 1-year projection.
///
/// Toggles:
///   • Mode:    Historical | Projected
///   • Period:  30D/3M/6M/1Y/5Y  or  1Y/5Y/10Y
///   • Grader:  Raw | PSA | CGC | BGS | ACE
///   • Grade:   10 | 9 | 8 | 7 | 6  (shown only when a grader is active)
class UnifiedPriceChart extends StatefulWidget {
  const UnifiedPriceChart({super.key, required this.forecast});
  final CardForecast forecast;

  @override
  State<UnifiedPriceChart> createState() => _UnifiedPriceChartState();
}

class _UnifiedPriceChartState extends State<UnifiedPriceChart> {
  _ChartMode _mode    = _ChartMode.historical;
  _HistPeriod _histPeriod = _HistPeriod.d30;
  _ProjPeriod _projPeriod = _ProjPeriod.y1;
  GraderType  _grader = GraderType.raw;
  int         _grade  = 10;

  static const _grades = [10, 9, 8, 7, 6];
  static const _graders = GraderType.values;

  // ── Derived values ────────────────────────────────────────────────────────

  double get _rawPrice {
    final p = widget.forecast.projection.currentPrice;
    return p > 0 ? p : 1.0;
  }

  double get _multiplier => gradeMultiplier(_grader, _grade);

  double get _effectivePrice =>
      _grader == GraderType.raw ? _rawPrice : _rawPrice * _multiplier;

  Color get _signalColor => switch (widget.forecast.signal.signal) {
        ForecastSignal.buy  => AppColors.success,
        ForecastSignal.hold => AppColors.warning,
        ForecastSignal.sell => AppColors.danger,
      };

  // ── Spot builders ─────────────────────────────────────────────────────────

  List<FlSpot> get _spots =>
      _mode == _ChartMode.historical ? _histSpots : _projSpots;

  List<FlSpot> get _histSpots {
    final mult =
        _grader == GraderType.raw ? 1.0 : gradeMultiplier(_grader, _grade);

    final List<PricePoint> history;
    if (_histPeriod.days == 30 &&
        widget.forecast.priceHistory.isNotEmpty) {
      history = widget.forecast.priceHistory;
    } else {
      history = generateStubHistoryForDays(_rawPrice, _histPeriod.days);
    }

    return history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.price * mult))
        .toList();
  }

  List<FlSpot> get _projSpots {
    final mult =
        _grader == GraderType.raw ? 1.0 : gradeMultiplier(_grader, _grade);
    final annualReturn =
        (widget.forecast.projection.returnPct / 100.0).clamp(-0.9, 10.0);

    final points = ForecastEngine.generateProjectionPoints(
      currentPrice: _rawPrice * mult,
      annualReturn: annualReturn,
      years: _projPeriod.years,
    );

    return points
        .map((p) => FlSpot(p.month.toDouble(), p.price))
        .toList();
  }

  // ── Y-axis bounds (always non-zero spread) ────────────────────────────────

  ({double min, double max, double interval}) _yBounds(List<FlSpot> spots) {
    if (spots.isEmpty) return (min: 0, max: 10, interval: 2.5);
    final prices = spots.map((s) => s.y).toList();
    final rawMin = prices.reduce(math.min);
    final rawMax = prices.reduce(math.max);
    final spread = math.max(rawMax - rawMin, rawMax * 0.02 + 1.0);
    final yMin   = rawMin - spread * 0.06;
    final yMax   = rawMax + spread * 0.06;
    return (
      min: yMin,
      max: yMax,
      interval: (yMax - yMin) / 4,
    );
  }

  // ── X-axis label formatter ────────────────────────────────────────────────

  String _xLabel(double x, List<FlSpot> spots) {
    if (_mode == _ChartMode.projected) {
      final m = x.toInt();
      final years = _projPeriod.years;
      if (years == 1) {
        return m == 0 ? 'Now' : '${m}M';
      } else {
        // Show year markers only
        if (m % 12 == 0) return 'Yr ${(m / 12).toInt()}';
        return '';
      }
    }

    // Historical — map index back to a date
    final histList = _histPeriod.days == 30 &&
            widget.forecast.priceHistory.isNotEmpty
        ? widget.forecast.priceHistory
        : generateStubHistoryForDays(_rawPrice, _histPeriod.days);

    final idx = x.toInt();
    if (idx < 0 || idx >= histList.length) return '';
    final date = histList[idx].date;

    if (_histPeriod.days <= 90) return DateFormat('MMM d').format(date);
    if (_histPeriod.days <= 365) return DateFormat('MMM').format(date);
    return DateFormat("MMM ''yy").format(date);
  }

  double _xInterval(List<FlSpot> spots) {
    if (spots.length <= 1) return 1;
    if (_mode == _ChartMode.projected) {
      return _projPeriod.years == 1 ? 3 : 12;
    }
    return (spots.length / 4).ceilToDouble();
  }

  // ── Tooltip label ─────────────────────────────────────────────────────────

  String _tooltipDate(int spotIndex, List<FlSpot> spots) {
    if (_mode == _ChartMode.projected) {
      final m = spots[spotIndex].x.toInt();
      if (_projPeriod.years == 1) return m == 0 ? 'Now' : 'Month $m';
      final yr = m ~/ 12;
      final mo = m % 12;
      return mo == 0 ? 'Year $yr' : 'Yr $yr +${mo}M';
    }
    final histList = _histPeriod.days == 30 &&
            widget.forecast.priceHistory.isNotEmpty
        ? widget.forecast.priceHistory
        : generateStubHistoryForDays(_rawPrice, _histPeriod.days);
    if (spotIndex < 0 || spotIndex >= histList.length) return '';
    return DateFormat('MMM d, yyyy').format(histList[spotIndex].date);
  }

  // ── Price formatter ───────────────────────────────────────────────────────

  String _fmtPrice(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
    return '\$${v.toStringAsFixed(0)}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spots  = _spots;
    final bounds = _yBounds(spots);
    final color  = _mode == _ChartMode.projected
        ? _signalColor
        : AppColors.accentSoft;

    // Change % over the visible window
    final changePct = spots.length >= 2 && spots.first.y > 0
        ? ((spots.last.y - spots.first.y) / spots.first.y) * 100
        : 0.0;
    final changeSign = changePct >= 0 ? '+' : '';
    final changeColor =
        changePct >= 0 ? AppColors.success : AppColors.danger;

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

          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _grader == GraderType.raw
                          ? 'RAW NM PRICE'
                          : '${graderLabel(_grader)} ${_grade} PRICE',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDisabled,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fmtPrice(_effectivePrice),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              if (spots.length >= 2)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: changeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '$changeSign${changePct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: changeColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Mode toggle ──────────────────────────────────────────────────
          _ModeToggle(
            selected: _mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: 10),

          // ── Period pills ─────────────────────────────────────────────────
          if (_mode == _ChartMode.historical)
            _PillRow<_HistPeriod>(
              items: _HistPeriod.all,
              selected: _histPeriod,
              label: (p) => p.label,
              onTap: (p) => setState(() => _histPeriod = p),
            )
          else
            _PillRow<_ProjPeriod>(
              items: _ProjPeriod.all,
              selected: _projPeriod,
              label: (p) => p.label,
              onTap: (p) => setState(() => _projPeriod = p),
            ),
          const SizedBox(height: 14),

          // ── Chart ────────────────────────────────────────────────────────
          SizedBox(
            height: 180,
            child: spots.isEmpty
                ? const Center(
                    child: Text('No data',
                        style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 12)),
                  )
                : LineChart(
                    LineChartData(
                      minY: bounds.min,
                      maxY: bounds.max,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: bounds.interval,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.border.withOpacity(0.4),
                          strokeWidth: 0.7,
                          dashArray: [4, 6],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 54,
                            interval: bounds.interval,
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
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: _xInterval(spots),
                            getTitlesWidget: (v, _) {
                              final label =
                                  _xLabel(v, spots);
                              if (label.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 4),
                                child: Text(
                                  label,
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
                          getTooltipColor: (_) =>
                              AppColors.surfaceVariant,
                          getTooltipItems: (touched) =>
                              touched.map((s) {
                            final label = _tooltipDate(
                                s.spotIndex, spots);
                            return LineTooltipItem(
                              '$label\n',
                              const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary),
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
                                spot.x == spots.first.x ||
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
                                color.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration:
                        const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                  ),
          ),
          const SizedBox(height: 16),

          // ── Grader selector ──────────────────────────────────────────────
          const Text(
            'PRICE TYPE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textDisabled,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _graders.map((g) {
                final selected = _grader == g;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _grader = g;
                      if (g == GraderType.raw) _grade = 10;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent.withOpacity(0.15)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : AppColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        graderLabel(g),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Grade selector (hidden for Raw) ──────────────────────────────
          if (_grader != GraderType.raw) ...[
            const SizedBox(height: 10),
            const Text(
              'GRADE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textDisabled,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: _grades.map((g) {
                final selected = _grade == g;
                // Colour coding: 10=gold, 9=green, 8=blue, 7=amber, 6=red
                final gradeColor = switch (g) {
                  10 => const Color(0xFFE8C547),
                  9  => AppColors.success,
                  8  => AppColors.accentSoft,
                  7  => AppColors.warning,
                  _  => AppColors.danger,
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _grade = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 36,
                      decoration: BoxDecoration(
                        color: selected
                            ? gradeColor.withOpacity(0.15)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? gradeColor
                              : AppColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$g',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? gradeColor
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Multiplier info row
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${graderLabel(_grader)} $_grade estimated at '
                '×${_multiplier.toStringAsFixed(1)} raw NM  '
                '≈ ${_fmtPrice(_effectivePrice)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          // ── Projected disclaimer ─────────────────────────────────────────
          if (_mode == _ChartMode.projected) ...[
            const SizedBox(height: 10),
            const Text(
              '⚠  Projections are model estimates, not guarantees.',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mode toggle (Historical | Projected)
// ---------------------------------------------------------------------------

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.selected, required this.onChanged});
  final _ChartMode selected;
  final ValueChanged<_ChartMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: _ChartMode.values.map((m) {
          final active = selected == m;
          final label = m == _ChartMode.historical
              ? '📈  Historical'
              : '🔮  Projected';
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: active
                      ? Border.all(color: AppColors.border)
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic pill row (period pickers)
// ---------------------------------------------------------------------------

class _PillRow<T> extends StatelessWidget {
  const _PillRow({
    required this.items,
    required this.selected,
    required this.label,
    required this.onTap,
  });
  final List<T> items;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        final active = item == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => onTap(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accent.withOpacity(0.12)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: active ? AppColors.accent : AppColors.border,
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Text(
                label(item),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? AppColors.accent
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
