import 'package:calorie_tracker/domain/recipe_share.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sample = RecipeShare(
    name: 'Porridge',
    servings: 2,
    items: const [
      RecipeShareItem(
        name: 'Oats',
        grams: 100,
        kcal100: 389,
        protein100: 16.9,
        carb100: 66,
        fat100: 6.9,
      ),
      RecipeShareItem(
        name: 'Milk',
        grams: 400,
        kcal100: 64,
        protein100: 3.4,
        carb100: 4.8,
        fat100: 3.6,
      ),
    ],
  );

  group('RecipeShare math', () {
    test('total and totalGrams', () {
      expect(sample.totalGrams, 500);
      // 389 + (64*4) = 389 + 256 = 645
      expect(sample.total.kcal, closeTo(645, 0.001));
    });

    test('perServing divides by servings', () {
      expect(sample.perServing.kcal, closeTo(322.5, 0.001));
    });
  });

  group('RecipeCodec', () {
    test('round-trips through the compact payload', () {
      final encoded = RecipeCodec.encode(sample);
      expect(encoded.startsWith('CTR1:'), isTrue);

      final back = RecipeCodec.decode(encoded)!;
      expect(back.name, 'Porridge');
      expect(back.servings, 2);
      expect(back.items.length, 2);
      expect(back.items.first.name, 'Oats');
      expect(back.items.first.kcal100, 389);
      expect(back.total.kcal, closeTo(645, 0.001));
    });

    test('payload is QR-friendly (well under 1KB)', () {
      expect(RecipeCodec.encode(sample).length, lessThan(1024));
    });

    test('rejects non-payloads', () {
      expect(RecipeCodec.decode('hello'), isNull);
      expect(RecipeCodec.decode('CTR1:not-base64!!'), isNull);
      expect(RecipeCodec.decode(''), isNull);
    });

    test('omits null macros but still decodes them as null', () {
      const r = RecipeShare(
        name: 'X',
        servings: 1,
        items: [RecipeShareItem(name: 'Water', grams: 100, kcal100: 0)],
      );
      final back = RecipeCodec.decode(RecipeCodec.encode(r))!;
      expect(back.items.first.protein100, isNull);
    });
  });
}
