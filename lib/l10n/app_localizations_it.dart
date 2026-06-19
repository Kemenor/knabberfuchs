// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Knabberfuchs';

  @override
  String get navDay => 'Giorno';

  @override
  String get navRecipes => 'Ricette';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionImport => 'Importa';

  @override
  String get settingsSectionLanguage => 'Lingua';

  @override
  String get settingsLanguage => 'Lingua dell’app';

  @override
  String get languageSystem => 'Predefinito di sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get dayPreviousDay => 'Previous day';

  @override
  String get dayNextDay => 'Next day';

  @override
  String get dayAddFood => 'Add food';

  @override
  String get dayMealFromList => 'Meal from an ingredient list';

  @override
  String get dayEmptyHint =>
      'Tap + to start a meal.\nEverything you add flows into it until you tap ✓ (or 15 min pass).';

  @override
  String get unitKcal => 'kcal';

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroFat => 'Fat';

  @override
  String targetOver(String kcal) {
    return '$kcal over';
  }

  @override
  String targetToGo(String kcal) {
    return '$kcal to go';
  }

  @override
  String targetLeft(String kcal) {
    return '$kcal left';
  }

  @override
  String get targetMinReached => 'minimum reached';

  @override
  String targetRangeBoth(String min, String max) {
    return 'Target $min–$max kcal';
  }

  @override
  String targetRangeMax(String max) {
    return 'Target $max kcal';
  }

  @override
  String targetRangeMin(String min) {
    return 'Minimum $min kcal';
  }

  @override
  String get mealMenuEdit => 'Edit meal';

  @override
  String get mealMenuSplit => 'Split across days';

  @override
  String get mealMenuSaveRecipe => 'Save as recipe';

  @override
  String get mealMenuDelete => 'Delete meal';

  @override
  String get mealFinish => 'Finish meal';

  @override
  String get mealAddTo => 'Add to this meal';

  @override
  String mealSavedToRecipes(String name) {
    return 'Saved \"$name\" to recipes';
  }

  @override
  String get editMealTitle => 'Edit meal';

  @override
  String get editMealName => 'Name';

  @override
  String get editMealType => 'Meal type';

  @override
  String get editMealWhen => 'When';
}
