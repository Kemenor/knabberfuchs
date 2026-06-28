import 'package:flutter/material.dart';
import 'package:fuchsbau/fuchsbau.dart';

/// App theme — delegates to the shared **fuchsbau** design system (the pinned
/// tangerine triad, replacing the old accidental-green M3 seed). knabberfuchs's
/// own component tweaks layer on top here; record any deviation in
/// `DESIGN_SYSTEM.md` with a pointer back to fuchsbau.
ThemeData buildTheme(
  Brightness brightness, {
  FuchsbauFont font = FuchsbauFont.figtree,
}) {
  final base = fuchsbauTheme(brightness, font: font);
  final scheme = base.colorScheme;
  // knabberfuchs deviation (see DESIGN_SYSTEM.md): the action FAB is emerald —
  // a positive, distinct CTA against the tangerine surface — the deep,
  // saturated tertiary. The fuchsbau package keeps the family default
  // (FAB = primary); this colour application is app-level, not family-level.
  return base.copyWith(
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: scheme.tertiary,
      foregroundColor: scheme.onTertiary,
    ),
  );
}
