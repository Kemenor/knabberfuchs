// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Knabberfuchs';

  @override
  String get navDay => 'Day';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navSettings => 'Settings';

  @override
  String get navTrends => 'Trends';

  @override
  String get settingsDisplay => 'Display';

  @override
  String get settingsShowTrends => 'Show Trends tab';

  @override
  String get settingsShowTrendsSub =>
      'Add a tab with weekly and monthly calorie charts';

  @override
  String get trendsWeek => 'Week';

  @override
  String get trendsMonth => 'Month';

  @override
  String get trendsCustom => 'Custom';

  @override
  String get trendsWeeklyAvg => 'Weekly average';

  @override
  String get trendsMonthlyAvg => 'Monthly average';

  @override
  String get trendsAvgPerDay => 'Average / day';

  @override
  String get trendsDaysInTarget => 'Days in target';

  @override
  String get trendsEmpty =>
      'No entries yet for this range. Log some food to see your trends.';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionImport => 'Import';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsTypeface => 'Typeface';

  @override
  String get typefaceDefault => 'Default';

  @override
  String get typefaceLowVision => 'Low-vision legibility';

  @override
  String get typefaceDyslexia => 'Dyslexia';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageMachineNote =>
      'Languages other than English have been machine-translated and may read awkwardly.';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get dateTomorrow => 'Tomorrow';

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
  String get mealMenuScale => 'Scale meal';

  @override
  String scaleMealApply(String pct) {
    return 'Scale to $pct%';
  }

  @override
  String scaleMealDone(String pct) {
    return 'Meal scaled to $pct%';
  }

  @override
  String get mealMenuSaveRecipe => 'Save as recipe';

  @override
  String get mealMenuDelete => 'Delete meal';

  @override
  String get mealFinish => 'Finish meal';

  @override
  String get mealAddTo => 'Add to this meal';

  @override
  String get mealCollapse => 'Collapse meal';

  @override
  String get mealExpand => 'Expand meal';

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

  @override
  String recipeDeleteConfirm(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipesEmpty =>
      'No recipes yet.\nCreate one to reuse meals, share them, or batch-cook and split across days.';

  @override
  String get recipeNew => 'New recipe';

  @override
  String recipeServings(String count) {
    return '$count servings';
  }

  @override
  String recipeImported(String name) {
    return 'Imported \"$name\"';
  }

  @override
  String get qrNotRecipe => 'That\'s not a valid recipe.';

  @override
  String get createBuildManually => 'Build manually';

  @override
  String get createBuildManuallySub => 'Add ingredients one by one';

  @override
  String get createFromList => 'From an ingredient list';

  @override
  String get createFromListSub =>
      'Photograph a printed list — save it or log it as a meal';

  @override
  String get createFromQr => 'Import from QR code';

  @override
  String get createFromQrSub => 'Scan a shared recipe';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get couldNotOpenLink => 'Couldn\'t open the link';

  @override
  String get settingsTargets => 'Targets';

  @override
  String get settingsTargetsSub => 'Calorie and macro goals, per day';

  @override
  String get metricCalories => 'Calories';

  @override
  String get settingsTargetsHelp =>
      'Set a minimum, a maximum, or both. A minimum helps if you need to make sure you eat enough. Leave blank to use the default.';

  @override
  String get settingsTargetDefault => 'Default';

  @override
  String get settingsTargetMin => 'min';

  @override
  String get settingsTargetMax => 'max';

  @override
  String get settingsCustomizePerDay => 'Customize per day';

  @override
  String get settingsCustomizePerDaySub =>
      'Training days and weekends can differ';

  @override
  String get settingsLogging => 'Logging';

  @override
  String get settingsMealTimes => 'Meal times';

  @override
  String get settingsMealTimesSub => 'Names each meal by the time you log it';

  @override
  String get settingsMealTimesHelp =>
      'A new meal is named after the window its first item falls in (e.g. \"Breakfast 08:23\"). Anything outside these windows is a snack. You can always rename a meal.';

  @override
  String get settingsFoodData => 'Food data';

  @override
  String get settingsOfflineRegions => 'Offline regions';

  @override
  String get settingsOfflineRegionsSub =>
      'Download country product databases for offline search';

  @override
  String settingsHealthConnect(String store) {
    return '$store';
  }

  @override
  String settingsHealthSync(String store) {
    return 'Sync to $store';
  }

  @override
  String settingsHealthSyncSub(String store) {
    return 'Write logged calories & macros to $store';
  }

  @override
  String get settingsHealthTimeNote =>
      'Entries sync at the time you logged them';

  @override
  String get settingsHealthTimeNoteSub =>
      'Back-date a meal from its ⋮ menu to change its time.';

  @override
  String get settingsDataBackup => 'Data & backup';

  @override
  String get settingsExport => 'Export backup';

  @override
  String get settingsExportSub => 'Share a .zip (JSON + CSV)';

  @override
  String get settingsImport => 'Import backup';

  @override
  String get settingsImportSub => 'Restore from a .zip (replaces all data)';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsContactDev => 'Contact the developer';

  @override
  String get settingsContactDevSub =>
      'Email feedback or a bug report (adds app & device info)';

  @override
  String settingsContactDevNoApp(String email) {
    return 'No email app found. Write to $email';
  }

  @override
  String get settingsAboutBody =>
      'Ad-free, no subscriptions. Food data from Open Food Facts (© Open Food Facts contributors, ODbL) and the Swiss Food Composition Database (Federal Food Safety and Veterinary Office, FSVO). Portion sizes informed by USDA FoodData Central (public domain). On-device photo recognition uses Google\'s AIY food_V1 model (Apache 2.0). Tap “View licenses” for open-source components.';

  @override
  String get offThanksTitle => 'Thanks to Open Food Facts';

  @override
  String get offThanksBody =>
      'Knabberfuchs is built on Open Food Facts — a free, open, crowdsourced food database kept alive by volunteers around the world. Without their work, this app simply would not exist.\n\nIf Knabberfuchs is useful to you, please consider supporting them.';

  @override
  String get offDonate => 'Donate to Open Food Facts';

  @override
  String healthSyncOff(String store) {
    return '$store sync turned off.';
  }

  @override
  String healthUnavailable(String store) {
    return '$store is not available on this device.';
  }

  @override
  String healthNoPermission(String store) {
    return '$store permission was not granted.';
  }

  @override
  String healthSyncOn(String store) {
    return '$store sync on — today pushed.';
  }

  @override
  String backupExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get backupReplaceTitle => 'Replace all data?';

  @override
  String get backupReplaceBody =>
      'Importing will replace your current entries, custom foods, recipes, targets, and settings with the backup contents.';

  @override
  String get backupRestored => 'Backup restored.';

  @override
  String backupImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get amountLabel => 'Amount';

  @override
  String get editEntryTitle => 'Edit entry';

  @override
  String kcalPer100(String kcal) {
    return '$kcal kcal / 100 g';
  }

  @override
  String volumeApprox(String grams) {
    return '≈ $grams g (assumes ~1 g/ml)';
  }

  @override
  String volumeDensity(String grams, String density) {
    return '≈ $grams g · $density g/ml';
  }

  @override
  String oneServing(String grams) {
    return '1 serving ($grams g)';
  }

  @override
  String portionChip(String unit, String grams) {
    return '1 $unit · $grams g';
  }

  @override
  String get portionUnitPiece => 'piece';

  @override
  String get portionUnitSmall => 'small';

  @override
  String get portionUnitMedium => 'medium';

  @override
  String get portionUnitLarge => 'large';

  @override
  String get portionUnitSlice => 'slice';

  @override
  String get portionUnitClove => 'clove';

  @override
  String get portionUnitStalk => 'stalk';

  @override
  String get portionUnitHandful => 'handful';

  @override
  String get portionUnitCob => 'cob';

  @override
  String get searchFoodsHint => 'Search foods…';

  @override
  String get searchRecentlyUsed => 'Recently used';

  @override
  String get createCustomFood => 'Create custom food';

  @override
  String get searchEmptyPrompt =>
      'Search for a food, scan a barcode,\nor create your own.';

  @override
  String searchNoMatches(String query) {
    return 'No matches for \"$query\".';
  }

  @override
  String kcalPer100Short(String kcal) {
    return '$kcal kcal\n/100 g';
  }

  @override
  String get sourceOff => 'Open Food Facts';

  @override
  String get sourceUsda => 'USDA';

  @override
  String get sourceCustom => 'Custom';

  @override
  String get sourceSwiss => 'Swiss DB';

  @override
  String get sourceContributed => 'Added by you';

  @override
  String get quickAdd => 'Quick add';

  @override
  String quickAddNamed(String name) {
    return 'Quick add \"$name\"';
  }

  @override
  String get quickAddSubtitle => 'Log just a name and calories';

  @override
  String get quickAddName => 'Name';

  @override
  String get quickAddCalories => 'Calories';

  @override
  String get quickAddWeight => 'Weight';

  @override
  String get quickAddMacros => 'Add macros (optional)';

  @override
  String get recognizeTooltip => 'Recognize from photo';

  @override
  String get recognizeTakePhoto => 'Take a photo';

  @override
  String get recognizeLooksLike => 'Looks like…';

  @override
  String get recognizeNoneManual => 'None of these — enter manually';

  @override
  String get recognizeNoGuess =>
      'Couldn\'t recognize the food. Add it manually.';

  @override
  String get recognizeGeminiNudge =>
      'Tip: add a free Gemini key in Settings for better results — including drinks the on-device model can\'t recognize.';

  @override
  String get dayCaptureTooltip => 'Add from a photo';

  @override
  String get captureScanAi => 'Scan a meal with AI';

  @override
  String get captureScanAiSub =>
      'Photograph a dish — we\'ll guess it and the calories';

  @override
  String get foodFormTitle => 'New food';

  @override
  String get barcodeField => 'Barcode (optional)';

  @override
  String get settingsAi => 'AI recognition';

  @override
  String get aiKeyDesc =>
      'Meal photos are recognised on your phone by default. Add a Google Gemini API key for sharper results and portion estimates. Your photo is then sent to Google. Gemini\'s free tier is plenty for personal use; if you\'ve enabled billing on your Google account, heavy use may incur charges. On the free tier, Google may use your photos to improve their models.';

  @override
  String get aiKeyLabel => 'Gemini API key';

  @override
  String get aiKeyGet => 'Get an API key';

  @override
  String get aiModelLabel => 'AI model';

  @override
  String get aiModelReliable => 'Gemini 2.5 Flash — reliable';

  @override
  String get aiModelAccurate => 'Gemini 3.5 Flash — sharper, often busy';

  @override
  String get aiModelNote =>
      'If your choice is busy it falls back to 2.5 Flash, then on-device.';

  @override
  String get aiOnDeviceOnlyTitle => 'Always recognise on-device';

  @override
  String get aiOnDeviceOnlySubtitle =>
      'Never upload photos to Gemini — use the on-device model for every scan.';

  @override
  String get recognizeByGemini => 'Estimated by Gemini';

  @override
  String get recognizeByOnDevice => 'Estimated on-device';

  @override
  String get geminiFailed =>
      'Couldn\'t reach Gemini — used on-device recognition.';

  @override
  String get geminiThinking1 => 'Asking Gemini for calories…';

  @override
  String get geminiThinking2 => 'Estimating calories from your photo…';

  @override
  String get geminiThinking3 => 'Identifying the dish…';

  @override
  String get geminiThinking4 => 'Working out the portion size…';

  @override
  String get geminiThinking5 => 'Reading the plate…';

  @override
  String get geminiThinking6 => 'Crunching the numbers…';

  @override
  String get geminiSlow => 'Gemini\'s a bit busy — hang on…';

  @override
  String geminiRetrying(int n) {
    return 'Server busy — retrying (attempt $n)…';
  }

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get selectFood => 'Select food';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionShare => 'Share';

  @override
  String get actionSet => 'Set';

  @override
  String kcalValue(String kcal) {
    return '$kcal kcal';
  }

  @override
  String gramsValue(String grams) {
    return '$grams g';
  }

  @override
  String gramsKcal(String grams, String kcal) {
    return '$grams g · $kcal kcal';
  }

  @override
  String kcalTotal(String kcal) {
    return '$kcal kcal total';
  }

  @override
  String loggedTo(String day) {
    return 'Logged to $day';
  }

  @override
  String get recipeEdit => 'Edit recipe';

  @override
  String get recipeNeedName => 'Give the recipe a name.';

  @override
  String get recipeNeedIngredient => 'Add at least one ingredient.';

  @override
  String get recipeName => 'Recipe name';

  @override
  String get recipeServingsField => 'Servings (portions this makes)';

  @override
  String get recipeLogPortion => 'Log portion to a day';

  @override
  String get recipeWhole => 'Whole recipe';

  @override
  String recipePerServing(String count) {
    return 'Per serving ($count)';
  }

  @override
  String get recipeLogPortionTitle => 'Log a portion';

  @override
  String get recipePortions => 'Portions';

  @override
  String recipeLogToDay(String day) {
    return 'Log to $day';
  }

  @override
  String shareTitle(String name) {
    return 'Share \"$name\"';
  }

  @override
  String get shareScanHint =>
      'Scan this in another phone’s \"Import from QR\".';

  @override
  String get shareAsImage => 'Share image';

  @override
  String get createFromText => 'Import from text';

  @override
  String get createFromTextSub => 'Paste a recipe you received';

  @override
  String get importTextTitle => 'Paste recipe';

  @override
  String get importTextHint => 'Recipe code…';

  @override
  String get shareAsText => 'Share as text';

  @override
  String shareMeta(String ingredients, String servings, String bytes) {
    return '$ingredients ingredients · $servings servings · $bytes bytes';
  }

  @override
  String shareSubject(String name) {
    return 'Recipe: $name';
  }

  @override
  String get ocrNoIngredients => 'No ingredients found in those images.';

  @override
  String get ocrDefaultMealName => 'Meal from photo';

  @override
  String get ocrNeedMatch => 'Match at least one ingredient first.';

  @override
  String get ocrSavedToRecipes => 'Saved to recipes';

  @override
  String get ocrReviewTitle => 'Review meal';

  @override
  String get ocrSaveAsRecipe => 'Save as recipe';

  @override
  String get ocrLogToDay => 'Log to day';

  @override
  String get ocrMealName => 'Meal name';

  @override
  String ocrMatched(String matched, String total) {
    return '$matched / $total matched';
  }

  @override
  String get ocrSwipeHint => 'Swipe → to pick a food, ← to remove.';

  @override
  String ocrFromSource(String amount, String name) {
    return '$amount · from \"$name\"';
  }

  @override
  String ocrPickHintSub(String amount) {
    return '$amount · swipe → to pick a food';
  }

  @override
  String kcalGrams(String kcal, String grams) {
    return '$kcal kcal\n$grams g';
  }

  @override
  String get ocrSetGrams => 'set g';

  @override
  String kcalDotGrams(String kcal, String grams) {
    return '$kcal kcal · $grams g';
  }

  @override
  String macroPcf(String kcal, String protein, String carb, String fat) {
    return '$kcal kcal · P $protein  C $carb  F $fat';
  }

  @override
  String get manualTitle => 'Custom food';

  @override
  String get manualNameRequired => 'Name *';

  @override
  String get manualBrandOptional => 'Brand (optional)';

  @override
  String get manualPer100 => 'Per 100 g';

  @override
  String get manualCalories => 'Calories (kcal) *';

  @override
  String get manualProtein => 'Protein (g)';

  @override
  String get manualCarbs => 'Carbs (g)';

  @override
  String get manualFat => 'Fat (g)';

  @override
  String get manualServing => 'Serving size (g, optional)';

  @override
  String get manualSaveFood => 'Save food';

  @override
  String get manualRequired => 'Required';

  @override
  String get manualInvalidNumber => 'Invalid number';

  @override
  String get addProductTitle => 'Add product';

  @override
  String get addPhotoOfTable => 'Take a photo of the nutrition table';

  @override
  String get addChooseGallery => 'Choose from gallery';

  @override
  String get addNameEnergyRequired =>
      'A name and energy (kcal/100 g) are required.';

  @override
  String addBarcodeLabel(String code) {
    return 'Barcode $code';
  }

  @override
  String get addProductName => 'Product name';

  @override
  String get addServingSize => 'Serving size';

  @override
  String get addNutritionPer100 => 'Nutrition per 100 g';

  @override
  String get addNutritionPer100Ml => 'Nutrition per 100 ml';

  @override
  String get addScanLabel => 'Scan label';

  @override
  String get addEnergy => 'Energy';

  @override
  String get addProtein => 'Protein';

  @override
  String get addCarbohydrate => 'Carbohydrate';

  @override
  String get addFat => 'Fat';

  @override
  String get addSugars => 'of which sugars';

  @override
  String get addSaturates => 'of which saturates';

  @override
  String get addFibre => 'Fibre';

  @override
  String get addSalt => 'Salt';

  @override
  String get offContributeTitle => 'Contribute to Open Food Facts';

  @override
  String get offContributeBody =>
      'Open this barcode on Open Food Facts to add the product. It needs a free account, but it\'s quick and helps everyone — the next person who scans it gets a match.';

  @override
  String get offContributeAction => 'Open in Open Food Facts';

  @override
  String get addFilledFromLabel =>
      'Filled from the label — please check the values.';

  @override
  String get addCouldntRead =>
      'Couldn\'t read the table. Enter the values manually.';

  @override
  String get backupShareSubject => 'Knabberfuchs backup';

  @override
  String get scanRecipeQr => 'Scan recipe QR';

  @override
  String get splashPreparing => 'Preparing food database…';

  @override
  String get scanEnterBarcode => 'Enter barcode';

  @override
  String get scanExampleHint => 'e.g. 3017620422003';

  @override
  String get scanLookUp => 'Look up';

  @override
  String get scanEnterManually => 'Enter manually';

  @override
  String get scanTorch => 'Toggle flash';

  @override
  String get scanCameraOnlyDevice =>
      'Camera scanning is only available on a device.';

  @override
  String get scanCameraFailed => 'Couldn\'t start the camera.';

  @override
  String get scanEnterManuallyButton => 'Enter barcode manually';

  @override
  String splitTitle(String name) {
    return 'Split \"$name\"';
  }

  @override
  String get splitDescription =>
      'Divide this meal into equal portions, one per day. The original is replaced.';

  @override
  String splitKcalEach(String kcal) {
    return '$kcal kcal each';
  }

  @override
  String splitInto(String n) {
    return 'Split into $n days';
  }

  @override
  String get cropTitle => 'Crop to the table';

  @override
  String get cropDone => 'Done';

  @override
  String get offlineReminderText =>
      'Looked up online — download your region for faster, offline scans.';

  @override
  String get offlineReminderAction => 'Regions';

  @override
  String regionDownloaded(String name) {
    return '$name downloaded';
  }

  @override
  String regionDownloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String regionRemoved(String name) {
    return '$name removed';
  }

  @override
  String get regionLoadError => 'Could not load the region list.';

  @override
  String get actionRetry => 'Retry';

  @override
  String get regionIntro =>
      'Download a country to search its packaged products offline. You can download several.';

  @override
  String get regionSearchHint => 'Search countries';

  @override
  String regionNoMatch(String query) {
    return 'No countries match \"$query\".';
  }

  @override
  String get regionTooltipDownload => 'Download';

  @override
  String get regionTooltipRemove => 'Remove';

  @override
  String get regionUpdate => 'Update';

  @override
  String regionSubtitle(String products, String size) {
    return '${products}k products · $size download';
  }

  @override
  String regionSubtitleInstalled(String base) {
    return '$base · installed';
  }

  @override
  String regionSubtitleUpdatable(String base) {
    return '$base · update available';
  }
}
