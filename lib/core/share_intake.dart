import 'dart:io' show Platform;

import 'package:flutter/services.dart';

const _intentChannel = MethodChannel('ch.knabberfuchs.app/intent');

/// Text shared into the app from another one (Android's share sheet:
/// ACTION_SEND text/plain → MainActivity). The platform side holds it until
/// it's taken, so a share that launched the app isn't lost while Flutter
/// starts. iOS has no share extension yet — always null there.
class ShareIntake {
  const ShareIntake._();

  /// The pending shared text, handed over once (then forgotten), or null.
  static Future<String?> take() async {
    if (!Platform.isAndroid) return null;
    try {
      return await _intentChannel.invokeMethod<String>('takeSharedText');
    } on MissingPluginException {
      return null; // tests / platforms without the channel
    } on PlatformException {
      return null;
    }
  }

  /// [onShare] runs when a share arrives while the app is already running.
  static void listen(void Function() onShare) {
    if (!Platform.isAndroid) return;
    _intentChannel.setMethodCallHandler((call) async {
      if (call.method == 'shareReady') onShare();
    });
  }
}
