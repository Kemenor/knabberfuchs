import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'backup.dart';
import 'db/database.dart';

/// Builds/shares backup ZIPs and restores from them. The ZIP contains
/// backup.json (the lossless logical restore source), entries.csv (portable /
/// spreadsheet-friendly), and manifest.json (schema version + timestamp).
class BackupService {
  final AppDatabase db;
  BackupService(this.db);

  Future<File> buildZip() async {
    final now = DateTime.now();
    final map = await buildBackupMap(db, exportedAt: now);
    final jsonBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(map),
    );
    final csvBytes = utf8.encode(buildEntriesCsv(await db.allEntries()));
    final manifestBytes = utf8.encode(
      jsonEncode({
        'app': 'calorie_tracker',
        'schemaVersion': backupSchemaVersion,
        'exportedAt': now.toIso8601String(),
      }),
    );

    final archive = Archive()
      ..addFile(ArchiveFile('backup.json', jsonBytes.length, jsonBytes))
      ..addFile(ArchiveFile('entries.csv', csvBytes.length, csvBytes))
      ..addFile(
        ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
      );

    final zipBytes = ZipEncoder().encode(archive);
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd-HHmmss').format(now);
    final file = File('${dir.path}/calorietracker-backup-$stamp.zip');
    await file.writeAsBytes(zipBytes);
    return file;
  }

  /// Build the ZIP and open the system SAVE dialog (SAF / document picker) —
  /// the share sheet has no reliable save-to-file target on every ROM, and
  /// the save dialog reaches cloud providers too (knobelfuchs finding,
  /// 2026-07-14). Returns the zip size in bytes, or null when cancelled.
  Future<int?> saveBackup() async {
    final file = await buildZip();
    try {
      final saved = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: file.uri.pathSegments.last,
          mimeTypesFilter: const ['application/zip'],
        ),
      );
      return saved != null ? await file.length() : null;
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  /// Replace all user data with the contents of a backup .zip. Throws
  /// [FormatException] if the file isn't a recognizable backup.
  Future<void> restoreFromZip(String path) async {
    final bytes = await File(path).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final jsonFile = archive.files.firstWhere(
      (f) => f.name == 'backup.json',
      orElse: () =>
          throw const FormatException('Not a valid backup (no backup.json).'),
    );
    final map =
        jsonDecode(utf8.decode(jsonFile.content as List<int>))
            as Map<String, dynamic>;
    await restoreBackupMap(db, map);
  }
}
