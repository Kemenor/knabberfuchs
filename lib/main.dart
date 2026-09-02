import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/dev_seed.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load date-symbol data so DateFormat can render de/fr/it month + weekday names.
  await initializeDateFormatting();

  // Debug-only sample data: run with `--dart-define=SEED=1`. Idempotent.
  const seedEnv = String.fromEnvironment('SEED');
  if (seedEnv.isNotEmpty) {
    final container = ProviderContainer();
    await maybeSeedDevData(container.read(dbProvider));
    runApp(
      UncontrolledProviderScope(container: container, child: const CalorieApp()),
    );
    return;
  }
  runApp(const ProviderScope(child: CalorieApp()));
}
