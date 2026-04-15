import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'widgets/activity_feed.dart';
import 'widgets/friend_list.dart';
import 'widgets/gem_leaderboard.dart';
import 'widgets/trade_room.dart';

/// Connect screen — 4-tab layout.
///
///   Activity Feed  |  The Circle  |  Rankings  |  Trade Room
class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              title: const Text(
                'Connect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(49),
                child: Column(
                  children: [
                    Container(height: 1, color: AppColors.border),
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: AppColors.accent,
                      indicatorWeight: 2,
                      labelColor: AppColors.accent,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Activity Feed'),
                        Tab(text: 'The Circle'),
                        Tab(text: 'Rankings'),
                        Tab(text: 'Trade Room'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              ActivityFeedTab(),
              FriendListTab(),
              GemLeaderboardTab(),
              TradeRoomTab(),
            ],
          ),
        ),
      ),
    );
  }
}
