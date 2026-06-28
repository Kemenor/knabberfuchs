import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuchsbau/fuchsbau.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'core/format.dart';
import 'core/locale.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'ui/home_shell.dart';

class CalorieApp extends ConsumerStatefulWidget {
  const CalorieApp({super.key});

  @override
  ConsumerState<CalorieApp> createState() => _CalorieAppState();
}

class _CalorieAppState extends ConsumerState<CalorieApp> {
  void _syncNumberLocale(AsyncValue<Locale?> v) {
    // Point the number formatters at the resolved UI locale (decimal comma in
    // de/fr/it).
    setNumberLocale(resolveUiLocale(v.asData?.value?.languageCode));
  }

  @override
  void initState() {
    super.initState();
    // Seed from the current value; updates arrive via ref.listen in build.
    _syncNumberLocale(ref.read(localeProvider));
  }

  @override
  Widget build(BuildContext context) {
    // null until the setting stream resolves → falls back to the device locale.
    final locale = ref.watch(localeProvider).asData?.value;
    // Keep the number formatters in sync as the locale changes — done via
    // listen (a side effect) rather than inline so build() stays pure.
    ref.listen(localeProvider, (_, next) => _syncNumberLocale(next));
    final font =
        ref.watch(fontProvider).asData?.value ?? FuchsbauFont.figtree;
    final themeMode =
        ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light, font: font),
      darkTheme: buildTheme(Brightness.dark, font: font),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _Startup(),
    );
  }
}

/// Runs one-time startup work (USDA seeding) behind a splash, then shows the app.
class _Startup extends ConsumerWidget {
  const _Startup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);
    return startup.when(
      data: (_) => const HomeShell(),
      loading: () => const _Splash(),
      // Seeding failures are non-fatal — fall through to the app.
      error: (_, _) => const HomeShell(),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.restaurant_menu_rounded, size: 56),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).splashPreparing),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
