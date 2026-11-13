import 'package:calorie_tracker/core/date_x.dart';
import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/domain/weight.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/weight/weight_day_row.dart';
import 'package:calorie_tracker/ui/weight/weight_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The weight Day row and sheet render from providers alone (no real DB
/// under testWidgets — see widget_test.dart): a week of weigh-ins, two today.
void main() {
  final today = DayKey.today();
  var id = 0;
  BodyMeasurement w(
    String day,
    double kg, {
    int hour = 7,
    bool counts = false,
  }) {
    final d = DayKey.parse(day);
    return BodyMeasurement(
      id: ++id,
      kind: MeasurementKind.weight,
      day: day,
      measuredAt: DateTime(d.year, d.month, d.day, hour),
      value: kg,
      source: hour == 6 ? MeasurementSource.health : MeasurementSource.manual,
      countsForDay: counts,
      hidden: false,
    );
  }

  final rows = [
    for (var i = 13; i >= 1; i--)
      w(DayKey.shift(today, -i), 88 - (13 - i) * 0.1),
    w(today, 86.6, hour: 6),
    w(today, 87.4, hour: 12),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool track = true,
    List<double> goals = const [80],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackWeightProvider.overrideWith((ref) => Stream.value(track)),
          weightUnitProvider.overrideWith((ref) => Stream.value(WeightUnit.kg)),
          weightGoalsProvider.overrideWith((ref) => Stream.value(goals)),
          heightCmProvider.overrideWith((ref) => Stream.value(null)),
          weightsProvider.overrideWith((ref) => Stream.value(rows)),
          dayWeighInsProvider.overrideWith(
            (ref, day) =>
                Stream.value(rows.where((r) => r.day == day).toList()),
          ),
          showTrendsProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Day row: the trend leads, today small, colour by goal', (
    tester,
  ) async {
    await pump(tester, WeightDayRow(day: today));
    // Trailing 7 days: 87.3 … 86.8, today 86.6 (the first counts) → 87.0.
    expect(find.textContaining('87.0 kg'), findsOneWidget);
    expect(find.textContaining('this week'), findsOneWidget);
    expect(find.text('Today 86.6 kg'), findsOneWidget);
  });

  testWidgets('Day row hides while Track weight is off', (tester) async {
    await pump(tester, WeightDayRow(day: today), track: false);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('Day row before the weigh-in offers to add it', (tester) async {
    final tomorrow = DayKey.shift(today, 1);
    await pump(tester, WeightDayRow(day: tomorrow));
    expect(find.text('Add a weight'), findsOneWidget);
  });

  testWidgets('sheet: first counts, Health rows are not editable', (
    tester,
  ) async {
    await pump(tester, WeightSheet(day: today));
    expect(find.text('Weigh-ins'), findsOneWidget);
    expect(find.text('counts · first'), findsOneWidget);
    expect(find.textContaining('from '), findsOneWidget);
    expect(find.textContaining('added here'), findsOneWidget);

    // The Health row (first) offers no "Edit" and no "Count this one".
    await tester.tap(find.byTooltip('Show menu').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Count this one'), findsNothing);
    expect(find.text('Remove'), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    // The manual one can be counted and edited.
    await tester.tap(find.byTooltip('Show menu').last);
    await tester.pumpAndSettle();
    expect(find.text('Count this one'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('87.4'), findsOneWidget); // value moved into the field
  });
}
