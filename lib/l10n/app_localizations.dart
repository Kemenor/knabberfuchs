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
