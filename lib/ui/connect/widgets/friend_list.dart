import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/connect_provider.dart';
import '../../theme/app_theme.dart';

/// "The Circle" — friend list with trade-match badges and vault entry points.
class FriendListTab extends ConsumerWidget {
  const FriendListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _EmptyFriends(),
      data: (friends) {
        if (friends.isEmpty) return const _EmptyFriends();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: friends.length,
          itemBuilder: (_, i) => _FriendRow(
            friend: friends[i],
            delay: Duration(milliseconds: 50 * i),
          ),
        );
      },
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.friend, required this.delay});
  final FriendProfile friend;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: friend.hasTradeMatch
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/connect/vault/${friend.uid}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                _FriendAvatar(friend: friend),
                const SizedBox(width: 12),

                // Name + gem accuracy
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (friend.gemAccuracyPct != null)
                        Row(
                          children: [
                            const Text('💎 ',
                                style: TextStyle(fontSize: 11)),
                            Text(
                              '${(friend.gemAccuracyPct! * 100).toStringAsFixed(0)}% gem accuracy',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Trade match badge
                if (friend.hasTradeMatch)
                  _TradeMatchBadge(count: friend.tradeMatchCount),

                const SizedBox(width: 8),

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionChip(
                      label: 'Wishlist',
                      icon: Icons.favorite_border_rounded,
                      onTap: () =>
                          context.push('/connect/vault/${friend.uid}?tab=wishlist'),
                    ),
                    const SizedBox(width: 6),
                    _ActionChip(
                      label: 'Vault',
                      icon: Icons.style_rounded,
                      onTap: () =>
                          context.push('/connect/vault/${friend.uid}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideX(begin: -0.02, end: 0);
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({required this.friend});
  final FriendProfile friend;

  @override
  Widget build(BuildContext context) {
    final initials = friend.displayName.isNotEmpty
        ? friend.displayName.substring(0, 1).toUpperCase()
        : '?';

    return Stack(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.accentSoft.withOpacity(0.15),
          backgroundImage: friend.avatarUrl != null &&
                  friend.avatarUrl!.isNotEmpty
              ? NetworkImage(friend.avatarUrl!)
              : null,
          child: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
              ? Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentSoft,
                  ),
                )
              : null,
        ),
        if (friend.hasTradeMatch)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.background, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class _TradeMatchBadge extends StatelessWidget {
  const _TradeMatchBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swap_horiz_rounded,
              size: 12, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            '$count match${count > 1 ? 'es' : ''}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            const Text(
              'Your circle is empty.\nSearch for collectors to follow.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppColors.textDisabled, height: 1.5),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text('Find Friends',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
      ),
    );
  }
}
