import 'package:calorie_tracker/data/ml/food_kcal_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('portionForLabel', () {
    test('matches a category from a specific dish label', () {
      expect(portionForLabel('Neapolitan pizza')?.grams, 300);
      expect(portionForLabel('Chocolate brownie')?.grams, 80);
      expect(portionForLabel('Caesar salad')?.kcal100, 90);
    });

    test('whole-word match: "egg" does not fire on "eggplant"', () {
      // No category keyword whole-word-matches "eggplant parmesan", so the
      // lookup returns null instead of the egg category (155 kcal/100 g).
      expect(portionForLabel('eggplant parmesan'), isNull);
      // a real egg dish still matches the egg category.
      expect(portionForLabel('scrambled eggs')?.kcal100, 155);
    });

    test('ordering: dessert wins over a generic ingredient word', () {
      // "Russian tea cake" contains "tea" but should be a cake, not a drink.
      expect(portionForLabel('Russian tea cake')?.grams, 120);
    });

    test('plurals match', () {
      expect(portionForLabel('French fries'), isNotNull);
      expect(portionForLabel('chocolate chip cookies')?.grams, 80);
    });

    test('returns null when no category matches', () {
      expect(portionForLabel('quux floozle'), isNull);
    });

    test('kcal computes from grams and density', () {
      final p = portionForLabel('cheeseburger')!;
      expect(p.grams, 250);
      expect(p.kcal100, 250);
      expect(p.kcal, 625); // 250 kcal/100 g * 250 g
    });
  });
}
