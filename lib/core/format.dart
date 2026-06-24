import 'package:intl/intl.dart';

/// Active locale for number *display*, set from the app when the UI locale
/// resolves (see [setNumberLocale]). Kept separate from the global
/// `Intl.defaultLocale` so it never perturbs date formatting.
String? _numLocale;

/// Point the display formatters at the active UI locale ('de'/'fr'/'it'/'en').
void setNumberLocale(String? languageCode) => _numLocale = languageCode;

// ---------------- Display (locale-aware) ----------------
// de/fr/it render a decimal comma ("1,5"); kcal totals get thousands grouping.

/// Rounded calories, with locale thousands grouping ("2.000" / "2 000").
String kcalStr(double v) => (NumberFormat.decimalPattern(
  _numLocale,
)..maximumFractionDigits = 0).format(v.round());

/// Grams: whole numbers as-is, otherwise one decimal. No grouping — this also
/// pre-fills editable fields, and the input parsers don't strip group separators.
String gramsStr(double v) =>
    (NumberFormat.decimalPattern(_numLocale)
          ..maximumFractionDigits = 1
          ..turnOffGrouping())
        .format(v);

/// Macros: always one decimal ("1,5" / "10,0"). No grouping (see [gramsStr]).
String macroStr(double v) =>
    (NumberFormat.decimalPattern(_numLocale)
          ..minimumFractionDigits = 1
          ..maximumFractionDigits = 1
          ..turnOffGrouping())
        .format(v);

// ---------------- Serialization (locale-independent) ----------------
// Period decimal, no grouping — safe for CSV columns and other machine output.

String kcalCsv(double v) => v.round().toString();
String gramsCsv(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
String macroCsv(double v) => v.toStringAsFixed(1);
