import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/connect_provider.dart';
import '../../theme/app_theme.dart';

/// Real-time submission activity feed with emoji reactions.
class ActivityFeedTab extends ConsumerWidget {
  const ActivityFeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(activityFeedProvider);

    return feedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _EmptyFeed(),
      data: (events) {
        if (events.isEmpty) return const _EmptyFeed();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: events.length,
          itemBuilder: (_, i) => _ActivityCard(
            event: events[i],
            delay: Duration(milliseconds: 40 * i.clamp(0, 10)),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Activity card
// ---------------------------------------------------------------------------

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard({required this.event, required this.delay});

  final ActivityEvent event;
  final Duration delay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final timeAgo = _timeAgo(event.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _Avatar(
                displayName: event.displayName,
                avatarUrl: event.avatarUrl,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textDisabled),
                    ),
                  ],
                ),
              ),
              // Grader badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Text(
                  event.graderLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Submission detail
          Row(
            children: [
              const Icon(Icons.send_rounded,
                  size: 12, color: AppColors.textDisabled),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'Submitted '),
                      TextSpan(
                        text: event.cardName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: ' · Est. ${fmt.format(event.estimatedValue)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Reaction row
          _ReactionRow(event: event),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0);
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ---------------------------------------------------------------------------
// Reaction row
// ---------------------------------------------------------------------------

class _ReactionRow extends ConsumerWidget {
  const _ReactionRow({required this.event});
  final ActivityEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: ActivityReaction.values.map((r) {
        final count = event.reactions[r.key] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _ReactionButton(
            reaction: r,
            count: count,
            onTap: () => ref
                .read(reactToEventProvider.notifier)
                .react(event.id, r),
          ),
        );
      }).toList(),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.reaction,
    required this.count,
    required this.onTap,
  });
  final ActivityReaction reaction;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: count > 0
              ? AppColors.accent.withOpacity(0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: count > 0
                ? AppColors.accent.withOpacity(0.25)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 13)),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  const _Avatar({required this.displayName, this.avatarUrl});
  final String displayName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.accent.withOpacity(0.15),
      backgroundImage:
          avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!)
              : null,
      child: avatarUrl == null || avatarUrl!.isEmpty
          ? Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dynamic_feed_rounded,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            const Text(
              'No activity yet.\nFollow friends to see their submissions here.',
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
