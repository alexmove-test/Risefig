// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get continueGame => 'Weiter';

  @override
  String get noShuffleMoves =>
      'Kein Paar frei — versuche Rückgängig, einen Hinweis oder einen Magneten';

  @override
  String get shuffleLockedChallenge =>
      'Mischen ist bei dieser Herausforderung aus';

  @override
  String get specialTile => 'Zielkachel mit Stern';

  @override
  String continueWith(String title) {
    return 'Weiter · $title';
  }

  @override
  String get newPlot => 'Neues Grundstück';

  @override
  String get previousPlot => 'Vorheriges Grundstück';

  @override
  String get nextPlot => 'Nächstes Grundstück';

  @override
  String get plotLockedHint => 'Die nächsten Siege bauen dieses Grundstück';

  @override
  String neighborYard(String name) {
    return 'Hof von $name';
  }

  @override
  String neighborRating(String name, int rating) {
    return '$name · $rating';
  }

  @override
  String get neighboringCourtyard => 'Ein Nachbarhof';

  @override
  String get courtyardPanHint => 'Ziehen, um den Hof anzusehen';

  @override
  String houseStateTitle(int state, int total) {
    return 'Haus · $state/$total';
  }

  @override
  String get houseFullyUpgraded => 'Haus vollständig ausgebaut';

  @override
  String get houseDetailsShow => 'Details';

  @override
  String get houseDetailsHide => 'Ausblenden';

  @override
  String upgradeHouseForText(String price) {
    return 'Ausbauen für $price';
  }

  @override
  String pointsShortfallText(String amount) {
    return 'Noch $amount Punkte fehlen';
  }

  @override
  String houseUpgradeOfferText(String cost) {
    return 'Hausausbau · $cost';
  }

  @override
  String get nextHouseLook => 'Nächstes Aussehen des Hauses';

  @override
  String houseLookLine(int built, int total) {
    return 'Hausansichten gebaut: $built von $total';
  }

  @override
  String hubLevelUnlocksPet(int id) {
    return 'Level $id schaltet ein Tier frei';
  }

  @override
  String get hubQuestRewardReady => 'Die Wochenbelohnung ist bereit';

  @override
  String get hubThreeStarUntilReward =>
      'Ein 3★-Abschluss schaltet die Belohnung frei';

  @override
  String hubNeighborEvent(String name, String text) {
    return '$name: $text';
  }

  @override
  String hubHarvestReady(String plant) {
    return '$plant ist reif — jetzt ernten';
  }

  @override
  String get hubBedFree => 'Ein Beet ist frei — pflanze einen Samen';

  @override
  String get today => 'Heute';

  @override
  String get clearedToday => 'Heute geschafft';

  @override
  String streakNights(int n) {
    return 'Tag $n von 3';
  }

  @override
  String get streakKept => 'Drei Abende gehalten';

  @override
  String get streakAtRisk => 'Erlischt um Mitternacht';

  @override
  String get keepTheLight => 'Halte das Licht';

  @override
  String openedProgress(int unlocked, int total) {
    return '$unlocked/$total offen';
  }

  @override
  String get courtyard => 'Zum Hof';

  @override
  String get howToPlay => 'So wird gespielt';

  @override
  String get levels => 'Level';

  @override
  String get retry => 'Nochmal';

  @override
  String get playAgain => 'Nochmal spielen';

  @override
  String get next => 'Weiter';

  @override
  String get menu => 'Menü';

  @override
  String get close => 'Schließen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get back => 'Zurück';

  @override
  String get privacyPolicy => 'Datenschutz';

  @override
  String get privacySettings => 'Datenschutzeinstellungen';

  @override
  String get hideBannerButton => '24 Stunden';

  @override
  String get hideBannerTitle => 'Banner für 24 Stunden ausblenden';

  @override
  String get hideBannerSubtitle =>
      'Sieh dir eine Werbung an. Auf diesem Gerät bleibt es aus.';

  @override
  String get hideBannerWatch => 'Werbung ansehen';

  @override
  String get hideBannerNotNow => 'Nicht jetzt';

  @override
  String get aboutGame => 'Über das Spiel';

  @override
  String builtAt(String time) {
    return 'Stand: $time';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get sound => 'Ton';

  @override
  String get music => 'Musik';

  @override
  String get hapticFeedback => 'Vibration';

  @override
  String get qMode => 'Q-Modus';

  @override
  String get qModeHint => 'Magnet-Werbung gibt 50';

  @override
  String get dimCoveredTiles => 'Verdeckte Kacheln abdunkeln';

  @override
  String get dimCoveredTilesHint =>
      'Kacheln, die du nicht nehmen kannst, werden grau';

  @override
  String get tableLook => 'Tischoptik';

  @override
  String get tableLookClassic => 'Klassisches Mahjong';

  @override
  String get tableLookClassicHint => '3D-Kacheln und Kupfertasten';

  @override
  String get tableLookCasual => 'Helles Match';

  @override
  String get tableLookCasualHint => 'Flache Kacheln, Grün und Gold';

  @override
  String get tableLookPremium => 'Neu';

  @override
  String get tableLookPremiumHint => 'Elfenbeinkacheln, warmer Holztisch';

  @override
  String get tableLookGift => 'Tisch';

  @override
  String get tableLookUse => 'Nutzen';

  @override
  String get tableLookLockedHint => 'Als Hofgeschenk freischalten';

  @override
  String get tableLookSettingsHint =>
      'Verschiedene Tischthemen kannst du im Menü wählen';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get tileLocked => 'Kachel ist gesperrt';

  @override
  String get trayFull => 'Ablage ist voll';

  @override
  String get trayFullHint => 'Kein passendes Paar.';

  @override
  String get noMovesShuffle => 'Keine Züge — mischen';

  @override
  String get youWin => 'Gewonnen!';

  @override
  String get noFreeTiles => 'Keine freien Kacheln';

  @override
  String get shuffled => 'Gemischt';

  @override
  String get stillNoMoves => 'Immer noch keine Züge';

  @override
  String get loadingAd => 'Werbung wird geladen…';

  @override
  String get rewardNotEarned => 'Belohnung nicht erhalten';

  @override
  String get adUnavailable =>
      'Werbung konnte nicht geladen werden. Versuch es noch einmal.';

  @override
  String get noUsefulMoves => 'Keine nützlichen Züge';

  @override
  String get continuing => 'Es geht weiter';

  @override
  String get moveUndone => 'Zug rückgängig gemacht';

  @override
  String get noMatchingTiles => 'Keine passenden Kacheln';

  @override
  String get couldNotOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String get dailyComplete => 'Tagesaufgabe geschafft';

  @override
  String streakLabel(int n) {
    return 'Serie: $n';
  }

  @override
  String score(int value) {
    return 'Ergebnis: $value';
  }

  @override
  String starsCount(int n) {
    return '$n Sterne';
  }

  @override
  String get dailyBonus => 'Bonus: +1 Hinweis und Mischen';

  @override
  String get points => 'Punkte';

  @override
  String pointsBalanceText(String value) {
    return 'Punkte: $value';
  }

  @override
  String get pointsShopTitle => 'Punkte';

  @override
  String get pointsShopSubtitle =>
      'Bei jedem geschafften Tisch verdient. Jederzeit aufladen.';

  @override
  String pointsEarnRuleText(int perClear, int perStar) {
    return 'Level schaffen: +$perClear, plus +$perStar pro Stern.';
  }

  @override
  String pointsPackBonus(int percent) {
    return '+$percent % Bonus';
  }

  @override
  String get pointsPackPopular => 'Am beliebtesten';

  @override
  String get pointsPackBest => 'Bester Wert';

  @override
  String get pointsBuy => 'Kaufen';

  @override
  String pointsCreditedText(String value) {
    return '+$value gutgeschrieben';
  }

  @override
  String get pointsPurchaseCancelled => 'Kauf abgebrochen';

  @override
  String get pointsPurchaseUnavailable => 'Shop nicht verfügbar';

  @override
  String get pointsDemoNote =>
      'Zahlungen sind noch nicht angebunden — das Paket kommt sofort an.';

  @override
  String get pointsWatchAd => 'Werbung ansehen';

  @override
  String pointsWatchAdRewardText(String value) {
    return 'Gratis +$value';
  }

  @override
  String level(int id) {
    return 'Level $id';
  }

  @override
  String get anotherLevelCleared => 'Noch ein Level geschafft';

  @override
  String get newBest => 'Neue Bestleistung!';

  @override
  String levelUnlocked(int id) {
    return 'Level $id freigeschaltet';
  }

  @override
  String get shuffle => 'Mischen';

  @override
  String get magnet => 'Magnet';

  @override
  String get hint => 'Hinweis';

  @override
  String get undo => 'Rückgängig';

  @override
  String watchAd(String name) {
    return 'Werbung ansehen → $name';
  }

  @override
  String boostEarnedText(int count, String name) {
    return '+$count $name';
  }

  @override
  String get noneLeft => 'keine mehr';

  @override
  String get coachTapFree =>
      'Nimm eine freie Kachel — oben offen und an einer Seite';

  @override
  String get coachMatchPair => 'Ein Paar in der Ablage verschwindet';

  @override
  String get coachTrayLimit =>
      'Die Ablage fasst 4 — ohne Paar voll, und du verlierst';

  @override
  String get tutorialCollect =>
      'Tippe auf eine freie Kachel — sie kommt in die Ablage';

  @override
  String get tutorialMatch =>
      'Sammle zwei gleiche Kacheln — das Paar verschwindet. Die Ablage hat nur 4 Plätze.';

  @override
  String get tutorialLayers =>
      'Eine verdeckte Kachel kannst du erst nehmen, wenn die obere weg ist.';

  @override
  String get tutorialBoosts =>
      'Tipp zeigt einen Zug, Magnet sammelt ein Paar, Zurück nimmt einen Zug zurück.';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get featureGotIt => 'Verstanden';

  @override
  String get featureNewBadge => 'NEU';

  @override
  String get featureNewGarden =>
      'Neu: Beete im Hof — tippe auf ein Beet, um einen Samen zu pflanzen';

  @override
  String featureUnlockGoal(int count, String feature) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Level',
      one: 'Noch 1 Level',
    );
    return '$_temp0 bis: $feature';
  }

  @override
  String get winPointsHint => 'Gib Punkte für dein Haus im Hof aus';

  @override
  String get replayTips => 'Tipps erneut zeigen';

  @override
  String get replayTipsDone => 'Tipps werden wieder angezeigt';

  @override
  String get featureTitleHouse => 'Haus';

  @override
  String get featureTitleGarden => 'Garten';

  @override
  String get featureTitleSeeds => 'Samen';

  @override
  String get featureBodyHouse =>
      'Level bringen Punkte. Gib sie hier aus, um das Haus auszubauen — es produziert auch Samen für den Garten.';

  @override
  String get featureBodyPoints =>
      'Punkte gibt es für jedes geschaffte Level. Damit bezahlst du Hausausbau und Pflanzen.';

  @override
  String get featureBodyGarden =>
      'Pflanze einen Samen ins Beet, warte und ernte eine Pflanze. Pflanzen füttern Tiere und lassen sich Nachbarn zeigen.';

  @override
  String get featureBodyWarehouse =>
      'Hier liegen geerntete Pflanzen. Füttere Tiere damit, kreuze zwei oder stelle eine in die Vitrine.';

  @override
  String get featureBodySeeds =>
      'Hier liegen die Samen aus dem Haus. Pflanze sie in die Gartenbeete.';

  @override
  String get featureBodyCross =>
      'Zwei Pflanzen ergeben einen neuen Samen. Ein stärkeres oder seltenes Ergebnis ist eine Chance, kein Versprechen.';

  @override
  String get featureBodyNeighbors =>
      'Auf den Hügeln wohnen Spieler, die in der Rangliste nah bei dir sind. Schreib ihnen und tut euch für Kreuzung und Verteidigung zusammen.';

  @override
  String get featureBodyShowcase =>
      'Zeig allen deine besten Pflanzen und sieh, was andere Spieler züchten.';

  @override
  String get featureBodyLeaderboard =>
      'Sterne und Siege dieser Woche bringen dich in der Rangliste nach oben.';

  @override
  String get featureBodyPets =>
      'Dein Tier lebt im Hof. Füttere es mit Pflanzen aus dem Garten.';

  @override
  String get easy => 'Leicht';

  @override
  String get normal => 'Normal';

  @override
  String get hard => 'Schwer';

  @override
  String get expert => 'Experte';

  @override
  String get you => 'Du';

  @override
  String get player => 'Spieler';

  @override
  String get yourName => 'Dein Name';

  @override
  String get youClimbed => 'Du bist aufgestiegen!';

  @override
  String rankClimbPlaces(int from, int to) {
    return 'Platz $from → $to';
  }

  @override
  String get leaderboard => 'Rangliste';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get changeName => 'Namen ändern';

  @override
  String get nameNotAllowed =>
      'Dieser Name ist nicht erlaubt. Wähle einen anderen.';

  @override
  String get rankingNamesNote =>
      'Namen wählen die Spieler. Melde oder blende alle aus, die gegen die Regeln verstoßen.';

  @override
  String get reportPlayer => 'Melden oder ausblenden';

  @override
  String get reportName => 'Diesen Namen melden';

  @override
  String get hidePlayer => 'Diesen Spieler ausblenden';

  @override
  String get reportThanks => 'Danke. Wir prüfen diesen Namen.';

  @override
  String get playerHidden =>
      'Dieser Spieler ist auf deinem Gerät ausgeblendet.';

  @override
  String get name => 'Name';

  @override
  String onlineRanking(int top) {
    return 'Online-Rangliste · Top $top';
  }

  @override
  String get offlineRanking => 'Offline: nur dein Ergebnis wird gezeigt.';

  @override
  String get rankingFormula =>
      'Wertung: Sterne × 100.000 + beste Ergebnisse + Kampagnenfortschritt.';

  @override
  String get scorePlotsLegend => 'Punkte : Grundstücke';

  @override
  String get loadRankingFailed =>
      'Die Online-Rangliste konnte nicht geladen werden';

  @override
  String starsLevel(int stars, int unlocked) {
    return '$stars ★ · Lv. $unlocked';
  }

  @override
  String get ad => 'WERBUNG';

  @override
  String get done => 'Fertig';

  @override
  String get closeWithoutReward => 'Ohne Belohnung schließen';

  @override
  String get simulatedAd => 'Simulierte Werbung';

  @override
  String get watchClipForBoost =>
      'Sieh dir den Clip an, um einen Boost zu erhalten';

  @override
  String get claimReward => 'Belohnung abholen';

  @override
  String get watchingAd => 'Werbung läuft…';

  @override
  String get weeklyQuests => 'Wochenaufgaben';

  @override
  String get claim => 'Abholen';

  @override
  String get claimed => 'Abgeholt';

  @override
  String get questBonus => '+1 Hinweis und Mischen';

  @override
  String get extraBoostThisWeek => '+1 Boost auf dem heutigen Tisch';

  @override
  String get seasonClosed => 'Saison beendet';

  @override
  String lastWeekPlace(int rank) {
    return 'Letzte Woche: Platz $rank';
  }

  @override
  String lastWeekScore(String rating) {
    return 'Wertung $rating';
  }

  @override
  String get reminders => 'Tägliche Erinnerungen';

  @override
  String get reminderDailyTitle => 'Dein Hof wartet';

  @override
  String get reminderDailyBody => 'Heute ist ein neuer Tisch bereit.';

  @override
  String get reminderStreakTitle => 'Deine Serie ist in Gefahr';

  @override
  String get reminderStreakBody =>
      'Die dritte Laterne erlischt um Mitternacht.';

  @override
  String get reminderWeekTitle => 'Eine neue Hofsaison';

  @override
  String get reminderWeekBody =>
      'Wochenaufgaben und Rangliste wurden zurückgesetzt.';

  @override
  String get pet => 'Tier';

  @override
  String get pets => 'Tiere';

  @override
  String get chooseAPet => 'Wähle einen Begleiter';

  @override
  String get addPet => 'Begleiter hinzufügen';

  @override
  String get petInviteAdopt => 'Ein Freund wartet';

  @override
  String get petInviteShow => 'Tiere zeigen';

  @override
  String get petYardStartAdventure => 'Abenteuer starten';

  @override
  String get petYardVisit => 'Höhle besuchen';

  @override
  String get petYardShow => 'Im Hof zeigen';

  @override
  String get petYardShowing => 'Im Hof';

  @override
  String get petYardShowAll => 'Alle im Hof zeigen';

  @override
  String get petCareHint =>
      'Siege helfen ihnen beim Spielen und Ausruhen. Füttere geerntete Pflanzen aus dem Lager.';

  @override
  String get petStarvingLine =>
      'Sie verhungern. Füttere eine geerntete Pflanze aus dem Lager.';

  @override
  String get petRemindersPromptTitle => 'Erinnerungen bei Hunger?';

  @override
  String get petRemindersPromptBody =>
      'Wir können dich benachrichtigen, wenn sie hungrig werden.';

  @override
  String get petRemindersYes => 'Erinnere mich';

  @override
  String get petRemindersLater => 'Nicht jetzt';

  @override
  String reminderPetHungerTitle(String name) {
    return '$name hat Hunger';
  }

  @override
  String get reminderPetHungerBody =>
      'Füttere eine geerntete Pflanze aus dem Lager.';

  @override
  String reminderPetPlayTitle(String name) {
    return '$name will spielen';
  }

  @override
  String get reminderPetPlayBody => 'Schaffe einen Tisch, um mitzuspielen.';

  @override
  String reminderPetRestTitle(String name) {
    return '$name will sich ausruhen';
  }

  @override
  String get reminderPetRestBody =>
      'Schaffe einen Tisch, damit dein Tier ruhen kann.';

  @override
  String reminderPetStarveTitle(String name) {
    return '$name verhungert';
  }

  @override
  String get reminderPetStarveBody =>
      'Füttere eine geerntete Pflanze aus dem Lager.';

  @override
  String petLevelLabel(int level) {
    return 'Level $level';
  }

  @override
  String petLevelShort(int level) {
    return 'Lv $level';
  }

  @override
  String get petMaxLevel => 'Höchstes Level';

  @override
  String petXpLabel(int xp, int need) {
    return 'Erfahrung $xp / $need';
  }

  @override
  String petStrengthLineText(String stat, int total) {
    return '$stat $total';
  }

  @override
  String petLevelChange(int from, int to) {
    return 'Level $from → $to';
  }

  @override
  String petStatChange(String stat, int from, int to) {
    return '$stat $from → $to';
  }

  @override
  String get petFeed => 'Füttern';

  @override
  String get petFeedTitle => 'Pflanze wählen';

  @override
  String get petFeedEmpty => 'Keine geernteten Pflanzen im Lager.';

  @override
  String get petFeedPointless =>
      'Voll gefüttert und schon auf dem höchsten Level.';

  @override
  String petFeedXp(int xp) {
    return 'Erfahrung: $xp';
  }

  @override
  String get petFeedSatiety => 'Stillt den Hunger. Die Stärke wächst nicht.';

  @override
  String get petFeedConfirm => 'Diese Pflanze füttern';

  @override
  String petFedReaction(String name) {
    return '$name genießt die Mahlzeit.';
  }

  @override
  String get petFeedFailed =>
      'Speichern fehlgeschlagen. Die Pflanze wurde nicht verbraucht.';

  @override
  String get petFeedMissing => 'Diese Pflanze ist nicht mehr im Lager.';

  @override
  String get petGuardAction => 'Garten bewachen';

  @override
  String get petGuarding => 'Bewacht den Garten';

  @override
  String get petStopGuard => 'Bewachen beenden';

  @override
  String get petRaidAction => 'Für Überfälle wählen';

  @override
  String get petRaiding => 'Für Überfälle gewählt';

  @override
  String get petStopRaid => 'Überfallwahl aufheben';

  @override
  String gardenGuardLabel(String name, int power) {
    return '$name bewacht den Garten. Verteidigung $power';
  }

  @override
  String get gardenNoDefender => 'Noch kein Verteidiger';

  @override
  String get gardenUnguarded => 'Garten ist unbewacht';

  @override
  String get boardSemantic => 'Feld';

  @override
  String traySemantic(int filled, int capacity) {
    return 'Ablage, $filled von $capacity';
  }

  @override
  String get trayEmptySlot => 'Leerer Platz';

  @override
  String get trayAlmostFull => 'Noch ein Platz — finde ein Paar';

  @override
  String get houseCardTitle => 'Haus';

  @override
  String get seedsHeading => 'Samen';

  @override
  String seedsButton(int count) {
    return 'Samen · $count';
  }

  @override
  String seedPowerStep(int from, int to) {
    return 'Samenkraft: $from → $to';
  }

  @override
  String seedCostStep(int from, int to) {
    return 'Herstellungskosten: $from → $to Punkte';
  }

  @override
  String seedSpeciesUnlock(String name) {
    return 'Neuer Samen: $name';
  }

  @override
  String seedDurationStep(String from, String to) {
    return 'Herstellungszeit: $from → $to';
  }

  @override
  String seedChanceStep(String summary) {
    return 'Chancen: $summary';
  }

  @override
  String get seedClassCommon => 'Gewöhnlich';

  @override
  String get seedClassNutrient => 'Nährstoff';

  @override
  String get seedClassRare => 'Selten';

  @override
  String seedClassLine(String name, int percent) {
    return '$name $percent%';
  }

  @override
  String seedSpan(int minutes, int seconds) {
    return '$minutes Min. $seconds Sek.';
  }

  @override
  String seedPowerLabel(int power) {
    return 'Futter: $power';
  }

  @override
  String seedPowerPending(int power) {
    return 'Erwartete Samenkraft: $power';
  }

  @override
  String seedMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get seedSpeciesHeading => 'Mögliche Samen';

  @override
  String get seedEqualChance =>
      'Beide Arten einer Klasse sind gleich wahrscheinlich';

  @override
  String produceSeedForText(String price) {
    return 'Samen herstellen · $price Punkte';
  }

  @override
  String yardSeedOfferText(String price) {
    return 'Samen\nherstellen\n$price';
  }

  @override
  String yardSeedTimerText(String time) {
    return 'Samen\n$time';
  }

  @override
  String get yardGrowPlant => 'Pflanze ziehen';

  @override
  String get watchAdHarvest => 'Werbung · jetzt ernten';

  @override
  String get plantAdUsed => 'Heute schon per Werbung geerntet';

  @override
  String speedUpForText(String price) {
    return 'Beschleunigen · $price Punkte';
  }

  @override
  String get claimSeed => 'Samen abholen';

  @override
  String get seedAdded => 'Samen ins Lager gelegt';

  @override
  String get openSeedStorage => 'Lager öffnen';

  @override
  String get seedPurpose => 'Aus diesem Samen kann eine Pflanze wachsen.';

  @override
  String seedHouseLevel(int level) {
    return 'Gewachsen durch Hauslevel $level';
  }

  @override
  String seedReceived(String date) {
    return 'Erhalten $date';
  }

  @override
  String seedGroupCount(int count) {
    return '×$count';
  }

  @override
  String get seedSortPower => 'Nach Futter';

  @override
  String get seedSortTime => 'Nach Erhalt';

  @override
  String get seedProducing => 'Ein Samen wächst';

  @override
  String get seedReadyTitle => 'Der Samen ist bereit';

  @override
  String get seedUnknown => 'Unbekannter Samen';

  @override
  String seedTimeLeft(int minutes, int seconds) {
    return 'Noch $minutes Min. $seconds Sek.';
  }

  @override
  String get seedBadgeIdle => 'Samenherstellung ist verfügbar';

  @override
  String seedBadgeProducing(String time) {
    return 'Samen wächst, noch $time';
  }

  @override
  String get seedBadgeReady => 'Samen kann abgeholt werden';

  @override
  String get seedReadyMark => 'Bereit';

  @override
  String get seedPlayMahjong => 'Mahjong spielen';

  @override
  String get produceFirstSeed => 'Den ersten Samen herstellen';

  @override
  String get seedsEmptyBody => 'Das Haus hat noch keinen Samen hergestellt.';

  @override
  String seedStackLabel(String name, int power, int count) {
    return '$name, Futter $power, $count';
  }

  @override
  String get seedProductionTitle => 'Samenherstellung';

  @override
  String plantsButton(int count) {
    return 'Pflanzen · $count';
  }

  @override
  String get warehouseTitle => 'Lager';

  @override
  String warehouseSemantic(int count) {
    return 'Lager, $count Pflanzen';
  }

  @override
  String get warehouseEmptyBody => 'Geerntete Pflanzen werden hier aufbewahrt';

  @override
  String get openGarden => 'Garten öffnen';

  @override
  String plantActionText(int seeds, String points) {
    return 'Pflanzen · $seeds Samen + $points Punkte';
  }

  @override
  String get chooseSeedTitle => 'Samen wählen';

  @override
  String get noSeedsBody => 'Noch keine Samen. Stelle einen im Haus her.';

  @override
  String get openHouseProduction => 'Herstellung öffnen';

  @override
  String gardenBedEmpty(int number) {
    return 'Beet $number, leer';
  }

  @override
  String bedTitle(int number) {
    return 'Beet $number';
  }

  @override
  String get harvestAction => 'Ernten';

  @override
  String get harvestMark => 'Ernten';

  @override
  String plantPower(int power) {
    return 'Futter: $power';
  }

  @override
  String plantCostLabelText(String points) {
    return 'Pflanzkosten: $points Punkte';
  }

  @override
  String growDurationLabel(int minutes) {
    return 'Wachstumszeit: $minutes Min.';
  }

  @override
  String seedsAvailable(int count) {
    return 'Verfügbar: $count';
  }

  @override
  String get plantPreviewLabel => 'Künftige Pflanze';

  @override
  String plantVariant(String variant) {
    return 'Aussehen: $variant';
  }

  @override
  String plantedOn(String date) {
    return 'Gepflanzt $date';
  }

  @override
  String maturedOn(String date) {
    return 'Gereift $date';
  }

  @override
  String harvestedOn(String date) {
    return 'Geerntet $date';
  }

  @override
  String get gardenSaveFailed =>
      'Speichern fehlgeschlagen. Es wurde nichts ausgegeben.';

  @override
  String get gardenNotReady => 'Noch nicht bereit';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageThai => 'ไทย';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get challengeCompactTower => 'Turm: räume jede Schicht ab';

  @override
  String challengeSpecialPair(int cleared) {
    return 'Nimm die beiden Sternkacheln weg · $cleared/2';
  }

  @override
  String get challengeNoShuffle => 'Räume das Feld ohne Mischen ab';

  @override
  String plotKindTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'house': 'Haus',
      'pond': 'Teich',
      'pets': 'Tiere',
      'guest': 'Gästehaus',
      'other': 'Haus',
    });
    return '$_temp0';
  }

  @override
  String plotKindTitleToward(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'house': 'Haus',
      'pond': 'Teich',
      'pets': 'Tiere',
      'guest': 'Gästehaus',
      'other': 'Haus',
    });
    return '$_temp0';
  }

  @override
  String plotLookComplete(String name) {
    return '$name ist fertig';
  }

  @override
  String plotLookNextOne(String name) {
    return 'Noch 1 Level bis zum nächsten Look von $name';
  }

  @override
  String plotLookProgressText(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Level bis zum nächsten Look von $name',
    );
    return '$_temp0';
  }

  @override
  String get nextWinUpgradesHouse => 'Dein nächster Sieg baut das Haus aus';

  @override
  String winsUntilHouseUpgradeText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Siege bis zum Hausausbau',
      one: 'Noch $count Sieg bis zum Hausausbau',
    );
    return '$_temp0';
  }

  @override
  String get nextWinImprovesPond => 'Dein nächster Sieg verbessert den Teich';

  @override
  String winsUntilPondUpgradeText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Siege, bis der Teich wächst',
      one: 'Noch $count Sieg, bis der Teich wächst',
    );
    return '$_temp0';
  }

  @override
  String get nextPondLook => 'Nächstes Aussehen des Teichs';

  @override
  String hubStarsUntilPlotText(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Sterne bis $dest',
      one: 'Noch 1 Stern bis $dest',
      zero: 'Noch 1 Stern bis $dest',
    );
    return '$_temp0';
  }

  @override
  String get oneDailyUntilReward => 'Eine Tagesaufgabe bis zur Belohnung';

  @override
  String hubDailiesUntilRewardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Tagesaufgaben bis zur Belohnung',
      one: 'Noch $count Tagesaufgabe bis zur Belohnung',
    );
    return '$_temp0';
  }

  @override
  String get oneLevelUntilReward => 'Ein Level bis zur Belohnung';

  @override
  String hubLevelsUntilRewardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Level bis zur Belohnung',
      one: 'Noch $count Level bis zur Belohnung',
    );
    return '$_temp0';
  }

  @override
  String courtyardLevelsUntilGift(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Level bis zum Hofgeschenk',
      one: 'Noch ein Level bis zum Hofgeschenk',
      zero: 'Noch ein Level bis zum Hofgeschenk',
    );
    return '$_temp0';
  }

  @override
  String hubStarsUntilReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Sterne bis zur Belohnung',
      one: 'Noch 1 Stern bis zur Belohnung',
      zero: 'Noch 1 Stern bis zur Belohnung',
    );
    return '$_temp0';
  }

  @override
  String pointsRewardText(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$amount Punkte',
      one: '+$amount Punkt',
    );
    return '$_temp0';
  }

  @override
  String get styleFruit => 'Obst';

  @override
  String get styleNature => 'Natur';

  @override
  String get styleCourt => 'Hof';

  @override
  String get styleMyth => 'Mythos';

  @override
  String get styleClassic => 'Klassisch';

  @override
  String get styleShape => 'Formen';

  @override
  String get styleNumber => 'Zahlen';

  @override
  String get styleMix => 'Mix';

  @override
  String get questDaily3 => 'Schaffe die Tagesaufgabe 3-mal';

  @override
  String get questStars8 => 'Verdiene 8 Sterne';

  @override
  String get questClears4 => 'Schaffe 4 Kampagnenlevel';

  @override
  String get questThreeStar1 => 'Erreiche 3★ auf einem Level';

  @override
  String get questStreak3 => 'Halte drei Abende Licht';

  @override
  String get weekGarden => 'Gartenwoche';

  @override
  String get weekCourt => 'Hofwoche';

  @override
  String get weekLanterns => 'Laternenwoche';

  @override
  String get weekMyth => 'Mythenwoche';

  @override
  String get weekHarvest => 'Erntewoche';

  @override
  String get weekDefault => 'Der Tisch dieser Woche';

  @override
  String get petCat => 'Katze';

  @override
  String get petDog => 'Hund';

  @override
  String get petRaccoon => 'Waschbär';

  @override
  String get petHamster => 'Hamster';

  @override
  String get petFox => 'Fuchs';

  @override
  String get petNeedHunger => 'Hunger';

  @override
  String get petNeedPlay => 'Spiel';

  @override
  String get petNeedRest => 'Ruhe';

  @override
  String petMoodContent(String name) {
    return '$name ist zufrieden.';
  }

  @override
  String petMoodAsking(String name) {
    return '$name braucht dich.';
  }

  @override
  String petMoodStarving(String name) {
    return '$name verhungert.';
  }

  @override
  String petCareHunger(String name) {
    return 'Du hast $name gefüttert.';
  }

  @override
  String petCarePlay(String name) {
    return 'Du hast mit $name gespielt.';
  }

  @override
  String petCareRest(String name) {
    return '$name hat geruht.';
  }

  @override
  String get petRoleAttacker => 'Angreifer';

  @override
  String get petRoleDefender => 'Verteidiger';

  @override
  String get petStatAttack => 'Angriff';

  @override
  String get petStatDefense => 'Verteidigung';

  @override
  String get growthSown => 'Samen gepflanzt';

  @override
  String get growthSprout => 'Spross';

  @override
  String get growthGrowing => 'Wächst';

  @override
  String get growthRipe => 'Bereit zum Ernten';

  @override
  String get seedAmberbell => 'Bernsteinglocke';

  @override
  String get seedMistfern => 'Nebelfarn';

  @override
  String get seedGlassreed => 'Glasrohr';

  @override
  String get seedCrimsonplum => 'Purpurpflaume';

  @override
  String get seedNightlotus => 'Nachtlotus';

  @override
  String get seedStarbamboo => 'Sternbambus';

  @override
  String get seedBlurbAmberbell =>
      'Ein warmer Samen mit einer winzigen Glocke darin.';

  @override
  String get seedBlurbMistfern => 'Ein blasses Farnblatt, zum Samen gefaltet.';

  @override
  String get seedBlurbGlassreed => 'Ein klares Rohr, das im Licht klingt.';

  @override
  String get seedBlurbCrimsonplum =>
      'Ein dunkler süßer Stein von einer Hofpflaume.';

  @override
  String get seedBlurbNightlotus =>
      'Eine violette Knospe, die erst nach der Dämmerung aufgeht.';

  @override
  String get seedBlurbStarbamboo =>
      'Ein gegliedertes Korn mit einem Funken an der Spitze.';

  @override
  String get plantOriginHouse => 'Herkunft: Hausherstellung';

  @override
  String plantOriginOther(String source) {
    return 'Herkunft: $source';
  }

  @override
  String get firstPhraseHouse =>
      'Das nächste Aussehen des Hauses wird mit Punkten gekauft.';

  @override
  String get firstPhrasePond => 'Dieser Teich füllt sich, während du spielst.';

  @override
  String get firstPhrasePets => 'Dieses Tierhaus wächst, während du spielst.';

  @override
  String get firstPhraseGuest => 'Dieser Hof geht online, während du spielst.';

  @override
  String get pathLifeHouse => 'Das Haus wirkt wärmer.';

  @override
  String get pathLifePond => 'Der Teich wirkt lebendig.';

  @override
  String get pathLifePets => 'Das Tierhaus wirkt wärmer.';

  @override
  String get pathLifeGuest => 'Der Hof summt leise.';

  @override
  String get rewardPond => 'Kleiner Teich';

  @override
  String get rewardSwing => 'Gartenschaukel';

  @override
  String get rewardFlowerBed => 'Blumenbeet';

  @override
  String get tileStateFree => 'frei';

  @override
  String get tileStateLocked => 'gesperrt';

  @override
  String tileRemoving(String name) {
    return '$name, wird entfernt';
  }

  @override
  String tileInTrayHinted(String name) {
    return '$name in der Ablage, Hinweis';
  }

  @override
  String tileInTray(String name) {
    return '$name in der Ablage';
  }

  @override
  String tileFreeHinted(String name) {
    return '$name, frei, Hinweis';
  }

  @override
  String tileLockedHinted(String name) {
    return '$name, gesperrt, Hinweis';
  }

  @override
  String tileFreeState(String name) {
    return '$name, frei';
  }

  @override
  String tileLockedState(String name) {
    return '$name, gesperrt';
  }

  @override
  String levelCardLocked(int id) {
    return 'Level $id, gesperrt';
  }

  @override
  String levelCardOpen(int id, String title, String stars, String progress) {
    return 'Level $id, $title, $stars$progress';
  }

  @override
  String get levelStarsNone => 'keine Sterne';

  @override
  String levelStarsSome(int count) {
    return '$count Sterne';
  }

  @override
  String get levelInProgress => ', läuft';

  @override
  String boostLeft(String name, int count) {
    return '$name, noch $count';
  }

  @override
  String boostNone(String name) {
    return '$name, keine mehr';
  }

  @override
  String get petsNeedCare => 'Tiere brauchen Pflege';

  @override
  String dailyButtonSemanticText(String today, String status) {
    return '$today. $status';
  }

  @override
  String courtyardSemanticText(String name) {
    return 'Hof $name';
  }

  @override
  String gardenBedReady(int number, String name) {
    return 'Beet $number, $name, bereit zum Ernten';
  }

  @override
  String gardenBedGrowing(int number, String name, String stage, String time) {
    return 'Beet $number, $name, $stage, noch $time';
  }

  @override
  String storyNextItem(String item) {
    return 'Als Nächstes: $item';
  }

  @override
  String newGiftItem(String item) {
    return 'Neues Geschenk: $item';
  }

  @override
  String storyProgressLine(String title, int progress) {
    return '$title · $progress/3';
  }

  @override
  String newChapterProgress(int progress) {
    return 'Neues Kapitel · $progress/3';
  }

  @override
  String storyReadyProgress(int stage) {
    return 'Geschichte bereit · $stage/3';
  }

  @override
  String foxStoryProgress(int stage) {
    return 'Geschichte des Fuchses · $stage/3';
  }

  @override
  String petBadgeText(String role, String level) {
    return '$role, $level';
  }

  @override
  String get chooseAPetYard => 'Wähle einen Begleiter';

  @override
  String get chooseAPetStatus => 'Wähle ein Tier';

  @override
  String get homeSemantic => 'Start';

  @override
  String get petAdventures => 'Tierabenteuer';

  @override
  String get adventures => 'Abenteuer';

  @override
  String get adventureComplete => 'Abenteuer geschafft';

  @override
  String get adventureCompleteBang => 'Abenteuer geschafft!';

  @override
  String get play => 'Spielen';

  @override
  String get storyLocked => 'Schließe die vorherige Geschichte ab';

  @override
  String get fiveAdventures => '5 Abenteuer';

  @override
  String get foxTitle => 'Eine gemütliche Ecke für den Fuchs';

  @override
  String get foxGoal0 => 'Ein Sieg, um einen Platz vorzubereiten';

  @override
  String get foxGoal1 => 'Ein Sieg, um ein Bett zu machen';

  @override
  String get foxGoal2 => 'Ein Sieg, um ein Spielzeug zu bringen';

  @override
  String get foxGoalDone => 'Der Fuchs fühlt sich zu Hause!';

  @override
  String get foxSeeWhatChanged => 'Sieh, was sich geändert hat!';

  @override
  String get foxHelpSettle => 'Hilf dem Fuchs, sich einzurichten · 3 Siege';

  @override
  String get foxSaveFailed =>
      'Speichern fehlgeschlagen. Bitte versuche es noch einmal.';

  @override
  String get foxIntro =>
      'Der Fuchs hat einen ruhigen Platz in deinem Hof gefunden. Drei Kampagnensiege machen ihn zu einem Zuhause.';

  @override
  String get foxStage0 =>
      'Räumen wir die Blätter weg. Gewinne ein Kampagnenlevel, um den Platz vorzubereiten.';

  @override
  String get foxStage1 =>
      'Der Platz ist bereit! Noch ein Sieg bringt ein weiches Bett.';

  @override
  String get foxStage2 =>
      'Ein weiches Bett! Wähle eine Farbe. Noch ein Sieg bringt ein Spielzeug.';

  @override
  String get foxStageDone =>
      'Der Fuchs fühlt sich zu Hause! Tippe auf den Fuchs, um zu spielen. Diese Ecke bleibt in deinem Hof.';

  @override
  String get foxHoney => 'Honig';

  @override
  String get foxSkyBlue => 'Himmelblau';

  @override
  String get foxBall => 'Ball';

  @override
  String get foxPlushToy => 'Plüschtier';

  @override
  String get later => 'Später';

  @override
  String get foxHelpStages => 'Hilfe · 3 Abschnitte';

  @override
  String get foxLovely => 'Wunderschön!';

  @override
  String get foxIsHome => 'Der Fuchs ist zu Hause · 3/3';

  @override
  String get foxStory => 'Geschichte des Fuchses';

  @override
  String get windEast => 'Ostwind';

  @override
  String get windSouth => 'Südwind';

  @override
  String get windWest => 'Westwind';

  @override
  String get windNorth => 'Nordwind';

  @override
  String get familyFruit => 'Obst';

  @override
  String get familyFlower => 'Blume';

  @override
  String get familyAnimal => 'Tier';

  @override
  String get familyBamboo => 'Bambus';

  @override
  String get familyCharacter => 'Zeichen';

  @override
  String get familyDot => 'Kreis';

  @override
  String get familyDragon => 'Drache';

  @override
  String get familyWind => 'Wind';

  @override
  String get familySeason => 'Jahreszeit';

  @override
  String get familyNumber => 'Zahl';

  @override
  String get familyShape => 'Form';

  @override
  String get familyTile => 'Kachel';

  @override
  String get familyArt => 'Kunst';

  @override
  String get familyClown => 'Clown';

  @override
  String get familyEmperor => 'Kaiser';

  @override
  String get familyJoker => 'Joker';

  @override
  String get familyProfession => 'Beruf';

  @override
  String get familyQueen => 'Königin';

  @override
  String get familyEast => 'Ost';

  @override
  String get familySouth => 'Süd';

  @override
  String get familyWest => 'West';

  @override
  String get familyNorth => 'Nord';

  @override
  String get familySpring => 'Frühling';

  @override
  String get familySummer => 'Sommer';

  @override
  String get familyAutumn => 'Herbst';

  @override
  String get familyWinter => 'Winter';

  @override
  String get storyCampaign0 => 'Spross';

  @override
  String get storyCampaign1 => 'Knospe';

  @override
  String get storyCampaign2 => 'Blüte';

  @override
  String get storyCampaign3 => 'Lichtung';

  @override
  String get storyCampaign4 => 'Rasen';

  @override
  String get storyCampaign5 => 'Hain';

  @override
  String get storyCampaign6 => 'Welle';

  @override
  String get storyCampaign7 => 'Bach';

  @override
  String get storyCampaign8 => 'Garten';

  @override
  String get storyCampaign9 => 'Laube';

  @override
  String get storyCampaign10 => 'Fächer';

  @override
  String get storyCampaign11 => 'Pfauenfächer';

  @override
  String get storyCampaign12 => 'Lotus';

  @override
  String get storyCampaign13 => 'Teich';

  @override
  String get storyCampaign14 => 'Karpfen';

  @override
  String get storyCampaign15 => 'See';

  @override
  String get storyCampaign16 => 'Ranke';

  @override
  String get storyCampaign17 => 'Efeu';

  @override
  String get storyCampaign18 => 'Fest';

  @override
  String get storyCampaign19 => 'Laternen';

  @override
  String get storyCampaign20 => 'Pavillon';

  @override
  String get storyCampaign21 => 'Windtempel';

  @override
  String get storyCampaign22 => 'Drache';

  @override
  String get storyCampaign23 => 'Himmelsdrache';

  @override
  String get houseEraName0 => 'Lichtung';

  @override
  String get houseEraPhrase0 => 'Hier wird ein Haus stehen.';

  @override
  String get houseEraName1 => 'Bude';

  @override
  String get houseEraPhrase1 => 'Eine Bude steht auf dem Grundstück.';

  @override
  String get houseEraName2 => 'Kate';

  @override
  String get houseEraPhrase2 => 'Die Kate hat eine Tür.';

  @override
  String get houseEraName3 => 'Blockhaus';

  @override
  String get houseEraPhrase3 => 'Das Blockhaus ist jetzt aus Holz.';

  @override
  String get houseEraName4 => 'Haus';

  @override
  String get houseEraPhrase4 => 'Hier steht ein richtiges Haus.';

  @override
  String get houseEraName5 => 'Landhaus';

  @override
  String get houseEraPhrase5 => 'Das Landhaus hat zwei Stockwerke.';

  @override
  String get houseEraName6 => 'Anwesen';

  @override
  String get houseEraPhrase6 => 'Das Anwesen breitet seine Flügel aus.';

  @override
  String get houseEraName7 => 'Villa';

  @override
  String get houseEraPhrase7 => 'Die Villa ist aus Stein.';

  @override
  String get houseEraName8 => 'Bergfried';

  @override
  String get houseEraPhrase8 => 'Die Mauern werden zum Bergfried.';

  @override
  String get houseEraName9 => 'Burg';

  @override
  String get houseEraPhrase9 => 'Eine Burg erhebt sich.';

  @override
  String get houseEraName10 => 'Große Burg';

  @override
  String get houseEraPhrase10 => 'Die Burg füllt den Hügel.';

  @override
  String get houseEraName11 => 'Residenz';

  @override
  String get houseEraPhrase11 => 'Die Residenz ist fertig.';

  @override
  String get pondEraName0 => 'Mulde';

  @override
  String get pondEraPhrase0 => 'Ein Teich wird diese Mulde füllen.';

  @override
  String get pondEraName1 => 'Pfütze';

  @override
  String get pondEraPhrase1 => 'Die Pfütze bleibt.';

  @override
  String get pondEraName2 => 'Teich';

  @override
  String get pondEraPhrase2 => 'Schilf nimmt das Ufer ein.';

  @override
  String get pondEraName3 => 'Steg';

  @override
  String get pondEraPhrase3 => 'Der Steg liegt.';

  @override
  String get pondEraName4 => 'Koiteich';

  @override
  String get pondEraPhrase4 => 'Die Koi haben ein Zuhause.';

  @override
  String get pondEraName5 => 'Pavillon';

  @override
  String get pondEraPhrase5 => 'Ein Pavillon blickt aufs Wasser.';

  @override
  String get pondEraName6 => 'Wassergarten';

  @override
  String get pondEraPhrase6 => 'Der Teich ist ein Garten.';

  @override
  String get pondEraName7 => 'Steinufer';

  @override
  String get pondEraPhrase7 => 'Steinufer und Laternen.';

  @override
  String get pondEraName8 => 'Brücke';

  @override
  String get pondEraPhrase8 => 'Eine Brücke führt übers Wasser.';

  @override
  String get pondEraName9 => 'Wasserhof';

  @override
  String get pondEraPhrase9 => 'Der Wasserhof ist ummauert.';

  @override
  String get pondEraName10 => 'Palastteich';

  @override
  String get pondEraPhrase10 => 'Die Palastgärten reichen bis zum Teich.';

  @override
  String get pondEraName11 => 'Wassergarten fertig';

  @override
  String get pondEraPhrase11 => 'Der Wassergarten ist fertig.';

  @override
  String get petsEraName0 => 'Hof';

  @override
  String get petsEraPhrase0 => 'Hier wird ein Tierhaus stehen.';

  @override
  String get petsEraName1 => 'Näpfe';

  @override
  String get petsEraPhrase1 => 'Näpfe warten im Gras.';

  @override
  String get petsEraName2 => 'Zwinger';

  @override
  String get petsEraPhrase2 => 'Ein Zwinger steht auf dem Grundstück.';

  @override
  String get petsEraName3 => 'Stall';

  @override
  String get petsEraPhrase3 => 'Der Stall hat eine Tür.';

  @override
  String get petsEraName4 => 'Tierhaus';

  @override
  String get petsEraPhrase4 => 'Die Tiere haben ein Haus.';

  @override
  String get petsEraName5 => 'Spielhof';

  @override
  String get petsEraPhrase5 => 'Ein Spielhof öffnet sich.';

  @override
  String get petsEraName6 => 'Garten';

  @override
  String get petsEraPhrase6 => 'Der Garten gehört ihnen.';

  @override
  String get petsEraName7 => 'Höhle';

  @override
  String get petsEraPhrase7 => 'Eine Höhle ist ausgelegt.';

  @override
  String get petsEraName8 => 'Herberge';

  @override
  String get petsEraPhrase8 => 'Die Herberge ist warm.';

  @override
  String get petsEraName9 => 'Menagerie';

  @override
  String get petsEraPhrase9 => 'Eine Menagerie versammelt sich.';

  @override
  String get petsEraName10 => 'Refugium';

  @override
  String get petsEraPhrase10 => 'Das Refugium ist eingezäunt.';

  @override
  String get petsEraName11 => 'Tierheim fertig';

  @override
  String get petsEraPhrase11 => 'Das Tierhaus ist fertig.';

  @override
  String get guestEraName0 => 'Stiller Hof';

  @override
  String get guestEraPhrase0 => 'Ein Signal wird diesen Hof erreichen.';

  @override
  String get guestEraName1 => 'Mast';

  @override
  String get guestEraPhrase1 => 'Der Mast hält die Leitung.';

  @override
  String get guestEraName2 => 'Kabel';

  @override
  String get guestEraPhrase2 => 'Das Kabel findet das Haus.';

  @override
  String get guestEraName3 => 'Schüssel';

  @override
  String get guestEraPhrase3 => 'Die Schüssel steht.';

  @override
  String get guestEraName4 => 'Bildschirme';

  @override
  String get guestEraPhrase4 => 'Bildschirme leuchten im Hof.';

  @override
  String get guestEraName5 => 'Leitungslampe';

  @override
  String get guestEraPhrase5 => 'Eine Lampe der Leitung.';

  @override
  String get guestEraName6 => 'Ferngespräch';

  @override
  String get guestEraPhrase6 => 'Der Hof spricht weiter hinaus.';

  @override
  String get guestEraName7 => 'Signalturm';

  @override
  String get guestEraPhrase7 => 'Ein Turm des Signals.';

  @override
  String get guestEraName8 => 'Sternwarte';

  @override
  String get guestEraPhrase8 => 'Die Sternwarte erhebt sich.';

  @override
  String get guestEraName9 => 'Kristallleitung';

  @override
  String get guestEraPhrase9 => 'Kristall und Draht.';

  @override
  String get guestEraName10 => 'Leuchtfeuer';

  @override
  String get guestEraPhrase10 => 'Ein Leuchtfeuer auf dem Hügel.';

  @override
  String get guestEraName11 => 'Hof online';

  @override
  String get guestEraPhrase11 => 'Der Hof ist vollständig online.';

  @override
  String get houseWarm0 => 'Noch ein Schritt auf dem Weg.';

  @override
  String get houseWarm1 => 'Das Grundstück gehört jetzt dir.';

  @override
  String get houseWarm2 => 'Das Haus ist ein Stück näher.';

  @override
  String get pondWarm0 => 'Das Wasser ist ein wenig gestiegen.';

  @override
  String get pondWarm1 => 'Der Teich gehört dir jetzt mehr.';

  @override
  String get pondWarm2 => 'Die Ufer rücken näher.';

  @override
  String get petsWarm0 => 'Das Tierhaus ist ein wenig gewachsen.';

  @override
  String get petsWarm1 => 'Der Hof gehört ihnen jetzt mehr.';

  @override
  String get petsWarm2 => 'Der Zwinger rückt näher.';

  @override
  String get guestWarm0 => 'Das Signal ist ein wenig gewachsen.';

  @override
  String get guestWarm1 => 'Der Hof ist besser verbunden.';

  @override
  String get guestWarm2 => 'Die Leitung rückt näher.';

  @override
  String get storyCatWindowTitle => 'Sonnige Fensterbank';

  @override
  String get storyCatWindowChapter0 => 'Finde das wärmste Fleckchen Sonne.';

  @override
  String get storyCatWindowChapter1 =>
      'Bring ein weiches Kissen und ein Wollknäuel.';

  @override
  String get storyCatWindowChapter2 =>
      'Häng einen Vorhang für das perfekte Mittagsschläfchen auf.';

  @override
  String get storyCatWatchTitle => 'Mitternachtswache';

  @override
  String get storyCatWatchChapter0 => 'Leuchte einen stillen Weg über den Hof.';

  @override
  String get storyCatWatchChapter1 =>
      'Häng eine Glocke auf, um jeden Besucher zu hören.';

  @override
  String get storyCatWatchChapter2 =>
      'Beobachte den Mond durch ein winziges Fernrohr.';

  @override
  String get storyCatGardenTitle => 'Geheimer Garten';

  @override
  String get storyCatGardenChapter0 => 'Pflanze eine versteckte grüne Ecke.';

  @override
  String get storyCatGardenChapter1 => 'Lade helle Schmetterlinge ein.';

  @override
  String get storyCatGardenChapter2 =>
      'Beende den Garten mit einem murmelnden Brunnen.';

  @override
  String get storyCatLibraryTitle => 'Kleine Bibliothek';

  @override
  String get storyCatLibraryChapter0 => 'Sammle drei Lieblingsbücher.';

  @override
  String get storyCatLibraryChapter1 =>
      'Breite eine Decke neben den Regalen aus.';

  @override
  String get storyCatLibraryChapter2 =>
      'Zünde eine Leselampe für lange Abende an.';

  @override
  String get storyCatTeaTitle => 'Hüter des Teehauses';

  @override
  String get storyCatTeaChapter0 => 'Stell die erste winzige Teetasse hin.';

  @override
  String get storyCatTeaChapter1 => 'Schmücke den Tisch mit frischen Blumen.';

  @override
  String get storyCatTeaChapter2 => 'Hiss das Banner des Teehauses für Gäste.';

  @override
  String get storyDogTrailTitle => 'Willkommenspfad';

  @override
  String get storyDogTrailChapter0 =>
      'Markiere einen freundlichen Pfad durch den Hof.';

  @override
  String get storyDogTrailChapter1 =>
      'Lass frisches Wasser für Reisende stehen.';

  @override
  String get storyDogTrailChapter2 =>
      'Leg am Ziel einen Ball für ein fröhliches Willkommen hin.';

  @override
  String get storyDogBridgeTitle => 'Brückenpatrouille';

  @override
  String get storyDogBridgeChapter0 =>
      'Sichere die alte Brücke mit einem starken Seil.';

  @override
  String get storyDogBridgeChapter1 =>
      'Häng eine Laterne für neblige Morgen auf.';

  @override
  String get storyDogBridgeChapter2 =>
      'Verdiene das goldene Abzeichen der Hofpatrouille.';

  @override
  String get storyDogPicnicTitle => 'Picknicktag';

  @override
  String get storyDogPicnicChapter0 => 'Packe einen Korb für jeden Freund.';

  @override
  String get storyDogPicnicChapter1 =>
      'Wähle einen sonnigen Platz für die Decke.';

  @override
  String get storyDogPicnicChapter2 =>
      'Teile die Leckereien, wenn alle da sind.';

  @override
  String get storyDogKiteTitle => 'Der verlorene Drachen';

  @override
  String get storyDogKiteChapter0 => 'Entdecke den Drachen hinter den Hügeln.';

  @override
  String get storyDogKiteChapter1 => 'Folge dem Wind mit einem Kompass.';

  @override
  String get storyDogKiteChapter2 =>
      'Bring ihn nach Hause und binde ein neues Band daran.';

  @override
  String get storyDogFestivalTitle => 'Festhelfer';

  @override
  String get storyDogFestivalChapter0 => 'Trag bunte Fahnen zum Platz.';

  @override
  String get storyDogFestivalChapter1 =>
      'Führe den Umzug mit einer kleinen Trommel an.';

  @override
  String get storyDogFestivalChapter2 =>
      'Erhalte eine Medaille, weil du allen geholfen hast.';

  @override
  String get storyRaccoonWorkshopTitle => 'Glänzende Werkstatt';

  @override
  String get storyRaccoonWorkshopChapter0 =>
      'Öffne einen Werkzeugkasten voll neugieriger Erfindungen.';

  @override
  String get storyRaccoonWorkshopChapter1 =>
      'Setze die hellsten Zahnräder zusammen.';

  @override
  String get storyRaccoonWorkshopChapter2 =>
      'Baue eine Uhr, die bei Sonnenuntergang schlägt.';

  @override
  String get storyRaccoonMarketTitle => 'Mondscheinmarkt';

  @override
  String get storyRaccoonMarketChapter0 =>
      'Flechte einen Korb für ungewöhnliche Funde.';

  @override
  String get storyRaccoonMarketChapter1 =>
      'Zünde einen Stand unter dem Mond an.';

  @override
  String get storyRaccoonMarketChapter2 =>
      'Tausch drei glänzende Münzen gegen eine Überraschung.';

  @override
  String get storyRaccoonRiverTitle => 'Flussschatz';

  @override
  String get storyRaccoonRiverChapter0 =>
      'Lies die Karte, die unter einem Stein versteckt ist.';

  @override
  String get storyRaccoonRiverChapter1 =>
      'Flicke ein winziges Boot für die Überfahrt.';

  @override
  String get storyRaccoonRiverChapter2 =>
      'Finde die singende Muschel am anderen Ufer.';

  @override
  String get storyRaccoonRecycleTitle => 'Garten der zweiten Chance';

  @override
  String get storyRaccoonRecycleChapter0 =>
      'Mach aus einer alten Kiste einen Pflanztopf.';

  @override
  String get storyRaccoonRecycleChapter1 =>
      'Repariere eine verbeulte Gießkanne.';

  @override
  String get storyRaccoonRecycleChapter2 =>
      'Baue eine Windmühle aus vergessenen Teilen.';

  @override
  String get storyRaccoonCafeTitle => 'Nachtcafé';

  @override
  String get storyRaccoonCafeChapter0 =>
      'Poliere eine Tasse für den ersten Gast.';

  @override
  String get storyRaccoonCafeChapter1 =>
      'Backe einen Teller mondförmiger Kekse.';

  @override
  String get storyRaccoonCafeChapter2 =>
      'Häng das Café-Schild vor Einbruch der Nacht auf.';

  @override
  String get storyHamsterRailwayTitle => 'Winzige Eisenbahn';

  @override
  String get storyHamsterRailwayChapter0 => 'Verlege Gleise um das Blumenbeet.';

  @override
  String get storyHamsterRailwayChapter1 =>
      'Baue einen Wagen in genau der richtigen Größe.';

  @override
  String get storyHamsterRailwayChapter2 =>
      'Eröffne den kleinsten Bahnhof des Hofs.';

  @override
  String get storyHamsterPantryTitle => 'Große Vorratskammer';

  @override
  String get storyHamsterPantryChapter0 =>
      'Sammle einen Winterbeutel voller Samen.';

  @override
  String get storyHamsterPantryChapter1 => 'Baue Regale aus glatten Zweigen.';

  @override
  String get storyHamsterPantryChapter2 =>
      'Beschrifte das feinste Glas in der Kammer.';

  @override
  String get storyHamsterCloudsTitle => 'Wolkensternwarte';

  @override
  String get storyHamsterCloudsChapter0 =>
      'Stell eine Leiter über das hohe Gras.';

  @override
  String get storyHamsterCloudsChapter1 =>
      'Richte das Fernrohr zwischen die Wolken.';

  @override
  String get storyHamsterCloudsChapter2 =>
      'Benenne einen neuen Stern nach dem Hof.';

  @override
  String get storyHamsterGardenTitle => 'Miniaturgarten';

  @override
  String get storyHamsterGardenChapter0 =>
      'Pflanze einen Garten in einen Tontopf.';

  @override
  String get storyHamsterGardenChapter1 =>
      'Setze eine Brücke über einen Kieselbach.';

  @override
  String get storyHamsterGardenChapter2 =>
      'Stell ein Pilzhaus für Besucher dazu.';

  @override
  String get storyHamsterBirthdayTitle => 'Geburtstagsparade';

  @override
  String get storyHamsterBirthdayChapter0 => 'Mach den winzigsten Partyhut.';

  @override
  String get storyHamsterBirthdayChapter1 =>
      'Backe einen Kuchen mit drei Beeren.';

  @override
  String get storyHamsterBirthdayChapter2 =>
      'Starte die Parade in einem Konfettiregen.';

  @override
  String get storyFoxCozyTitle => 'Eine gemütliche Ecke';

  @override
  String get storyFoxCozyChapter0 =>
      'Räume die Blätter aus einer stillen Ecke.';

  @override
  String get storyFoxCozyChapter1 =>
      'Bring ein weiches Bett für Mittagsschläfchen.';

  @override
  String get storyFoxCozyChapter2 =>
      'Wähle ein Lieblingsspielzeug und mach es heimelig.';

  @override
  String get storyFoxFirefliesTitle => 'Glühwürmchenpfad';

  @override
  String get storyFoxFirefliesChapter0 => 'Stell eine Laterne an den Waldrand.';

  @override
  String get storyFoxFirefliesChapter1 =>
      'Pflanze Nachtblumen entlang des Pfads.';

  @override
  String get storyFoxFirefliesChapter2 =>
      'Begrüße eine funkelnde Wolke aus Glühwürmchen.';

  @override
  String get storyFoxPostTitle => 'Waldpost';

  @override
  String get storyFoxPostChapter0 =>
      'Baue einen roten Briefkasten unter der Eiche.';

  @override
  String get storyFoxPostChapter1 => 'Sortiere Briefe für jeden Hoffreund.';

  @override
  String get storyFoxPostChapter2 =>
      'Trag die erste Zustellung in einer neuen Tasche.';

  @override
  String get storyFoxStudioTitle => 'Herbstatelier';

  @override
  String get storyFoxStudioChapter0 =>
      'Stell eine Staffelei zwischen die goldenen Blätter.';

  @override
  String get storyFoxStudioChapter1 => 'Mische Farben für ein Herbstporträt.';

  @override
  String get storyFoxStudioChapter2 => 'Rahm das Bild für das Hofhaus ein.';

  @override
  String get storyFoxCampTitle => 'Sternenlager';

  @override
  String get storyFoxCampChapter0 => 'Schlag ein Zelt unter den Kiefern auf.';

  @override
  String get storyFoxCampChapter1 =>
      'Zünde ein warmes, vorsichtiges Lagerfeuer.';

  @override
  String get storyFoxCampChapter2 =>
      'Bleib wach, um eine Sternschnuppe zu finden.';

  @override
  String get petItemCushion => 'Kissen';

  @override
  String get petItemYarn => 'Wollknäuel';

  @override
  String get petItemCurtain => 'Vorhang';

  @override
  String get petItemLantern => 'Laterne';

  @override
  String get petItemBell => 'Glocke';

  @override
  String get petItemTelescope => 'Fernrohr';

  @override
  String get petItemSeedling => 'Setzling';

  @override
  String get petItemButterflies => 'Schmetterlinge';

  @override
  String get petItemFountain => 'Brunnen';

  @override
  String get petItemBooks => 'Bücher';

  @override
  String get petItemBlanket => 'Decke';

  @override
  String get petItemLamp => 'Leselampe';

  @override
  String get petItemTeacup => 'Teeservice';

  @override
  String get petItemFlowers => 'Blumen';

  @override
  String get petItemBanner => 'Banner';

  @override
  String get petItemSignpost => 'Wegweiser';

  @override
  String get petItemBowl => 'Wassernapf';

  @override
  String get petItemBall => 'Ball';

  @override
  String get petItemRope => 'Starkes Seil';

  @override
  String get petItemBadge => 'Patrouillenabzeichen';

  @override
  String get petItemBasket => 'Korb';

  @override
  String get petItemTreats => 'Leckereien';

  @override
  String get petItemKite => 'Drache';

  @override
  String get petItemCompass => 'Kompass';

  @override
  String get petItemRibbon => 'Band';

  @override
  String get petItemFlags => 'Festfahnen';

  @override
  String get petItemDrum => 'Trommel';

  @override
  String get petItemMedal => 'Medaille';

  @override
  String get petItemToolbox => 'Werkzeugkasten';

  @override
  String get petItemGears => 'Zahnräder';

  @override
  String get petItemClock => 'Uhr';

  @override
  String get petItemCoins => 'Glänzende Münzen';

  @override
  String get petItemMap => 'Schatzkarte';

  @override
  String get petItemBoat => 'Winziges Boot';

  @override
  String get petItemShell => 'Singende Muschel';

  @override
  String get petItemCrate => 'Pflanzkiste';

  @override
  String get petItemWateringCan => 'Gießkanne';

  @override
  String get petItemWindmill => 'Windmühle';

  @override
  String get petItemMug => 'Cafétasse';

  @override
  String get petItemCookies => 'Kekse';

  @override
  String get petItemTracks => 'Eisenbahngleise';

  @override
  String get petItemCart => 'Winziger Wagen';

  @override
  String get petItemStation => 'Bahnhof';

  @override
  String get petItemSeedBag => 'Samenbeutel';

  @override
  String get petItemShelf => 'Regale';

  @override
  String get petItemJar => 'Vorratsglas';

  @override
  String get petItemLadder => 'Leiter';

  @override
  String get petItemStar => 'Neuer Stern';

  @override
  String get petItemPot => 'Gartentopf';

  @override
  String get petItemBridge => 'Winzige Brücke';

  @override
  String get petItemMushroom => 'Pilzhaus';

  @override
  String get petItemHat => 'Partyhut';

  @override
  String get petItemCake => 'Beerenkuchen';

  @override
  String get petItemConfetti => 'Konfetti';

  @override
  String get petItemClearing => 'Stille Lichtung';

  @override
  String get petItemBed => 'Weiches Bett';

  @override
  String get petItemToy => 'Lieblingsspielzeug';

  @override
  String get petItemFireflies => 'Glühwürmchen';

  @override
  String get petItemMailbox => 'Briefkasten';

  @override
  String get petItemLetters => 'Briefe';

  @override
  String get petItemSatchel => 'Posttasche';

  @override
  String get petItemEasel => 'Staffelei';

  @override
  String get petItemPaints => 'Farben';

  @override
  String get petItemFrame => 'Bilderrahmen';

  @override
  String get petItemTent => 'Zelt';

  @override
  String get petItemCampfire => 'Lagerfeuer';

  @override
  String get neighborsTitle => 'Nachbarn';

  @override
  String get neighborsClose => 'Schließen';

  @override
  String get neighborsTabAll => 'Alle Spieler';

  @override
  String get neighborsTabSaved => 'Favoriten';

  @override
  String get neighborsSearchHint => 'Nach dem Anfang eines Namens suchen';

  @override
  String get neighborsForYou => 'Für dich';

  @override
  String neighborsUpdates(int count) {
    return '$count Neuigkeiten';
  }

  @override
  String get neighborsShowLess => 'Weniger zeigen';

  @override
  String get neighborsEmptySaved =>
      'Leute, die du für später speicherst, erscheinen hier.';

  @override
  String get neighborsBrowsePlayers => 'Alle Spieler ansehen';

  @override
  String get neighborsEmptySearch => 'Kein Name beginnt so.';

  @override
  String get neighborsEmptyPlayers =>
      'Keine anderen Spieler stehen in dieser Liste.';

  @override
  String get neighborsOffline =>
      'Keine Verbindung. Zuvor geladene Spieler bleiben hier.';

  @override
  String get neighborsLoadFailed => 'Spieler konnten nicht geladen werden.';

  @override
  String get neighborsRetry => 'Nochmal versuchen';

  @override
  String get neighborsLoading => 'Spieler werden geladen';

  @override
  String get neighborsLoadingMore => 'Weitere Spieler werden geladen';

  @override
  String neighborsLevel(int level) {
    return 'Level $level';
  }

  @override
  String get neighborsAdd => 'Zu Favoriten hinzufügen';

  @override
  String get neighborsRemove => 'Aus Favoriten entfernen';

  @override
  String neighborsSaved(String name) {
    return '$name ist bei den Favoriten.';
  }

  @override
  String neighborsRemoved(String name) {
    return '$name wurde aus den Favoriten entfernt.';
  }

  @override
  String get neighborsFindAgain => 'In Favoriten wiederfinden';

  @override
  String get neighborsBack => 'Zurück zur Liste';

  @override
  String get neighborsSavedHint =>
      'Speichere diesen Spieler, um ihn in den Favoriten wiederzufinden.';

  @override
  String get neighborsSignalAsksHelp => 'Bittet um Hilfe';

  @override
  String get neighborsSignalSeeksDefense => 'Sucht Schutz';

  @override
  String get neighborsSignalOffersCross => 'Bietet eine Kreuzung an';

  @override
  String get neighborsSignalAwaitsReply => 'Wartet auf eine Antwort';

  @override
  String get neighborsSignalHelpedYou => 'Hat dir geholfen';

  @override
  String neighborsUnseen(int count) {
    return '$count neu';
  }

  @override
  String get neighborsHistory => 'Gemeinsam';

  @override
  String get neighborsBlock => 'Blockieren';

  @override
  String neighborsBlocked(String name) {
    return '$name ist blockiert und ausgeblendet.';
  }

  @override
  String get neighborsWaiting => 'Wartet auf eine Antwort';

  @override
  String get neighborsUnavailable => 'Diese Aktion ist nicht verfügbar.';

  @override
  String get neighborsFailed =>
      'Das ist nicht angekommen. Du kannst es noch einmal versuchen.';

  @override
  String get neighborsEnded => 'Dieses Angebot ist beendet.';

  @override
  String get neighborsDeclined => 'Dieses Angebot wurde abgelehnt.';

  @override
  String get neighborsCancelled => 'Dieses Angebot wurde abgebrochen.';

  @override
  String get neighborsInProgress => 'Wird bearbeitet';

  @override
  String get neighborsDone => 'Fertig';

  @override
  String get neighborsReply => 'Antworten';

  @override
  String get neighborsViewOffer => 'Angebot ansehen';

  @override
  String get neighborsPeaceful => 'Friedliche Aktionen';

  @override
  String get neighborsAttackSection => 'Angriff';

  @override
  String get neighborsAttackExplain =>
      'Damit startest du einen Angriff auf diesen Spieler.';

  @override
  String get neighborsConfirm => 'Bestätigen';

  @override
  String get neighborsThank => 'Danke sagen';

  @override
  String neighborsThankSent(String name) {
    return 'Danke an $name gesendet.';
  }

  @override
  String get neighborsOfferAgain => 'Erneut anbieten';

  @override
  String neighborsCost(String cost) {
    return 'Das verbraucht: $cost';
  }

  @override
  String neighborsOutcome(String outcome) {
    return 'Nach dem Bestätigen: $outcome';
  }

  @override
  String get neighborsHelpAction => 'Helfen';

  @override
  String get neighborsDefenseAction => 'Schützen';

  @override
  String get neighborsCrossDecline => 'Ablehnen';

  @override
  String neighborsUsesPlant(String plant) {
    return 'Pflanze: $plant';
  }

  @override
  String get neighborsPlantStays => 'Diese Pflanze bleibt bei ihrem Besitzer.';

  @override
  String get neighborsPlantLeaves => 'Diese Pflanze wird verbraucht.';

  @override
  String neighborsMemoryHelped(String name) {
    return '$name hat deiner Pflanze geholfen.';
  }

  @override
  String neighborsMemoryDefended(String name) {
    return 'Das Tier von $name hat den Garten geschützt.';
  }

  @override
  String neighborsMemoryCrossed(String name) {
    return 'Du und $name habt eine neue Pflanze erhalten.';
  }

  @override
  String neighborsMemoryThanked(String name) {
    return 'Du hast $name gedankt.';
  }

  @override
  String neighborsMemoryRaid(String name) {
    return 'Angriffsbericht mit $name.';
  }

  @override
  String get neighborsReasonUnsupported =>
      'Diese gemeinsame Aktion ist noch nicht verfügbar.';

  @override
  String get neighborsReasonNotAllowed =>
      'Diese Aktion ist für diesen Spieler nicht verfügbar.';

  @override
  String get neighborsReasonMissingPet =>
      'Ein schützendes Tier wird gebraucht.';

  @override
  String get neighborsReasonMissingPlant =>
      'Die Pflanze für diese Aktion wird gebraucht.';

  @override
  String neighborsProtector(String name) {
    return 'Beschützer: $name';
  }

  @override
  String neighborsUntil(String time) {
    return 'Bis $time';
  }

  @override
  String neighborsAttackPower(int value) {
    return 'Angriff $value';
  }

  @override
  String neighborsDefensePower(int value) {
    return 'Verteidigung $value';
  }

  @override
  String neighborsLoot(int count) {
    return 'Mögliche Essenz: $count';
  }

  @override
  String get showcaseTitle => 'Pflanzenvitrine';

  @override
  String get showcaseAll => 'Alle Pflanzen';

  @override
  String get showcaseMine => 'Meine Pflanzen';

  @override
  String get showcaseManage => 'Meine Pflanzen ausstellen';

  @override
  String get showcaseRefresh => 'Vitrine aktualisieren';

  @override
  String get showcaseIntro =>
      'Entdecke Pflanzen anderer Spieler. Auf jeder Karte steht der Besitzer.';

  @override
  String get showcaseMyIntro =>
      'Wähle eine geerntete Pflanze. Andere sehen sie zusammen mit deinem Spielernamen. Sie bleibt im Lager und kann nicht an ein Tier verfüttert werden, solange sie ausgestellt ist.';

  @override
  String get showcaseEmpty =>
      'Noch keine Pflanzen in der Vitrine. Du kannst die erste ausstellen.';

  @override
  String get showcaseChoose => 'Pflanze wählen';

  @override
  String get showcaseNoPlants =>
      'Ernte eine Pflanze aus dem Garten, um sie auszustellen.';

  @override
  String get showcasePublish => 'Ausstellen';

  @override
  String get showcaseWithdraw => 'Aus der Vitrine nehmen';

  @override
  String get showcasePublished => 'Öffentlich ausgestellt';

  @override
  String get showcasePrivate => 'Nur du siehst diese Pflanze';

  @override
  String get showcaseUnconfirmed =>
      'Veröffentlichung nicht bestätigt. Wiederhole sie oder nimm die Pflanze aus der Vitrine.';

  @override
  String get showcasePublishedNotice =>
      'Deine Pflanze ist jetzt öffentlich ausgestellt.';

  @override
  String get showcaseRemovedNotice =>
      'Pflanze aus der Vitrine genommen. Du kannst sie wieder verwenden.';

  @override
  String get showcaseUnavailable =>
      'Die Online-Vitrine ist nicht verfügbar. Deine Pflanzen sind noch hier.';

  @override
  String get showcaseLoadFailed =>
      'Die Vitrine konnte nicht aktualisiert werden. Prüfe die Verbindung und versuche es noch einmal.';

  @override
  String get showcaseOperationFailed =>
      'Die Aktion konnte nicht bestätigt werden. Deine Pflanze ist geschützt; versuche es erneut, wenn du verbunden bist.';

  @override
  String get showcaseMissingLocal =>
      'Diese veröffentlichte Pflanze ist nicht im Lager dieses Geräts.';

  @override
  String get showcaseMore => 'Weitere Pflanzen laden';

  @override
  String showcaseSpecimen(int number) {
    return 'Pflanze $number';
  }

  @override
  String get showcaseFeedLocked =>
      'Ausgestellte Pflanzen können nicht an Tiere verfüttert werden. Nimm sie zuerst aus der Vitrine.';

  @override
  String get crossOpen => 'Pflanzen kreuzen';

  @override
  String get crossTitle => 'Kreuzung';

  @override
  String get crossNeedTwo => 'Wähle zwei geerntete Pflanzen.';

  @override
  String get crossAimCombat => 'Kampffutter';

  @override
  String get crossAimGarden => 'Reicheres Beet';

  @override
  String get crossAimSeeds => 'Samen wählen';

  @override
  String crossOdds(int ordinary, int raised, int rare) {
    return 'Gewöhnlich $ordinary%. Stärker $raised%. Selten $rare%.';
  }

  @override
  String get crossConfirm => 'Kreuzen';

  @override
  String get crossFailed =>
      'Die Kreuzung konnte nicht gespeichert werden. Versuch es erneut.';

  @override
  String get crossListed => 'Nimm die Pflanze zuerst aus der Vitrine.';

  @override
  String get crossWaiting => 'Schließe zuerst die laufende Kreuzung ab.';

  @override
  String get crossChooseTrait =>
      'Wähle Angriff oder Verteidigung für dieses Futter.';

  @override
  String get crossAttack => 'Angriff';

  @override
  String get crossDefense => 'Verteidigung';

  @override
  String get crossChooseSpecies => 'Wähle den Samen.';

  @override
  String get crossOrdinary =>
      'Die Kreuzung blieb gewöhnlich. Ein gewöhnlicher Samen wurde hinzugefügt.';

  @override
  String get crossGranted => 'Der Samen aus der Kreuzung liegt im Vorrat.';

  @override
  String get crossTraitAttack => 'Angriffsfutter';

  @override
  String get crossTraitDefense => 'Verteidigungsfutter';

  @override
  String get crossTraitBloom => 'Wächst schneller';

  @override
  String get plantOriginCross => 'Herkunft: Kreuzung';

  @override
  String get neighborsActions => 'Aktionen';

  @override
  String get neighborsActionMessage => 'Nachricht senden';

  @override
  String get neighborsActionDefend => 'Beschützen';

  @override
  String get neighborsActionCross => 'Kreuzung anbieten';

  @override
  String get neighborsActionRaid => 'Angreifen';

  @override
  String get neighborsActionsOffline =>
      'Aktionen mit Spielern brauchen eine Internetverbindung.';

  @override
  String get neighborsNeedGuard => 'Wähle zuerst im Tierhof ein Wachtier aus.';

  @override
  String get neighborsNeedRaider =>
      'Wähle zuerst im Tierhof ein Tier für Überfälle aus.';

  @override
  String get neighborsNeedPlant =>
      'Du brauchst eine geerntete Pflanze im Lager.';

  @override
  String get neighborsChoosePhrase => 'Wähle einen Satz';

  @override
  String get neighborsChoosePlant => 'Wähle eine Pflanze zum Abgeben';

  @override
  String get neighborsSend => 'Senden';

  @override
  String neighborsSent(String name) {
    return 'An $name gesendet.';
  }

  @override
  String get neighborsAlreadyOpen =>
      'Mit diesem Spieler gibt es schon eine offene Anfrage dieser Art.';

  @override
  String get neighborsRequestClosed =>
      'Diese Anfrage ist bereits abgeschlossen.';

  @override
  String get neighborsSendFailed =>
      'Das hat nicht geklappt. Prüfe die Verbindung und versuche es erneut.';

  @override
  String neighborsDefendExplain(String name, int value) {
    return 'Wenn $name annimmt, bewacht dein Tier 24 Stunden lang den Hof mit. Verteidigung $value.';
  }

  @override
  String neighborsRaidExplain(String name, int value) {
    return '$name hat 24 Stunden, um einen Wächter aufzustellen. Der Hof hält nur, wenn der Wächter stärker ist als dein Angriff $value. Sonst verbrennt eine Pflanze und du nimmst eine andere mit.';
  }

  @override
  String get neighborsCrossExplain =>
      'Jeder gibt eine Pflanze und erhält einen Samen des Ergebnisses. Deine Pflanze wird erst verbraucht, wenn du den Samen nimmst.';

  @override
  String get neighborsMessages => 'Nachrichten und Anfragen';

  @override
  String get neighborsPhraseHello => 'Hallo, Nachbar!';

  @override
  String get neighborsPhraseGoodLuck => 'Viel Glück!';

  @override
  String get neighborsPhraseThanks => 'Danke!';

  @override
  String get neighborsPhraseNiceGarden => 'Schöner Garten!';

  @override
  String get neighborsPhraseLetsCross =>
      'Lass uns zusammen etwas Seltenes züchten.';

  @override
  String get neighborsPhraseIWillGuard => 'Ich passe auf deinen Hof auf.';

  @override
  String get neighborsPhraseReadyForRaid => 'Bereit? Ich komme zu deinem Hof!';

  @override
  String get neighborsPhraseWellPlayed => 'Gut gespielt!';

  @override
  String neighborsInMessage(String name) {
    return '$name hat dir geschrieben';
  }

  @override
  String neighborsInDefense(String name, int value) {
    return '$name bietet an, deinen Hof 24 Stunden zu bewachen. Verteidigung $value.';
  }

  @override
  String neighborsInCross(String name, String plant) {
    return '$name bietet an, $plant mit einer deiner Pflanzen zu kreuzen.';
  }

  @override
  String neighborsInRaid(String name, int value) {
    return '$name überfällt deinen Hof. Angriff $value.';
  }

  @override
  String get neighborsOutMessage => 'Du hast geschrieben';

  @override
  String neighborsOutDefense(int value) {
    return 'Du hast Schutz angeboten. Verteidigung $value.';
  }

  @override
  String neighborsOutCross(String plant) {
    return 'Du hast $plant zur Kreuzung angeboten.';
  }

  @override
  String neighborsOutRaid(int value) {
    return 'Du hast diesen Hof überfallen. Angriff $value.';
  }

  @override
  String neighborsQuote(String name, String text) {
    return '$name: „$text“';
  }

  @override
  String get neighborsYou => 'Du';

  @override
  String get neighborsAcceptDefense => 'Schutz annehmen';

  @override
  String get neighborsChooseCrossPlant => 'Eigene Pflanze wählen';

  @override
  String get neighborsRepel => 'Hof verteidigen';

  @override
  String get neighborsCancelRequest => 'Anfrage zurückziehen';

  @override
  String get neighborsClaimSeed => 'Samen nehmen';

  @override
  String neighborsRaidWon(int attack, int defense) {
    return 'Der Überfall ist gelungen: Angriff $attack gegen Verteidigung $defense.';
  }

  @override
  String neighborsRaidRepelled(int attack, int defense) {
    return 'Der Hof hat gehalten: Angriff $attack gegen Verteidigung $defense.';
  }

  @override
  String neighborsGuarding(String time) {
    return 'Der Schutz gilt bis $time.';
  }

  @override
  String get neighborsGuardEnded => 'Der Schutz ist abgelaufen.';

  @override
  String neighborsCrossResult(String plant) {
    return 'Ergebnis der Kreuzung: Samen von $plant.';
  }

  @override
  String get neighborsSeedClaimed => 'Der Samen liegt in deinem Samenvorrat.';

  @override
  String neighborsSeedMissing(String plant) {
    return 'Lege $plant ins Lager, um den Samen zu nehmen.';
  }

  @override
  String neighborsYourDefense(int value) {
    return 'Verteidigung deines Hofes: $value';
  }

  @override
  String get neighborsReplied => 'Antwort gesendet.';

  @override
  String get neighborsSignalMessage => 'Neue Nachricht';

  @override
  String get neighborsSignalDefense => 'Bietet Schutz an';

  @override
  String get neighborsSignalRaid => 'Überfällt deinen Hof';

  @override
  String get neighborsSignalResult => 'Antwort erhalten';

  @override
  String get socialFriends => 'Freunde';

  @override
  String get socialFriend => 'Ihr seid befreundet';

  @override
  String get socialFriendsEmpty =>
      'Noch keine Freunde. Öffne das Profil eines Nachbarn und lade ihn ein. Nach der Annahme erscheint er hier.';

  @override
  String get socialIncoming => 'Freundschaftsanfrage';

  @override
  String get socialWaiting => 'Wartet auf Annahme';

  @override
  String get socialUnavailable =>
      'Verbindung fehlgeschlagen. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get socialChat => 'Unterhaltung';

  @override
  String get socialRemoveFriend => 'Freund entfernen';

  @override
  String get socialFriendConsent =>
      'Mit der Annahme könnt ihr euch gegenseitig private Nachrichten senden.';

  @override
  String get socialAccept => 'Freundschaft annehmen';

  @override
  String get socialInvite => 'Als Freund einladen';

  @override
  String get socialInvitesClosed =>
      'Dieser Spieler nimmt gerade keine Freundschaftsanfragen an.';

  @override
  String get socialMyProfile => 'Mein Profil';

  @override
  String get socialProfilePublic =>
      'Diese freiwilligen Angaben sind für andere Spieler sichtbar.';

  @override
  String get socialAbout => 'Über mich';

  @override
  String get socialLanguage => 'Sprachen für Gespräche';

  @override
  String get socialInterests => 'Interessen';

  @override
  String get socialGoal => 'Was ich im Spiel suche';

  @override
  String get socialPicAboutFriendly => 'Freundlich';

  @override
  String get socialPicAboutCalm => 'Ruhig';

  @override
  String get socialPicAboutCheerful => 'Fröhlich';

  @override
  String get socialPicAboutGentle => 'Sanft';

  @override
  String get socialPicAboutNight => 'Abends';

  @override
  String get socialPicAboutCurious => 'Neugierig';

  @override
  String get socialPicInterestGarden => 'Garten';

  @override
  String get socialPicInterestPets => 'Haustiere';

  @override
  String get socialPicInterestMahjong => 'Mahjong';

  @override
  String get socialPicInterestCourtyard => 'Hof';

  @override
  String get socialPicInterestSeeds => 'Samen';

  @override
  String get socialPicInterestStars => 'Sterne';

  @override
  String get socialPicGoalFlower => 'Eine seltene Blume';

  @override
  String get socialPicGoalHouse => 'Ein schöneres Haus';

  @override
  String get socialPicGoalFriends => 'Freunde';

  @override
  String get socialPicGoalLevels => 'Level schaffen';

  @override
  String get socialPicGoalChat => 'Ein Gespräch';

  @override
  String get socialPicGoalCross => 'Kreuzung';

  @override
  String get socialOpenInvites => 'Neue Freundschaftsanfragen erlauben';

  @override
  String get socialSave => 'Profil speichern';

  @override
  String get socialProfileHeading => 'Profil';

  @override
  String get socialNotChosen => 'Nicht gewählt';

  @override
  String get socialInvitesOpen => 'Nimmt Freundschaftsanfragen an';

  @override
  String get socialBadgesTitle => 'Abzeichen in der Nachbarliste';

  @override
  String get socialBadgesExplain =>
      'Für Punkte sehen Nachbarn eine Zeit lang deinen Avatar und deine Profilabzeichen neben deinem Namen.';

  @override
  String socialBadgesActive(String time) {
    return 'Für Nachbarn sichtbar bis $time';
  }

  @override
  String get socialBadgesOff => 'Gerade zeigt die Liste nur deinen Namen.';

  @override
  String socialBadgesOffer(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage',
      one: '1 Tag',
    );
    return '$_temp0 · $price Punkte';
  }

  @override
  String get socialBadgesTooLong =>
      'Die Anzeige lässt sich höchstens 30 Tage im Voraus verlängern.';

  @override
  String get socialBadgesFailed =>
      'Abzeichen konnten nicht aktiviert werden. Deine Punkte wurden erstattet.';

  @override
  String get socialBadgesNotListed =>
      'Du bist noch nicht in der Nachbarliste. Prüfe die Verbindung und versuche es erneut. Es wurden keine Punkte abgezogen.';

  @override
  String get socialChatEmpty => 'Sag Hallo oder bedanke dich für die Hilfe!';

  @override
  String get socialReportMessage => 'Nachricht melden';

  @override
  String get socialOlderMessages => 'Ältere Nachrichten';

  @override
  String get socialSendFailed =>
      'Versand nicht bestätigt. Versuche es erneut oder prüfe die Freundschaft im Profil.';

  @override
  String get socialMessageHint => 'Nachricht schreiben';

  @override
  String get socialGrownTogether => 'Gemeinsam gezogen mit';

  @override
  String get socialHistoryEmpty =>
      'Hier erscheinen eure gemeinsamen Erlebnisse.';

  @override
  String get socialHistory => 'Gemeinsame Erlebnisse';

  @override
  String get socialProfileReport => 'Profil melden';

  @override
  String neighborsRaidDeadline(String time) {
    return 'Ohne Antwort bis $time verteidigt der zugewiesene Wächter von selbst.';
  }

  @override
  String get neighborsRaidDefendTitle => 'Wer verteidigt den Hof?';

  @override
  String neighborsRaidDefendRule(int value) {
    return 'Angriff $value. Nur ein stärkerer Wächter hält den Hof.';
  }

  @override
  String neighborsRaidOptionOwn(String pet, int value) {
    return '$pet · Verteidigung $value';
  }

  @override
  String neighborsRaidOptionGuard(String name, int value) {
    return 'Wächter von $name · Verteidigung $value';
  }

  @override
  String neighborsRaidOptionHelp(String name, int value) {
    return '$name folgt dem Hilferuf · Verteidigung $value';
  }

  @override
  String get neighborsRaidOptionNone => 'Nicht verteidigen';

  @override
  String get neighborsRaidHolds => 'Hält';

  @override
  String get neighborsRaidFalls => 'Zu schwach';

  @override
  String get neighborsRaidNoDefenders =>
      'Du hast keine Wächter-Tiere und auf deinen Ruf hat noch niemand geantwortet. Ohne Wächter gelingt der Überfall.';

  @override
  String get neighborsRaidChooseLoss =>
      'Der Hof fällt. Wähle, welche Pflanze verbrennt; der Angreifer nimmt eine zufällige der übrigen.';

  @override
  String neighborsRaidOnlyPlant(String plant) {
    return 'Deine einzige Pflanze, $plant, geht an den Angreifer.';
  }

  @override
  String get neighborsRaidEmptyStorage =>
      'Dein Lager ist leer, der Angreifer geht leer aus.';

  @override
  String get neighborsRaidAcceptLoss => 'Verlust annehmen';

  @override
  String neighborsRaidDestroyed(String plant) {
    return 'Verbrannt: $plant.';
  }

  @override
  String neighborsRaidStolen(String plant) {
    return 'Vom Angreifer genommen: $plant.';
  }

  @override
  String neighborsRaidLoot(String plant) {
    return 'Deine Beute: $plant.';
  }

  @override
  String get neighborsRaidNoLoot => 'Im Lager gab es nichts zu holen.';

  @override
  String get neighborsRaidAutoDefended =>
      'Niemand hat rechtzeitig geantwortet, also verteidigte der zugewiesene Wächter.';

  @override
  String neighborsRaidDefendedBy(String name) {
    return 'Verteidigt von einem Tier von $name.';
  }

  @override
  String get neighborsRaidTakeLoot => 'Pflanze nehmen';

  @override
  String neighborsRaidLootTaken(String plant) {
    return '$plant liegt in deinem Lager.';
  }

  @override
  String get neighborsRaidTooSoon =>
      'Dieser Hof erholt sich von einem Überfall. Versuch es später.';

  @override
  String get neighborsHelpTitle => 'Hilferufe';

  @override
  String neighborsHelpExplain(int price) {
    return 'Freunde sehen deinen Ruf kostenlos. Ein Ruf an alle Spieler kostet $price Punkte. Antwortende Wächter erscheinen in der Verteidigungsliste.';
  }

  @override
  String get neighborsHelpAskFriends => 'Freunde um Hilfe bitten';

  @override
  String neighborsHelpAskEveryone(int price) {
    return 'Alle Spieler rufen · $price Punkte';
  }

  @override
  String get neighborsHelpAskedFriends =>
      'Deine Freunde sehen deinen Hilferuf.';

  @override
  String get neighborsHelpAskedEveryone =>
      'Alle Spieler sehen deinen Hilferuf.';

  @override
  String get neighborsHelpNoFriends =>
      'Du hast noch keine Freunde, die du rufen kannst.';

  @override
  String neighborsHelpArrived(int count) {
    return 'Geantwortete Wächter: $count';
  }

  @override
  String get neighborsHelpFailed =>
      'Der Hilferuf wurde nicht gesendet. Ausgegebene Punkte wurden erstattet.';

  @override
  String neighborsHelpCallLine(String name, int attack) {
    return '$name wird überfallen · Angriff $attack';
  }

  @override
  String neighborsHelpUntil(String time) {
    return 'Offen bis $time';
  }

  @override
  String neighborsHelpSend(int value) {
    return 'Meinen Wächter schicken · Verteidigung $value';
  }

  @override
  String neighborsHelpSent(String name) {
    return 'Dein Wächter ist bereit, $name zu verteidigen.';
  }

  @override
  String get neighborsHelpOffered => 'Dein Wächter ist angeboten.';

  @override
  String get neighborsHelpNeedGuard =>
      'Weise ein Wächter-Tier zu, um zu helfen.';

  @override
  String get plantOriginRaid => 'Bei einem Überfall erbeutet';

  @override
  String get deleteAccount => 'Konto und Daten löschen';

  @override
  String get deleteAccountTitle => 'Konto und Daten löschen?';

  @override
  String get deleteAccountBody =>
      'Das löscht Hof, Fortschritt und Einstellungen auf diesem Gerät. Wenn das Gerät angemeldet ist, wird auch dieses anonyme Konto gelöscht: Ranglisteneintrag, Profil, Freundschaften, Nachrichten, Nachbaraktionen, Hilferufe und Schaukarten. Ein gemeinsames Gespräch oder eine Anfrage verschwindet auch beim anderen Spieler. Meldungen anderer Spieler bleiben bis zum Ende der Prüfung. Das kann nicht rückgängig gemacht werden.';

  @override
  String get deleteAccountConfirm => 'Löschen';

  @override
  String get deleteAccountFailed =>
      'Das Löschen konnte nicht abgeschlossen werden. Prüfe die Verbindung und versuche es erneut, oder schreibe an myevidentsuccess@gmail.com.';

  @override
  String get deleteAccountWorking => 'Wird gelöscht…';
}
