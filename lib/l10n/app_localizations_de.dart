// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Knabberfuchs';

  @override
  String get navDay => 'Tag';

  @override
  String get navRecipes => 'Rezepte';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navTrends => 'Verlauf';

  @override
  String get settingsDisplay => 'Anzeige';

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get settingsTracking => 'Tracking';

  @override
  String get settingsShowTrends => 'Verlauf-Tab anzeigen';

  @override
  String get settingsShowTrendsSub =>
      'Einen Tab mit wöchentlichen und monatlichen Kaloriendiagrammen hinzufügen';

  @override
  String get trendsWeek => 'Woche';

  @override
  String get trendsMonth => 'Monat';

  @override
  String get trendsCustom => 'Eigen';

  @override
  String get trendsWeeklyAvg => 'Wochendurchschnitt';

  @override
  String get trendsMonthlyAvg => 'Monatsdurchschnitt';

  @override
  String get trendsAvgPerDay => 'Ø pro Tag';

  @override
  String get trendsDaysInTarget => 'Tage im Ziel';

  @override
  String get trendsEmpty =>
      'Noch keine Einträge in diesem Zeitraum. Erfasse etwas, um deinen Verlauf zu sehen.';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionImport => 'Importieren';

  @override
  String get settingsSectionLanguage => 'Sprache';

  @override
  String get settingsTheme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get settingsTypeface => 'Schriftart';

  @override
  String get typefaceDefault => 'Standard';

  @override
  String get typefaceLowVision => 'Bessere Lesbarkeit (Sehschwäche)';

  @override
  String get typefaceDyslexia => 'Legasthenie';

  @override
  String get settingsLanguage => 'App-Sprache';

  @override
  String get languageSystem => 'Systemstandard';

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
      'Andere Sprachen als Englisch wurden maschinell übersetzt und können holprig klingen.';

  @override
  String get dateToday => 'Heute';

  @override
  String get dateYesterday => 'Gestern';

  @override
  String get dateTomorrow => 'Morgen';

  @override
  String get dayPreviousDay => 'Vorheriger Tag';

  @override
  String get dayNextDay => 'Nächster Tag';

  @override
  String get dayAddFood => 'Essen hinzufügen';

  @override
  String get dayMealFromList => 'Mahlzeit aus einer Zutatenliste';

  @override
  String get dayEmptyHint =>
      'Tippe auf +, um eine Mahlzeit zu beginnen.\nAlles, was du hinzufügst, fließt hinein, bis du auf ✓ tippst (oder 15 Min. vergehen).';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitTsp => 'TL';

  @override
  String get unitTbsp => 'EL';

  @override
  String get unitCup => 'Tasse';

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarbs => 'Kohlenhydrate';

  @override
  String get macroFat => 'Fett';

  @override
  String targetOver(String kcal) {
    return '$kcal darüber';
  }

  @override
  String targetToGo(String kcal) {
    return 'noch $kcal';
  }

  @override
  String targetLeft(String kcal) {
    return '$kcal übrig';
  }

  @override
  String get targetMinReached => 'Minimum erreicht';

  @override
  String targetRangeBoth(String min, String max) {
    return 'Ziel $min–$max kcal';
  }

  @override
  String targetRangeMax(String max) {
    return 'Ziel $max kcal';
  }

  @override
  String targetRangeMin(String min) {
    return 'Minimum $min kcal';
  }

  @override
  String get mealMenuEdit => 'Mahlzeit bearbeiten';

  @override
  String get mealMenuSplit => 'Auf mehrere Tage aufteilen';

  @override
  String get mealMenuScale => 'Mahlzeit skalieren';

  @override
  String scaleMealApply(String pct) {
    return 'Auf $pct% skalieren';
  }

  @override
  String scaleMealDone(String pct) {
    return 'Mahlzeit auf $pct% skaliert';
  }

  @override
  String get mealMenuSaveRecipe => 'Als Rezept speichern';

  @override
  String get mealMenuDelete => 'Mahlzeit löschen';

  @override
  String get mealFinish => 'Mahlzeit abschließen';

  @override
  String get mealAddTo => 'Zu dieser Mahlzeit hinzufügen';

  @override
  String get mealCollapse => 'Mahlzeit einklappen';

  @override
  String get mealExpand => 'Mahlzeit ausklappen';

  @override
  String mealSavedToRecipes(String name) {
    return '\"$name\" in Rezepten gespeichert';
  }

  @override
  String get editMealTitle => 'Mahlzeit bearbeiten';

  @override
  String get editMealName => 'Name';

  @override
  String get editMealType => 'Art der Mahlzeit';

  @override
  String get editMealWhen => 'Wann';

  @override
  String recipeDeleteConfirm(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get recipesTitle => 'Rezepte';

  @override
  String get recipesEmpty =>
      'Noch keine Rezepte.\nErstelle eines, um Mahlzeiten wiederzuverwenden, zu teilen oder auf Vorrat zu kochen und auf mehrere Tage aufzuteilen.';

  @override
  String get recipeNew => 'Neues Rezept';

  @override
  String recipeServings(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Portionen',
      one: '$countString Portion',
    );
    return '$_temp0';
  }

  @override
  String recipeImported(String name) {
    return '\"$name\" importiert';
  }

  @override
  String get qrNotRecipe => 'Das ist kein gültiges Rezept.';

  @override
  String get createBuildManually => 'Manuell erstellen';

  @override
  String get createBuildManuallySub => 'Zutaten einzeln hinzufügen';

  @override
  String get createFromList => 'Aus einer Zutatenliste';

  @override
  String get createFromListSub =>
      'Eine gedruckte Liste fotografieren — speichern oder als Mahlzeit erfassen';

  @override
  String get createFromQr => 'Aus QR-Code importieren';

  @override
  String get createFromQrSub => 'Ein geteiltes Rezept scannen';

  @override
  String genericError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get couldNotOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String get settingsTargets => 'Ziele';

  @override
  String get settingsTargetsSub => 'Kalorien- und Makroziele, pro Tag';

  @override
  String get metricCalories => 'Kalorien';

  @override
  String get settingsTargetsHelp =>
      'Lege ein Minimum, ein Maximum oder beides fest. Ein Minimum hilft, wenn du sicherstellen möchtest, genug zu essen. Leer lassen, um den Standard zu verwenden.';

  @override
  String get settingsTargetDefault => 'Standard';

  @override
  String get settingsTargetMin => 'Min.';

  @override
  String get settingsTargetMax => 'Max.';

  @override
  String get settingsCustomizePerDay => 'Pro Tag anpassen';

  @override
  String get settingsCustomizePerDaySub =>
      'Trainingstage und Wochenenden können sich unterscheiden';

  @override
  String get settingsLogging => 'Erfassung';

  @override
  String get settingsMealTimes => 'Mahlzeiten-Zeiten';

  @override
  String get settingsMealTimesSub =>
      'Benennt jede Mahlzeit nach der Uhrzeit der Erfassung';

  @override
  String get settingsMealTimesHelp =>
      'Eine neue Mahlzeit wird nach dem Zeitfenster benannt, in das ihr erstes Element fällt (z. B. \"Frühstück 08:23\"). Alles außerhalb dieser Fenster ist ein Snack. Du kannst eine Mahlzeit jederzeit umbenennen.';

  @override
  String get settingsFoodData => 'Lebensmitteldaten';

  @override
  String get settingsOfflineRegions => 'Offline-Regionen';

  @override
  String get settingsOfflineRegionsSub =>
      'Länder-Produktdatenbanken für die Offline-Suche herunterladen';

  @override
  String settingsHealthConnect(String store) {
    return '$store';
  }

  @override
  String settingsHealthSync(String store) {
    return 'Mit $store synchronisieren';
  }

  @override
  String settingsHealthSyncSub(String store) {
    return 'Erfasste Kalorien & Makros in $store schreiben';
  }

  @override
  String get settingsHealthTimeNote =>
      'Einträge werden zur Erfassungszeit synchronisiert';

  @override
  String get settingsHealthTimeNoteSub =>
      'Datiere eine Mahlzeit über ihr ⋮-Menü zurück, um ihre Zeit zu ändern.';

  @override
  String get settingsDataBackup => 'Daten & Backup';

  @override
  String get settingsExport => 'Backup exportieren';

  @override
  String get settingsExportSub => 'Eine .zip teilen (JSON + CSV)';

  @override
  String get settingsImport => 'Backup importieren';

  @override
  String get settingsImportSub =>
      'Aus einer .zip wiederherstellen (ersetzt alle Daten)';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsContactDev => 'Entwickler kontaktieren';

  @override
  String get settingsContactDevSub =>
      'Feedback oder Fehlerbericht per E-Mail (mit App- & Geräteinfos)';

  @override
  String settingsContactDevNoApp(String email) {
    return 'Keine E-Mail-App gefunden. Schreib an $email';
  }

  @override
  String get settingsAboutBody =>
      'Werbefrei, keine Abos. Lebensmitteldaten von Open Food Facts (© Open Food Facts contributors, ODbL) und der Schweizer Nährwertdatenbank (Bundesamt für Lebensmittelsicherheit und Veterinärwesen, BLV). Portionsgrössen basierend auf USDA FoodData Central (gemeinfrei). Die Foto-Erkennung auf dem Gerät nutzt Googles AIY-food_V1-Modell (Apache 2.0). Tippe auf „Lizenzen anzeigen“ für die Open-Source-Komponenten.';

  @override
  String get offThanksTitle => 'Dank an Open Food Facts';

  @override
  String get offThanksBody =>
      'Knabberfuchs basiert auf Open Food Facts — einer kostenlosen, offenen, gemeinschaftlich gepflegten Lebensmitteldatenbank, die von Freiwilligen auf der ganzen Welt am Leben gehalten wird. Ohne ihre Arbeit würde es diese App schlicht nicht geben.\n\nWenn dir Knabberfuchs nützlich ist, denk bitte darüber nach, sie zu unterstützen.';

  @override
  String get offDonate => 'An Open Food Facts spenden';

  @override
  String healthSyncOff(String store) {
    return '$store-Synchronisierung deaktiviert.';
  }

  @override
  String healthUnavailable(String store) {
    return '$store ist auf diesem Gerät nicht verfügbar.';
  }

  @override
  String healthNoPermission(String store) {
    return '$store-Berechtigung wurde nicht erteilt.';
  }

  @override
  String healthSyncOn(String store) {
    return '$store-Synchronisierung aktiv — heute übertragen.';
  }

  @override
  String backupExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get backupFileType => 'Backup';

  @override
  String get backupReplaceTitle => 'Alle Daten ersetzen?';

  @override
  String get backupReplaceBody =>
      'Beim Import werden deine aktuellen Einträge, eigenen Lebensmittel, Rezepte, Ziele und Einstellungen durch den Backup-Inhalt ersetzt.';

  @override
  String get backupRestored => 'Backup wiederhergestellt.';

  @override
  String backupImportFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get amountLabel => 'Menge';

  @override
  String get editEntryTitle => 'Eintrag bearbeiten';

  @override
  String kcalPer100(String kcal) {
    return '$kcal kcal / 100 g';
  }

  @override
  String volumeApprox(String grams) {
    return '≈ $grams g (angenommen ~1 g/ml)';
  }

  @override
  String volumeDensity(String grams, String density) {
    return '≈ $grams g · $density g/ml';
  }

  @override
  String oneServing(String grams) {
    return '1 Portion ($grams g)';
  }

  @override
  String portionChip(String unit, String grams) {
    return '1 $unit · $grams g';
  }

  @override
  String get portionUnitPiece => 'Stück';

  @override
  String get portionUnitSmall => 'klein';

  @override
  String get portionUnitMedium => 'mittelgross';

  @override
  String get portionUnitLarge => 'gross';

  @override
  String get portionUnitSlice => 'Scheibe';

  @override
  String get portionUnitClove => 'Zehe';

  @override
  String get portionUnitStalk => 'Stange';

  @override
  String get portionUnitHandful => 'Handvoll';

  @override
  String get portionUnitCob => 'Kolben';

  @override
  String get searchFoodsHint => 'Lebensmittel suchen…';

  @override
  String get searchRecentlyUsed => 'Zuletzt verwendet';

  @override
  String get createCustomFood => 'Eigenes Lebensmittel erstellen';

  @override
  String get searchEmptyPrompt =>
      'Suche nach einem Lebensmittel, scanne einen Barcode\noder erstelle dein eigenes.';

  @override
  String searchNoMatches(String query) {
    return 'Keine Treffer für \"$query\".';
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
  String get sourceCustom => 'Eigenes';

  @override
  String get sourceSwiss => 'Schweizer DB';

  @override
  String get sourceContributed => 'Von dir hinzugefügt';

  @override
  String get quickAdd => 'Schnell hinzufügen';

  @override
  String quickAddNamed(String name) {
    return '„$name“ schnell hinzufügen';
  }

  @override
  String get quickAddSubtitle => 'Nur Name und Kalorien erfassen';

  @override
  String get quickAddName => 'Name';

  @override
  String get quickAddCalories => 'Kalorien';

  @override
  String get quickAddWeight => 'Gewicht';

  @override
  String get quickAddMacros => 'Makros hinzufügen (optional)';

  @override
  String get recognizeTooltip => 'Per Foto erkennen';

  @override
  String get recognizeTakePhoto => 'Foto aufnehmen';

  @override
  String get recognizeLooksLike => 'Sieht aus wie…';

  @override
  String get recognizeNoneManual => 'Nichts davon – manuell eingeben';

  @override
  String get recognizeNoGuess => 'Essen nicht erkannt. Füge es manuell hinzu.';

  @override
  String get recognizeGeminiNudge =>
      'Tipp: Hinterlege in den Einstellungen einen kostenlosen Gemini-Schlüssel für bessere Ergebnisse – auch für Getränke, die das Gerätemodell nicht erkennt.';

  @override
  String get dayCaptureTooltip => 'Per Foto hinzufügen';

  @override
  String get captureScanAi => 'Mahlzeit mit KI scannen';

  @override
  String get captureScanAiSub =>
      'Fotografiere ein Gericht — wir schätzen es und die Kalorien';

  @override
  String get foodFormTitle => 'Neues Lebensmittel';

  @override
  String get barcodeField => 'Barcode (optional)';

  @override
  String get settingsAi => 'KI-Erkennung';

  @override
  String get aiKeyDesc =>
      'Fotos werden standardmäßig auf deinem Gerät erkannt. Füge einen Google-Gemini-API-Schlüssel hinzu für genauere Ergebnisse und Portionsschätzungen. Dein Foto wird dann an Google gesendet. Geminis kostenloser Tarif reicht für den privaten Gebrauch; wenn du in deinem Google-Konto die Abrechnung aktiviert hast, kann intensive Nutzung Kosten verursachen. Im kostenlosen Tarif kann Google deine Fotos zur Verbesserung seiner Modelle verwenden.';

  @override
  String get aiKeyLabel => 'Gemini-API-Schlüssel';

  @override
  String get aiKeyGet => 'API-Schlüssel holen';

  @override
  String get aiModelLabel => 'KI-Modell';

  @override
  String get aiModelReliable => 'Gemini 2.5 Flash — zuverlässig';

  @override
  String get aiModelAccurate => 'Gemini 3.5 Flash — schärfer, oft ausgelastet';

  @override
  String get aiModelNote =>
      'Wenn dein Modell ausgelastet ist, wird auf 2.5 Flash und dann auf das Gerät zurückgegriffen.';

  @override
  String get aiOnDeviceOnlyTitle => 'Immer auf dem Gerät erkennen';

  @override
  String get aiOnDeviceOnlySubtitle =>
      'Fotos nie an Gemini senden – für jeden Scan das Modell auf dem Gerät verwenden.';

  @override
  String get recognizeByGemini => 'Von Gemini geschätzt';

  @override
  String get geminiHintTitle => 'Mahlzeit beschreiben (optional)';

  @override
  String get geminiHintLabel => 'Hinweis hinzufügen';

  @override
  String get geminiHintExample => 'z. B. hausgemachte Lasagne, große Portion';

  @override
  String get geminiHintEstimate => 'Schätzen';

  @override
  String get a11yPreviousPeriod => 'Vorheriger Zeitraum';

  @override
  String get a11yNextPeriod => 'Nächster Zeitraum';

  @override
  String get a11yClearSearch => 'Suche löschen';

  @override
  String get a11yShowApiKey => 'Schlüssel anzeigen';

  @override
  String get a11yHideApiKey => 'Schlüssel verbergen';

  @override
  String get a11yRemoveIngredient => 'Zutat entfernen';

  @override
  String get a11yDecrease => 'Verringern';

  @override
  String get a11yIncrease => 'Erhöhen';

  @override
  String get a11yAnalysing => 'Analysiere…';

  @override
  String get a11yChangeDate => 'Datum ändern';

  @override
  String get a11ySelectedPhoto => 'Ausgewähltes Essensfoto';

  @override
  String get a11yTrendsChart => 'Trenddiagramm für den gewählten Zeitraum';

  @override
  String a11yQrCode(String name) {
    return 'QR-Code für Rezept $name';
  }

  @override
  String get recognizeByOnDevice => 'Auf dem Gerät geschätzt';

  @override
  String get geminiFailed =>
      'Gemini nicht erreichbar – Erkennung auf dem Gerät verwendet.';

  @override
  String get geminiThinking1 => 'Gemini wird nach Kalorien gefragt…';

  @override
  String get geminiThinking2 => 'Kalorien werden aus deinem Foto geschätzt…';

  @override
  String get geminiThinking3 => 'Gericht wird erkannt…';

  @override
  String get geminiThinking4 => 'Portionsgröße wird ermittelt…';

  @override
  String get geminiThinking5 => 'Teller wird gelesen…';

  @override
  String get geminiThinking6 => 'Zahlen werden berechnet…';

  @override
  String get geminiSlow => 'Gemini ist etwas ausgelastet – einen Moment…';

  @override
  String geminiRetrying(int n) {
    return 'Server ausgelastet – neuer Versuch (Versuch $n)…';
  }

  @override
  String get scanBarcode => 'Barcode scannen';

  @override
  String get selectFood => 'Lebensmittel auswählen';

  @override
  String get addIngredient => 'Zutat hinzufügen';

  @override
  String get ingredients => 'Zutaten';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionSet => 'Festlegen';

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
    return '$kcal kcal gesamt';
  }

  @override
  String loggedTo(String day) {
    return 'Erfasst für $day';
  }

  @override
  String get recipeEdit => 'Rezept bearbeiten';

  @override
  String get recipeNeedName => 'Gib dem Rezept einen Namen.';

  @override
  String get recipeNeedIngredient => 'Füge mindestens eine Zutat hinzu.';

  @override
  String get recipeName => 'Rezeptname';

  @override
  String get recipeServingsField => 'Portionen (die dieses Rezept ergibt)';

  @override
  String get recipeLogPortion => 'Portion für einen Tag erfassen';

  @override
  String get recipeWhole => 'Ganzes Rezept';

  @override
  String recipePerServing(String count) {
    return 'Pro Portion ($count)';
  }

  @override
  String get recipeLogPortionTitle => 'Eine Portion erfassen';

  @override
  String get recipePortions => 'Portionen';

  @override
  String recipeLogToDay(String day) {
    return 'Für $day erfassen';
  }

  @override
  String shareTitle(String name) {
    return '\"$name\" teilen';
  }

  @override
  String get shareScanHint =>
      'Scanne dies auf einem anderen Handy unter \"Aus QR importieren\".';

  @override
  String get shareAsImage => 'Bild teilen';

  @override
  String get createFromText => 'Aus Text importieren';

  @override
  String get createFromTextSub => 'Ein erhaltenes Rezept einfügen';

  @override
  String get importTextTitle => 'Rezept einfügen';

  @override
  String get importTextHint => 'Rezept-Code…';

  @override
  String get shareAsText => 'Als Text teilen';

  @override
  String shareMeta(int ingredients, num servings, String bytes) {
    final intl.NumberFormat servingsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String servingsString = servingsNumberFormat.format(servings);

    String _temp0 = intl.Intl.pluralLogic(
      ingredients,
      locale: localeName,
      other: '$ingredients Zutaten',
      one: '$ingredients Zutat',
    );
    String _temp1 = intl.Intl.pluralLogic(
      servings,
      locale: localeName,
      other: '$servingsString Portionen',
      one: '$servingsString Portion',
    );
    return '$_temp0 · $_temp1 · $bytes Bytes';
  }

  @override
  String shareSubject(String name) {
    return 'Rezept: $name';
  }

  @override
  String get ocrNoIngredients =>
      'In diesen Bildern wurden keine Zutaten gefunden.';

  @override
  String get ocrDefaultMealName => 'Mahlzeit vom Foto';

  @override
  String get ocrNeedMatch => 'Ordne zuerst mindestens eine Zutat zu.';

  @override
  String get ocrSavedToRecipes => 'In Rezepten gespeichert';

  @override
  String get ocrReviewTitle => 'Mahlzeit prüfen';

  @override
  String get ocrSaveAsRecipe => 'Als Rezept speichern';

  @override
  String get ocrLogToDay => 'Für Tag erfassen';

  @override
  String get ocrMealName => 'Name der Mahlzeit';

  @override
  String ocrMatched(String matched, String total) {
    return '$matched / $total zugeordnet';
  }

  @override
  String get ocrSwipeHint =>
      'Wische →, um ein Lebensmittel zu wählen, ←, um zu entfernen.';

  @override
  String ocrFromSource(String amount, String name) {
    return '$amount · aus \"$name\"';
  }

  @override
  String ocrPickHintSub(String amount) {
    return '$amount · wische →, um ein Lebensmittel zu wählen';
  }

  @override
  String kcalGrams(String kcal, String grams) {
    return '$kcal kcal\n$grams g';
  }

  @override
  String get ocrSetGrams => 'g festlegen';

  @override
  String kcalDotGrams(String kcal, String grams) {
    return '$kcal kcal · $grams g';
  }

  @override
  String macroPcf(String kcal, String protein, String carb, String fat) {
    return '$kcal kcal · P $protein  K $carb  F $fat';
  }

  @override
  String get manualTitle => 'Eigenes Lebensmittel';

  @override
  String get manualNameRequired => 'Name *';

  @override
  String get manualBrandOptional => 'Marke (optional)';

  @override
  String get manualPer100 => 'Pro 100 g';

  @override
  String get manualCalories => 'Kalorien (kcal) *';

  @override
  String get manualProtein => 'Protein (g)';

  @override
  String get manualCarbs => 'Kohlenhydrate (g)';

  @override
  String get manualFat => 'Fett (g)';

  @override
  String get manualServing => 'Portionsgröße (g, optional)';

  @override
  String get manualSaveFood => 'Lebensmittel speichern';

  @override
  String get manualRequired => 'Erforderlich';

  @override
  String get manualInvalidNumber => 'Ungültige Zahl';

  @override
  String get addProductTitle => 'Produkt hinzufügen';

  @override
  String get addPhotoOfTable => 'Foto der Nährwerttabelle aufnehmen';

  @override
  String get addChooseGallery => 'Aus Galerie wählen';

  @override
  String get addNameEnergyRequired =>
      'Name und Energie (kcal/100 g) sind erforderlich.';

  @override
  String addBarcodeLabel(String code) {
    return 'Barcode $code';
  }

  @override
  String get addProductName => 'Produktname';

  @override
  String get addServingSize => 'Portionsgröße';

  @override
  String get addNutritionPer100 => 'Nährwerte pro 100 g';

  @override
  String get addNutritionPer100Ml => 'Nährwerte pro 100 ml';

  @override
  String get addScanLabel => 'Etikett scannen';

  @override
  String get addEnergy => 'Energie';

  @override
  String get addProtein => 'Protein';

  @override
  String get addCarbohydrate => 'Kohlenhydrate';

  @override
  String get addFat => 'Fett';

  @override
  String get addSugars => 'davon Zucker';

  @override
  String get addSaturates => 'davon gesättigte Fettsäuren';

  @override
  String get addFibre => 'Ballaststoffe';

  @override
  String get addSalt => 'Salz';

  @override
  String get offContributeTitle => 'Zu Open Food Facts beitragen';

  @override
  String get offContributeBody =>
      'Öffne diesen Barcode bei Open Food Facts, um das Produkt hinzuzufügen. Dafür braucht es ein kostenloses Konto, aber es geht schnell und hilft allen – die nächste Person, die ihn scannt, erhält einen Treffer.';

  @override
  String get offContributeAction => 'In Open Food Facts öffnen';

  @override
  String get addFilledFromLabel =>
      'Vom Etikett übernommen — bitte die Werte prüfen.';

  @override
  String get addCouldntRead =>
      'Tabelle konnte nicht gelesen werden. Gib die Werte manuell ein.';

  @override
  String get backupShareSubject => 'Knabberfuchs-Backup';

  @override
  String get scanRecipeQr => 'Rezept-QR scannen';

  @override
  String get splashPreparing => 'Lebensmitteldatenbank wird vorbereitet…';

  @override
  String get scanEnterBarcode => 'Barcode eingeben';

  @override
  String get scanExampleHint => 'z. B. 3017620422003';

  @override
  String get scanLookUp => 'Nachschlagen';

  @override
  String get scanEnterManually => 'Manuell eingeben';

  @override
  String get scanTorch => 'Blitz umschalten';

  @override
  String get scanCameraOnlyDevice =>
      'Kamera-Scannen ist nur auf einem Gerät verfügbar.';

  @override
  String get scanCameraFailed => 'Kamera konnte nicht gestartet werden.';

  @override
  String get scanEnterManuallyButton => 'Barcode manuell eingeben';

  @override
  String splitTitle(String name) {
    return '\"$name\" aufteilen';
  }

  @override
  String get splitDescription =>
      'Teile diese Mahlzeit in gleiche Portionen, eine pro Tag. Das Original wird ersetzt.';

  @override
  String splitKcalEach(String kcal) {
    return 'je $kcal kcal';
  }

  @override
  String splitInto(String n) {
    return 'Auf $n Tage aufteilen';
  }

  @override
  String get cropTitle => 'Auf die Tabelle zuschneiden';

  @override
  String get cropDone => 'Fertig';

  @override
  String get offlineReminderText =>
      'Online nachgeschlagen — lade deine Region für schnellere Offline-Scans herunter.';

  @override
  String get offlineReminderAction => 'Regionen';

  @override
  String regionDownloaded(String name) {
    return '$name heruntergeladen';
  }

  @override
  String regionDownloadFailed(String error) {
    return 'Download fehlgeschlagen: $error';
  }

  @override
  String regionRemoved(String name) {
    return '$name entfernt';
  }

  @override
  String get regionLoadError => 'Regionsliste konnte nicht geladen werden.';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get regionIntro =>
      'Lade ein Land herunter, um seine verpackten Produkte offline zu durchsuchen. Du kannst mehrere herunterladen.';

  @override
  String get regionSearchHint => 'Länder suchen';

  @override
  String regionNoMatch(String query) {
    return 'Keine Länder passen zu \"$query\".';
  }

  @override
  String get regionTooltipDownload => 'Herunterladen';

  @override
  String get regionTooltipRemove => 'Entfernen';

  @override
  String get regionUpdate => 'Aktualisieren';

  @override
  String regionSubtitle(String products, String size) {
    return '${products}k Produkte · $size Download';
  }

  @override
  String regionSubtitleInstalled(String base) {
    return '$base · installiert';
  }

  @override
  String regionSubtitleUpdatable(String base) {
    return '$base · Update verfügbar';
  }
}
