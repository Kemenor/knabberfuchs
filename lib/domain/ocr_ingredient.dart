import 'nutrition.dart';
import 'text_fold.dart';
import 'units.dart';

/// One ingredient parsed from a recipe line, e.g. "Olive Oil 2 tbsp" (OCR) or
/// "- 200 g flour" (pasted from an AI app).
class OcrIngredient {
  final String name;
  final double amount;

  /// Mass/volume unit if recognized; null for count units ([rawUnit] holds the
  /// token, e.g. 'cloves', 'x', 'heads').
  final AmountUnit? unit;
  final String rawUnit;

  /// An AI app's nutrition estimate for this amount (totals, not per 100 g) —
  /// usable without matching a food, marked as estimated. Null for lines that
  /// must be matched (OCR, plain lists).
  final Nutrition? estimate;

  const OcrIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.rawUnit,
    this.estimate,
  });

  bool get isCount => unit == null;

  /// Grams when the unit is mass/volume; null for count units (resolve via the
  /// matched food's serving size in the UI).
  double? get gramsIfKnown => unit?.toGrams(amount);
}

/// A pasted ingredient list: the items plus what the text says about itself
/// — a heading as the name, "Serves 4" as the servings.
class IngredientList {
  final String? title;
  final double? servings;
  final List<OcrIngredient> items;

  const IngredientList({this.title, this.servings, required this.items});
}

/// Normalize an ingredient name for the OCR auto-match memory: lowercase,
/// fold common accents, strip punctuation, collapse whitespace. So "Crème
/// Fraîche" and "creme fraiche" map to the same key.
String normalizeOcrName(String s) {
  return foldDiacritics(s.toLowerCase().trim())
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Count-style units we keep (the food is matched separately), in the app's
/// four languages, folded (lowercase, no accents). Anything else unrecognized
/// after a number (mins, people, kcal, …) is a non-ingredient line in the
/// trailing form, or part of the name in the amount-first form ("2 eggs").
const _countUnits = {
  // en
  'x', 'clove', 'cloves', 'head', 'heads', 'slice', 'slices', 'piece',
  'pieces', 'pinch', 'pinches', 'can', 'cans', 'tin', 'tins', 'bunch',
  'bunches', 'sprig', 'sprigs', 'handful', 'handfuls', 'leaf', 'leaves',
  'stick', 'sticks', 'ball', 'balls', 'pack', 'packs', 'jar', 'jars', 'sheet',
  'sheets',
  // de
  'stk', 'stuck', 'prise', 'prisen', 'scheibe', 'scheiben', 'dose', 'dosen',
  'bund', 'zehe', 'zehen', 'packung', 'packungen', 'glas', 'glaser', 'becher',
  'handvoll', 'blatt', 'blatter', 'zweig', 'zweige',
  // fr (pièce/pièces fold to the English 'piece'/'pieces' above)
  'pincee', 'pincees', 'tranche', 'tranches', 'gousse',
  'gousses', 'boite', 'boites', 'botte', 'bottes', 'feuille', 'feuilles',
  'sachet', 'sachets', 'branche', 'branches',
  // it
  'pezzo', 'pezzi', 'pizzico', 'pizzichi', 'fetta', 'fette', 'spicchio',
  'spicchi', 'lattina', 'lattine', 'mazzo', 'mazzi', 'foglia', 'foglie',
  'confezione', 'confezioni', 'rametto', 'rametti',
};

/// Mass/volume unit tokens (folded) → unit + factor to the base amount.
final Map<String, (AmountUnit, double)> _massVolume = {
  for (final t in [
    'g',
    'gr',
    'gram',
    'grams',
    'gramm',
    'gramme',
    'grammes',
    'grammi',
    'grammo',
  ])
    t: (AmountUnit.grams, 1),
  for (final t in [
    'kg',
    'kilo',
    'kilos',
    'kilogram',
    'kilograms',
    'kilogramm',
    'chilo',
    'chili',
  ])
    t: (AmountUnit.grams, 1000),
  'mg': (AmountUnit.grams, 0.001),
  'ml': (AmountUnit.milliliters, 1),
  'cl': (AmountUnit.milliliters, 10),
  'dl': (AmountUnit.milliliters, 100),
  for (final t in ['l', 'liter', 'litre', 'liters', 'litres', 'litro', 'litri'])
    t: (AmountUnit.milliliters, 1000),
  for (final t in [
    'tbsp',
    'tbsps',
    'tbs',
    'tablespoon',
    'tablespoons',
    'el',
    'essloffel',
    'cs',
    'cas',
    'cucchiaio',
    'cucchiai',
  ])
    t: (AmountUnit.tablespoon, 1),
  for (final t in [
    'tsp',
    'tsps',
    'teaspoon',
    'teaspoons',
    'tl',
    'teeloffel',
    'cc',
    'cac',
    'cucchiaino',
    'cucchiaini',
  ])
    t: (AmountUnit.teaspoon, 1),
  for (final t in ['cup', 'cups', 'tasse', 'tassen', 'tazza', 'tazze'])
    t: (AmountUnit.cup, 1),
};

/// Multi-word French spoon units, matched on the folded text before the
/// single-token lookup.
const _multiWordUnits = {
  'c. a soupe': AmountUnit.tablespoon,
  'c.a.s.': AmountUnit.tablespoon,
  'cuillere a soupe': AmountUnit.tablespoon,
  'cuilleres a soupe': AmountUnit.tablespoon,
  'c. a cafe': AmountUnit.teaspoon,
  'c.a.c.': AmountUnit.teaspoon,
  'cuillere a cafe': AmountUnit.teaspoon,
  'cuilleres a cafe': AmountUnit.teaspoon,
};

/// Words that, right after a number, mean "not an ingredient" (time, energy,
/// people) in the amount-first form.
const _notIngredientUnits = {
  'min',
  'mins',
  'minute',
  'minutes',
  'minuten',
  'minuti',
  'h',
  'std',
  'hour',
  'hours',
  'stunde',
  'stunden',
  'heure',
  'heures',
  'ora',
  'ore',
  'kcal',
  'cal',
  'kj',
  'grad',
  'degrees',
  'people',
  'persons',
  'personen',
  'persone',
  'personnes',
  'servings',
  'serving',
  'portions',
  'portion',
  'portionen',
  'porzioni',
  'porzione',
};

/// Names that are nutrition summary labels, not ingredients — an AI's
/// "- Protein: 45 g" under the list must not import as an ingredient.
const _nutrientNames = {
  'protein',
  'proteins',
  'proteine',
  'proteines',
  'eiweiss',
  'carbs',
  'carbohydrates',
  'kohlenhydrate',
  'glucides',
  'carboidrati',
  'fat',
  'fats',
  'fett',
  'lipides',
  'grassi',
  'fiber',
  'fibre',
  'fibres',
  'ballaststoffe',
  'fibre alimentari',
  'calories',
  'kalorien',
  'energy',
  'energie',
  'energia',
  'total',
  'gesamt',
  'totale',
};

/// An amount: "200", "1,5", "1/2", "1 1/2", "½", "1½".
const _amountPattern =
    r'(\d+\s+\d+/\d+|\d+/\d+|\d+(?:[.,]\d+)?\s*[½¼¾⅓⅔]|\d+(?:[.,]\d+)?|[½¼¾⅓⅔])';

const _vulgar = {'½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 1 / 3, '⅔': 2 / 3};

double? _parseAmount(String raw) {
  final s = raw.trim();
  final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(s);
  if (mixed != null) {
    final d = double.parse(mixed.group(3)!);
    return d == 0
        ? null
        : double.parse(mixed.group(1)!) + double.parse(mixed.group(2)!) / d;
  }
  final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(s);
  if (frac != null) {
    final d = double.parse(frac.group(2)!);
    return d == 0 ? null : double.parse(frac.group(1)!) / d;
  }
  final last = s.isEmpty ? '' : s.substring(s.length - 1);
  if (_vulgar.containsKey(last)) {
    final whole = s.substring(0, s.length - 1).trim().replaceAll(',', '.');
    return (whole.isEmpty ? 0 : double.parse(whole)) + _vulgar[last]!;
  }
  return double.tryParse(s.replaceAll(',', '.'));
}

String _fold(String s) => foldDiacritics(s.toLowerCase());

/// Strip list decoration an AI or a website adds: bullets, numbering,
/// checkboxes, markdown emphasis.
String _clean(String line) {
  var s = line.trim();
  s = s.replaceAll('**', '').replaceAll('__', '').replaceAll('`', '');
  s = s.replaceFirst(RegExp(r'^(?:[-*•·–—]|\d+[.)])\s+'), '');
  s = s.replaceFirst(RegExp(r'^\[[ xX]\]\s*'), '');
  return s.trim();
}

/// The trailing form: "Olive oil 2 tbsp", "Olive oil: 2 tbsp", "Olive oil –
/// 200 g", "Olive oil (2 tbsp)". The unit must be a known one — OCR rows like
/// "Prep 30 mins" are dropped.
final _trailingRe = RegExp(
  '^(.+?)[\\s:,–—-]+\\(?$_amountPattern\\s*([A-Za-zÀ-ÿ]+)\\.?\\)?\$',
);

/// The amount-first form: "200 g flour", "200g flour", "2 EL Olivenöl",
/// "2 eggs", "½ cup milk".
final _leadingRe = RegExp('^$_amountPattern\\s*(.*)\$');

OcrIngredient? _resolve(String name, double amount, String unitToken) {
  final u = _fold(unitToken).replaceAll(RegExp(r'\.$'), '');
  final mv = _massVolume[u];
  if (mv != null) {
    return OcrIngredient(
      name: name,
      amount: amount * mv.$2,
      unit: mv.$1,
      rawUnit: u,
    );
  }
  if (_countUnits.contains(u)) {
    return OcrIngredient(name: name, amount: amount, unit: null, rawUnit: u);
  }
  return null;
}

bool _isIngredientName(String name) {
  final n = normalizeOcrName(name);
  return n.length >= 2 && !_nutrientNames.contains(n);
}

OcrIngredient? _parseTrailing(String line) {
  final m = _trailingRe.firstMatch(line);
  if (m == null) return null;
  final name = m.group(1)!.trim();
  final amount = _parseAmount(m.group(2)!);
  if (amount == null || !_isIngredientName(name)) return null;
  return _resolve(name, amount, m.group(3)!);
}

OcrIngredient? _parseLeading(String line) {
  final m = _leadingRe.firstMatch(line);
  if (m == null) return null;
  final amount = _parseAmount(m.group(1)!);
  var rest = m.group(2)!.trim();
  if (amount == null || rest.isEmpty) return null;

  AmountUnit? unit;
  var rawUnit = 'x';
  var factor = 1.0;
  final folded = _fold(rest);
  final multi = _multiWordUnits.keys
      .where((k) => folded.startsWith('$k '))
      .firstOrNull;
  if (multi != null) {
    unit = _multiWordUnits[multi];
    rawUnit = unit!.label;
    rest = rest.substring(multi.length).trim();
  } else {
    final tok = RegExp(r'^([A-Za-zÀ-ÿ]+\.?)(?:\s+|$)').firstMatch(rest);
    final u = tok == null
        ? ''
        : _fold(tok.group(1)!).replaceAll(RegExp(r'\.$'), '');
    if (_notIngredientUnits.contains(u)) return null;
    final mv = _massVolume[u];
    if (mv != null) {
      (unit, factor) = mv;
      rawUnit = u;
      rest = rest.substring(tok!.end).trim();
    } else if (_countUnits.contains(u)) {
      rawUnit = u;
      rest = rest.substring(tok!.end).trim();
    }
    // Otherwise the word is the food itself: "2 eggs" → 2 × "eggs".
  }
  // "200 g of flour", "100 g de farine", "un filo d'olio".
  rest = rest.replaceFirst(
    RegExp(r"^(?:of|de|d'|di|von)\s*", caseSensitive: false),
    '',
  );
  if (!_isIngredientName(rest)) return null;
  return OcrIngredient(
    name: rest,
    amount: amount * factor,
    unit: unit,
    rawUnit: rawUnit,
  );
}

OcrIngredient? _parseLine(String raw) {
  final line = _clean(raw);
  if (line.length < 2) return null;
  // Trailing first: it's the OCR layout and keeps names with digits intact
  // ("Omega 3 Fish Oil 200g").
  return _parseTrailing(line) ?? _parseLeading(line);
}

/// Parse recipe lines into ingredients. Lines without an amount (headers,
/// method text, "Serves 4") are skipped. Accepts the OCR layout ("Garlic 2
/// cloves") and the written one ("- 2 cloves garlic", "200 g Mehl", "½ cup
/// milk"), with bullets, numbering and markdown stripped.
List<OcrIngredient> parseIngredientLines(Iterable<String> lines) => [
  for (final l in lines) ?_parseLine(l),
];

final _servingsRe = RegExp(
  r'(?:serves|servings?|portions?|portionen|porzioni|personnes?)\s*:?\s*(\d+(?:[.,]\d+)?)'
  r'|(\d+(?:[.,]\d+)?)\s*(?:servings?|portions?|portionen|personen|persons|people|porzioni|persone|personnes)',
);

const _sectionWords = {
  'ingredients',
  'zutaten',
  'ingredienti',
  'method',
  'instructions',
  'steps',
  'directions',
  'zubereitung',
  'preparation',
  'preparazione',
  'procedimento',
  'shopping list',
  'einkaufsliste',
};

/// A heading-like line: a markdown heading or a short, sentence-less line.
/// AI prose ("Here's your chili, adapted to 600 kcal:") is not.
String? _title(String raw) {
  var s = raw.trim();
  final heading = s.startsWith('#') || (s.startsWith('**') && s.endsWith('**'));
  s = _clean(s.replaceFirst(RegExp(r'^#+\s*'), ''));
  if (s.isEmpty || s.length > 60) return null;
  if (_sectionWords.contains(_fold(s).replaceAll(RegExp(r'[:\s]+$'), ''))) {
    return null;
  }
  if (heading) return s.replaceFirst(RegExp(r':$'), '');
  final sentence = RegExp(r'[.:!?]$').hasMatch(s) || s.split(' ').length > 6;
  return sentence ? null : s;
}

/// Parse a whole pasted text (from an AI app, a website, a note): every line
/// that reads as an ingredient, the first heading before them as the title,
/// and a "Serves 4" / "4 Portionen" line as the servings.
IngredientList parseIngredientText(String text) {
  String? title;
  double? servings;
  final items = <OcrIngredient>[];
  for (final raw in text.split(RegExp(r'\r?\n'))) {
    if (raw.trim().isEmpty) continue;
    final s = _servingsRe.firstMatch(_fold(raw));
    if (s != null && servings == null) {
      servings = _parseAmount(s.group(1) ?? s.group(2)!);
      continue;
    }
    final item = _parseLine(raw);
    if (item != null) {
      items.add(item);
    } else if (title == null && items.isEmpty) {
      title = _title(raw);
    }
  }
  return IngredientList(title: title, servings: servings, items: items);
}
