/// Compact number formatting for the UI.
String kcalStr(double v) => v.round().toString();

String gramsStr(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

String macroStr(double v) => v.toStringAsFixed(1);
