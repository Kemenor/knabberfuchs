import 'package:calorie_tracker/domain/nutrition_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a German label, prefers kcal, sub-rows not confused', () {
    final n = parseNutritionLabel([
      'Nährwerte pro 100 g',
      'Energie 2000 kJ / 480 kcal',
      'Fett 25 g',
      'davon gesättigte Fettsäuren 12 g',
      'Kohlenhydrate 50 g',
      'davon Zucker 30 g',
      'Eiweiß 8 g',
      'Salz 1,2 g',
    ]);
    expect(n.kcal100, 480);
    expect(n.fat100, 25);
    expect(n.satFat100, 12);
    expect(n.carb100, 50);
    expect(n.sugar100, 30);
    expect(n.protein100, 8);
    expect(n.saltG100, 1.2);
  });

  test('parses English + French keywords', () {
    final en = parseNutritionLabel([
      'Energy 1000 kJ / 240 kcal',
      'Fat 10g',
      'of which saturates 4g',
      'Carbohydrate 30g',
      'of which sugars 12g',
      'Protein 5g',
      'Salt 0.5g',
    ]);
    expect(en.kcal100, 240);
    expect(en.satFat100, 4);
    expect(en.sugar100, 12);
    expect(en.fat100, 10);

    final fr = parseNutritionLabel([
      'Énergie 1500 kJ / 360 kcal',
      'Matières grasses 20 g',
      'dont acides gras saturés 9 g',
      'Glucides 40 g',
      'dont sucres 15 g',
      'Protéines 6 g',
      'Sel 1 g',
    ]);
    expect(fr.kcal100, 360);
    expect(fr.fat100, 20);
    expect(fr.satFat100, 9);
    expect(fr.carb100, 40);
    expect(fr.sugar100, 15);
    expect(fr.protein100, 6);
  });

  test('converts kJ to kcal when no kcal present', () {
    final n = parseNutritionLabel(['Energie 2000 kJ']);
    expect(n.kcal100, closeTo(478, 1)); // 2000 / 4.184
  });

  test('reads grouped energy figures (Swiss/German/French/English)', () {
    // Regression: "2'000 kJ" first-matched as "000 kj" -> 0 kcal, accepted.
    expect(parseNutritionLabel(["Energie 2'000 kJ"]).kcal100, closeTo(478, 1));
    expect(parseNutritionLabel(['Energie 2’000 kJ']).kcal100, closeTo(478, 1));
    // German dot grouping: 1.046 kJ is 1046 kJ, not 1.046 kJ (0.25 kcal).
    expect(
      parseNutritionLabel(['Brennwert 1.046 kJ']).kcal100,
      closeTo(250, 1),
    );
    expect(parseNutritionLabel(['énergie 2 000 kJ']).kcal100, closeTo(478, 1));
    expect(
      parseNutritionLabel(['Energy 1,046 kJ / 250 kcal']).kcal100,
      closeTo(250, 1),
    );
    // A decimal comma is not grouping.
    expect(parseNutritionLabel(['Energie 473,0 kJ']).kcal100, closeTo(113, 1));
  });

  test('hasAny false on irrelevant text', () {
    expect(parseNutritionLabel(['Ingredients: water, sugar']).hasAny, isFalse);
  });

  test('rejects physically impossible values (OCR misreads)', () {
    final n = parseNutritionLabel([
      'Fett 159 g', // "1,5" misread -> impossible (>100 g/100 g)
      'Brennwert 9999 kcal',
      'Eiweiß 12 g', // plausible -> kept
    ]);
    expect(n.fat100, isNull);
    expect(n.kcal100, isNull);
    expect(n.protein100, 12);
  });
}
