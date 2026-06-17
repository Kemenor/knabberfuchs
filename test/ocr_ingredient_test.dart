import 'package:calorie_tracker/domain/ocr_ingredient.dart';
import 'package:calorie_tracker/domain/units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses real Sidekick ingredient lines', () {
    final r = parseIngredientLines([
      'Echalion Shallots 200g',
      'Balsamic Vinegar 2 tbsp',
      'Caster Sugar 1 tsp',
      'Crème Fraîche 150g',
      'Garlic 2 cloves',
      'Lemon 1x',
      'Smal Red Cabbage 0.5x',
      'Little Gem Lettuces 2 heads',
      'Flatbreads 4x',
    ]);
    expect(r, hasLength(9));

    final shallots = r.first;
    expect(shallots.name, 'Echalion Shallots');
    expect(shallots.amount, 200);
    expect(shallots.unit, AmountUnit.grams);
    expect(shallots.gramsIfKnown, 200);

    final vinegar = r[1];
    expect(vinegar.unit, AmountUnit.tablespoon);
    expect(vinegar.gramsIfKnown, 30); // 2 * 15ml

    final garlic = r[4];
    expect(garlic.name, 'Garlic');
    expect(garlic.amount, 2);
    expect(garlic.isCount, isTrue);
    expect(garlic.rawUnit, 'cloves');
    expect(garlic.gramsIfKnown, isNull);

    expect(r[6].amount, 0.5); // 0.5x cabbage
    expect(r[7].rawUnit, 'heads');
  });

  test('kg / l normalize to grams / ml', () {
    final r = parseIngredientLines(['Flour 1.5kg', 'Stock 1l', 'Milk 250ml']);
    expect(r[0].gramsIfKnown, 1500);
    expect(r[1].gramsIfKnown, 1000);
    expect(r[2].gramsIfKnown, 250);
  });

  test('skips non-ingredient lines', () {
    final r = parseIngredientLines([
      'Method',
      'Serves 4 people',
      'Prep 30 mins',
      'Total 520 kcal',
      'Ingredients',
    ]);
    expect(r, isEmpty);
  });

  test('grabs the trailing quantity even if the name contains a number', () {
    final r = parseIngredientLines(['Omega 3 Fish Oil 200g']);
    expect(r.single.name, 'Omega 3 Fish Oil');
    expect(r.single.amount, 200);
  });
}
