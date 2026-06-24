import 'package:flutter/widgets.dart';

import '../data/db/database.dart';

extension FoodLocalizedName on Food {
  /// Display name for the given UI [languageCode], falling back to the
  /// canonical English [name] when there's no localized override (e.g.
  /// single-language USDA/OFF/custom rows, or Italian until it's translated).
  String localizedName(String? languageCode) => switch (languageCode) {
    'de' => nameDe ?? name,
    'fr' => nameFr ?? name,
    'it' => nameIt ?? name,
    _ => name,
  };

  /// Convenience: resolve against the active UI locale from [context].
  String localizedNameOf(BuildContext context) =>
      localizedName(Localizations.localeOf(context).languageCode);
}
