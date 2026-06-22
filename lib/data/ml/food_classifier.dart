import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// One food-recognition guess.
class FoodGuess {
  final String label;
  final double score; // 0..1
  const FoodGuess(this.label, this.score);
}

/// On-device food image classifier backed by Google's AIY food_V1 model
/// (Apache-2.0, 2024 dish classes). Input is 192×192×3 uint8; output is 2024
/// uint8 probabilities (value / 256). Index 0 is `__background__` and is
/// skipped. Fully offline — no network, no API key.
class FoodClassifier {
  static const _modelAsset = 'assets/foodmodel/food_V1.tflite';
  static const _labelsAsset = 'assets/foodmodel/food_labels.txt';
  static const _inputSize = 192;

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> _ensureLoaded() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(_modelAsset);
    final raw = await rootBundle.loadString(_labelsAsset);
    _labels = raw.split('\n').map((l) => l.trim()).toList();
  }

  /// Classify a JPEG/PNG image and return the top [topK] food guesses, best
  /// first, excluding the background class and anything below [minScore].
  Future<List<FoodGuess>> classify(Uint8List bytes,
      {int topK = 5, double minScore = 0.02}) async {
    await _ensureLoaded();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return const [];
    final resized =
        img.copyResize(decoded, width: _inputSize, height: _inputSize);

    // [1, 192, 192, 3] uint8
    final input = [
      List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final p = resized.getPixel(x, y);
          return [p.r.toInt(), p.g.toInt(), p.b.toInt()];
        }),
      ),
    ];
    final labels = _labels!;
    final output = [List<int>.filled(labels.length, 0)];
    _interpreter!.run(input, output);

    final scores = output[0];
    final order = List<int>.generate(scores.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));

    final out = <FoodGuess>[];
    for (final i in order) {
      if (i == 0) continue; // __background__
      final score = scores[i] / 256.0;
      if (score < minScore || out.length >= topK) break;
      final label = i < labels.length ? labels[i] : '?';
      out.add(FoodGuess(label, score));
    }
    return out;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
