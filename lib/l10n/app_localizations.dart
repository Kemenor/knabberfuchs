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

  /// Snackbar when exporting a backup fails
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String backupExportFailed(String error);

  /// File-type filter name shown in the system file picker when choosing a backup .zip
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupFileType;

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

  /// Tooltip of the photo-recognition action
  ///
  /// In en, this message translates to:
  /// **'Recognize from photo'**
  String get recognizeTooltip;

  /// Image source option: take a photo with the camera
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get recognizeTakePhoto;

  /// Header above the photo-recognition guesses
  ///
  /// In en, this message translates to:
  /// **'Looks like…'**
  String get recognizeLooksLike;

  /// Option to reject all recognition guesses and enter the food manually
  ///
  /// In en, this message translates to:
  /// **'None of these — enter manually'**
  String get recognizeNoneManual;

  /// Shown when photo recognition produced no usable guess
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t recognize the food. Add it manually.'**
  String get recognizeNoGuess;

  /// Hint suggesting a Gemini API key for better photo recognition
  ///
  /// In en, this message translates to:
  /// **'Tip: add a free Gemini key in Settings for better results — including drinks the on-device model can\'t recognize.'**
  String get recognizeGeminiNudge;

  /// Tooltip of the camera action on the Day screen
  ///
  /// In en, this message translates to:
  /// **'Add from a photo'**
  String get dayCaptureTooltip;

  /// Capture menu entry: recognize a meal photo with AI
  ///
  /// In en, this message translates to:
  /// **'Scan a meal with AI'**
  String get captureScanAi;

  /// Subtitle under the scan-a-meal-with-AI entry
  ///
  /// In en, this message translates to:
  /// **'Photograph a dish — we\'ll guess it and the calories'**
  String get captureScanAiSub;

  /// Title of the new-food form
  ///
  /// In en, this message translates to:
  /// **'New food'**
  String get foodFormTitle;

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

  /// Explainer for the Gemini API key setting, including the privacy implications
  ///
  /// In en, this message translates to:
  /// **'Meal photos are recognised on your phone by default. Add a Google Gemini API key for sharper results and portion estimates. Your photo is then sent to Google. Gemini\'s free tier is plenty for personal use; if you\'ve enabled billing on your Google account, heavy use may incur charges. On the free tier, Google may use your photos to improve their models.'**
  String get aiKeyDesc;

  /// Label of the Gemini API key field
  ///
  /// In en, this message translates to:
  /// **'Gemini API key'**
  String get aiKeyLabel;

  /// Link that opens the page for obtaining a Gemini API key
  ///
  /// In en, this message translates to:
  /// **'Get an API key'**
  String get aiKeyGet;

  /// Label of the AI model picker
  ///
  /// In en, this message translates to:
  /// **'AI model'**
  String get aiModelLabel;

  /// AI model option: Gemini 2.5 Flash (model name stays as is)
  ///
  /// In en, this message translates to:
  /// **'Gemini 2.5 Flash — reliable'**
  String get aiModelReliable;

  /// AI model option: Gemini 3.5 Flash (model name stays as is)
  ///
  /// In en, this message translates to:
  /// **'Gemini 3.5 Flash — sharper, often busy'**
  String get aiModelAccurate;

  /// Note under the model picker explaining the fallback chain
  ///
  /// In en, this message translates to:
  /// **'If your choice is busy it falls back to 2.5 Flash, then on-device.'**
  String get aiModelNote;

  /// Toggle title: never upload photos, always use the on-device model
  ///
  /// In en, this message translates to:
  /// **'Always recognise on-device'**
  String get aiOnDeviceOnlyTitle;

  /// Subtitle under the always-on-device toggle
  ///
  /// In en, this message translates to:
  /// **'Never upload photos to Gemini — use the on-device model for every scan.'**
  String get aiOnDeviceOnlySubtitle;

  /// Attribution badge on results estimated by Gemini
  ///
  /// In en, this message translates to:
  /// **'Estimated by Gemini'**
  String get recognizeByGemini;

  /// Title of the optional meal-description step before a Gemini scan
  ///
  /// In en, this message translates to:
  /// **'Describe the meal (optional)'**
  String get geminiHintTitle;

  /// Label of the optional hint text field for a Gemini scan
  ///
  /// In en, this message translates to:
  /// **'Add a hint'**
  String get geminiHintLabel;

  /// Example placeholder in the Gemini hint field
  ///
  /// In en, this message translates to:
  /// **'e.g. homemade lasagne, large portion'**
  String get geminiHintExample;

  /// Button that starts the Gemini estimate
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get geminiHintEstimate;

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

  /// Attribution badge on results estimated by the on-device model
  ///
  /// In en, this message translates to:
  /// **'Estimated on-device'**
  String get recognizeByOnDevice;

  /// Snackbar when Gemini was unreachable and the on-device model was used instead
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Gemini — used on-device recognition.'**
  String get geminiFailed;

  /// Rotating status line while waiting for Gemini (1/6)
  ///
  /// In en, this message translates to:
  /// **'Asking Gemini for calories…'**
  String get geminiThinking1;

  /// Rotating status line while waiting for Gemini (2/6)
  ///
  /// In en, this message translates to:
  /// **'Estimating calories from your photo…'**
  String get geminiThinking2;

  /// Rotating status line while waiting for Gemini (3/6)
  ///
  /// In en, this message translates to:
  /// **'Identifying the dish…'**
  String get geminiThinking3;

  /// Rotating status line while waiting for Gemini (4/6)
  ///
  /// In en, this message translates to:
  /// **'Working out the portion size…'**
  String get geminiThinking4;

  /// Rotating status line while waiting for Gemini (5/6)
  ///
  /// In en, this message translates to:
  /// **'Reading the plate…'**
  String get geminiThinking5;

  /// Rotating status line while waiting for Gemini (6/6)
  ///
  /// In en, this message translates to:
  /// **'Crunching the numbers…'**
  String get geminiThinking6;

  /// Status line when a Gemini request takes unusually long
  ///
  /// In en, this message translates to:
  /// **'Gemini\'s a bit busy — hang on…'**
  String get geminiSlow;

  /// Status line while retrying a busy Gemini server
  ///
  /// In en, this message translates to:
  /// **'Server busy — retrying (attempt {n})…'**
  String geminiRetrying(int n);

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
  /// **'Import from text'**
  String get createFromText;

  /// Subtitle under the import-from-text option
  ///
  /// In en, this message translates to:
  /// **'Paste a recipe you received'**
  String get createFromTextSub;

  /// Title of the paste-recipe dialog
  ///
  /// In en, this message translates to:
  /// **'Paste recipe'**
  String get importTextTitle;

  /// Placeholder in the paste-recipe text field
  ///
  /// In en, this message translates to:
  /// **'Recipe code…'**
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

  /// Share-sheet subject line for an exported backup file
  ///
  /// In en, this message translates to:
  /// **'Knabberfuchs backup'**
  String get backupShareSubject;

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

  /// Region row subtitle: product count in thousands and download size
  ///
  /// In en, this message translates to:
  /// **'{products}k products · {size} download'**
  String regionSubtitle(String products, String size);

  /// Region row subtitle suffix when the pack is installed
  ///
  /// In en, this message translates to:
  /// **'{base} · installed'**
  String regionSubtitleInstalled(String base);

  /// Region row subtitle suffix when an update is available
  ///
  /// In en, this message translates to:
  /// **'{base} · update available'**
  String regionSubtitleUpdatable(String base);
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
