import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../providers/connect_provider.dart';
import '../../theme/app_theme.dart';

/// Trade Room — displays wishlist matches and allows proposing a fair trade.
class TradeRoomTab extends ConsumerWidget {
  const TradeRoomTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(tradeMatchesProvider);

    return matchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _EmptyTradeRoom(),
      data: (matches) {
        if (matches.isEmpty) return const _EmptyTradeRoom();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: matches.length,
          itemBuilder: (_, i) => _TradeMatchCard(
            match: matches[i],
            delay: Duration(milliseconds: 60 * i),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single trade-match card
// ---------------------------------------------------------------------------

class _TradeMatchCard extends StatelessWidget {
  const _TradeMatchCard({required this.match, required this.delay});
  final TradeMatch match;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Friend header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      AppColors.accentSoft.withOpacity(0.15),
                  backgroundImage: match.friend.avatarUrl != null &&
                          match.friend.avatarUrl!.isNotEmpty
                      ? NetworkImage(match.friend.avatarUrl!)
                      : null,
                  child: match.friend.avatarUrl == null ||
                          match.friend.avatarUrl!.isEmpty
                      ? Text(
                          match.friend.displayName
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentSoft,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.friend.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'has ${match.matchedCards.length} card'
                        '${match.matchedCards.length > 1 ? 's' : ''} '
                        'on your wishlist',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.35)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz_rounded,
                          size: 12, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'MATCH',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.border, height: 1),

          // Matched cards row
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              itemCount: match.matchedCards.length,
              itemBuilder: (_, j) => _CardThumb(
                card: match.matchedCards[j],
                delay: Duration(milliseconds: 80 * j),
              ),
            ),
          ),

          const Divider(color: AppColors.border, height: 1),

          // Action row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _ProposalButton(match: match),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.04, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Card thumbnail in the matched cards row
// ---------------------------------------------------------------------------

class _CardThumb extends StatelessWidget {
  const _CardThumb({required this.card, required this.delay});
  final dynamic card;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final price = card.pricing.ebayUs?.lastSoldNm;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: card.meta.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: card.meta.imageUrl,
                    width: 44,
                    height: 62,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 44,
                    height: 62,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.style_rounded,
                        size: 18, color: AppColors.textDisabled),
                  ),
          ),
          if (price != null)
            Text(
              fmt.format(price),
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent),
            ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Fair-trade proposal button → share sheet
// ---------------------------------------------------------------------------

class _ProposalButton extends StatelessWidget {
  const _ProposalButton({required this.match});
  final TradeMatch match;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () => _propose(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success.withOpacity(0.12),
          foregroundColor: AppColors.success,
          elevation: 0,
          side: BorderSide(color: AppColors.success.withOpacity(0.35)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.send_rounded, size: 15),
        label: const Text(
          'Start a Fair-Trade Proposal',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  void _propose(BuildContext context) {
    final names = match.matchedCards.map((c) => c.meta.name).join(', ');
    final msg =
        'Hey ${match.friend.displayName}! 👋\n\n'
        'I noticed you have $names on your list — '
        'want to work out a fair trade?\n\n'
        'Check it out on Slab Stack 💎\n#SlabStack #PokémonTCG';

    Share.share(msg, subject: 'Trade Proposal from Slab Stack');
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyTradeRoom extends StatelessWidget {
  const _EmptyTradeRoom();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_horiz_rounded,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            const Text(
              'No trade matches yet.\n'
              'Mark cards as "Open to Offers" in your Vault,\n'
              'or add cards to your Wishlist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppColors.textDisabled, height: 1.5),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
      ),
    );
  }
}
