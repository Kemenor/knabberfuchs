import 'package:flutter/material.dart';

import '../domain/day_summary.dart';

/// Canonical color for a calorie [TargetStatus]: over = error, under = tertiary,
/// in-range = primary, none = muted. Single source shared by the day screen and
/// the trends charts (see DESIGN_SYSTEM.md — status colors).
Color statusColor(ColorScheme scheme, TargetStatus status) => switch (status) {
  TargetStatus.over => scheme.error,
  TargetStatus.under => scheme.tertiary,
  TargetStatus.inRange => scheme.primary,
  TargetStatus.none => scheme.onSurfaceVariant,
};
