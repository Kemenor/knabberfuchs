import 'units.dart';

/// One ingredient parsed from an OCR'd recipe line, e.g. "Olive Oil 2 tbsp".
class OcrIngredient {
  final String name;
  final double amount;

  /// Mass/volume unit if recognized; null for count units ([rawUnit] holds the
  /// token, e.g. 'cloves', 'x', 'heads').
  final AmountUnit? unit;
  final String rawUnit;

  const OcrIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.rawUnit,
  });

  bool get isCount => unit == null;

  /// Grams when the unit is mass/volume; null for count units (resolve via the
  /// matched food's serving size in the UI).
  double? get gramsIfKnown => unit?.toGrams(amount);
}

/// Normalize an ingredient name for the OCR auto-match memory: lowercase,
/// fold common accents, strip punctuation, collapse whitespace. So "Crème
/// Fraîche" and "creme fraiche" map to the same key.
String normalizeOcrName(String s) {
  var n = s.toLowerCase().trim();
  const accents = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n', 'ß': 'ss',
  };
  accents.forEach((k, v) => n = n.replaceAll(k, v));
  return n
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Count-style units we keep (the food is matched separately); anything else
/// unrecognized (mins, people, kcal, …) is treated as a non-ingredient line.
const _countUnits = {
  'x', 'clove', 'cloves', 'head', 'heads', 'slice', 'slices', 'piece', 'pieces',
  'pinch', 'pinches', 'can', 'cans', 'tin', 'tins', 'bunch', 'bunches', 'sprig',
  'sprigs', 'handful', 'handfuls', 'leaf', 'leaves', 'stick', 'sticks', 'ball',
  'balls', 'pack', 'packs', 'jar', 'jars', 'sheet', 'sheets',
};

final _lineRe = RegExp(r'^(.+?)\s+(\d+(?:[.,]\d+)?)\s*([a-zA-Z]+)\.?$');

/// Parse OCR text lines into ingredients. Lines without a trailing
/// number+recognized-unit (headers, method text, "Serves 4") are skipped.
List<OcrIngredient> parseIngredientLines(Iterable<String> lines) {
  final out = <OcrIngredient>[];
  for (final raw in lines) {
    final m = _lineRe.firstMatch(raw.trim());
    if (m == null) continue;
    final name = m.group(1)!.trim();
    if (name.length < 2) continue;
    var amount = double.parse(m.group(2)!.replaceAll(',', '.'));
    final rawUnit = m.group(3)!.toLowerCase();

    AmountUnit? unit;
    switch (rawUnit) {
      case 'g' || 'gr' || 'gram' || 'grams':
        unit = AmountUnit.grams;
      case 'kg':
        unit = AmountUnit.grams;
        amount *= 1000;
      case 'mg':
        unit = AmountUnit.grams;
        amount /= 1000;
      case 'ml':
        unit = AmountUnit.milliliters;
      case 'l' || 'liter' || 'litre' || 'liters' || 'litres':
        unit = AmountUnit.milliliters;
        amount *= 1000;
      case 'tbsp' || 'tbsps' || 'tablespoon' || 'tablespoons':
        unit = AmountUnit.tablespoon;
      case 'tsp' || 'tsps' || 'teaspoon' || 'teaspoons':
        unit = AmountUnit.teaspoon;
      case 'cup' || 'cups':
        unit = AmountUnit.cup;
      default:
        unit = null;
    }
    // Skip lines whose "unit" is an unrecognized word (mins, people, kcal…).
    if (unit == null && !_countUnits.contains(rawUnit)) continue;

    out.add(OcrIngredient(
        name: name, amount: amount, unit: unit, rawUnit: rawUnit));
  }
  return out;
}
