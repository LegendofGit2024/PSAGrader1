import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../providers/forecast_provider.dart';
import '../../theme/app_theme.dart';

/// Compact bento tile showing the Heat Index gauge + velocity/delta breakdown.
class HeatIndexTile extends StatelessWidget {
  const HeatIndexTile({super.key, required this.heat});
  final HeatResult heat;

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
          // Label
          const Text(
            'HEAT INDEX',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textDisabled,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Gauge + reading side by side
          Row(
            children: [
              _HeatGauge(heat: heat),
              const SizedBox(width: 16),
              Expanded(child: _HeatBreakdown(heat: heat)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ---------------------------------------------------------------------------
// Circular heat gauge
// ---------------------------------------------------------------------------

class _HeatGauge extends StatelessWidget {
  const _HeatGauge({required this.heat});
  final HeatResult heat;

  Color _needleColor() {
    if (heat.isHot)  return AppColors.danger;
    if (heat.isCold) return AppColors.accentSoft;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final color = _needleColor();
    // Map heat index (0–3 range) to 0–1 for gauge fill
    final fill  = (heat.index / 3.0).clamp(0.0, 1.0);

    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _GaugePainter(fill: fill, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                heat.index.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                heat.isHot ? '🔥' : heat.isCold ? '❄️' : '〰',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.fill, required this.color});
  final double fill;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      Paint()
        ..color = AppColors.surfaceVariant
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Fill
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5 * fill,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fill != fill || old.color != color;
}

// ---------------------------------------------------------------------------
// Velocity / delta breakdown
// ---------------------------------------------------------------------------

class _HeatBreakdown extends StatelessWidget {
  const _HeatBreakdown({required this.heat});
  final HeatResult heat;

  @override
  Widget build(BuildContext context) {
    final velColor = heat.salesVelocity >= 1.5
        ? AppColors.success
        : heat.salesVelocity < 0.7
            ? AppColors.danger
            : AppColors.textSecondary;

    final deltaColor = heat.priceDelta7d >= 0
        ? AppColors.success
        : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatRow(
          icon: '📉',
          label: 'Velocity',
          value: '${heat.salesVelocity.toStringAsFixed(1)}×',
          hint: 'vs 30d avg',
          color: velColor,
        ),
        const SizedBox(height: 8),
        _StatRow(
          icon: '📈',
          label: 'Price Δ 7d',
          value: '${heat.priceDelta7d >= 0 ? '+' : ''}${(heat.priceDelta7d * 100).toStringAsFixed(1)}%',
          hint: 'last sold',
          color: deltaColor,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _labelBg(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            heat.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _labelColor(),
            ),
          ),
        ),
      ],
    );
  }

  Color _labelBg() {
    if (heat.isHot)  return AppColors.danger.withOpacity(0.12);
    if (heat.isCold) return AppColors.accentSoft.withOpacity(0.12);
    return AppColors.warning.withOpacity(0.12);
  }

  Color _labelColor() {
    if (heat.isHot)  return AppColors.danger;
    if (heat.isCold) return AppColors.accentSoft;
    return AppColors.warning;
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    required this.color,
  });
  final String icon;
  final String label;
  final String value;
  final String hint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
