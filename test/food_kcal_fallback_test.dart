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
      // eggplant should fall through to the vegetable category, not egg (155).
      final eggplant = portionForLabel('eggplant parmesan');
      expect(eggplant?.kcal100, isNot(155));
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
      expect(p.kcal, (p.kcal100 * p.grams / 100).round());
    });
  });
}
