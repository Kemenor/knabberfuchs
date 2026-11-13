import 'dart:convert';

import 'day_summary.dart' show TargetMetric;
import 'enums.dart';
import 'nutrition.dart';
import 'ocr_ingredient.dart';
import 'units.dart';

/// The structured answer the user's own AI app gives back (PLAN
/// "AI bridge", A.3) — a JSON object marked `"knabberfuchs": 1`, usually in a
/// fenced code block somewhere in the reply:
///
/// ```json
/// {"knabberfuchs": 1, "kind": "meal", "name": "Lunch bowl", "meal": "lunch",
///  "items": [{"name": "Rice, cooked", "g": 180, "kcal": 234, "protein": 4.3,
///             "carbs": 51, "fat": 0.5}]}
/// ```
///
/// Items carrying `kcal` are the AI's **estimate** for that amount (totals,
/// not per 100 g); items without nutrition must be matched to a food.
/// Unknown keys are ignored, so the format can grow.
class AiBlock {
  /// `meal` (log it) or `recipe` (save it) — both stay possible on review.
  final bool isRecipe;
  final String? name;
  final double? servings;
  final MealType? meal;

  /// `yyyy-MM-dd` when the AI said which day ("yesterday's dinner").
  final String? day;
  final List<OcrIngredient> items;

  const AiBlock({
    required this.isRecipe,
    this.name,
    this.servings,
    this.meal,
    this.day,
    required this.items,
  });
}

/// The first `knabberfuchs` block in [text], or null. Tolerant of prose and
/// code fences around it: every `{` is tried as the start of a JSON object.
AiBlock? findAiBlock(String text) {
  for (var i = text.indexOf('{'); i >= 0; i = text.indexOf('{', i + 1)) {
    final end = _matchingBrace(text, i);
    if (end < 0) continue;
    final candidate = text.substring(i, end + 1);
    if (!candidate.contains('knabberfuchs')) continue;
    try {
      final map = jsonDecode(candidate);
      if (map is Map && map.containsKey('knabberfuchs')) return _parse(map);
    } on FormatException {
      continue; // a brace inside prose; keep looking
    }
  }
  return null;
}

/// Index of the `}` closing the object opened at [start], respecting strings.
int _matchingBrace(String s, int start) {
  var depth = 0;
  var inString = false;
  for (var i = start; i < s.length; i++) {
    final c = s[i];
    if (inString) {
      if (c == r'\') {
        i++; // skip the escaped character
      } else if (c == '"') {
        inString = false;
      }
    } else if (c == '"') {
      inString = true;
    } else if (c == '{') {
      depth++;
    } else if (c == '}') {
      if (--depth == 0) return i;
    }
  }
  return -1;
}

double? _num(Object? v) => switch (v) {
  num n => n.toDouble(),
  String s => double.tryParse(s.replaceAll(',', '.')),
  _ => null,
};

AiBlock _parse(Map map) {
  final items = <OcrIngredient>[];
  for (final raw in (map['items'] as List? ?? const [])) {
    if (raw is! Map) continue;
    final item = _item(raw);
    if (item != null) items.add(item);
  }
  final day = map['date']?.toString();
  return AiBlock(
    isRecipe: map['kind']?.toString().toLowerCase() == 'recipe',
    name: (map['name'] as Object?)?.toString().trim().nullIfEmpty,
    servings: _num(map['servings']),
    meal: MealType.values
        .where((m) => m.name == map['meal']?.toString().toLowerCase())
        .firstOrNull,
    day: day != null && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(day)
        ? day
        : null,
    items: items,
  );
}

OcrIngredient? _item(Map raw) {
  final name = raw['name']?.toString().trim() ?? '';
  if (name.isEmpty) return null;

  // Amount: grams / ml directly, else an amount + unit in the parser's
  // vocabulary ("2 tbsp", "1 slice"), else one piece.
  final g = _num(raw['g'] ?? raw['grams']);
  final ml = _num(raw['ml']);
  OcrIngredient base;
  if (g != null && g > 0) {
    base = OcrIngredient(
      name: name,
      amount: g,
      unit: AmountUnit.grams,
      rawUnit: 'g',
    );
  } else if (ml != null && ml > 0) {
    base = OcrIngredient(
      name: name,
      amount: ml,
      unit: AmountUnit.milliliters,
      rawUnit: 'ml',
    );
  } else {
    final amount = _num(raw['amount']) ?? 1;
    final unit = raw['unit']?.toString().trim() ?? '';
    base =
        parseIngredientLines([
          '$name $amount ${unit.isEmpty ? 'x' : unit}',
        ]).firstOrNull ??
        OcrIngredient(name: name, amount: amount, unit: null, rawUnit: 'x');
  }

  final kcal = _num(raw['kcal']);
  if (kcal == null) return base;
  return OcrIngredient(
    name: base.name,
    amount: base.amount,
    unit: base.unit,
    rawUnit: base.rawUnit,
    estimate: Nutrition(
      kcal: kcal,
      protein: _num(raw['protein']) ?? 0,
      carb: _num(raw['carbs'] ?? raw['carb']) ?? 0,
      fat: _num(raw['fat']) ?? 0,
      micros: {
        for (final (key, metric) in const [
          ('fiber', TargetMetric.fiber),
          ('satFat', TargetMetric.satFat),
          ('sugar', TargetMetric.sugar),
          ('salt', TargetMetric.salt),
        ])
          metric.name: ?_num(raw[key]),
      },
    ),
  );
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
