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
}
