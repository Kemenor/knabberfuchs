import 'package:calorie_tracker/domain/nutrition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nutrition.fromPer100g', () {
    test('scales by grams', () {
      final n = Nutrition.fromPer100g(
        kcal100: 52,
        protein100: 0.3,
        carb100: 14,
        fat100: 0.2,
        grams: 150,
      );
      expect(n.kcal, closeTo(78, 0.001));
      expect(n.protein, closeTo(0.45, 0.001));
      expect(n.carb, closeTo(21, 0.001));
      expect(n.fat, closeTo(0.3, 0.001));
    });

    test('scales micros too', () {
      final n = Nutrition.fromPer100g(
        kcal100: 100,
        micros100: {'iron_mg': 2.0},
        grams: 50,
      );
      expect(n.micros['iron_mg'], closeTo(1.0, 0.001));
    });

    test('null macros treated as zero', () {
      final n = Nutrition.fromPer100g(kcal100: 200, grams: 100);
      expect(n.protein, 0);
      expect(n.carb, 0);
      expect(n.fat, 0);
    });
  });

  group('Nutrition aggregation', () {
    test('+ adds macros and merges micros', () {
      const a = Nutrition(kcal: 100, protein: 5, micros: {'iron_mg': 1});
      const b = Nutrition(
        kcal: 50,
        protein: 2,
        micros: {'iron_mg': 2, 'zinc_mg': 1},
      );
      final c = a + b;
      expect(c.kcal, 150);
      expect(c.protein, 7);
      expect(c.micros['iron_mg'], 3);
      expect(c.micros['zinc_mg'], 1);
    });

    test('sum of empty is zero', () {
      expect(Nutrition.sum([]).kcal, 0);
    });
  });

  group('micros codec', () {
    test('round-trips', () {
      final json = encodeMicros({'iron_mg': 1.5, 'zinc_mg': 0.4});
      final back = decodeMicros(json);
      expect(back['iron_mg'], 1.5);
      expect(back['zinc_mg'], 0.4);
    });

    test('empty encodes to null', () {
      expect(encodeMicros({}), isNull);
    });

    test('garbage decodes to empty', () {
      expect(decodeMicros('not json'), isEmpty);
      expect(decodeMicros(null), isEmpty);
    });
  });
}
