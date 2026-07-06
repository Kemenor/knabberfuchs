import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/repositories/diary_repository.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/food/log_food_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives the log-food sheet end-to-end: sheet UI -> amount x unit x density
/// -> grams handed to the diary repository. This is the one UI spot where a
/// regression silently alters stored numbers, so the math is pinned through
/// the real widget, not just units_test.
///
/// Per the widget_test.dart convention there is NO real DB under testWidgets
/// (drift's real async deadlocks against FakeAsync): a recording repository
/// captures what would be stored.
class _RecordingDiaryRepo extends DiaryRepository {
  // The lazy in-memory DB is never opened — no query ever runs on it.
  _RecordingDiaryRepo() : super(AppDatabase(NativeDatabase.memory()));

  final logged = <({double grams, MealType meal, String day})>[];

  @override
  Future<void> logFood({
    required Food food,
    required double grams,
    required MealType meal,
    required String day,
    int? groupId,
    String? displayName,
  }) async {
    logged.add((grams: grams, meal: meal, day: day));
  }
}

Food _food({double? servingG, double? density, double kcal100 = 400}) => Food(
  id: 1,
  source: FoodSource.custom,
  name: 'Test Food',
  kcal100: kcal100,
  protein100: 10,
  servingG: servingG,
  densityGPerMl: density,
  isFavorite: false,
  usageCount: 0,
  updatedAt: DateTime(2026, 7, 6),
);

void main() {
  const day = '2026-07-06';
  late _RecordingDiaryRepo repo;

  setUp(() => repo = _RecordingDiaryRepo());

  Future<void> openSheet(WidgetTester tester, Food food) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [diaryRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (ctx, ref, _) => ElevatedButton(
                onPressed: () => showLogFoodSheet(
                  ctx,
                  ref,
                  food: food,
                  day: day,
                  meal: MealType.lunch,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    // Bounded pumps, not pumpAndSettle: the amount field autofocuses and its
    // blinking cursor keeps scheduling frames, so pumpAndSettle never settles.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<({double grams, MealType meal, String day})> submit(
    WidgetTester tester,
  ) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return repo.logged.single;
  }

  testWidgets('solid food defaults to its serving weight in grams', (
    tester,
  ) async {
    await openSheet(tester, _food(servingG: 30));

    // Prefilled with the natural portion, unit g, live kcal = 400*30/100.
    expect(find.widgetWithText(TextField, '30'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);

    final logged = await submit(tester);
    expect(logged.grams, 30);
    expect(logged.day, day);
    expect(logged.meal, MealType.lunch);
  });

  testWidgets('typed amount in grams is passed verbatim', (tester) async {
    await openSheet(tester, _food(servingG: 30));

    await tester.enterText(find.byType(TextField), '150');
    await tester.pump();
    expect(find.text('600'), findsOneWidget); // 400 kcal/100g * 150g

    expect((await submit(tester)).grams, 150);
  });

  testWidgets('liquid opens in ml and converts via its density', (
    tester,
  ) async {
    await openSheet(tester, _food(density: 1.03, kcal100: 60));

    // Liquids open in ml with the typical 200 ml prefill.
    expect(find.widgetWithText(TextField, '200'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();

    // 100 ml * 1.03 g/ml = 103 g -> 60 kcal/100g * 103g = 61.8 -> "62".
    expect(find.text('62'), findsOneWidget);
    expect((await submit(tester)).grams, closeTo(103, 1e-9));
  });

  testWidgets('tbsp converts at 15 ml with water-like default density', (
    tester,
  ) async {
    await openSheet(tester, _food());

    await tester.tap(find.widgetWithText(ChoiceChip, 'tbsp'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '2');
    await tester.pump();

    // 2 tbsp * 15 ml * 1.0 g/ml = 30 g.
    expect((await submit(tester)).grams, closeTo(30, 1e-9));
  });

  testWidgets('the serving chip restores the natural portion', (tester) async {
    await openSheet(tester, _food(servingG: 30));

    await tester.enterText(find.byType(TextField), '250');
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, '1 serving (30 g)'));
    await tester.pump();

    expect((await submit(tester)).grams, 30);
  });

  testWidgets('zero or unparsable amounts disable Add and log nothing', (
    tester,
  ) async {
    await openSheet(tester, _food(servingG: 30));

    for (final bad in ['0', '', '.']) {
      await tester.enterText(find.byType(TextField), bad);
      await tester.pump();
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Add'),
      );
      expect(button.onPressed, isNull, reason: 'amount "$bad"');
    }
    expect(repo.logged, isEmpty);
  });
}
