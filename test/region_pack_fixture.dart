import 'package:sqlite3/sqlite3.dart';

/// One `products` row of a region-pack fixture. Defaults give every nutrient a
/// distinct non-null value so mapping tests can pin them.
class PackProduct {
  final String barcode;
  final String name;
  final String? brand;
  final String? lang;
  final String? servingLabel;
  final double? servingG;
  final double kcal100;
  final double? protein100;
  final double? carb100;
  final double? fat100;
  final double? fiber100;
  final double? sugar100;
  final double? satfat100;
  final double? sodiumMg100;
  final double? salt100;
  final String? nutriscore;

  const PackProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.lang = 'en',
    this.servingLabel = '1 bottle',
    this.servingG = 330,
    this.kcal100 = 42,
    this.protein100 = 1.5,
    this.carb100 = 10,
    this.fat100 = 0.5,
    this.fiber100 = 0.1,
    this.sugar100 = 9,
    this.satfat100 = 0.2,
    this.sodiumMg100 = 15,
    this.salt100 = 0.04,
    this.nutriscore = 'c',
  });
}

/// Writes a region-pack SQLite file with the exact schema
/// `pipeline/finalize_pack.py` produces (same column list and order, same FTS5
/// setup). If the pipeline schema drifts, update this fixture *and*
/// `RegionPackStore._cols` together — the layering tests exist to catch that.
void writeRegionPackFixture(String path, List<PackProduct> products) {
  final db = sqlite3.open(path);
  db.execute('''
    CREATE TABLE products (
      barcode TEXT, name TEXT, brand TEXT, lang TEXT, serving_label TEXT,
      serving_g REAL, kcal100 REAL, protein100 REAL, carb100 REAL,
      fat100 REAL, fiber100 REAL, sugar100 REAL, satfat100 REAL,
      sodium_mg100 REAL, salt100 REAL, nutriscore TEXT
    );
    CREATE UNIQUE INDEX idx_barcode ON products(barcode);
    CREATE VIRTUAL TABLE products_fts USING fts5(
      name, brand,
      content='products', content_rowid='rowid',
      tokenize='unicode61 remove_diacritics 2'
    );
  ''');
  final stmt = db.prepare(
    'INSERT INTO products VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
  );
  for (final p in products) {
    stmt.execute([
      p.barcode,
      p.name,
      p.brand,
      p.lang,
      p.servingLabel,
      p.servingG,
      p.kcal100,
      p.protein100,
      p.carb100,
      p.fat100,
      p.fiber100,
      p.sugar100,
      p.satfat100,
      p.sodiumMg100,
      p.salt100,
      p.nutriscore,
    ]);
  }
  stmt.close();
  db.execute(
    "INSERT INTO products_fts(rowid, name, brand) "
    "SELECT rowid, name, COALESCE(brand, '') FROM products",
  );
  db.close();
}
