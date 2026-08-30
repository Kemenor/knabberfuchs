import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

/// The base recognition instruction sent to Gemini with the photo.
const _basePrompt =
    'You are a nutrition assistant. Identify the food in this photo and '
    'estimate the nutrition for ONE realistic serving as shown. Estimate the '
    'edible weight in grams realistically — most plated dishes are 200-500 g, '
    'drinks 200-400 ml, snacks 30-150 g; only exceed this if the photo '
    'clearly shows an unusually large portion. Return the dish name and the '
    'TOTALS for that serving (not per 100 g): calories in kcal, and protein, '
    'carbohydrate and fat in grams. If the image is not food, set is_food to '
    'false.';

/// The prompt to send for a photo, optionally refined by a user [description].
/// A blank/whitespace hint yields the base prompt unchanged; a real hint is
/// appended as guidance that still defers to the photo. Pure → unit-testable.
String buildGeminiPrompt(String? description) {
  final hint = description?.trim() ?? '';
  if (hint.isEmpty) return _basePrompt;
  return '$_basePrompt The user adds this hint about the meal — use it to '
      'refine the identification and portion, but still rely on the photo: '
      '"$hint".';
}

/// The instruction for a text-only meal description ("Describe meal" flow).
/// Unlike the photo prompt, the result is ITEMIZED: one estimate per food
/// component, so each part logs as its own diary entry and stays individually
/// correctable (grilled 2026-07-03).
const _textPrompt =
    'You are a nutrition assistant. The user describes a meal in free text '
    '(English, German, French or Italian). Split it into its food components. '
    'For each component estimate the edible weight in grams (realistic '
    'portions when none is given) and the TOTALS for that amount (not per '
    '100 g): calories in kcal, and protein, carbohydrate and fat in grams. '
    'Keep component names short, in the language of the description. Also '
    'return meal_name: a 1-3 word summary in that language. If the text does '
    'not describe food or drink, set is_food to false.';

/// Why a Gemini call didn't produce an estimate.
///
/// Every failure used to collapse into a bare `null`, which the UI reported as
/// "couldn't reach Gemini" — so a tester whose key Google was *rejecting* went
/// looking for a network outage instead (FEEDBACK.md, 2026-08-27). The cause
/// has to survive as far as the message.
enum GeminiFailure {
  /// 400 `API_KEY_INVALID` or 401 — the key is wrong, mistyped or revoked.
  invalidKey,

  /// 403 — the key is real but not allowed here: the Generative Language API
  /// isn't enabled on its Cloud project, or the key carries a restriction.
  noAccess,

  /// 404 — this key can't reach that model. The other model in Settings may
  /// still work, which is why the fallback runs before this is reported.
  modelUnavailable,

  /// 429 — the per-minute rate limit or the daily free-tier quota.
  quota,

  /// 5xx or a timeout — Google is overloaded or slow. Worth retrying later.
  busy,

  /// The request never reached Google (no connectivity, DNS, TLS).
  network,

  /// 200, and the model says it isn't food. An answer, not a failure of ours.
  notFood,

  /// 200 with a payload we can't use, or a status we don't classify.
  unknown,
}

/// Most actionable first. When the preferred and the fallback model fail
/// *differently*, the user hears about the one they can actually do something
/// about — a rejected key beats "Google is busy".
const _failureRank = <GeminiFailure>[
  GeminiFailure.notFood,
  GeminiFailure.invalidKey,
  GeminiFailure.noAccess,
  GeminiFailure.modelUnavailable,
  GeminiFailure.quota,
  GeminiFailure.network,
  GeminiFailure.unknown,
  GeminiFailure.busy,
];

GeminiFailure _moreActionable(GeminiFailure? a, GeminiFailure b) => a == null
    ? b
    : (_failureRank.indexOf(a) <= _failureRank.indexOf(b) ? a : b);

/// Classify a non-200 Gemini response into the cause the user needs to hear.
/// Pure → unit-testable without a network. Google reports a bad key as **400
/// `API_KEY_INVALID`**, not 401, so the body matters as much as the status.
GeminiFailure classifyGeminiError(int statusCode, String body) {
  switch (statusCode) {
    case 400:
      return body.contains('API_KEY_INVALID') ||
              body.contains('API key not valid')
          ? GeminiFailure.invalidKey
          : GeminiFailure.unknown;
    case 401:
      return GeminiFailure.invalidKey;
    case 403:
      return GeminiFailure.noAccess;
    case 404:
      return GeminiFailure.modelUnavailable;
    case 429:
      return GeminiFailure.quota;
    case 500:
    case 502:
    case 503:
    case 504:
      return GeminiFailure.busy;
    default:
      return GeminiFailure.unknown;
  }
}

/// The result of a Gemini call: the estimate, or the classified reason there
/// isn't one. A null [value] always carries a [failure].
class GeminiOutcome<T> {
  final T? value;
  final GeminiFailure? failure;

  const GeminiOutcome.success(T this.value) : failure = null;
  const GeminiOutcome.failed(GeminiFailure this.failure) : value = null;

  /// True when there's an estimate to use.
  bool get ok => value != null;

  /// True when the user can *fix* this — a rejected key, a model their key
  /// can't reach, a spent quota. Those earn a dialog with a route into
  /// Settings; the rest are a snackbar they're free to ignore.
  bool get isActionable =>
      failure == GeminiFailure.invalidKey ||
      failure == GeminiFailure.noAccess ||
      failure == GeminiFailure.modelUnavailable ||
      failure == GeminiFailure.quota;
}

/// One food estimate from Gemini — totals for the portion shown (not per 100 g).
class GeminiFoodResult {
  final String name;
  final double? grams;
  final double kcal;
  final double? protein;
  final double? carb;
  final double? fat;
  const GeminiFoodResult({
    required this.name,
    this.grams,
    required this.kcal,
    this.protein,
    this.carb,
    this.fat,
  });
}

/// Optional cloud food recognition via the user's own (free-tier) Google Gemini
/// API key. Sends the photo to Gemini and asks for the dish + nutrition as JSON.
/// Strictly opt-in: nothing leaves the device until the user configures a key.
class GeminiService {
  /// Always tried last (after the user's preferred model) because it's GA,
  /// free-tier, strong at vision, and reliably available. The newer flash
  /// models (e.g. gemini-3.5-flash) can be more accurate but get overloaded
  /// (HTTP 503), so they're only the *preferred* first try, not the fallback.
  static const fallbackModel = 'gemini-2.5-flash';
  static const _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Optional injected client (for tests). When null, each request gets a
  /// FRESH client that is closed afterwards — reusing one long-lived client
  /// let a stale pooled connection from a slow first request silently break
  /// every later call (the "works once, then always local" bug).
  final http.Client? _injected;
  GeminiService({http.Client? client}) : _injected = client;

  /// Tries [preferredModel] first, then [fallbackModel] (skipped if the same)
  /// before giving up. Each model gets one 30 s try with a fresh client.
  ///
  /// [isCancelled] is polled before every upload: an in-flight request can't
  /// be aborted (http's close() lets it finish), but a cancel must at least
  /// stop the photo from being re-sent to the next model.
  Future<GeminiOutcome<GeminiFoodResult>> recognizeFood(
    Uint8List bytes,
    String apiKey, {
    String? preferredModel,
    String? description,
    bool Function()? isCancelled,
  }) async {
    // Decode/resize/encode of a full camera photo takes ~1 s — off the UI
    // isolate so the progress dialog keeps animating.
    final b64 = base64Encode(await compute(_downscaleJpeg, bytes));
    // An optional user hint disambiguates an ambiguous photo (the user knows
    // it's a calzone, or homemade with extra cheese). Still anchored on the
    // photo; the hint just refines identification + portion.
    final promptText = buildGeminiPrompt(description);
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': promptText},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': b64},
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'object',
          'properties': {
            'is_food': {'type': 'boolean'},
            'name': {'type': 'string'},
            'grams': {'type': 'number'},
            'kcal': {'type': 'number'},
            'protein_g': {'type': 'number'},
            'carb_g': {'type': 'number'},
            'fat_g': {'type': 'number'},
          },
          'required': ['is_food', 'name', 'kcal'],
        },
      },
    });
    return _attemptModels<GeminiFoodResult>(
      requestBody: body,
      apiKey: apiKey,
      preferredModel: preferredModel,
      isCancelled: isCancelled,
      interpret: _interpretFood,
      logLabel: 'photo',
    );
  }

  /// Text-only itemized estimate for the "Describe meal" flow. Same
  /// model-fallback/cancel semantics as [recognizeFood], no image part.
  Future<GeminiOutcome<GeminiMealResult>> estimateMealFromText(
    String description,
    String apiKey, {
    String? preferredModel,
    bool Function()? isCancelled,
  }) async {
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': '$_textPrompt\n\nThe meal: "${description.trim()}"'},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'object',
          'properties': {
            'is_food': {'type': 'boolean'},
            'meal_name': {'type': 'string'},
            'items': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'name': {'type': 'string'},
                  'grams': {'type': 'number'},
                  'kcal': {'type': 'number'},
                  'protein_g': {'type': 'number'},
                  'carb_g': {'type': 'number'},
                  'fat_g': {'type': 'number'},
                },
                'required': ['name', 'kcal'],
              },
            },
          },
          'required': ['is_food', 'items'],
        },
      },
    });
    return _attemptModels<GeminiMealResult>(
      requestBody: body,
      apiKey: apiKey,
      preferredModel: preferredModel,
      isCancelled: isCancelled,
      interpret: _interpretMeal,
      logLabel: 'text',
    );
  }

  /// Validate [apiKey] (against [model], default [fallbackModel]) with the
  /// smallest real request there is, so Settings can name the problem while
  /// the user is still looking at the key field — instead of leaving them to
  /// discover it mid-meal as "couldn't reach Gemini". Returns null when the
  /// key works.
  Future<GeminiFailure?> testKey(String apiKey, {String? model}) async {
    final target = (model == null || model.isEmpty) ? fallbackModel : model;
    final client = _injected ?? http.Client();
    try {
      final resp = await client
          .post(
            Uri.parse('$_base/$target:generateContent'),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            // No generationConfig: the status code is the whole answer, and
            // capping output tokens is rejected outright by some models.
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': 'ping'},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));
      return resp.statusCode == 200
          ? null
          : classifyGeminiError(resp.statusCode, resp.body);
    } on TimeoutException {
      return GeminiFailure.busy;
    } on SocketException {
      return GeminiFailure.network;
    } on http.ClientException {
      return GeminiFailure.network;
    } catch (_) {
      return GeminiFailure.unknown;
    } finally {
      if (_injected == null) client.close();
    }
  }

  /// The shared preferred → fallback loop. Each model gets one 30 s try with a
  /// fresh client; on a transient failure we move to the next and remember the
  /// most actionable cause seen, so exhausting the chain still reports *why*.
  Future<GeminiOutcome<T>> _attemptModels<T>({
    required String requestBody,
    required String apiKey,
    required String? preferredModel,
    required bool Function()? isCancelled,
    required GeminiOutcome<T> Function(String responseBody) interpret,
    required String logLabel,
  }) async {
    final models = <String>{preferredModel ?? fallbackModel, fallbackModel};
    GeminiFailure? seen;
    for (final model in models) {
      if (isCancelled?.call() ?? false) {
        return GeminiOutcome<T>.failed(seen ?? GeminiFailure.busy);
      }
      final uri = Uri.parse('$_base/$model:generateContent');
      final client = _injected ?? http.Client();
      try {
        // The key travels in a header, not the query string, so it never
        // shows up in a stringified URI (exception messages, logs).
        final resp = await client
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': apiKey,
              },
              body: requestBody,
            )
            .timeout(const Duration(seconds: 30));
        if (resp.statusCode != 200) {
          final f = classifyGeminiError(resp.statusCode, resp.body);
          debugPrint('[gemini] $model HTTP ${resp.statusCode} → ${f.name}');
          seen = _moreActionable(seen, f);
          // A rejected or unauthorized key fails identically on every model —
          // trying the fallback only re-uploads the photo for a second no.
          if (f == GeminiFailure.invalidKey || f == GeminiFailure.noAccess) {
            return GeminiOutcome<T>.failed(f);
          }
          continue;
        }
        // A 200 is the model's answer, useful or not — never retried.
        final out = interpret(resp.body);
        debugPrint('[gemini] $logLabel $model ok=${out.ok}');
        return out;
      } on TimeoutException {
        debugPrint('[gemini] $model timeout — next model');
        seen = _moreActionable(seen, GeminiFailure.busy);
        continue;
      } on SocketException {
        debugPrint('[gemini] $model no connectivity — next model');
        seen = _moreActionable(seen, GeminiFailure.network);
        continue;
      } on http.ClientException {
        debugPrint('[gemini] $model transport failure — next model');
        seen = _moreActionable(seen, GeminiFailure.network);
        continue;
      } catch (e) {
        // Log only the exception type: http exceptions embed the full URI.
        debugPrint('[gemini] $model error: ${e.runtimeType} — next model');
        seen = _moreActionable(seen, GeminiFailure.unknown);
        continue;
      } finally {
        if (_injected == null) client.close();
      }
    }
    return GeminiOutcome<T>.failed(seen ?? GeminiFailure.unknown);
  }

  /// Request clients are created and closed per call; only an injected client
  /// (owned by the caller) would need closing, and the caller handles that.
  void dispose() {}
}

/// Itemized meal estimate from a text description: a short meal name plus one
/// [GeminiFoodResult] per component.
class GeminiMealResult {
  final String? name;
  final List<GeminiFoodResult> items;
  const GeminiMealResult({this.name, required this.items});
}

GeminiOutcome<GeminiFoodResult> _interpretFood(String body) {
  final r = parseGeminiResponse(body);
  if (r != null) return GeminiOutcome.success(r);
  return GeminiOutcome.failed(
    geminiSaidNotFood(body) ? GeminiFailure.notFood : GeminiFailure.unknown,
  );
}

GeminiOutcome<GeminiMealResult> _interpretMeal(String body) {
  final r = parseGeminiMealResponse(body);
  if (r != null) return GeminiOutcome.success(r);
  return GeminiOutcome.failed(
    geminiSaidNotFood(body) ? GeminiFailure.notFood : GeminiFailure.unknown,
  );
}

/// The model's reply text out of a `generateContent` envelope, or null if the
/// envelope isn't the shape we expect.
String? _candidateText(String responseBody) {
  try {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    return (((data['candidates'] as List?)?.first
                    as Map<String, dynamic>?)?['content']?['parts']
                as List?)
            ?.first?['text']
        as String?;
  } catch (_) {
    return null;
  }
}

/// True when a 200 response carried an explicit `is_food: false` — the model
/// answered, it just wasn't food. Keeping that apart from a malformed payload
/// stops "that isn't food" being reported as a problem reaching Google.
bool geminiSaidNotFood(String responseBody) {
  try {
    final text = _candidateText(responseBody);
    if (text == null) return false;
    return (jsonDecode(text) as Map<String, dynamic>)['is_food'] == false;
  } catch (_) {
    return false;
  }
}

/// Parse the text-estimate response into a [GeminiMealResult]. Null on shape
/// mismatch, non-food, or an empty/valueless item list.
GeminiMealResult? parseGeminiMealResponse(String responseBody) {
  try {
    final text = _candidateText(responseBody);
    if (text == null) return null;
    final j = jsonDecode(text) as Map<String, dynamic>;
    if (j['is_food'] == false) return null;
    double? n(dynamic v) => v is num ? v.toDouble() : null;
    final items = <GeminiFoodResult>[];
    for (final raw in (j['items'] as List? ?? const [])) {
      if (raw is! Map<String, dynamic>) continue;
      final name = (raw['name'] as String?)?.trim();
      final kcal = n(raw['kcal']);
      if (name == null || name.isEmpty || kcal == null) continue;
      items.add(
        GeminiFoodResult(
          name: name,
          grams: n(raw['grams']),
          kcal: kcal,
          protein: n(raw['protein_g']),
          carb: n(raw['carb_g']),
          fat: n(raw['fat_g']),
        ),
      );
    }
    if (items.isEmpty) return null;
    return GeminiMealResult(
      name: (j['meal_name'] as String?)?.trim(),
      items: items,
    );
  } catch (_) {
    return null;
  }
}

/// Shrink the photo (longest side ≤ 768 px, JPEG q85) to keep the upload
/// small and fast — plenty of detail for recognition. Top-level so [compute]
/// can run it in a worker isolate.
Uint8List _downscaleJpeg(Uint8List bytes) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    // Truncated/corrupt buffers can make the format probes throw rather than
    // return null (e.g. the PSD header reader on very short input).
    return bytes;
  }
  if (decoded == null) return bytes;
  var im = decoded;
  final maxSide = decoded.width >= decoded.height
      ? decoded.width
      : decoded.height;
  if (maxSide > 768) {
    im = decoded.width >= decoded.height
        ? img.copyResize(decoded, width: 768)
        : img.copyResize(decoded, height: 768);
  }
  return img.encodeJpg(im, quality: 85);
}

/// Parse Gemini's `generateContent` response into a [GeminiFoodResult].
/// Returns null on any shape mismatch or a non-food / nameless result.
GeminiFoodResult? parseGeminiResponse(String responseBody) {
  try {
    final text = _candidateText(responseBody);
    if (text == null) return null;
    final j = jsonDecode(text) as Map<String, dynamic>;
    if (j['is_food'] == false) return null;
    final name = (j['name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;
    double? n(dynamic v) => v is num ? v.toDouble() : null;
    final kcal = n(j['kcal']);
    if (kcal == null) return null;
    return GeminiFoodResult(
      name: name,
      grams: n(j['grams']),
      kcal: kcal,
      protein: n(j['protein_g']),
      carb: n(j['carb_g']),
      fat: n(j['fat_g']),
    );
  } catch (_) {
    return null;
  }
}
