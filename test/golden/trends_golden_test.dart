import 'dart:io';
import 'dart:typed_data';

import 'package:calorie_tracker/core/theme.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/trends/trends_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden (screenshot) tests for the Trends charts. Seeds a deterministic
/// stretch of days with a target so the bars, status colors and target band all
/// render, and loads the vendored Roboto font so text renders for real.
/// Regenerate after intentional UI changes with:
///   flutter test --update-goldens test/golden/trends_golden_test.dart
/// Goldens are font/AA-sensitive, so Linux is the canonical platform (the dev
/// distrobox + the `test` CI job): regenerate there. Off Linux comparison is
/// skipped — see test/flutter_test_config.dart.
Future<void> _loadRoboto() async {
  final loader = FontLoader('Roboto');
  for (final name in ['Roboto-Regular', 'Roboto-Medium', 'Roboto-Bold']) {
    loader.addFont(
      File('test/golden/fonts/$name.ttf').readAsBytes().then(
        (b) => ByteData.view(Uint8List.fromList(b).buffer),
      ),
    );
  }
  await loader.load();
}

/// Pins the trends window so golden dates (the range header) are deterministic.
class _FixedRange extends TrendRangeNotifier {
  _FixedRange(this._window);
  final TrendWindow _window;
  @override
  TrendWindow build() => _window;
}

void main() {
  setUpAll(_loadRoboto);

  const target = CalorieTarget(1800, 2200);

  /// [days] of deterministic, varied calories ending on a fixed date. A repeating
  /// pattern covers under / in-range / over plus the occasional un-logged day.
  List<DayTrend> seed(int days) {
    const pattern = [1650.0, 2000.0, 2450.0, 1950.0, 0.0, 2200.0, 1500.0];
    final end = DateTime(2026, 6, 21);
    return [
      for (var i = days - 1; i >= 0; i--)
        () {
          final date = end.subtract(Duration(days: i));
          final kcal = pattern[(days - 1 - i) % pattern.length];
          return DayTrend(
            date: date,
            kcal: kcal,
            target: target,
            status: statusFor(kcal, target),
          );
        }(),
    ];
  }

  Widget app(List<DayTrend> trends, TrendWindow window) {
    final base = buildTheme(Brightness.light);
    final theme = base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Roboto'),
    );
    return ProviderScope(
      overrides: [
        trendsProvider.overrideWith((ref) => Stream.value(trends)),
        trendRangeProvider.overrideWith(() => _FixedRange(window)),
        // The chip row and activity note read settings; without these
        // overrides they'd reach the real dbProvider (path_provider) inside
        // a widget test.
        trackedNutrientsProvider.overrideWith(
          (ref) => Stream.value(defaultTrackedNutrients),
        ),
        healthEnergyReadProvider.overrideWith((ref) => Stream.value(false)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TrendsScreen(),
      ),
    );
  }

  testWidgets('trends — week view', (tester) async {
    tester.view.physicalSize = const Size(1080, 1700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        seed(7),
        TrendWindow(
          TrendMode.week,
          0,
          DateTime(2026, 6, 15),
          DateTime(2026, 6, 21),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TrendsScreen),
      matchesGoldenFile('goldens/trends_week.png'),
    );
  });

  testWidgets('trends — month view', (tester) async {
    tester.view.physicalSize = const Size(1080, 1700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        seed(30),
        TrendWindow(
          TrendMode.month,
          0,
          DateTime(2026, 5, 23),
          DateTime(2026, 6, 21),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TrendsScreen),
      matchesGoldenFile('goldens/trends_month.png'),
    );
  });

  testWidgets('trends — week view with customized per-day goals', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // A distinct goal per weekday (Mon=0…Sun=6) so each bar renders its own
    // target zone instead of one shared band.
    const goals = {
      0: CalorieTarget(1800, 2100),
      1: CalorieTarget(1800, 2100),
      2: CalorieTarget(1700, 2000),
      3: CalorieTarget(1900, 2200),
      4: CalorieTarget(2000, 2500),
      5: CalorieTarget(2000, 2700),
      6: CalorieTarget(1600, 2000),
    };
    const pattern = [1650.0, 2000.0, 2450.0, 1950.0, 0.0, 2200.0, 1500.0];
    final end = DateTime(2026, 6, 21);
    final trends = [
      for (var i = 6; i >= 0; i--)
        () {
          final date = end.subtract(Duration(days: i));
          final kcal = pattern[(6 - i) % pattern.length];
          final t = goals[date.weekday - 1]!;
          return DayTrend(
            date: date,
            kcal: kcal,
            target: t,
            status: statusFor(kcal, t),
          );
        }(),
    ];

    await tester.pumpWidget(
      app(
        trends,
        TrendWindow(
          TrendMode.week,
          0,
          DateTime(2026, 6, 15),
          DateTime(2026, 6, 21),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TrendsScreen),
      matchesGoldenFile('goldens/trends_custom_week.png'),
    );
  });

  testWidgets('trends — long custom range aggregates to weekly', (tester) async {
    tester.view.physicalSize = const Size(1080, 1700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // ~4 months of data: the chart collapses to weekly buckets.
    await tester.pumpWidget(
      app(
        seed(120),
        TrendWindow(
          TrendMode.custom,
          0,
          DateTime(2026, 2, 22),
          DateTime(2026, 6, 21),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TrendsScreen),
      matchesGoldenFile('goldens/trends_long_custom.png'),
    );
  });

  testWidgets('trends — multi-year custom range aggregates to monthly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // ~2 years of data: the chart collapses to monthly buckets.
    final trends = seed(800);
    await tester.pumpWidget(
      app(
        trends,
        TrendWindow(
          TrendMode.custom,
          0,
          trends.first.date,
          trends.last.date,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TrendsScreen),
      matchesGoldenFile('goldens/trends_monthly.png'),
    );
  });
}
