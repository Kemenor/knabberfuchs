import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'db/database.dart';

/// Stores the meal photos kept from AI recognition as plain JPEG files in the
/// app's documents dir (`meal_photos/`); entries reference them by file name
/// only, so the folder can move with the platform's documents path.
///
/// Files are written once and never edited. Deletion is a startup sweep
/// ([sweepOrphans]) instead of per-delete hooks: entries die through too many
/// paths to hook them all (SQL cascade on group delete, backup restore wiping
/// the diary, split replacing a group), and a missed hook would leak storage
/// forever. A dangling reference the other way (backup restored on a new
/// device) is harmless — display tolerates a missing file.
class MealPhotoStore {
  final AppDatabase db;

  /// Overridable in tests (path_provider needs a platform channel).
  final Future<Directory> Function() _documentsDir;

  MealPhotoStore(this.db, {Future<Directory> Function()? documentsDir})
    : _documentsDir = documentsDir ?? getApplicationDocumentsDirectory;

  Future<Directory> _photosDir() async {
    final docs = await _documentsDir();
    return Directory('${docs.path}/meal_photos').create(recursive: true);
  }

  /// Absolute path of the photos folder (for resolving stored file names).
  Future<String> photosDirPath() async => (await _photosDir()).path;

  /// Persist [bytes] (already JPEG — the picker re-encodes) and return the
  /// file name to store on the entry.
  Future<String> save(Uint8List bytes) async {
    final dir = await _photosDir();
    final name = 'meal_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File('${dir.path}/$name').writeAsBytes(bytes, flush: true);
    return name;
  }

  /// Delete photo files no entry references anymore. Best-effort: any error
  /// (weird platform FS, file locked) is swallowed — orphans just survive
  /// until the next sweep. Files younger than a day are kept so a sweep never
  /// races a photo saved moments before its entry commits.
  Future<void> sweepOrphans() async {
    try {
      final dir = await _photosDir();
      final referenced = await db.referencedPhotoPaths();
      final cutoff = DateTime.now().subtract(const Duration(days: 1));
      await for (final f in dir.list()) {
        if (f is! File) continue;
        final name = f.uri.pathSegments.last;
        if (referenced.contains(name)) continue;
        if ((await f.stat()).modified.isAfter(cutoff)) continue;
        try {
          await f.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }
}
