import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/status_color.dart';
import '../../domain/day_summary.dart' show TargetStatus;
import '../../domain/weight.dart';
import '../../l10n/app_localizations.dart';

/// "kg" / "lb".
String weightUnitLabel(AppLocalizations l10n, WeightUnit u) =>
    u == WeightUnit.kg ? l10n.unitKg : l10n.unitLb;

/// The number alone in the display unit, one decimal ("87,4").
String weightNumber(double kg, WeightUnit u) => macroStr(u.fromKg(kg));

/// "87.4 kg" / "192.7 lb".
String weightText(AppLocalizations l10n, double kg, WeightUnit u) =>
    l10n.weightValue(weightNumber(kg, u), weightUnitLabel(l10n, u));

/// A change with its sign and unit: "−0.5 kg", "+0.3 lb", "±0.0 kg".
String weightChangeText(AppLocalizations l10n, double deltaKg, WeightUnit u) {
  final v = u.fromKg(deltaKg);
  final rounded = double.parse(v.toStringAsFixed(1));
  final sign = rounded > 0
      ? '+'
      : rounded < 0
      ? '−'
      : '±';
  return l10n.weightValue(
    '$sign${macroStr(rounded.abs())}',
    weightUnitLabel(l10n, u),
  );
}

/// Colour for a change: emerald toward the goal, amber away from it, none
/// (default text colour) without a goal. Never red.
Color? towardColor(BuildContext context, bool? toward) => switch (toward) {
  true => statusTextColor(context, TargetStatus.inRange),
  false => statusTextColor(context, TargetStatus.over),
  null => null,
};
