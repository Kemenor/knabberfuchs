import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'ui/home_shell.dart';

class CalorieApp extends ConsumerWidget {
  const CalorieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // null until the setting stream resolves → falls back to the device locale.
    final locale = ref.watch(localeProvider).asData?.value;
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
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
            const Icon(Icons.restaurant_menu, size: 56),
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
