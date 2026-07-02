import 'package:flutter/foundation.dart';
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
  Future<List<FoodGuess>> classify(
    Uint8List bytes, {
    int topK = 5,
    double minScore = 0.02,
  }) async {
    await _ensureLoaded();
    // Decode/crop/resize of a full camera photo is the expensive part (~1 s);
    // run it in a worker isolate so the UI spinner keeps animating. The
    // interpreter itself holds a native handle and can't cross isolates, so
    // inference stays here — it's fast on the 192×192 input.
    final rgb = await compute(_prepareInput, bytes);
    if (rgb == null) return const [];

    // [1, 192, 192, 3] uint8
    final input = [
      List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final o = (y * _inputSize + x) * 3;
          return [rgb[o], rgb[o + 1], rgb[o + 2]];
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

/// Decode, centre-crop to a square (so the model sees the dish without the
/// aspect-ratio distortion a straight stretch-to-192 would introduce) and
/// resize to the model input. Returns tightly packed RGB bytes
/// (192·192·3), or null if the image doesn't decode. Top-level so [compute]
/// can run it in a worker isolate.
Uint8List? _prepareInput(Uint8List bytes) {
  const inputSize = FoodClassifier._inputSize;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final side = decoded.width < decoded.height ? decoded.width : decoded.height;
  final square = img.copyCrop(
    decoded,
    x: (decoded.width - side) ~/ 2,
    y: (decoded.height - side) ~/ 2,
    width: side,
    height: side,
  );
  final resized = img.copyResize(square, width: inputSize, height: inputSize);
  final out = Uint8List(inputSize * inputSize * 3);
  var o = 0;
  for (var y = 0; y < inputSize; y++) {
    for (var x = 0; x < inputSize; x++) {
      final p = resized.getPixel(x, y);
      out[o++] = p.r.toInt();
      out[o++] = p.g.toInt();
      out[o++] = p.b.toInt();
    }
  }
  return out;
}
