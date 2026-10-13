// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get continueGame => 'เล่นต่อ';

  @override
  String get noShuffleMoves =>
      'ไม่มีคู่ให้จับ — ลองย้อนกลับ ใช้คำใบ้ หรือแม่เหล็ก';

  @override
  String get shuffleLockedChallenge => 'สับไพ่ไม่ได้ในชาเลนจ์นี้';

  @override
  String get specialTile => 'ไพ่เป้าหมายที่มีดาว';

  @override
  String continueWith(String title) {
    return 'เล่นต่อ · $title';
  }

  @override
  String get newPlot => 'แปลงใหม่';

  @override
  String get previousPlot => 'แปลงก่อนหน้า';

  @override
  String get nextPlot => 'แปลงถัดไป';

  @override
  String get plotLockedHint => 'ชัยชนะถัดไปจะสร้างแปลงนี้';

  @override
  String neighborYard(String name) {
    return 'ลานบ้านของ $name';
  }

  @override
  String neighborRating(String name, int rating) {
    return '$name · $rating';
  }

  @override
  String get neighboringCourtyard => 'ลานบ้านเพื่อนบ้าน';

  @override
  String get courtyardPanHint => 'ลากเพื่อมองรอบลานบ้าน';

  @override
  String houseStateTitle(int state, int total) {
    return 'บ้าน · $state/$total';
  }

  @override
  String get houseFullyUpgraded => 'บ้านอัปเกรดครบแล้ว';

  @override
  String get houseDetailsShow => 'รายละเอียด';

  @override
  String get houseDetailsHide => 'ซ่อน';

  @override
  String upgradeHouseForText(String price) {
    return 'อัปเกรดในราคา $price';
  }

  @override
  String pointsShortfallText(String amount) {
    return 'แต้มไม่พอ $amount';
  }

  @override
  String houseUpgradeOfferText(String cost) {
    return 'อัปเกรดบ้าน · $cost';
  }

  @override
  String get nextHouseLook => 'รูปลักษณ์ถัดไปของบ้าน';

  @override
  String houseLookLine(int built, int total) {
    return 'รูปลักษณ์บ้านที่สร้างแล้ว: $built จาก $total';
  }

  @override
  String hubLevelUnlocksPet(int id) {
    return 'ด่าน $id จะปลดล็อกสัตว์เลี้ยง';
  }

  @override
  String get hubQuestRewardReady => 'รางวัลรายสัปดาห์พร้อมแล้ว';

  @override
  String get hubThreeStarUntilReward => 'ผ่านด้วย 3★ จะได้รางวัล';

  @override
  String hubNeighborEvent(String name, String text) {
    return '$name: $text';
  }

  @override
  String hubHarvestReady(String plant) {
    return '$plant สุกแล้ว — แตะเพื่อเก็บเกี่ยว';
  }

  @override
  String get hubBedFree => 'แปลงว่างอยู่ — ปลูกเมล็ดกันเถอะ';

  @override
  String get today => 'วันนี้';

  @override
  String get clearedToday => 'ผ่านวันนี้แล้ว';

  @override
  String streakNights(int n) {
    return 'วันที่ $n จาก 3';
  }

  @override
  String get streakKept => 'คงแสงสามคืนแล้ว';

  @override
  String get streakAtRisk => 'จะดับตอนเที่ยงคืน';

  @override
  String get keepTheLight => 'รักษาแสงไฟ';

  @override
  String openedProgress(int unlocked, int total) {
    return 'เปิดแล้ว $unlocked/$total';
  }

  @override
  String get courtyard => 'ลานบ้าน';

  @override
  String get howToPlay => 'วิธีเล่น';

  @override
  String get levels => 'ด่าน';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get playAgain => 'เล่นอีกครั้ง';

  @override
  String get next => 'ถัดไป';

  @override
  String get menu => 'เมนู';

  @override
  String get close => 'ปิด';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get save => 'บันทึก';

  @override
  String get back => 'กลับ';

  @override
  String get privacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get privacySettings => 'การตั้งค่าความเป็นส่วนตัว';

  @override
  String get hideBannerButton => '24 ชั่วโมง';

  @override
  String get hideBannerTitle => 'ซ่อนแบนเนอร์ 24 ชั่วโมง';

  @override
  String get hideBannerSubtitle => 'ดูโฆษณา แล้วจะปิดบนอุปกรณ์นี้';

  @override
  String get hideBannerWatch => 'ดูโฆษณา';

  @override
  String get hideBannerNotNow => 'ไว้ทีหลัง';

  @override
  String get aboutGame => 'เกี่ยวกับเกม';

  @override
  String builtAt(String time) {
    return 'บิลด์: $time';
  }

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get sound => 'เสียง';

  @override
  String get music => 'เพลง';

  @override
  String get hapticFeedback => 'การสั่น';

  @override
  String get qMode => 'โหมด Q';

  @override
  String get qModeHint => 'โฆษณาแม่เหล็กให้ 50';

  @override
  String get dimCoveredTiles => 'ทำให้ไพ่ที่ปิดอยู่จางลง';

  @override
  String get dimCoveredTilesHint => 'ทำให้ไพ่ที่หยิบไม่ได้เป็นสีเทา';

  @override
  String get tableLook => 'รูปลักษณ์โต๊ะ';

  @override
  String get tableLookClassic => 'มาจองคลาสสิก';

  @override
  String get tableLookClassicHint => 'ไพ่สามมิติและปุ่มทองแดง';

  @override
  String get tableLookCasual => 'แมตช์สีสด';

  @override
  String get tableLookCasualHint => 'ไพ่แบน สีเขียวและทอง';

  @override
  String get tableLookPremium => 'ใหม่';

  @override
  String get tableLookPremiumHint => 'ไพ่สีงาช้าง โต๊ะไม้โทนอุ่น';

  @override
  String get tableLookGift => 'โต๊ะ';

  @override
  String get tableLookUse => 'ใช้';

  @override
  String get tableLookLockedHint => 'ปลดล็อกเป็นของขวัญลานบ้าน';

  @override
  String get tableLookSettingsHint => 'เลือกธีมโต๊ะแบบอื่นได้ในเมนู';

  @override
  String get language => 'ภาษา';

  @override
  String get languageSystem => 'ตามระบบ';

  @override
  String get tileLocked => 'ไพ่ถูกล็อก';

  @override
  String get trayFull => 'ถาดเต็ม';

  @override
  String get trayFullHint => 'ไม่มีคู่ที่ตรงกัน';

  @override
  String get noMovesShuffle => 'ไม่มีตาเดิน — สับไพ่';

  @override
  String get youWin => 'คุณชนะ!';

  @override
  String get noFreeTiles => 'ไม่มีไพ่ว่าง';

  @override
  String get shuffled => 'สับแล้ว';

  @override
  String get stillNoMoves => 'ยังไม่มีตาเดิน';

  @override
  String get loadingAd => 'กำลังโหลดโฆษณา…';

  @override
  String get rewardNotEarned => 'ยังไม่ได้รับรางวัล';

  @override
  String get adUnavailable => 'โหลดโฆษณาไม่ได้ ลองอีกครั้ง';

  @override
  String get noUsefulMoves => 'ไม่มีตาเดินที่ใช้ได้';

  @override
  String get continuing => 'กำลังเล่นต่อ';

  @override
  String get moveUndone => 'ย้อนการเดินแล้ว';

  @override
  String get noMatchingTiles => 'ไม่มีไพ่ที่ตรงกัน';

  @override
  String get couldNotOpenLink => 'เปิดลิงก์ไม่ได้';

  @override
  String get dailyComplete => 'ภารกิจรายวันเสร็จแล้ว';

  @override
  String streakLabel(int n) {
    return 'สตรีค: $n';
  }

  @override
  String score(int value) {
    return 'คะแนน: $value';
  }

  @override
  String starsCount(int n) {
    return '$n ดาว';
  }

  @override
  String get dailyBonus => 'โบนัส: +1 คำใบ้และสับไพ่';

  @override
  String get points => 'แต้ม';

  @override
  String pointsBalanceText(String value) {
    return 'แต้ม: $value';
  }

  @override
  String get pointsShopTitle => 'แต้ม';

  @override
  String get pointsShopSubtitle => 'ได้ทุกครั้งที่ผ่านโต๊ะ เติมได้ทุกเมื่อ';

  @override
  String pointsEarnRuleText(int perClear, int perStar) {
    return 'ผ่านด่าน: +$perClear และ +$perStar ต่อดาว';
  }

  @override
  String pointsPackBonus(int percent) {
    return 'โบนัส +$percent%';
  }

  @override
  String get pointsPackPopular => 'คนซื้อมากสุด';

  @override
  String get pointsPackBest => 'คุ้มที่สุด';

  @override
  String get pointsBuy => 'ซื้อ';

  @override
  String pointsCreditedText(String value) {
    return 'ได้รับ +$value';
  }

  @override
  String get pointsPurchaseCancelled => 'ยกเลิกการซื้อแล้ว';

  @override
  String get pointsPurchaseUnavailable => 'ร้านค้าไม่พร้อมใช้งาน';

  @override
  String get pointsDemoNote => 'ยังไม่ได้เชื่อมการชำระเงิน — แพ็กจะเข้าทันที';

  @override
  String get pointsWatchAd => 'ดูโฆษณา';

  @override
  String pointsWatchAdRewardText(String value) {
    return 'ฟรี +$value';
  }

  @override
  String level(int id) {
    return 'ด่าน $id';
  }

  @override
  String get anotherLevelCleared => 'ผ่านอีกหนึ่งด่าน';

  @override
  String get newBest => 'สถิติใหม่!';

  @override
  String levelUnlocked(int id) {
    return 'ปลดล็อกด่าน $id';
  }

  @override
  String get shuffle => 'สับ';

  @override
  String get magnet => 'แม่เหล็ก';

  @override
  String get hint => 'คำใบ้';

  @override
  String get undo => 'ย้อนกลับ';

  @override
  String watchAd(String name) {
    return 'ดูโฆษณา → $name';
  }

  @override
  String boostEarnedText(int count, String name) {
    return '+$count $name';
  }

  @override
  String get noneLeft => 'หมดแล้ว';

  @override
  String get coachTapFree => 'จับไพ่ที่ว่าง — เปิดด้านบนและด้านหนึ่ง';

  @override
  String get coachMatchPair => 'คู่ในถาดจะถูกลบ';

  @override
  String get coachTrayLimit => 'ถาดใส่ได้ 4 ใบ — เต็มโดยไม่มีคู่แล้วจะแพ้';

  @override
  String get tutorialCollect => 'แตะไพ่ที่ว่าง — ไพ่จะเข้าไปในถาด';

  @override
  String get tutorialMatch =>
      'เก็บไพ่ที่เหมือนกันสองใบ — คู่จะหายไป ถาดมีแค่ 4 ช่อง';

  @override
  String get tutorialLayers => 'ไพ่ที่ถูกทับหยิบไม่ได้จนกว่าไพ่ด้านบนจะหายไป';

  @override
  String get tutorialBoosts =>
      'คำใบ้แสดงตาเดิน แม่เหล็กเก็บคู่ ย้อนกลับคืนตาเดิน';

  @override
  String get tutorialSkip => 'ข้าม';

  @override
  String get featureGotIt => 'เข้าใจแล้ว';

  @override
  String get featureNewBadge => 'ใหม่';

  @override
  String get featureNewGarden => 'ใหม่: แปลงปลูกในลาน — แตะแปลงเพื่อปลูกเมล็ด';

  @override
  String featureUnlockGoal(int count, String feature) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ด่าน',
      one: 'อีก $count ด่าน',
    );
    return '$_temp0 จะปลดล็อก: $feature';
  }

  @override
  String get winPointsHint => 'ใช้แต้มอัปเกรดบ้านในลาน';

  @override
  String get replayTips => 'แสดงคำแนะนำอีกครั้ง';

  @override
  String get replayTipsDone => 'คำแนะนำจะแสดงอีกครั้ง';

  @override
  String get featureTitleHouse => 'บ้าน';

  @override
  String get featureTitleGarden => 'สวน';

  @override
  String get featureTitleSeeds => 'เมล็ด';

  @override
  String get featureBodyHouse =>
      'ผ่านด่านได้แต้ม ใช้แต้มที่นี่เพื่ออัปเกรดบ้าน — บ้านยังผลิตเมล็ดสำหรับสวนด้วย';

  @override
  String get featureBodyPoints =>
      'ได้แต้มจากทุกด่านที่ผ่าน ใช้จ่ายค่าอัปเกรดบ้านและการปลูก';

  @override
  String get featureBodyGarden =>
      'ปลูกเมล็ดในแปลง รอ แล้วเก็บเกี่ยวพืช พืชใช้เลี้ยงสัตว์และอวดเพื่อนบ้านได้';

  @override
  String get featureBodyWarehouse =>
      'พืชที่เก็บเกี่ยวอยู่ที่นี่ ใช้เลี้ยงสัตว์ ผสมสองต้น หรือนำขึ้นตู้แสดง';

  @override
  String get featureBodySeeds =>
      'เมล็ดที่บ้านผลิตเก็บไว้ที่นี่ นำไปปลูกในแปลงสวน';

  @override
  String get featureBodyCross =>
      'ใช้พืชสองต้นแลกเมล็ดใหม่หนึ่งเมล็ด ผลที่แรงหรือหายากเป็นโอกาส ไม่ใช่สัญญา';

  @override
  String get featureBodyNeighbors =>
      'ผู้เล่นที่อันดับใกล้คุณอยู่บนเนินเขา ส่งข้อความและร่วมมือกันผสมพืชและป้องกัน';

  @override
  String get featureBodyShowcase =>
      'อวดพืชที่ดีที่สุดให้ทุกคนเห็น และดูว่าผู้เล่นอื่นปลูกอะไร';

  @override
  String get featureBodyLeaderboard =>
      'ดาวและชัยชนะในสัปดาห์นี้ช่วยให้อันดับของคุณสูงขึ้น';

  @override
  String get featureBodyPets =>
      'สัตว์เลี้ยงของคุณอยู่ในลาน ให้อาหารด้วยพืชจากสวน';

  @override
  String get easy => 'ง่าย';

  @override
  String get normal => 'ปกติ';

  @override
  String get hard => 'ยาก';

  @override
  String get expert => 'ผู้เชี่ยวชาญ';

  @override
  String get you => 'คุณ';

  @override
  String get player => 'ผู้เล่น';

  @override
  String get yourName => 'ชื่อของคุณ';

  @override
  String get youClimbed => 'คุณไต่อันดับแล้ว!';

  @override
  String rankClimbPlaces(int from, int to) {
    return 'อันดับ $from → $to';
  }

  @override
  String get leaderboard => 'กระดานอันดับ';

  @override
  String get refresh => 'รีเฟรช';

  @override
  String get changeName => 'เปลี่ยนชื่อ';

  @override
  String get nameNotAllowed => 'ใช้ชื่อนี้ไม่ได้ เลือกชื่ออื่น';

  @override
  String get rankingNamesNote =>
      'ผู้เล่นเป็นคนตั้งชื่อ รายงานหรือซ่อนคนที่ผิดกฎได้';

  @override
  String get reportPlayer => 'รายงานหรือซ่อน';

  @override
  String get reportName => 'รายงานชื่อนี้';

  @override
  String get hidePlayer => 'ซ่อนผู้เล่นนี้';

  @override
  String get reportThanks => 'ขอบคุณ เราจะตรวจสอบชื่อนี้';

  @override
  String get playerHidden => 'ซ่อนผู้เล่นนี้บนอุปกรณ์ของคุณแล้ว';

  @override
  String get name => 'ชื่อ';

  @override
  String onlineRanking(int top) {
    return 'อันดับออนไลน์ · สูงสุด $top';
  }

  @override
  String get offlineRanking => 'ออฟไลน์: แสดงเฉพาะผลของคุณ';

  @override
  String get rankingFormula =>
      'คะแนนจัดอันดับ: ดาว × 100,000 + คะแนนดีที่สุด + ความคืบหน้าแคมเปญ';

  @override
  String get scorePlotsLegend => 'คะแนน : แปลง';

  @override
  String get loadRankingFailed => 'โหลดอันดับออนไลน์ไม่ได้';

  @override
  String starsLevel(int stars, int unlocked) {
    return '$stars ★ · ด่าน $unlocked';
  }

  @override
  String get ad => 'โฆษณา';

  @override
  String get done => 'เสร็จ';

  @override
  String get closeWithoutReward => 'ปิดโดยไม่รับรางวัล';

  @override
  String get simulatedAd => 'โฆษณาจำลอง';

  @override
  String get watchClipForBoost => 'ดูคลิปเพื่อรับบูสต์';

  @override
  String get claimReward => 'รับรางวัล';

  @override
  String get watchingAd => 'กำลังดูโฆษณา…';

  @override
  String get weeklyQuests => 'เควสต์รายสัปดาห์';

  @override
  String get claim => 'รับ';

  @override
  String get claimed => 'รับแล้ว';

  @override
  String get questBonus => '+1 คำใบ้และสับไพ่';

  @override
  String get extraBoostThisWeek => '+1 บูสต์บนโต๊ะวันนี้';

  @override
  String get seasonClosed => 'ซีซันปิดแล้ว';

  @override
  String lastWeekPlace(int rank) {
    return 'สัปดาห์ที่แล้ว: อันดับ $rank';
  }

  @override
  String lastWeekScore(String rating) {
    return 'คะแนน $rating';
  }

  @override
  String get reminders => 'การแจ้งเตือนรายวัน';

  @override
  String get reminderDailyTitle => 'ลานบ้านของคุณกำลังรอ';

  @override
  String get reminderDailyBody => 'วันนี้มีโต๊ะใหม่พร้อมแล้ว';

  @override
  String get reminderStreakTitle => 'สตรีคของคุณกำลังจะดับ';

  @override
  String get reminderStreakBody => 'โคมดวงที่สามจะดับตอนเที่ยงคืน';

  @override
  String get reminderWeekTitle => 'ซีซันลานบ้านใหม่';

  @override
  String get reminderWeekBody => 'เควสต์รายสัปดาห์และอันดับถูกรีเซ็ตแล้ว';

  @override
  String get pet => 'สัตว์เลี้ยง';

  @override
  String get pets => 'สัตว์เลี้ยง';

  @override
  String get chooseAPet => 'เลือกเพื่อนคู่ใจ';

  @override
  String get addPet => 'เพิ่มเพื่อนคู่ใจ';

  @override
  String get petInviteAdopt => 'เพื่อนกำลังรอคุณ';

  @override
  String get petInviteShow => 'แสดงสัตว์เลี้ยง';

  @override
  String get petYardStartAdventure => 'เริ่มการผจญภัย';

  @override
  String get petYardVisit => 'แวะที่รัง';

  @override
  String get petYardShow => 'แสดงในลาน';

  @override
  String get petYardShowing => 'อยู่ในลาน';

  @override
  String get petYardShowAll => 'แสดงทุกตัวในลาน';

  @override
  String get petCareHint =>
      'ชัยชนะช่วยให้พวกมันเล่นและพักผ่อน ให้อาหารจากพืชที่เก็บในคลัง';

  @override
  String get petStarvingLine => 'พวกมันหิวมาก ให้อาหารจากพืชที่เก็บในคลัง';

  @override
  String get petRemindersPromptTitle => 'แจ้งเตือนเมื่อหิวไหม?';

  @override
  String get petRemindersPromptBody => 'เราจะแจ้งเมื่อพวกมันเริ่มหิว';

  @override
  String get petRemindersYes => 'แจ้งเตือนฉัน';

  @override
  String get petRemindersLater => 'ไว้ทีหลัง';

  @override
  String reminderPetHungerTitle(String name) {
    return '$name หิวแล้ว';
  }

  @override
  String get reminderPetHungerBody => 'ให้อาหารจากพืชที่เก็บในคลัง';

  @override
  String reminderPetPlayTitle(String name) {
    return '$name อยากเล่น';
  }

  @override
  String get reminderPetPlayBody => 'ผ่านโต๊ะหนึ่งโต๊ะเพื่อเล่นกับพวกมัน';

  @override
  String reminderPetRestTitle(String name) {
    return '$name อยากพัก';
  }

  @override
  String get reminderPetRestBody => 'ผ่านโต๊ะหนึ่งโต๊ะเพื่อให้พวกมันได้พัก';

  @override
  String reminderPetStarveTitle(String name) {
    return '$name หิวมาก';
  }

  @override
  String get reminderPetStarveBody => 'ให้อาหารจากพืชที่เก็บในคลัง';

  @override
  String petLevelLabel(int level) {
    return 'ระดับ $level';
  }

  @override
  String petLevelShort(int level) {
    return 'ระดับ $level';
  }

  @override
  String get petMaxLevel => 'ระดับสูงสุด';

  @override
  String petXpLabel(int xp, int need) {
    return 'ประสบการณ์ $xp / $need';
  }

  @override
  String petStrengthLineText(String stat, int total) {
    return '$stat $total';
  }

  @override
  String petLevelChange(int from, int to) {
    return 'ระดับ $from → $to';
  }

  @override
  String petStatChange(String stat, int from, int to) {
    return '$stat $from → $to';
  }

  @override
  String get petFeed => 'ให้อาหาร';

  @override
  String get petFeedTitle => 'เลือกพืช';

  @override
  String get petFeedEmpty => 'ไม่มีพืชที่เก็บแล้วในคลัง';

  @override
  String get petFeedPointless => 'อิ่มแล้ว และอยู่ระดับสูงสุด';

  @override
  String petFeedXp(int xp) {
    return 'ประสบการณ์: $xp';
  }

  @override
  String get petFeedSatiety => 'บรรเทาความหิว พลังจะไม่เพิ่ม';

  @override
  String get petFeedConfirm => 'ให้อาหารพืชนี้';

  @override
  String petFedReaction(String name) {
    return '$name อร่อยกับมื้อนี้';
  }

  @override
  String get petFeedFailed => 'บันทึกไม่ได้ พืชไม่ได้ถูกใช้';

  @override
  String get petFeedMissing => 'พืชนั้นไม่อยู่ในคลังแล้ว';

  @override
  String get petGuardAction => 'เฝ้าสวน';

  @override
  String get petGuarding => 'กำลังเฝ้าสวน';

  @override
  String get petStopGuard => 'หยุดเฝ้า';

  @override
  String get petRaidAction => 'เลือกสำหรับบุก';

  @override
  String get petRaiding => 'ถูกเลือกให้บุก';

  @override
  String get petStopRaid => 'ยกเลิกการเลือกบุก';

  @override
  String gardenGuardLabel(String name, int power) {
    return '$name เฝ้าสวน ป้องกัน $power';
  }

  @override
  String get gardenNoDefender => 'ยังไม่มีผู้ป้องกัน';

  @override
  String get gardenUnguarded => 'สวนไม่มีคนเฝ้า';

  @override
  String get boardSemantic => 'กระดาน';

  @override
  String traySemantic(int filled, int capacity) {
    return 'ถาด $filled จาก $capacity';
  }

  @override
  String get trayEmptySlot => 'ช่องว่าง';

  @override
  String get trayAlmostFull => 'เหลือที่ว่างหนึ่งช่อง — หาคู่';

  @override
  String get houseCardTitle => 'บ้าน';

  @override
  String get seedsHeading => 'เมล็ด';

  @override
  String seedsButton(int count) {
    return 'เมล็ด · $count';
  }

  @override
  String seedPowerStep(int from, int to) {
    return 'พลังเมล็ด: $from → $to';
  }

  @override
  String seedCostStep(int from, int to) {
    return 'ต้นทุนการผลิต: $from → $to แต้ม';
  }

  @override
  String seedSpeciesUnlock(String name) {
    return 'เมล็ดใหม่: $name';
  }

  @override
  String seedDurationStep(String from, String to) {
    return 'เวลาผลิต: $from → $to';
  }

  @override
  String seedChanceStep(String summary) {
    return 'โอกาส: $summary';
  }

  @override
  String get seedClassCommon => 'ธรรมดา';

  @override
  String get seedClassNutrient => 'บำรุง';

  @override
  String get seedClassRare => 'หายาก';

  @override
  String seedClassLine(String name, int percent) {
    return '$name $percent%';
  }

  @override
  String seedSpan(int minutes, int seconds) {
    return '$minutes นาที $seconds วินาที';
  }

  @override
  String seedPowerLabel(int power) {
    return 'อาหาร: $power';
  }

  @override
  String seedPowerPending(int power) {
    return 'พลังเมล็ดที่คาดไว้: $power';
  }

  @override
  String seedMinutes(int minutes) {
    return '$minutes นาที';
  }

  @override
  String get seedSpeciesHeading => 'เมล็ดที่เป็นไปได้';

  @override
  String get seedEqualChance => 'สองชนิดในชั้นเดียวกันมีโอกาสเท่ากัน';

  @override
  String produceSeedForText(String price) {
    return 'ผลิตเมล็ด · $price แต้ม';
  }

  @override
  String yardSeedOfferText(String price) {
    return 'ผลิต\nเมล็ด\n$price';
  }

  @override
  String yardSeedTimerText(String time) {
    return 'เมล็ด\n$time';
  }

  @override
  String get yardGrowPlant => 'ปลูกพืช';

  @override
  String get watchAdHarvest => 'ดูโฆษณา · เก็บเลย';

  @override
  String get plantAdUsed => 'วันนี้เก็บด้วยโฆษณาไปแล้ว';

  @override
  String speedUpForText(String price) {
    return 'เร่ง · $price แต้ม';
  }

  @override
  String get claimSeed => 'เก็บเมล็ด';

  @override
  String get seedAdded => 'เพิ่มเมล็ดเข้าที่เก็บแล้ว';

  @override
  String get openSeedStorage => 'เปิดที่เก็บ';

  @override
  String get seedPurpose => 'ปลูกพืชจากเมล็ดนี้ได้';

  @override
  String seedHouseLevel(int level) {
    return 'ปลูกโดยระดับบ้าน $level';
  }

  @override
  String seedReceived(String date) {
    return 'ได้รับ $date';
  }

  @override
  String seedGroupCount(int count) {
    return '×$count';
  }

  @override
  String get seedSortPower => 'ตามอาหาร';

  @override
  String get seedSortTime => 'ตามเวลาที่ได้รับ';

  @override
  String get seedProducing => 'เมล็ดกำลังงอก';

  @override
  String get seedReadyTitle => 'เมล็ดพร้อมแล้ว';

  @override
  String get seedUnknown => 'เมล็ดไม่ทราบชนิด';

  @override
  String seedTimeLeft(int minutes, int seconds) {
    return 'เหลือ $minutes นาที $seconds วินาที';
  }

  @override
  String get seedBadgeIdle => 'ผลิตเมล็ดได้';

  @override
  String seedBadgeProducing(String time) {
    return 'เมล็ดกำลังงอก เหลือ $time';
  }

  @override
  String get seedBadgeReady => 'เมล็ดพร้อมเก็บ';

  @override
  String get seedReadyMark => 'พร้อม';

  @override
  String get seedPlayMahjong => 'เล่นมาจอง';

  @override
  String get produceFirstSeed => 'ผลิตเมล็ดแรก';

  @override
  String get seedsEmptyBody => 'บ้านยังไม่ได้ผลิตเมล็ด';

  @override
  String seedStackLabel(String name, int power, int count) {
    return '$name อาหาร $power จำนวน $count';
  }

  @override
  String get seedProductionTitle => 'การผลิตเมล็ด';

  @override
  String plantsButton(int count) {
    return 'พืช · $count';
  }

  @override
  String get warehouseTitle => 'คลัง';

  @override
  String warehouseSemantic(int count) {
    return 'คลัง พืช $count ต้น';
  }

  @override
  String get warehouseEmptyBody => 'พืชที่เก็บจะถูกเก็บไว้ที่นี่';

  @override
  String get openGarden => 'เปิดสวน';

  @override
  String plantActionText(int seeds, String points) {
    return 'ปลูก · เมล็ด $seeds + $points แต้ม';
  }

  @override
  String get chooseSeedTitle => 'เลือกเมล็ด';

  @override
  String get noSeedsBody => 'ยังไม่มีเมล็ด ผลิตในบ้านก่อน';

  @override
  String get openHouseProduction => 'เปิดการผลิต';

  @override
  String gardenBedEmpty(int number) {
    return 'แปลง $number ว่าง';
  }

  @override
  String bedTitle(int number) {
    return 'แปลง $number';
  }

  @override
  String get harvestAction => 'เก็บ';

  @override
  String get harvestMark => 'เก็บ';

  @override
  String plantPower(int power) {
    return 'อาหาร: $power';
  }

  @override
  String plantCostLabelText(String points) {
    return 'ค่าปลูก: $points แต้ม';
  }

  @override
  String growDurationLabel(int minutes) {
    return 'เวลาเติบโต: $minutes นาที';
  }

  @override
  String seedsAvailable(int count) {
    return 'มีอยู่: $count';
  }

  @override
  String get plantPreviewLabel => 'พืชในอนาคต';

  @override
  String plantVariant(String variant) {
    return 'รูปลักษณ์: $variant';
  }

  @override
  String plantedOn(String date) {
    return 'ปลูก $date';
  }

  @override
  String maturedOn(String date) {
    return 'สุก $date';
  }

  @override
  String harvestedOn(String date) {
    return 'เก็บ $date';
  }

  @override
  String get gardenSaveFailed => 'บันทึกไม่ได้ ไม่มีอะไรถูกใช้';

  @override
  String get gardenNotReady => 'ยังไม่พร้อม';

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
  String get challengeCompactTower => 'หอคอย: เก็บทุกชั้นให้หมด';

  @override
  String challengeSpecialPair(int cleared) {
    return 'เก็บไพ่ที่มีดาวสองใบ · $cleared/2';
  }

  @override
  String get challengeNoShuffle => 'เก็บกระดานให้หมดโดยไม่สับ';

  @override
  String plotKindTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'house': 'บ้าน',
      'pond': 'สระน้ำ',
      'pets': 'สัตว์เลี้ยง',
      'guest': 'บ้านรับแขก',
      'other': 'บ้าน',
    });
    return '$_temp0';
  }

  @override
  String plotKindTitleToward(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'house': 'บ้าน',
      'pond': 'สระน้ำ',
      'pets': 'สัตว์เลี้ยง',
      'guest': 'บ้านรับแขก',
      'other': 'บ้าน',
    });
    return '$_temp0';
  }

  @override
  String plotLookComplete(String name) {
    return '$name สมบูรณ์แล้ว';
  }

  @override
  String plotLookNextOne(String name) {
    return 'อีก 1 ด่านก่อนรูปลักษณ์ถัดไปของ $name';
  }

  @override
  String plotLookProgressText(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ด่านก่อนรูปลักษณ์ถัดไปของ $name',
    );
    return '$_temp0';
  }

  @override
  String get nextWinUpgradesHouse => 'ชัยชนะครั้งถัดไปจะอัปเกรดบ้าน';

  @override
  String winsUntilHouseUpgradeText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ชัยชนะก่อนบ้านจะอัปเกรด',
      one: 'อีก $count ชัยชนะก่อนบ้านจะอัปเกรด',
    );
    return '$_temp0';
  }

  @override
  String get nextWinImprovesPond => 'ชัยชนะครั้งถัดไปจะทำให้สระน้ำงอกงาม';

  @override
  String winsUntilPondUpgradeText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ชัยชนะก่อนสระน้ำจะงอกงาม',
      one: 'อีก $count ชัยชนะก่อนสระน้ำจะงอกงาม',
    );
    return '$_temp0';
  }

  @override
  String get nextPondLook => 'รูปลักษณ์ถัดไปของสระน้ำ';

  @override
  String hubStarsUntilPlotText(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ดาวก่อนถึง$dest',
      one: 'อีก 1 ดาวก่อนถึง$dest',
      zero: 'อีก 1 ดาวก่อนถึง$dest',
    );
    return '$_temp0';
  }

  @override
  String get oneDailyUntilReward => 'อีกหนึ่งภารกิจรายวันก่อนได้รางวัล';

  @override
  String hubDailiesUntilRewardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ภารกิจรายวันก่อนได้รางวัล',
      one: 'อีก $count ภารกิจรายวันก่อนได้รางวัล',
    );
    return '$_temp0';
  }

  @override
  String get oneLevelUntilReward => 'อีกหนึ่งด่านก่อนได้รางวัล';

  @override
  String hubLevelsUntilRewardText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ด่านก่อนได้รางวัล',
      one: 'อีก $count ด่านก่อนได้รางวัล',
    );
    return '$_temp0';
  }

  @override
  String courtyardLevelsUntilGift(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ด่านก่อนของขวัญลานบ้าน',
      one: 'อีกหนึ่งด่านก่อนของขวัญลานบ้าน',
      zero: 'อีกหนึ่งด่านก่อนของขวัญลานบ้าน',
    );
    return '$_temp0';
  }

  @override
  String hubStarsUntilReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'อีก $count ดาวก่อนได้รางวัล',
      one: 'อีก 1 ดาวก่อนได้รางวัล',
      zero: 'อีก 1 ดาวก่อนได้รางวัล',
    );
    return '$_temp0';
  }

  @override
  String pointsRewardText(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$amount แต้ม',
      one: '+$amount แต้ม',
    );
    return '$_temp0';
  }

  @override
  String get styleFruit => 'ผลไม้';

  @override
  String get styleNature => 'ธรรมชาติ';

  @override
  String get styleCourt => 'ราชสำนัก';

  @override
  String get styleMyth => 'ตำนาน';

  @override
  String get styleClassic => 'คลาสสิก';

  @override
  String get styleShape => 'รูปทรง';

  @override
  String get styleNumber => 'ตัวเลข';

  @override
  String get styleMix => 'ผสม';

  @override
  String get questDaily3 => 'ผ่านรายวัน 3 ครั้ง';

  @override
  String get questStars8 => 'สะสม 8 ดาว';

  @override
  String get questClears4 => 'ผ่าน 4 ด่านแคมเปญ';

  @override
  String get questThreeStar1 => 'ได้ 3★ ในด่านหนึ่ง';

  @override
  String get questStreak3 => 'คงแสงสามคืน';

  @override
  String get weekGarden => 'สัปดาห์สวน';

  @override
  String get weekCourt => 'สัปดาห์ลานบ้าน';

  @override
  String get weekLanterns => 'สัปดาห์โคมไฟ';

  @override
  String get weekMyth => 'สัปดาห์ตำนาน';

  @override
  String get weekHarvest => 'สัปดาห์เก็บเกี่ยว';

  @override
  String get weekDefault => 'โต๊ะของสัปดาห์นี้';

  @override
  String get petCat => 'แมว';

  @override
  String get petDog => 'สุนัข';

  @override
  String get petRaccoon => 'แรคคูน';

  @override
  String get petHamster => 'แฮมสเตอร์';

  @override
  String get petFox => 'จิ้งจอก';

  @override
  String get petNeedHunger => 'ความหิว';

  @override
  String get petNeedPlay => 'การเล่น';

  @override
  String get petNeedRest => 'การพักผ่อน';

  @override
  String petMoodContent(String name) {
    return '$name สบายดี';
  }

  @override
  String petMoodAsking(String name) {
    return '$name ต้องการคุณ';
  }

  @override
  String petMoodStarving(String name) {
    return '$name หิวมาก';
  }

  @override
  String petCareHunger(String name) {
    return 'คุณให้อาหาร $name แล้ว';
  }

  @override
  String petCarePlay(String name) {
    return 'คุณเล่นกับ $name แล้ว';
  }

  @override
  String petCareRest(String name) {
    return '$name ได้พักแล้ว';
  }

  @override
  String get petRoleAttacker => 'ผู้โจมตี';

  @override
  String get petRoleDefender => 'ผู้ป้องกัน';

  @override
  String get petStatAttack => 'พลังโจมตี';

  @override
  String get petStatDefense => 'พลังป้องกัน';

  @override
  String get growthSown => 'เพาะเมล็ดแล้ว';

  @override
  String get growthSprout => 'ต้นอ่อน';

  @override
  String get growthGrowing => 'กำลังเติบโต';

  @override
  String get growthRipe => 'พร้อมเก็บ';

  @override
  String get seedAmberbell => 'ระฆังอำพัน';

  @override
  String get seedMistfern => 'เฟิร์นหมอก';

  @override
  String get seedGlassreed => 'อ้อแก้ว';

  @override
  String get seedCrimsonplum => 'พลัมแดง';

  @override
  String get seedNightlotus => 'บัวราตรี';

  @override
  String get seedStarbamboo => 'ไผ่ดาว';

  @override
  String get seedBlurbAmberbell => 'เมล็ดอุ่นที่มีระฆังเล็กอยู่ข้างใน';

  @override
  String get seedBlurbMistfern => 'ใบอ่อนซีดพับอยู่ในเมล็ด';

  @override
  String get seedBlurbGlassreed => 'ต้นอ้อใสที่ส่งเสียงเมื่อแสงกระทบ';

  @override
  String get seedBlurbCrimsonplum => 'เมล็ดหวานเข้มจากพลัมในลานบ้าน';

  @override
  String get seedBlurbNightlotus => 'ดอกตูมสีม่วงที่บานหลังพลบค่ำเท่านั้น';

  @override
  String get seedBlurbStarbamboo => 'เมล็ดเป็นข้อที่มีประกายที่ปลาย';

  @override
  String get plantOriginHouse => 'ที่มา: การผลิตของบ้าน';

  @override
  String plantOriginOther(String source) {
    return 'ที่มา: $source';
  }

  @override
  String get firstPhraseHouse => 'รูปลักษณ์ถัดไปของบ้านซื้อด้วยแต้ม';

  @override
  String get firstPhrasePond => 'สระน้ำนี้จะเต็มขึ้นเมื่อคุณเล่น';

  @override
  String get firstPhrasePets => 'บ้านสัตว์เลี้ยงนี้จะโตขึ้นเมื่อคุณเล่น';

  @override
  String get firstPhraseGuest => 'ลานนี้จะออนไลน์เมื่อคุณเล่น';

  @override
  String get pathLifeHouse => 'บ้านรู้สึกอบอุ่นขึ้น';

  @override
  String get pathLifePond => 'สระน้ำมีชีวิตชีวา';

  @override
  String get pathLifePets => 'บ้านสัตว์เลี้ยงอบอุ่นขึ้น';

  @override
  String get pathLifeGuest => 'ลานส่งเสียงฮัมเบา ๆ';

  @override
  String get rewardPond => 'สระน้ำเล็ก';

  @override
  String get rewardSwing => 'ชิงช้าในสวน';

  @override
  String get rewardFlowerBed => 'แปลงดอกไม้';

  @override
  String get tileStateFree => 'ว่าง';

  @override
  String get tileStateLocked => 'ล็อก';

  @override
  String tileRemoving(String name) {
    return '$name กำลังจับคู่';
  }

  @override
  String tileInTrayHinted(String name) {
    return '$name ในถาด มีคำใบ้';
  }

  @override
  String tileInTray(String name) {
    return '$name ในถาด';
  }

  @override
  String tileFreeHinted(String name) {
    return '$name ว่าง มีคำใบ้';
  }

  @override
  String tileLockedHinted(String name) {
    return '$name ล็อก มีคำใบ้';
  }

  @override
  String tileFreeState(String name) {
    return '$name ว่าง';
  }

  @override
  String tileLockedState(String name) {
    return '$name ล็อก';
  }

  @override
  String levelCardLocked(int id) {
    return 'ด่าน $id ล็อก';
  }

  @override
  String levelCardOpen(int id, String title, String stars, String progress) {
    return 'ด่าน $id, $title, $stars$progress';
  }

  @override
  String get levelStarsNone => 'ไม่มีดาว';

  @override
  String levelStarsSome(int count) {
    return '$count ดาว';
  }

  @override
  String get levelInProgress => ', กำลังเล่น';

  @override
  String boostLeft(String name, int count) {
    return '$name เหลือ $count';
  }

  @override
  String boostNone(String name) {
    return '$name หมดแล้ว';
  }

  @override
  String get petsNeedCare => 'สัตว์เลี้ยง ต้องการการดูแล';

  @override
  String dailyButtonSemanticText(String today, String status) {
    return '$today. $status';
  }

  @override
  String courtyardSemanticText(String name) {
    return 'ลานบ้าน $name';
  }

  @override
  String gardenBedReady(int number, String name) {
    return 'แปลง $number, $name, พร้อมเก็บ';
  }

  @override
  String gardenBedGrowing(int number, String name, String stage, String time) {
    return 'แปลง $number, $name, $stage, เหลือ $time';
  }

  @override
  String storyNextItem(String item) {
    return 'ถัดไป: $item';
  }

  @override
  String newGiftItem(String item) {
    return 'ของขวัญใหม่: $item';
  }

  @override
  String storyProgressLine(String title, int progress) {
    return '$title · $progress/3';
  }

  @override
  String newChapterProgress(int progress) {
    return 'บทใหม่ · $progress/3';
  }

  @override
  String storyReadyProgress(int stage) {
    return 'เรื่องราวพร้อม · $stage/3';
  }

  @override
  String foxStoryProgress(int stage) {
    return 'เรื่องของจิ้งจอก · $stage/3';
  }

  @override
  String petBadgeText(String role, String level) {
    return '$role, $level';
  }

  @override
  String get chooseAPetYard => 'เลือกเพื่อนคู่ใจ';

  @override
  String get chooseAPetStatus => 'เลือกสัตว์เลี้ยง';

  @override
  String get homeSemantic => 'บ้าน';

  @override
  String get petAdventures => 'การผจญภัยของสัตว์เลี้ยง';

  @override
  String get adventures => 'การผจญภัย';

  @override
  String get adventureComplete => 'การผจญภัยเสร็จสิ้น';

  @override
  String get adventureCompleteBang => 'การผจญภัยเสร็จสิ้น!';

  @override
  String get play => 'เล่น';

  @override
  String get storyLocked => 'ทำเรื่องก่อนหน้าให้จบก่อน';

  @override
  String get fiveAdventures => '5 การผจญภัย';

  @override
  String get foxTitle => 'มุมอบอุ่นสำหรับจิ้งจอก';

  @override
  String get foxGoal0 => 'ชนะหนึ่งครั้งเพื่อเตรียมที่';

  @override
  String get foxGoal1 => 'ชนะหนึ่งครั้งเพื่อทำที่นอน';

  @override
  String get foxGoal2 => 'ชนะหนึ่งครั้งเพื่อนำของเล่นมา';

  @override
  String get foxGoalDone => 'จิ้งจอกรู้สึกเหมือนอยู่บ้าน!';

  @override
  String get foxSeeWhatChanged => 'ดูว่ามีอะไรเปลี่ยน!';

  @override
  String get foxHelpSettle => 'ช่วยจิ้งจอกตั้งถิ่นฐาน · ชนะ 3 ครั้ง';

  @override
  String get foxSaveFailed => 'บันทึกไม่ได้ โปรดลองอีกครั้ง';

  @override
  String get foxIntro =>
      'จิ้งจอกพบมุมสงบในลานบ้านของคุณ ชนะแคมเปญสามครั้งจะทำให้ที่นี่เป็นบ้าน';

  @override
  String get foxStage0 => 'มาเก็บใบไม้กัน ชนะด่านแคมเปญเพื่อเตรียมที่';

  @override
  String get foxStage1 => 'ที่พร้อมแล้ว! ชนะอีกครั้งจะได้ที่นอนนุ่ม';

  @override
  String get foxStage2 => 'ที่นอนนุ่ม! เลือกสี ชนะอีกครั้งจะได้ของเล่น';

  @override
  String get foxStageDone =>
      'จิ้งจอกรู้สึกเหมือนอยู่บ้าน! แตะจิ้งจอกเพื่อเล่น มุมนี้จะอยู่ในลานบ้านของคุณ';

  @override
  String get foxHoney => 'สีน้ำผึ้ง';

  @override
  String get foxSkyBlue => 'สีฟ้าท้องฟ้า';

  @override
  String get foxBall => 'ลูกบอล';

  @override
  String get foxPlushToy => 'ตุ๊กตาผ้า';

  @override
  String get later => 'ไว้ทีหลัง';

  @override
  String get foxHelpStages => 'ช่วย · 3 ขั้น';

  @override
  String get foxLovely => 'น่ารัก!';

  @override
  String get foxIsHome => 'จิ้งจอกอยู่บ้าน · 3/3';

  @override
  String get foxStory => 'เรื่องของจิ้งจอก';

  @override
  String get windEast => 'ลมตะวันออก';

  @override
  String get windSouth => 'ลมใต้';

  @override
  String get windWest => 'ลมตะวันตก';

  @override
  String get windNorth => 'ลมเหนือ';

  @override
  String get familyFruit => 'ผลไม้';

  @override
  String get familyFlower => 'ดอกไม้';

  @override
  String get familyAnimal => 'สัตว์';

  @override
  String get familyBamboo => 'ไม้ไผ่';

  @override
  String get familyCharacter => 'อักษร';

  @override
  String get familyDot => 'จุด';

  @override
  String get familyDragon => 'มังกร';

  @override
  String get familyWind => 'ลม';

  @override
  String get familySeason => 'ฤดู';

  @override
  String get familyNumber => 'ตัวเลข';

  @override
  String get familyShape => 'รูปทรง';

  @override
  String get familyTile => 'ไพ่';

  @override
  String get familyArt => 'ศิลปะ';

  @override
  String get familyClown => 'ตัวตลก';

  @override
  String get familyEmperor => 'จักรพรรดิ';

  @override
  String get familyJoker => 'โจ๊กเกอร์';

  @override
  String get familyProfession => 'อาชีพ';

  @override
  String get familyQueen => 'ราชินี';

  @override
  String get familyEast => 'ตะวันออก';

  @override
  String get familySouth => 'ใต้';

  @override
  String get familyWest => 'ตะวันตก';

  @override
  String get familyNorth => 'เหนือ';

  @override
  String get familySpring => 'ฤดูใบไม้ผลิ';

  @override
  String get familySummer => 'ฤดูร้อน';

  @override
  String get familyAutumn => 'ฤดูใบไม้ร่วง';

  @override
  String get familyWinter => 'ฤดูหนาว';

  @override
  String get storyCampaign0 => 'ต้นอ่อน';

  @override
  String get storyCampaign1 => 'ดอกตูม';

  @override
  String get storyCampaign2 => 'ดอกบาน';

  @override
  String get storyCampaign3 => 'ลานโล่ง';

  @override
  String get storyCampaign4 => 'สนามหญ้า';

  @override
  String get storyCampaign5 => 'ดงไม้';

  @override
  String get storyCampaign6 => 'คลื่น';

  @override
  String get storyCampaign7 => 'ลำธาร';

  @override
  String get storyCampaign8 => 'สวน';

  @override
  String get storyCampaign9 => 'ศาลา';

  @override
  String get storyCampaign10 => 'พัด';

  @override
  String get storyCampaign11 => 'พัดนกยูง';

  @override
  String get storyCampaign12 => 'บัว';

  @override
  String get storyCampaign13 => 'สระ';

  @override
  String get storyCampaign14 => 'ปลาคาร์ป';

  @override
  String get storyCampaign15 => 'ทะเลสาบ';

  @override
  String get storyCampaign16 => 'เถาวัลย์';

  @override
  String get storyCampaign17 => 'ไม้เลื้อย';

  @override
  String get storyCampaign18 => 'เทศกาล';

  @override
  String get storyCampaign19 => 'โคมไฟ';

  @override
  String get storyCampaign20 => 'ศาลาใหญ่';

  @override
  String get storyCampaign21 => 'วิหารลม';

  @override
  String get storyCampaign22 => 'มังกร';

  @override
  String get storyCampaign23 => 'มังกรฟ้า';

  @override
  String get houseEraName0 => 'โล่ง';

  @override
  String get houseEraPhrase0 => 'บ้านจะตั้งที่นี่';

  @override
  String get houseEraName1 => 'เพิง';

  @override
  String get houseEraPhrase1 => 'เพิงโน้มอยู่บนแปลง';

  @override
  String get houseEraName2 => 'กระท่อม';

  @override
  String get houseEraPhrase2 => 'กระท่อมมีประตูแล้ว';

  @override
  String get houseEraName3 => 'บ้านไม้';

  @override
  String get houseEraPhrase3 => 'ตอนนี้เป็นบ้านไม้';

  @override
  String get houseEraName4 => 'บ้าน';

  @override
  String get houseEraPhrase4 => 'บ้านจริงตั้งอยู่ที่นี่';

  @override
  String get houseEraName5 => 'บ้านสองชั้น';

  @override
  String get houseEraPhrase5 => 'บ้านมีสองชั้น';

  @override
  String get houseEraName6 => 'คฤหาสน์';

  @override
  String get houseEraPhrase6 => 'คฤหาสน์แผ่ปีก';

  @override
  String get houseEraName7 => 'แมนชัน';

  @override
  String get houseEraPhrase7 => 'แมนชันเป็นหิน';

  @override
  String get houseEraName8 => 'ป้อม';

  @override
  String get houseEraPhrase8 => 'กำแพงกลายเป็นป้อม';

  @override
  String get houseEraName9 => 'ปราสาท';

  @override
  String get houseEraPhrase9 => 'ปราสาทผุดขึ้น';

  @override
  String get houseEraName10 => 'ปราสาทใหญ่';

  @override
  String get houseEraPhrase10 => 'ปราสาทเต็มเนินเขา';

  @override
  String get houseEraName11 => 'ที่พำนัก';

  @override
  String get houseEraPhrase11 => 'ที่พำนักสมบูรณ์แล้ว';

  @override
  String get pondEraName0 => 'แอ่ง';

  @override
  String get pondEraPhrase0 => 'สระน้ำจะเต็มแอ่งนี้';

  @override
  String get pondEraName1 => 'แอ่งน้ำ';

  @override
  String get pondEraPhrase1 => 'แอ่งน้ำคงอยู่';

  @override
  String get pondEraName2 => 'สระ';

  @override
  String get pondEraPhrase2 => 'ต้นอ้อขึ้นริมฝั่ง';

  @override
  String get pondEraName3 => 'ทางเดิน';

  @override
  String get pondEraPhrase3 => 'ทางเดินวางลงแล้ว';

  @override
  String get pondEraName4 => 'สระปลาคาร์ป';

  @override
  String get pondEraPhrase4 => 'ปลาคาร์ปมีบ้าน';

  @override
  String get pondEraName5 => 'ศาลา';

  @override
  String get pondEraPhrase5 => 'ศาลามองดูน้ำ';

  @override
  String get pondEraName6 => 'สวนน้ำ';

  @override
  String get pondEraPhrase6 => 'สระกลายเป็นสวน';

  @override
  String get pondEraName7 => 'ริมฝั่งหิน';

  @override
  String get pondEraPhrase7 => 'ริมฝั่งหินและโคมไฟ';

  @override
  String get pondEraName8 => 'สะพาน';

  @override
  String get pondEraPhrase8 => 'สะพานข้ามน้ำ';

  @override
  String get pondEraName9 => 'ลานน้ำ';

  @override
  String get pondEraPhrase9 => 'ลานน้ำมีกำแพง';

  @override
  String get pondEraName10 => 'สระวัง';

  @override
  String get pondEraPhrase10 => 'สวนวังมาถึงสระ';

  @override
  String get pondEraName11 => 'สวนน้ำสมบูรณ์';

  @override
  String get pondEraPhrase11 => 'สวนน้ำสมบูรณ์แล้ว';

  @override
  String get petsEraName0 => 'ลาน';

  @override
  String get petsEraPhrase0 => 'บ้านสัตว์เลี้ยงจะตั้งที่นี่';

  @override
  String get petsEraName1 => 'ชาม';

  @override
  String get petsEraPhrase1 => 'ชามรออยู่ในหญ้า';

  @override
  String get petsEraName2 => 'กรง';

  @override
  String get petsEraPhrase2 => 'กรงโน้มอยู่บนแปลง';

  @override
  String get petsEraName3 => 'เล้า';

  @override
  String get petsEraPhrase3 => 'เล้ามีประตูแล้ว';

  @override
  String get petsEraName4 => 'บ้านสัตว์เลี้ยง';

  @override
  String get petsEraPhrase4 => 'สัตว์เลี้ยงมีบ้านแล้ว';

  @override
  String get petsEraName5 => 'ลานเล่น';

  @override
  String get petsEraPhrase5 => 'ลานเล่นเปิดแล้ว';

  @override
  String get petsEraName6 => 'สวน';

  @override
  String get petsEraPhrase6 => 'สวนนี้เป็นของพวกมัน';

  @override
  String get petsEraName7 => 'รัง';

  @override
  String get petsEraPhrase7 => 'รังถูกปูไว้แล้ว';

  @override
  String get petsEraName8 => 'เรือน';

  @override
  String get petsEraPhrase8 => 'เรือนอบอุ่น';

  @override
  String get petsEraName9 => 'สวนสัตว์เล็ก';

  @override
  String get petsEraPhrase9 => 'สวนสัตว์เล็กรวมกัน';

  @override
  String get petsEraName10 => 'เขตสงบ';

  @override
  String get petsEraPhrase10 => 'เขตสงบมีรั้วแล้ว';

  @override
  String get petsEraName11 => 'บ้านสัตว์เลี้ยงสมบูรณ์';

  @override
  String get petsEraPhrase11 => 'บ้านสัตว์เลี้ยงสมบูรณ์แล้ว';

  @override
  String get guestEraName0 => 'ลานเงียบ';

  @override
  String get guestEraPhrase0 => 'สัญญาณจะมาถึงลานนี้';

  @override
  String get guestEraName1 => 'เสา';

  @override
  String get guestEraPhrase1 => 'เสาถือสายไว้';

  @override
  String get guestEraName2 => 'สายเคเบิล';

  @override
  String get guestEraPhrase2 => 'สายเคเบิลมาถึงบ้าน';

  @override
  String get guestEraName3 => 'จานรับสัญญาณ';

  @override
  String get guestEraPhrase3 => 'จานรับสัญญาณตั้งขึ้นแล้ว';

  @override
  String get guestEraName4 => 'จอ';

  @override
  String get guestEraPhrase4 => 'จอสว่างในลาน';

  @override
  String get guestEraName5 => 'โคมสาย';

  @override
  String get guestEraPhrase5 => 'โคมของสายสัญญาณ';

  @override
  String get guestEraName6 => 'คุยไกล';

  @override
  String get guestEraPhrase6 => 'ลานคุยได้ไกลขึ้น';

  @override
  String get guestEraName7 => 'หอสัญญาณ';

  @override
  String get guestEraPhrase7 => 'หอของสัญญาณ';

  @override
  String get guestEraName8 => 'หอดูดาว';

  @override
  String get guestEraPhrase8 => 'หอดูดาวผุดขึ้น';

  @override
  String get guestEraName9 => 'สายคริสตัล';

  @override
  String get guestEraPhrase9 => 'คริสตัลและลวด';

  @override
  String get guestEraName10 => 'ประภาคาร';

  @override
  String get guestEraPhrase10 => 'ประภาคารบนเนินเขา';

  @override
  String get guestEraName11 => 'ลานออนไลน์';

  @override
  String get guestEraPhrase11 => 'ลานออนไลน์ครบแล้ว';

  @override
  String get houseWarm0 => 'อีกก้าวบนเส้นทาง';

  @override
  String get houseWarm1 => 'แปลงนี้เป็นของคุณแล้ว';

  @override
  String get houseWarm2 => 'บ้านใกล้ขึ้นอีกนิด';

  @override
  String get pondWarm0 => 'น้ำสูงขึ้นเล็กน้อย';

  @override
  String get pondWarm1 => 'สระเป็นของคุณมากขึ้น';

  @override
  String get pondWarm2 => 'ริมฝั่งใกล้ขึ้น';

  @override
  String get petsWarm0 => 'บ้านสัตว์เลี้ยงโตขึ้นเล็กน้อย';

  @override
  String get petsWarm1 => 'ลานเป็นของพวกมันมากขึ้น';

  @override
  String get petsWarm2 => 'กรงใกล้ขึ้น';

  @override
  String get guestWarm0 => 'สัญญาณแรงขึ้นเล็กน้อย';

  @override
  String get guestWarm1 => 'ลานเชื่อมต่อมากขึ้น';

  @override
  String get guestWarm2 => 'สายใกล้ขึ้น';

  @override
  String get storyCatWindowTitle => 'ขอบหน้าต่างแดด';

  @override
  String get storyCatWindowChapter0 => 'หาหย่อมแสงแดดที่อุ่นที่สุด';

  @override
  String get storyCatWindowChapter1 => 'นำเบาะนุ่มและไหมพรมมา';

  @override
  String get storyCatWindowChapter2 =>
      'แขวนม่านสำหรับการงีบตอนบ่ายที่สมบูรณ์แบบ';

  @override
  String get storyCatWatchTitle => 'เฝ้ายามเที่ยงคืน';

  @override
  String get storyCatWatchChapter0 => 'จุดทางเดินเงียบ ๆ ข้ามลานบ้าน';

  @override
  String get storyCatWatchChapter1 => 'ใส่กระดิ่งเพื่อได้ยินผู้มาเยือนทุกคน';

  @override
  String get storyCatWatchChapter2 => 'มองดวงจันทร์ผ่านกล้องส่องทางไกลเล็ก ๆ';

  @override
  String get storyCatGardenTitle => 'สวนลับ';

  @override
  String get storyCatGardenChapter0 => 'ปลูกมุมเขียวที่ซ่อนอยู่';

  @override
  String get storyCatGardenChapter1 => 'เชื้อเชิญผีเสื้อสีสดให้มาเยือน';

  @override
  String get storyCatGardenChapter2 => 'เติมน้ำพุกระซิบให้สวนสมบูรณ์';

  @override
  String get storyCatLibraryTitle => 'ห้องสมุดเล็ก';

  @override
  String get storyCatLibraryChapter0 => 'สะสมหนังสือนิทานโปรดสามเล่ม';

  @override
  String get storyCatLibraryChapter1 => 'ปูผ้าห่มข้างชั้นหนังสือ';

  @override
  String get storyCatLibraryChapter2 => 'จุดโคมอ่านหนังสือสำหรับเย็นที่ยาวนาน';

  @override
  String get storyCatTeaTitle => 'ผู้ดูแลโรงน้ำชา';

  @override
  String get storyCatTeaChapter0 => 'จัดถ้วยชาเล็กใบแรก';

  @override
  String get storyCatTeaChapter1 => 'ประดับโต๊ะด้วยดอกไม้สด';

  @override
  String get storyCatTeaChapter2 => 'ชูธงโรงน้ำชาต้อนรับแขก';

  @override
  String get storyDogTrailTitle => 'เส้นทางต้อนรับ';

  @override
  String get storyDogTrailChapter0 => 'ทำเครื่องหมายเส้นทางเป็นมิตรผ่านลาน';

  @override
  String get storyDogTrailChapter1 => 'วางน้ำสดไว้ให้ผู้เดินทาง';

  @override
  String get storyDogTrailChapter2 =>
      'วางลูกบอลที่เส้นชัยเพื่อต้อนรับอย่างร่าเริง';

  @override
  String get storyDogBridgeTitle => 'ลาดตระเวนสะพาน';

  @override
  String get storyDogBridgeChapter0 => 'ยึดสะพานเก่าด้วยเชือกแข็งแรง';

  @override
  String get storyDogBridgeChapter1 => 'แขวนโคมสำหรับเช้าที่มีหมอก';

  @override
  String get storyDogBridgeChapter2 => 'รับตราลาดตระเวนลานบ้านสีทอง';

  @override
  String get storyDogPicnicTitle => 'วันปิกนิก';

  @override
  String get storyDogPicnicChapter0 => 'จัดตะกร้าให้เพื่อนทุกคน';

  @override
  String get storyDogPicnicChapter1 => 'เลือกที่แดดจัดสำหรับผ้าห่ม';

  @override
  String get storyDogPicnicChapter2 => 'แบ่งขนมเมื่อทุกคนมาถึง';

  @override
  String get storyDogKiteTitle => 'ว่าวที่หายไป';

  @override
  String get storyDogKiteChapter0 => 'มองเห็นว่าวพ้นเนินเขา';

  @override
  String get storyDogKiteChapter1 => 'ตามลมไปกับเข็มทิศ';

  @override
  String get storyDogKiteChapter2 => 'นำกลับบ้านและผูกโบใหม่';

  @override
  String get storyDogFestivalTitle => 'ผู้ช่วยเทศกาล';

  @override
  String get storyDogFestivalChapter0 => 'ถือธงสีสดไปที่ลานกว้าง';

  @override
  String get storyDogFestivalChapter1 => 'นำขบวนพร้อมกลองเล็ก';

  @override
  String get storyDogFestivalChapter2 => 'รับเหรียญเพราะช่วยทุกคน';

  @override
  String get storyRaccoonWorkshopTitle => 'โรงงานแวววาว';

  @override
  String get storyRaccoonWorkshopChapter0 =>
      'เปิดกล่องเครื่องมือของสิ่งประดิษฐ์แปลก ๆ';

  @override
  String get storyRaccoonWorkshopChapter1 =>
      'ประกอบเฟืองที่สว่างที่สุดเข้าด้วยกัน';

  @override
  String get storyRaccoonWorkshopChapter2 =>
      'สร้างนาฬิกาที่ตีเมื่อพระอาทิตย์ตก';

  @override
  String get storyRaccoonMarketTitle => 'ตลาดแสงจันทร์';

  @override
  String get storyRaccoonMarketChapter0 => 'สานตะกร้าสำหรับของแปลก';

  @override
  String get storyRaccoonMarketChapter1 => 'จุดแผงใต้แสงจันทร์';

  @override
  String get storyRaccoonMarketChapter2 =>
      'แลกเหรียญแวววาวสามเหรียญกับของเซอร์ไพรส์';

  @override
  String get storyRaccoonRiverTitle => 'สมบัติริมแม่น้ำ';

  @override
  String get storyRaccoonRiverChapter0 => 'อ่านแผนที่ที่ซ่อนใต้ก้อนหิน';

  @override
  String get storyRaccoonRiverChapter1 => 'ปะเรือเล็กสำหรับการข้าม';

  @override
  String get storyRaccoonRiverChapter2 => 'พบเปลือกหอยร้องเพลงที่ฝั่งตรงข้าม';

  @override
  String get storyRaccoonRecycleTitle => 'สวนโอกาสที่สอง';

  @override
  String get storyRaccoonRecycleChapter0 => 'เปลี่ยนลังเก่าเป็นกระถาง';

  @override
  String get storyRaccoonRecycleChapter1 => 'ซ่อมบัวรดน้ำที่บุบ';

  @override
  String get storyRaccoonRecycleChapter2 => 'สร้างกังหันลมจากชิ้นส่วนที่ถูกลืม';

  @override
  String get storyRaccoonCafeTitle => 'คาเฟ่ยามค่ำ';

  @override
  String get storyRaccoonCafeChapter0 => 'ขัดแก้วให้แขกคนแรก';

  @override
  String get storyRaccoonCafeChapter1 => 'อบคุกกี้รูปพระจันทร์หนึ่งจาน';

  @override
  String get storyRaccoonCafeChapter2 => 'แขวนป้ายคาเฟ่ก่อนค่ำคืน';

  @override
  String get storyHamsterRailwayTitle => 'ทางรถไฟจิ๋ว';

  @override
  String get storyHamsterRailwayChapter0 => 'วางรางรอบแปลงดอกไม้';

  @override
  String get storyHamsterRailwayChapter1 => 'สร้างรถเข็นขนาดพอดี';

  @override
  String get storyHamsterRailwayChapter2 => 'เปิดสถานีที่เล็กที่สุดของลานบ้าน';

  @override
  String get storyHamsterPantryTitle => 'ห้องเก็บอาหารใหญ่';

  @override
  String get storyHamsterPantryChapter0 => 'สะสมถุงเมล็ดสำหรับฤดูหนาว';

  @override
  String get storyHamsterPantryChapter1 => 'สร้างชั้นวางจากกิ่งเรียบ';

  @override
  String get storyHamsterPantryChapter2 => 'ติดป้ายโหลที่ดีที่สุดในห้องเก็บ';

  @override
  String get storyHamsterCloudsTitle => 'หอดูเมฆ';

  @override
  String get storyHamsterCloudsChapter0 => 'ตั้งบันไดเหนือหญ้าสูง';

  @override
  String get storyHamsterCloudsChapter1 => 'เล็งกล้องส่องทางไกลระหว่างเมฆ';

  @override
  String get storyHamsterCloudsChapter2 => 'ตั้งชื่อดาวดวงใหม่ตามลานบ้าน';

  @override
  String get storyHamsterGardenTitle => 'สวนจำลอง';

  @override
  String get storyHamsterGardenChapter0 => 'ปลูกสวนในกระถางดิน';

  @override
  String get storyHamsterGardenChapter1 => 'วางสะพานข้ามลำธารกรวด';

  @override
  String get storyHamsterGardenChapter2 => 'เพิ่มบ้านเห็ดให้ผู้มาเยือน';

  @override
  String get storyHamsterBirthdayTitle => 'ขบวนวันเกิด';

  @override
  String get storyHamsterBirthdayChapter0 => 'ทำหมวกปาร์ตี้ที่เล็กที่สุด';

  @override
  String get storyHamsterBirthdayChapter1 => 'อบเค้กด้วยเบอร์รีสามลูก';

  @override
  String get storyHamsterBirthdayChapter2 => 'เริ่มขบวนท่ามกลางสายฝนคอนเฟตติ';

  @override
  String get storyFoxCozyTitle => 'มุมอบอุ่น';

  @override
  String get storyFoxCozyChapter0 => 'กวาดใบไม้จากมุมสงบ';

  @override
  String get storyFoxCozyChapter1 => 'นำที่นอนนุ่มมาสำหรับการงีบตอนบ่าย';

  @override
  String get storyFoxCozyChapter2 => 'เลือกของเล่นโปรดและทำให้ที่นี่เป็นบ้าน';

  @override
  String get storyFoxFirefliesTitle => 'ทางหิ่งห้อย';

  @override
  String get storyFoxFirefliesChapter0 => 'วางโคมที่ขอบป่า';

  @override
  String get storyFoxFirefliesChapter1 => 'ปลูกดอกไม้กลางคืนตามทาง';

  @override
  String get storyFoxFirefliesChapter2 => 'ต้อนรับฝูงหิ่งห้อยประกาย';

  @override
  String get storyFoxPostTitle => 'ที่ทำการไปรษณีย์ป่า';

  @override
  String get storyFoxPostChapter0 => 'สร้างตู้จดหมายสีแดงใต้ต้นโอ๊ก';

  @override
  String get storyFoxPostChapter1 => 'แยกจดหมายให้เพื่อนทุกคนในลานบ้าน';

  @override
  String get storyFoxPostChapter2 => 'ส่งของชิ้นแรกในกระเป๋าใบใหม่';

  @override
  String get storyFoxStudioTitle => 'สตูดิโอฤดูใบไม้ร่วง';

  @override
  String get storyFoxStudioChapter0 => 'ตั้งขาตั้งภาพท่ามกลางใบไม้สีทอง';

  @override
  String get storyFoxStudioChapter1 => 'ผสมสีสำหรับภาพฤดูใบไม้ร่วง';

  @override
  String get storyFoxStudioChapter2 => 'ใส่กรอบภาพให้บ้านในลาน';

  @override
  String get storyFoxCampTitle => 'ค่ายใต้ดาว';

  @override
  String get storyFoxCampChapter0 => 'ตั้งเต็นท์ใต้ต้นสน';

  @override
  String get storyFoxCampChapter1 => 'จุดกองไฟที่อบอุ่นและระมัดระวัง';

  @override
  String get storyFoxCampChapter2 => 'เฝ้าหาดาวตก';

  @override
  String get petItemCushion => 'เบาะ';

  @override
  String get petItemYarn => 'ไหมพรม';

  @override
  String get petItemCurtain => 'ม่าน';

  @override
  String get petItemLantern => 'โคม';

  @override
  String get petItemBell => 'กระดิ่ง';

  @override
  String get petItemTelescope => 'กล้องส่องทางไกล';

  @override
  String get petItemSeedling => 'ต้นกล้า';

  @override
  String get petItemButterflies => 'ผีเสื้อ';

  @override
  String get petItemFountain => 'น้ำพุ';

  @override
  String get petItemBooks => 'หนังสือ';

  @override
  String get petItemBlanket => 'ผ้าห่ม';

  @override
  String get petItemLamp => 'โคมอ่านหนังสือ';

  @override
  String get petItemTeacup => 'ชุดน้ำชา';

  @override
  String get petItemFlowers => 'ดอกไม้';

  @override
  String get petItemBanner => 'ธง';

  @override
  String get petItemSignpost => 'ป้ายทาง';

  @override
  String get petItemBowl => 'ชามน้ำ';

  @override
  String get petItemBall => 'ลูกบอล';

  @override
  String get petItemRope => 'เชือกแข็งแรง';

  @override
  String get petItemBadge => 'ตราลาดตระเวน';

  @override
  String get petItemBasket => 'ตะกร้า';

  @override
  String get petItemTreats => 'ขนม';

  @override
  String get petItemKite => 'ว่าว';

  @override
  String get petItemCompass => 'เข็มทิศ';

  @override
  String get petItemRibbon => 'โบ';

  @override
  String get petItemFlags => 'ธงเทศกาล';

  @override
  String get petItemDrum => 'กลอง';

  @override
  String get petItemMedal => 'เหรียญ';

  @override
  String get petItemToolbox => 'กล่องเครื่องมือ';

  @override
  String get petItemGears => 'เฟือง';

  @override
  String get petItemClock => 'นาฬิกา';

  @override
  String get petItemCoins => 'เหรียญแวววาว';

  @override
  String get petItemMap => 'แผนที่สมบัติ';

  @override
  String get petItemBoat => 'เรือเล็ก';

  @override
  String get petItemShell => 'เปลือกหอยร้องเพลง';

  @override
  String get petItemCrate => 'ลังกระถาง';

  @override
  String get petItemWateringCan => 'บัวรดน้ำ';

  @override
  String get petItemWindmill => 'กังหันลม';

  @override
  String get petItemMug => 'แก้วคาเฟ่';

  @override
  String get petItemCookies => 'คุกกี้';

  @override
  String get petItemTracks => 'รางรถไฟ';

  @override
  String get petItemCart => 'รถเข็นจิ๋ว';

  @override
  String get petItemStation => 'สถานี';

  @override
  String get petItemSeedBag => 'ถุงเมล็ด';

  @override
  String get petItemShelf => 'ชั้นวาง';

  @override
  String get petItemJar => 'โหลห้องเก็บ';

  @override
  String get petItemLadder => 'บันได';

  @override
  String get petItemStar => 'ดาวดวงใหม่';

  @override
  String get petItemPot => 'กระถางสวน';

  @override
  String get petItemBridge => 'สะพานจิ๋ว';

  @override
  String get petItemMushroom => 'บ้านเห็ด';

  @override
  String get petItemHat => 'หมวกปาร์ตี้';

  @override
  String get petItemCake => 'เค้กเบอร์รี';

  @override
  String get petItemConfetti => 'คอนเฟตติ';

  @override
  String get petItemClearing => 'มุมโล่งสงบ';

  @override
  String get petItemBed => 'ที่นอนนุ่ม';

  @override
  String get petItemToy => 'ของเล่นโปรด';

  @override
  String get petItemFireflies => 'หิ่งห้อย';

  @override
  String get petItemMailbox => 'ตู้จดหมาย';

  @override
  String get petItemLetters => 'จดหมาย';

  @override
  String get petItemSatchel => 'กระเป๋าไปรษณีย์';

  @override
  String get petItemEasel => 'ขาตั้งภาพ';

  @override
  String get petItemPaints => 'สี';

  @override
  String get petItemFrame => 'กรอบรูป';

  @override
  String get petItemTent => 'เต็นท์';

  @override
  String get petItemCampfire => 'กองไฟ';

  @override
  String get neighborsTitle => 'เพื่อนบ้าน';

  @override
  String get neighborsClose => 'ปิด';

  @override
  String get neighborsTabAll => 'ผู้เล่นทั้งหมด';

  @override
  String get neighborsTabSaved => 'รายการโปรด';

  @override
  String get neighborsSearchHint => 'ค้นจากต้นชื่อ';

  @override
  String get neighborsForYou => 'สำหรับคุณ';

  @override
  String neighborsUpdates(int count) {
    return 'อัปเดต $count รายการ';
  }

  @override
  String get neighborsShowLess => 'ย่อ';

  @override
  String get neighborsEmptySaved => 'คนที่คุณบันทึกไว้จะอยู่ที่นี่';

  @override
  String get neighborsBrowsePlayers => 'ดูผู้เล่นทั้งหมด';

  @override
  String get neighborsEmptySearch => 'ไม่มีชื่อที่ขึ้นต้นแบบนี้';

  @override
  String get neighborsEmptyPlayers => 'ไม่มีผู้เล่นคนอื่นในรายการนี้';

  @override
  String get neighborsOffline =>
      'ไม่มีการเชื่อมต่อ รายชื่อที่โหลดไว้แล้วยังอยู่';

  @override
  String get neighborsLoadFailed => 'โหลดผู้เล่นไม่สำเร็จ';

  @override
  String get neighborsRetry => 'ลองอีกครั้ง';

  @override
  String get neighborsLoading => 'กำลังโหลดผู้เล่น';

  @override
  String get neighborsLoadingMore => 'กำลังโหลดเพิ่ม';

  @override
  String neighborsLevel(int level) {
    return 'ระดับ $level';
  }

  @override
  String get neighborsAdd => 'เพิ่มในรายการโปรด';

  @override
  String get neighborsRemove => 'เอาออกจากรายการโปรด';

  @override
  String neighborsSaved(String name) {
    return '$name อยู่ในรายการโปรดแล้ว';
  }

  @override
  String neighborsRemoved(String name) {
    return 'เอา $name ออกจากรายการโปรดแล้ว';
  }

  @override
  String get neighborsFindAgain => 'หาในรายการโปรด';

  @override
  String get neighborsBack => 'กลับไปรายชื่อ';

  @override
  String get neighborsSavedHint =>
      'บันทึกผู้เล่นนี้ไว้ แล้วเปิดอีกครั้งจากรายการโปรด';

  @override
  String get neighborsSignalAsksHelp => 'ขอความช่วยเหลือ';

  @override
  String get neighborsSignalSeeksDefense => 'หาคนปกป้อง';

  @override
  String get neighborsSignalOffersCross => 'เสนอผสมพันธุ์พืช';

  @override
  String get neighborsSignalAwaitsReply => 'รอคำตอบ';

  @override
  String get neighborsSignalHelpedYou => 'ช่วยคุณแล้ว';

  @override
  String neighborsUnseen(int count) {
    return 'ใหม่ $count';
  }

  @override
  String get neighborsHistory => 'สิ่งที่ทำร่วมกัน';

  @override
  String get neighborsBlock => 'บล็อก';

  @override
  String neighborsBlocked(String name) {
    return 'บล็อก $name แล้ว และซ่อนจากรายการ';
  }

  @override
  String get neighborsWaiting => 'กำลังรอคำตอบ';

  @override
  String get neighborsUnavailable => 'การกระทำนี้ใช้ไม่ได้';

  @override
  String get neighborsFailed => 'ยังไม่สำเร็จ ลองอีกครั้งได้';

  @override
  String get neighborsEnded => 'ข้อเสนอนี้จบแล้ว';

  @override
  String get neighborsDeclined => 'ข้อเสนอถูกปฏิเสธ';

  @override
  String get neighborsCancelled => 'ข้อเสนอถูกยกเลิก';

  @override
  String get neighborsInProgress => 'กำลังทำ';

  @override
  String get neighborsDone => 'เสร็จแล้ว';

  @override
  String get neighborsReply => 'ตอบ';

  @override
  String get neighborsViewOffer => 'ดูข้อเสนอ';

  @override
  String get neighborsPeaceful => 'การกระทำที่เป็นมิตร';

  @override
  String get neighborsAttackSection => 'โจมตี';

  @override
  String get neighborsAttackExplain => 'นี่จะเริ่มการโจมตีผู้เล่นนี้';

  @override
  String get neighborsConfirm => 'ยืนยัน';

  @override
  String get neighborsThank => 'ขอบคุณ';

  @override
  String neighborsThankSent(String name) {
    return 'ส่งคำขอบคุณถึง $name แล้ว';
  }

  @override
  String get neighborsOfferAgain => 'เสนออีกครั้ง';

  @override
  String neighborsCost(String cost) {
    return 'จะใช้: $cost';
  }

  @override
  String neighborsOutcome(String outcome) {
    return 'หลังยืนยัน: $outcome';
  }

  @override
  String get neighborsHelpAction => 'ช่วย';

  @override
  String get neighborsDefenseAction => 'ปกป้อง';

  @override
  String get neighborsCrossDecline => 'ปฏิเสธ';

  @override
  String neighborsUsesPlant(String plant) {
    return 'พืช: $plant';
  }

  @override
  String get neighborsPlantStays => 'พืชนี้ยังอยู่กับเจ้าของ';

  @override
  String get neighborsPlantLeaves => 'พืชนี้ถูกใช้ไป';

  @override
  String neighborsMemoryHelped(String name) {
    return '$name ช่วยพืชของคุณ';
  }

  @override
  String neighborsMemoryDefended(String name) {
    return 'สัตว์เลี้ยงของ $name ปกป้องสวน';
  }

  @override
  String neighborsMemoryCrossed(String name) {
    return 'คุณและ $name ได้พืชใหม่';
  }

  @override
  String neighborsMemoryThanked(String name) {
    return 'คุณขอบคุณ $name';
  }

  @override
  String neighborsMemoryRaid(String name) {
    return 'รายงานการโจมตีกับ $name';
  }

  @override
  String get neighborsReasonUnsupported => 'การกระทำร่วมกันยังใช้ไม่ได้';

  @override
  String get neighborsReasonNotAllowed => 'การกระทำนี้ใช้กับผู้เล่นนี้ไม่ได้';

  @override
  String get neighborsReasonMissingPet => 'ต้องมีสัตว์เลี้ยงที่ปกป้องได้';

  @override
  String get neighborsReasonMissingPlant => 'ต้องมีพืชสำหรับการกระทำนี้';

  @override
  String neighborsProtector(String name) {
    return 'ผู้ปกป้อง: $name';
  }

  @override
  String neighborsUntil(String time) {
    return 'จนถึง $time';
  }

  @override
  String neighborsAttackPower(int value) {
    return 'โจมตี $value';
  }

  @override
  String neighborsDefensePower(int value) {
    return 'ป้องกัน $value';
  }

  @override
  String neighborsLoot(int count) {
    return 'เอสเซนส์ที่เป็นไปได้: $count';
  }

  @override
  String get showcaseTitle => 'ตู้แสดงพืช';

  @override
  String get showcaseAll => 'พืชทั้งหมด';

  @override
  String get showcaseMine => 'พืชของฉัน';

  @override
  String get showcaseManage => 'นำพืชของฉันมาแสดง';

  @override
  String get showcaseRefresh => 'รีเฟรชตู้แสดงพืช';

  @override
  String get showcaseIntro =>
      'ชมพืชที่ผู้เล่นคนอื่นปลูก แต่ละการ์ดจะแสดงชื่อเจ้าของ';

  @override
  String get showcaseMyIntro =>
      'เลือกพืชที่เก็บเกี่ยวแล้วเพื่อแสดงพร้อมชื่อผู้เล่นของคุณ พืชยังอยู่ในคลัง แต่จะใช้ให้อาหารสัตว์เลี้ยงไม่ได้จนกว่าจะนำออกจากตู้แสดง';

  @override
  String get showcaseEmpty =>
      'ยังไม่มีพืชในตู้แสดง คุณสามารถนำพืชต้นแรกมาแสดงได้';

  @override
  String get showcaseChoose => 'เลือกพืช';

  @override
  String get showcaseNoPlants => 'เก็บเกี่ยวพืชจากแปลงเพื่อนำมาแสดง';

  @override
  String get showcasePublish => 'นำมาแสดง';

  @override
  String get showcaseWithdraw => 'นำออกจากตู้แสดง';

  @override
  String get showcasePublished => 'กำลังแสดงให้ทุกคนเห็น';

  @override
  String get showcasePrivate => 'มีเพียงคุณที่เห็นพืชนี้';

  @override
  String get showcaseUnconfirmed =>
      'ยังยืนยันการแสดงไม่ได้ ลองอีกครั้งหรือนำออกจากตู้แสดง';

  @override
  String get showcasePublishedNotice => 'พืชของคุณอยู่ในตู้แสดงสาธารณะแล้ว';

  @override
  String get showcaseRemovedNotice =>
      'นำพืชออกจากตู้แสดงแล้ว คุณใช้พืชนี้ได้อีกครั้ง';

  @override
  String get showcaseUnavailable =>
      'ตู้แสดงออนไลน์ยังไม่พร้อมใช้งาน พืชของคุณยังอยู่';

  @override
  String get showcaseLoadFailed =>
      'รีเฟรชตู้แสดงไม่ได้ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get showcaseOperationFailed =>
      'ยังยืนยันการดำเนินการไม่ได้ พืชของคุณได้รับการป้องกัน ลองอีกครั้งเมื่อเชื่อมต่อ';

  @override
  String get showcaseMissingLocal => 'พืชที่แสดงนี้ไม่อยู่ในคลังของอุปกรณ์นี้';

  @override
  String get showcaseMore => 'โหลดพืชเพิ่มเติม';

  @override
  String showcaseSpecimen(int number) {
    return 'พืชหมายเลข $number';
  }

  @override
  String get showcaseFeedLocked =>
      'พืชที่แสดงอยู่ใช้ให้อาหารสัตว์เลี้ยงไม่ได้ กรุณานำออกจากตู้แสดงก่อน';

  @override
  String get crossOpen => 'ผสมพืช';

  @override
  String get crossTitle => 'การผสมพืช';

  @override
  String get crossNeedTwo => 'เลือกพืชที่เก็บเกี่ยวแล้วสองต้น';

  @override
  String get crossAimCombat => 'อาหารต่อสู้';

  @override
  String get crossAimGarden => 'สวนที่งอกเร็ว';

  @override
  String get crossAimSeeds => 'เลือกเมล็ด';

  @override
  String crossOdds(int ordinary, int raised, int rare) {
    return 'ธรรมดา $ordinary% แข็งแรงขึ้น $raised% หายาก $rare%';
  }

  @override
  String get crossConfirm => 'ผสม';

  @override
  String get crossFailed => 'บันทึกการผสมไม่ได้ ลองอีกครั้ง';

  @override
  String get crossListed => 'นำพืชออกจากตู้แสดงก่อน';

  @override
  String get crossWaiting => 'จบการผสมที่ค้างอยู่ก่อน';

  @override
  String get crossChooseTrait => 'เลือกโจมตีหรือป้องกันสำหรับอาหารนี้';

  @override
  String get crossAttack => 'โจมตี';

  @override
  String get crossDefense => 'ป้องกัน';

  @override
  String get crossChooseSpecies => 'เลือกเมล็ด';

  @override
  String get crossOrdinary => 'การผสมได้ผลธรรมดา เพิ่มเมล็ดธรรมดาแล้ว';

  @override
  String get crossGranted => 'เมล็ดจากการผสมอยู่ในคลังเมล็ด';

  @override
  String get crossTraitAttack => 'อาหารโจมตี';

  @override
  String get crossTraitDefense => 'อาหารป้องกัน';

  @override
  String get crossTraitBloom => 'โตเร็วขึ้น';

  @override
  String get plantOriginCross => 'ที่มา: การผสม';

  @override
  String get neighborsActions => 'การกระทำ';

  @override
  String get neighborsActionMessage => 'ส่งข้อความ';

  @override
  String get neighborsActionDefend => 'ปกป้อง';

  @override
  String get neighborsActionCross => 'เสนอการผสม';

  @override
  String get neighborsActionRaid => 'โจมตี';

  @override
  String get neighborsActionsOffline => 'การกระทำกับผู้เล่นต้องใช้อินเทอร์เน็ต';

  @override
  String get neighborsNeedGuard =>
      'กำหนดสัตว์เลี้ยงผู้พิทักษ์ในลานสัตว์เลี้ยงก่อน';

  @override
  String get neighborsNeedRaider =>
      'กำหนดสัตว์เลี้ยงจู่โจมในลานสัตว์เลี้ยงก่อน';

  @override
  String get neighborsNeedPlant => 'ต้องมีพืชที่เก็บเกี่ยวแล้วในคลัง';

  @override
  String get neighborsChoosePhrase => 'เลือกข้อความ';

  @override
  String get neighborsChoosePlant => 'เลือกพืชที่จะมอบให้';

  @override
  String get neighborsSend => 'ส่ง';

  @override
  String neighborsSent(String name) {
    return 'ส่งถึง $name แล้ว';
  }

  @override
  String get neighborsAlreadyOpen =>
      'คุณมีคำขอประเภทนี้ที่ยังเปิดอยู่กับผู้เล่นนี้แล้ว';

  @override
  String get neighborsRequestClosed => 'คำขอนี้ปิดไปแล้ว';

  @override
  String get neighborsSendFailed =>
      'ไม่สำเร็จ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String neighborsDefendExplain(String name, int value) {
    return 'เมื่อ $name ตอบรับ สัตว์เลี้ยงของคุณจะช่วยเฝ้าลานของเขา 24 ชั่วโมง ป้องกัน $value';
  }

  @override
  String neighborsRaidExplain(String name, int value) {
    return '$name มีเวลา 24 ชั่วโมงในการส่งสัตว์เฝ้ายาม ลานจะรอดก็ต่อเมื่อผู้เฝ้ายามแรงกว่าพลังโจมตี $value ของคุณ ไม่เช่นนั้นพืชหนึ่งต้นจะถูกเผา และคุณจะได้อีกต้นไป';
  }

  @override
  String get neighborsCrossExplain =>
      'แต่ละคนให้พืชหนึ่งต้นและได้เมล็ดผลลัพธ์หนึ่งเมล็ด พืชของคุณจะถูกใช้เมื่อคุณรับเมล็ดเท่านั้น';

  @override
  String get neighborsMessages => 'ข้อความและคำขอ';

  @override
  String get neighborsPhraseHello => 'สวัสดีเพื่อนบ้าน!';

  @override
  String get neighborsPhraseGoodLuck => 'โชคดีนะ!';

  @override
  String get neighborsPhraseThanks => 'ขอบคุณ!';

  @override
  String get neighborsPhraseNiceGarden => 'สวนสวยมาก!';

  @override
  String get neighborsPhraseLetsCross => 'มาปลูกอะไรหายากด้วยกันเถอะ';

  @override
  String get neighborsPhraseIWillGuard => 'ฉันจะช่วยดูลานของคุณเอง';

  @override
  String get neighborsPhraseReadyForRaid => 'พร้อมไหม? ฉันจะบุกลานของคุณแล้ว!';

  @override
  String get neighborsPhraseWellPlayed => 'เล่นได้ดีมาก!';

  @override
  String neighborsInMessage(String name) {
    return '$name ส่งข้อความถึงคุณ';
  }

  @override
  String neighborsInDefense(String name, int value) {
    return '$name เสนอช่วยเฝ้าลานของคุณ 24 ชั่วโมง ป้องกัน $value';
  }

  @override
  String neighborsInCross(String name, String plant) {
    return '$name เสนอผสม $plant ของเขากับพืชของคุณ';
  }

  @override
  String neighborsInRaid(String name, int value) {
    return '$name กำลังจู่โจมลานของคุณ โจมตี $value';
  }

  @override
  String get neighborsOutMessage => 'คุณส่งข้อความ';

  @override
  String neighborsOutDefense(int value) {
    return 'คุณเสนอการปกป้อง ป้องกัน $value';
  }

  @override
  String neighborsOutCross(String plant) {
    return 'คุณเสนอ $plant สำหรับการผสม';
  }

  @override
  String neighborsOutRaid(int value) {
    return 'คุณจู่โจมลานนี้ โจมตี $value';
  }

  @override
  String neighborsQuote(String name, String text) {
    return '$name: “$text”';
  }

  @override
  String get neighborsYou => 'คุณ';

  @override
  String get neighborsAcceptDefense => 'รับการปกป้อง';

  @override
  String get neighborsChooseCrossPlant => 'เลือกพืชของคุณ';

  @override
  String get neighborsRepel => 'ป้องกันลาน';

  @override
  String get neighborsCancelRequest => 'ยกเลิกคำขอ';

  @override
  String get neighborsClaimSeed => 'รับเมล็ด';

  @override
  String neighborsRaidWon(int attack, int defense) {
    return 'การจู่โจมสำเร็จ: โจมตี $attack ต่อป้องกัน $defense';
  }

  @override
  String neighborsRaidRepelled(int attack, int defense) {
    return 'ลานต้านไว้ได้: โจมตี $attack ต่อป้องกัน $defense';
  }

  @override
  String neighborsGuarding(String time) {
    return 'การปกป้องมีผลถึง $time';
  }

  @override
  String get neighborsGuardEnded => 'การปกป้องสิ้นสุดแล้ว';

  @override
  String neighborsCrossResult(String plant) {
    return 'ผลการผสม: เมล็ด $plant';
  }

  @override
  String get neighborsSeedClaimed => 'เมล็ดอยู่ในคลังเมล็ดของคุณแล้ว';

  @override
  String neighborsSeedMissing(String plant) {
    return 'ต้องมี $plant ในคลังจึงจะรับเมล็ดได้';
  }

  @override
  String neighborsYourDefense(int value) {
    return 'การป้องกันลานของคุณ: $value';
  }

  @override
  String get neighborsReplied => 'ส่งคำตอบแล้ว';

  @override
  String get neighborsSignalMessage => 'ข้อความใหม่';

  @override
  String get neighborsSignalDefense => 'เสนอการปกป้อง';

  @override
  String get neighborsSignalRaid => 'กำลังจู่โจมลานของคุณ';

  @override
  String get neighborsSignalResult => 'ได้รับคำตอบแล้ว';

  @override
  String get socialFriends => 'เพื่อน';

  @override
  String get socialFriend => 'คุณเป็นเพื่อนกันแล้ว';

  @override
  String get socialFriendsEmpty =>
      'ยังไม่มีเพื่อน เปิดโปรไฟล์เพื่อนบ้านแล้วส่งคำเชิญ เมื่อยอมรับแล้วจะปรากฏที่นี่';

  @override
  String get socialIncoming => 'คำเชิญเป็นเพื่อน';

  @override
  String get socialWaiting => 'รอการตอบรับ';

  @override
  String get socialUnavailable =>
      'เชื่อมต่อไม่ได้ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get socialChat => 'การสนทนา';

  @override
  String get socialRemoveFriend => 'ลบเพื่อน';

  @override
  String get socialFriendConsent =>
      'การยอมรับเป็นเพื่อนอนุญาตให้ทั้งสองคนส่งข้อความส่วนตัวได้';

  @override
  String get socialAccept => 'ยอมรับเป็นเพื่อน';

  @override
  String get socialInvite => 'เชิญเป็นเพื่อน';

  @override
  String get socialInvitesClosed => 'ผู้เล่นนี้ยังไม่รับคำเชิญเป็นเพื่อน';

  @override
  String get socialMyProfile => 'โปรไฟล์ของฉัน';

  @override
  String get socialProfilePublic =>
      'ข้อมูลเหล่านี้ไม่จำเป็นต้องกรอกและผู้เล่นอื่นมองเห็นได้';

  @override
  String get socialAbout => 'เกี่ยวกับฉัน';

  @override
  String get socialLanguage => 'ภาษาที่ใช้สนทนา';

  @override
  String get socialInterests => 'ความสนใจ';

  @override
  String get socialGoal => 'สิ่งที่มองหาในเกม';

  @override
  String get socialPicAboutFriendly => 'เป็นมิตร';

  @override
  String get socialPicAboutCalm => 'สงบ';

  @override
  String get socialPicAboutCheerful => 'ร่าเริง';

  @override
  String get socialPicAboutGentle => 'อ่อนโยน';

  @override
  String get socialPicAboutNight => 'ตอนเย็น';

  @override
  String get socialPicAboutCurious => 'อยากรู้';

  @override
  String get socialPicInterestGarden => 'สวน';

  @override
  String get socialPicInterestPets => 'สัตว์เลี้ยง';

  @override
  String get socialPicInterestMahjong => 'ไพ่นกกระจอก';

  @override
  String get socialPicInterestCourtyard => 'ลานบ้าน';

  @override
  String get socialPicInterestSeeds => 'เมล็ด';

  @override
  String get socialPicInterestStars => 'ดาว';

  @override
  String get socialPicGoalFlower => 'ดอกไม้หายาก';

  @override
  String get socialPicGoalHouse => 'บ้านที่สวยขึ้น';

  @override
  String get socialPicGoalFriends => 'เพื่อน';

  @override
  String get socialPicGoalLevels => 'ผ่านด่าน';

  @override
  String get socialPicGoalChat => 'คุยกัน';

  @override
  String get socialPicGoalCross => 'ผสมพันธุ์';

  @override
  String get socialOpenInvites => 'รับคำเชิญเป็นเพื่อนใหม่';

  @override
  String get socialSave => 'บันทึกโปรไฟล์';

  @override
  String get socialProfileHeading => 'โปรไฟล์';

  @override
  String get socialNotChosen => 'ยังไม่ได้เลือก';

  @override
  String get socialInvitesOpen => 'รับคำเชิญเป็นเพื่อน';

  @override
  String get socialBadgesTitle => 'ป้ายในรายชื่อเพื่อนบ้าน';

  @override
  String get socialBadgesExplain =>
      'ใช้แต้มเพื่อแสดงอวาตาร์และป้ายโปรไฟล์ข้างชื่อของคุณชั่วคราว';

  @override
  String socialBadgesActive(String time) {
    return 'เพื่อนบ้านมองเห็นถึง $time';
  }

  @override
  String get socialBadgesOff => 'ตอนนี้รายชื่อแสดงเฉพาะชื่อของคุณ';

  @override
  String socialBadgesOffer(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days วัน',
    );
    return '$_temp0 · $price แต้ม';
  }

  @override
  String get socialBadgesTooLong => 'ต่อเวลาได้ไม่เกิน 30 วันล่วงหน้า';

  @override
  String get socialBadgesFailed => 'เปิดป้ายไม่สำเร็จ คืนแต้มให้แล้ว';

  @override
  String get socialBadgesNotListed =>
      'คุณยังไม่อยู่ในรายชื่อเพื่อนบ้าน ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง ยังไม่มีการหักแต้ม';

  @override
  String get socialChatEmpty => 'ทักทายหรือขอบคุณเพื่อนที่ช่วยเหลือ!';

  @override
  String get socialReportMessage => 'รายงานข้อความ';

  @override
  String get socialOlderMessages => 'ข้อความก่อนหน้า';

  @override
  String get socialSendFailed =>
      'ยังไม่ยืนยันการส่ง ลองอีกครั้งหรือกลับไปที่โปรไฟล์เพื่อตรวจสอบสถานะเพื่อน';

  @override
  String get socialMessageHint => 'เขียนข้อความ';

  @override
  String get socialGrownTogether => 'ปลูกร่วมกับ';

  @override
  String get socialHistoryEmpty => 'ช่วงเวลาร่วมกันจะปรากฏที่นี่';

  @override
  String get socialHistory => 'ประวัติร่วมกัน';

  @override
  String get socialProfileReport => 'รายงานโปรไฟล์';

  @override
  String neighborsRaidDeadline(String time) {
    return 'หากไม่ตอบภายใน $time ผู้เฝ้ายามที่กำหนดไว้จะป้องกันเอง';
  }

  @override
  String get neighborsRaidDefendTitle => 'ใครจะป้องกันลาน?';

  @override
  String neighborsRaidDefendRule(int value) {
    return 'พลังโจมตี $value ลานจะรอดก็ต่อเมื่อผู้ป้องกันแรงกว่า';
  }

  @override
  String neighborsRaidOptionOwn(String pet, int value) {
    return '$pet · ป้องกัน $value';
  }

  @override
  String neighborsRaidOptionGuard(String name, int value) {
    return 'ผู้เฝ้ายามจาก $name · ป้องกัน $value';
  }

  @override
  String neighborsRaidOptionHelp(String name, int value) {
    return '$name ตอบรับคำขอ · ป้องกัน $value';
  }

  @override
  String get neighborsRaidOptionNone => 'ไม่ป้องกัน';

  @override
  String get neighborsRaidHolds => 'รอด';

  @override
  String get neighborsRaidFalls => 'อ่อนกว่า';

  @override
  String get neighborsRaidNoDefenders =>
      'คุณไม่มีสัตว์เฝ้ายาม และยังไม่มีใครตอบรับคำขอ หากไม่มีผู้ป้องกัน การจู่โจมจะสำเร็จ';

  @override
  String get neighborsRaidChooseLoss =>
      'ลานจะไม่รอด เลือกพืชที่จะถูกเผา ผู้จู่โจมจะสุ่มเอาหนึ่งต้นจากที่เหลือ';

  @override
  String neighborsRaidOnlyPlant(String plant) {
    return 'พืชต้นเดียวของคุณ $plant จะตกเป็นของผู้จู่โจม';
  }

  @override
  String get neighborsRaidEmptyStorage =>
      'คลังว่างเปล่า ผู้จู่โจมจึงไม่ได้อะไรไป';

  @override
  String get neighborsRaidAcceptLoss => 'ยอมรับความสูญเสีย';

  @override
  String neighborsRaidDestroyed(String plant) {
    return 'ถูกเผา: $plant';
  }

  @override
  String neighborsRaidStolen(String plant) {
    return 'ผู้จู่โจมเอาไป: $plant';
  }

  @override
  String neighborsRaidLoot(String plant) {
    return 'ของที่ได้: $plant';
  }

  @override
  String get neighborsRaidNoLoot => 'ในคลังไม่มีอะไรให้เอาไป';

  @override
  String get neighborsRaidAutoDefended =>
      'ไม่มีใครตอบทันเวลา ผู้เฝ้ายามที่กำหนดไว้จึงป้องกันเอง';

  @override
  String neighborsRaidDefendedBy(String name) {
    return 'ป้องกันโดยสัตว์ของ $name';
  }

  @override
  String get neighborsRaidTakeLoot => 'รับพืช';

  @override
  String neighborsRaidLootTaken(String plant) {
    return '$plant อยู่ในคลังของคุณแล้ว';
  }

  @override
  String get neighborsRaidTooSoon =>
      'ลานนี้กำลังพักหลังการจู่โจม ลองใหม่ภายหลัง';

  @override
  String get neighborsHelpTitle => 'คำขอความช่วยเหลือ';

  @override
  String neighborsHelpExplain(int price) {
    return 'เพื่อนเห็นคำขอได้ฟรี การขอจากผู้เล่นทุกคนใช้ $price พอยต์ ผู้เฝ้ายามที่ตอบรับจะปรากฏในรายการป้องกัน';
  }

  @override
  String get neighborsHelpAskFriends => 'ขอความช่วยเหลือจากเพื่อน';

  @override
  String neighborsHelpAskEveryone(int price) {
    return 'ขอจากผู้เล่นทุกคน · $price พอยต์';
  }

  @override
  String get neighborsHelpAskedFriends =>
      'เพื่อนของคุณเห็นคำขอความช่วยเหลือแล้ว';

  @override
  String get neighborsHelpAskedEveryone =>
      'ผู้เล่นทุกคนเห็นคำขอความช่วยเหลือแล้ว';

  @override
  String get neighborsHelpNoFriends => 'คุณยังไม่มีเพื่อนให้ขอความช่วยเหลือ';

  @override
  String neighborsHelpArrived(int count) {
    return 'ผู้ป้องกันที่ตอบรับ: $count';
  }

  @override
  String get neighborsHelpFailed =>
      'ส่งคำขอความช่วยเหลือไม่สำเร็จ คืนพอยต์ที่ใช้ไปแล้ว';

  @override
  String neighborsHelpCallLine(String name, int attack) {
    return '$name ถูกจู่โจม · โจมตี $attack';
  }

  @override
  String neighborsHelpUntil(String time) {
    return 'เปิดถึง $time';
  }

  @override
  String neighborsHelpSend(int value) {
    return 'ส่งผู้เฝ้ายามของฉัน · ป้องกัน $value';
  }

  @override
  String neighborsHelpSent(String name) {
    return 'ผู้เฝ้ายามของคุณพร้อมป้องกัน $name แล้ว';
  }

  @override
  String get neighborsHelpOffered => 'เสนอผู้เฝ้ายามของคุณแล้ว';

  @override
  String get neighborsHelpNeedGuard => 'กำหนดสัตว์เฝ้ายามก่อนจึงจะช่วยได้';

  @override
  String get plantOriginRaid => 'ได้มาจากการจู่โจม';

  @override
  String get deleteAccount => 'ลบบัญชีและข้อมูล';

  @override
  String get deleteAccountTitle => 'ลบบัญชีและข้อมูล?';

  @override
  String get deleteAccountBody =>
      'การทำนี้จะลบสนามหญ้า ความคืบหน้า และการตั้งค่าบนอุปกรณ์นี้ หากอุปกรณ์ลงชื่อเข้าใช้แล้ว บัญชีนิรนามนี้จะถูกลบด้วย ได้แก่ อันดับ โปรไฟล์ มิตรภาพ ข้อความ การกระทำกับเพื่อนบ้าน เสียงเรียกช่วยเหลือ และการ์ดโชว์ต้นไม้ บทสนทนาหรือคำขอที่ใช้ร่วมกันจะหายไปของอีกฝ่ายด้วย รายงานที่ผู้เล่นคนอื่นส่งไว้จะคงอยู่จนกว่าการตรวจสอบจะจบ การลบนี้ย้อนกลับไม่ได้';

  @override
  String get deleteAccountConfirm => 'ลบ';

  @override
  String get deleteAccountFailed =>
      'ลบไม่สำเร็จ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง หรืออีเมล myevidentsuccess@gmail.com';

  @override
  String get deleteAccountWorking => 'กำลังลบ…';
}
