import '../l10n/app_localizations.dart';

/// Localized word for a curated natural-portion unit key (see tool/portions/),
/// or null if [key] isn't one of our known units — e.g. an Open Food Facts
/// `serving_size` string like "30 g", which the caller should render as a
/// plain "1 serving" instead.
String? portionUnitLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'piece':
      return l10n.portionUnitPiece;
    case 'small':
      return l10n.portionUnitSmall;
    case 'medium':
      return l10n.portionUnitMedium;
    case 'large':
      return l10n.portionUnitLarge;
    case 'slice':
      return l10n.portionUnitSlice;
    case 'clove':
      return l10n.portionUnitClove;
    case 'stalk':
      return l10n.portionUnitStalk;
    case 'handful':
      return l10n.portionUnitHandful;
    case 'cob':
      return l10n.portionUnitCob;
    default:
      return null;
  }
}
