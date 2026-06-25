import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'day/day_screen.dart';
import 'recipes/recipes_screen.dart';
import 'settings/settings_screen.dart';
import 'trends/trends_screen.dart';

/// Root navigation: a bottom bar switching between the top-level destinations.
/// Order is **Day, [Trends], Recipes, Settings** — the Trends tab is optional
/// (toggled in Settings via [showTrendsProvider]). Day is always index 0 (the
/// only programmatic jump target). Tabs keep their state (IndexedStack) so
/// switching never resets scroll position or an in-progress search.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final showTrends = ref.watch(showTrendsProvider).asData?.value ?? true;

    final pages = <Widget>[
      const DayScreen(),
      if (showTrends) const TrendsScreen(),
      const RecipesScreen(),
      const SettingsScreen(),
    ];
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.today_outlined),
        selectedIcon: const Icon(Icons.today),
        label: l10n.navDay,
      ),
      if (showTrends)
        NavigationDestination(
          icon: const Icon(Icons.insights_outlined),
          selectedIcon: const Icon(Icons.insights),
          label: l10n.navTrends,
        ),
      NavigationDestination(
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon: const Icon(Icons.menu_book),
        label: l10n.navRecipes,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.navSettings,
      ),
    ];

    // Clamp so toggling Trends off while on a later tab can't point past the
    // (now shorter) list.
    final index = ref.watch(homeTabProvider).clamp(0, pages.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(homeTabProvider.notifier).set(i),
        destinations: destinations,
      ),
    );
  }
}
