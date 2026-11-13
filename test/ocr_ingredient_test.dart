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

  group('written lists (pasted from an AI app or a website)', () {
    test('amount first, with bullets, numbering and markdown', () {
      final r = parseIngredientLines([
        '- 200 g flour',
        '* 200g sugar',
        '1. 2 eggs',
        '• ½ cup milk',
        '- **400 g** kidney beans, drained',
        '- [ ] 1 1/2 tsp salt',
      ]);
      expect(r.map((i) => i.name), [
        'flour',
        'sugar',
        'eggs',
        'milk',
        'kidney beans, drained',
        'salt',
      ]);
      expect(r[0].gramsIfKnown, 200);
      expect(r[1].gramsIfKnown, 200);
      expect((r[2].amount, r[2].isCount, r[2].rawUnit), (2, true, 'x'));
      expect((r[3].amount, r[3].unit), (0.5, AmountUnit.cup));
      expect(r[4].gramsIfKnown, 400);
      expect((r[5].amount, r[5].unit), (1.5, AmountUnit.teaspoon));
    });

    test('count units come before the name', () {
      final r = parseIngredientLines(['2 slices rye bread', '3 cloves garlic']);
      expect(
        (r[0].name, r[0].amount, r[0].rawUnit),
        ('rye bread', 2, 'slices'),
      );
      expect((r[1].name, r[1].rawUnit), ('garlic', 'cloves'));
    });

    test('German, French and Italian units', () {
      final r = parseIngredientLines([
        '200 g Mehl',
        '2 EL Olivenöl',
        '1 TL Salz',
        '1 Prise Pfeffer',
        '2 dl Rahm',
        "1 c. à soupe d'huile d'olive",
        '3 gousses ail',
        '2 cucchiai di zucchero',
        '1 spicchio aglio',
      ]);
      expect(r, hasLength(9));
      expect((r[1].name, r[1].unit), ('Olivenöl', AmountUnit.tablespoon));
      expect(r[2].unit, AmountUnit.teaspoon);
      expect((r[3].name, r[3].rawUnit), ('Pfeffer', 'prise'));
      expect(r[4].gramsIfKnown, 200); // 2 dl = 200 ml
      expect((r[5].name, r[5].unit), ("huile d'olive", AmountUnit.tablespoon));
      expect((r[6].name, r[6].rawUnit), ('ail', 'gousses'));
      expect((r[7].name, r[7].unit), ('zucchero', AmountUnit.tablespoon));
      expect(r[8].rawUnit, 'spicchio');
    });

    test('trailing form with a separator still works', () {
      final r = parseIngredientLines([
        'Olive oil: 2 tbsp',
        'Rice – 180 g',
        'Butter (10 g)',
      ]);
      expect(r.map((i) => i.name), ['Olive oil', 'Rice', 'Butter']);
      expect(r[2].gramsIfKnown, 10);
    });

    test('time, energy and nutrition summaries are not ingredients', () {
      final r = parseIngredientLines([
        '1. Preheat the oven to 200 °C',
        '10 minutes',
        '- Protein: 45 g',
        '- 520 kcal per serving',
        'Salt to taste',
      ]);
      expect(r, isEmpty);
    });
  });

  group('parseIngredientText', () {
    test('an AI answer: prose, heading, servings, list', () {
      final list = parseIngredientText('''
Here's your chili adapted to 600 kcal per serving:

## Chili con carne (lighter)
Serves 4

- 500 g lean beef mince
- 400 g kidney beans
- 2 tbsp olive oil
- 1 onion

Per serving: about 600 kcal.
''');
      expect(list.title, 'Chili con carne (lighter)');
      expect(list.servings, 4);
      expect(list.items.map((i) => i.name), [
        'lean beef mince',
        'kidney beans',
        'olive oil',
        'onion',
      ]);
    });

    test('a bare list has no title; "4 Portionen" is servings', () {
      final list = parseIngredientText('Für 4 Portionen\n200 g Mehl\n2 Eier');
      expect(list.title, isNull);
      expect(list.servings, 4);
      expect(list.items, hasLength(2));
    });

    test('a short plain first line is a title, a section header is not', () {
      expect(
        parseIngredientText('Overnight oats\n50 g oats').title,
        'Overnight oats',
      );
      expect(parseIngredientText('Ingredients:\n50 g oats').title, isNull);
    });
  });

  test('normalizeOcrName folds accents and punctuation', () {
    expect(normalizeOcrName('Crème Fraîche'), 'creme fraiche');
    expect(normalizeOcrName('creme fraiche'), 'creme fraiche');
    expect(normalizeOcrName('  Olive   Oil! '), 'olive oil');
  });
}
