import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const _intentChannel = MethodChannel('ch.knabberfuchs.app/intent');

/// Open [url] in an external app or the browser. Returns false if nothing could
/// handle it.
///
/// On **Android** this goes through a platform channel that launches the VIEW
/// intent with `FLAG_ACTIVITY_NEW_TASK`, so a handing-off app (e.g. Open Food
/// Facts) opens in its *own* task instead of stacking onto ours — otherwise
/// reopening Knabberfuchs would resurface the other app. `url_launcher` doesn't
/// expose intent flags, hence the channel. On **iOS** `url_launcher` is fine:
/// opening another app is already a clean app switch.
Future<bool> openExternalUrl(String url) async {
  if (Platform.isAndroid) {
    return await _intentChannel.invokeMethod<bool>('openExternal', {
          'url': url,
        }) ??
        false;
  }
  return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
