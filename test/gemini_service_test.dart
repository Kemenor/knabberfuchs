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
      expect(r.value?.items.single.name, 'Toast');
      expect(requested, hasLength(2));
      expect(requested.first, contains('gemini-3.5-flash'));
      expect(requested.last, contains('gemini-2.5-flash'));
    });

    test('preferred timeout falls back; both failing reports why', () async {
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
      expect(r.ok, isFalse);
      // 418 isn't a status we classify; it outranks the timeout's "busy".
      expect(r.failure, GeminiFailure.unknown);
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
      expect(r.failure, GeminiFailure.busy);
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
      expect(r.ok, isFalse);
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
      expect(r.value?.name, 'Calzone');
      expect(requested, hasLength(2));
    });
  });

  // Every failure used to collapse into a bare null, so the UI could only ever
  // say "couldn't reach Gemini" — including for a key Google was rejecting
  // (FEEDBACK.md 2026-08-27). The cause must survive to the caller.
  group('failure classification', () {
    test('a rejected key is 400 API_KEY_INVALID, not 401', () {
      const body =
          '{"error":{"code":400,"message":"API key not valid. Please pass a '
          'valid API key.","status":"INVALID_ARGUMENT","details":[{"reason":'
          '"API_KEY_INVALID"}]}}';
      expect(classifyGeminiError(400, body), GeminiFailure.invalidKey);
    });

    test('a plain 400 is not blamed on the key', () {
      expect(
        classifyGeminiError(400, '{"error":{"message":"bad request"}}'),
        GeminiFailure.unknown,
      );
    });

    test('statuses map to the cause the user needs to hear', () {
      expect(classifyGeminiError(401, ''), GeminiFailure.invalidKey);
      expect(classifyGeminiError(403, ''), GeminiFailure.noAccess);
      expect(classifyGeminiError(404, ''), GeminiFailure.modelUnavailable);
      expect(classifyGeminiError(429, ''), GeminiFailure.quota);
      expect(classifyGeminiError(500, ''), GeminiFailure.busy);
      expect(classifyGeminiError(503, ''), GeminiFailure.busy);
      expect(classifyGeminiError(504, ''), GeminiFailure.busy);
      expect(classifyGeminiError(418, ''), GeminiFailure.unknown);
    });

    test('only fixable causes earn the dialog', () {
      for (final f in [
        GeminiFailure.invalidKey,
        GeminiFailure.noAccess,
        GeminiFailure.modelUnavailable,
        GeminiFailure.quota,
      ]) {
        expect(GeminiOutcome<int>.failed(f).isActionable, isTrue, reason: '$f');
      }
      for (final f in [
        GeminiFailure.busy,
        GeminiFailure.network,
        GeminiFailure.notFood,
        GeminiFailure.unknown,
      ]) {
        expect(GeminiOutcome<int>.failed(f).isActionable, isFalse, reason: '$f');
      }
    });

    test('a rejected key short-circuits — the photo is not re-uploaded', () async {
      var calls = 0;
      final svc = GeminiService(
        client: MockClient((req) async {
          calls++;
          return http.Response('{"error":{"reason":"API_KEY_INVALID"}}', 400);
        }),
      );
      final r = await svc.recognizeFood(
        Uint8List.fromList([1, 2, 3]),
        'bad-key',
        preferredModel: 'gemini-3.5-flash',
      );
      expect(r.failure, GeminiFailure.invalidKey);
      expect(calls, 1, reason: 'the fallback model would be rejected too');
    });

    test('a 403 short-circuits the same way', () async {
      var calls = 0;
      final svc = GeminiService(
        client: MockClient((req) async {
          calls++;
          return http.Response('forbidden', 403);
        }),
      );
      final r = await svc.estimateMealFromText('toast', 'k',
          preferredModel: 'gemini-3.5-flash');
      expect(r.failure, GeminiFailure.noAccess);
      expect(calls, 1);
    });

    test('404 on the preferred model still tries the fallback', () async {
      final requested = <String>[];
      final svc = GeminiService(
        client: MockClient((req) async {
          requested.add(req.url.path);
          return http.Response('no such model', 404);
        }),
      );
      final r = await svc.estimateMealFromText('toast', 'k',
          preferredModel: 'gemini-3.5-flash');
      expect(requested, hasLength(2));
      expect(r.failure, GeminiFailure.modelUnavailable);
    });

    test('the most actionable cause wins over a mere "busy"', () async {
      final svc = GeminiService(
        client: MockClient((req) async {
          return req.url.path.contains('gemini-3.5-flash')
              ? http.Response('quota', 429)
              : http.Response('overloaded', 503);
        }),
      );
      final r = await svc.estimateMealFromText('toast', 'k',
          preferredModel: 'gemini-3.5-flash');
      expect(r.failure, GeminiFailure.quota);
    });

    test('a 200 that says "not food" is not reported as a failure to reach '
        'Google', () async {
      final svc = GeminiService(
        client: MockClient(
          (req) async =>
              http.Response(_wrap({'is_food': false, 'name': 'a cat'}), 200),
        ),
      );
      final r = await svc.recognizeFood(Uint8List.fromList([1]), 'k');
      expect(r.failure, GeminiFailure.notFood);
    });

    test('a 200 with an unusable payload is unknown, not notFood', () async {
      final svc = GeminiService(
        client: MockClient((req) async => http.Response('{"junk":1}', 200)),
      );
      final r = await svc.recognizeFood(Uint8List.fromList([1]), 'k');
      expect(r.failure, GeminiFailure.unknown);
    });

    test('geminiSaidNotFood only fires on an explicit is_food:false', () {
      expect(geminiSaidNotFood(_wrap({'is_food': false})), isTrue);
      expect(geminiSaidNotFood(_wrap({'is_food': true, 'kcal': 1})), isFalse);
      expect(geminiSaidNotFood('not json'), isFalse);
      expect(geminiSaidNotFood('{}'), isFalse);
    });
  });

  group('testKey', () {
    test('a working key returns null and hits the chosen model', () async {
      http.Request? seen;
      final svc = GeminiService(
        client: MockClient((req) async {
          seen = req;
          return http.Response('{}', 200);
        }),
      );
      expect(await svc.testKey('good', model: 'gemini-3.5-flash'), isNull);
      expect(seen!.url.path, contains('gemini-3.5-flash'));
      expect(seen!.headers['x-goog-api-key'], 'good');
      expect(seen!.url.toString(), isNot(contains('good')));
    });

    test('a rejected key comes back named', () async {
      final svc = GeminiService(
        client: MockClient(
          (req) async =>
              http.Response('{"error":{"reason":"API_KEY_INVALID"}}', 400),
        ),
      );
      expect(await svc.testKey('bad'), GeminiFailure.invalidKey);
    });

    test('no model given falls back to the reliable default', () async {
      http.Request? seen;
      final svc = GeminiService(
        client: MockClient((req) async {
          seen = req;
          return http.Response('{}', 200);
        }),
      );
      await svc.testKey('k');
      expect(seen!.url.path, contains(GeminiService.fallbackModel));
    });
  });
}
