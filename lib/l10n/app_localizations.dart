import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
  ];

  /// Application name (brand; usually not translated)
  ///
  /// In en, this message translates to:
  /// **'Knabberfuchs'**
  String get appTitle;

  /// Bottom navigation: the daily diary tab
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get navDay;

  /// Bottom navigation: the recipes tab
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get navRecipes;

  /// Bottom navigation: the settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Bottom navigation: the trends/charts tab
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get navTrends;

  /// Settings section header for display options
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplay;

  /// Settings section header: theme, typeface and language
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Settings section header for tracking options like the Trends tab
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get settingsTracking;

  /// Settings toggle title that shows/hides the Trends tab
  ///
  /// In en, this message translates to:
  /// **'Show Trends tab'**
  String get settingsShowTrends;

  /// Subtitle under the Show Trends toggle
  ///
  /// In en, this message translates to:
  /// **'Add a tab with weekly and monthly calorie charts'**
  String get settingsShowTrendsSub;

  /// Trends period chip: weekly view
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get trendsWeek;

  /// Trends period chip: monthly view
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get trendsMonth;

  /// Trends period chip: custom date range (keep short)
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get trendsCustom;

  /// Trends chart title for the weekly-average view
  ///
  /// In en, this message translates to:
  /// **'Weekly average'**
  String get trendsWeeklyAvg;

  /// Trends chart title for the monthly-average view
  ///
  /// In en, this message translates to:
  /// **'Monthly average'**
  String get trendsMonthlyAvg;

  /// Trends stat label: average calories per day in the period
  ///
  /// In en, this message translates to:
  /// **'Average / day'**
  String get trendsAvgPerDay;

  /// Trends stat label: how many days stayed within the calorie target
  ///
  /// In en, this message translates to:
  /// **'Days in target'**
  String get trendsDaysInTarget;

  /// Empty state on the Trends screen
  ///
  /// In en, this message translates to:
  /// **'No entries yet for this range. Log some food to see your trends.'**
  String get trendsEmpty;

  /// Generic save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Generic delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Generic add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Confirm button of the import-backup dialog
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// Settings section header for the app language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// Settings row title for the light/dark theme picker
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme option: follow the system light/dark setting
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme option: always light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option: always dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Settings row title for the font picker
  ///
  /// In en, this message translates to:
  /// **'Typeface'**
  String get settingsTypeface;

  /// Typeface option: the standard app font
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get typefaceDefault;

  /// Typeface option: a high-legibility font for low vision
  ///
  /// In en, this message translates to:
  /// **'Low-vision legibility'**
  String get typefaceLowVision;

  /// Typeface option: a dyslexia-friendly font
  ///
  /// In en, this message translates to:
  /// **'Dyslexia'**
  String get typefaceDyslexia;

  /// Settings row title for choosing the UI language
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguage;

  /// Language option that follows the device locale
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// Language picker option; endonym, shown in its own language (do not translate)
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language picker option; endonym, shown in its own language (do not translate)
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// Language picker option; endonym, shown in its own language (do not translate)
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Language picker option; endonym, shown in its own language (do not translate)
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// Footnote under the language picker disclosing that non-English locales are machine translations
  ///
  /// In en, this message translates to:
  /// **'Languages other than English have been machine-translated and may read awkwardly.'**
  String get languageMachineNote;

  /// Relative date label for the current day
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// Relative date label for the previous day
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// Relative date label for the next day
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// Tooltip of the previous-day arrow on the Day screen
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get dayPreviousDay;

  /// Tooltip of the next-day arrow on the Day screen
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get dayNextDay;

  /// Main FAB label on the Day screen; also the title of the add-food screen and log sheet
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get dayAddFood;

  /// Menu entry: build a meal by photographing a printed ingredient list
  ///
  /// In en, this message translates to:
  /// **'Meal from an ingredient list'**
  String get dayMealFromList;

  /// Empty-state hint on the Day screen
  ///
  /// In en, this message translates to:
  /// **'Tap + to start a meal.\nEverything you add flows into it until you tap ✓ (or 15 min pass).'**
  String get dayEmptyHint;

  /// Kilocalorie unit symbol (usually not translated)
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// Teaspoon unit label on the amount field and unit chips (abbreviate if customary)
  ///
  /// In en, this message translates to:
  /// **'tsp'**
  String get unitTsp;

  /// Tablespoon unit label on the amount field and unit chips (abbreviate if customary)
  ///
  /// In en, this message translates to:
  /// **'tbsp'**
  String get unitTbsp;

  /// Cup volume-unit label on the amount field and unit chips
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get unitCup;

  /// Macronutrient label: protein
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// Macronutrient label: carbohydrates (keep short)
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get macroCarbs;

  /// Macronutrient label: fat
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get macroFat;

  /// Day header status: kcal above the maximum target
  ///
  /// In en, this message translates to:
  /// **'{kcal} over'**
  String targetOver(String kcal);

  /// Day header status: kcal still needed to reach the minimum target
  ///
  /// In en, this message translates to:
  /// **'{kcal} to go'**
  String targetToGo(String kcal);

  /// Day header status: kcal left until the maximum target
  ///
  /// In en, this message translates to:
  /// **'{kcal} left'**
  String targetLeft(String kcal);

  /// Day header status once the minimum-calorie target is met
  ///
  /// In en, this message translates to:
  /// **'minimum reached'**
  String get targetMinReached;

  /// Day header target line when both a minimum and a maximum are set
  ///
  /// In en, this message translates to:
  /// **'Target {min}–{max} kcal'**
  String targetRangeBoth(String min, String max);

  /// Day header target line when only a maximum is set
  ///
  /// In en, this message translates to:
  /// **'Target {max} kcal'**
  String targetRangeMax(String max);

  /// Day header target line when only a minimum is set
  ///
  /// In en, this message translates to:
  /// **'Minimum {min} kcal'**
  String targetRangeMin(String min);

  /// Meal overflow menu: edit the meal's name, type and time
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get mealMenuEdit;

  /// Meal overflow menu: split the meal into portions over several days
  ///
  /// In en, this message translates to:
  /// **'Split across days'**
  String get mealMenuSplit;

  /// Meal overflow menu: move this meal's entries into another meal of the day
  ///
  /// In en, this message translates to:
  /// **'Merge into another meal'**
  String get mealMenuMerge;

  /// Meal overflow menu: scale all amounts by a percentage
  ///
  /// In en, this message translates to:
  /// **'Scale meal'**
  String get mealMenuScale;

  /// Confirm button in the scale-meal sheet
  ///
  /// In en, this message translates to:
  /// **'Scale to {pct}%'**
  String scaleMealApply(String pct);

  /// Snackbar after a meal was scaled
  ///
  /// In en, this message translates to:
  /// **'Meal scaled to {pct}%'**
  String scaleMealDone(String pct);

  /// Meal overflow menu: save the meal as a recipe
  ///
  /// In en, this message translates to:
  /// **'Save as recipe'**
  String get mealMenuSaveRecipe;

  /// Meal overflow menu: delete the meal and its entries
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get mealMenuDelete;

  /// Confirmation dialog title before deleting a whole meal group
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String mealDeleteConfirm(String name);

  /// Meal overflow menu: open the read-only per-meal nutrition breakdown page
  ///
  /// In en, this message translates to:
  /// **'Meal details'**
  String get mealMenuDetails;

  /// Settings toggle: add a compact tracked-nutrient subtotal line to every meal header on the Day screen
  ///
  /// In en, this message translates to:
  /// **'Show nutrients per meal'**
  String get settingsShowMealNutrients;

  /// Subtitle under the Show nutrients per meal toggle
  ///
  /// In en, this message translates to:
  /// **'Adds your tracked nutrients to each meal header'**
  String get settingsShowMealNutrientsSub;

  /// Abbreviation for protein in compact nutrient lines (meal headers, ingredient rows)
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get metricShortProtein;

  /// Abbreviation for carbohydrates in compact nutrient lines
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get metricShortCarb;

  /// Abbreviation for fat in compact nutrient lines
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get metricShortFat;

  /// Abbreviation for fibre in compact nutrient lines
  ///
  /// In en, this message translates to:
  /// **'Fib'**
  String get metricShortFiber;

  /// Abbreviation for saturated fat in compact nutrient lines
  ///
  /// In en, this message translates to:
  /// **'SatF'**
  String get metricShortSatFat;

  /// Abbreviation for sugar in compact nutrient lines
  ///
  /// In en, this message translates to:
  /// **'Sug'**
  String get metricShortSugar;

  /// Abbreviation for salt in compact nutrient lines
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get metricShortSalt;

  /// Tooltip of the ✓ button that closes the currently running meal
  ///
  /// In en, this message translates to:
  /// **'Finish meal'**
  String get mealFinish;

  /// Tooltip of the + button that adds more food to an existing meal
  ///
  /// In en, this message translates to:
  /// **'Add to this meal'**
  String get mealAddTo;

  /// Tooltip to collapse an expanded meal card
  ///
  /// In en, this message translates to:
  /// **'Collapse meal'**
  String get mealCollapse;

  /// Tooltip to expand a collapsed meal card
  ///
  /// In en, this message translates to:
  /// **'Expand meal'**
  String get mealExpand;

  /// Snackbar after saving a meal as a recipe
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\" to recipes'**
  String mealSavedToRecipes(String name);

  /// Title of the edit-meal sheet
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get editMealTitle;

  /// Label of the meal-name field in the edit-meal sheet
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editMealName;

  /// Label above the meal-type chips (breakfast/lunch/…) in the edit-meal sheet
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get editMealType;

  /// Label above the date/time row in the edit-meal sheet
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get editMealWhen;

  /// Confirmation dialog title before deleting a recipe
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String recipeDeleteConfirm(String name);

  /// Title of the Recipes screen
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// Empty state on the Recipes screen
  ///
  /// In en, this message translates to:
  /// **'No recipes yet.\nCreate one to reuse meals, share them, or batch-cook and split across days.'**
  String get recipesEmpty;

  /// FAB label to create a new recipe
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get recipeNew;

  /// How many servings a recipe makes, shown on recipe cards; the count can be fractional
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} serving} other{{count} servings}}'**
  String recipeServings(num count);

  /// Snackbar after importing a shared recipe
  ///
  /// In en, this message translates to:
  /// **'Imported \"{name}\"'**
  String recipeImported(String name);

  /// Error when a scanned QR code or pasted text is not a valid recipe
  ///
  /// In en, this message translates to:
  /// **'That\'s not a valid recipe.'**
  String get qrNotRecipe;

  /// New-recipe sheet option: add ingredients one by one
  ///
  /// In en, this message translates to:
  /// **'Build manually'**
  String get createBuildManually;

  /// Subtitle under the build-manually option
  ///
  /// In en, this message translates to:
  /// **'Add ingredients one by one'**
  String get createBuildManuallySub;

  /// New-recipe sheet option: photograph a printed ingredient list
  ///
  /// In en, this message translates to:
  /// **'From an ingredient list'**
  String get createFromList;

  /// Subtitle under the from-an-ingredient-list option
  ///
  /// In en, this message translates to:
  /// **'Photograph a printed list — save it or log it as a meal'**
  String get createFromListSub;

  /// New-recipe sheet option: import a recipe shared as a QR code
  ///
  /// In en, this message translates to:
  /// **'Import from QR code'**
  String get createFromQr;

  /// Subtitle under the import-from-QR option
  ///
  /// In en, this message translates to:
  /// **'Scan a shared recipe'**
  String get createFromQrSub;

  /// Generic error message with the underlying error appended
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(String error);

  /// Shown when launching an external URL or app fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link'**
  String get couldNotOpenLink;

  /// Settings tile title that opens the Targets screen
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get settingsTargets;

  /// Subtitle on the Settings tile that opens the Targets screen
  ///
  /// In en, this message translates to:
  /// **'Calorie and macro goals, per day'**
  String get settingsTargetsSub;

  /// Label for the calories metric in the Targets screen header
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get metricCalories;

  /// Standalone label for the fiber metric (targets, day card, trends chips)
  ///
  /// In en, this message translates to:
  /// **'Fibre'**
  String get metricFiber;

  /// Standalone SHORT label for the saturated-fat metric (targets, day card, trends chips)
  ///
  /// In en, this message translates to:
  /// **'Sat. fat'**
  String get metricSatFat;

  /// Standalone label for the sugar metric (targets, day card, trends chips)
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get metricSugar;

  /// Standalone label for the salt metric (targets, day card, trends chips)
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get metricSalt;

  /// Header above the nutrient toggle chips on the Targets screen
  ///
  /// In en, this message translates to:
  /// **'Tracked nutrients'**
  String get settingsTrackedNutrients;

  /// Explainer under the tracked-nutrients header
  ///
  /// In en, this message translates to:
  /// **'Choose what gets a target and shows on the Day card and Trends. Calories are always on; switching one off keeps its values.'**
  String get settingsTrackedNutrientsSub;

  /// Explainer text at the top of the Targets screen
  ///
  /// In en, this message translates to:
  /// **'Set a minimum, a maximum, or both. A minimum helps if you need to make sure you eat enough. Leave blank to use the default.'**
  String get settingsTargetsHelp;

  /// Label of the default (non-customized) daily target row
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsTargetDefault;

  /// Hint in the minimum-calories target field
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get settingsTargetMin;

  /// Hint in the maximum-calories target field
  ///
  /// In en, this message translates to:
  /// **'max'**
  String get settingsTargetMax;

  /// Toggle title to set different targets per weekday
  ///
  /// In en, this message translates to:
  /// **'Customize per day'**
  String get settingsCustomizePerDay;

  /// Subtitle under the customize-per-day toggle
  ///
  /// In en, this message translates to:
  /// **'Training days and weekends can differ'**
  String get settingsCustomizePerDaySub;

  /// Settings section header for logging behavior
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get settingsLogging;

  /// Settings tile title for configuring the meal-time windows
  ///
  /// In en, this message translates to:
  /// **'Meal times'**
  String get settingsMealTimes;

  /// Subtitle under the meal-times tile
  ///
  /// In en, this message translates to:
  /// **'Names each meal by the time you log it'**
  String get settingsMealTimesSub;

  /// Explainer text on the meal-times settings screen
  ///
  /// In en, this message translates to:
  /// **'A new meal is named after the window its first item falls in (e.g. \"Breakfast 08:23\"). Anything outside these windows is a snack. You can always rename a meal.'**
  String get settingsMealTimesHelp;

  /// Settings section header for food-database options
  ///
  /// In en, this message translates to:
  /// **'Food data'**
  String get settingsFoodData;

  /// Settings tile title that opens the offline-regions screen
  ///
  /// In en, this message translates to:
  /// **'Offline regions'**
  String get settingsOfflineRegions;

  /// Subtitle under the offline-regions tile
  ///
  /// In en, this message translates to:
  /// **'Download country product databases for offline search'**
  String get settingsOfflineRegionsSub;

  /// Settings picker title: when installed offline region packs update themselves
  ///
  /// In en, this message translates to:
  /// **'Auto-update offline regions'**
  String get settingsPackAutoUpdate;

  /// Auto-update option: only on Wi-Fi (default)
  ///
  /// In en, this message translates to:
  /// **'On Wi-Fi only'**
  String get packAutoUpdateWifi;

  /// Auto-update option: on Wi-Fi and mobile data
  ///
  /// In en, this message translates to:
  /// **'On Wi-Fi and mobile data'**
  String get packAutoUpdateAny;

  /// Auto-update option: never
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get packAutoUpdateOff;

  /// Footnote under the auto-update picker
  ///
  /// In en, this message translates to:
  /// **'Checks for newer product data at most once a day, when you open the app.'**
  String get packAutoUpdateFootnote;

  /// Settings section header: just the platform health store's name (e.g. Health Connect)
  ///
  /// In en, this message translates to:
  /// **'{store}'**
  String settingsHealthConnect(String store);

  /// Toggle title to sync logged nutrition to the platform health store
  ///
  /// In en, this message translates to:
  /// **'Sync to {store}'**
  String settingsHealthSync(String store);

  /// Subtitle under the health-sync toggle
  ///
  /// In en, this message translates to:
  /// **'Write logged calories & macros to {store}'**
  String settingsHealthSyncSub(String store);

  /// Info row title: entries sync with their logged timestamp
  ///
  /// In en, this message translates to:
  /// **'Entries sync at the time you logged them'**
  String get settingsHealthTimeNote;

  /// Subtitle explaining how to change a synced entry's time
  ///
  /// In en, this message translates to:
  /// **'Back-date a meal from its ⋮ menu to change its time.'**
  String get settingsHealthTimeNoteSub;

  /// Settings section header for backup and restore
  ///
  /// In en, this message translates to:
  /// **'Data & backup'**
  String get settingsDataBackup;

  /// Settings tile title to export a backup
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExport;

  /// Subtitle under the export-backup tile
  ///
  /// In en, this message translates to:
  /// **'Share a .zip (JSON + CSV)'**
  String get settingsExportSub;

  /// Settings tile title to import a backup
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get settingsImport;

  /// Subtitle under the import-backup tile
  ///
  /// In en, this message translates to:
  /// **'Restore from a .zip (replaces all data)'**
  String get settingsImportSub;

  /// Settings section header for the about block
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Settings tile title to email the developer
  ///
  /// In en, this message translates to:
  /// **'Contact the developer'**
  String get settingsContactDev;

  /// Subtitle under the contact-the-developer tile
  ///
  /// In en, this message translates to:
  /// **'Email feedback or a bug report (adds app & device info)'**
  String get settingsContactDevSub;

  /// Snackbar when no email app is installed
  ///
  /// In en, this message translates to:
  /// **'No email app found. Write to {email}'**
  String settingsContactDevNoApp(String email);

  /// About text with data-source and license attributions
  ///
  /// In en, this message translates to:
  /// **'Ad-free, no subscriptions. Food data from Open Food Facts (© Open Food Facts contributors, ODbL) and the Swiss Food Composition Database (Federal Food Safety and Veterinary Office, FSVO). Portion sizes informed by USDA FoodData Central (public domain). On-device photo recognition uses Google\'s AIY food_V1 model (Apache 2.0). Tap “View licenses” for open-source components.'**
  String get settingsAboutBody;

  /// Title of the Open Food Facts thank-you card in Settings
  ///
  /// In en, this message translates to:
  /// **'Thanks to Open Food Facts'**
  String get offThanksTitle;

  /// Body of the Open Food Facts thank-you card
  ///
  /// In en, this message translates to:
  /// **'Knabberfuchs is built on Open Food Facts — a free, open, crowdsourced food database kept alive by volunteers around the world. Without their work, this app simply would not exist.\n\nIf Knabberfuchs is useful to you, please consider supporting them.'**
  String get offThanksBody;

  /// Button that opens the Open Food Facts donation page
  ///
  /// In en, this message translates to:
  /// **'Donate to Open Food Facts'**
  String get offDonate;

  /// Snackbar when health sync is turned off
  ///
  /// In en, this message translates to:
  /// **'{store} sync turned off.'**
  String healthSyncOff(String store);

  /// Snackbar when the platform health store is missing on this device
  ///
  /// In en, this message translates to:
  /// **'{store} is not available on this device.'**
  String healthUnavailable(String store);

  /// Snackbar when the health-store permission was denied
  ///
  /// In en, this message translates to:
  /// **'{store} permission was not granted.'**
  String healthNoPermission(String store);

  /// Snackbar when health sync was enabled and today's entries were pushed
  ///
  /// In en, this message translates to:
  /// **'{store} sync on — today pushed.'**
  String healthSyncOn(String store);

  /// Settings row: wipe and re-push everything to the health store
  ///
  /// In en, this message translates to:
  /// **'Resync all days'**
  String get settingsHealthResync;

  /// Subtitle of the resync-all settings row
  ///
  /// In en, this message translates to:
  /// **'Clear this app\'s data in {store}, then write the whole diary again'**
  String settingsHealthResyncSub(String store);

  /// Snackbar after a full health resync finished
  ///
  /// In en, this message translates to:
  /// **'Resynced to {store}.'**
  String healthResyncDone(String store);

  /// Settings switch: read active energy and shift the daily kcal target by it
  ///
  /// In en, this message translates to:
  /// **'Adjust budget by activity'**
  String get settingsHealthEnergyRead;

  /// Subtitle of the activity-adjustment switch
  ///
  /// In en, this message translates to:
  /// **'Add your active burn from {store} to the daily calorie target'**
  String settingsHealthEnergyReadSub(String store);

  /// Snackbar after enabling the activity budget adjustment
  ///
  /// In en, this message translates to:
  /// **'Activity adjustment on.'**
  String get healthEnergyReadOn;

  /// Day-card line explaining the target shift by burned energy
  ///
  /// In en, this message translates to:
  /// **'+{kcal} kcal from activity'**
  String activityBonus(String kcal);

  /// Muted note on the Trends tab when the activity adjustment is enabled
  ///
  /// In en, this message translates to:
  /// **'Target band doesn\'t include activity adjustments.'**
  String get trendsActivityNote;

  /// Snackbar when exporting a backup fails
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String backupExportFailed(String error);

  /// Snackbar after the backup zip was saved via the system save dialog; size is human-readable like '1.2 MB'
  ///
  /// In en, this message translates to:
  /// **'Backup saved ({size}).'**
  String backupSaved(String size);

  /// Confirmation dialog title before importing a backup
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get backupReplaceTitle;

  /// Confirmation dialog body warning that importing replaces all data
  ///
  /// In en, this message translates to:
  /// **'Importing will replace your current entries, custom foods, recipes, targets, and settings with the backup contents.'**
  String get backupReplaceBody;

  /// Snackbar after a backup was restored
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get backupRestored;

  /// Snackbar when importing a backup fails
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String backupImportFailed(String error);

  /// Snackbar when the backup file's schema version is newer than this app supports
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer app version. Update the app, then try importing again.'**
  String get backupImportNewerVersion;

  /// Label of the amount input in the log-food sheet; also the sheet title when only picking an amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// Title of the edit-diary-entry sheet
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntryTitle;

  /// Calorie-density line in the log-food sheet
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal / 100 g'**
  String kcalPer100(String kcal);

  /// Grams estimate under the unit chips when the food's density is unknown
  ///
  /// In en, this message translates to:
  /// **'≈ {grams} g (assumes ~1 g/ml)'**
  String volumeApprox(String grams);

  /// Grams estimate under the unit chips using the food's known density
  ///
  /// In en, this message translates to:
  /// **'≈ {grams} g · {density} g/ml'**
  String volumeDensity(String grams, String density);

  /// Quick-pick chip for one serving when only a serving weight is known
  ///
  /// In en, this message translates to:
  /// **'1 serving ({grams} g)'**
  String oneServing(String grams);

  /// Quick-pick chip for one natural portion, e.g. '1 medium · 300 g'
  ///
  /// In en, this message translates to:
  /// **'1 {unit} · {grams} g'**
  String portionChip(String unit, String grams);

  /// Natural-portion unit: one piece of a food
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get portionUnitPiece;

  /// Natural-portion size: a small specimen (e.g. '1 small · 90 g')
  ///
  /// In en, this message translates to:
  /// **'small'**
  String get portionUnitSmall;

  /// Natural-portion size: a medium specimen (e.g. '1 medium · 120 g')
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get portionUnitMedium;

  /// Natural-portion size: a large specimen (e.g. '1 large · 150 g')
  ///
  /// In en, this message translates to:
  /// **'large'**
  String get portionUnitLarge;

  /// Natural-portion unit: one slice (bread, cheese, …)
  ///
  /// In en, this message translates to:
  /// **'slice'**
  String get portionUnitSlice;

  /// Natural-portion unit: one clove (garlic)
  ///
  /// In en, this message translates to:
  /// **'clove'**
  String get portionUnitClove;

  /// Natural-portion unit: one stalk (celery, rhubarb, …)
  ///
  /// In en, this message translates to:
  /// **'stalk'**
  String get portionUnitStalk;

  /// Natural-portion unit: one handful (nuts, berries, …)
  ///
  /// In en, this message translates to:
  /// **'handful'**
  String get portionUnitHandful;

  /// Natural-portion unit: one cob (corn)
  ///
  /// In en, this message translates to:
  /// **'cob'**
  String get portionUnitCob;

  /// Placeholder in the food search field
  ///
  /// In en, this message translates to:
  /// **'Search foods…'**
  String get searchFoodsHint;

  /// Section header above recently logged foods in the search list
  ///
  /// In en, this message translates to:
  /// **'Recently used'**
  String get searchRecentlyUsed;

  /// List action that opens the custom-food form
  ///
  /// In en, this message translates to:
  /// **'Create custom food'**
  String get createCustomFood;

  /// Empty state of the food search screen
  ///
  /// In en, this message translates to:
  /// **'Search for a food, scan a barcode,\nor create your own.'**
  String get searchEmptyPrompt;

  /// Shown when a food search returns no results
  ///
  /// In en, this message translates to:
  /// **'No matches for \"{query}\".'**
  String searchNoMatches(String query);

  /// Two-line trailing text on food search rows: kcal per 100 g
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal\n/100 g'**
  String kcalPer100Short(String kcal);

  /// Food source badge: Open Food Facts (brand; do not translate)
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts'**
  String get sourceOff;

  /// Food source badge: USDA (brand; do not translate)
  ///
  /// In en, this message translates to:
  /// **'USDA'**
  String get sourceUsda;

  /// Food source badge: a food the user created
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get sourceCustom;

  /// Food source badge: the Swiss Food Composition Database (keep short)
  ///
  /// In en, this message translates to:
  /// **'Swiss DB'**
  String get sourceSwiss;

  /// Food source badge: a product the user submitted
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get sourceContributed;

  /// List action to log a food with just a name and calories
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// Quick-add list action including the search text as the name
  ///
  /// In en, this message translates to:
  /// **'Quick add \"{name}\"'**
  String quickAddNamed(String name);

  /// Subtitle under the quick-add action
  ///
  /// In en, this message translates to:
  /// **'Log just a name and calories'**
  String get quickAddSubtitle;

  /// Label of the name field in the quick-add sheet
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get quickAddName;

  /// Label of the calories field in the quick-add sheet
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get quickAddCalories;

  /// Label of the optional weight field in the quick-add sheet
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get quickAddWeight;

  /// Expander that reveals the optional macro fields in the quick-add sheet
  ///
  /// In en, this message translates to:
  /// **'Add macros (optional)'**
  String get quickAddMacros;

  /// Image source option: take a photo with the camera
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get recognizeTakePhoto;

  /// Title of the new-food form
  ///
  /// In en, this message translates to:
  /// **'New food'**
  String get foodFormTitle;

  /// App-bar title of the food form when editing an existing custom food
  ///
  /// In en, this message translates to:
  /// **'Edit food'**
  String get foodFormEditTitle;

  /// Confirmation dialog title before deleting a custom food; logged history keeps its snapshots
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String foodDeleteConfirm(String name);

  /// Label of the optional barcode field in the food form
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get barcodeField;

  /// Settings section header for AI photo recognition
  ///
  /// In en, this message translates to:
  /// **'AI recognition'**
  String get settingsAi;

  /// Accessibility label of the previous-period arrow on the Trends screen
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get a11yPreviousPeriod;

  /// Accessibility label of the next-period arrow on the Trends screen
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get a11yNextPeriod;

  /// Accessibility label of the clear (×) button in the search field
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get a11yClearSearch;

  /// Accessibility label of the button that reveals the API key
  ///
  /// In en, this message translates to:
  /// **'Show key'**
  String get a11yShowApiKey;

  /// Accessibility label of the button that hides the API key
  ///
  /// In en, this message translates to:
  /// **'Hide key'**
  String get a11yHideApiKey;

  /// Accessibility label of the remove button on an ingredient row
  ///
  /// In en, this message translates to:
  /// **'Remove ingredient'**
  String get a11yRemoveIngredient;

  /// Accessibility label of a stepper's decrease (−) button
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get a11yDecrease;

  /// Accessibility label of a stepper's increase (+) button
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get a11yIncrease;

  /// Accessibility label of the busy spinner while a photo is analysed
  ///
  /// In en, this message translates to:
  /// **'Analysing…'**
  String get a11yAnalysing;

  /// Accessibility label of the date button on the Day screen
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get a11yChangeDate;

  /// Accessibility description of the chosen meal photo
  ///
  /// In en, this message translates to:
  /// **'Selected meal photo'**
  String get a11ySelectedPhoto;

  /// Accessibility label of the stored photo shown with a logged meal (quick add sheet, meal detail)
  ///
  /// In en, this message translates to:
  /// **'Meal photo'**
  String get a11yMealPhoto;

  /// Accessibility label of the tappable photo banner on the meal detail page
  ///
  /// In en, this message translates to:
  /// **'Meal photo. Tap to view full screen.'**
  String get a11yMealPhotoOpen;

  /// Accessibility description of the trends chart
  ///
  /// In en, this message translates to:
  /// **'Trend chart for the selected period'**
  String get a11yTrendsChart;

  /// Accessibility description of the recipe-share QR code
  ///
  /// In en, this message translates to:
  /// **'QR code for recipe {name}'**
  String a11yQrCode(String name);

  /// Dismiss action on the AI-problem dialog: skip the AI and enter the meal by hand
  ///
  /// In en, this message translates to:
  /// **'Continue manually'**
  String get actionContinueManually;

  /// FAB label that opens the barcode scanner
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// Title of the food-picker screen
  ///
  /// In en, this message translates to:
  /// **'Select food'**
  String get selectFood;

  /// Button label to add an ingredient to a recipe
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// Section header for a recipe's ingredient list
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// Generic edit action label/tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Generic share action label/tooltip
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// Confirm button in small set-a-value dialogs
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get actionSet;

  /// A calorie value with its unit
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String kcalValue(String kcal);

  /// A gram value with its unit
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String gramsValue(String grams);

  /// Ingredient row summary: grams and calories
  ///
  /// In en, this message translates to:
  /// **'{grams} g · {kcal} kcal'**
  String gramsKcal(String grams, String kcal);

  /// Total-calories line in the recipe editor
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal total'**
  String kcalTotal(String kcal);

  /// Snackbar after logging food to a day
  ///
  /// In en, this message translates to:
  /// **'Logged to {day}'**
  String loggedTo(String day);

  /// Title of the recipe editor when editing an existing recipe
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get recipeEdit;

  /// Validation message when saving a recipe without a name
  ///
  /// In en, this message translates to:
  /// **'Give the recipe a name.'**
  String get recipeNeedName;

  /// Validation message when saving a recipe without ingredients
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient.'**
  String get recipeNeedIngredient;

  /// Label of the recipe-name field
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get recipeName;

  /// Label of the servings field in the recipe editor
  ///
  /// In en, this message translates to:
  /// **'Servings (portions this makes)'**
  String get recipeServingsField;

  /// FAB on the recipe detail screen: log a portion to a diary day
  ///
  /// In en, this message translates to:
  /// **'Log portion to a day'**
  String get recipeLogPortion;

  /// Caption next to the whole-recipe calorie total
  ///
  /// In en, this message translates to:
  /// **'Whole recipe'**
  String get recipeWhole;

  /// Caption next to the per-serving calories; count is the servings the recipe makes
  ///
  /// In en, this message translates to:
  /// **'Per serving ({count})'**
  String recipePerServing(String count);

  /// Title of the log-a-portion sheet
  ///
  /// In en, this message translates to:
  /// **'Log a portion'**
  String get recipeLogPortionTitle;

  /// Label of the portions stepper in the log-portion and split sheets
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get recipePortions;

  /// Confirm button in the log-portion sheet, showing the target day
  ///
  /// In en, this message translates to:
  /// **'Log to {day}'**
  String recipeLogToDay(String day);

  /// Title of the recipe share screen
  ///
  /// In en, this message translates to:
  /// **'Share \"{name}\"'**
  String shareTitle(String name);

  /// Hint under the QR code on the share screen
  ///
  /// In en, this message translates to:
  /// **'Scan this in another phone’s \"Import from QR\".'**
  String get shareScanHint;

  /// Button to share the recipe QR code as an image
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareAsImage;

  /// New-recipe sheet option: paste a recipe code received as text
  ///
  /// In en, this message translates to:
  /// **'Paste a recipe or list'**
  String get createFromText;

  /// Subtitle under the import-from-text option
  ///
  /// In en, this message translates to:
  /// **'From your AI app, a website, or a recipe code'**
  String get createFromTextSub;

  /// Title of the paste-recipe dialog
  ///
  /// In en, this message translates to:
  /// **'Paste a recipe or list'**
  String get importTextTitle;

  /// Placeholder in the paste-recipe text field
  ///
  /// In en, this message translates to:
  /// **'An ingredient list, or a recipe code'**
  String get importTextHint;

  /// Button to share the recipe as encoded text
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get shareAsText;

  /// Summary line under the share QR code: ingredient count, servings, and encoded payload size
  ///
  /// In en, this message translates to:
  /// **'{ingredients, plural, one{{ingredients} ingredient} other{{ingredients} ingredients}} · {servings, plural, one{{servings} serving} other{{servings} servings}} · {bytes} bytes'**
  String shareMeta(int ingredients, num servings, String bytes);

  /// Share-sheet subject line for a shared recipe
  ///
  /// In en, this message translates to:
  /// **'Recipe: {name}'**
  String shareSubject(String name);

  /// Snackbar when OCR found no ingredients in the photos
  ///
  /// In en, this message translates to:
  /// **'No ingredients found in those images.'**
  String get ocrNoIngredients;

  /// Default name for a meal created from a photographed ingredient list
  ///
  /// In en, this message translates to:
  /// **'Meal from photo'**
  String get ocrDefaultMealName;

  /// Validation message: at least one OCR ingredient must be matched to a food
  ///
  /// In en, this message translates to:
  /// **'Match at least one ingredient first.'**
  String get ocrNeedMatch;

  /// Snackbar after saving the OCR meal as a recipe
  ///
  /// In en, this message translates to:
  /// **'Saved to recipes'**
  String get ocrSavedToRecipes;

  /// Title of the OCR review screen
  ///
  /// In en, this message translates to:
  /// **'Review meal'**
  String get ocrReviewTitle;

  /// Action on the OCR review screen: save the meal as a recipe
  ///
  /// In en, this message translates to:
  /// **'Save as recipe'**
  String get ocrSaveAsRecipe;

  /// Action on the OCR review screen: log the meal to a diary day
  ///
  /// In en, this message translates to:
  /// **'Log to day'**
  String get ocrLogToDay;

  /// Label of the meal-name field on the OCR review screen
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get ocrMealName;

  /// Progress line: how many OCR ingredients are matched to foods
  ///
  /// In en, this message translates to:
  /// **'{matched} / {total} matched'**
  String ocrMatched(String matched, String total);

  /// Hint explaining the swipe gestures on the OCR review list
  ///
  /// In en, this message translates to:
  /// **'Swipe → to pick a food, ← to remove.'**
  String get ocrSwipeHint;

  /// Subtitle of a matched OCR row: parsed amount and the matched food's name
  ///
  /// In en, this message translates to:
  /// **'{amount} · from \"{name}\"'**
  String ocrFromSource(String amount, String name);

  /// Subtitle of an unmatched OCR row prompting to pick a food
  ///
  /// In en, this message translates to:
  /// **'{amount} · swipe → to pick a food'**
  String ocrPickHintSub(String amount);

  /// Two-line trailing text on OCR review rows: calories and grams
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal\n{grams} g'**
  String kcalGrams(String kcal, String grams);

  /// Tiny button on an OCR row to type the grams directly (keep very short)
  ///
  /// In en, this message translates to:
  /// **'set g'**
  String get ocrSetGrams;

  /// Day capture menu: paste text from an AI app (ingredient list or meal)
  ///
  /// In en, this message translates to:
  /// **'Paste from your AI app'**
  String get capturePaste;

  /// Subtitle of the paste-from-AI option in the capture menu
  ///
  /// In en, this message translates to:
  /// **'An ingredient list or a meal — matched to your foods'**
  String get capturePasteSub;

  /// Snackbar when pasted/shared text contains no ingredient lines
  ///
  /// In en, this message translates to:
  /// **'No ingredients found in that text.'**
  String get pasteNothingFound;

  /// Default name of a meal imported from pasted/shared text without a heading
  ///
  /// In en, this message translates to:
  /// **'Imported meal'**
  String get importedMealName;

  /// Subtitle of a review row showing a best-guess food not yet confirmed: parsed amount and the original name
  ///
  /// In en, this message translates to:
  /// **'{amount} · suggested for \"{name}\"'**
  String ocrSuggestedFor(String amount, String name);

  /// Button on a review row to accept the suggested food (keep very short)
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get ocrUseSuggestion;

  /// Settings row and screen title: the keyless bridge to the user's own AI app
  ///
  /// In en, this message translates to:
  /// **'AI helper'**
  String get aiHelperTitle;

  /// Subtitle of the AI helper row in Settings
  ///
  /// In en, this message translates to:
  /// **'Use your own AI app — no key needed'**
  String get aiHelperSettingsSub;

  /// Intro paragraph of the AI helper screen
  ///
  /// In en, this message translates to:
  /// **'Knabberfuchs doesn\'t talk to any AI. Your own AI app — Claude, ChatGPT, Gemini … — does the thinking: give it these instructions once, then bring its answers back with Share → Knabberfuchs or \"Paste from your AI app\".'**
  String get aiHelperIntro;

  /// Section header on the AI helper screen
  ///
  /// In en, this message translates to:
  /// **'Instructions for your AI app'**
  String get aiInstructionsSection;

  /// AI helper: instruction preset for estimating and logging meals
  ///
  /// In en, this message translates to:
  /// **'Log what I ate'**
  String get aiTaskLogTitle;

  /// Subtitle of the log-a-meal preset
  ///
  /// In en, this message translates to:
  /// **'Describe a meal or send a photo — get back a block to log'**
  String get aiTaskLogSub;

  /// AI helper: instruction preset for adapting recipes to targets
  ///
  /// In en, this message translates to:
  /// **'Adapt a recipe'**
  String get aiTaskRecipeTitle;

  /// Subtitle of the adapt-a-recipe preset
  ///
  /// In en, this message translates to:
  /// **'Fit a recipe to your targets — get back its ingredient list'**
  String get aiTaskRecipeSub;

  /// Button copying an instruction preset (keep short)
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get aiCopy;

  /// Snackbar after copying instructions
  ///
  /// In en, this message translates to:
  /// **'Instructions copied — paste them into your AI app.'**
  String get aiCopied;

  /// Button in the paste dialog copying the AI instructions (keep short)
  ///
  /// In en, this message translates to:
  /// **'Copy the prompt'**
  String get aiCopyPrompt;

  /// Button label right after the prompt was copied (keep short)
  ///
  /// In en, this message translates to:
  /// **'Prompt copied'**
  String get aiPromptCopied;

  /// Placeholder of the paste field in the Day paste-from-AI dialog
  ///
  /// In en, this message translates to:
  /// **'The AI\'s answer lands here'**
  String get aiPasteHint;

  /// Two-step how-to in the Day paste-from-AI dialog
  ///
  /// In en, this message translates to:
  /// **'1. Copy the prompt and send it to your AI app with your meal — describe it or add a photo.\n2. Copy its answer and come back — it lands below. Tap Import.'**
  String get aiPasteStepsLog;

  /// Two-step how-to in the Recipes paste dialog
  ///
  /// In en, this message translates to:
  /// **'1. Copy the prompt and send it to your AI app with the recipe you want.\n2. Copy its answer and come back — it lands below. Tap Import. An ingredient list or a recipe code works too.'**
  String get aiPasteStepsRecipe;

  /// How-to note under the instruction presets
  ///
  /// In en, this message translates to:
  /// **'Paste them once into a Claude Project, ChatGPT\'s custom instructions or a Gem — they include your current targets. Copy them again after changing your targets.'**
  String get aiHowTo;

  /// Section header: share recent days as text for analysis
  ///
  /// In en, this message translates to:
  /// **'Share a summary'**
  String get aiSummarySection;

  /// Explanation under the share-summary header
  ///
  /// In en, this message translates to:
  /// **'Your last days as text — for your AI app to look for patterns.'**
  String get aiSummarySub;

  /// Button: share the last 7 days
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get aiSummary7;

  /// Button: share the last 30 days
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get aiSummary30;

  /// Subtitle of a review row carrying an AI estimate
  ///
  /// In en, this message translates to:
  /// **'{amount} · estimated by your AI'**
  String ocrEstimated(String amount);

  /// One-line calories-and-grams summary
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal · {grams} g'**
  String kcalDotGrams(String kcal, String grams);

  /// Compact nutrition line; P/C/F are one-letter macro abbreviations — localize the letters
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal · P {protein}  C {carb}  F {fat}'**
  String macroPcf(String kcal, String protein, String carb, String fat);

  /// Title of the custom-food form
  ///
  /// In en, this message translates to:
  /// **'Custom food'**
  String get manualTitle;

  /// Label of the required name field (* marks required)
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get manualNameRequired;

  /// Label of the optional brand field
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get manualBrandOptional;

  /// Section header: nutrition values are entered per 100 g
  ///
  /// In en, this message translates to:
  /// **'Per 100 g'**
  String get manualPer100;

  /// Label of the required calories field (* marks required)
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal) *'**
  String get manualCalories;

  /// Label of the protein field, in grams
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get manualProtein;

  /// Label of the carbohydrates field, in grams
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get manualCarbs;

  /// Label of the fat field, in grams
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get manualFat;

  /// Label of the optional serving-size field, in grams
  ///
  /// In en, this message translates to:
  /// **'Serving size (g, optional)'**
  String get manualServing;

  /// Submit button of the custom-food form
  ///
  /// In en, this message translates to:
  /// **'Save food'**
  String get manualSaveFood;

  /// Validation error under an empty required field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get manualRequired;

  /// Validation error for a value that isn't a valid number
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get manualInvalidNumber;

  /// Title of the add-product screen shown after scanning an unknown barcode
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProductTitle;

  /// Action: photograph the product's nutrition table
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the nutrition table'**
  String get addPhotoOfTable;

  /// Action: pick the nutrition-table photo from the gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get addChooseGallery;

  /// Validation message on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'A name and energy (kcal/100 g) are required.'**
  String get addNameEnergyRequired;

  /// Read-only barcode line on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'Barcode {code}'**
  String addBarcodeLabel(String code);

  /// Label of the product-name field
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get addProductName;

  /// Label of the serving-size field on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get addServingSize;

  /// Section header: nutrition values per 100 g
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100 g'**
  String get addNutritionPer100;

  /// Section header: nutrition values per 100 ml, for liquids
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100 ml'**
  String get addNutritionPer100Ml;

  /// Button that OCRs the photographed nutrition label
  ///
  /// In en, this message translates to:
  /// **'Scan label'**
  String get addScanLabel;

  /// Label of the energy field on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get addEnergy;

  /// Label of the protein field on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get addProtein;

  /// Label of the carbohydrate field on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'Carbohydrate'**
  String get addCarbohydrate;

  /// Label of the fat field on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get addFat;

  /// Sub-field label 'of which sugars', as printed on EU nutrition labels
  ///
  /// In en, this message translates to:
  /// **'of which sugars'**
  String get addSugars;

  /// Sub-field label 'of which saturates', as printed on EU nutrition labels
  ///
  /// In en, this message translates to:
  /// **'of which saturates'**
  String get addSaturates;

  /// Label of the fibre field on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'Fibre'**
  String get addFibre;

  /// Label of the salt field on the add-product screen
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get addSalt;

  /// Title of the card prompting the user to add the scanned product to Open Food Facts
  ///
  /// In en, this message translates to:
  /// **'Contribute to Open Food Facts'**
  String get offContributeTitle;

  /// Explanation under the Open Food Facts contribute title
  ///
  /// In en, this message translates to:
  /// **'Open this barcode on Open Food Facts to add the product. It needs a free account, but it\'s quick and helps everyone — the next person who scans it gets a match.'**
  String get offContributeBody;

  /// Tappable action label that opens the product's Open Food Facts page
  ///
  /// In en, this message translates to:
  /// **'Open in Open Food Facts'**
  String get offContributeAction;

  /// Info banner after OCR pre-filled the nutrition fields
  ///
  /// In en, this message translates to:
  /// **'Filled from the label — please check the values.'**
  String get addFilledFromLabel;

  /// Error banner when the nutrition-label OCR failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the table. Enter the values manually.'**
  String get addCouldntRead;

  /// Title of the recipe QR scanner screen
  ///
  /// In en, this message translates to:
  /// **'Scan recipe QR'**
  String get scanRecipeQr;

  /// Splash-screen status while the food database is being seeded
  ///
  /// In en, this message translates to:
  /// **'Preparing food database…'**
  String get splashPreparing;

  /// Title of the manual barcode entry dialog
  ///
  /// In en, this message translates to:
  /// **'Enter barcode'**
  String get scanEnterBarcode;

  /// Example-barcode placeholder in the manual entry field
  ///
  /// In en, this message translates to:
  /// **'e.g. 3017620422003'**
  String get scanExampleHint;

  /// Confirm button of the manual barcode dialog
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get scanLookUp;

  /// Action to type the barcode instead of scanning it
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get scanEnterManually;

  /// Tooltip for the scanner's flashlight/torch toggle button
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get scanTorch;

  /// Shown on emulators/desktops where camera scanning is unavailable
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is only available on a device.'**
  String get scanCameraOnlyDevice;

  /// Error when the camera fails to start
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the camera.'**
  String get scanCameraFailed;

  /// Fallback button to type the barcode when the camera fails
  ///
  /// In en, this message translates to:
  /// **'Enter barcode manually'**
  String get scanEnterManuallyButton;

  /// Title of the split-meal sheet
  ///
  /// In en, this message translates to:
  /// **'Split \"{name}\"'**
  String splitTitle(String name);

  /// Explainer in the split-meal sheet
  ///
  /// In en, this message translates to:
  /// **'Divide this meal into equal portions, one per day. The original is replaced.'**
  String get splitDescription;

  /// Per-portion calories in the split-meal sheet
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal each'**
  String splitKcalEach(String kcal);

  /// Confirm button of the split-meal sheet; also the snackbar after splitting
  ///
  /// In en, this message translates to:
  /// **'Split into {n} days'**
  String splitInto(String n);

  /// Title of the merge-meal sheet
  ///
  /// In en, this message translates to:
  /// **'Merge \"{name}\" into…'**
  String mergeTitle(String name);

  /// Explainer in the merge-meal sheet
  ///
  /// In en, this message translates to:
  /// **'Move everything in this meal into another meal of the day. This meal is removed.'**
  String get mergeDescription;

  /// Shown in the merge-meal sheet when the day has no other meal to merge into
  ///
  /// In en, this message translates to:
  /// **'No other meals on this day.'**
  String get mergeNoOtherMeals;

  /// Snackbar after merging a meal into another
  ///
  /// In en, this message translates to:
  /// **'Merged into \"{name}\".'**
  String mergedInto(String name);

  /// Title of the crop screen for nutrition-table photos
  ///
  /// In en, this message translates to:
  /// **'Crop to the table'**
  String get cropTitle;

  /// Confirm button on the crop screen
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get cropDone;

  /// Snackbar nudging the user to download an offline region pack
  ///
  /// In en, this message translates to:
  /// **'Looked up online — download your region for faster, offline scans.'**
  String get offlineReminderText;

  /// Snackbar action that opens the offline-regions screen (keep short)
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get offlineReminderAction;

  /// Snackbar after a region pack finished downloading
  ///
  /// In en, this message translates to:
  /// **'{name} downloaded'**
  String regionDownloaded(String name);

  /// Snackbar when a region pack download fails
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String regionDownloadFailed(String error);

  /// Snackbar after removing a region pack
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String regionRemoved(String name);

  /// Error when the list of available regions can't be fetched
  ///
  /// In en, this message translates to:
  /// **'Could not load the region list.'**
  String get regionLoadError;

  /// Generic retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// Intro text on the offline-regions screen
  ///
  /// In en, this message translates to:
  /// **'Download a country to search its packaged products offline. You can download several.'**
  String get regionIntro;

  /// Placeholder in the country search field
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get regionSearchHint;

  /// Shown when no country matches the search
  ///
  /// In en, this message translates to:
  /// **'No countries match \"{query}\".'**
  String regionNoMatch(String query);

  /// Tooltip of a region row's download button
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get regionTooltipDownload;

  /// Tooltip of a region row's remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get regionTooltipRemove;

  /// Button to update an installed region pack
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get regionUpdate;

  /// Snackbar after region packs were updated; regions is a comma-separated list of region names
  ///
  /// In en, this message translates to:
  /// **'Offline data updated: {regions}'**
  String regionsAutoUpdated(String regions);

  /// Button on the Offline regions screen that updates every outdated region
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Update 1 region} other{Update {count} regions}}'**
  String regionUpdateAll(int count);

  /// Region row subtitle: product count in thousands and download size
  ///
  /// In en, this message translates to:
  /// **'{products}k products · {size} download'**
  String regionSubtitle(String products, String size);

  /// Region row subtitle suffix when the pack is installed and current; date is when it was last downloaded, e.g. 12 Oct
  ///
  /// In en, this message translates to:
  /// **'{base} · updated {date}'**
  String regionSubtitleInstalled(String base, String date);

  /// Region row subtitle suffix when an update is available
  ///
  /// In en, this message translates to:
  /// **'{base} · update available'**
  String regionSubtitleUpdatable(String base);

  /// Snackbar action undoing a removal
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// Settings switch: shows or hides all weight tracking
  ///
  /// In en, this message translates to:
  /// **'Track weight'**
  String get settingsTrackWeight;

  /// Subtitle of the Track weight switch
  ///
  /// In en, this message translates to:
  /// **'Weigh-ins, your 7-day trend and goal weights'**
  String get settingsTrackWeightSub;

  /// Settings row opening the weight settings
  ///
  /// In en, this message translates to:
  /// **'Goal weights & unit'**
  String get settingsWeight;

  /// Subtitle of the weight settings row
  ///
  /// In en, this message translates to:
  /// **'Milestones, kg or lb, height for BMI'**
  String get settingsWeightSub;

  /// Trends view switch: the nutrition charts
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get trendsNutrition;

  /// Unit: kilograms
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// Unit: pounds
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get unitLb;

  /// Unit: centimetres
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// Unit: inches
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get unitIn;

  /// Weight sheet / view / settings title; also the input label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightTitle;

  /// A weight with its unit, e.g. 87.4 kg
  ///
  /// In en, this message translates to:
  /// **'{value} {unit}'**
  String weightValue(String value, String unit);

  /// After the big 7-day average on the Day row: 87.0 kg 7-day
  ///
  /// In en, this message translates to:
  /// **'7-day'**
  String get weightSevenDay;

  /// Day row: change of the 7-day average vs the week before
  ///
  /// In en, this message translates to:
  /// **'{change} this week'**
  String weightThisWeek(String change);

  /// Day row: the day's own weigh-in under the trend, e.g. Today 86.9 kg
  ///
  /// In en, this message translates to:
  /// **'{day} {value}'**
  String weightDayValue(String day, String value);

  /// Day row before today's weigh-in
  ///
  /// In en, this message translates to:
  /// **'Add today\'s weight'**
  String get weightAddToday;

  /// Day row on another day without a weigh-in
  ///
  /// In en, this message translates to:
  /// **'Add a weight'**
  String get weightAddForDay;

  /// Shown while there are too few weigh-ins for an average
  ///
  /// In en, this message translates to:
  /// **'The 7-day average starts at 3 weigh-ins in a week'**
  String get weightNoAverageYet;

  /// Weight sheet date line, e.g. Today, 13 Nov
  ///
  /// In en, this message translates to:
  /// **'{day}, {date}'**
  String weightSheetDate(String day, String date);

  /// Weight sheet input label while editing a weigh-in
  ///
  /// In en, this message translates to:
  /// **'Editing the {time} weigh-in'**
  String weightEditing(String time);

  /// Weight sheet: the weigh-in's time
  ///
  /// In en, this message translates to:
  /// **'Time {time}'**
  String weightTime(String time);

  /// Button changing the weigh-in time
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get weightChangeTime;

  /// Weight sheet: header of the day's weigh-ins
  ///
  /// In en, this message translates to:
  /// **'Weigh-ins'**
  String get weightWeighIns;

  /// Badge: this weigh-in is the day's value because it was the first
  ///
  /// In en, this message translates to:
  /// **'counts · first'**
  String get weightCountsFirst;

  /// Badge: the user chose this weigh-in as the day's value
  ///
  /// In en, this message translates to:
  /// **'counts · chosen'**
  String get weightCountsChosen;

  /// Weigh-in source: imported from Health Connect / Apple Health
  ///
  /// In en, this message translates to:
  /// **'from {store}'**
  String weightSourceHealth(String store);

  /// Weigh-in source: typed into the app
  ///
  /// In en, this message translates to:
  /// **'added here'**
  String get weightSourceHere;

  /// Menu: make this weigh-in the day's value
  ///
  /// In en, this message translates to:
  /// **'Count this one'**
  String get weightCountThis;

  /// Menu: remove a weigh-in / goal
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get weightRemove;

  /// Snackbar after removing a weigh-in
  ///
  /// In en, this message translates to:
  /// **'Weigh-in removed'**
  String get weightRemoved;

  /// Weight sheet footer
  ///
  /// In en, this message translates to:
  /// **'7-day average {value}'**
  String weightSheetAverage(String value);

  /// Weight sheet link to Trends · Weight
  ///
  /// In en, this message translates to:
  /// **'See trend'**
  String get weightSeeTrend;

  /// FAB on the weight view
  ///
  /// In en, this message translates to:
  /// **'Add weight'**
  String get weightAdd;

  /// Weight view empty state
  ///
  /// In en, this message translates to:
  /// **'No weigh-ins yet. Add one with the button below or from the Day screen.'**
  String get weightEmpty;

  /// Weight chart with no data in the chosen range
  ///
  /// In en, this message translates to:
  /// **'No weigh-ins in this range'**
  String get weightEmptyRange;

  /// Range: one month (keep short)
  ///
  /// In en, this message translates to:
  /// **'1 M'**
  String get weightRange1M;

  /// Range: three months (keep short)
  ///
  /// In en, this message translates to:
  /// **'3 M'**
  String get weightRange3M;

  /// Range: one year (keep short)
  ///
  /// In en, this message translates to:
  /// **'1 Y'**
  String get weightRange1Y;

  /// Range: everything (keep short)
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get weightRangeAll;

  /// Weight card / chart legend: the rolling 7-day average
  ///
  /// In en, this message translates to:
  /// **'7-day average'**
  String get weightCardAverage;

  /// Weight card: change of the average vs the week before
  ///
  /// In en, this message translates to:
  /// **'{change} vs. last week'**
  String weightVsLastWeek(String change);

  /// Weight card: the latest daily value
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get weightCardLatest;

  /// Weight card: change of the trend since the first average
  ///
  /// In en, this message translates to:
  /// **'Since start'**
  String get weightCardSinceStart;

  /// Weight card: where the trend started
  ///
  /// In en, this message translates to:
  /// **'from {value} · {date}'**
  String weightSinceFrom(String value, String date);

  /// Weight card: the next goal weight or BMI boundary
  ///
  /// In en, this message translates to:
  /// **'Next milestone'**
  String get weightCardNext;

  /// Weight card label when no goal is set
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get weightCardGoal;

  /// Weight card: distance to the next milestone
  ///
  /// In en, this message translates to:
  /// **'{distance} to go'**
  String weightToGo(String distance);

  /// Weight card: estimate, only on a steady trend
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{~1 week at this pace} other{~{weeks} weeks at this pace}}'**
  String weightEta(int weeks);

  /// Weight card without a goal
  ///
  /// In en, this message translates to:
  /// **'No goal set'**
  String get weightNoGoal;

  /// Weight card link to the goal settings
  ///
  /// In en, this message translates to:
  /// **'Set a goal weight →'**
  String get weightSetGoal;

  /// Weight card once past the final goal
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get weightGoalReached;

  /// Tag of the final goal weight on the chart / card
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get weightGoalLabel;

  /// Milestone tag when losing: the weight where BMI drops under this value
  ///
  /// In en, this message translates to:
  /// **'BMI < {bmi}'**
  String weightBmiUnder(String bmi);

  /// Milestone tag when gaining: the weight where BMI reaches this value
  ///
  /// In en, this message translates to:
  /// **'BMI ≥ {bmi}'**
  String weightBmiAtLeast(String bmi);

  /// Header of the calendar-week list
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weightWeeks;

  /// The current calendar week in the list
  ///
  /// In en, this message translates to:
  /// **'{range} · so far'**
  String weightSoFar(String range);

  /// Chart legend: a daily weigh-in dot
  ///
  /// In en, this message translates to:
  /// **'Weigh-in'**
  String get weightLegendWeighIn;

  /// Chart legend: dashed goal lines
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get weightLegendMilestones;

  /// Screen-reader label of the weight chart
  ///
  /// In en, this message translates to:
  /// **'Weight chart: daily weigh-ins, the 7-day average and your milestones'**
  String get a11yWeightChart;

  /// Weight settings: kg / lb
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get weightUnit;

  /// Weight settings: body height
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get weightHeight;

  /// Weight settings: what the height is for
  ///
  /// In en, this message translates to:
  /// **'Optional — adds BMI milestones'**
  String get weightHeightSub;

  /// Weight settings section header
  ///
  /// In en, this message translates to:
  /// **'Goal weights'**
  String get weightGoalsSection;

  /// Weight settings: how goals and direction work
  ///
  /// In en, this message translates to:
  /// **'Your goal and the milestones on the way. The one farthest from your trend is the goal — below it means losing counts as progress, above it gaining. Without a goal, the numbers stay neutral.'**
  String get weightGoalsHelp;

  /// Weight settings: add a goal / milestone
  ///
  /// In en, this message translates to:
  /// **'Add a goal weight'**
  String get weightGoalAdd;

  /// Weight settings: empty goal list
  ///
  /// In en, this message translates to:
  /// **'No goal set — the numbers stay neutral'**
  String get weightGoalsEmpty;

  /// Health section switch: import weigh-ins from the health store
  ///
  /// In en, this message translates to:
  /// **'Read weight'**
  String get settingsHealthWeightRead;

  /// Subtitle of Read weight
  ///
  /// In en, this message translates to:
  /// **'Weigh-ins from a scale or another app in {store}'**
  String settingsHealthWeightReadSub(String store);

  /// Health section switch: save weigh-ins typed in the app to the health store
  ///
  /// In en, this message translates to:
  /// **'Write my weights'**
  String get settingsHealthWeightWrite;

  /// Subtitle of Write my weights
  ///
  /// In en, this message translates to:
  /// **'Saves the weigh-ins you add here to {store}'**
  String settingsHealthWeightWriteSub(String store);

  /// Snackbar after turning on Read weight
  ///
  /// In en, this message translates to:
  /// **'Weigh-ins from {store} now show up here'**
  String healthWeightReadOn(String store);

  /// Snackbar after turning on Write my weights
  ///
  /// In en, this message translates to:
  /// **'New weigh-ins are saved to {store}'**
  String healthWeightWriteOn(String store);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
