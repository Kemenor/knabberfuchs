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
  String get navTrends => 'Andamento';

  @override
  String get settingsDisplay => 'Visualizzazione';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsTracking => 'Monitoraggio';

  @override
  String get settingsShowTrends => 'Mostra scheda Andamento';

  @override
  String get settingsShowTrendsSub =>
      'Aggiungi una scheda con grafici delle calorie settimanali e mensili';

  @override
  String get trendsWeek => 'Settimana';

  @override
  String get trendsMonth => 'Mese';

  @override
  String get trendsCustom => 'Person.';

  @override
  String get trendsWeeklyAvg => 'Media settimanale';

  @override
  String get trendsMonthlyAvg => 'Media mensile';

  @override
  String get trendsAvgPerDay => 'Media / giorno';

  @override
  String get trendsDaysInTarget => 'Giorni in linea';

  @override
  String get trendsEmpty =>
      'Nessun dato per questo periodo. Registra del cibo per vedere l\'andamento.';

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
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settingsTypeface => 'Carattere';

  @override
  String get typefaceDefault => 'Predefinito';

  @override
  String get typefaceLowVision => 'Leggibilità (ipovisione)';

  @override
  String get typefaceDyslexia => 'Dislessia';

  @override
  String get settingsLanguage => 'Lingua dell\'app';

  @override
  String get languageSystem => 'Predefinita di sistema';

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
      'Le lingue diverse dall\'inglese sono state tradotte automaticamente e possono risultare poco naturali.';

  @override
  String get dateToday => 'Oggi';

  @override
  String get dateYesterday => 'Ieri';

  @override
  String get dateTomorrow => 'Domani';

  @override
  String get dayPreviousDay => 'Giorno precedente';

  @override
  String get dayNextDay => 'Giorno successivo';

  @override
  String get dayAddFood => 'Aggiungi alimento';

  @override
  String get dayMealFromList => 'Pasto da un elenco di ingredienti';

  @override
  String get dayEmptyHint =>
      'Tocca + per iniziare un pasto.\nTutto ciò che aggiungi vi confluisce finché non tocchi ✓ (o passano 15 min).';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitTsp => 'cucchiaino';

  @override
  String get unitTbsp => 'cucchiaio';

  @override
  String get unitCup => 'tazza';

  @override
  String get macroProtein => 'Proteine';

  @override
  String get macroCarbs => 'Carboidrati';

  @override
  String get macroFat => 'Grassi';

  @override
  String targetOver(String kcal) {
    return '$kcal in più';
  }

  @override
  String targetToGo(String kcal) {
    return 'ancora $kcal';
  }

  @override
  String targetLeft(String kcal) {
    return '$kcal rimaste';
  }

  @override
  String get targetMinReached => 'minimo raggiunto';

  @override
  String targetRangeBoth(String min, String max) {
    return 'Obiettivo $min–$max kcal';
  }

  @override
  String targetRangeMax(String max) {
    return 'Obiettivo $max kcal';
  }

  @override
  String targetRangeMin(String min) {
    return 'Minimo $min kcal';
  }

  @override
  String get mealMenuEdit => 'Modifica pasto';

  @override
  String get mealMenuSplit => 'Distribuisci su più giorni';

  @override
  String get mealMenuScale => 'Ridimensiona pasto';

  @override
  String scaleMealApply(String pct) {
    return 'Ridimensiona al $pct%';
  }

  @override
  String scaleMealDone(String pct) {
    return 'Pasto ridimensionato al $pct%';
  }

  @override
  String get mealMenuSaveRecipe => 'Salva come ricetta';

  @override
  String get mealMenuDelete => 'Elimina pasto';

  @override
  String get mealFinish => 'Termina pasto';

  @override
  String get mealAddTo => 'Aggiungi a questo pasto';

  @override
  String get mealCollapse => 'Comprimi pasto';

  @override
  String get mealExpand => 'Espandi pasto';

  @override
  String mealSavedToRecipes(String name) {
    return '\"$name\" salvato nelle ricette';
  }

  @override
  String get editMealTitle => 'Modifica pasto';

  @override
  String get editMealName => 'Nome';

  @override
  String get editMealType => 'Tipo di pasto';

  @override
  String get editMealWhen => 'Quando';

  @override
  String recipeDeleteConfirm(String name) {
    return 'Eliminare “$name”?';
  }

  @override
  String get recipesTitle => 'Ricette';

  @override
  String get recipesEmpty =>
      'Ancora nessuna ricetta.\nCreane una per riutilizzare i pasti, condividerli o cucinare in grandi quantità e distribuire su più giorni.';

  @override
  String get recipeNew => 'Nuova ricetta';

  @override
  String recipeServings(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString porzioni',
      one: '$countString porzione',
    );
    return '$_temp0';
  }

  @override
  String recipeImported(String name) {
    return '\"$name\" importato';
  }

  @override
  String get qrNotRecipe => 'Non è una ricetta valida.';

  @override
  String get createBuildManually => 'Crea manualmente';

  @override
  String get createBuildManuallySub => 'Aggiungi gli ingredienti uno per uno';

  @override
  String get createFromList => 'Da un elenco di ingredienti';

  @override
  String get createFromListSub =>
      'Fotografa un elenco stampato — salvalo o registralo come pasto';

  @override
  String get createFromQr => 'Importa da codice QR';

  @override
  String get createFromQrSub => 'Scansiona una ricetta condivisa';

  @override
  String genericError(String error) {
    return 'Errore: $error';
  }

  @override
  String get couldNotOpenLink => 'Impossibile aprire il link';

  @override
  String get settingsTargets => 'Obiettivi';

  @override
  String get settingsTargetsSub => 'Obiettivi di calorie e macro, al giorno';

  @override
  String get metricCalories => 'Calorie';

  @override
  String get settingsTargetsHelp =>
      'Imposta un minimo, un massimo o entrambi. Un minimo aiuta se devi assicurarti di mangiare abbastanza. Lascia vuoto per usare il valore predefinito.';

  @override
  String get settingsTargetDefault => 'Predefinito';

  @override
  String get settingsTargetMin => 'min';

  @override
  String get settingsTargetMax => 'max';

  @override
  String get settingsCustomizePerDay => 'Personalizza per giorno';

  @override
  String get settingsCustomizePerDaySub =>
      'I giorni di allenamento e i fine settimana possono differire';

  @override
  String get settingsLogging => 'Registrazione';

  @override
  String get settingsMealTimes => 'Orari dei pasti';

  @override
  String get settingsMealTimesSub =>
      'Nomina ogni pasto in base all\'ora di registrazione';

  @override
  String get settingsMealTimesHelp =>
      'Un nuovo pasto prende il nome dalla fascia oraria in cui ricade il suo primo elemento (es. \"Colazione 08:23\"). Tutto ciò che è fuori da queste fasce è uno spuntino. Puoi sempre rinominare un pasto.';

  @override
  String get settingsFoodData => 'Dati alimentari';

  @override
  String get settingsOfflineRegions => 'Regioni offline';

  @override
  String get settingsOfflineRegionsSub =>
      'Scarica i database di prodotti per paese per la ricerca offline';

  @override
  String settingsHealthConnect(String store) {
    return '$store';
  }

  @override
  String settingsHealthSync(String store) {
    return 'Sincronizza con $store';
  }

  @override
  String settingsHealthSyncSub(String store) {
    return 'Scrivi calorie e macro registrate in $store';
  }

  @override
  String get settingsHealthTimeNote =>
      'Le voci si sincronizzano all\'ora di registrazione';

  @override
  String get settingsHealthTimeNoteSub =>
      'Retrodata un pasto dal suo menu ⋮ per cambiarne l\'ora.';

  @override
  String get settingsDataBackup => 'Dati e backup';

  @override
  String get settingsExport => 'Esporta backup';

  @override
  String get settingsExportSub => 'Condividi uno .zip (JSON + CSV)';

  @override
  String get settingsImport => 'Importa backup';

  @override
  String get settingsImportSub =>
      'Ripristina da uno .zip (sostituisce tutti i dati)';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get settingsContactDev => 'Contatta lo sviluppatore';

  @override
  String get settingsContactDevSub =>
      'Invia feedback o una segnalazione via e-mail (con info app e dispositivo)';

  @override
  String settingsContactDevNoApp(String email) {
    return 'Nessuna app e-mail trovata. Scrivi a $email';
  }

  @override
  String get settingsAboutBody =>
      'Senza pubblicità, senza abbonamenti. Dati alimentari da Open Food Facts (© contributori Open Food Facts, ODbL) e dalla Banca dati svizzera dei valori nutritivi (Ufficio federale della sicurezza alimentare e di veterinaria, USAV). Dimensioni delle porzioni basate su USDA FoodData Central (dominio pubblico). Il riconoscimento foto sul dispositivo usa il modello AIY food_V1 di Google (Apache 2.0). Tocca “Mostra licenze” per i componenti open source.';

  @override
  String get offThanksTitle => 'Grazie a Open Food Facts';

  @override
  String get offThanksBody =>
      'Knabberfuchs si basa su Open Food Facts — un database alimentare gratuito, aperto e collaborativo, mantenuto vivo da volontari di tutto il mondo. Senza il loro lavoro, questa app semplicemente non esisterebbe.\n\nSe Knabberfuchs ti è utile, valuta di sostenerli.';

  @override
  String get offDonate => 'Dona a Open Food Facts';

  @override
  String healthSyncOff(String store) {
    return 'Sincronizzazione $store disattivata.';
  }

  @override
  String healthUnavailable(String store) {
    return '$store non è disponibile su questo dispositivo.';
  }

  @override
  String healthNoPermission(String store) {
    return 'L\'autorizzazione a $store non è stata concessa.';
  }

  @override
  String healthSyncOn(String store) {
    return 'Sincronizzazione $store attiva — oggi inviato.';
  }

  @override
  String backupExportFailed(String error) {
    return 'Esportazione non riuscita: $error';
  }

  @override
  String get backupFileType => 'Backup';

  @override
  String get backupReplaceTitle => 'Sostituire tutti i dati?';

  @override
  String get backupReplaceBody =>
      'L\'importazione sostituirà le voci attuali, gli alimenti personalizzati, le ricette, gli obiettivi e le impostazioni con il contenuto del backup.';

  @override
  String get backupRestored => 'Backup ripristinato.';

  @override
  String backupImportFailed(String error) {
    return 'Importazione non riuscita: $error';
  }

  @override
  String get amountLabel => 'Quantità';

  @override
  String get editEntryTitle => 'Modifica voce';

  @override
  String kcalPer100(String kcal) {
    return '$kcal kcal / 100 g';
  }

  @override
  String volumeApprox(String grams) {
    return '≈ $grams g (assume ~1 g/ml)';
  }

  @override
  String volumeDensity(String grams, String density) {
    return '≈ $grams g · $density g/ml';
  }

  @override
  String oneServing(String grams) {
    return '1 porzione ($grams g)';
  }

  @override
  String portionChip(String unit, String grams) {
    return '1 $unit · $grams g';
  }

  @override
  String get portionUnitPiece => 'pezzo';

  @override
  String get portionUnitSmall => 'piccolo';

  @override
  String get portionUnitMedium => 'medio';

  @override
  String get portionUnitLarge => 'grande';

  @override
  String get portionUnitSlice => 'fetta';

  @override
  String get portionUnitClove => 'spicchio';

  @override
  String get portionUnitStalk => 'gambo';

  @override
  String get portionUnitHandful => 'manciata';

  @override
  String get portionUnitCob => 'pannocchia';

  @override
  String get searchFoodsHint => 'Cerca alimenti…';

  @override
  String get searchRecentlyUsed => 'Usati di recente';

  @override
  String get createCustomFood => 'Crea alimento personalizzato';

  @override
  String get searchEmptyPrompt =>
      'Cerca un alimento, scansiona un codice a barre\no crea il tuo.';

  @override
  String searchNoMatches(String query) {
    return 'Nessun risultato per \"$query\".';
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
  String get sourceCustom => 'Personalizzato';

  @override
  String get sourceSwiss => 'Banca dati CH';

  @override
  String get sourceContributed => 'Aggiunto da te';

  @override
  String get quickAdd => 'Aggiunta rapida';

  @override
  String quickAddNamed(String name) {
    return 'Aggiunta rapida \"$name\"';
  }

  @override
  String get quickAddSubtitle => 'Registra solo nome e calorie';

  @override
  String get quickAddName => 'Nome';

  @override
  String get quickAddCalories => 'Calorie';

  @override
  String get quickAddWeight => 'Peso';

  @override
  String get quickAddMacros => 'Aggiungi macro (facoltativo)';

  @override
  String get recognizeTooltip => 'Riconosci da foto';

  @override
  String get recognizeTakePhoto => 'Scatta una foto';

  @override
  String get recognizeLooksLike => 'Sembra…';

  @override
  String get recognizeNoneManual => 'Nessuno di questi – inserisci manualmente';

  @override
  String get recognizeNoGuess =>
      'Alimento non riconosciuto. Aggiungilo manualmente.';

  @override
  String get recognizeGeminiNudge =>
      'Suggerimento: aggiungi una chiave Gemini gratuita nelle Impostazioni per risultati migliori, incluse le bevande che il modello sul dispositivo non riconosce.';

  @override
  String get dayCaptureTooltip => 'Aggiungi da una foto';

  @override
  String get captureScanAi => 'Scansiona un pasto con l\'IA';

  @override
  String get captureScanAiSub =>
      'Fotografa un piatto — indoviniamo piatto e calorie';

  @override
  String get foodFormTitle => 'Nuovo alimento';

  @override
  String get barcodeField => 'Codice a barre (facoltativo)';

  @override
  String get settingsAi => 'Riconoscimento IA';

  @override
  String get aiKeyDesc =>
      'Le foto vengono riconosciute sul telefono per impostazione predefinita. Aggiungi una chiave API Google Gemini per risultati più precisi e stime delle porzioni. La foto viene quindi inviata a Google. Il piano gratuito di Gemini è sufficiente per l\'uso personale; se hai attivato la fatturazione sul tuo account Google, un uso intenso può comportare costi. Nel piano gratuito Google può usare le tue foto per migliorare i propri modelli.';

  @override
  String get aiKeyLabel => 'Chiave API Gemini';

  @override
  String get aiKeyGet => 'Ottieni una chiave API';

  @override
  String get aiModelLabel => 'Modello IA';

  @override
  String get aiModelReliable => 'Gemini 2.5 Flash — affidabile';

  @override
  String get aiModelAccurate =>
      'Gemini 3.5 Flash — più preciso, spesso occupato';

  @override
  String get aiModelNote =>
      'Se il tuo modello è occupato, passa a 2.5 Flash e poi al dispositivo.';

  @override
  String get aiOnDeviceOnlyTitle => 'Riconosci sempre sul dispositivo';

  @override
  String get aiOnDeviceOnlySubtitle =>
      'Non inviare mai foto a Gemini — usa il modello sul dispositivo per ogni scansione.';

  @override
  String get recognizeByGemini => 'Stimato da Gemini';

  @override
  String get geminiHintTitle => 'Descrivi il pasto (facoltativo)';

  @override
  String get geminiHintLabel => 'Aggiungi un suggerimento';

  @override
  String get geminiHintExample => 'es. lasagne fatte in casa, porzione grande';

  @override
  String get geminiHintEstimate => 'Stima';

  @override
  String get a11yPreviousPeriod => 'Periodo precedente';

  @override
  String get a11yNextPeriod => 'Periodo successivo';

  @override
  String get a11yClearSearch => 'Cancella ricerca';

  @override
  String get a11yShowApiKey => 'Mostra chiave';

  @override
  String get a11yHideApiKey => 'Nascondi chiave';

  @override
  String get a11yRemoveIngredient => 'Rimuovi ingrediente';

  @override
  String get a11yDecrease => 'Diminuisci';

  @override
  String get a11yIncrease => 'Aumenta';

  @override
  String get a11yAnalysing => 'Analisi…';

  @override
  String get a11yChangeDate => 'Cambia data';

  @override
  String get a11ySelectedPhoto => 'Foto del pasto selezionata';

  @override
  String get a11yTrendsChart => 'Grafico dell\'andamento per il periodo scelto';

  @override
  String a11yQrCode(String name) {
    return 'Codice QR per la ricetta $name';
  }

  @override
  String get recognizeByOnDevice => 'Stimato sul dispositivo';

  @override
  String get geminiFailed =>
      'Gemini non raggiungibile — usato il riconoscimento sul dispositivo.';

  @override
  String get geminiThinking1 => 'Richiesta delle calorie a Gemini…';

  @override
  String get geminiThinking2 => 'Stima delle calorie dalla tua foto…';

  @override
  String get geminiThinking3 => 'Identificazione del piatto…';

  @override
  String get geminiThinking4 => 'Calcolo della porzione…';

  @override
  String get geminiThinking5 => 'Lettura del piatto…';

  @override
  String get geminiThinking6 => 'Calcolo dei numeri…';

  @override
  String get geminiSlow => 'Gemini è un po\' occupato — un attimo…';

  @override
  String geminiRetrying(int n) {
    return 'Server occupato — nuovo tentativo ($n)…';
  }

  @override
  String get scanBarcode => 'Scansiona codice a barre';

  @override
  String get selectFood => 'Seleziona alimento';

  @override
  String get addIngredient => 'Aggiungi ingrediente';

  @override
  String get ingredients => 'Ingredienti';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionShare => 'Condividi';

  @override
  String get actionSet => 'Imposta';

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
    return '$kcal kcal totali';
  }

  @override
  String loggedTo(String day) {
    return 'Registrato per $day';
  }

  @override
  String get recipeEdit => 'Modifica ricetta';

  @override
  String get recipeNeedName => 'Dai un nome alla ricetta.';

  @override
  String get recipeNeedIngredient => 'Aggiungi almeno un ingrediente.';

  @override
  String get recipeName => 'Nome della ricetta';

  @override
  String get recipeServingsField => 'Porzioni (che questa ricetta produce)';

  @override
  String get recipeLogPortion => 'Registra una porzione per un giorno';

  @override
  String get recipeWhole => 'Ricetta intera';

  @override
  String recipePerServing(String count) {
    return 'Per porzione ($count)';
  }

  @override
  String get recipeLogPortionTitle => 'Registra una porzione';

  @override
  String get recipePortions => 'Porzioni';

  @override
  String recipeLogToDay(String day) {
    return 'Registra per $day';
  }

  @override
  String shareTitle(String name) {
    return 'Condividi \"$name\"';
  }

  @override
  String get shareScanHint =>
      'Scansiona questo su un altro telefono in \"Importa da QR\".';

  @override
  String get shareAsImage => 'Condividi immagine';

  @override
  String get createFromText => 'Importa da testo';

  @override
  String get createFromTextSub => 'Incolla una ricetta ricevuta';

  @override
  String get importTextTitle => 'Incolla ricetta';

  @override
  String get importTextHint => 'Codice ricetta…';

  @override
  String get shareAsText => 'Condividi come testo';

  @override
  String shareMeta(int ingredients, num servings, String bytes) {
    final intl.NumberFormat servingsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String servingsString = servingsNumberFormat.format(servings);

    String _temp0 = intl.Intl.pluralLogic(
      ingredients,
      locale: localeName,
      other: '$ingredients ingredienti',
      one: '$ingredients ingrediente',
    );
    String _temp1 = intl.Intl.pluralLogic(
      servings,
      locale: localeName,
      other: '$servingsString porzioni',
      one: '$servingsString porzione',
    );
    return '$_temp0 · $_temp1 · $bytes byte';
  }

  @override
  String shareSubject(String name) {
    return 'Ricetta: $name';
  }

  @override
  String get ocrNoIngredients =>
      'Nessun ingrediente trovato in quelle immagini.';

  @override
  String get ocrDefaultMealName => 'Pasto da foto';

  @override
  String get ocrNeedMatch => 'Associa prima almeno un ingrediente.';

  @override
  String get ocrSavedToRecipes => 'Salvato nelle ricette';

  @override
  String get ocrReviewTitle => 'Verifica pasto';

  @override
  String get ocrSaveAsRecipe => 'Salva come ricetta';

  @override
  String get ocrLogToDay => 'Registra per un giorno';

  @override
  String get ocrMealName => 'Nome del pasto';

  @override
  String ocrMatched(String matched, String total) {
    return '$matched / $total associati';
  }

  @override
  String get ocrSwipeHint =>
      'Scorri → per scegliere un alimento, ← per rimuovere.';

  @override
  String ocrFromSource(String amount, String name) {
    return '$amount · da \"$name\"';
  }

  @override
  String ocrPickHintSub(String amount) {
    return '$amount · scorri → per scegliere un alimento';
  }

  @override
  String kcalGrams(String kcal, String grams) {
    return '$kcal kcal\n$grams g';
  }

  @override
  String get ocrSetGrams => 'imposta g';

  @override
  String kcalDotGrams(String kcal, String grams) {
    return '$kcal kcal · $grams g';
  }

  @override
  String macroPcf(String kcal, String protein, String carb, String fat) {
    return '$kcal kcal · P $protein  C $carb  G $fat';
  }

  @override
  String get manualTitle => 'Alimento personalizzato';

  @override
  String get manualNameRequired => 'Nome *';

  @override
  String get manualBrandOptional => 'Marca (facoltativo)';

  @override
  String get manualPer100 => 'Per 100 g';

  @override
  String get manualCalories => 'Calorie (kcal) *';

  @override
  String get manualProtein => 'Proteine (g)';

  @override
  String get manualCarbs => 'Carboidrati (g)';

  @override
  String get manualFat => 'Grassi (g)';

  @override
  String get manualServing => 'Dimensione porzione (g, facoltativo)';

  @override
  String get manualSaveFood => 'Salva alimento';

  @override
  String get manualRequired => 'Obbligatorio';

  @override
  String get manualInvalidNumber => 'Numero non valido';

  @override
  String get addProductTitle => 'Aggiungi prodotto';

  @override
  String get addPhotoOfTable => 'Scatta una foto della tabella nutrizionale';

  @override
  String get addChooseGallery => 'Scegli dalla galleria';

  @override
  String get addNameEnergyRequired =>
      'Sono richiesti un nome e l\'energia (kcal/100 g).';

  @override
  String addBarcodeLabel(String code) {
    return 'Codice a barre $code';
  }

  @override
  String get addProductName => 'Nome del prodotto';

  @override
  String get addServingSize => 'Dimensione porzione';

  @override
  String get addNutritionPer100 => 'Valori nutrizionali per 100 g';

  @override
  String get addNutritionPer100Ml => 'Valori nutrizionali per 100 ml';

  @override
  String get addScanLabel => 'Scansiona etichetta';

  @override
  String get addEnergy => 'Energia';

  @override
  String get addProtein => 'Proteine';

  @override
  String get addCarbohydrate => 'Carboidrati';

  @override
  String get addFat => 'Grassi';

  @override
  String get addSugars => 'di cui zuccheri';

  @override
  String get addSaturates => 'di cui acidi grassi saturi';

  @override
  String get addFibre => 'Fibre';

  @override
  String get addSalt => 'Sale';

  @override
  String get offContributeTitle => 'Contribuisci a Open Food Facts';

  @override
  String get offContributeBody =>
      'Apri questo codice a barre su Open Food Facts per aggiungere il prodotto. Serve un account gratuito, ma è veloce e utile a tutti — la prossima persona che lo scansiona troverà una corrispondenza.';

  @override
  String get offContributeAction => 'Apri in Open Food Facts';

  @override
  String get addFilledFromLabel =>
      'Compilato dall\'etichetta — controlla i valori.';

  @override
  String get addCouldntRead =>
      'Impossibile leggere la tabella. Inserisci i valori manualmente.';

  @override
  String get backupShareSubject => 'Backup Knabberfuchs';

  @override
  String get scanRecipeQr => 'Scansiona QR ricetta';

  @override
  String get splashPreparing => 'Preparazione del database alimentare…';

  @override
  String get scanEnterBarcode => 'Inserisci codice a barre';

  @override
  String get scanExampleHint => 'es. 3017620422003';

  @override
  String get scanLookUp => 'Cerca';

  @override
  String get scanEnterManually => 'Inserisci manualmente';

  @override
  String get scanTorch => 'Attiva/disattiva flash';

  @override
  String get scanCameraOnlyDevice =>
      'La scansione con fotocamera è disponibile solo su un dispositivo.';

  @override
  String get scanCameraFailed => 'Impossibile avviare la fotocamera.';

  @override
  String get scanEnterManuallyButton =>
      'Inserisci il codice a barre manualmente';

  @override
  String splitTitle(String name) {
    return 'Distribuisci \"$name\"';
  }

  @override
  String get splitDescription =>
      'Dividi questo pasto in porzioni uguali, una al giorno. L\'originale viene sostituito.';

  @override
  String splitKcalEach(String kcal) {
    return '$kcal kcal ciascuna';
  }

  @override
  String splitInto(String n) {
    return 'Distribuisci su $n giorni';
  }

  @override
  String get cropTitle => 'Ritaglia sulla tabella';

  @override
  String get cropDone => 'Fatto';

  @override
  String get offlineReminderText =>
      'Cercato online — scarica la tua regione per scansioni offline più veloci.';

  @override
  String get offlineReminderAction => 'Regioni';

  @override
  String regionDownloaded(String name) {
    return '$name scaricato';
  }

  @override
  String regionDownloadFailed(String error) {
    return 'Download non riuscito: $error';
  }

  @override
  String regionRemoved(String name) {
    return '$name rimosso';
  }

  @override
  String get regionLoadError => 'Impossibile caricare l\'elenco delle regioni.';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get regionIntro =>
      'Scarica un paese per cercarne i prodotti confezionati offline. Puoi scaricarne diversi.';

  @override
  String get regionSearchHint => 'Cerca paesi';

  @override
  String regionNoMatch(String query) {
    return 'Nessun paese corrisponde a \"$query\".';
  }

  @override
  String get regionTooltipDownload => 'Scarica';

  @override
  String get regionTooltipRemove => 'Rimuovi';

  @override
  String get regionUpdate => 'Aggiorna';

  @override
  String regionSubtitle(String products, String size) {
    return '${products}k prodotti · $size da scaricare';
  }

  @override
  String regionSubtitleInstalled(String base) {
    return '$base · installato';
  }

  @override
  String regionSubtitleUpdatable(String base) {
    return '$base · aggiornamento disponibile';
  }
}
