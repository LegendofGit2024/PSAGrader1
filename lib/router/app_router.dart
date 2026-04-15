import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../ui/auth/login_screen.dart';
import '../ui/connect/connect_screen.dart';
import '../ui/connect/friend_vault_screen.dart';
import '../ui/dashboard/dashboard_screen.dart';
import '../ui/forecast/forecast_screen.dart';
import '../services/auth_service.dart' show authStateProvider;
import '../ui/portfolio/add_item_sheet.dart';
import '../ui/portfolio/binder_view.dart';
import '../ui/portfolio/card_detail_screen.dart';
import '../ui/portfolio/portfolio_screen.dart';
import '../ui/portfolio/showcase_screen.dart';
import '../ui/submission/submission_screen.dart';
import '../ui/theme/app_theme.dart';

part 'app_router.g.dart';

// Route path constants
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const portfolio = '/portfolio';
  static const cardDetail = '/portfolio/card/:itemId';
  static const addCard = '/portfolio/add';
  static const binderView = '/portfolio/binder/:binderId';
  static const submission = '/submission';
  static const forecast = '/forecast';
  static const connect = '/connect';
  static const friendVault = '/connect/vault/:friendUid';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Listen to auth state so the router rebuilds on sign-in / sign-out
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Wait for the auth stream to emit its first value before redirecting.
      if (authState is AsyncLoading) return null;

      final isLoggedIn = authState.asData?.value != null;
      final location = state.matchedLocation;

      // Always leave the splash once auth state is known.
      if (location == AppRoutes.splash) {
        return isLoggedIn ? AppRoutes.dashboard : AppRoutes.login;
      }

      if (!isLoggedIn && location != AppRoutes.login) return AppRoutes.login;
      if (isLoggedIn && location == AppRoutes.login) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashPlaceholder(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.portfolio,
            builder: (context, state) => const PortfolioScreen(),
            routes: [
              GoRoute(
                path: 'card/:itemId',
                builder: (context, state) => CardDetailScreen(
                  itemId: state.pathParameters['itemId']!,
                ),
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => AddItemScreen(
                  preselectedBinderId: state.uri.queryParameters['binderId'],
                  preselectedSlot: int.tryParse(
                      state.uri.queryParameters['slot'] ?? ''),
                ),
              ),
              GoRoute(
                path: 'binder/:binderId',
                builder: (context, state) => BinderView(
                  binderId: state.pathParameters['binderId']!,
                ),
              ),
              GoRoute(
                path: 'showcase',
                builder: (context, state) => const ShowcaseScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.submission,
            builder: (context, state) => const SubmissionScreen(),
          ),
          GoRoute(
            path: AppRoutes.forecast,
            builder: (context, state) => const ForecastScreen(),
          ),
          GoRoute(
            path: AppRoutes.connect,
            builder: (context, state) => const ConnectScreen(),
            routes: [
              GoRoute(
                path: 'vault/:friendUid',
                builder: (context, state) {
                  final friendUid = state.pathParameters['friendUid']!;
                  final tab =
                      state.uri.queryParameters['tab'] == 'wishlist' ? 1 : 0;
                  return FriendVaultScreen(
                    friendUid: friendUid,
                    initialTab: tab,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Shell — bottom nav bar wrapper (screens wired in later modules)
// ---------------------------------------------------------------------------
class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});
  final Widget child;

  static const _tabs = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard', route: AppRoutes.dashboard),
    (icon: Icons.style_rounded, label: 'Vault', route: AppRoutes.portfolio),
    (icon: Icons.calculate_rounded, label: 'Submit', route: AppRoutes.submission),
    (icon: Icons.trending_up_rounded, label: 'Forecast', route: AppRoutes.forecast),
    (icon: Icons.people_rounded, label: 'Connect', route: AppRoutes.connect),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t.route));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (i) => context.go(_tabs[i].route),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

// Placeholder — replaced screen-by-screen in later modules
class _SplashPlaceholder extends ConsumerWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state is already watched in appRouter — this just shows a spinner
    // while the redirect guard evaluates. The guard handles navigation.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💎', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenPlaceholder extends StatelessWidget {
  const _ScreenPlaceholder({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(name, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
