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

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// Settings section header for the app language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

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

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// Footnote under the language picker disclosing that non-English locales are machine translations
  ///
  /// In en, this message translates to:
  /// **'Only English is human-written. German, French and Italian are machine-translated and may read awkwardly.'**
  String get languageMachineNote;

  /// No description provided for @dayPreviousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get dayPreviousDay;

  /// No description provided for @dayNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get dayNextDay;

  /// No description provided for @dayAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get dayAddFood;

  /// No description provided for @dayMealFromList.
  ///
  /// In en, this message translates to:
  /// **'Meal from an ingredient list'**
  String get dayMealFromList;

  /// Empty-state hint on the Day screen
  ///
  /// In en, this message translates to:
  /// **'Tap + to start a meal.\nEverything you add flows into it until you tap ✓ (or 15 min pass).'**
  String get dayEmptyHint;

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @macroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// No description provided for @macroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get macroCarbs;

  /// No description provided for @macroFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get macroFat;

  /// No description provided for @targetOver.
  ///
  /// In en, this message translates to:
  /// **'{kcal} over'**
  String targetOver(String kcal);

  /// No description provided for @targetToGo.
  ///
  /// In en, this message translates to:
  /// **'{kcal} to go'**
  String targetToGo(String kcal);

  /// No description provided for @targetLeft.
  ///
  /// In en, this message translates to:
  /// **'{kcal} left'**
  String targetLeft(String kcal);

  /// No description provided for @targetMinReached.
  ///
  /// In en, this message translates to:
  /// **'minimum reached'**
  String get targetMinReached;

  /// No description provided for @targetRangeBoth.
  ///
  /// In en, this message translates to:
  /// **'Target {min}–{max} kcal'**
  String targetRangeBoth(String min, String max);

  /// No description provided for @targetRangeMax.
  ///
  /// In en, this message translates to:
  /// **'Target {max} kcal'**
  String targetRangeMax(String max);

  /// No description provided for @targetRangeMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum {min} kcal'**
  String targetRangeMin(String min);

  /// No description provided for @mealMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get mealMenuEdit;

  /// No description provided for @mealMenuSplit.
  ///
  /// In en, this message translates to:
  /// **'Split across days'**
  String get mealMenuSplit;

  /// No description provided for @mealMenuSaveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save as recipe'**
  String get mealMenuSaveRecipe;

  /// No description provided for @mealMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get mealMenuDelete;

  /// No description provided for @mealFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish meal'**
  String get mealFinish;

  /// No description provided for @mealAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to this meal'**
  String get mealAddTo;

  /// No description provided for @mealSavedToRecipes.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\" to recipes'**
  String mealSavedToRecipes(String name);

  /// No description provided for @editMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get editMealTitle;

  /// No description provided for @editMealName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editMealName;

  /// No description provided for @editMealType.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get editMealType;

  /// No description provided for @editMealWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get editMealWhen;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// No description provided for @recipesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet.\nCreate one to reuse meals, share them, or batch-cook and split across days.'**
  String get recipesEmpty;

  /// No description provided for @recipeNew.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get recipeNew;

  /// No description provided for @recipeServings.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String recipeServings(String count);

  /// No description provided for @recipeImported.
  ///
  /// In en, this message translates to:
  /// **'Imported \"{name}\"'**
  String recipeImported(String name);

  /// No description provided for @qrNotRecipe.
  ///
  /// In en, this message translates to:
  /// **'That QR code is not a recipe.'**
  String get qrNotRecipe;

  /// No description provided for @createBuildManually.
  ///
  /// In en, this message translates to:
  /// **'Build manually'**
  String get createBuildManually;

  /// No description provided for @createBuildManuallySub.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients one by one'**
  String get createBuildManuallySub;

  /// No description provided for @createFromList.
  ///
  /// In en, this message translates to:
  /// **'From an ingredient list'**
  String get createFromList;

  /// No description provided for @createFromListSub.
  ///
  /// In en, this message translates to:
  /// **'Photograph a printed list — save it or log it as a meal'**
  String get createFromListSub;

  /// No description provided for @createFromQr.
  ///
  /// In en, this message translates to:
  /// **'Import from QR code'**
  String get createFromQr;

  /// No description provided for @createFromQrSub.
  ///
  /// In en, this message translates to:
  /// **'Scan a shared recipe'**
  String get createFromQrSub;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(String error);

  /// No description provided for @settingsTargets.
  ///
  /// In en, this message translates to:
  /// **'Calorie targets'**
  String get settingsTargets;

  /// No description provided for @settingsTargetsHelp.
  ///
  /// In en, this message translates to:
  /// **'Set a minimum, a maximum, or both. A minimum helps if you need to make sure you eat enough. Leave blank to use the default.'**
  String get settingsTargetsHelp;

  /// No description provided for @settingsTargetDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsTargetDefault;

  /// No description provided for @settingsCustomizePerDay.
  ///
  /// In en, this message translates to:
  /// **'Customize per day'**
  String get settingsCustomizePerDay;

  /// No description provided for @settingsCustomizePerDaySub.
  ///
  /// In en, this message translates to:
  /// **'Training days and weekends can differ'**
  String get settingsCustomizePerDaySub;

  /// No description provided for @settingsLogging.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get settingsLogging;

  /// No description provided for @settingsMealTimes.
  ///
  /// In en, this message translates to:
  /// **'Meal times'**
  String get settingsMealTimes;

  /// No description provided for @settingsMealTimesSub.
  ///
  /// In en, this message translates to:
  /// **'Names each meal by the time you log it'**
  String get settingsMealTimesSub;

  /// No description provided for @settingsMealTimesHelp.
  ///
  /// In en, this message translates to:
  /// **'A new meal is named after the window its first item falls in (e.g. \"Breakfast 08:23\"). Anything outside these windows is a snack. You can always rename a meal.'**
  String get settingsMealTimesHelp;

  /// No description provided for @settingsFoodData.
  ///
  /// In en, this message translates to:
  /// **'Food data'**
  String get settingsFoodData;

  /// No description provided for @settingsOfflineRegions.
  ///
  /// In en, this message translates to:
  /// **'Offline regions'**
  String get settingsOfflineRegions;

  /// No description provided for @settingsOfflineRegionsSub.
  ///
  /// In en, this message translates to:
  /// **'Download country product databases for offline search'**
  String get settingsOfflineRegionsSub;

  /// No description provided for @settingsHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get settingsHealthConnect;

  /// No description provided for @settingsHealthSync.
  ///
  /// In en, this message translates to:
  /// **'Sync to Health Connect'**
  String get settingsHealthSync;

  /// No description provided for @settingsHealthSyncSub.
  ///
  /// In en, this message translates to:
  /// **'Write logged calories & macros to Health Connect'**
  String get settingsHealthSyncSub;

  /// No description provided for @settingsHealthTimeNote.
  ///
  /// In en, this message translates to:
  /// **'Entries sync at the time you logged them'**
  String get settingsHealthTimeNote;

  /// No description provided for @settingsHealthTimeNoteSub.
  ///
  /// In en, this message translates to:
  /// **'Back-date a meal from its ⋮ menu to change its time.'**
  String get settingsHealthTimeNoteSub;

  /// No description provided for @settingsDataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data & backup'**
  String get settingsDataBackup;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExport;

  /// No description provided for @settingsExportSub.
  ///
  /// In en, this message translates to:
  /// **'Share a .zip (JSON + CSV)'**
  String get settingsExportSub;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get settingsImport;

  /// No description provided for @settingsImportSub.
  ///
  /// In en, this message translates to:
  /// **'Restore from a .zip (replaces all data)'**
  String get settingsImportSub;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Ad-free, no subscriptions. Data from Open Food Facts and the Swiss Food Composition Database (Federal Food Safety and Veterinary Office, FSVO).'**
  String get settingsAboutBody;

  /// No description provided for @offThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks to Open Food Facts'**
  String get offThanksTitle;

  /// No description provided for @offThanksBody.
  ///
  /// In en, this message translates to:
  /// **'Knabberfuchs is built on Open Food Facts — a free, open, crowdsourced food database kept alive by volunteers around the world. Without their work, this app simply would not exist.\n\nIf Knabberfuchs is useful to you, please consider supporting them.'**
  String get offThanksBody;

  /// No description provided for @offDonate.
  ///
  /// In en, this message translates to:
  /// **'Donate to Open Food Facts'**
  String get offDonate;

  /// No description provided for @healthSyncOff.
  ///
  /// In en, this message translates to:
  /// **'Health Connect sync turned off.'**
  String get healthSyncOff;

  /// No description provided for @healthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Health Connect is not available on this device.'**
  String get healthUnavailable;

  /// No description provided for @healthNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Health Connect permission was not granted.'**
  String get healthNoPermission;

  /// No description provided for @healthSyncOn.
  ///
  /// In en, this message translates to:
  /// **'Health Connect sync on — today pushed.'**
  String get healthSyncOn;

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String backupExportFailed(String error);

  /// No description provided for @backupReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get backupReplaceTitle;

  /// No description provided for @backupReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'Importing will replace your current entries, custom foods, recipes, targets, and settings with the backup contents.'**
  String get backupReplaceBody;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get backupRestored;

  /// No description provided for @backupImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String backupImportFailed(String error);

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @editEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntryTitle;

  /// No description provided for @kcalPer100.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal / 100 g'**
  String kcalPer100(String kcal);

  /// No description provided for @volumeApprox.
  ///
  /// In en, this message translates to:
  /// **'≈ {grams} g (assumes ~1 g/ml)'**
  String volumeApprox(String grams);

  /// No description provided for @oneServing.
  ///
  /// In en, this message translates to:
  /// **'1 serving ({grams} g)'**
  String oneServing(String grams);

  /// No description provided for @searchFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods…'**
  String get searchFoodsHint;

  /// No description provided for @searchRecentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Recently used'**
  String get searchRecentlyUsed;

  /// No description provided for @createCustomFood.
  ///
  /// In en, this message translates to:
  /// **'Create custom food'**
  String get createCustomFood;

  /// No description provided for @searchEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search for a food, scan a barcode,\nor create your own.'**
  String get searchEmptyPrompt;

  /// No description provided for @searchNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches for \"{query}\".'**
  String searchNoMatches(String query);

  /// No description provided for @kcalPer100Short.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal\n/100 g'**
  String kcalPer100Short(String kcal);

  /// No description provided for @sourceOff.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts'**
  String get sourceOff;

  /// No description provided for @sourceUsda.
  ///
  /// In en, this message translates to:
  /// **'USDA'**
  String get sourceUsda;

  /// No description provided for @sourceCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get sourceCustom;

  /// No description provided for @sourceSwiss.
  ///
  /// In en, this message translates to:
  /// **'Swiss DB'**
  String get sourceSwiss;

  /// No description provided for @sourceContributed.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get sourceContributed;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @selectFood.
  ///
  /// In en, this message translates to:
  /// **'Select food'**
  String get selectFood;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get actionSet;

  /// No description provided for @kcalValue.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String kcalValue(String kcal);

  /// No description provided for @gramsValue.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String gramsValue(String grams);

  /// No description provided for @gramsKcal.
  ///
  /// In en, this message translates to:
  /// **'{grams} g · {kcal} kcal'**
  String gramsKcal(String grams, String kcal);

  /// No description provided for @kcalTotal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal total'**
  String kcalTotal(String kcal);

  /// No description provided for @loggedTo.
  ///
  /// In en, this message translates to:
  /// **'Logged to {day}'**
  String loggedTo(String day);

  /// No description provided for @recipeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get recipeEdit;

  /// No description provided for @recipeNeedName.
  ///
  /// In en, this message translates to:
  /// **'Give the recipe a name.'**
  String get recipeNeedName;

  /// No description provided for @recipeNeedIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient.'**
  String get recipeNeedIngredient;

  /// No description provided for @recipeName.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get recipeName;

  /// No description provided for @recipeServingsField.
  ///
  /// In en, this message translates to:
  /// **'Servings (portions this makes)'**
  String get recipeServingsField;

  /// No description provided for @recipeLogPortion.
  ///
  /// In en, this message translates to:
  /// **'Log portion to a day'**
  String get recipeLogPortion;

  /// No description provided for @recipeWhole.
  ///
  /// In en, this message translates to:
  /// **'Whole recipe'**
  String get recipeWhole;

  /// No description provided for @recipePerServing.
  ///
  /// In en, this message translates to:
  /// **'Per serving ({count})'**
  String recipePerServing(String count);

  /// No description provided for @recipeLogPortionTitle.
  ///
  /// In en, this message translates to:
  /// **'Log a portion'**
  String get recipeLogPortionTitle;

  /// No description provided for @recipePortions.
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get recipePortions;

  /// No description provided for @recipeLogToDay.
  ///
  /// In en, this message translates to:
  /// **'Log to {day}'**
  String recipeLogToDay(String day);

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share \"{name}\"'**
  String shareTitle(String name);

  /// No description provided for @shareScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan this in another phone’s \"Import from QR\".'**
  String get shareScanHint;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get shareAsText;

  /// No description provided for @shareMeta.
  ///
  /// In en, this message translates to:
  /// **'{ingredients} ingredients · {servings} servings · {bytes} bytes'**
  String shareMeta(String ingredients, String servings, String bytes);

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'Recipe: {name}'**
  String shareSubject(String name);

  /// No description provided for @ocrNoIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found in those images.'**
  String get ocrNoIngredients;

  /// No description provided for @ocrDefaultMealName.
  ///
  /// In en, this message translates to:
  /// **'Meal from photo'**
  String get ocrDefaultMealName;

  /// No description provided for @ocrNeedMatch.
  ///
  /// In en, this message translates to:
  /// **'Match at least one ingredient first.'**
  String get ocrNeedMatch;

  /// No description provided for @ocrSavedToRecipes.
  ///
  /// In en, this message translates to:
  /// **'Saved to recipes'**
  String get ocrSavedToRecipes;

  /// No description provided for @ocrReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review meal'**
  String get ocrReviewTitle;

  /// No description provided for @ocrSaveAsRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save as recipe'**
  String get ocrSaveAsRecipe;

  /// No description provided for @ocrLogToDay.
  ///
  /// In en, this message translates to:
  /// **'Log to day'**
  String get ocrLogToDay;

  /// No description provided for @ocrMealName.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get ocrMealName;

  /// No description provided for @ocrMatched.
  ///
  /// In en, this message translates to:
  /// **'{matched} / {total} matched'**
  String ocrMatched(String matched, String total);

  /// No description provided for @ocrSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe → to pick a food, ← to remove.'**
  String get ocrSwipeHint;

  /// No description provided for @ocrFromSource.
  ///
  /// In en, this message translates to:
  /// **'{amount} · from \"{name}\"'**
  String ocrFromSource(String amount, String name);

  /// No description provided for @ocrPickHintSub.
  ///
  /// In en, this message translates to:
  /// **'{amount} · swipe → to pick a food'**
  String ocrPickHintSub(String amount);

  /// No description provided for @kcalGrams.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal\n{grams} g'**
  String kcalGrams(String kcal, String grams);

  /// No description provided for @ocrSetGrams.
  ///
  /// In en, this message translates to:
  /// **'set g'**
  String get ocrSetGrams;

  /// No description provided for @kcalDotGrams.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal · {grams} g'**
  String kcalDotGrams(String kcal, String grams);

  /// No description provided for @macroPcf.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal · P {protein}  C {carb}  F {fat}'**
  String macroPcf(String kcal, String protein, String carb, String fat);

  /// No description provided for @manualTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom food'**
  String get manualTitle;

  /// No description provided for @manualNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get manualNameRequired;

  /// No description provided for @manualBrandOptional.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get manualBrandOptional;

  /// No description provided for @manualPer100.
  ///
  /// In en, this message translates to:
  /// **'Per 100 g'**
  String get manualPer100;

  /// No description provided for @manualCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal) *'**
  String get manualCalories;

  /// No description provided for @manualProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get manualProtein;

  /// No description provided for @manualCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get manualCarbs;

  /// No description provided for @manualFat.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get manualFat;

  /// No description provided for @manualServing.
  ///
  /// In en, this message translates to:
  /// **'Serving size (g, optional)'**
  String get manualServing;

  /// No description provided for @manualSaveFood.
  ///
  /// In en, this message translates to:
  /// **'Save food'**
  String get manualSaveFood;

  /// No description provided for @manualRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get manualRequired;

  /// No description provided for @manualInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get manualInvalidNumber;

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProductTitle;

  /// No description provided for @addPhotoOfTable.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the nutrition table'**
  String get addPhotoOfTable;

  /// No description provided for @addChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get addChooseGallery;

  /// No description provided for @addNameEnergyRequired.
  ///
  /// In en, this message translates to:
  /// **'A name and energy (kcal/100 g) are required.'**
  String get addNameEnergyRequired;

  /// No description provided for @addBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode {code}'**
  String addBarcodeLabel(String code);

  /// No description provided for @addProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get addProductName;

  /// No description provided for @addServingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get addServingSize;

  /// No description provided for @addNutritionPer100.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100 g'**
  String get addNutritionPer100;

  /// No description provided for @addScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan label'**
  String get addScanLabel;

  /// No description provided for @addEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get addEnergy;

  /// No description provided for @addProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get addProtein;

  /// No description provided for @addCarbohydrate.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrate'**
  String get addCarbohydrate;

  /// No description provided for @addFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get addFat;

  /// No description provided for @addSugars.
  ///
  /// In en, this message translates to:
  /// **'of which sugars'**
  String get addSugars;

  /// No description provided for @addSaturates.
  ///
  /// In en, this message translates to:
  /// **'of which saturates'**
  String get addSaturates;

  /// No description provided for @addFibre.
  ///
  /// In en, this message translates to:
  /// **'Fibre'**
  String get addFibre;

  /// No description provided for @addSalt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get addSalt;

  /// No description provided for @addToOff.
  ///
  /// In en, this message translates to:
  /// **'Add to Open Food Facts'**
  String get addToOff;

  /// No description provided for @addToOffNote.
  ///
  /// In en, this message translates to:
  /// **'Opens Open Food Facts so everyone benefits. Your local entry is saved either way.'**
  String get addToOffNote;

  /// No description provided for @addFilledFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Filled from the label — please check the values.'**
  String get addFilledFromLabel;

  /// No description provided for @addCouldntRead.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the table. Enter the values manually.'**
  String get addCouldntRead;

  /// No description provided for @backupShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Knabberfuchs backup'**
  String get backupShareSubject;

  /// No description provided for @scanRecipeQr.
  ///
  /// In en, this message translates to:
  /// **'Scan recipe QR'**
  String get scanRecipeQr;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing food database…'**
  String get splashPreparing;

  /// No description provided for @scanEnterBarcode.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode'**
  String get scanEnterBarcode;

  /// No description provided for @scanExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3017620422003'**
  String get scanExampleHint;

  /// No description provided for @scanLookUp.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get scanLookUp;

  /// No description provided for @scanEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get scanEnterManually;

  /// No description provided for @scanCameraOnlyDevice.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is only available on a device.'**
  String get scanCameraOnlyDevice;

  /// No description provided for @scanCameraFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the camera.'**
  String get scanCameraFailed;

  /// No description provided for @scanEnterManuallyButton.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode manually'**
  String get scanEnterManuallyButton;

  /// No description provided for @splitTitle.
  ///
  /// In en, this message translates to:
  /// **'Split \"{name}\"'**
  String splitTitle(String name);

  /// No description provided for @splitDescription.
  ///
  /// In en, this message translates to:
  /// **'Divide this meal into equal portions, one per day. The original is replaced.'**
  String get splitDescription;

  /// No description provided for @splitKcalEach.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal each'**
  String splitKcalEach(String kcal);

  /// No description provided for @splitInto.
  ///
  /// In en, this message translates to:
  /// **'Split into {n} days'**
  String splitInto(String n);

  /// No description provided for @cropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop to the table'**
  String get cropTitle;

  /// No description provided for @cropDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get cropDone;

  /// No description provided for @offlineReminderText.
  ///
  /// In en, this message translates to:
  /// **'Looked up online — download your region for faster, offline scans.'**
  String get offlineReminderText;

  /// No description provided for @offlineReminderAction.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get offlineReminderAction;

  /// No description provided for @regionDownloaded.
  ///
  /// In en, this message translates to:
  /// **'{name} downloaded'**
  String regionDownloaded(String name);

  /// No description provided for @regionDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String regionDownloadFailed(String error);

  /// No description provided for @regionRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String regionRemoved(String name);

  /// No description provided for @regionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the region list.'**
  String get regionLoadError;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @regionIntro.
  ///
  /// In en, this message translates to:
  /// **'Download a country to search its packaged products offline. You can download several.'**
  String get regionIntro;

  /// No description provided for @regionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get regionSearchHint;

  /// No description provided for @regionNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No countries match \"{query}\".'**
  String regionNoMatch(String query);

  /// No description provided for @regionTooltipDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get regionTooltipDownload;

  /// No description provided for @regionTooltipRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get regionTooltipRemove;

  /// No description provided for @regionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get regionUpdate;

  /// No description provided for @regionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{products}k products · {size} download'**
  String regionSubtitle(String products, String size);

  /// No description provided for @regionSubtitleInstalled.
  ///
  /// In en, this message translates to:
  /// **'{base} · installed'**
  String regionSubtitleInstalled(String base);

  /// No description provided for @regionSubtitleUpdatable.
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
