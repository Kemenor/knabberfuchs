import 'package:calorie_tracker/domain/ai_block.dart';
import 'package:calorie_tracker/domain/enums.dart';
import 'package:calorie_tracker/domain/units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('finds the block inside a chatty answer with a code fence', () {
    final b = findAiBlock('''
Sure! Here's my estimate — the rice portion is a guess.

```json
{"knabberfuchs": 1, "kind": "meal", "name": "Lunch bowl", "meal": "lunch",
 "items": [
  {"name": "Chicken breast, grilled", "g": 150, "kcal": 248, "protein": 46, "carbs": 0, "fat": 5.4, "fiber": 0, "salt": 0.3},
  {"name": "Rice, cooked", "g": 180, "kcal": 234, "protein": 4.3, "carbs": 51, "fat": 0.5}
 ]}
```

Enjoy {your} meal!
''')!;
    expect(b.isRecipe, isFalse);
    expect(b.name, 'Lunch bowl');
    expect(b.meal, MealType.lunch);
    expect(b.items, hasLength(2));
    final chicken = b.items.first;
    expect(chicken.gramsIfKnown, 150);
    expect(chicken.estimate!.kcal, 248);
    expect(chicken.estimate!.protein, 46);
    expect(chicken.estimate!.micros, {'fiber': 0.0, 'salt': 0.3});
  });

  test('a recipe block: amounts without nutrition must be matched', () {
    final b = findAiBlock(
      '{"knabberfuchs": 1, "kind": "recipe", "name": "Chili", "servings": 4, '
      '"items": [{"name": "Beef mince, lean", "g": 500}, '
      '{"name": "Olive oil", "amount": 1, "unit": "tbsp"}, '
      '{"name": "Onion", "amount": 2}]}',
    )!;
    expect((b.isRecipe, b.servings), (true, 4));
    expect(b.items.every((i) => i.estimate == null), isTrue);
    expect(b.items[0].gramsIfKnown, 500);
    expect((b.items[1].unit, b.items[1].amount), (AmountUnit.tablespoon, 1));
    expect((b.items[2].isCount, b.items[2].amount), (true, 2));
  });

  test('ml for drinks; an estimate without a weight is still an estimate', () {
    final b = findAiBlock(
      '{"knabberfuchs":1,"items":[{"name":"Orange juice","ml":250,"kcal":110},'
      '{"name":"Apple","kcal":80}]}',
    )!;
    expect(b.items[0].unit, AmountUnit.milliliters);
    expect(b.items[1].gramsIfKnown, isNull);
    expect(b.items[1].estimate!.kcal, 80);
  });

  test('a date is kept only in yyyy-MM-dd form', () {
    expect(
      findAiBlock('{"knabberfuchs":1,"date":"2026-11-12","items":[]}')!.day,
      '2026-11-12',
    );
    expect(
      findAiBlock('{"knabberfuchs":1,"date":"yesterday","items":[]}')!.day,
      isNull,
    );
  });

  test('no block, or JSON without the marker → null', () {
    expect(findAiBlock('- 200 g flour\n- 2 eggs'), isNull);
    expect(findAiBlock('{"items": [{"name": "x", "g": 1}]}'), isNull);
    expect(findAiBlock('{"knabberfuchs": 1, "items": [ broken'), isNull);
  });
}
