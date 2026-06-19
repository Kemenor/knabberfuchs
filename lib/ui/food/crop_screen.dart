import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

/// Lets the user drag a rectangle to keep only the nutrition table before OCR.
/// Pops the cropped image bytes (or null if cancelled).
class CropScreen extends StatefulWidget {
  final Uint8List image;
  const CropScreen({super.key, required this.image});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final _controller = CropController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crop to the table'),
        actions: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: () {
                setState(() => _busy = true);
                _controller.crop();
              },
              child: const Text('Done'),
            ),
        ],
      ),
      body: Crop(
        image: widget.image,
        controller: _controller,
        baseColor: Colors.black,
        maskColor: Colors.black.withValues(alpha: 0.6),
        onCropped: (result) {
          if (!mounted) return;
          if (result is CropSuccess) {
            Navigator.of(context).pop(result.croppedImage);
          } else {
            setState(() => _busy = false);
          }
        },
      ),
    );
  }
}
