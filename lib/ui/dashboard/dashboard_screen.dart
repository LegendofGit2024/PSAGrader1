import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../router/app_router.dart';
import '../theme/app_theme.dart';
import 'widgets/equity_chart_tile.dart';
import 'widgets/hot_not_tile.dart';
import 'widgets/liquidity_tile.dart';
import 'widgets/movers_tile.dart';
import 'widgets/sentiment_tile.dart';
import 'widgets/smart_todo_tile.dart';
import 'widgets/whale_watch_tile.dart';

/// Dashboard — the Fund Manager control centre.
///
/// Bento grid layout (3-column base):
///
///   ┌────────────────────────────────────────┐
///   │ Header (avatar + notifications)        │
///   ├──────────────────┬──────────┬──────────┤
///   │ Equity + Chart   │ Liquidity│          │
///   │    (2×2)         │  (1×1)   │          │
///   │                  ├──────────┤          │
///   │                  │Sentiment │          │
///   │                  │  (1×1)   │          │
///   ├──────────────────┴──────────┴──────────┤
///   │ Quick Actions (full-width)             │
///   ├────────────────────────┬───────────────┤
///   │ What's Hot / Not (2×1) │ Whale (1×1)   │
///   ├────────────────────────┴───────────────┤
///   │ 7-Day Movers (full-width)              │
///   ├────────────────────────────────────────┤
///   │ Smart To-Do (full-width)               │
///   └────────────────────────────────────────┘
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(child: _DashboardHeader()),

          // Bento grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // ≥700 px → 4 cols so tiles aren't enormous on laptop
                      final wide = constraints.maxWidth >= 700;
                      final cols = wide ? 4 : 3;
                      return StaggeredGrid.count(
                        crossAxisCount: cols,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          // Equity chart (2 cols × 2 rows)
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 2,
                            child: const EquityChartTile()
                                .animate()
                                .fadeIn(delay: 50.ms, duration: 400.ms),
                          ),
                          // Liquidity (1×1)
                          StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: const LiquidityTile()
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 400.ms),
                          ),
                          // Sentiment (1×1)
                          StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: const SentimentTile()
                                .animate()
                                .fadeIn(delay: 150.ms, duration: 400.ms),
                          ),

                          // Quick Actions (full width)
                          StaggeredGridTile.fit(
                            crossAxisCellCount: cols,
                            child: const _QuickActionsRow()
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 400.ms),
                          ),

                          // Hot/Not (2 cols × 2 rows)
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 2,
                            child: const HotNotTile()
                                .animate()
                                .fadeIn(delay: 250.ms, duration: 400.ms),
                          ),
                          // Whale Watch (fills remaining cols on same row × 2 rows)
                          StaggeredGridTile.count(
                            crossAxisCellCount: cols - 2,
                            mainAxisCellCount: 2,
                            child: const WhaleWatchTile()
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 400.ms),
                          ),

                          // Movers (full width, intrinsic height)
                          StaggeredGridTile.fit(
                            crossAxisCellCount: cols,
                            child: const MoversTile()
                                .animate()
                                .fadeIn(delay: 350.ms, duration: 400.ms),
                          ),

                          // Smart To-Do (full width, intrinsic height)
                          StaggeredGridTile.fit(
                            crossAxisCellCount: cols,
                            child: const SmartTodoTile()
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 400.ms),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard header — avatar + app name + notification bell
// ---------------------------------------------------------------------------

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            // Avatar / initials
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accent.withOpacity(0.15),
              child: const Icon(Icons.person_rounded,
                  size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 10),

            // Greeting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SLAB STACK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Your Vault Dashboard',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Notification bell
            _NotificationBell(),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_rounded,
              color: AppColors.textSecondary, size: 22),
          onPressed: () {
            // TODO: open notifications panel
          },
        ),
        // Unread dot
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Actions row — 4 circular action buttons
// ---------------------------------------------------------------------------

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    const actions = [
      (icon: Icons.qr_code_scanner_rounded, label: 'Scan Card', route: '/portfolio/add'),
      (icon: Icons.sell_rounded, label: 'Log Sale', route: '/portfolio'),
      (icon: Icons.calculate_rounded, label: 'Submit', route: '/submission'),
      (icon: Icons.people_rounded, label: 'Find Friends', route: '/connect'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) => _ActionButton(
              icon: a.icon,
              label: a.label,
              route: a.route,
            )).toList(),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
