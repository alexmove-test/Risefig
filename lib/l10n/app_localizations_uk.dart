// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get continueGame => 'Продовжити';

  @override
  String get noShuffleMoves =>
      'Немає доступної пари — спробуйте скасування, підказку або магніт';

  @override
  String get shuffleLockedChallenge =>
      'У цьому випробуванні перемішування недоступне';

  @override
  String get specialTile => 'Цільова плитка із зіркою';

  @override
  String continueWith(String title) {
    return 'Продовжити · $title';
  }

  @override
  String get newPlot => 'Нова ділянка';

  @override
  String get previousPlot => 'Попередня ділянка';

  @override
  String get nextPlot => 'Наступна ділянка';

  @override
  String get plotLockedHint => 'Наступні перемоги будуватимуть цю ділянку';

  @override
  String neighborYard(String name) {
    return 'Двір: $name';
  }

  @override
  String neighborRating(String name, int rating) {
    return '$name · $rating';
  }

  @override
  String get neighboringCourtyard => 'Сусідський двір';

  @override
  String get courtyardPanHint => 'Потягніть, щоб оглянути двір';

  @override
  String houseStateTitle(int state, int total) {
    return 'Будинок · $state/$total';
  }

  @override
  String get houseFullyUpgraded => 'Будинок повністю поліпшено';

  @override
  String get houseDetailsShow => 'Докладніше';

  @override
  String get houseDetailsHide => 'Сховати';

  @override
  String upgradeHouseForText(String price) {
    return 'Поліпшити за $price';
  }

  @override
  String pointsShortfallText(String amount) {
    return 'Не вистачає $amount поінтів';
  }

  @override
  String houseUpgradeOfferText(String cost) {
    return 'Поліпшення будинку — $cost';
  }

  @override
  String get nextHouseLook => 'Наступний вигляд будинку';

  @override
  String houseLookLine(int built, int total) {
    return 'Вигляди будинку: побудовано $built із $total';
  }

  @override
  String hubLevelUnlocksPet(int id) {
    return 'Рівень $id відкриє улюбленця';
  }

  @override
  String get hubQuestRewardReady => 'Нагорода тижня чекає';

  @override
  String get hubThreeStarUntilReward => '3★ відкриє нагороду';

  @override
  String hubNeighborEvent(String name, String text) {
    return '$name: $text';
  }

  @override
  String hubHarvestReady(String plant) {
    return 'Урожай готовий: $plant — зберіть';
  }

  @override
  String get hubBedFree => 'Грядка вільна — посадіть насіння';

  @override
  String get today => 'Сьогодні';

  @override
  String get clearedToday => 'День закрито';

  @override
  String streakNights(int n) {
    return 'День $n із 3';
  }

  @override
  String get streakKept => 'Серію збережено';

  @override
  String get streakAtRisk => 'Згасне опівночі';

  @override
  String get keepTheLight => 'Збережи світло';

  @override
  String openedProgress(int unlocked, int total) {
    return 'відкрито $unlocked/$total';
  }

  @override
  String get courtyard => 'До двору';

  @override
  String get howToPlay => 'Як грати';

  @override
  String get levels => 'Рівні';

  @override
  String get retry => 'Спочатку';

  @override
  String get playAgain => 'Ще раз';

  @override
  String get next => 'Далі';

  @override
  String get menu => 'Меню';

  @override
  String get close => 'Закрити';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get back => 'Назад';

  @override
  String get privacyPolicy => 'Політика конфіденційності';

  @override
  String get privacySettings => 'Налаштування конфіденційності';

  @override
  String get hideBannerButton => '24 години';

  @override
  String get hideBannerTitle => 'Прибрати банер на 24 години';

  @override
  String get hideBannerSubtitle =>
      'Подивитися рекламу. На цьому пристрої його не буде.';

  @override
  String get hideBannerWatch => 'Дивитися рекламу';

  @override
  String get hideBannerNotNow => 'Не зараз';

  @override
  String get aboutGame => 'Про гру';

  @override
  String builtAt(String time) {
    return 'Збірка: $time';
  }

  @override
  String get settings => 'Налаштування';

  @override
  String get sound => 'Звук';

  @override
  String get music => 'Музика';

  @override
  String get hapticFeedback => 'Тактильний відгук';

  @override
  String get qMode => 'Режим Q';

  @override
  String get qModeHint => 'Реклама на магніті дає 50';

  @override
  String get dimCoveredTiles => 'Затемнювати закриті';

  @override
  String get dimCoveredTilesHint => 'Сірим — плитки, які не можна взяти';

  @override
  String get tableLook => 'Оформлення столу';

  @override
  String get tableLookClassic => 'Класичний маджонг';

  @override
  String get tableLookClassicHint => 'Об\'ємні кістки й мідні кнопки';

  @override
  String get tableLookCasual => 'Яскравий матч';

  @override
  String get tableLookCasualHint => 'Пласкі плитки, зелень і золото';

  @override
  String get tableLookPremium => 'Нова';

  @override
  String get tableLookPremiumHint =>
      'Порцелянові кістки, теплий дерев\'яний стіл';

  @override
  String get tableLookGift => 'Стіл';

  @override
  String get tableLookUse => 'Взяти';

  @override
  String get tableLookLockedHint => 'Відкриється подарунком двору';

  @override
  String get tableLookSettingsHint => 'Різні теми столу можна вибрати в меню';

  @override
  String get language => 'Мова';

  @override
  String get languageSystem => 'Як у системі';

  @override
  String get tileLocked => 'Плитку заблоковано';

  @override
  String get trayFull => 'Лоток повний';

  @override
  String get trayFullHint => 'Немає пари для збігу.';

  @override
  String get noMovesShuffle => 'Немає ходів — перемішайте';

  @override
  String get youWin => 'Перемога!';

  @override
  String get noFreeTiles => 'Немає відкритих плиток';

  @override
  String get shuffled => 'Перемішано';

  @override
  String get stillNoMoves => 'Досі немає ходів';

  @override
  String get loadingAd => 'Завантаження реклами…';

  @override
  String get rewardNotEarned => 'Нагороду не отримано';

  @override
  String get adUnavailable =>
      'Не вдалося завантажити рекламу. Натисніть ще раз.';

  @override
  String get noUsefulMoves => 'Немає корисних ходів';

  @override
  String get continuing => 'Продовжуємо';

  @override
  String get moveUndone => 'Хід скасовано';

  @override
  String get noMatchingTiles => 'Немає відповідних плиток';

  @override
  String get couldNotOpenLink => 'Не вдалося відкрити посилання';

  @override
  String get dailyComplete => 'Сьогодні зіграно';

  @override
  String streakLabel(int n) {
    return 'Серія: $n';
  }

  @override
  String score(int value) {
    return 'Рахунок: $value';
  }

  @override
  String starsCount(int n) {
    return '$n ★';
  }

  @override
  String get dailyBonus => 'Запас: +1 підказка і перемішування';

  @override
  String get points => 'Бали';

  @override
  String pointsBalanceText(String value) {
    return 'Бали: $value';
  }

  @override
  String get pointsShopTitle => 'Бали';

  @override
  String get pointsShopSubtitle =>
      'Накопичуються за пройдені рівні. Поповнити можна будь-коли.';

  @override
  String pointsEarnRuleText(int perClear, int perStar) {
    return 'За пройдений рівень +$perClear, і ще +$perStar за кожну зірку.';
  }

  @override
  String pointsPackBonus(int percent) {
    return '+$percent% зверху';
  }

  @override
  String get pointsPackPopular => 'Беруть найчастіше';

  @override
  String get pointsPackBest => 'Найвигідніше';

  @override
  String get pointsBuy => 'Купити';

  @override
  String pointsCreditedText(String value) {
    return 'Зараховано +$value';
  }

  @override
  String get pointsPurchaseCancelled => 'Покупку скасовано';

  @override
  String get pointsPurchaseUnavailable => 'Крамниця недоступна';

  @override
  String get pointsDemoNote =>
      'Оплату ще не підключено — пакет зараховується одразу.';

  @override
  String get pointsWatchAd => 'Дивитися ролик';

  @override
  String pointsWatchAdRewardText(String value) {
    return 'Безкоштовно +$value';
  }

  @override
  String level(int id) {
    return 'Рівень $id';
  }

  @override
  String get anotherLevelCleared => 'Ще один рівень пройдено';

  @override
  String get newBest => 'Новий рекорд!';

  @override
  String levelUnlocked(int id) {
    return 'Відкрито рівень $id';
  }

  @override
  String get shuffle => 'Перемішати';

  @override
  String get magnet => 'Магніт';

  @override
  String get hint => 'Підказка';

  @override
  String get undo => 'Скасувати';

  @override
  String watchAd(String name) {
    return 'Реклама → $name';
  }

  @override
  String boostEarnedText(int count, String name) {
    return '+$count $name';
  }

  @override
  String get noneLeft => 'немає використань';

  @override
  String get coachTapFree => 'Бери вільну: зверху і збоку відкрита';

  @override
  String get coachMatchPair => 'Пара в лотку знімається';

  @override
  String get coachTrayLimit => 'Лоток на 4 — якщо заб\'ється, партію програно';

  @override
  String get tutorialCollect =>
      'Натисніть вільну плитку — вона потрапить у лоток';

  @override
  String get tutorialMatch =>
      'Зберіть дві однакові — пара зникне. У лотку лише 4 місця.';

  @override
  String get tutorialLayers =>
      'Нижню не можна взяти, поки вона закрита зверху.';

  @override
  String get tutorialBoosts =>
      'Підказка підсвітить хід, магніт збере пару, скасування поверне хід.';

  @override
  String get tutorialSkip => 'Пропустити';

  @override
  String get featureGotIt => 'Зрозуміло';

  @override
  String get featureNewBadge => 'НОВЕ';

  @override
  String get featureNewGarden =>
      'Нове: грядки у дворі — натисніть грядку, щоб посадити насінину';

  @override
  String featureUnlockGoal(int count, String feature) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ще $count рівня',
      many: 'Ще $count рівнів',
      few: 'Ще $count рівні',
      one: 'Ще $count рівень',
    );
    return '$_temp0 — відкриється: $feature';
  }

  @override
  String get winPointsHint => 'Витрачайте бали на будинок у дворі';

  @override
  String get replayTips => 'Показати підказки знову';

  @override
  String get replayTipsDone => 'Підказки з\'являться знову';

  @override
  String get featureTitleHouse => 'Будинок';

  @override
  String get featureTitleGarden => 'Город';

  @override
  String get featureTitleSeeds => 'Насіння';

  @override
  String get featureBodyHouse =>
      'За рівні дають бали. Витрачайте їх тут на поліпшення будинку — він же виробляє насіння для городу.';

  @override
  String get featureBodyPoints =>
      'Бали приходять за кожен пройдений рівень. Ними платять за поліпшення будинку і посадку.';

  @override
  String get featureBodyGarden =>
      'Посадіть насінину на грядку, зачекайте і зберіть рослину. Рослинами годують улюбленців, їх можна показати сусідам.';

  @override
  String get featureBodyWarehouse =>
      'Тут зберігаються зібрані рослини. Годуйте ними улюбленців, схрещуйте дві в одну або виставляйте на вітрину.';

  @override
  String get featureBodySeeds =>
      'Тут лежить насіння, яке виробив будинок. Саджайте його на грядки городу.';

  @override
  String get featureBodyCross =>
      'Дві рослини перетворюються на одну нову насінину. Сильний або рідкісний результат — шанс, а не обіцянка.';

  @override
  String get featureBodyNeighbors =>
      'На пагорбах живуть гравці поруч із вами в рейтингу. Пишіть їм і об\'єднуйтеся для схрещування та захисту.';

  @override
  String get featureBodyShowcase =>
      'Покажіть усім найкращі рослини і подивіться, що вирощують інші гравці.';

  @override
  String get featureBodyLeaderboard =>
      'Зірки і перемоги за тиждень піднімають вас у рейтингу серед інших гравців.';

  @override
  String get featureBodyPets =>
      'Улюбленець живе у дворі. Годуйте його рослинами з городу.';

  @override
  String get easy => 'Легко';

  @override
  String get normal => 'Нормально';

  @override
  String get hard => 'Складно';

  @override
  String get expert => 'Експерт';

  @override
  String get you => 'Ви';

  @override
  String get player => 'Гравець';

  @override
  String get yourName => 'Ваше ім\'я';

  @override
  String get youClimbed => 'Ви піднялися!';

  @override
  String rankClimbPlaces(int from, int to) {
    return 'Місце $from → $to';
  }

  @override
  String get leaderboard => 'Загальний рейтинг';

  @override
  String get refresh => 'Оновити';

  @override
  String get changeName => 'Змінити ім\'я';

  @override
  String get nameNotAllowed => 'Таке ім\'я не можна. Оберіть інше.';

  @override
  String get rankingNamesNote =>
      'Імена задають гравці. Поскаржтеся або сховайте тих, хто порушує правила.';

  @override
  String get reportPlayer => 'Поскаржитися або сховати';

  @override
  String get reportName => 'Поскаржитися на ім\'я';

  @override
  String get hidePlayer => 'Сховати цього гравця';

  @override
  String get reportThanks => 'Дякуємо. Ми перевіримо це ім\'я.';

  @override
  String get playerHidden => 'Гравця сховано на пристрої.';

  @override
  String get name => 'Ім\'я';

  @override
  String onlineRanking(int top) {
    return 'Онлайн-рейтинг · топ $top';
  }

  @override
  String get offlineRanking => 'Офлайн: показано лише ваш результат.';

  @override
  String get rankingFormula =>
      'Рейтинг: зірки × 100 000 + найкращі рахунки + прогрес кампанії.';

  @override
  String get scorePlotsLegend => 'Бали : ділянки';

  @override
  String get loadRankingFailed => 'Не вдалося завантажити онлайн-рейтинг';

  @override
  String starsLevel(int stars, int unlocked) {
    return '$stars ★ · рів. $unlocked';
  }

  @override
  String get ad => 'РЕКЛАМА';

  @override
  String get done => 'Готово';

  @override
  String get closeWithoutReward => 'Закрити без нагороди';

  @override
  String get simulatedAd => 'Імітація реклами';

  @override
  String get watchClipForBoost => 'Додивіться ролик, щоб отримати буст';

  @override
  String get claimReward => 'Отримати нагороду';

  @override
  String get watchingAd => 'Дивіться рекламу…';

  @override
  String get weeklyQuests => 'Завдання тижня';

  @override
  String get claim => 'Забрати';

  @override
  String get claimed => 'Отримано';

  @override
  String get questBonus => '+1 підказка і перемішування';

  @override
  String get extraBoostThisWeek => '+1 буст на столі сьогодні';

  @override
  String get seasonClosed => 'Сезон закрито';

  @override
  String lastWeekPlace(int rank) {
    return 'Минулий тиждень: місце $rank';
  }

  @override
  String lastWeekScore(String rating) {
    return 'Рахунок $rating';
  }

  @override
  String get reminders => 'Нагадування';

  @override
  String get reminderDailyTitle => 'Двір чекає на вас';

  @override
  String get reminderDailyBody => 'Сьогодні готовий новий стіл.';

  @override
  String get reminderStreakTitle => 'Серія зараз згасне';

  @override
  String get reminderStreakBody => 'Третій ліхтар згасне опівночі.';

  @override
  String get reminderWeekTitle => 'Новий сезон двору';

  @override
  String get reminderWeekBody => 'Завдання й рейтинг тижня оновилися.';

  @override
  String get pet => 'Улюбленець';

  @override
  String get pets => 'Улюбленці';

  @override
  String get chooseAPet => 'Оберіть улюбленця';

  @override
  String get addPet => 'Додати улюбленця';

  @override
  String get petInviteAdopt => 'Друг чекає на тебе';

  @override
  String get petInviteShow => 'Показати улюбленців';

  @override
  String get petYardStartAdventure => 'Почати пригоду';

  @override
  String get petYardVisit => 'Зазирнути в куточок';

  @override
  String get petYardShow => 'Показати у дворі';

  @override
  String get petYardShowing => 'У дворі';

  @override
  String get petYardShowAll => 'Показати всіх у дворі';

  @override
  String get petCareHint =>
      'Перемоги допомагають із грою та відпочинком. Годуйте зібраними рослинами зі складу.';

  @override
  String get petStarvingLine => 'Голодує. Погодуйте рослиною зі складу.';

  @override
  String get petRemindersPromptTitle => 'Нагадати про голод?';

  @override
  String get petRemindersPromptBody =>
      'Можемо нагадати, коли улюбленець зголодніє.';

  @override
  String get petRemindersYes => 'Нагадати';

  @override
  String get petRemindersLater => 'Не зараз';

  @override
  String reminderPetHungerTitle(String name) {
    return '$name хоче їсти';
  }

  @override
  String get reminderPetHungerBody => 'Погодуйте рослиною зі складу.';

  @override
  String reminderPetPlayTitle(String name) {
    return '$name хоче грати';
  }

  @override
  String get reminderPetPlayBody => 'Пройдіть рівень, щоб пограти.';

  @override
  String reminderPetRestTitle(String name) {
    return '$name хоче відпочити';
  }

  @override
  String get reminderPetRestBody =>
      'Пройдіть рівень — улюбленцю потрібен відпочинок.';

  @override
  String reminderPetStarveTitle(String name) {
    return '$name голодує';
  }

  @override
  String get reminderPetStarveBody => 'Погодуйте рослиною зі складу.';

  @override
  String petLevelLabel(int level) {
    return 'Рівень $level';
  }

  @override
  String petLevelShort(int level) {
    return 'Рів. $level';
  }

  @override
  String get petMaxLevel => 'Максимальний рівень';

  @override
  String petXpLabel(int xp, int need) {
    return 'Досвід $xp / $need';
  }

  @override
  String petStrengthLineText(String stat, int total) {
    return '$stat $total';
  }

  @override
  String petLevelChange(int from, int to) {
    return 'Рівень $from → $to';
  }

  @override
  String petStatChange(String stat, int from, int to) {
    return '$stat $from → $to';
  }

  @override
  String get petFeed => 'Погодувати';

  @override
  String get petFeedTitle => 'Вибір рослини';

  @override
  String get petFeedEmpty => 'На складі немає зібраних рослин.';

  @override
  String get petFeedPointless => 'Улюбленець ситий, і рівень уже максимальний.';

  @override
  String petFeedXp(int xp) {
    return 'Досвід: $xp';
  }

  @override
  String get petFeedSatiety => 'Відновить ситість. Сила не зросте.';

  @override
  String get petFeedConfirm => 'Згодувати цю рослину';

  @override
  String petFedReaction(String name) {
    return '$name задоволено їсть.';
  }

  @override
  String get petFeedFailed => 'Не вдалося зберегти. Рослину не витрачено.';

  @override
  String get petFeedMissing => 'Цієї рослини вже немає на складі.';

  @override
  String get petGuardAction => 'Охороняти город';

  @override
  String get petGuarding => 'Охороняє город';

  @override
  String get petStopGuard => 'Зняти охорону';

  @override
  String get petRaidAction => 'Обрати для набігів';

  @override
  String get petRaiding => 'Обрано для набігів';

  @override
  String get petStopRaid => 'Зняти вибір набігу';

  @override
  String gardenGuardLabel(String name, int power) {
    return '$name охороняє город. Захист $power';
  }

  @override
  String get gardenNoDefender => 'Захисника поки немає';

  @override
  String get gardenUnguarded => 'Город без охорони';

  @override
  String get boardSemantic => 'Поле';

  @override
  String traySemantic(int filled, int capacity) {
    return 'Лоток, $filled із $capacity';
  }

  @override
  String get trayEmptySlot => 'Порожній слот';

  @override
  String get trayAlmostFull => 'Залишилося одне місце — знайдіть пару';

  @override
  String get houseCardTitle => 'Будинок';

  @override
  String get seedsHeading => 'Насіння';

  @override
  String seedsButton(int count) {
    return 'Насіння · $count';
  }

  @override
  String seedPowerStep(int from, int to) {
    return 'Сила насіння: $from → $to';
  }

  @override
  String seedCostStep(int from, int to) {
    return 'Вартість виробництва: $from → $to поінтів';
  }

  @override
  String seedSpeciesUnlock(String name) {
    return 'Новий вид: $name';
  }

  @override
  String seedDurationStep(String from, String to) {
    return 'Час виробництва: $from → $to';
  }

  @override
  String seedChanceStep(String summary) {
    return 'Шанси: $summary';
  }

  @override
  String get seedClassCommon => 'Звичайні';

  @override
  String get seedClassNutrient => 'Поживні';

  @override
  String get seedClassRare => 'Рідкісні';

  @override
  String seedClassLine(String name, int percent) {
    return '$name $percent%';
  }

  @override
  String seedSpan(int minutes, int seconds) {
    return '$minutes хв $seconds с';
  }

  @override
  String seedPowerLabel(int power) {
    return 'Сила насінини: $power';
  }

  @override
  String seedPowerPending(int power) {
    return 'Сила очікуваної насінини: $power';
  }

  @override
  String seedMinutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String get seedSpeciesHeading => 'Можливі види';

  @override
  String get seedEqualChance => 'Однакова ймовірність';

  @override
  String produceSeedForText(String price) {
    return 'Виробити насінину · $price поінтів';
  }

  @override
  String yardSeedOfferText(String price) {
    return 'Виробити\nнасіння\n$price';
  }

  @override
  String yardSeedTimerText(String time) {
    return 'Насіння\n$time';
  }

  @override
  String get yardGrowPlant => 'Виростити рослину';

  @override
  String get watchAdHarvest => 'Ролик · зібрати зараз';

  @override
  String get plantAdUsed => 'Сьогодні ролик уже збирав рослину';

  @override
  String speedUpForText(String price) {
    return 'Прискорити · $price поінтів';
  }

  @override
  String get claimSeed => 'Забрати насінину';

  @override
  String get seedAdded => 'Насінину додано до сховища';

  @override
  String get openSeedStorage => 'Відкрити сховище';

  @override
  String get seedPurpose => 'З цієї насінини можна буде виростити рослину.';

  @override
  String seedHouseLevel(int level) {
    return 'Вироблено будинком рівня $level';
  }

  @override
  String seedReceived(String date) {
    return 'Отримано $date';
  }

  @override
  String seedGroupCount(int count) {
    return '×$count';
  }

  @override
  String get seedSortPower => 'За силою';

  @override
  String get seedSortTime => 'За часом отримання';

  @override
  String get seedProducing => 'Насінина вирощується';

  @override
  String get seedReadyTitle => 'Насінина готова';

  @override
  String get seedUnknown => 'Невідома насінина';

  @override
  String seedTimeLeft(int minutes, int seconds) {
    return 'Залишилося $minutes хв $seconds с';
  }

  @override
  String get seedBadgeIdle => 'Виробництво насіння доступне';

  @override
  String seedBadgeProducing(String time) {
    return 'Насінина вирощується, залишилося $time';
  }

  @override
  String get seedBadgeReady => 'Насінину можна забрати';

  @override
  String get seedReadyMark => 'Готово';

  @override
  String get seedPlayMahjong => 'Грати в маджонг';

  @override
  String get produceFirstSeed => 'Виробити першу насінину';

  @override
  String get seedsEmptyBody => 'Будинок ще не виробив жодної насінини.';

  @override
  String seedStackLabel(String name, int power, int count) {
    return '$name, сила $power, $count';
  }

  @override
  String get seedProductionTitle => 'Виробництво насіння';

  @override
  String plantsButton(int count) {
    return 'Рослини · $count';
  }

  @override
  String get warehouseTitle => 'Склад';

  @override
  String warehouseSemantic(int count) {
    return 'Склад, рослин $count';
  }

  @override
  String get warehouseEmptyBody => 'Тут зберігатимуться зібрані рослини';

  @override
  String get openGarden => 'Відкрити город';

  @override
  String plantActionText(int seeds, String points) {
    return 'Посадити · $seeds насінина + $points поінтів';
  }

  @override
  String get chooseSeedTitle => 'Вибір насінини';

  @override
  String get noSeedsBody =>
      'Насіння поки немає. Відкрийте виробництво в будинку.';

  @override
  String get openHouseProduction => 'Відкрити виробництво';

  @override
  String gardenBedEmpty(int number) {
    return 'Грядка $number, порожня';
  }

  @override
  String bedTitle(int number) {
    return 'Грядка $number';
  }

  @override
  String get harvestAction => 'Зібрати';

  @override
  String get harvestMark => 'Зібрати';

  @override
  String plantPower(int power) {
    return 'Сила рослини: $power';
  }

  @override
  String plantCostLabelText(String points) {
    return 'Вартість посадки: $points поінтів';
  }

  @override
  String growDurationLabel(int minutes) {
    return 'Час вирощування: $minutes хв';
  }

  @override
  String seedsAvailable(int count) {
    return 'Доступно: $count';
  }

  @override
  String get plantPreviewLabel => 'Майбутня рослина';

  @override
  String plantVariant(String variant) {
    return 'Зовнішній варіант: $variant';
  }

  @override
  String plantedOn(String date) {
    return 'Посаджено $date';
  }

  @override
  String maturedOn(String date) {
    return 'Дозріло $date';
  }

  @override
  String harvestedOn(String date) {
    return 'Зібрано $date';
  }

  @override
  String get gardenSaveFailed => 'Не вдалося зберегти. Нічого не списано.';

  @override
  String get gardenNotReady => 'Ще не дозріло';

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
  String get challengeCompactTower => 'Вежа: розберіть усі шари';

  @override
  String challengeSpecialPair(int cleared) {
    return 'Зніміть дві плитки із зіркою · $cleared/2';
  }

  @override
  String get challengeNoShuffle => 'Розберіть поле без перемішування';

  @override
  String plotKindTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'house': 'Будинок',
      'pond': 'Ставок',
      'pets': 'Улюбленці',
      'guest': 'Будинок для гостей',
      'other': 'Будинок',
    });
    return '$_temp0';
  }

  @override
  String plotKindTitleToward(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'house': 'будинку',
      'pond': 'ставка',
      'pets': 'улюбленців',
      'guest': 'будинку для гостей',
      'other': 'будинку',
    });
    return '$_temp0';
  }

  @override
  String plotLookComplete(String name) {
    return '$name зібрано';
  }

  @override
  String plotLookNextOne(String name) {
    return '1 рівень до наступного вигляду: $name';
  }

  @override
  String plotLookProgressText(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рів. до наступного вигляду: $name',
      one: '1 рівень до наступного вигляду: $name',
      zero: '$name зібрано',
    );
    return '$_temp0';
  }

  @override
  String get nextWinUpgradesHouse => 'Наступна перемога поліпшить будинок';

  @override
  String winsUntilHouseUpgradeText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'До поліпшення будинку — $count перемог',
      many: 'До поліпшення будинку — $count перемог',
      few: 'До поліпшення будинку — $count перемоги',
      one: 'До поліпшення будинку — $count перемога',
    );
    return '$_temp0';
  }

  @override
  String get nextWinImprovesPond => 'Наступна перемога поліпшить ставок';

  @override
  String winsUntilPondUpgradeText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'До поліпшення ставка — $count перемог',
      many: 'До поліпшення ставка — $count перемог',
      few: 'До поліпшення ставка — $count перемоги',
      one: 'До поліпшення ставка — $count перемога',
    );
    return '$_temp0';
  }

  @override
  String get nextPondLook => 'Наступний вигляд ставка';

  @override
  String hubStarsUntilPlotText(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ще $count зірок до $dest',
      many: 'ще $count зірок до $dest',
      few: 'ще $count зірки до $dest',
      one: 'ще $count зірка до $dest',
      zero: 'ще 1 зірка до $dest',
    );
    return '$_temp0';
  }

  @override
  String get oneDailyUntilReward => 'Одна щоденка до нагороди';

  @override
  String hubDailiesUntilRewardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ще $count щоденок до нагороди',
      many: 'ще $count щоденок до нагороди',
      few: 'ще $count щоденки до нагороди',
      one: 'ще $count щоденка до нагороди',
    );
    return '$_temp0';
  }

  @override
  String get oneLevelUntilReward => 'Один рівень до нагороди';

  @override
  String hubLevelsUntilRewardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ще $count рівня до нагороди',
      many: 'ще $count рівнів до нагороди',
      few: 'ще $count рівні до нагороди',
      one: 'ще $count рівень до нагороди',
    );
    return '$_temp0';
  }

  @override
  String courtyardLevelsUntilGift(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ще $count рівнів до подарунка для двору',
      many: 'Ще $count рівнів до подарунка для двору',
      few: 'Ще $count рівні до подарунка для двору',
      one: 'Ще $count рівень до подарунка для двору',
      zero: 'Ще 1 рівень до подарунка для двору',
    );
    return '$_temp0';
  }

  @override
  String hubStarsUntilReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ще $count зірок до нагороди',
      many: 'ще $count зірок до нагороди',
      few: 'ще $count зірки до нагороди',
      one: 'ще $count зірка до нагороди',
      zero: 'ще 1 зірка до нагороди',
    );
    return '$_temp0';
  }

  @override
  String pointsRewardText(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$amount балів',
      many: '+$amount балів',
      few: '+$amount бали',
      one: '+$amount бал',
    );
    return '$_temp0';
  }

  @override
  String get styleFruit => 'Фрукти';

  @override
  String get styleNature => 'Природа';

  @override
  String get styleCourt => 'Двір';

  @override
  String get styleMyth => 'Міф';

  @override
  String get styleClassic => 'Класика';

  @override
  String get styleShape => 'Фігури';

  @override
  String get styleNumber => 'Цифри';

  @override
  String get styleMix => 'Мікс';

  @override
  String get questDaily3 => 'Закрийте daily 3 рази';

  @override
  String get questStars8 => 'Наберіть 8 зірок';

  @override
  String get questClears4 => 'Пройдіть 4 рівні кампанії';

  @override
  String get questThreeStar1 => 'Візьміть 3★ на рівні';

  @override
  String get questStreak3 => 'Три вечори світла';

  @override
  String get weekGarden => 'Тиждень саду';

  @override
  String get weekCourt => 'Тиждень двору';

  @override
  String get weekLanterns => 'Тиждень ліхтарів';

  @override
  String get weekMyth => 'Тиждень міфу';

  @override
  String get weekHarvest => 'Тиждень урожаю';

  @override
  String get weekDefault => 'Стіл цього тижня';

  @override
  String get petCat => 'Кіт';

  @override
  String get petDog => 'Собака';

  @override
  String get petRaccoon => 'Єнот';

  @override
  String get petHamster => 'Хом\'як';

  @override
  String get petFox => 'Лисиця';

  @override
  String get petNeedHunger => 'Голод';

  @override
  String get petNeedPlay => 'Гра';

  @override
  String get petNeedRest => 'Відпочинок';

  @override
  String petMoodContent(String name) {
    return '$name у порядку.';
  }

  @override
  String petMoodAsking(String name) {
    return '$name просить уваги.';
  }

  @override
  String petMoodStarving(String name) {
    return '$name голодує.';
  }

  @override
  String petCareHunger(String name) {
    return 'Ви погодували $name.';
  }

  @override
  String petCarePlay(String name) {
    return 'Ви пограли з $name.';
  }

  @override
  String petCareRest(String name) {
    return 'Ви дали $name відпочити.';
  }

  @override
  String get petRoleAttacker => 'Атакувальний';

  @override
  String get petRoleDefender => 'Захисник';

  @override
  String get petStatAttack => 'Атака';

  @override
  String get petStatDefense => 'Захист';

  @override
  String get growthSown => 'Насінину посаджено';

  @override
  String get growthSprout => 'Паросток';

  @override
  String get growthGrowing => 'Рослина росте';

  @override
  String get growthRipe => 'Можна зібрати';

  @override
  String get seedAmberbell => 'Бурштиновий дзвоник';

  @override
  String get seedMistfern => 'Туманна папороть';

  @override
  String get seedGlassreed => 'Скляний очерет';

  @override
  String get seedCrimsonplum => 'Багряна слива';

  @override
  String get seedNightlotus => 'Нічний лотос';

  @override
  String get seedStarbamboo => 'Зоряний бамбук';

  @override
  String get seedBlurbAmberbell =>
      'Тепле насіння, всередині якого дзвенить крихітний дзвоник.';

  @override
  String get seedBlurbMistfern =>
      'Блідий листок папороті, згорнутий у насіння.';

  @override
  String get seedBlurbGlassreed => 'Прозорий очерет, який дзвенить на світлі.';

  @override
  String get seedBlurbCrimsonplum => 'Темна солодка кісточка дворової сливи.';

  @override
  String get seedBlurbNightlotus =>
      'Фіолетовий бутон, який розкривається після заходу.';

  @override
  String get seedBlurbStarbamboo => 'Членисте зерно з іскоркою на кінчику.';

  @override
  String get plantOriginHouse => 'Походження: виробництво будинку';

  @override
  String plantOriginOther(String source) {
    return 'Походження: $source';
  }

  @override
  String get firstPhraseHouse =>
      'Наступний вигляд будинку купується за поінти.';

  @override
  String get firstPhrasePond => 'Цей ставок наповнюється, поки ти граєш.';

  @override
  String get firstPhrasePets => 'Цей будиночок улюбленця росте, поки ти граєш.';

  @override
  String get firstPhraseGuest => 'Цей двір виходить у мережу, поки ти граєш.';

  @override
  String get pathLifeHouse => 'У будинку стало тепліше.';

  @override
  String get pathLifePond => 'Ставок ожив.';

  @override
  String get pathLifePets => 'У будиночку стало тепліше.';

  @override
  String get pathLifeGuest => 'Двір трохи гуде.';

  @override
  String get rewardPond => 'Маленький ставок';

  @override
  String get rewardSwing => 'Садові гойдалки';

  @override
  String get rewardFlowerBed => 'Квітник';

  @override
  String get tileStateFree => 'вільна';

  @override
  String get tileStateLocked => 'закрита';

  @override
  String tileRemoving(String name) {
    return '$name, зняття пари';
  }

  @override
  String tileInTrayHinted(String name) {
    return '$name у лотку, підказка';
  }

  @override
  String tileInTray(String name) {
    return '$name у лотку';
  }

  @override
  String tileFreeHinted(String name) {
    return '$name, вільна, підказка';
  }

  @override
  String tileLockedHinted(String name) {
    return '$name, закрита, підказка';
  }

  @override
  String tileFreeState(String name) {
    return '$name, вільна';
  }

  @override
  String tileLockedState(String name) {
    return '$name, закрита';
  }

  @override
  String levelCardLocked(int id) {
    return 'Рівень $id, закрито';
  }

  @override
  String levelCardOpen(int id, String title, String stars, String progress) {
    return 'Рівень $id, $title, $stars$progress';
  }

  @override
  String get levelStarsNone => 'без зірок';

  @override
  String levelStarsSome(int count) {
    return '$count ★';
  }

  @override
  String get levelInProgress => ', партію розпочато';

  @override
  String boostLeft(String name, int count) {
    return '$name, залишилося $count';
  }

  @override
  String boostNone(String name) {
    return '$name, немає використань';
  }

  @override
  String get petsNeedCare => 'Улюбленці, потрібна турбота';

  @override
  String dailyButtonSemanticText(String today, String status) {
    return '$today. $status';
  }

  @override
  String courtyardSemanticText(String name) {
    return 'Двір: $name';
  }

  @override
  String gardenBedReady(int number, String name) {
    return 'Грядка $number, $name, можна зібрати';
  }

  @override
  String gardenBedGrowing(int number, String name, String stage, String time) {
    return 'Грядка $number, $name, $stage, залишилося $time';
  }

  @override
  String storyNextItem(String item) {
    return 'Далі: $item';
  }

  @override
  String newGiftItem(String item) {
    return 'Новий подарунок: $item';
  }

  @override
  String storyProgressLine(String title, int progress) {
    return '$title · $progress/3';
  }

  @override
  String newChapterProgress(int progress) {
    return 'Новий розділ · $progress/3';
  }

  @override
  String storyReadyProgress(int stage) {
    return 'Історія чекає · $stage/3';
  }

  @override
  String foxStoryProgress(int stage) {
    return 'Історія лисеняти · $stage/3';
  }

  @override
  String petBadgeText(String role, String level) {
    return '$role, $level';
  }

  @override
  String get chooseAPetYard => 'Обрати улюбленця';

  @override
  String get chooseAPetStatus => 'Обрати улюбленця';

  @override
  String get homeSemantic => 'Будинок';

  @override
  String get petAdventures => 'Пригоди улюбленців';

  @override
  String get adventures => 'Пригоди';

  @override
  String get adventureComplete => 'Пригоду завершено';

  @override
  String get adventureCompleteBang => 'Пригоду завершено!';

  @override
  String get play => 'Грати';

  @override
  String get storyLocked => 'Заверши попередню історію';

  @override
  String get fiveAdventures => '5 пригод';

  @override
  String get foxTitle => 'Затишний куточок лисеняти';

  @override
  String get foxGoal0 => 'Одна перемога — і місце готове';

  @override
  String get foxGoal1 => 'Одна перемога — і з\'явиться лежанка';

  @override
  String get foxGoal2 => 'Одна перемога — і принесемо іграшку';

  @override
  String get foxGoalDone => 'Лисеня тепер удома!';

  @override
  String get foxSeeWhatChanged => 'Подивися, що змінилося!';

  @override
  String get foxHelpSettle => 'Допоможемо облаштуватися · 3 перемоги';

  @override
  String get foxSaveFailed => 'Не вдалося зберегти. Спробуй ще раз.';

  @override
  String get foxIntro =>
      'Лисеня знайшло тихе місце у твоєму дворі. Три перемоги в кампанії — і тут стане затишно.';

  @override
  String get foxStage0 =>
      'Приберемо листя! Переможи на рівні кампанії, щоб підготувати місце.';

  @override
  String get foxStage1 =>
      'Місце готове! Ще одна перемога — і з\'явиться м\'яка лежанка.';

  @override
  String get foxStage2 =>
      'Яка м\'яка лежанка! Обери колір. Ще одна перемога — і принесемо іграшку.';

  @override
  String get foxStageDone =>
      'Лисеня тепер удома! Натисни на нього, щоб пограти. Цей куточок лишається у твоєму дворі.';

  @override
  String get foxHoney => 'Медова';

  @override
  String get foxSkyBlue => 'Блакитна';

  @override
  String get foxBall => 'М\'ячик';

  @override
  String get foxPlushToy => 'М\'яка іграшка';

  @override
  String get later => 'Пізніше';

  @override
  String get foxHelpStages => 'Допомогти · 3 етапи';

  @override
  String get foxLovely => 'Як затишно!';

  @override
  String get foxIsHome => 'Лисеня вдома · 3/3';

  @override
  String get foxStory => 'Історія лисеняти';

  @override
  String get windEast => 'Східний вітер';

  @override
  String get windSouth => 'Південний вітер';

  @override
  String get windWest => 'Західний вітер';

  @override
  String get windNorth => 'Північний вітер';

  @override
  String get familyFruit => 'Фрукт';

  @override
  String get familyFlower => 'Квітка';

  @override
  String get familyAnimal => 'Тварина';

  @override
  String get familyBamboo => 'Бамбук';

  @override
  String get familyCharacter => 'Ієрогліф';

  @override
  String get familyDot => 'Крапка';

  @override
  String get familyDragon => 'Дракон';

  @override
  String get familyWind => 'Вітер';

  @override
  String get familySeason => 'Сезон';

  @override
  String get familyNumber => 'Цифра';

  @override
  String get familyShape => 'Фігура';

  @override
  String get familyTile => 'Плитка';

  @override
  String get familyArt => 'Візерунок';

  @override
  String get familyClown => 'Клоун';

  @override
  String get familyEmperor => 'Імператор';

  @override
  String get familyJoker => 'Джокер';

  @override
  String get familyProfession => 'Професія';

  @override
  String get familyQueen => 'Королева';

  @override
  String get familyEast => 'Схід';

  @override
  String get familySouth => 'Південь';

  @override
  String get familyWest => 'Захід';

  @override
  String get familyNorth => 'Північ';

  @override
  String get familySpring => 'Весна';

  @override
  String get familySummer => 'Літо';

  @override
  String get familyAutumn => 'Осінь';

  @override
  String get familyWinter => 'Зима';

  @override
  String get storyCampaign0 => 'Паросток';

  @override
  String get storyCampaign1 => 'Брунька';

  @override
  String get storyCampaign2 => 'Цвітіння';

  @override
  String get storyCampaign3 => 'Галявина';

  @override
  String get storyCampaign4 => 'Лужок';

  @override
  String get storyCampaign5 => 'Гайок';

  @override
  String get storyCampaign6 => 'Хвиля';

  @override
  String get storyCampaign7 => 'Струмок';

  @override
  String get storyCampaign8 => 'Сад';

  @override
  String get storyCampaign9 => 'Альтанка';

  @override
  String get storyCampaign10 => 'Віяло';

  @override
  String get storyCampaign11 => 'Павине віяло';

  @override
  String get storyCampaign12 => 'Лотос';

  @override
  String get storyCampaign13 => 'Ставок';

  @override
  String get storyCampaign14 => 'Коропи';

  @override
  String get storyCampaign15 => 'Озеро';

  @override
  String get storyCampaign16 => 'Лоза';

  @override
  String get storyCampaign17 => 'Плющ';

  @override
  String get storyCampaign18 => 'Свято';

  @override
  String get storyCampaign19 => 'Ліхтарі';

  @override
  String get storyCampaign20 => 'Павільйон';

  @override
  String get storyCampaign21 => 'Храм вітрів';

  @override
  String get storyCampaign22 => 'Дракон';

  @override
  String get storyCampaign23 => 'Небесний дракон';

  @override
  String get houseEraName0 => 'Пустир';

  @override
  String get houseEraPhrase0 => 'Тут буде будинок.';

  @override
  String get houseEraName1 => 'Халупа';

  @override
  String get houseEraPhrase1 => 'На ділянці стала халупа.';

  @override
  String get houseEraName2 => 'Хижа';

  @override
  String get houseEraPhrase2 => 'У хижі з\'явилися двері.';

  @override
  String get houseEraName3 => 'Хата';

  @override
  String get houseEraPhrase3 => 'Хата вже з колод.';

  @override
  String get houseEraName4 => 'Будинок';

  @override
  String get houseEraPhrase4 => 'Стоїть справжній будинок.';

  @override
  String get houseEraName5 => 'Котедж';

  @override
  String get houseEraPhrase5 => 'У котеджа два поверхи.';

  @override
  String get houseEraName6 => 'Садиба';

  @override
  String get houseEraPhrase6 => 'Садиба розправила крила.';

  @override
  String get houseEraName7 => 'Особняк';

  @override
  String get houseEraPhrase7 => 'Особняк став кам\'яним.';

  @override
  String get houseEraName8 => 'Фортеця';

  @override
  String get houseEraPhrase8 => 'Стіни стали фортецею.';

  @override
  String get houseEraName9 => 'Замок';

  @override
  String get houseEraPhrase9 => 'Росте замок.';

  @override
  String get houseEraName10 => 'Великий замок';

  @override
  String get houseEraPhrase10 => 'Замок зайняв пагорб.';

  @override
  String get houseEraName11 => 'Резиденція';

  @override
  String get houseEraPhrase11 => 'Резиденцію зібрано.';

  @override
  String get pondEraName0 => 'Низина';

  @override
  String get pondEraPhrase0 => 'Тут наллється ставок.';

  @override
  String get pondEraName1 => 'Калюжа';

  @override
  String get pondEraPhrase1 => 'Калюжа тримає воду.';

  @override
  String get pondEraName2 => 'Ставок';

  @override
  String get pondEraPhrase2 => 'Очерет узяв край.';

  @override
  String get pondEraName3 => 'Містки';

  @override
  String get pondEraPhrase3 => 'Містки лягли.';

  @override
  String get pondEraName4 => 'Ставок із коропами';

  @override
  String get pondEraPhrase4 => 'Коропам є дім.';

  @override
  String get pondEraName5 => 'Альтанка';

  @override
  String get pondEraPhrase5 => 'Альтанка дивиться на воду.';

  @override
  String get pondEraName6 => 'Водний сад';

  @override
  String get pondEraPhrase6 => 'Ставок став садом.';

  @override
  String get pondEraName7 => 'Кам\'яні береги';

  @override
  String get pondEraPhrase7 => 'Кам\'яні береги й ліхтарі.';

  @override
  String get pondEraName8 => 'Міст';

  @override
  String get pondEraPhrase8 => 'Міст перейшов воду.';

  @override
  String get pondEraName9 => 'Водний двір';

  @override
  String get pondEraPhrase9 => 'Водний двір обнесено стіною.';

  @override
  String get pondEraName10 => 'Палацовий ставок';

  @override
  String get pondEraPhrase10 => 'Палацовий сад дійшов до ставка.';

  @override
  String get pondEraName11 => 'Сад готовий';

  @override
  String get pondEraPhrase11 => 'Водний сад зібрано.';

  @override
  String get petsEraName0 => 'Двір';

  @override
  String get petsEraPhrase0 => 'Тут буде будиночок улюбленця.';

  @override
  String get petsEraName1 => 'Миски';

  @override
  String get petsEraPhrase1 => 'Миски чекають у траві.';

  @override
  String get petsEraName2 => 'Будка';

  @override
  String get petsEraPhrase2 => 'На ділянці стала будка.';

  @override
  String get petsEraName3 => 'Клітка';

  @override
  String get petsEraPhrase3 => 'У клітки з\'явилися двері.';

  @override
  String get petsEraName4 => 'Будиночок улюбленця';

  @override
  String get petsEraPhrase4 => 'В улюбленців є дім.';

  @override
  String get petsEraName5 => 'Майданчик';

  @override
  String get petsEraPhrase5 => 'Відкрився майданчик.';

  @override
  String get petsEraName6 => 'Сад';

  @override
  String get petsEraPhrase6 => 'Сад став їхнім.';

  @override
  String get petsEraName7 => 'Нора';

  @override
  String get petsEraPhrase7 => 'Нору вистелено.';

  @override
  String get petsEraName8 => 'Флігель';

  @override
  String get petsEraPhrase8 => 'Флігель теплий.';

  @override
  String get petsEraName9 => 'Звіринець';

  @override
  String get petsEraPhrase9 => 'Звіринець збирається.';

  @override
  String get petsEraName10 => 'Притулок';

  @override
  String get petsEraPhrase10 => 'Притулок обнесено.';

  @override
  String get petsEraName11 => 'Будиночок готовий';

  @override
  String get petsEraPhrase11 => 'Будиночок улюбленця зібрано.';

  @override
  String get guestEraName0 => 'Тихий двір';

  @override
  String get guestEraPhrase0 => 'Сюди дійде сигнал.';

  @override
  String get guestEraName1 => 'Стовп';

  @override
  String get guestEraPhrase1 => 'Стовп тримає лінію.';

  @override
  String get guestEraName2 => 'Кабель';

  @override
  String get guestEraPhrase2 => 'Кабель знайшов дім.';

  @override
  String get guestEraName3 => 'Тарілка';

  @override
  String get guestEraPhrase3 => 'Тарілка стоїть.';

  @override
  String get guestEraName4 => 'Екрани';

  @override
  String get guestEraPhrase4 => 'Екрани світяться у дворі.';

  @override
  String get guestEraName5 => 'Ліхтар лінії';

  @override
  String get guestEraPhrase5 => 'Ліхтар лінії.';

  @override
  String get guestEraName6 => 'Далекий зв\'язок';

  @override
  String get guestEraPhrase6 => 'Двір говорить далі.';

  @override
  String get guestEraName7 => 'Вежа сигналу';

  @override
  String get guestEraPhrase7 => 'Вежа сигналу.';

  @override
  String get guestEraName8 => 'Обсерваторія';

  @override
  String get guestEraPhrase8 => 'Росте обсерваторія.';

  @override
  String get guestEraName9 => 'Кришталева лінія';

  @override
  String get guestEraPhrase9 => 'Кришталь і дріт.';

  @override
  String get guestEraName10 => 'Маяк';

  @override
  String get guestEraPhrase10 => 'Маяк на пагорбі.';

  @override
  String get guestEraName11 => 'Двір у мережі';

  @override
  String get guestEraPhrase11 => 'Двір повністю в мережі.';

  @override
  String get houseWarm0 => 'Ще один крок стежкою.';

  @override
  String get houseWarm1 => 'Ділянка стала своєю.';

  @override
  String get houseWarm2 => 'Будинок трохи ближче.';

  @override
  String get pondWarm0 => 'Вода трохи піднялася.';

  @override
  String get pondWarm1 => 'Ставок став своїм.';

  @override
  String get pondWarm2 => 'Береги ближче.';

  @override
  String get petsWarm0 => 'Будиночок трохи затишніший.';

  @override
  String get petsWarm1 => 'Улюбленцям просторіше.';

  @override
  String get petsWarm2 => 'Двір став своїм.';

  @override
  String get guestWarm0 => 'Сигнал трохи сильніший.';

  @override
  String get guestWarm1 => 'Двір зв\'язаний краще.';

  @override
  String get guestWarm2 => 'Лінія ближче.';

  @override
  String get storyCatWindowTitle => 'Сонячне підвіконня';

  @override
  String get storyCatWindowChapter0 => 'Знайдемо найтепліше сонячне місце.';

  @override
  String get storyCatWindowChapter1 => 'Принесемо м\'яку подушку і клубок.';

  @override
  String get storyCatWindowChapter2 =>
      'Повісимо фіранку для ідеального денного сну.';

  @override
  String get storyCatWatchTitle => 'Нічна варта';

  @override
  String get storyCatWatchChapter0 => 'Освітимо тиху доріжку через двір.';

  @override
  String get storyCatWatchChapter1 => 'Додамо дзвіночок, щоб чути гостей.';

  @override
  String get storyCatWatchChapter2 =>
      'Подивимось на місяць у маленький телескоп.';

  @override
  String get storyCatGardenTitle => 'Таємний сад';

  @override
  String get storyCatGardenChapter0 => 'Посадимо затишний зелений куточок.';

  @override
  String get storyCatGardenChapter1 => 'Покличемо в гості яскравих метеликів.';

  @override
  String get storyCatGardenChapter2 => 'Завершимо сад дзюркотливим фонтаном.';

  @override
  String get storyCatLibraryTitle => 'Маленька бібліотека';

  @override
  String get storyCatLibraryChapter0 => 'Зберемо три улюблені книжки.';

  @override
  String get storyCatLibraryChapter1 => 'Розстелимо плед біля полиць.';

  @override
  String get storyCatLibraryChapter2 => 'Запалимо лампу для довгих вечорів.';

  @override
  String get storyCatTeaTitle => 'Вартовий чайного будиночка';

  @override
  String get storyCatTeaChapter0 => 'Поставимо першу маленьку чашку.';

  @override
  String get storyCatTeaChapter1 => 'Прикрасимо стіл свіжими квітами.';

  @override
  String get storyCatTeaChapter2 =>
      'Піднімемо прапор чайного будиночка для гостей.';

  @override
  String get storyDogTrailTitle => 'Стежка знайомств';

  @override
  String get storyDogTrailChapter0 => 'Позначимо дружню стежку через двір.';

  @override
  String get storyDogTrailChapter1 => 'Залишимо мандрівникам свіжу воду.';

  @override
  String get storyDogTrailChapter2 =>
      'Покладемо на фініші м\'яч для веселої зустрічі.';

  @override
  String get storyDogBridgeTitle => 'Вартовий мосту';

  @override
  String get storyDogBridgeChapter0 => 'Зміцнимо старий міст міцною мотузкою.';

  @override
  String get storyDogBridgeChapter1 => 'Повісимо ліхтар для туманних ранків.';

  @override
  String get storyDogBridgeChapter2 =>
      'Заслужимо золотий значок вартового двору.';

  @override
  String get storyDogPicnicTitle => 'День пікніка';

  @override
  String get storyDogPicnicChapter0 => 'Зберемо кошик для всіх друзів.';

  @override
  String get storyDogPicnicChapter1 => 'Оберемо сонячне місце для пледа.';

  @override
  String get storyDogPicnicChapter2 =>
      'Розділимо частування, коли всі зберуться.';

  @override
  String get storyDogKiteTitle => 'Загублений повітряний змій';

  @override
  String get storyDogKiteChapter0 =>
      'Побачивши змія за пагорбами, рушимо в путь.';

  @override
  String get storyDogKiteChapter1 => 'Підемо за вітром за компасом.';

  @override
  String get storyDogKiteChapter2 =>
      'Повернемо змія додому і прив\'яжемо нову стрічку.';

  @override
  String get storyDogFestivalTitle => 'Помічник свята';

  @override
  String get storyDogFestivalChapter0 =>
      'Віднесемо кольорові прапорці на площу.';

  @override
  String get storyDogFestivalChapter1 =>
      'Поведемо парад із маленьким барабаном.';

  @override
  String get storyDogFestivalChapter2 =>
      'Отримаємо медаль за допомогу всьому двору.';

  @override
  String get storyRaccoonWorkshopTitle => 'Блискуча майстерня';

  @override
  String get storyRaccoonWorkshopChapter0 =>
      'Відкриємо скриньку цікавих винаходів.';

  @override
  String get storyRaccoonWorkshopChapter1 =>
      'З\'єднаємо найблискучіші шестерні.';

  @override
  String get storyRaccoonWorkshopChapter2 =>
      'Зберемо годинник, який дзвонить на заході.';

  @override
  String get storyRaccoonMarketTitle => 'Місячний ринок';

  @override
  String get storyRaccoonMarketChapter0 =>
      'Сплетемо кошик для незвичайних знахідок.';

  @override
  String get storyRaccoonMarketChapter1 => 'Запалимо крамничку під місяцем.';

  @override
  String get storyRaccoonMarketChapter2 =>
      'Обміняємо три блискучі монети на сюрприз.';

  @override
  String get storyRaccoonRiverTitle => 'Річковий скарб';

  @override
  String get storyRaccoonRiverChapter0 =>
      'Прочитаємо карту, сховану під каменем.';

  @override
  String get storyRaccoonRiverChapter1 => 'Полагодимо човник для переправи.';

  @override
  String get storyRaccoonRiverChapter2 =>
      'Знайдемо співучу мушлю на далекому березі.';

  @override
  String get storyRaccoonRecycleTitle => 'Сад другого життя';

  @override
  String get storyRaccoonRecycleChapter0 =>
      'Перетворимо стару скриньку на клумбу.';

  @override
  String get storyRaccoonRecycleChapter1 => 'Полагодимо пом\'яту лійку.';

  @override
  String get storyRaccoonRecycleChapter2 => 'Зберемо млин із забутих деталей.';

  @override
  String get storyRaccoonCafeTitle => 'Нічне кафе';

  @override
  String get storyRaccoonCafeChapter0 => 'Начистимо кухоль для першого гостя.';

  @override
  String get storyRaccoonCafeChapter1 => 'Спечемо печиво у формі місяця.';

  @override
  String get storyRaccoonCafeChapter2 =>
      'Повісимо вивіску кафе до настання ночі.';

  @override
  String get storyHamsterRailwayTitle => 'Крихітна залізниця';

  @override
  String get storyHamsterRailwayChapter0 =>
      'Прокладемо рейки навколо квітника.';

  @override
  String get storyHamsterRailwayChapter1 =>
      'Зберемо вагончик потрібного розміру.';

  @override
  String get storyHamsterRailwayChapter2 => 'Відкриємо найменшу станцію двору.';

  @override
  String get storyHamsterPantryTitle => 'Велика комора';

  @override
  String get storyHamsterPantryChapter0 => 'Зберемо мішечок насіння на зиму.';

  @override
  String get storyHamsterPantryChapter1 =>
      'Побудуємо полиці з гладеньких гілочок.';

  @override
  String get storyHamsterPantryChapter2 => 'Підпишемо найкращу банку в коморі.';

  @override
  String get storyHamsterCloudsTitle => 'Хмарна обсерваторія';

  @override
  String get storyHamsterCloudsChapter0 =>
      'Піднімемо драбину над високою травою.';

  @override
  String get storyHamsterCloudsChapter1 => 'Спрямуємо телескоп між хмарами.';

  @override
  String get storyHamsterCloudsChapter2 => 'Назвемо нову зірку на честь двору.';

  @override
  String get storyHamsterGardenTitle => 'Мініатюрний сад';

  @override
  String get storyHamsterGardenChapter0 => 'Посадимо сад у глиняному горщику.';

  @override
  String get storyHamsterGardenChapter1 =>
      'Поставимо місток над струмком із камінців.';

  @override
  String get storyHamsterGardenChapter2 => 'Додамо будиночок-гриб для гостей.';

  @override
  String get storyHamsterBirthdayTitle => 'Парад до дня народження';

  @override
  String get storyHamsterBirthdayChapter0 =>
      'Зробимо найменший святковий ковпак.';

  @override
  String get storyHamsterBirthdayChapter1 => 'Спечемо торт із трьома ягодами.';

  @override
  String get storyHamsterBirthdayChapter2 => 'Почнемо парад під дощем конфеті.';

  @override
  String get storyFoxCozyTitle => 'Затишний куточок';

  @override
  String get storyFoxCozyChapter0 => 'Приберемо листя в тихому куточку.';

  @override
  String get storyFoxCozyChapter1 =>
      'Принесемо м\'яку лежанку для денного сну.';

  @override
  String get storyFoxCozyChapter2 =>
      'Оберемо улюблену іграшку і влаштуємо справжній дім.';

  @override
  String get storyFoxFirefliesTitle => 'Стежка світлячків';

  @override
  String get storyFoxFirefliesChapter0 => 'Поставимо ліхтар на краю лісу.';

  @override
  String get storyFoxFirefliesChapter1 => 'Посадимо нічні квіти вздовж стежки.';

  @override
  String get storyFoxFirefliesChapter2 =>
      'Зустрінемо мерехтливу хмару світлячків.';

  @override
  String get storyFoxPostTitle => 'Лісова пошта';

  @override
  String get storyFoxPostChapter0 => 'Поставимо червону скриньку під дубом.';

  @override
  String get storyFoxPostChapter1 => 'Розберемо листи для всіх друзів двору.';

  @override
  String get storyFoxPostChapter2 => 'Віднесемо першу пошту в новій сумці.';

  @override
  String get storyFoxStudioTitle => 'Осіння майстерня';

  @override
  String get storyFoxStudioChapter0 =>
      'Поставимо мольберт серед золотого листя.';

  @override
  String get storyFoxStudioChapter1 => 'Змішаємо фарби для осіннього портрета.';

  @override
  String get storyFoxStudioChapter2 => 'Оформимо картину для будинку у дворі.';

  @override
  String get storyFoxCampTitle => 'Табір під зорями';

  @override
  String get storyFoxCampChapter0 => 'Поставимо намет під соснами.';

  @override
  String get storyFoxCampChapter1 => 'Розведемо тепле й безпечне багаття.';

  @override
  String get storyFoxCampChapter2 => 'Не заснемо, щоб побачити падаючу зірку.';

  @override
  String get petItemCushion => 'Подушка';

  @override
  String get petItemYarn => 'Клубок';

  @override
  String get petItemCurtain => 'Фіранка';

  @override
  String get petItemLantern => 'Ліхтар';

  @override
  String get petItemBell => 'Дзвіночок';

  @override
  String get petItemTelescope => 'Телескоп';

  @override
  String get petItemSeedling => 'Саджанець';

  @override
  String get petItemButterflies => 'Метелики';

  @override
  String get petItemFountain => 'Фонтан';

  @override
  String get petItemBooks => 'Книжки';

  @override
  String get petItemBlanket => 'Плед';

  @override
  String get petItemLamp => 'Лампа';

  @override
  String get petItemTeacup => 'Чайний набір';

  @override
  String get petItemFlowers => 'Квіти';

  @override
  String get petItemBanner => 'Прапор';

  @override
  String get petItemSignpost => 'Вказівник';

  @override
  String get petItemBowl => 'Миска';

  @override
  String get petItemBall => 'М\\';

  @override
  String get petItemRope => 'Мотузка';

  @override
  String get petItemBadge => 'Значок';

  @override
  String get petItemBasket => 'Кошик';

  @override
  String get petItemTreats => 'Частування';

  @override
  String get petItemKite => 'Повітряний змій';

  @override
  String get petItemCompass => 'Компас';

  @override
  String get petItemRibbon => 'Стрічка';

  @override
  String get petItemFlags => 'Прапорці';

  @override
  String get petItemDrum => 'Барабан';

  @override
  String get petItemMedal => 'Медаль';

  @override
  String get petItemToolbox => 'Скринька інструментів';

  @override
  String get petItemGears => 'Шестерні';

  @override
  String get petItemClock => 'Годинник';

  @override
  String get petItemCoins => 'Монети';

  @override
  String get petItemMap => 'Карта';

  @override
  String get petItemBoat => 'Човник';

  @override
  String get petItemShell => 'Мушля';

  @override
  String get petItemCrate => 'Скринька-клумба';

  @override
  String get petItemWateringCan => 'Лійка';

  @override
  String get petItemWindmill => 'Млин';

  @override
  String get petItemMug => 'Кухоль';

  @override
  String get petItemCookies => 'Печиво';

  @override
  String get petItemTracks => 'Рейки';

  @override
  String get petItemCart => 'Вагончик';

  @override
  String get petItemStation => 'Станція';

  @override
  String get petItemSeedBag => 'Мішечок насіння';

  @override
  String get petItemShelf => 'Полиці';

  @override
  String get petItemJar => 'Банка';

  @override
  String get petItemLadder => 'Драбина';

  @override
  String get petItemStar => 'Нова зірка';

  @override
  String get petItemPot => 'Горщик';

  @override
  String get petItemBridge => 'Місток';

  @override
  String get petItemMushroom => 'Будиночок-гриб';

  @override
  String get petItemHat => 'Ковпак';

  @override
  String get petItemCake => 'Торт';

  @override
  String get petItemConfetti => 'Конфеті';

  @override
  String get petItemClearing => 'Тихе місце';

  @override
  String get petItemBed => 'Лежанка';

  @override
  String get petItemToy => 'Іграшка';

  @override
  String get petItemFireflies => 'Світлячки';

  @override
  String get petItemMailbox => 'Поштова скринька';

  @override
  String get petItemLetters => 'Листи';

  @override
  String get petItemSatchel => 'Поштова сумка';

  @override
  String get petItemEasel => 'Мольберт';

  @override
  String get petItemPaints => 'Фарби';

  @override
  String get petItemFrame => 'Рама';

  @override
  String get petItemTent => 'Намет';

  @override
  String get petItemCampfire => 'Багаття';

  @override
  String get neighborsTitle => 'Сусіди';

  @override
  String get neighborsClose => 'Закрити';

  @override
  String get neighborsTabAll => 'Усі гравці';

  @override
  String get neighborsTabSaved => 'Обрані';

  @override
  String get neighborsSearchHint => 'Пошук за початком імені';

  @override
  String get neighborsForYou => 'Для тебе';

  @override
  String neighborsUpdates(int count) {
    return 'Оновлення: $count';
  }

  @override
  String get neighborsShowLess => 'Згорнути';

  @override
  String get neighborsEmptySaved => 'Тут будуть гравці, яких ви збережете.';

  @override
  String get neighborsBrowsePlayers => 'Відкрити всіх гравців';

  @override
  String get neighborsEmptySearch => 'Немає імені з таким початком.';

  @override
  String get neighborsEmptyPlayers => 'У цьому списку немає інших гравців.';

  @override
  String get neighborsOffline =>
      'Немає зв\'язку. Тут лишаються раніше завантажені гравці.';

  @override
  String get neighborsLoadFailed => 'Не вдалося завантажити гравців.';

  @override
  String get neighborsRetry => 'Повторити';

  @override
  String get neighborsLoading => 'Завантаження гравців';

  @override
  String get neighborsLoadingMore => 'Завантаження ще';

  @override
  String neighborsLevel(int level) {
    return 'рівень $level';
  }

  @override
  String get neighborsAdd => 'Додати до обраних';

  @override
  String get neighborsRemove => 'Прибрати з обраних';

  @override
  String neighborsSaved(String name) {
    return '$name у списку «Обрані».';
  }

  @override
  String neighborsRemoved(String name) {
    return '$name прибрано з обраних.';
  }

  @override
  String get neighborsFindAgain => 'Знайти в обраних';

  @override
  String get neighborsBack => 'До списку';

  @override
  String get neighborsSavedHint =>
      'Збережіть гравця, щоб знову знайти його в «Обраних».';

  @override
  String get neighborsSignalAsksHelp => 'Просить допомоги';

  @override
  String get neighborsSignalSeeksDefense => 'Шукає захист';

  @override
  String get neighborsSignalOffersCross => 'Пропонує схрещування';

  @override
  String get neighborsSignalAwaitsReply => 'Чекає на відповідь';

  @override
  String get neighborsSignalHelpedYou => 'Допоміг тобі';

  @override
  String neighborsUnseen(int count) {
    return 'нових: $count';
  }

  @override
  String get neighborsHistory => 'Ваші дії';

  @override
  String get neighborsBlock => 'Заблокувати';

  @override
  String neighborsBlocked(String name) {
    return '$name заблоковано і приховано.';
  }

  @override
  String get neighborsWaiting => 'Чекаємо на відповідь';

  @override
  String get neighborsUnavailable => 'Ця дія недоступна.';

  @override
  String get neighborsFailed => 'Не вийшло. Можна повторити.';

  @override
  String get neighborsEnded => 'Ця пропозиція завершилася.';

  @override
  String get neighborsDeclined => 'Пропозицію відхилено.';

  @override
  String get neighborsCancelled => 'Пропозицію скасовано.';

  @override
  String get neighborsInProgress => 'Виконується';

  @override
  String get neighborsDone => 'Завершено';

  @override
  String get neighborsReply => 'Відповісти';

  @override
  String get neighborsViewOffer => 'Подивитися пропозицію';

  @override
  String get neighborsPeaceful => 'Мирні дії';

  @override
  String get neighborsAttackSection => 'Напад';

  @override
  String get neighborsAttackExplain => 'Це починає напад на цього гравця.';

  @override
  String get neighborsConfirm => 'Підтвердити';

  @override
  String get neighborsThank => 'Подякувати';

  @override
  String neighborsThankSent(String name) {
    return 'Подяку надіслано гравцеві $name.';
  }

  @override
  String get neighborsOfferAgain => 'Запропонувати ще раз';

  @override
  String neighborsCost(String cost) {
    return 'Буде витрачено: $cost';
  }

  @override
  String neighborsOutcome(String outcome) {
    return 'Після підтвердження: $outcome';
  }

  @override
  String get neighborsHelpAction => 'Допомогти';

  @override
  String get neighborsDefenseAction => 'Захистити';

  @override
  String get neighborsCrossDecline => 'Відхилити';

  @override
  String neighborsUsesPlant(String plant) {
    return 'Рослина: $plant';
  }

  @override
  String get neighborsPlantStays => 'Ця рослина лишається у власника.';

  @override
  String get neighborsPlantLeaves => 'Цю рослину витрачено.';

  @override
  String neighborsMemoryHelped(String name) {
    return '$name допоміг твоїй рослині.';
  }

  @override
  String neighborsMemoryDefended(String name) {
    return 'Улюбленець $name захистив город.';
  }

  @override
  String neighborsMemoryCrossed(String name) {
    return 'Ви і $name отримали нову рослину.';
  }

  @override
  String neighborsMemoryThanked(String name) {
    return 'Ви подякували $name.';
  }

  @override
  String neighborsMemoryRaid(String name) {
    return 'Звіт про напад із $name.';
  }

  @override
  String get neighborsReasonUnsupported => 'Спільна дія поки недоступна.';

  @override
  String get neighborsReasonNotAllowed => 'Для цього гравця дія недоступна.';

  @override
  String get neighborsReasonMissingPet => 'Потрібен улюбленець-захисник.';

  @override
  String get neighborsReasonMissingPlant => 'Потрібна рослина для цієї дії.';

  @override
  String neighborsProtector(String name) {
    return 'Захисник: $name';
  }

  @override
  String neighborsUntil(String time) {
    return 'До $time';
  }

  @override
  String neighborsAttackPower(int value) {
    return 'Атака $value';
  }

  @override
  String neighborsDefensePower(int value) {
    return 'Захист $value';
  }

  @override
  String neighborsLoot(int count) {
    return 'Можлива есенція: $count';
  }

  @override
  String get showcaseTitle => 'Вітрина рослин';

  @override
  String get showcaseAll => 'Усі рослини';

  @override
  String get showcaseMine => 'Мої рослини';

  @override
  String get showcaseManage => 'Виставити свої рослини';

  @override
  String get showcaseRefresh => 'Оновити вітрину';

  @override
  String get showcaseIntro =>
      'Знайомся з рослинами інших гравців. На кожній картці вказано власника.';

  @override
  String get showcaseMyIntro =>
      'Обери зібрану рослину: її і твоє ігрове ім\'я побачать інші гравці. Рослина лишиться на складі. Поки вона на вітрині, її не можна згодувати улюбленцю.';

  @override
  String get showcaseEmpty =>
      'На вітрині поки немає рослин. Ти можеш виставити першу.';

  @override
  String get showcaseChoose => 'Обрати рослину';

  @override
  String get showcaseNoPlants =>
      'Збери рослину з грядки, щоб виставити її на вітрину.';

  @override
  String get showcasePublish => 'Виставити';

  @override
  String get showcaseWithdraw => 'Зняти з вітрини';

  @override
  String get showcasePublished => 'На спільній вітрині';

  @override
  String get showcasePrivate => 'Видно лише тобі';

  @override
  String get showcaseUnconfirmed =>
      'Публікацію не підтверджено. Повтори її або зніми рослину з вітрини.';

  @override
  String get showcasePublishedNotice =>
      'Твоя рослина тепер на спільній вітрині.';

  @override
  String get showcaseRemovedNotice =>
      'Рослину знято з вітрини. Її знову можна використовувати.';

  @override
  String get showcaseUnavailable =>
      'Спільна вітрина зараз недоступна. Твої рослини збережено.';

  @override
  String get showcaseLoadFailed =>
      'Не вдалося оновити вітрину. Перевір з\'єднання і спробуй ще раз.';

  @override
  String get showcaseOperationFailed =>
      'Не вдалося підтвердити дію. Рослину захищено; повтори спробу, коли буде зв\'язок.';

  @override
  String get showcaseMissingLocal =>
      'Цю рослину виставлено, але її немає на складі цього пристрою.';

  @override
  String get showcaseMore => 'Завантажити ще';

  @override
  String showcaseSpecimen(int number) {
    return 'Рослина №$number';
  }

  @override
  String get showcaseFeedLocked =>
      'Рослини на вітрині не можна згодувати улюбленцям. Спочатку зніми їх із вітрини.';

  @override
  String get crossOpen => 'Схрестити рослини';

  @override
  String get crossTitle => 'Схрещування';

  @override
  String get crossNeedTwo => 'Обери дві зібрані рослини.';

  @override
  String get crossAimCombat => 'Бойовий корм';

  @override
  String get crossAimGarden => 'Багатший город';

  @override
  String get crossAimSeeds => 'Насіння на вибір';

  @override
  String crossOdds(int ordinary, int raised, int rare) {
    return 'Звичайний результат $ordinary%. Сильніший $raised%. Рідкісний $rare%.';
  }

  @override
  String get crossConfirm => 'Схрестити';

  @override
  String get crossFailed => 'Схрещування не збереглося. Спробуй ще раз.';

  @override
  String get crossListed => 'Спочатку зніми рослину з вітрини.';

  @override
  String get crossWaiting => 'Спочатку заверши поточне схрещування.';

  @override
  String get crossChooseTrait => 'Обери атаку або захист для цього корму.';

  @override
  String get crossAttack => 'Атака';

  @override
  String get crossDefense => 'Захист';

  @override
  String get crossChooseSpecies => 'Обери насінину.';

  @override
  String get crossOrdinary =>
      'Схрещування лишилося звичайним. Звичайну насінину додано до запасу.';

  @override
  String get crossGranted =>
      'Насінина від схрещування лежить у запасі насіння.';

  @override
  String get crossTraitAttack => 'Корм атаки';

  @override
  String get crossTraitDefense => 'Корм захисту';

  @override
  String get crossTraitBloom => 'Росте швидше';

  @override
  String get plantOriginCross => 'Походження: схрещування';

  @override
  String get neighborsActions => 'Дії';

  @override
  String get neighborsActionMessage => 'Написати';

  @override
  String get neighborsActionDefend => 'Захистити';

  @override
  String get neighborsActionCross => 'Запропонувати схрещування';

  @override
  String get neighborsActionRaid => 'Напасти';

  @override
  String get neighborsActionsOffline =>
      'Для дій із гравцями потрібен інтернет.';

  @override
  String get neighborsNeedGuard =>
      'Спочатку признач улюбленця-захисника у дворі улюбленців.';

  @override
  String get neighborsNeedRaider =>
      'Спочатку признач улюбленця для набігів у дворі улюбленців.';

  @override
  String get neighborsNeedPlant => 'Потрібна зібрана рослина на складі.';

  @override
  String get neighborsChoosePhrase => 'Обери фразу';

  @override
  String get neighborsChoosePlant => 'Обери рослину, яку віддаси';

  @override
  String get neighborsSend => 'Надіслати';

  @override
  String neighborsSent(String name) {
    return 'Надіслано: $name.';
  }

  @override
  String get neighborsAlreadyOpen =>
      'Із цим гравцем уже є відкритий запит такого виду.';

  @override
  String get neighborsRequestClosed => 'Цей запит уже закрито.';

  @override
  String get neighborsSendFailed =>
      'Не вийшло. Перевір інтернет і спробуй ще раз.';

  @override
  String neighborsDefendExplain(String name, int value) {
    return 'Коли $name прийме допомогу, твій улюбленець 24 години допомагає охороняти його двір. Захист $value.';
  }

  @override
  String neighborsRaidExplain(String name, int value) {
    return 'У $name є доба, щоб виставити захисника. Двір встоїть, лише якщо захисник сильніший за твою атаку $value. Інакше одна рослина згорить, а іншу ти забереш собі.';
  }

  @override
  String get neighborsCrossExplain =>
      'Кожен віддає одну рослину і отримує одну насінину результату. Твою рослину списують, лише коли забираєш насінину.';

  @override
  String get neighborsMessages => 'Повідомлення і запити';

  @override
  String get neighborsPhraseHello => 'Привіт, сусіде!';

  @override
  String get neighborsPhraseGoodLuck => 'Хай щастить!';

  @override
  String get neighborsPhraseThanks => 'Дякую!';

  @override
  String get neighborsPhraseNiceGarden => 'Чудовий сад!';

  @override
  String get neighborsPhraseLetsCross => 'Давай виростимо щось рідкісне.';

  @override
  String get neighborsPhraseIWillGuard => 'Нагляну за твоїм двором.';

  @override
  String get neighborsPhraseReadyForRaid => 'Готуйся, йду в набіг!';

  @override
  String get neighborsPhraseWellPlayed => 'Гарна гра!';

  @override
  String neighborsInMessage(String name) {
    return '$name пише тобі';
  }

  @override
  String neighborsInDefense(String name, int value) {
    return '$name пропонує 24 години охороняти твій двір. Захист $value.';
  }

  @override
  String neighborsInCross(String name, String plant) {
    return '$name пропонує схрестити свою рослину «$plant» із твоєю.';
  }

  @override
  String neighborsInRaid(String name, int value) {
    return '$name нападає на твій двір. Атака $value.';
  }

  @override
  String get neighborsOutMessage => 'Ти написав';

  @override
  String neighborsOutDefense(int value) {
    return 'Ти запропонував захист. Захист $value.';
  }

  @override
  String neighborsOutCross(String plant) {
    return 'Ти запропонував для схрещування рослину «$plant».';
  }

  @override
  String neighborsOutRaid(int value) {
    return 'Ти напав на цей двір. Атака $value.';
  }

  @override
  String neighborsQuote(String name, String text) {
    return '$name: «$text»';
  }

  @override
  String get neighborsYou => 'Ти';

  @override
  String get neighborsAcceptDefense => 'Прийняти захист';

  @override
  String get neighborsChooseCrossPlant => 'Обрати свою рослину';

  @override
  String get neighborsRepel => 'Відбитися';

  @override
  String get neighborsCancelRequest => 'Скасувати запит';

  @override
  String get neighborsClaimSeed => 'Забрати насінину';

  @override
  String neighborsRaidWon(int attack, int defense) {
    return 'Набіг удався: атака $attack проти захисту $defense.';
  }

  @override
  String neighborsRaidRepelled(int attack, int defense) {
    return 'Двір устояв: атака $attack проти захисту $defense.';
  }

  @override
  String neighborsGuarding(String time) {
    return 'Захист діє до $time.';
  }

  @override
  String get neighborsGuardEnded => 'Захист закінчився.';

  @override
  String neighborsCrossResult(String plant) {
    return 'Підсумок схрещування: насінина «$plant».';
  }

  @override
  String get neighborsSeedClaimed => 'Насінина лежить у запасі насіння.';

  @override
  String neighborsSeedMissing(String plant) {
    return 'Щоб забрати насінину, потрібна рослина «$plant» на складі.';
  }

  @override
  String neighborsYourDefense(int value) {
    return 'Захист твого двору: $value';
  }

  @override
  String get neighborsReplied => 'Відповідь надіслано.';

  @override
  String get neighborsSignalMessage => 'Нове повідомлення';

  @override
  String get neighborsSignalDefense => 'Пропонує захист';

  @override
  String get neighborsSignalRaid => 'Нападає на твій двір';

  @override
  String get neighborsSignalResult => 'Надійшла відповідь';

  @override
  String get socialFriends => 'Друзі';

  @override
  String get socialFriend => 'Ви друзі';

  @override
  String get socialFriendsEmpty =>
      'Поки немає друзів. Відкрийте картку сусіда і запросіть його. Після прийняття запрошення він з\'явиться тут.';

  @override
  String get socialIncoming => 'Запрошення в друзі';

  @override
  String get socialWaiting => 'Очікує прийняття';

  @override
  String get socialUnavailable =>
      'Не вдалося підключитися. Перевірте з\'єднання і повторіть.';

  @override
  String get socialChat => 'Листування';

  @override
  String get socialRemoveFriend => 'Видалити з друзів';

  @override
  String get socialFriendConsent =>
      'Прийняття дружби дозволяє вам обом надсилати особисті повідомлення.';

  @override
  String get socialAccept => 'Прийняти дружбу';

  @override
  String get socialInvite => 'Запросити в друзі';

  @override
  String get socialInvitesClosed =>
      'Гравець поки не приймає запрошення в друзі.';

  @override
  String get socialMyProfile => 'Мій профіль';

  @override
  String get socialProfilePublic =>
      'Ці відомості необов\'язкові і видимі іншим гравцям.';

  @override
  String get socialAbout => 'Про себе';

  @override
  String get socialLanguage => 'Мови спілкування';

  @override
  String get socialInterests => 'Інтереси';

  @override
  String get socialGoal => 'Що шукаю в грі';

  @override
  String get socialPicAboutFriendly => 'Приязний';

  @override
  String get socialPicAboutCalm => 'Спокійний';

  @override
  String get socialPicAboutCheerful => 'Веселий';

  @override
  String get socialPicAboutGentle => 'Ніжний';

  @override
  String get socialPicAboutNight => 'Увечері';

  @override
  String get socialPicAboutCurious => 'Допитливий';

  @override
  String get socialPicInterestGarden => 'Сад';

  @override
  String get socialPicInterestPets => 'Улюбленці';

  @override
  String get socialPicInterestMahjong => 'Маджонг';

  @override
  String get socialPicInterestCourtyard => 'Двір';

  @override
  String get socialPicInterestSeeds => 'Насіння';

  @override
  String get socialPicInterestStars => 'Зірки';

  @override
  String get socialPicGoalFlower => 'Рідкісна квітка';

  @override
  String get socialPicGoalHouse => 'Гарніший дім';

  @override
  String get socialPicGoalFriends => 'Друзі';

  @override
  String get socialPicGoalLevels => 'Проходити рівні';

  @override
  String get socialPicGoalChat => 'Спілкування';

  @override
  String get socialPicGoalCross => 'Схрещування';

  @override
  String get socialOpenInvites => 'Приймати нові запрошення в друзі';

  @override
  String get socialSave => 'Зберегти профіль';

  @override
  String get socialProfileHeading => 'Профіль';

  @override
  String get socialNotChosen => 'Не вибрано';

  @override
  String get socialInvitesOpen => 'Приймає запрошення в друзі';

  @override
  String get socialBadgesTitle => 'Значки у списку сусідів';

  @override
  String get socialBadgesExplain =>
      'За поінти сусіди на певний час побачать ваш аватар і значки профілю поруч з іменем.';

  @override
  String socialBadgesActive(String time) {
    return 'Видно сусідам до $time';
  }

  @override
  String get socialBadgesOff => 'Зараз у списку видно лише ім\'я.';

  @override
  String socialBadgesOffer(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня',
      many: '$days днів',
      few: '$days дні',
      one: '$days день',
    );
    return '$_temp0 · $price поінтів';
  }

  @override
  String get socialBadgesTooLong =>
      'Показ можна продовжити не далі ніж на 30 днів уперед.';

  @override
  String get socialBadgesFailed =>
      'Не вдалося ввімкнути значки. Поінти повернуто.';

  @override
  String get socialBadgesNotListed =>
      'Вас поки немає у списку сусідів. Перевірте мережу й спробуйте ще раз. Поінти не списано.';

  @override
  String get socialChatEmpty =>
      'Привітайтеся або подякуйте другові за допомогу!';

  @override
  String get socialReportMessage => 'Поскаржитися на повідомлення';

  @override
  String get socialOlderMessages => 'Попередні повідомлення';

  @override
  String get socialSendFailed =>
      'Надсилання не підтверджено. Повторіть або поверніться до картки, щоб перевірити статус дружби.';

  @override
  String get socialMessageHint => 'Напишіть повідомлення';

  @override
  String get socialGrownTogether => 'Виростили разом із';

  @override
  String get socialHistoryEmpty => 'Тут з\'являться ваші спільні події.';

  @override
  String get socialHistory => 'Спільна історія';

  @override
  String get socialProfileReport => 'Поскаржитися на профіль';

  @override
  String neighborsRaidDeadline(String time) {
    return 'Якщо не відповісти до $time, двір захистить призначений захисник.';
  }

  @override
  String get neighborsRaidDefendTitle => 'Хто захищає двір?';

  @override
  String neighborsRaidDefendRule(int value) {
    return 'Атака $value. Двір встоїть лише з сильнішим захисником.';
  }

  @override
  String neighborsRaidOptionOwn(String pet, int value) {
    return '$pet · захист $value';
  }

  @override
  String neighborsRaidOptionGuard(String name, int value) {
    return 'Охоронець від $name · захист $value';
  }

  @override
  String neighborsRaidOptionHelp(String name, int value) {
    return '$name відгукнувся на поклик · захист $value';
  }

  @override
  String get neighborsRaidOptionNone => 'Не захищатися';

  @override
  String get neighborsRaidHolds => 'Встоїть';

  @override
  String get neighborsRaidFalls => 'Слабший за атаку';

  @override
  String get neighborsRaidNoDefenders =>
      'У тебе немає улюбленців-захисників, і на поклик поки ніхто не відгукнувся. Без захисника набіг вдасться.';

  @override
  String get neighborsRaidChooseLoss =>
      'Двір не встоїть. Обери, яка рослина згорить; нападник забере випадкову з решти.';

  @override
  String neighborsRaidOnlyPlant(String plant) {
    return 'Єдина рослина, $plant, піде нападнику.';
  }

  @override
  String get neighborsRaidEmptyStorage =>
      'Склад порожній — нападнику нічого забрати.';

  @override
  String get neighborsRaidAcceptLoss => 'Прийняти втрату';

  @override
  String neighborsRaidDestroyed(String plant) {
    return 'Згоріло: $plant.';
  }

  @override
  String neighborsRaidStolen(String plant) {
    return 'Нападник забрав: $plant.';
  }

  @override
  String neighborsRaidLoot(String plant) {
    return 'Твоя здобич: $plant.';
  }

  @override
  String get neighborsRaidNoLoot => 'На складі нічого було забрати.';

  @override
  String get neighborsRaidAutoDefended =>
      'Відповіді не було, тож захищав призначений захисник.';

  @override
  String neighborsRaidDefendedBy(String name) {
    return 'Захищав улюбленець від $name.';
  }

  @override
  String get neighborsRaidTakeLoot => 'Забрати рослину';

  @override
  String neighborsRaidLootTaken(String plant) {
    return '$plant — на твоєму складі.';
  }

  @override
  String get neighborsRaidTooSoon =>
      'Цей двір відпочиває після набігу. Спробуй пізніше.';

  @override
  String get neighborsHelpTitle => 'Кличуть на допомогу';

  @override
  String neighborsHelpExplain(int price) {
    return 'Друзі бачать поклик безкоштовно. Поклик усім гравцям коштує $price поінтів. Захисники, що відгукнулися, з\'являться у списку захисту.';
  }

  @override
  String get neighborsHelpAskFriends => 'Покликати друзів на допомогу';

  @override
  String neighborsHelpAskEveryone(int price) {
    return 'Покликати всіх · $price поінтів';
  }

  @override
  String get neighborsHelpAskedFriends =>
      'Друзі бачать твій поклик про допомогу.';

  @override
  String get neighborsHelpAskedEveryone =>
      'Усі гравці бачать твій поклик про допомогу.';

  @override
  String get neighborsHelpNoFriends =>
      'Поки нікого покликати: у тебе немає друзів.';

  @override
  String neighborsHelpArrived(int count) {
    return 'Відгукнулося захисників: $count';
  }

  @override
  String get neighborsHelpFailed =>
      'Поклик про допомогу не надіслано. Списані поінти повернуто.';

  @override
  String neighborsHelpCallLine(String name, int attack) {
    return 'На $name напали · атака $attack';
  }

  @override
  String neighborsHelpUntil(String time) {
    return 'Відкрито до $time';
  }

  @override
  String neighborsHelpSend(int value) {
    return 'Надіслати захисника · захист $value';
  }

  @override
  String neighborsHelpSent(String name) {
    return 'Твій захисник готовий захищати $name.';
  }

  @override
  String get neighborsHelpOffered => 'Твого захисника запропоновано.';

  @override
  String get neighborsHelpNeedGuard =>
      'Признач улюбленця-захисника, щоб допомагати.';

  @override
  String get plantOriginRaid => 'Здобуто в набігу';

  @override
  String get deleteAccount => 'Видалити акаунт і дані';

  @override
  String get deleteAccountTitle => 'Видалити акаунт і дані?';

  @override
  String get deleteAccountBody =>
      'Це зітре двір, прогрес і налаштування на цьому пристрої. Якщо пристрій увійшов у мережу, зникне і цей анонімний акаунт: запис у рейтингу, профіль, дружба, листування, дії з сусідами, заклики про допомогу і картки вітрини. Спільна розмова чи заявка зникне і в іншого гравця. Скарги, які надіслали інші, лишаються до кінця перевірки. Це не можна скасувати.';

  @override
  String get deleteAccountConfirm => 'Видалити';

  @override
  String get deleteAccountFailed =>
      'Не вдалося завершити видалення. Перевірте з\'єднання і повторіть або напишіть на myevidentsuccess@gmail.com.';

  @override
  String get deleteAccountWorking => 'Видаляємо…';
}
