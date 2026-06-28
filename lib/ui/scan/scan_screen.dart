import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';

/// Barcode/QR scanner. Pops the scanned (or manually entered) string.
///
/// Uses mobile_scanner's recommended explicit lifecycle (start/stop tied to
/// app lifecycle, no autoStart race) to avoid the camera2 NPE on some devices
/// (juliansteenbakker/mobile_scanner#719). Degrades to manual entry if the
/// camera errors or isn't available (e.g. desktop).
class ScanScreen extends StatefulWidget {
  final List<BarcodeFormat> formats;
  final String? title;
  final bool allowManual;

  const ScanScreen({
    super.key,
    this.formats = const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
    this.title,
    this.allowManual = true,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _handled = false;

  /// Consensus capture: count how often each value is decoded and only accept
  /// one once it's been read [_consensusVotes] times. A single misdecoded frame
  /// (a transient wrong value) never repeats, so it can't slip through; a code
  /// actually in front of the camera reaches the threshold within ~100–200 ms.
  final Map<String, int> _votes = {};
  static const int _consensusVotes = 2;

  bool get _cameraSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    if (_cameraSupported) {
      _controller = MobileScannerController(
        autoStart: false,
        // `normal` (not `noDuplicates`) so the same code is re-emitted across
        // frames — the consensus check in _onDetect needs the repeats. A short
        // timeout keeps repeats coming quickly so acceptance still feels instant.
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 100,
        // More pixels help small / low-contrast / curved grocery codes resolve.
        cameraResolution: const Size(1920, 1080),
        formats: widget.formats,
      );
      WidgetsBinding.instance.addObserver(this);
      _safeStart();
    }
  }

  Future<void> _safeStart() async {
    try {
      await _controller?.start();
    } catch (_) {
      // Surfaced by errorBuilder; nothing else to do.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _safeStart();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(controller.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    _controller = null;
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final b in capture.barcodes) {
      final code = b.rawValue;
      if (code == null || code.isEmpty) continue;
      final votes = (_votes[code] ?? 0) + 1;
      _votes[code] = votes;
      if (votes >= _consensusVotes) {
        _handled = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
  }

  Future<void> _enterManually() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    String? code;
    try {
      code = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.scanEnterBarcode),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: l10n.scanExampleHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.scanLookUp),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    if (code != null && code.isNotEmpty && mounted) {
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? l10n.scanBarcode),
        actions: [
          if (_cameraSupported && _controller != null)
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller!,
              builder: (context, state, _) {
                if (state.torchState == TorchState.unavailable) {
                  return const SizedBox.shrink();
                }
                final on = state.torchState == TorchState.on;
                return IconButton(
                  tooltip: l10n.scanTorch,
                  icon: Icon(on ? Symbols.flash_on_rounded : Symbols.flash_off_rounded),
                  onPressed: () => _controller?.toggleTorch(),
                );
              },
            ),
          if (widget.allowManual)
            IconButton(
              tooltip: l10n.scanEnterManually,
              icon: const Icon(Symbols.keyboard_rounded),
              onPressed: _enterManually,
            ),
        ],
      ),
      body: _cameraSupported && _controller != null
          ? Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _controller!,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => _CameraError(
                    message: error.errorDetails?.message ?? error.toString(),
                    onManual: widget.allowManual ? _enterManually : null,
                  ),
                ),
                const IgnorePointer(child: _ScanFrame()),
              ],
            )
          : _CameraError(
              message: l10n.scanCameraOnlyDevice,
              onManual: widget.allowManual ? _enterManually : null,
            ),
    );
  }
}

class _CameraError extends StatelessWidget {
  final String message;
  final VoidCallback? onManual;
  const _CameraError({required this.message, this.onManual});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.photo_camera_back_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.scanCameraFailed,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (onManual != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onManual,
                icon: const Icon(Symbols.keyboard_rounded),
                label: Text(l10n.scanEnterManuallyButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white70, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
