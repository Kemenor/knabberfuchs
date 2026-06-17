import 'package:calorie_tracker/domain/units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('grams pass through', () {
    expect(AmountUnit.grams.toGrams(150), 150);
    expect(AmountUnit.grams.isVolume, isFalse);
  });

  test('volume units convert via ml * density', () {
    expect(AmountUnit.milliliters.toGrams(100), 100); // water
    expect(AmountUnit.tablespoon.toGrams(2), 30); // 2*15ml*1.0
    expect(AmountUnit.teaspoon.toGrams(1), 5);
    expect(AmountUnit.cup.toGrams(1), 240);
  });

  test('density applies to volumes only', () {
    expect(AmountUnit.tablespoon.toGrams(2, density: 0.92), closeTo(27.6, 0.001));
    expect(AmountUnit.grams.toGrams(100, density: 0.92), 100);
  });

  test('labels', () {
    expect(AmountUnit.tablespoon.label, 'tbsp');
    expect(AmountUnit.grams.label, 'g');
  });
}
