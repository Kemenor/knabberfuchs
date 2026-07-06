import 'dart:io';

import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/day/meal_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Meal-detail photo banner: entries carrying a photoPath surface as one
/// tappable image (deduplicated across entries) that opens the full-screen
/// viewer. Everything is driven through provider overrides — per the
/// widget_test.dart convention there is NO real DB under testWidgets.
void main() {
  const day = '2026-07-06';
  final createdAt = DateTime(2026, 7, 6, 12);

  Entry entry(int id, String name, {String? photoPath}) => Entry(
    id: id,
    day: day,
    mealType: MealType.lunch,
    groupId: 1,
    grams: 100,
    sName: name,
    sKcal100: 100,
    sortIndex: 0,
    createdAt: createdAt,
    photoPath: photoPath,
  );

  Future<void> pumpDetail(WidgetTester tester, List<Entry> entries) async {
    final group = EntryGroup(id: 1, day: day, name: 'Lunch', createdAt: createdAt);
    final dir = Directory.systemTemp.createTempSync('meal_detail_photo');
    addTearDown(() => dir.deleteSync(recursive: true));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dayGroupsStreamProvider.overrideWith((ref) => Stream.value([group])),
          daySummaryProvider.overrideWith(
            (ref) => Stream.value(
              DaySummary(day: day, entries: [for (final e in entries) EntryView(e)]),
            ),
          ),
          trackedNutrientsProvider.overrideWith(
            (ref) => Stream.value(defaultTrackedNutrients),
          ),
          mealPhotoDirProvider.overrideWith((ref) async => dir.path),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MealDetailScreen(groupId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('no photoPath -> no banner image', (tester) async {
    await pumpDetail(tester, [entry(1, 'Beans'), entry(2, 'Beef')]);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shared photoPath -> one banner image, tap opens viewer', (
    tester,
  ) async {
    await pumpDetail(tester, [
      entry(1, 'Beans', photoPath: 'a.jpg'),
      entry(2, 'Beef', photoPath: 'a.jpg'),
      entry(3, 'Rice'),
    ]);
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.byType(Image));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });
}
