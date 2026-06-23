import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const supportEmail = 'developer@knabberfuchs.ch';

/// Open the user's email app with a message to the developer, pre-filled with
/// app + device diagnostics (a normal app can't read system logcat, so this is
/// the useful subset for debugging). [locale] is the active UI language.
/// Returns false if no email app could be launched.
Future<bool> contactDeveloper({String? locale}) async {
  final info = await PackageInfo.fromPlatform();
  final diag = StringBuffer()
    ..writeln('App: Knabberfuchs ${info.version} (${info.buildNumber})');
  if (Platform.isAndroid) {
    final a = await DeviceInfoPlugin().androidInfo;
    diag.writeln('Device: ${a.manufacturer} ${a.model} '
        '(Android ${a.version.release}, API ${a.version.sdkInt})');
  }
  if (locale != null) diag.writeln('Language: $locale');

  final body = '\n\n\n'
      '--- diagnostics (helps me debug — feel free to delete) ---\n$diag';
  final subject = 'Knabberfuchs feedback — ${info.version} (${info.buildNumber})';
  // Build the mailto by hand so spaces encode as %20 (not + which some mail
  // apps show literally in the body).
  final uri = Uri.parse('mailto:$supportEmail'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}');
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
