import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../providers/forecast_provider.dart';
import '../../theme/app_theme.dart';

/// BUY / HOLD / SELL verdict card with animated glow, confidence bar,
/// "Why" icon chips, and the full reasoning sentence.
class SignalCard extends StatefulWidget {
  const SignalCard({super.key, required this.signal});
  final SignalResult signal;

  @override
  State<SignalCard> createState() => _SignalCardState();
}

class _SignalCardState extends State<SignalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Color get _color => switch (widget.signal.signal) {
        ForecastSignal.buy  => AppColors.success,
        ForecastSignal.hold => AppColors.warning,
        ForecastSignal.sell => AppColors.danger,
      };

  IconData get _icon => switch (widget.signal.signal) {
        ForecastSignal.buy  => Icons.trending_up_rounded,
        ForecastSignal.hold => Icons.pause_circle_rounded,
        ForecastSignal.sell => Icons.trending_down_rounded,
      };

  String get _label => switch (widget.signal.signal) {
        ForecastSignal.buy  => 'BUY / ACCUMULATE',
        ForecastSignal.hold => 'HOLD',
        ForecastSignal.sell => 'SELL / TAKE PROFIT',
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(
                  0.12 + _glowCtrl.value * 0.16),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _ConfidenceBar(
                      confidence: widget.signal.confidence,
                      color: _color,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Why chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.signal.whyTags
                .map((t) => _WhyChip(tag: t))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Reasoning sentence
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: _color.withOpacity(0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.signal.reasoning,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
  }
}

// ---------------------------------------------------------------------------
// Confidence bar
// ---------------------------------------------------------------------------

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.confidence, required this.color});
  final double confidence;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(confidence * 100).toStringAsFixed(0)}% confidence',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Why chip
// ---------------------------------------------------------------------------

class _WhyChip extends StatelessWidget {
  const _WhyChip({required this.tag});
  final WhyTag tag;

  String _emoji() => switch (tag.icon) {
        WhyIcon.highVelocity => '📉',
        WhyIcon.lowSupply    => '🔒',
        WhyIcon.popPlateau   => '🛡️',
        WhyIcon.overheating  => '🔥',
        WhyIcon.flippers     => '⚠️',
        WhyIcon.steady       => '➡️',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_emoji(), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            tag.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
