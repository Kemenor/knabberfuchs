/// Per-100 g nutrition values parsed from an OCR'd nutrition table.
class NutritionLabel {
  double? kcal100;
  double? protein100;
  double? carb100;
  double? fat100;
  double? fiber100;
  double? sugar100;
  double? satFat100;
  double? saltG100;

  bool get hasAny =>
      kcal100 != null ||
      protein100 != null ||
      carb100 != null ||
      fat100 != null;
}

// Keyword sets (lowercased substrings) for DE / FR / IT / EN labels. More
// specific rows (saturates, sugars) are tested before their parents (fat,
// carbs) so "of which sugars" doesn't get read as carbohydrate.
const _energy = ['energie', 'énergie', 'energy', 'energia', 'brennwert'];
const _satFat = ['gesättigt', 'satur', 'saturé', 'saturi'];
const _fat = [
  'fett',
  'matières grasses',
  'matieres grasses',
  'lipides',
  'fat',
  'grassi',
];
const _fiber = ['ballaststoffe', 'fibres', 'fibre', 'fiber'];
const _sugar = ['zucker', 'sucres', 'sugars', 'zuccheri'];
const _carb = ['kohlenhydrate', 'glucides', 'carbohydrate', 'carboidrati'];
const _protein = [
  'eiweiß',
  'eiweiss',
  'protéines',
  'proteines',
  'protein',
  'proteine',
];
// Whole words only: plain contains would let 'sel' claim the selenium row of
// Swiss labels ("Selen 0,01 mg") or French prose ("selon"), and 'sale'
// Italian derivatives ("salato") — assigning the wrong number to salt.
final _saltRe = RegExp(r'\b(salz|sel|salt|sale)\b');

bool _has(String line, List<String> keys) => keys.any(line.contains);

final _numRe = RegExp(r'(\d+(?:[.,]\d+)?)');
final _kcalRe = RegExp(r'(\d+(?:[.,]\d+)?)\s*kcal');
final _kjRe = RegExp(r'(\d+(?:[.,]\d+)?)\s*kj');

double? _num(String s) {
  final m = _numRe.firstMatch(s);
  return m == null ? null : double.tryParse(m.group(1)!.replaceAll(',', '.'));
}

/// A gram value per 100 g can't exceed 100; reject OCR misreads (e.g. "1,5"
/// read as "159") so we don't prefill impossible numbers.
double? _grams(String s) {
  final v = _num(s);
  return (v != null && v >= 0 && v <= 100) ? v : null;
}

/// Digit-grouping separator between a digit and exactly three digits with no
/// fourth: Swiss 2'000 / 2’000, German 1.046, French 2 000 (incl. no-break
/// spaces), English 1,000. "473,0" keeps its decimal comma.
final _groupingRe = RegExp("(\\d)[\\u00A0\\u202F '’.,](\\d{3})(?!\\d)");

/// Collapse grouped energy figures so the kcal/kJ regexes read the whole
/// number: "Energie 2'000 kJ" once first-matched as "000 kj" -> 0 kcal, and
/// "1.046 kJ" parsed as 1.046 kJ -> 0.25 kcal. Looped for multi-group values.
String _ungroup(String s) {
  var out = s;
  while (true) {
    final next = out.replaceAllMapped(_groupingRe, (m) => '${m[1]}${m[2]}');
    if (next == out) return out;
    out = next;
  }
}

double? _energyKcal(String rawLine) {
  final line = _ungroup(rawLine);
  final k = _kcalRe.firstMatch(line);
  if (k != null) return double.tryParse(k.group(1)!.replaceAll(',', '.'));
  final j = _kjRe.firstMatch(line);
  if (j != null) {
    final kj = double.tryParse(j.group(1)!.replaceAll(',', '.'));
    return kj == null ? null : (kj / 4.184); // kJ -> kcal
  }
  return null;
}

/// Parse OCR lines from a nutrition table into per-100 g values. Best-effort:
/// the user reviews/edits before saving.
NutritionLabel parseNutritionLabel(Iterable<String> lines) {
  final out = NutritionLabel();
  for (final raw in lines) {
    final line = raw.toLowerCase().trim();
    if (line.isEmpty) continue;

    if (out.kcal100 == null && _has(line, _energy)) {
      final k = _energyKcal(line);
      // Ceiling allows pure fats/oils (~900 kcal/100 g) plus OCR slack.
      out.kcal100 = (k != null && k >= 0 && k <= 1200) ? k : null;
    } else if (out.satFat100 == null && _has(line, _satFat)) {
      out.satFat100 = _grams(line);
    } else if (out.sugar100 == null && _has(line, _sugar)) {
      out.sugar100 = _grams(line);
    } else if (out.fiber100 == null && _has(line, _fiber)) {
      out.fiber100 = _grams(line);
    } else if (out.fat100 == null && _has(line, _fat)) {
      out.fat100 = _grams(line);
    } else if (out.carb100 == null && _has(line, _carb)) {
      out.carb100 = _grams(line);
    } else if (out.protein100 == null && _has(line, _protein)) {
      out.protein100 = _grams(line);
    } else if (out.saltG100 == null && _saltRe.hasMatch(line)) {
      out.saltG100 = _grams(line);
    }
  }
  return out;
}
