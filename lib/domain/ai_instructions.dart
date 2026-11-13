import 'day_summary.dart';

/// What the copied instructions set the user's own AI app up to do.
enum AiTask { logMeal, adaptRecipe }

/// Language names for the "talk to me in …" line, by app locale code.
const _languages = {
  'en': 'English',
  'de': 'German',
  'fr': 'French',
  'it': 'Italian',
};

String _n(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

String _range(CalorieTarget t, String unit) => switch ((t.min, t.max)) {
  (final lo?, final hi?) => '${_n(lo)}–${_n(hi)} $unit',
  (final lo?, null) => 'at least ${_n(lo)} $unit',
  (null, final hi?) => 'at most ${_n(hi)} $unit',
  _ => '',
};

const _metricWords = {
  TargetMetric.protein: 'protein',
  TargetMetric.carb: 'carbs',
  TargetMetric.fat: 'fat',
  TargetMetric.fiber: 'fiber',
  TargetMetric.satFat: 'saturated fat',
  TargetMetric.sugar: 'sugar',
  TargetMetric.salt: 'salt',
};

/// The JSON keys the importer reads for each micro (ai_block.dart).
const _microKeys = {
  TargetMetric.fiber: 'fiber',
  TargetMetric.satFat: 'satFat',
  TargetMetric.sugar: 'sugar',
  TargetMetric.salt: 'salt',
};

/// "My daily targets: 1800–2200 kcal, protein at least 120 g." — or null
/// when nothing is set.
String? _targetsLine(
  CalorieTarget kcal,
  Map<TargetMetric, CalorieTarget> nutrients,
  Set<TargetMetric> tracked,
) {
  final parts = [
    if (!kcal.isEmpty) _range(kcal, 'kcal'),
    for (final m in TargetMetric.values)
      if (m != TargetMetric.kcal &&
          tracked.contains(m) &&
          !(nutrients[m]?.isEmpty ?? true))
        '${_metricWords[m]} ${_range(nutrients[m]!, 'g')}',
  ];
  return parts.isEmpty ? null : 'My daily targets: ${parts.join(', ')}.';
}

/// The instructions the user pastes once into their AI app (a Claude
/// Project, ChatGPT custom instructions, a Gem). Written in English — they
/// are for the AI, and English gives the most reliable structured output —
/// with a line asking it to talk to the user in the app's [language].
/// Fills in the user's targets and the nutrients they track.
String buildAiInstructions(
  AiTask task, {
  required String language,
  CalorieTarget kcal = const CalorieTarget(null, null),
  Map<TargetMetric, CalorieTarget> nutrients = const {},
  Set<TargetMetric> tracked = const {},
}) {
  final lang = _languages[language] ?? 'English';
  final targets = _targetsLine(kcal, nutrients, tracked);
  final micros = [
    for (final m in _microKeys.keys)
      if (tracked.contains(m)) '"${_microKeys[m]}"',
  ];
  final b = StringBuffer();
  switch (task) {
    case AiTask.logMeal:
      b
        ..writeln(
          'You help me log food in my calorie tracker app, Knabberfuchs. '
          'Talk to me in $lang.',
        )
        ..writeln()
        ..writeln(
          'When I describe a meal or send a photo of one, estimate each '
          'component separately and answer with one JSON block in exactly '
          'this shape:',
        )
        ..writeln()
        ..writeln('```json')
        ..writeln(
          '{"knabberfuchs": 1, "kind": "meal", "name": "Short meal name", '
          '"meal": "lunch",',
        )
        ..writeln(' "items": [')
        ..writeln(
          '  {"name": "Chicken breast, grilled", "g": 150, "kcal": 248, '
          '"protein": 46, "carbs": 0, "fat": 5.4}',
        )
        ..writeln(' ]}')
        ..writeln('```')
        ..writeln()
        ..writeln('Rules:')
        ..writeln(
          '- One item per food. "g" (or "ml" for drinks) is the portion you '
          'estimate; "kcal", "protein", "carbs" and "fat" are totals for that '
          'portion, not per 100 g.',
        );
      if (micros.isNotEmpty) {
        b.writeln('- Also give ${micros.join(', ')} in grams for each item.');
      }
      b
        ..writeln(
          '- "meal" is breakfast, lunch, dinner or snack — leave it out if '
          'unclear. Add "date": "YYYY-MM-DD" only if I say it was another day.',
        )
        ..writeln(
          '- Write the food names in $lang, plain and searchable. If you are '
          'unsure about a portion, say so in one short sentence outside the '
          'block.',
        );
    case AiTask.adaptRecipe:
      b
        ..writeln(
          'You help me adapt recipes for my calorie tracker app, Knabberfuchs. '
          'Talk to me in $lang.',
        )
        ..writeln()
        ..writeln(
          'When I give you a recipe and a calorie goal, change the amounts or '
          'swap ingredients so one serving fits, keep it cookable, and say in '
          'a few words what you changed. Then give the ingredient list as one '
          'JSON block in exactly this shape:',
        )
        ..writeln()
        ..writeln('```json')
        ..writeln(
          '{"knabberfuchs": 1, "kind": "recipe", "name": "Chili con carne", '
          '"servings": 4,',
        )
        ..writeln(' "items": [')
        ..writeln('  {"name": "Beef mince, lean", "g": 500},')
        ..writeln('  {"name": "Olive oil", "amount": 1, "unit": "tbsp"}')
        ..writeln(' ]}')
        ..writeln('```')
        ..writeln()
        ..writeln('Rules:')
        ..writeln(
          '- Amounts are for the whole recipe; "servings" is how many '
          'portions it makes.',
        )
        ..writeln(
          '- Use "g" (or "ml") wherever you can; otherwise "amount" + "unit" '
          '(tbsp, tsp, cup, piece, slice, clove, pinch, can).',
        )
        ..writeln(
          '- Leave out nutrition values: my app matches every ingredient to '
          'its own food database. Write the names in $lang, plain and '
          'searchable.',
        );
  }
  if (targets != null) b.writeln('- $targets');
  return b.toString().trimRight();
}

/// One day's totals, as the summary reads them.
typedef DayTotals = ({
  String day,
  double kcal,
  double protein,
  double carb,
  double fat,
  double fiber,
  double satFat,
  double sugar,
  double salt,
});

double _metric(DayTotals d, TargetMetric m) => switch (m) {
  TargetMetric.kcal => d.kcal,
  TargetMetric.protein => d.protein,
  TargetMetric.carb => d.carb,
  TargetMetric.fat => d.fat,
  TargetMetric.fiber => d.fiber,
  TargetMetric.satFat => d.satFat,
  TargetMetric.sugar => d.sugar,
  TargetMetric.salt => d.salt,
};

/// The "Share a summary" text: [days] (oldest first, every day in the range,
/// `null` totals for days with nothing logged) as a compact table with the
/// targets and the averages over logged days — for the user's AI app to
/// analyse. English for the same reason as the instructions; numbers are
/// what matter.
String buildShareSummary({
  required List<String> days,
  required Map<String, DayTotals> totals,
  CalorieTarget kcal = const CalorieTarget(null, null),
  Map<TargetMetric, CalorieTarget> nutrients = const {},
  Set<TargetMetric> tracked = const {},
}) {
  final metrics = [
    TargetMetric.kcal,
    for (final m in TargetMetric.values)
      if (m != TargetMetric.kcal && tracked.contains(m)) m,
  ];
  String head(TargetMetric m) =>
      m == TargetMetric.kcal ? 'kcal' : '${_metricWords[m]} (g)';
  final b = StringBuffer()
    ..writeln(
      'Knabberfuchs — my food log, ${days.length} days '
      '(${days.first} to ${days.last})',
    );
  final targets = _targetsLine(kcal, nutrients, tracked);
  if (targets != null) b.writeln(targets);
  b
    ..writeln()
    ..writeln(['day', ...metrics.map(head)].join(' | '));
  final logged = <DayTotals>[];
  for (final day in days) {
    final t = totals[day];
    if (t == null) {
      b.writeln('$day | nothing logged');
      continue;
    }
    logged.add(t);
    b.writeln(
      [
        day,
        for (final m in metrics) _n(_metric(t, m).roundToDouble()),
      ].join(' | '),
    );
  }
  if (logged.isNotEmpty) {
    String avg(TargetMetric m) => _n(
      (logged.map((t) => _metric(t, m)).reduce((a, b) => a + b) / logged.length)
          .roundToDouble(),
    );
    b
      ..writeln()
      ..writeln(
        'Average over ${logged.length} logged '
        '${logged.length == 1 ? 'day' : 'days'}: '
        '${metrics.map((m) => '${avg(m)} ${m == TargetMetric.kcal ? 'kcal' : 'g ${_metricWords[m]}'}').join(', ')}',
      );
  }
  return b.toString().trimRight();
}
