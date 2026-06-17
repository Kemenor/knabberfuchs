import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/ocr_ingredient.dart';

/// On-device OCR (ML Kit) for recipe screenshots. Reconstructs rows by vertical
/// position so a name and its (separately-styled) quantity land on one line,
/// then parses ingredients.
class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<OcrIngredient>> ingredientsFromImage(String path) async {
    return parseIngredientLines(await _rows(path));
  }

  Future<List<String>> _rows(String path) async {
    final result =
        await _recognizer.processImage(InputImage.fromFilePath(path));

    final lines = <_L>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final b = line.boundingBox;
        lines.add(_L(b.center.dy, b.left, b.height, line.text));
      }
    }
    lines.sort((a, b) => a.cy.compareTo(b.cy));

    final rows = <List<_L>>[];
    for (final l in lines) {
      if (rows.isNotEmpty &&
          (l.cy - rows.last.first.cy).abs() < 0.6 * l.height) {
        rows.last.add(l);
      } else {
        rows.add([l]);
      }
    }
    return [
      for (final row in rows)
        (row..sort((a, b) => a.left.compareTo(b.left)))
            .map((l) => l.text)
            .join(' '),
    ];
  }

  void dispose() => _recognizer.close();
}

class _L {
  final double cy;
  final double left;
  final double height;
  final String text;
  _L(this.cy, this.left, this.height, this.text);
}
