import 'dart:convert';

import 'package:calorie_tracker/data/ml/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';

String _wrap(Map<String, dynamic> inner) => jsonEncode({
  'candidates': [
    {
      'content': {
        'parts': [
          {'text': jsonEncode(inner)},
        ],
        'role': 'model',
      },
      'finishReason': 'STOP',
    },
  ],
});

void main() {
  group('buildGeminiPrompt', () {
    test('no hint → base prompt unchanged', () {
      expect(buildGeminiPrompt(null), buildGeminiPrompt(''));
      expect(buildGeminiPrompt(null), isNot(contains('hint about the meal')));
      expect(buildGeminiPrompt(null), contains('nutrition assistant'));
    });

    test('blank/whitespace hint is ignored', () {
      expect(buildGeminiPrompt('   '), buildGeminiPrompt(null));
    });

    test('a real hint is appended (trimmed, quoted) and refines, not replaces', () {
      final p = buildGeminiPrompt('  homemade lasagne, large portion  ');
      // Still anchored on the base instruction.
      expect(p, startsWith(buildGeminiPrompt(null)));
      // The trimmed hint is embedded.
      expect(p, contains('"homemade lasagne, large portion"'));
      // Framed as a refinement that still defers to the photo.
      expect(p, contains('still rely on the photo'));
    });
  });

  test('parses a valid food estimate (portion totals)', () {
    final r = parseGeminiResponse(
      _wrap({
        'is_food': true,
        'name': 'Margherita pizza',
        'grams': 320,
        'kcal': 850,
        'protein_g': 34,
        'carb_g': 95,
        'fat_g': 36,
      }),
    );
    expect(r, isNotNull);
    expect(r!.name, 'Margherita pizza');
    expect(r.grams, 320);
    expect(r.kcal, 850);
    expect(r.protein, 34);
    expect(r.carb, 95);
    expect(r.fat, 36);
  });

  test('non-food returns null', () {
    expect(
      parseGeminiResponse(_wrap({'is_food': false, 'name': 'a cat'})),
      isNull,
    );
  });

  test('missing kcal or name returns null', () {
    expect(
      parseGeminiResponse(_wrap({'is_food': true, 'name': 'Soup'})),
      isNull,
    );
    expect(parseGeminiResponse(_wrap({'is_food': true, 'kcal': 200})), isNull);
  });

  test('macros are optional', () {
    final r = parseGeminiResponse(
      _wrap({'is_food': true, 'name': 'Apple', 'kcal': 95}),
    );
    expect(r, isNotNull);
    expect(r!.kcal, 95);
    expect(r.protein, isNull);
  });

  test('garbage / wrong shape returns null, never throws', () {
    expect(parseGeminiResponse('not json'), isNull);
    expect(parseGeminiResponse('{}'), isNull);
    expect(parseGeminiResponse(jsonEncode({'candidates': []})), isNull);
  });

  // The itemized text-estimate ("Describe meal") response.

  test('meal response parses name and per-component items', () {
    final r = parseGeminiMealResponse(
      _wrap({
        'is_food': true,
        'meal_name': 'Znüni',
        'items': [
          {
            'name': 'Roggenbrot',
            'grams': 120,
            'kcal': 260,
            'protein_g': 8,
            'carb_g': 50,
            'fat_g': 2,
          },
          {'name': 'Butter', 'grams': 10, 'kcal': 74},
        ],
      }),
    );
    expect(r, isNotNull);
    expect(r!.name, 'Znüni');
    expect(r.items, hasLength(2));
    expect(r.items[0].carb, 50);
    expect(r.items[1].kcal, 74);
    expect(r.items[1].protein, isNull);
  });

  test('meal response drops valueless items; all-dropped means null', () {
    final r = parseGeminiMealResponse(
      _wrap({
        'is_food': true,
        'items': [
          {'name': 'Tee', 'kcal': 2},
          {'name': ''},
          {'kcal': 100},
        ],
      }),
    );
    expect(r!.items.single.name, 'Tee');
    expect(
      parseGeminiMealResponse(
        _wrap({
          'is_food': true,
          'items': [
            {'name': 'x'},
          ],
        }),
      ),
      isNull,
    );
  });

  test('meal response: non-food, empty items, garbage all return null', () {
    expect(
      parseGeminiMealResponse(_wrap({'is_food': false, 'items': []})),
      isNull,
    );
    expect(
      parseGeminiMealResponse(_wrap({'is_food': true, 'items': []})),
      isNull,
    );
    expect(parseGeminiMealResponse('not json'), isNull);
  });
}
