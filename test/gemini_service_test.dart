import 'dart:async';
import 'dart:convert';

import 'package:calorie_tracker/data/ml/gemini_service.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

    test(
      'a real hint is appended (trimmed, quoted) and refines, not replaces',
      () {
        final p = buildGeminiPrompt('  homemade lasagne, large portion  ');
        // Still anchored on the base instruction.
        expect(p, startsWith(buildGeminiPrompt(null)));
        // The trimmed hint is embedded.
        expect(p, contains('"homemade lasagne, large portion"'));
        // Framed as a refinement that still defers to the photo.
        expect(p, contains('still rely on the photo'));
      },
    );
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

  group('model fallback / HTTP loop', () {
    String mealBody() => _wrap({
      'is_food': true,
      'meal_name': 'Test',
      'items': [
        {'name': 'Toast', 'kcal': 180.0},
      ],
    });

    test('preferred 503 falls back to gemini-2.5-flash and succeeds', () async {
      final requested = <String>[];
      final svc = GeminiService(
        client: MockClient((req) async {
          requested.add(req.url.path);
          if (req.url.path.contains('gemini-3.5-flash')) {
            return http.Response('overloaded', 503);
          }
          return http.Response(mealBody(), 200);
        }),
      );
      final r = await svc.estimateMealFromText(
        'toast',
        'test-key',
        preferredModel: 'gemini-3.5-flash',
      );
      expect(r?.items.single.name, 'Toast');
      expect(requested, hasLength(2));
      expect(requested.first, contains('gemini-3.5-flash'));
      expect(requested.last, contains('gemini-2.5-flash'));
    });

    test('preferred timeout falls back; both failing returns null', () async {
      var calls = 0;
      final svc = GeminiService(
        client: MockClient((req) async {
          calls++;
          if (req.url.path.contains('gemini-3.5-flash')) {
            throw TimeoutException('slow');
          }
          return http.Response('teapot', 418);
        }),
      );
      final r = await svc.estimateMealFromText(
        'toast',
        'test-key',
        preferredModel: 'gemini-3.5-flash',
      );
      expect(r, isNull);
      expect(calls, 2);
    });

    test('preferred == fallback is tried only once', () async {
      var calls = 0;
      final svc = GeminiService(
        client: MockClient((req) async {
          calls++;
          return http.Response('overloaded', 503);
        }),
      );
      final r = await svc.estimateMealFromText(
        'toast',
        'test-key',
        preferredModel: GeminiService.fallbackModel,
      );
      expect(r, isNull);
      expect(calls, 1);
    });

    test('cancellation between attempts stops the fallback upload', () async {
      var calls = 0;
      final svc = GeminiService(
        client: MockClient((req) async {
          calls++;
          return http.Response('overloaded', 503);
        }),
      );
      final r = await svc.estimateMealFromText(
        'toast',
        'test-key',
        preferredModel: 'gemini-3.5-flash',
        // Cancelled right after the first attempt: the photo/text must not
        // be re-sent to the fallback model.
        isCancelled: () => calls >= 1,
      );
      expect(r, isNull);
      expect(calls, 1);
    });

    test('api key travels in the header, never the URL', () async {
      http.Request? seen;
      final svc = GeminiService(
        client: MockClient((req) async {
          seen = req;
          return http.Response(mealBody(), 200);
        }),
      );
      await svc.estimateMealFromText('toast', 'secret-key');
      expect(seen!.headers['x-goog-api-key'], 'secret-key');
      expect(seen!.url.toString(), isNot(contains('secret-key')));
    });

    test('recognizeFood uses the same fallback loop (photo path)', () async {
      final requested = <String>[];
      final svc = GeminiService(
        client: MockClient((req) async {
          requested.add(req.url.path);
          if (req.url.path.contains('gemini-3.5-flash')) {
            return http.Response('overloaded', 503);
          }
          return http.Response(
            _wrap({'is_food': true, 'name': 'Calzone', 'kcal': 640.0}),
            200,
          );
        }),
      );
      // Undecodable bytes pass through the downscaler unchanged — fine here.
      final r = await svc.recognizeFood(
        Uint8List.fromList([1, 2, 3]),
        'test-key',
        preferredModel: 'gemini-3.5-flash',
      );
      expect(r?.name, 'Calzone');
      expect(requested, hasLength(2));
    });
  });
}
