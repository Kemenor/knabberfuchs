import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/trends/trends_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a BarChart and summary for logged days', (tester) async {
    const target = CalorieTarget(1800, 2200);
    final trends = [
      for (var i = 0; i < 7; i++)
        () {
          final kcal = i == 1 ? 0.0 : 1500.0 + i * 200; // one empty day
          return DayTrend(
            date: DateTime(2026, 6, 15 + i),
            kcal: kcal,
            target: target,
            status: statusFor(kcal, target),
          );
        }(),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [trendsProvider.overrideWith((ref) => Stream.value(trends))],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TrendsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The chart builds (fl_chart construction would throw here otherwise) and
    // the summary card shows.
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('Average / day'), findsOneWidget);
    expect(find.text('Days in target'), findsOneWidget);
  });

  testWidgets('shows the empty state when nothing is logged', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trendsProvider.overrideWith(
            (ref) => Stream.value([
              DayTrend(
                date: DateTime(2026, 6, 15),
                kcal: 0,
                target: const CalorieTarget(null, null),
                status: TargetStatus.none,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TrendsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BarChart), findsNothing);
    expect(find.textContaining('No entries yet'), findsOneWidget);
  });
}
