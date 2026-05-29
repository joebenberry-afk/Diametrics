import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_tokens.dart';

/// The persistent scaffold that hosts the four primary tabs.
///
/// Used by `StatefulShellRoute.indexedStack` in [app_router.dart]. Each tab
/// owns its own Navigator (managed by [StatefulNavigationShell]) so pushing
/// a sub-route inside one tab does not affect the others.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTabSelected(int index) {
    // `goBranch` preserves the destination branch's navigator stack unless
    // the user re-taps the active tab, in which case it pops back to root.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor:
            isDark ? AppThemeTokens.bgSurfaceDark : AppThemeTokens.bgSurface,
        indicatorColor:
            AppThemeTokens.brandPrimary.withValues(alpha: 0.15),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home),
            selectedIcon: Icon(
              LucideIcons.home,
              color: AppThemeTokens.brandPrimary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.trendingUp),
            selectedIcon: Icon(
              LucideIcons.trendingUp,
              color: AppThemeTokens.brandPrimary,
            ),
            label: 'Trends',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.plusCircle),
            selectedIcon: Icon(
              LucideIcons.plusCircle,
              color: AppThemeTokens.brandPrimary,
            ),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            selectedIcon: Icon(
              LucideIcons.user,
              color: AppThemeTokens.brandPrimary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
