import 'package:calorie_tracker/domain/ai_block.dart';
import 'package:calorie_tracker/domain/ai_instructions.dart';
import 'package:calorie_tracker/domain/day_summary.dart';
import 'package:flutter_test/flutter_test.dart';

DayTotals _day(String day, double kcal, {double protein = 0}) => (
  day: day,
  kcal: kcal,
  protein: protein,
  carb: 0,
  fat: 0,
  fiber: 0,
  satFat: 0,
  sugar: 0,
  salt: 0,
);

void main() {
  group('buildAiInstructions', () {
    test('log-a-meal: language, targets, tracked micros', () {
      final text = buildAiInstructions(
        AiTask.logMeal,
        language: 'de',
        kcal: const CalorieTarget(1800, 2200),
        nutrients: const {TargetMetric.protein: CalorieTarget(120, null)},
        tracked: const {TargetMetric.protein, TargetMetric.fiber},
      );
      expect(text, contains('Talk to me in German.'));
      expect(text, contains('Write the food names in German'));
      expect(
        text,
        contains('My daily targets: 1800–2200 kcal, protein at least 120 g.'),
      );
      expect(text, contains('Also give "fiber" in grams'));
      expect(text, isNot(contains('"sugar"'))); // not tracked
    });

    test("the example block is one the importer reads", () {
      for (final task in AiTask.values) {
        final text = buildAiInstructions(task, language: 'en');
        final block = findAiBlock(text);
        expect(block, isNotNull, reason: task.name);
        expect(block!.items, isNotEmpty);
        expect(block.isRecipe, task == AiTask.adaptRecipe);
      }
    });

    test('adapt-a-recipe asks for amounts only; no targets → no line', () {
      final text = buildAiInstructions(AiTask.adaptRecipe, language: 'it');
      expect(text, contains('Talk to me in Italian.'));
      expect(text, contains('Leave out nutrition values'));
      expect(text, isNot(contains('My daily targets')));
    });
  });

  test('buildShareSummary: every day, gaps marked, averages over logged', () {
    final text = buildShareSummary(
      days: const ['2026-11-11', '2026-11-12', '2026-11-13'],
      totals: {
        '2026-11-11': _day('2026-11-11', 1900, protein: 110),
        '2026-11-13': _day('2026-11-13', 2100, protein: 130),
      },
      kcal: const CalorieTarget(1800, 2200),
      tracked: const {TargetMetric.protein},
    );
    expect(text, contains('3 days (2026-11-11 to 2026-11-13)'));
    expect(text, contains('day | kcal | protein (g)'));
    expect(text, contains('2026-11-11 | 1900 | 110'));
    expect(text, contains('2026-11-12 | nothing logged'));
    expect(
      text,
      contains('Average over 2 logged days: 2000 kcal, 120 g protein'),
    );
  });
}
