import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

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
  // gemini-2.5-flash: GA, free-tier, strong vision, and reliably available —
  // gemini-3.5-flash was persistently returning HTTP 503 (overloaded), failing
  // every scan. If Google retires/renames this, the recognise flow falls back
  // to the on-device classifier; bump the string to follow the current model.
  static const _model = 'gemini-2.5-flash';
  static const _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const _prompt =
      'You are a nutrition assistant. Identify the food in this photo and '
      'estimate the nutrition for the portion shown. Return the dish name, the '
      'estimated edible weight in grams, and the TOTALS for the whole portion '
      '(not per 100 g): calories in kcal, and protein, carbohydrate and fat in '
      'grams. If the image is not food, set is_food to false.';

  /// Optional injected client (for tests). When null, each request gets a
  /// FRESH client that is closed afterwards — reusing one long-lived client
  /// let a stale pooled connection from a slow first request silently break
  /// every later call (the "works once, then always local" bug).
  final http.Client? _injected;
  GeminiService({http.Client? client}) : _injected = client;

  /// [onAttempt] fires at the start of each network attempt with its 1-based
  /// number, so the UI can surface a live retry counter.
  Future<GeminiFoodResult?> recognizeFood(
    Uint8List bytes,
    String apiKey, {
    void Function(int attempt)? onAttempt,
  }) async {
    final b64 = base64Encode(_downscaleJpeg(bytes));
    final uri = Uri.parse('$_base/$_model:generateContent?key=$apiKey');
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': b64}
            },
          ]
        }
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
    // Up to two attempts, each with its own client. Retry once on a transient
    // overload (503) or timeout; any other failure falls straight through to
    // the on-device classifier.
    for (var attempt = 1; attempt <= 2; attempt++) {
      onAttempt?.call(attempt);
      final client = _injected ?? http.Client();
      try {
        final resp = await client
            .post(uri,
                headers: {'Content-Type': 'application/json'}, body: body)
            .timeout(const Duration(seconds: 60));
        if (resp.statusCode == 503 && attempt == 1) {
          debugPrint('[gemini] 503 overloaded, retrying');
          continue;
        }
        if (resp.statusCode != 200) {
          debugPrint('[gemini] HTTP ${resp.statusCode}: '
              '${resp.body.length > 300 ? resp.body.substring(0, 300) : resp.body}');
          return null;
        }
        final r = parseGeminiResponse(resp.body);
        debugPrint('[gemini] ok=${r != null} name=${r?.name}');
        return r;
      } on TimeoutException {
        debugPrint('[gemini] timeout (attempt $attempt)');
        if (attempt == 1) continue;
        return null;
      } catch (e) {
        debugPrint('[gemini] error: $e');
        return null;
      } finally {
        if (_injected == null) client.close();
      }
    }
    return null;
  }

  /// Shrink the photo (longest side ≤ 768 px, JPEG q85) to keep the upload
  /// small and fast — plenty of detail for recognition.
  Uint8List _downscaleJpeg(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    var im = decoded;
    final maxSide =
        decoded.width >= decoded.height ? decoded.width : decoded.height;
    if (maxSide > 768) {
      im = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: 768)
          : img.copyResize(decoded, height: 768);
    }
    return img.encodeJpg(im, quality: 85);
  }

  /// Request clients are created and closed per call; only an injected client
  /// (owned by the caller) would need closing, and the caller handles that.
  void dispose() {}
}

/// Parse Gemini's `generateContent` response into a [GeminiFoodResult].
/// Returns null on any shape mismatch or a non-food / nameless result.
GeminiFoodResult? parseGeminiResponse(String responseBody) {
  try {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final text = (((data['candidates'] as List?)?.first
            as Map<String, dynamic>?)?['content']?['parts'] as List?)
        ?.first?['text'] as String?;
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
