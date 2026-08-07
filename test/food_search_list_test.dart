import 'package:calorie_tracker/data/db/database.dart';
import 'package:calorie_tracker/data/offline/region_pack_store.dart';
import 'package:calorie_tracker/data/repositories/food_repository.dart';
import 'package:calorie_tracker/data/sources/off_api.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers.dart';
import 'package:calorie_tracker/ui/food/food_search_list.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canned-result repository: no DB, no network (per the widget_test.dart
/// convention drift's real async would deadlock under FakeAsync — the lazy
/// in-memory DB is never opened).
class _StubFoodRepo extends FoodRepository {
  _StubFoodRepo(this.foods)
    : super(AppDatabase(NativeDatabase.memory()), OffApi(), RegionPackStore());

  final List<Food> foods;

  @override
  Future<List<Food>> searchLocal(String query) async =>
      query.trim().isEmpty ? const [] : foods;

  @override
  Future<List<Food>> searchOnline(String query) async => const [];
}

Food _food(int id, FoodSource source, String name, {String? barcode}) => Food(
  id: id,
  source: source,
  barcode: barcode,
  name: name,
  kcal100: 100,
  isFavorite: false,
  usageCount: 0,
  updatedAt: DateTime(2026, 8, 7),
);

void main() {
  testWidgets('source chips appear while typing and filter results', (
    tester,
  ) async {
    final repo = _StubFoodRepo([
      _food(1, FoodSource.swissFcdb, 'Chicken, breast, raw'),
      _food(2, FoodSource.openFoodFacts, 'Chicken Nuggets', barcode: '761'),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [foodRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: FoodSearchList(onPick: (_) {})),
        ),
      ),
    );
    await tester.pump();

    // No chips on the default (recents) list.
    expect(find.byType(FilterChip), findsNothing);

    await tester.enterText(find.byType(TextField), 'chicken');
    await tester.pump();
    // Let the 600 ms online debounce fire and its local refresh settle.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.byType(FilterChip), findsNWidgets(3));
    expect(find.text('Chicken, breast, raw'), findsOneWidget);
    expect(find.text('Chicken Nuggets'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Swiss DB'));
    await tester.pump();
    expect(find.text('Chicken, breast, raw'), findsOneWidget);
    expect(find.text('Chicken Nuggets'), findsNothing);

    // Tapping the active chip again clears the filter.
    await tester.tap(find.widgetWithText(FilterChip, 'Swiss DB'));
    await tester.pump();
    expect(find.text('Chicken Nuggets'), findsOneWidget);
  });
}
