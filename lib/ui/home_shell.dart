import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/share_intake.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'day/day_screen.dart';
import 'import/text_import.dart';
import 'recipes/recipes_screen.dart';
import 'settings/settings_screen.dart';
import 'trends/trends_screen.dart';

/// Root navigation: a bottom bar switching between the top-level destinations.
/// Order is **Day, Recipes, [Trends], Settings** — the Trends tab is optional
/// (toggled in Settings via [showTrendsProvider]). Day is always index 0 (the
/// only programmatic jump target). Tabs keep their state (IndexedStack) so
/// switching never resets scroll position or an in-progress search.
///
/// It is also where text shared in from another app lands (Android share
/// sheet → [ShareIntake]): on start and on every new share, the text goes to
/// the Day tab's import review for the day on screen.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    ShareIntake.listen(_takeShare);
    WidgetsBinding.instance.addPostFrameCallback((_) => _takeShare());
  }

  Future<void> _takeShare() async {
    final text = await ShareIntake.take();
    if (text == null || !mounted) return;
    ref.read(homeTabProvider.notifier).set(HomeTab.day);
    await handleImportedText(
      context,
      ref,
      text,
      day: ref.read(selectedDayProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showTrends = ref.watch(showTrendsProvider).asData?.value ?? true;

    final tabs = <HomeTab>[
      HomeTab.day,
      HomeTab.recipes,
      if (showTrends) HomeTab.trends,
      HomeTab.settings,
    ];
    final pages = <Widget>[
      const DayScreen(),
      const RecipesScreen(),
      if (showTrends) const TrendsScreen(),
      const SettingsScreen(),
    ];
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Symbols.today_rounded),
        selectedIcon: const Icon(Symbols.today_rounded, fill: 1),
        label: l10n.navDay,
      ),
      NavigationDestination(
        icon: const Icon(Symbols.menu_book_rounded),
        selectedIcon: const Icon(Symbols.menu_book_rounded, fill: 1),
        label: l10n.navRecipes,
      ),
      if (showTrends)
        NavigationDestination(
          icon: const Icon(Symbols.insights_rounded),
          selectedIcon: const Icon(Symbols.insights_rounded, fill: 1),
          label: l10n.navTrends,
        ),
      NavigationDestination(
        icon: const Icon(Symbols.settings_rounded),
        selectedIcon: const Icon(Symbols.settings_rounded, fill: 1),
        label: l10n.navSettings,
      ),
    ];

    // Selection is a tab identity, so the list growing/shrinking around it
    // never moves the user (enabling Trends while on Settings keeps Settings
    // selected). A selected tab that disappears falls back to Day — only
    // possible via an external settings change, e.g. a backup restore.
    final selected = ref.watch(homeTabProvider);
    final index = tabs.contains(selected) ? tabs.indexOf(selected) : 0;

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) =>
              ref.read(homeTabProvider.notifier).set(tabs[i]),
          destinations: destinations,
        ),
      ),
    );
  }
}
