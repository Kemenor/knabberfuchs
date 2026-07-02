import 'dart:async';
import 'dart:convert';

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
/// Strictly opt-in: the on-device classifier stays the keyless default, and the
/// photo only leaves the device when the user has configured a key.
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
  /// on a 503/timeout/transient failure, before the caller falls back to the
  /// on-device classifier. Each model gets one 30 s try with a fresh client.
  ///
  /// [isCancelled] is polled before every upload: an in-flight request can't
  /// be aborted (http's close() lets it finish), but a cancel must at least
  /// stop the photo from being re-sent to the next model.
  Future<GeminiFoodResult?> recognizeFood(
    Uint8List bytes,
    String apiKey, {
    String? preferredModel,
    String? description,
    bool Function()? isCancelled,
  }) async {
    // Decode/resize/encode of a full camera photo takes ~1 s — off the UI
    // isolate so the progress dialog keeps animating.
    final b64 = base64Encode(await compute(_downscaleJpeg, bytes));
    final models = <String>{preferredModel ?? fallbackModel, fallbackModel};
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
    // Try each model in turn (preferred → fallback), one 30 s attempt each with
    // a fresh client. On any failure (503/timeout/error/non-200) move to the
    // next model; exhausting them returns null → the on-device classifier.
    for (final model in models) {
      if (isCancelled?.call() ?? false) return null;
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
              body: body,
            )
            .timeout(const Duration(seconds: 30));
        if (resp.statusCode != 200) {
          debugPrint('[gemini] $model HTTP ${resp.statusCode} — next model');
          continue;
        }
        final r = parseGeminiResponse(resp.body);
        debugPrint('[gemini] $model ok=${r != null} name=${r?.name}');
        return r;
      } on TimeoutException {
        debugPrint('[gemini] $model timeout — next model');
        continue;
      } catch (e) {
        // Log only the exception type: http exceptions embed the full URI.
        debugPrint('[gemini] $model error: ${e.runtimeType} — next model');
        continue;
      } finally {
        if (_injected == null) client.close();
      }
    }
    return null;
  }

  /// Request clients are created and closed per call; only an injected client
  /// (owned by the caller) would need closing, and the caller handles that.
  void dispose() {}
}

/// Shrink the photo (longest side ≤ 768 px, JPEG q85) to keep the upload
/// small and fast — plenty of detail for recognition. Top-level so [compute]
/// can run it in a worker isolate.
Uint8List _downscaleJpeg(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
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
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final text =
        (((data['candidates'] as List?)?.first
                        as Map<String, dynamic>?)?['content']?['parts']
                    as List?)
                ?.first?['text']
            as String?;
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
