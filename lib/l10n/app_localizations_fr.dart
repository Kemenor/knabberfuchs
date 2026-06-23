// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Knabberfuchs';

  @override
  String get navDay => 'Jour';

  @override
  String get navRecipes => 'Recettes';

  @override
  String get navSettings => 'Réglages';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionImport => 'Importer';

  @override
  String get settingsSectionLanguage => 'Langue';

  @override
  String get settingsLanguage => 'Langue de l\'application';

  @override
  String get languageSystem => 'Réglage du système';

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
      'Les langues autres que l\'anglais ont été traduites automatiquement et peuvent sembler maladroites.';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateYesterday => 'Hier';

  @override
  String get dateTomorrow => 'Demain';

  @override
  String get dayPreviousDay => 'Jour précédent';

  @override
  String get dayNextDay => 'Jour suivant';

  @override
  String get dayAddFood => 'Ajouter un aliment';

  @override
  String get dayMealFromList => 'Repas à partir d\'une liste d\'ingrédients';

  @override
  String get dayEmptyHint =>
      'Appuyez sur + pour commencer un repas.\nTout ce que vous ajoutez s\'y intègre jusqu\'à ce que vous appuyiez sur ✓ (ou après 15 min).';

  @override
  String get unitKcal => 'kcal';

  @override
  String get macroProtein => 'Protéines';

  @override
  String get macroCarbs => 'Glucides';

  @override
  String get macroFat => 'Lipides';

  @override
  String targetOver(String kcal) {
    return '$kcal de trop';
  }

  @override
  String targetToGo(String kcal) {
    return 'encore $kcal';
  }

  @override
  String targetLeft(String kcal) {
    return '$kcal restantes';
  }

  @override
  String get targetMinReached => 'minimum atteint';

  @override
  String targetRangeBoth(String min, String max) {
    return 'Objectif $min–$max kcal';
  }

  @override
  String targetRangeMax(String max) {
    return 'Objectif $max kcal';
  }

  @override
  String targetRangeMin(String min) {
    return 'Minimum $min kcal';
  }

  @override
  String get mealMenuEdit => 'Modifier le repas';

  @override
  String get mealMenuSplit => 'Répartir sur plusieurs jours';

  @override
  String get mealMenuSaveRecipe => 'Enregistrer comme recette';

  @override
  String get mealMenuDelete => 'Supprimer le repas';

  @override
  String get mealFinish => 'Terminer le repas';

  @override
  String get mealAddTo => 'Ajouter à ce repas';

  @override
  String mealSavedToRecipes(String name) {
    return '\"$name\" enregistré dans les recettes';
  }

  @override
  String get editMealTitle => 'Modifier le repas';

  @override
  String get editMealName => 'Nom';

  @override
  String get editMealType => 'Type de repas';

  @override
  String get editMealWhen => 'Quand';

  @override
  String recipeDeleteConfirm(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get recipesTitle => 'Recettes';

  @override
  String get recipesEmpty =>
      'Aucune recette pour l\'instant.\nCréez-en une pour réutiliser des repas, les partager ou cuisiner en grande quantité et répartir sur plusieurs jours.';

  @override
  String get recipeNew => 'Nouvelle recette';

  @override
  String recipeServings(String count) {
    return '$count portions';
  }

  @override
  String recipeImported(String name) {
    return '\"$name\" importé';
  }

  @override
  String get qrNotRecipe => 'Ce n\'est pas une recette valide.';

  @override
  String get createBuildManually => 'Créer manuellement';

  @override
  String get createBuildManuallySub => 'Ajouter les ingrédients un par un';

  @override
  String get createFromList => 'À partir d\'une liste d\'ingrédients';

  @override
  String get createFromListSub =>
      'Photographiez une liste imprimée — enregistrez-la ou consignez-la comme repas';

  @override
  String get createFromQr => 'Importer depuis un code QR';

  @override
  String get createFromQrSub => 'Scanner une recette partagée';

  @override
  String genericError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get settingsTargets => 'Objectifs caloriques';

  @override
  String get settingsTargetsHelp =>
      'Définissez un minimum, un maximum ou les deux. Un minimum aide si vous devez vous assurer de manger assez. Laissez vide pour utiliser la valeur par défaut.';

  @override
  String get settingsTargetDefault => 'Par défaut';

  @override
  String get settingsCustomizePerDay => 'Personnaliser par jour';

  @override
  String get settingsCustomizePerDaySub =>
      'Les jours d\'entraînement et les week-ends peuvent différer';

  @override
  String get settingsLogging => 'Journal';

  @override
  String get settingsMealTimes => 'Heures des repas';

  @override
  String get settingsMealTimesSub =>
      'Nomme chaque repas selon l\'heure de saisie';

  @override
  String get settingsMealTimesHelp =>
      'Un nouveau repas est nommé selon la plage horaire dans laquelle tombe son premier élément (p. ex. \"Petit-déjeuner 08:23\"). Tout ce qui est en dehors de ces plages est une collation. Vous pouvez toujours renommer un repas.';

  @override
  String get settingsFoodData => 'Données alimentaires';

  @override
  String get settingsOfflineRegions => 'Régions hors ligne';

  @override
  String get settingsOfflineRegionsSub =>
      'Téléchargez les bases de données de produits par pays pour la recherche hors ligne';

  @override
  String get settingsHealthConnect => 'Health Connect';

  @override
  String get settingsHealthSync => 'Synchroniser avec Health Connect';

  @override
  String get settingsHealthSyncSub =>
      'Écrire les calories et macros enregistrées dans Health Connect';

  @override
  String get settingsHealthTimeNote =>
      'Les entrées se synchronisent à l\'heure de saisie';

  @override
  String get settingsHealthTimeNoteSub =>
      'Antidatez un repas depuis son menu ⋮ pour changer son heure.';

  @override
  String get settingsDataBackup => 'Données et sauvegarde';

  @override
  String get settingsExport => 'Exporter la sauvegarde';

  @override
  String get settingsExportSub => 'Partager un .zip (JSON + CSV)';

  @override
  String get settingsImport => 'Importer une sauvegarde';

  @override
  String get settingsImportSub =>
      'Restaurer depuis un .zip (remplace toutes les données)';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsContactDev => 'Contacter le développeur';

  @override
  String get settingsContactDevSub =>
      'Envoyer un retour ou un bug par e-mail (ajoute infos app & appareil)';

  @override
  String settingsContactDevNoApp(String email) {
    return 'Aucune app e-mail trouvée. Écrivez à $email';
  }

  @override
  String get settingsAboutBody =>
      'Sans publicité, sans abonnement. Données alimentaires d\'Open Food Facts (© contributeurs Open Food Facts, ODbL) et de la Base de données suisse des valeurs nutritives (Office fédéral de la sécurité alimentaire et des affaires vétérinaires, OSAV). Tailles de portions d\'après USDA FoodData Central (domaine public). La reconnaissance photo sur l\'appareil utilise le modèle AIY food_V1 de Google (Apache 2.0). Touchez « Afficher les licences » pour les composants open source.';

  @override
  String get offThanksTitle => 'Merci à Open Food Facts';

  @override
  String get offThanksBody =>
      'Knabberfuchs repose sur Open Food Facts — une base de données alimentaire gratuite, ouverte et collaborative, maintenue en vie par des bénévoles du monde entier. Sans leur travail, cette application n\'existerait tout simplement pas.\n\nSi Knabberfuchs vous est utile, pensez à les soutenir.';

  @override
  String get offDonate => 'Faire un don à Open Food Facts';

  @override
  String get healthSyncOff => 'Synchronisation Health Connect désactivée.';

  @override
  String get healthUnavailable =>
      'Health Connect n\'est pas disponible sur cet appareil.';

  @override
  String get healthNoPermission =>
      'L\'autorisation Health Connect n\'a pas été accordée.';

  @override
  String get healthSyncOn =>
      'Synchronisation Health Connect activée — aujourd\'hui envoyé.';

  @override
  String backupExportFailed(String error) {
    return 'Échec de l\'export : $error';
  }

  @override
  String get backupReplaceTitle => 'Remplacer toutes les données ?';

  @override
  String get backupReplaceBody =>
      'L\'import remplacera vos entrées actuelles, aliments personnalisés, recettes, objectifs et réglages par le contenu de la sauvegarde.';

  @override
  String get backupRestored => 'Sauvegarde restaurée.';

  @override
  String backupImportFailed(String error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String get amountLabel => 'Quantité';

  @override
  String get editEntryTitle => 'Modifier l\'entrée';

  @override
  String kcalPer100(String kcal) {
    return '$kcal kcal / 100 g';
  }

  @override
  String volumeApprox(String grams) {
    return '≈ $grams g (suppose ~1 g/ml)';
  }

  @override
  String volumeDensity(String grams, String density) {
    return '≈ $grams g · $density g/ml';
  }

  @override
  String oneServing(String grams) {
    return '1 portion ($grams g)';
  }

  @override
  String portionChip(String unit, String grams) {
    return '1 $unit · $grams g';
  }

  @override
  String get portionUnitPiece => 'pièce';

  @override
  String get portionUnitSmall => 'petit';

  @override
  String get portionUnitMedium => 'moyen';

  @override
  String get portionUnitLarge => 'grand';

  @override
  String get portionUnitSlice => 'tranche';

  @override
  String get portionUnitClove => 'gousse';

  @override
  String get portionUnitStalk => 'branche';

  @override
  String get portionUnitHandful => 'poignée';

  @override
  String get portionUnitCob => 'épi';

  @override
  String get searchFoodsHint => 'Rechercher des aliments…';

  @override
  String get searchRecentlyUsed => 'Récemment utilisés';

  @override
  String get createCustomFood => 'Créer un aliment personnalisé';

  @override
  String get searchEmptyPrompt =>
      'Recherchez un aliment, scannez un code-barres\nou créez le vôtre.';

  @override
  String searchNoMatches(String query) {
    return 'Aucun résultat pour \"$query\".';
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
  String get sourceCustom => 'Personnalisé';

  @override
  String get sourceSwiss => 'Base suisse';

  @override
  String get sourceContributed => 'Ajouté par vous';

  @override
  String get quickAdd => 'Ajout rapide';

  @override
  String quickAddNamed(String name) {
    return 'Ajout rapide « $name »';
  }

  @override
  String get quickAddSubtitle => 'Enregistrer juste un nom et des calories';

  @override
  String get quickAddName => 'Nom';

  @override
  String get quickAddCalories => 'Calories';

  @override
  String get quickAddWeight => 'Poids';

  @override
  String get quickAddMacros => 'Ajouter les macros (facultatif)';

  @override
  String get recognizeTooltip => 'Reconnaître par photo';

  @override
  String get recognizeTakePhoto => 'Prendre une photo';

  @override
  String get recognizeLooksLike => 'On dirait…';

  @override
  String get recognizeNoneManual => 'Aucun de ceux-ci – saisir manuellement';

  @override
  String get recognizeNoGuess =>
      'Aliment non reconnu. Ajoutez-le manuellement.';

  @override
  String get dayCaptureTooltip => 'Ajouter depuis une photo';

  @override
  String get captureScanAi => 'Scanner un repas avec l\'IA';

  @override
  String get captureScanAiSub =>
      'Photographiez un plat — on devine le plat et les calories';

  @override
  String get foodFormTitle => 'Nouvel aliment';

  @override
  String get barcodeField => 'Code-barres (facultatif)';

  @override
  String get settingsAi => 'Reconnaissance par IA';

  @override
  String get aiKeyDesc =>
      'Les photos sont reconnues sur votre téléphone par défaut. Ajoutez une clé API Google Gemini pour des résultats plus précis et des estimations de portions. Votre photo est alors envoyée à Google. L\'offre gratuite de Gemini suffit pour un usage personnel ; si vous avez activé la facturation sur votre compte Google, une utilisation intensive peut entraîner des frais. Dans l\'offre gratuite, Google peut utiliser vos photos pour améliorer ses modèles.';

  @override
  String get aiKeyLabel => 'Clé API Gemini';

  @override
  String get aiKeyGet => 'Obtenir une clé API';

  @override
  String get aiOnDeviceOnlyTitle => 'Toujours reconnaître sur l\'appareil';

  @override
  String get aiOnDeviceOnlySubtitle =>
      'Ne jamais envoyer de photos à Gemini — utiliser le modèle sur l\'appareil pour chaque scan.';

  @override
  String get recognizeByGemini => 'Estimé par Gemini';

  @override
  String get recognizeByOnDevice => 'Estimé sur l\'appareil';

  @override
  String get geminiFailed =>
      'Gemini injoignable — reconnaissance sur l\'appareil utilisée.';

  @override
  String get geminiThinking1 => 'Demande des calories à Gemini…';

  @override
  String get geminiThinking2 => 'Estimation des calories d\'après votre photo…';

  @override
  String get geminiThinking3 => 'Identification du plat…';

  @override
  String get geminiThinking4 => 'Évaluation de la portion…';

  @override
  String geminiRetrying(int n) {
    return 'Serveur occupé — nouvelle tentative ($n)…';
  }

  @override
  String get scanBarcode => 'Scanner un code-barres';

  @override
  String get selectFood => 'Sélectionner un aliment';

  @override
  String get addIngredient => 'Ajouter un ingrédient';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionSet => 'Définir';

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
    return '$kcal kcal au total';
  }

  @override
  String loggedTo(String day) {
    return 'Enregistré pour $day';
  }

  @override
  String get recipeEdit => 'Modifier la recette';

  @override
  String get recipeNeedName => 'Donnez un nom à la recette.';

  @override
  String get recipeNeedIngredient => 'Ajoutez au moins un ingrédient.';

  @override
  String get recipeName => 'Nom de la recette';

  @override
  String get recipeServingsField => 'Portions (que donne cette recette)';

  @override
  String get recipeLogPortion => 'Consigner une portion pour un jour';

  @override
  String get recipeWhole => 'Recette entière';

  @override
  String recipePerServing(String count) {
    return 'Par portion ($count)';
  }

  @override
  String get recipeLogPortionTitle => 'Consigner une portion';

  @override
  String get recipePortions => 'Portions';

  @override
  String recipeLogToDay(String day) {
    return 'Consigner pour $day';
  }

  @override
  String shareTitle(String name) {
    return 'Partager \"$name\"';
  }

  @override
  String get shareScanHint =>
      'Scannez ceci sur un autre téléphone via \"Importer depuis QR\".';

  @override
  String get shareAsImage => 'Partager l\'image';

  @override
  String get createFromText => 'Importer depuis un texte';

  @override
  String get createFromTextSub => 'Coller une recette reçue';

  @override
  String get importTextTitle => 'Coller la recette';

  @override
  String get importTextHint => 'Code de la recette…';

  @override
  String get shareAsText => 'Partager en texte';

  @override
  String shareMeta(String ingredients, String servings, String bytes) {
    return '$ingredients ingrédients · $servings portions · $bytes octets';
  }

  @override
  String shareSubject(String name) {
    return 'Recette : $name';
  }

  @override
  String get ocrNoIngredients => 'Aucun ingrédient trouvé dans ces images.';

  @override
  String get ocrDefaultMealName => 'Repas depuis une photo';

  @override
  String get ocrNeedMatch => 'Associez d\'abord au moins un ingrédient.';

  @override
  String get ocrSavedToRecipes => 'Enregistré dans les recettes';

  @override
  String get ocrReviewTitle => 'Vérifier le repas';

  @override
  String get ocrSaveAsRecipe => 'Enregistrer comme recette';

  @override
  String get ocrLogToDay => 'Consigner pour un jour';

  @override
  String get ocrMealName => 'Nom du repas';

  @override
  String ocrMatched(String matched, String total) {
    return '$matched / $total associés';
  }

  @override
  String get ocrSwipeHint =>
      'Glissez → pour choisir un aliment, ← pour retirer.';

  @override
  String ocrFromSource(String amount, String name) {
    return '$amount · depuis \"$name\"';
  }

  @override
  String ocrPickHintSub(String amount) {
    return '$amount · glissez → pour choisir un aliment';
  }

  @override
  String kcalGrams(String kcal, String grams) {
    return '$kcal kcal\n$grams g';
  }

  @override
  String get ocrSetGrams => 'définir g';

  @override
  String kcalDotGrams(String kcal, String grams) {
    return '$kcal kcal · $grams g';
  }

  @override
  String macroPcf(String kcal, String protein, String carb, String fat) {
    return '$kcal kcal · P $protein  G $carb  L $fat';
  }

  @override
  String get manualTitle => 'Aliment personnalisé';

  @override
  String get manualNameRequired => 'Nom *';

  @override
  String get manualBrandOptional => 'Marque (facultatif)';

  @override
  String get manualPer100 => 'Pour 100 g';

  @override
  String get manualCalories => 'Calories (kcal) *';

  @override
  String get manualProtein => 'Protéines (g)';

  @override
  String get manualCarbs => 'Glucides (g)';

  @override
  String get manualFat => 'Lipides (g)';

  @override
  String get manualServing => 'Taille de portion (g, facultatif)';

  @override
  String get manualSaveFood => 'Enregistrer l\'aliment';

  @override
  String get manualRequired => 'Requis';

  @override
  String get manualInvalidNumber => 'Nombre invalide';

  @override
  String get addProductTitle => 'Ajouter un produit';

  @override
  String get addPhotoOfTable => 'Prendre une photo du tableau nutritionnel';

  @override
  String get addChooseGallery => 'Choisir dans la galerie';

  @override
  String get addNameEnergyRequired =>
      'Un nom et l\'énergie (kcal/100 g) sont requis.';

  @override
  String addBarcodeLabel(String code) {
    return 'Code-barres $code';
  }

  @override
  String get addProductName => 'Nom du produit';

  @override
  String get addServingSize => 'Taille de portion';

  @override
  String get addNutritionPer100 => 'Valeurs nutritionnelles pour 100 g';

  @override
  String get addScanLabel => 'Scanner l\'étiquette';

  @override
  String get addEnergy => 'Énergie';

  @override
  String get addProtein => 'Protéines';

  @override
  String get addCarbohydrate => 'Glucides';

  @override
  String get addFat => 'Lipides';

  @override
  String get addSugars => 'dont sucres';

  @override
  String get addSaturates => 'dont acides gras saturés';

  @override
  String get addFibre => 'Fibres';

  @override
  String get addSalt => 'Sel';

  @override
  String get shareToOff =>
      'Envie de partager ce produit avec tout le monde ? Ajoutez-le à Open Food Facts.';

  @override
  String get shareToOffLink => 'Comment ajouter un produit';

  @override
  String get addFilledFromLabel =>
      'Rempli à partir de l\'étiquette — veuillez vérifier les valeurs.';

  @override
  String get addCouldntRead =>
      'Impossible de lire le tableau. Saisissez les valeurs manuellement.';

  @override
  String get backupShareSubject => 'Sauvegarde Knabberfuchs';

  @override
  String get scanRecipeQr => 'Scanner le QR de la recette';

  @override
  String get splashPreparing =>
      'Préparation de la base de données alimentaire…';

  @override
  String get scanEnterBarcode => 'Saisir le code-barres';

  @override
  String get scanExampleHint => 'p. ex. 3017620422003';

  @override
  String get scanLookUp => 'Rechercher';

  @override
  String get scanEnterManually => 'Saisir manuellement';

  @override
  String get scanCameraOnlyDevice =>
      'Le scan par caméra n\'est disponible que sur un appareil.';

  @override
  String get scanCameraFailed => 'Impossible de démarrer la caméra.';

  @override
  String get scanEnterManuallyButton => 'Saisir le code-barres manuellement';

  @override
  String splitTitle(String name) {
    return 'Répartir \"$name\"';
  }

  @override
  String get splitDescription =>
      'Divisez ce repas en portions égales, une par jour. L\'original est remplacé.';

  @override
  String splitKcalEach(String kcal) {
    return '$kcal kcal chacune';
  }

  @override
  String splitInto(String n) {
    return 'Répartir sur $n jours';
  }

  @override
  String get cropTitle => 'Recadrer sur le tableau';

  @override
  String get cropDone => 'Terminé';

  @override
  String get offlineReminderText =>
      'Recherche en ligne — téléchargez votre région pour des scans hors ligne plus rapides.';

  @override
  String get offlineReminderAction => 'Régions';

  @override
  String regionDownloaded(String name) {
    return '$name téléchargé';
  }

  @override
  String regionDownloadFailed(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String regionRemoved(String name) {
    return '$name supprimé';
  }

  @override
  String get regionLoadError => 'Impossible de charger la liste des régions.';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get regionIntro =>
      'Téléchargez un pays pour rechercher ses produits emballés hors ligne. Vous pouvez en télécharger plusieurs.';

  @override
  String get regionSearchHint => 'Rechercher des pays';

  @override
  String regionNoMatch(String query) {
    return 'Aucun pays ne correspond à \"$query\".';
  }

  @override
  String get regionTooltipDownload => 'Télécharger';

  @override
  String get regionTooltipRemove => 'Supprimer';

  @override
  String get regionUpdate => 'Mettre à jour';

  @override
  String regionSubtitle(String products, String size) {
    return '${products}k produits · $size à télécharger';
  }

  @override
  String regionSubtitleInstalled(String base) {
    return '$base · installé';
  }

  @override
  String regionSubtitleUpdatable(String base) {
    return '$base · mise à jour disponible';
  }
}
