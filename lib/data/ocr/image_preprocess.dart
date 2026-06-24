import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Light preprocessing to help ML Kit read a cropped nutrition table. The main
/// failure mode is tiny digits (e.g. "1,5" read as "159"), so the key step is
/// upscaling a small crop; grayscale + a mild contrast bump help low-contrast,
/// shiny packaging. Returns the original bytes if decoding fails.
Uint8List preprocessLabelImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  var im = decoded;
  const targetW = 1400;
  if (im.width < targetW) {
    im = img.copyResize(
      im,
      width: targetW,
      interpolation: img.Interpolation.cubic,
    );
  }
  im = img.grayscale(im);
  im = img.adjustColor(im, contrast: 1.15);
  return img.encodeJpg(im, quality: 92);
}
