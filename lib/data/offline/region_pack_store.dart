import 'package:sqlite3/sqlite3.dart';

import '../../domain/enums.dart';
import '../../domain/search_query.dart';
import '../db/database.dart';

/// Holds the downloaded region packs as read-only SQLite handles and searches
/// them via their FTS5 index. Results are synthetic [Food]s with id 0 — call
/// FoodRepository.ensurePersisted before logging.
class RegionPackStore {
  final Map<String, Database> _open = {};
  final Map<String, String> _paths = {};

  /// Sync the open handles to [codeToPath] (closing removed packs, opening
  /// new). Pack files are versioned, so an update arrives as a *new path* for
  /// an existing code: the stale handle must be closed and reopened, never
  /// kept serving the old file.
  void setPacks(Map<String, String> codeToPath) {
    for (final code in _open.keys.toList()) {
      if (codeToPath[code] != _paths[code]) {
        _open.remove(code)?.close();
        _paths.remove(code);
      }
    }
    for (final entry in codeToPath.entries) {
      if (_open.containsKey(entry.key)) continue;
      try {
        _open[entry.key] = sqlite3.open(entry.value, mode: OpenMode.readOnly);
        _paths[entry.key] = entry.value;
      } catch (_) {
        // corrupt/missing file — skip
      }
    }
  }

  bool get isEmpty => _open.isEmpty;

  static const _cols =
      'p.barcode, p.name, p.brand, p.lang, p.serving_g, p.serving_label, '
      'p.kcal100, p.protein100, p.carb100, p.fat100, p.fiber100, p.sugar100, '
      'p.satfat100, p.sodium_mg100, p.salt100';

  List<Food> search(String query, {int limit = 50}) {
    final tokens = searchTokens(query);
    if (tokens.isEmpty || _open.isEmpty) return const [];
    final match = tokens.map((t) => '$t*').join(' ');
    final byBarcode = <String, Food>{};
    for (final db in _open.values) {
      try {
        final rs = db.select(
          'SELECT $_cols FROM products_fts f JOIN products p ON p.rowid = f.rowid '
          'WHERE products_fts MATCH ? ORDER BY length(p.name) LIMIT ?',
          [match, limit],
        );
        for (final row in rs) {
          final bc = row['barcode'] as String?;
          if (bc == null || byBarcode.containsKey(bc)) continue;
          byBarcode[bc] = _toFood(row);
        }
      } catch (_) {
        continue;
      }
    }
    final list = byBarcode.values.toList()
      ..sort((a, b) => a.name.length.compareTo(b.name.length));
    return list.take(limit).toList();
  }

  Food? lookupBarcode(String barcode) {
    for (final db in _open.values) {
      try {
        final rs = db.select(
          'SELECT $_cols FROM products p WHERE p.barcode = ? LIMIT 1',
          [barcode],
        );
        if (rs.isNotEmpty) return _toFood(rs.first);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Food _toFood(Row row) {
    double? d(String k) => (row[k] as num?)?.toDouble();
    final bc = row['barcode'] as String?;
    return Food(
      id: 0,
      source: FoodSource.openFoodFacts,
      externalId: bc,
      barcode: bc,
      name: row['name'] as String,
      brand: row['brand'] as String?,
      locale: row['lang'] as String?,
      servingG: d('serving_g'),
      servingLabel: row['serving_label'] as String?,
      kcal100: d('kcal100') ?? 0,
      protein100: d('protein100'),
      carb100: d('carb100'),
      fat100: d('fat100'),
      fiber100: d('fiber100'),
      sugar100: d('sugar100'),
      satFat100: d('satfat100'),
      sodiumMg100: d('sodium_mg100'),
      saltG100: d('salt100'),
      isFavorite: false,
      usageCount: 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  void dispose() {
    for (final db in _open.values) {
      db.close();
    }
    _open.clear();
    _paths.clear();
  }
}
