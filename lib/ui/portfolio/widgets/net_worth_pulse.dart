import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/collection_provider.dart';
import '../../theme/app_theme.dart';

/// The "Net Worth Pulse" — portfolio header with animated glow.
///
/// Glow states:
///   Gold pulse  → portfolio hit a new All-Time High today
///   Green pulse → portfolio is up > 5% vs cost basis this month
///   No glow     → flat or down
class NetWorthPulse extends ConsumerStatefulWidget {
  const NetWorthPulse({super.key});

  @override
  ConsumerState<NetWorthPulse> createState() => _NetWorthPulseState();
}

class _NetWorthPulseState extends ConsumerState<NetWorthPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valuationAsync = ref.watch(portfolioValuationProvider);
    final athAsync = ref.watch(allTimeHighProvider);

    return valuationAsync.when(
      loading: () => _skeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (val) {
        final ath = athAsync.asData?.value ?? 0;
        final isATH = val.totalMarketValue > ath && val.totalMarketValue > 0;
        final isUpMonth = val.roiPct > 5;

        final GlowState glowState;
        if (isATH) {
          glowState = GlowState.gold;
        } else if (isUpMonth) {
          glowState = GlowState.green;
        } else {
          glowState = GlowState.none;
        }

        return _PulseBody(
          valuation: val,
          glowState: glowState,
          pulseAnim: _pulseAnim,
          isATH: isATH,
        );
      },
    );
  }

  Widget _skeleton() {
    return Container(
      height: 160,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

enum GlowState { none, green, gold }

// ---------------------------------------------------------------------------
// Pulse body — separated to minimise AnimatedBuilder scope
// ---------------------------------------------------------------------------

class _PulseBody extends StatelessWidget {
  const _PulseBody({
    required this.valuation,
    required this.glowState,
    required this.pulseAnim,
    required this.isATH,
  });

  final PortfolioValuation valuation;
  final GlowState glowState;
  final Animation<double> pulseAnim;
  final bool isATH;

  Color get _glowColor => switch (glowState) {
        GlowState.gold  => AppColors.accent,
        GlowState.green => AppColors.success,
        GlowState.none  => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final fmtFull = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: glowState != GlowState.none
                ? [
                    BoxShadow(
                      color: _glowColor.withOpacity(0.12 * pulseAnim.value),
                      blurRadius: 40 * pulseAnim.value,
                      spreadRadius: 6 * pulseAnim.value,
                    ),
                    BoxShadow(
                      color: _glowColor.withOpacity(0.06 * pulseAnim.value),
                      blurRadius: 80 * pulseAnim.value,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label row
            Row(
              children: [
                const Text(
                  'TOTAL MARKET VALUE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDisabled,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (isATH)
                  _ATHBadge()
                else if (valuation.isUp)
                  _TrendChip(
                    pct: valuation.roiPct,
                    positive: true,
                  )
                else
                  _TrendChip(
                    pct: valuation.roiPct,
                    positive: false,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Main value
            Text(
              fmt.format(valuation.totalMarketValue),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -1.5,
                height: 1.0,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),

            const SizedBox(height: 10),

            // Secondary row: Unrealized Gains + Projected 1Y
            Row(
              children: [
                _SecondaryMetric(
                  label: 'Unrealized',
                  value:
                      '${valuation.unrealizedGains >= 0 ? '+' : ''}${fmtFull.format(valuation.unrealizedGains)}',
                  color: valuation.unrealizedGains >= 0
                      ? AppColors.success
                      : AppColors.danger,
                ),
                const SizedBox(width: 16),
                _ProjectedValue(costBasis: valuation.totalCostBasis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// All-Time High badge
// ---------------------------------------------------------------------------

class _ATHBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8C547), Color(0xFFFFE09A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 12, color: Color(0xFF5A3A00)),
          SizedBox(width: 4),
          Text(
            'ALL-TIME HIGH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5A3A00),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trend chip
// ---------------------------------------------------------------------------

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.pct, required this.positive});
  final double pct;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (positive ? AppColors.success : AppColors.danger)
            .withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (positive ? AppColors.success : AppColors.danger)
              .withOpacity(0.3),
        ),
      ),
      child: Text(
        '${positive ? '+' : ''}${pct.toStringAsFixed(1)}% ROI',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: positive ? AppColors.success : AppColors.danger,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Secondary metric label
// ---------------------------------------------------------------------------

class _SecondaryMetric extends StatelessWidget {
  const _SecondaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textDisabled)),
        Text(value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Projected 1Y value  (simple 12% annual growth assumption —
// replaced by the Forecast Engine formula in Module 4)
// ---------------------------------------------------------------------------

class _ProjectedValue extends StatelessWidget {
  const _ProjectedValue({required this.costBasis});
  final double costBasis;

  @override
  Widget build(BuildContext context) {
    // Stub: 12% YoY growth — Forecast Engine will override
    final projected = costBasis * 1.12;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Projected 1Y',
            style:
                TextStyle(fontSize: 10, color: AppColors.textDisabled)),
        Row(
          children: [
            Text(
              fmt.format(projected),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accentSoft,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.trending_up_rounded,
                size: 13, color: AppColors.accentSoft),
          ],
        ),
      ],
    );
  }
}
