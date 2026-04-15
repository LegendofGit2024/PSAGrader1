import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

/// 2×1 bento tile: "What's Hot / What's Not" with icon-based reasoning.
class HotNotTile extends ConsumerWidget {
  const HotNotTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(hotCardsProvider);

    return _BentoTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                "WHAT'S HOT / NOT",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Live signals',
                  style: TextStyle(fontSize: 9, color: AppColors.textDisabled),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Cards
          Expanded(
            child: cardsAsync.when(
              loading: () => const Center(
                child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (cards) => cards.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => _HotCardChip(
                        card: cards[i],
                        delay: Duration(milliseconds: 80 * i),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual hot/cold card chip
// ---------------------------------------------------------------------------

class _HotCardChip extends StatelessWidget {
  const _HotCardChip({required this.card, required this.delay});

  final HotCard card;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final isHot = card.direction == HotDirection.hot;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Container(
      width: 130,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHot
              ? AppColors.success.withOpacity(0.25)
              : AppColors.danger.withOpacity(0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Direction badge
          Row(
            children: [
              Text(
                isHot ? '🔥' : '❄️',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                isHot ? 'HOT' : 'COLD',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isHot ? AppColors.success : AppColors.accentSoft,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Card image or placeholder
          if (card.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: card.imageUrl,
                height: 48,
                width: 34,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 48,
              width: 34,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.style_rounded,
                  size: 16, color: AppColors.textDisabled),
            ),
          const SizedBox(height: 6),

          // Name
          Text(
            card.cardName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Price
          if (card.currentValue > 0)
            Text(
              fmt.format(card.currentValue),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),

          const Spacer(),

          // Reason icon chip
          _SignalChip(signal: card.signal, reason: card.reasonText),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Signal reason chip
// ---------------------------------------------------------------------------

class _SignalChip extends StatelessWidget {
  const _SignalChip({required this.signal, required this.reason});
  final HotSignal signal;
  final String reason;

  String _icon() => switch (signal) {
        HotSignal.volumeSpike  => '📉',
        HotSignal.popPlateau   => '🛡️',
        HotSignal.media        => '📺',
        HotSignal.thinSpread   => '⚠️',
      };

  String _label() => switch (signal) {
        HotSignal.volumeSpike  => 'Vol ↑',
        HotSignal.popPlateau   => 'Pop',
        HotSignal.media        => 'Media',
        HotSignal.thinSpread   => 'Spread',
      };

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: reason,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_icon(), style: const TextStyle(fontSize: 9)),
            const SizedBox(width: 3),
            Text(
              _label(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
