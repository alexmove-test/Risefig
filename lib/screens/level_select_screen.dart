import 'dart:async';

import 'package:flutter/material.dart';

import '../debug_agent_log.dart';
import '../debug_boot_timer.dart';
import '../l10n/l10n.dart';
import '../models/game_snapshot.dart';
import '../models/garden.dart';
import '../models/house_upgrade.dart';
import '../models/hub_event.dart';
import '../models/hub_goal.dart';
import '../models/levels.dart';
import '../models/meta_features.dart';
import '../models/plot_kind.dart';
import '../models/rank_climb.dart';
import '../models/seed_catalog.dart';
import '../models/weekly_quests.dart';
import '../models/weekly_score.dart';
import '../models/neighbor_request.dart';
import '../models/neighbor_social.dart';
import '../services/analytics_service.dart';
import '../services/firebase_neighbor_directory.dart';
import '../services/neighbor_actions.dart';
import '../services/neighbor_records.dart';
import '../services/neighbor_request_repository.dart';
import '../services/raid_help_repository.dart';
import '../services/social_repository.dart';
import '../services/ugc_block_store.dart';
import '../services/courtyard_reward_store.dart';
import '../services/feature_intro_store.dart';
import '../services/firebase_leaderboard_repository.dart';
import '../services/hub_feed.dart';
import '../services/hub_goals.dart';
import '../services/leaderboard_service.dart';
import '../services/local_reminder_service.dart';
import '../services/pet_store.dart';
import '../services/fox_adventure_store.dart';
import '../services/player_profile_store.dart';
import '../services/points_controller.dart';
import '../services/progress_store.dart';
import '../services/quest_store.dart';
import '../services/table_look_controller.dart';
import '../widgets/app_settings.dart';
import '../widgets/courtyard/courtyard_estate.dart';
import '../widgets/courtyard/courtyard_pan_hint.dart';
import '../widgets/courtyard/courtyard_win_overlay.dart';
import '../widgets/courtyard/courtyard_world.dart';
import '../widgets/courtyard/courtyard_world_layout.dart';
import '../widgets/courtyard/home_upgrade_preview.dart';
import '../widgets/feature_intro_card.dart';
import '../widgets/garden/garden_sheets.dart';
import '../widgets/garden/plant_chip.dart';
import '../widgets/garden/plant_flight.dart';
import '../widgets/seeds/house_sheet.dart';
import '../widgets/seeds/seed_storage_sheet.dart';
import '../widgets/hub_goal_banner.dart';
import '../widgets/neighbors/neighbor_copy.dart';
import '../widgets/neighbors/neighbors_panel.dart';
import '../widgets/pets/pet_page.dart';
import '../widgets/points/points_chip.dart';
import '../widgets/points/points_shop_sheet.dart';
import '../widgets/rank_climb_overlay.dart';
import '../widgets/table_coach_banner.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

/// Р”РІРѕСЂ РЅР° РІРµСЃСЊ СЌРєСЂР°РЅ; СЃРµС‚РєР° СѓСЂРѕРІРЅРµР№ РѕС‚РєСЂС‹РІР°РµС‚СЃСЏ С€С‚РѕСЂРєРѕР№.
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  ProgressStore? _store;
  QuestStore? _quests;
  PetStore? _pets;
  FoxAdventureStore? _foxAdventure;
  CourtyardRewardStore? _courtyardRewards;
  FeatureIntroStore? _intros;
  bool _foxSceneOpen = false;
  bool _firstSessionCover = false;
  bool _didAutoOpenFirst = false;
  int _cycle = 0;
  CourtyardWinReveal? _winReveal;
  RankClimb? _rankClimb;
  Timer? _panHintTimer;
  var _panHintDismissed = false;
  Timer? _ripenTimer;
  DateTime? _ripenAt;
  List<NeighborYard> _neighbors = NeighborYard.placed(
    others: const [],
    online: false,
  );
  PointsController? _points;
  var _buyingHouse = false;
  var _houseOpen = false;
  var _yardSheet = false;
  final _plantChipKey = GlobalKey();
  ({SeedSpecies species, Offset from, Offset to})? _flight;
  final _neighborsKey = GlobalKey<NeighborsOverlayState>();
  late final FirebaseNeighborDirectory _neighborDirectory =
      FirebaseNeighborDirectory(progress: () => _store);
  AcquaintanceStore? _acquaintances;
  NeighborNoticeStore? _notices;
  NeighborHistoryStore? _history;
  UgcBlockStore? _neighborBlocks;
  var _neighborsMounted = false;
  var _neighborsOpen = false;
  var _neighborsCovering = false;
  var _unseenNeighbors = 0;
  final _neighborRequests = FirebaseNeighborRequestRepository();
  final _raidHelp = FirebaseRaidHelpRepository();
  final _social = FirebaseSocialRepository();
  String? _requestsMe;
  List<NeighborRequest> _knownRequests = const [];

  static const _panHintDuration = Duration(seconds: 6);

  static const _gold = Color(0xFFD4AF37);
  static const _goldSoft = Color(0xFFE8C96A);
  static const _woodTop = Color(0xFF6B3E24);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final points = PointsScope.maybeOf(context);
    if (!identical(points, _points)) {
      _points?.removeListener(_onPoints);
      _points = points;
      points?.addListener(_onPoints);
    }
    _ensurePanHintTimer();
  }

  void _onPoints() {
    final store = _store;
    final points = _points;
    if (store != null &&
        points != null &&
        points.isPersistent &&
        !points.houseMigrated) {
      unawaited(points.migrateHouse(store));
    }
  }

  @override
  void dispose() {
    _points?.removeListener(_onPoints);
    _panHintTimer?.cancel();
    _ripenTimer?.cancel();
    super.dispose();
  }

  bool get _panHintPending {
    final store = _store;
    return store != null && !store.courtyardPanHintDone && !_firstSessionCover;
  }

  bool get _showPanHint =>
      _panHintPending && !_panHintDismissed && _winReveal == null;

  void _hidePanHintBanner() {
    _panHintTimer?.cancel();
    _panHintTimer = null;
    if (_panHintDismissed) return;
    _panHintDismissed = true;
    if (mounted) setState(() {});
  }

  void _markPanHintLearned() {
    _panHintTimer?.cancel();
    _panHintTimer = null;
    _panHintDismissed = true;
    final store = _store;
    if (store != null && !store.courtyardPanHintDone) {
      unawaited(store.markCourtyardPanHintDone());
    }
    if (mounted) setState(() {});
  }

  void _armPanHintAfterWin() {
    final store = _store;
    if (store == null || store.courtyardPanHintDone) return;
    _panHintTimer?.cancel();
    _panHintTimer = null;
    _panHintDismissed = false;
  }

  void _ensurePanHintTimer() {
    if (!_showPanHint) {
      _panHintTimer?.cancel();
      _panHintTimer = null;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_showPanHint) {
        _panHintTimer?.cancel();
        _panHintTimer = null;
        return;
      }
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
      _panHintTimer ??= Timer(_panHintDuration, _hidePanHintBanner);
    });
  }

  Future<void> _load() async {
    // #region agent log
    agentDbg(
      location: 'level_select_screen.dart:_load',
      message: 'progress load start',
      hypothesisId: 'D',
      data: {'ms': agentBoot.elapsedMilliseconds},
    );
    // #endregion
    final store = await ProgressStore.open();
    final hadBrokenStreak = store.dailyStreak > 0 && store.visibleStreak() == 0;
    await store.ensureWeek();
    await store.expireStreakIfNeeded();
    if (hadBrokenStreak) {
      await AnalyticsService.log('streak_broken');
    }
    final quests = await QuestStore.open();
    final pets = await PetStore.open();
    final foxAdventure = await FoxAdventureStore.open();
    final courtyardRewards = await CourtyardRewardStore.open();
    await courtyardRewards.bootstrapCompleted([
      for (var id = 1; id <= store.maxUnlocked; id++)
        if (store.isCompleted(id)) id,
    ]);
    await foxAdventure.attachExistingCompanion(pets);
    final acquaintances = await AcquaintanceStore.open();
    final notices = await NeighborNoticeStore.open();
    final history = await NeighborHistoryStore.open();
    final neighborBlocks = await UgcBlockStore.open();
    final intros = await FeatureIntroStore.open();
    final unseenNeighbors = unseenNeighborCount(const [], notices.seenIds);
    // #region agent log
    agentDbg(
      location: 'level_select_screen.dart:_load',
      message: 'progress load done',
      hypothesisId: 'D',
      data: {'ms': agentBoot.elapsedMilliseconds},
    );
    // #endregion
    if (!mounted) return;
    _intros = intros;
    final points = PointsScope.read(context);
    if (points != null) await points.migrateHouse(store);
    if (!mounted) return;
    unawaited(TableLookScope.maybeOf(context)?.attachRewards(courtyardRewards));

    if (!store.hasCompletedAny && !_didAutoOpenFirst) {
      _didAutoOpenFirst = true;
      setState(() {
        _store = store;
        _quests = quests;
        _pets = pets;
        _foxAdventure = foxAdventure;
        _courtyardRewards = courtyardRewards;
        _acquaintances = acquaintances;
        _notices = notices;
        _history = history;
        _neighborBlocks = neighborBlocks;
        _unseenNeighbors = unseenNeighbors;
        _cycle = 0;
        _firstSessionCover = true;
      });
      unawaited(_loadNeighbors());
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _openLevel(Levels.byId(1));
      });
      return;
    }

    setState(() {
      _store = store;
      _quests = quests;
      _pets = pets;
      _foxAdventure = foxAdventure;
      _courtyardRewards = courtyardRewards;
      _acquaintances = acquaintances;
      _notices = notices;
      _history = history;
      _neighborBlocks = neighborBlocks;
      _unseenNeighbors = unseenNeighbors;
      _cycle = Levels.cycleOf(store.lastPlayedLevel);
    });
    unawaited(_loadNeighbors());
    _ensurePanHintTimer();
    _afterHubReady();
  }

  Future<void> _loadNeighbors() async {
    final store = _store;
    if (store == null) return;
    final profile = await PlayerProfileStore.open();
    final fetch = await FirebaseLeaderboardRepository.fetchTop(
      progress: store,
      profile: profile,
    );
    if (!mounted) return;
    final nearby = LeaderboardService.nearbyOthers(
      fetch.entries,
      count: CourtyardWorldLayout.neighborCount,
    );
    setState(() {
      _neighbors = NeighborYard.placed(others: nearby, online: fetch.online);
    });
    unawaited(_loadNeighborRequests());
  }

  Future<void> _loadNeighborRequests() async {
    final me = await _neighborRequests.connect();
    if (me == null || !mounted) return;
    try {
      final list = await _neighborRequests.fetch(me);
      if (!mounted) return;
      _onNeighborRequests(me.id, list);
    } catch (error) {
      debugPrint('Neighbor requests for the badge failed: $error');
    }
  }

  void _onNeighborRequests(String me, List<NeighborRequest> requests) {
    _requestsMe = me;
    _knownRequests = requests;
    _refreshNeighborNotices();
  }

  int _neighborUnseen(NeighborNoticeStore notices) {
    final me = _requestsMe;
    final requests = me == null
        ? 0
        : unseenRequestCount(
            _knownRequests,
            me,
            notices.seenIds,
            blockedIds: _neighborBlocks?.blockedIds ?? const {},
          );
    return unseenNeighborCount(const [], notices.seenIds) + requests;
  }

  Future<void> _afterHubReady() async {
    if (!mounted) return;
    await LocalReminderService.resync(l10n: AppLocalizations.of(context));
    if (!mounted) return;
    final summary = await _store?.consumeSeasonSheet();
    if (!mounted || summary == null) return;
    await _showSeasonClosed(summary);
  }

  Future<void> _showSeasonClosed(WeekSeasonSummary summary) async {
    final l10n = AppLocalizations.of(context);
    final rating = _formatRating(summary.rating);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3A2012),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
              width: 1.6,
            ),
          ),
          title: Text(
            l10n.seasonClosed,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFE8C96A),
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (summary.rank != null)
                Text(
                  l10n.lastWeekPlace(summary.rank!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF8F1DE),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                l10n.lastWeekScore(rating),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFF8F1DE).withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                l10n.done,
                style: const TextStyle(color: Color(0xFFF8F1DE)),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatRating(int rating) {
    final text = rating.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final posFromEnd = text.length - i;
      buffer.write(text[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  LevelDef _continueLevel(ProgressStore store) {
    final last = store.lastPlayedLevel;
    if (Levels.cycleOf(last) != _cycle) {
      final start = Levels.cycleStartId(_cycle);
      return Levels.byId(start.clamp(1, store.maxUnlocked));
    }
    final nextId = last + 1;
    if (store.isCompleted(last) &&
        nextId <= Levels.maxLevelId &&
        store.isUnlocked(nextId) &&
        Levels.cycleOf(nextId) == _cycle) {
      return Levels.byId(nextId);
    }
    return Levels.byId(last);
  }

  Future<void> _openLevel(LevelDef level) async {
    final store = _store;
    if (store == null || !store.isUnlocked(level.id)) return;
    if (_foxSceneOpen) return;
    if (_winReveal != null || _rankClimb != null) {
      setState(() {
        _winReveal = null;
        _rankClimb = null;
      });
    }

    await store.markPlayed(level.id);
    if (!mounted) return;

    final reveal = await _pushTable(
      GameScreen(
        level: level,
        progress: store,
        onProgressChanged: () {
          if (mounted) setState(() {});
        },
      ),
    );
    if (!mounted) return;
    unawaited(_quests?.ensureWeek());
    setState(() {
      _firstSessionCover = false;
      _cycle = reveal?.cycle ?? Levels.cycleOf(_store!.lastPlayedLevel);
      _winReveal = reveal;
      _rankClimb = null;
    });
    if (reveal != null) _armPanHintAfterWin();
    _ensurePanHintTimer();
  }

  Future<void> _openDaily() async {
    final store = _store;
    if (store == null) return;
    if (_winReveal != null || _rankClimb != null) {
      setState(() {
        _winReveal = null;
        _rankClimb = null;
      });
    }
    await store.expireStreakIfNeeded();
    if (!mounted) return;
    final reveal = await _pushTable(
      GameScreen(
        level: Levels.dailyFor(DateTime.now()),
        progress: store,
        isDaily: true,
        onProgressChanged: () {
          if (mounted) setState(() {});
        },
      ),
    );
    if (!mounted) return;
    unawaited(_quests?.ensureWeek());
    setState(() {
      _winReveal = reveal;
      _rankClimb = null;
      if (reveal != null) {
        _cycle = reveal.cycle;
        _armPanHintAfterWin();
      }
    });
    _ensurePanHintTimer();
  }

  Future<CourtyardWinReveal?> _pushTable(GameScreen screen) {
    final pushed = Navigator.of(
      context,
    ).push<CourtyardWinReveal>(GameScreen.route(screen));
    if (_firstSessionCover) {
      setState(() => _firstSessionCover = false);
    }
    return pushed;
  }

  Future<void> _continueGame() async {
    final store = _store;
    if (store == null) return;
    final snap = store.savedSnapshot;
    if (snap != null && snap.levelId == GameSnapshot.dailyLevelId) {
      await _openDaily();
      return;
    }
    if (snap != null) {
      await _openLevel(Levels.byId(snap.levelId));
      return;
    }
    await _openLevel(_continueLevel(store));
  }

  Future<void> _openLeaderboard() async {
    final store = _store;
    if (store == null) return;
    await _intro(MetaFeature.leaderboard);
    if (!mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => LeaderboardScreen(progress: store)),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openPets() async {
    final pets = _pets;
    if (pets == null || _foxSceneOpen) return;
    _foxSceneOpen = true;
    try {
      unawaited(AnalyticsService.log('pet_visit'));
      await _intro(MetaFeature.pets);
      if (!mounted) return;
      await openPetPage(context, pets: pets, adventure: _foxAdventure);
    } finally {
      _foxSceneOpen = false;
      if (mounted) setState(() {});
    }
  }

  void _onWinOverlayFinished() {
    unawaited(_continueAfterWinCelebration());
  }

  Future<void> _continueAfterWinCelebration() async {
    final reveal = _winReveal;
    if (reveal == null) return;
    RankClimb? climb;
    final pending = reveal.climb;
    if (pending != null) {
      try {
        climb = await pending.timeout(
          const Duration(seconds: 4),
          onTimeout: () => null,
        );
      } catch (_) {
        climb = null;
      }
    }
    if (!mounted || !identical(_winReveal, reveal)) return;
    if (climb != null && climb.rose) {
      setState(() => _rankClimb = climb);
      return;
    }
    _finishWinSequence();
  }

  void _onRankClimbFinished() {
    _finishWinSequence();
  }

  void _finishWinSequence() {
    if (_winReveal == null && _rankClimb == null) return;
    setState(() {
      _winReveal = null;
      _rankClimb = null;
    });
    _ensurePanHintTimer();
  }

  HubGoal? _hubGoal({
    required ProgressStore store,
    required QuestStore? quests,
  }) {
    if (_winReveal != null || _rankClimb != null) return null;
    final points = PointsScope.maybeOf(context);
    return HubGoals.pick(
      progress: store,
      quests: quests?.quests ?? const [],
      hasPet: _pets?.hasPet ?? false,
      houseState: points?.houseState ?? HouseUpgrade.firstState,
      pointsBalance: points?.balance ?? 0,
      featureUnlocks: true,
      house: false,
    );
  }

  HubEvent? _hubEvent(DateTime now) {
    if (_winReveal != null || _rankClimb != null) return null;
    final points = PointsScope.maybeOf(context);
    final gardenOpen = _isOpen(MetaFeature.garden);
    return HubFeed.latest(
      now: now,
      requests: _isOpen(MetaFeature.neighbors) ? _knownRequests : const [],
      me: _requestsMe,
      seenIds: _notices?.seenIds ?? const {},
      blockedIds: _neighborBlocks?.blockedIds ?? const {},
      garden: gardenOpen ? points?.garden : null,
      hasSeeds: (points?.seedCount ?? 0) > 0,
    );
  }

  String? _hubEventText(AppLocalizations l10n, HubEvent event) {
    return switch (event.kind) {
      HubEventKind.neighbor => neighborHubLine(
        l10n,
        event.request!,
        _requestsMe ?? '',
      ),
      HubEventKind.harvestReady => l10n.hubHarvestReady(
        l10n.seedName(event.species!),
      ),
      HubEventKind.bedFree => l10n.hubBedFree,
    };
  }

  VoidCallback _hubEventTap(HubEvent event) {
    return switch (event.kind) {
      HubEventKind.neighbor => () => unawaited(_openNeighborsPanel()),
      HubEventKind.harvestReady ||
      HubEventKind.bedFree => () => unawaited(_openBed(event.bedIndex!)),
    };
  }

  /// Грядка созревает по часам, а не по событию контроллера: будим экран сами.
  void _armRipening(DateTime now) {
    final points = PointsScope.maybeOf(context);
    final next = _isOpen(MetaFeature.garden)
        ? HubFeed.nextRipening(points?.garden, now)
        : null;
    if (next == _ripenAt) return;
    _ripenTimer?.cancel();
    _ripenTimer = null;
    _ripenAt = next;
    if (next == null) return;
    final wait = next.difference(now) + const Duration(milliseconds: 200);
    _ripenTimer = Timer(wait, () {
      _ripenAt = null;
      if (mounted) setState(() {});
    });
  }

  int get _cleared => MetaFeatures.clearedFrom(_store?.maxUnlocked ?? 1);

  bool _isOpen(MetaFeature feature) => MetaFeatures.isOpen(feature, _cleared);

  /// Фича уже открыта, но игрок её ещё не трогал.
  bool _isNew(MetaFeature feature) {
    final intros = _intros;
    return intros != null && _isOpen(feature) && !intros.isSeen(feature);
  }

  Future<void> _intro(MetaFeature feature) async {
    await showFeatureIntroOnce(context, feature, store: _intros);
    if (mounted) setState(() {});
  }

  Future<void> _openPointsShop() async {
    await _intro(MetaFeature.points);
    if (!mounted) return;
    await showPointsShop(context);
  }

  Future<void> _openSettings() async {
    await showAppSettings(context);
    if (mounted) setState(() {});
  }

  Future<void> _openHouse() async {
    if (_houseOpen || !mounted) return;
    _houseOpen = true;
    try {
      await _intro(MetaFeature.house);
      if (!mounted) return;
      await showHouseSheet(
        context,
        onBuy: _buyHouse,
        onPlayMahjong: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          unawaited(_continueGame());
        },
      );
    } finally {
      _houseOpen = false;
    }
  }

  Future<void> _openSeedStorage() async {
    await _intro(MetaFeature.seeds);
    if (!mounted) return;
    final produce = await showSeedStorage(context);
    if (produce && mounted) await _openHouse();
  }

  Future<void> _openWarehouse() async {
    if (_yardSheet || !mounted) return;
    _yardSheet = true;
    try {
      await _intro(MetaFeature.warehouse);
      if (!mounted) return;
      await showWarehouse(context, showcase: _isOpen(MetaFeature.showcase));
    } finally {
      _yardSheet = false;
    }
  }

  Future<void> _openBed(int index) async {
    if (_yardSheet || !mounted) return;
    final points = _points ?? PointsScope.read(context);
    if (points == null) return;
    _yardSheet = true;
    try {
      await _intro(MetaFeature.garden);
      if (!mounted) return;
      if (points.garden.bedAt(index) == null) {
        final result = await showSeedPicker(context, bedIndex: index);
        if (!mounted || result == null) return;
        if (result == SeedPickerResult.produce) await _openHouse();
        if (result == SeedPickerResult.play) unawaited(_continueGame());
        return;
      }
      final plant = await showGardenBed(context, bedIndex: index);
      if (plant != null && mounted) _launchFlight(plant);
    } finally {
      _yardSheet = false;
    }
  }

  void _launchFlight(HarvestedPlant plant) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final chip = _plantChipKey.currentContext?.findRenderObject();
    final overlay = context.findRenderObject();
    if (chip is! RenderBox || overlay is! RenderBox) return;
    if (!chip.hasSize || !overlay.hasSize) return;
    final to = overlay.globalToLocal(
      chip.localToGlobal(chip.size.center(Offset.zero)),
    );
    final from = Offset(overlay.size.width / 2, overlay.size.height * 0.58);
    setState(() {
      _flight = (species: plant.species, from: from, to: to);
    });
  }

  Future<void> _startSeedFromYard() async {
    final points = _points ?? PointsScope.read(context);
    if (points == null) return;
    final result = await points.startSeedBatch();
    if (result.started) {
      AnalyticsService.log('seed_produce', <String, Object>{
        'house': result.seeds.batch?.houseLevel ?? 0,
        'cost': result.cost,
      });
    }
  }

  Future<void> _claimSeedFromYard() async {
    final points = _points ?? PointsScope.read(context);
    if (points == null) return;
    final result = await points.claimSeed();
    if (result.claimed) {
      AnalyticsService.log('seed_claim', <String, Object>{
        'power': result.seed?.power ?? 0,
      });
    }
  }

  /// Пустая грядка — посадить. Если все заняты, открыть спелую или растущую.
  Future<void> _growPlant() async {
    final points = _points ?? PointsScope.read(context);
    if (points == null) return;
    final now = DateTime.now();
    int? empty;
    int? ripe;
    int? growing;
    for (var i = 0; i < GardenCatalog.bedCount; i++) {
      final bed = points.garden.bedAt(i);
      if (bed == null) {
        empty ??= i;
      } else if (bed.isReady(now)) {
        ripe ??= i;
      } else {
        growing ??= i;
      }
    }
    final index = empty ?? ripe ?? growing;
    if (index == null) return;
    await _openBed(index);
  }

  Future<void> _buyHouse() async {
    if (_buyingHouse) return;
    final points = _points ?? PointsScope.read(context);
    if (points == null) return;
    setState(() => _buyingHouse = true);
    try {
      await points.buyNextHouse();
    } finally {
      if (mounted) setState(() => _buyingHouse = false);
    }
  }

  VoidCallback? _hubGoalTap(HubGoal goal) {
    return switch (goal.kind) {
      HubGoalKind.petUnlock => _openPets,
      HubGoalKind.questClaim => () => unawaited(_claimHubQuest(goal.quest)),
      HubGoalKind.dailyReward ||
      HubGoalKind.featureUnlock ||
      HubGoalKind.questRemain ||
      HubGoalKind.plotUnlock ||
      HubGoalKind.plotLook => _continueGame,
    };
  }

  Future<void> _claimHubQuest(QuestProgress? quest) async {
    final store = _store;
    final quests = _quests;
    if (store == null || quests == null || quest == null) return;
    final claimed = await quests.claim(quest.def.id, store);
    if (!claimed || !mounted) return;
    setState(() {});
  }

  Future<void> _openNeighborsPanel() async {
    if (_acquaintances == null ||
        _notices == null ||
        _history == null ||
        _neighborBlocks == null) {
      return;
    }
    await _intro(MetaFeature.neighbors);
    if (!mounted) return;
    setState(() {
      _neighborsMounted = true;
      _neighborsOpen = true;
      _neighborsCovering = true;
    });
  }

  void _closeNeighborsPanel() {
    setState(() => _neighborsOpen = false);
  }

  void _onNeighborsObscuring(bool covering) {
    if (!mounted || _neighborsCovering == covering) return;
    setState(() => _neighborsCovering = covering);
  }

  void _refreshNeighborNotices() {
    final notices = _notices;
    if (!mounted || notices == null) return;
    final count = _neighborUnseen(notices);
    if (count == _unseenNeighbors) return;
    setState(() => _unseenNeighbors = count);
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (store == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B5C40),
        body: Stack(
          fit: StackFit.expand,
          children: [MahjongScreenBackdrop(dark: true)],
        ),
      );
    }
    if (_firstSessionCover) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B5C40),
        body: Stack(
          fit: StackFit.expand,
          children: [MahjongScreenBackdrop(dark: true)],
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    final quests = _quests;
    final points = PointsScope.maybeOf(context);
    final purchasedHome = points != null && points.houseMigrated
        ? points.houseState
        : null;
    final estate = CourtyardEstate.fromStore(
      store,
      streak: store.visibleStreak(),
      festival: (quests?.claimedCount ?? 0) > 0,
      purchasedHome: purchasedHome,
    );
    final shownHome =
        (_winReveal?.estateTo ?? estate).purchasedHome ??
        CourtyardEstate.frozenHome(
          before: estate,
          houseMigrated: false,
          purchasedState: HouseUpgrade.firstState,
        );
    final stars = store.totalStars;
    final now = DateTime.now();
    _armRipening(now);
    final hubEvent = _hubEvent(now);
    final hubEventText = hubEvent == null
        ? null
        : _hubEventText(l10n, hubEvent);
    final hubGoal = hubEventText == null
        ? _hubGoal(store: store, quests: quests)
        : null;
    final acquaintances = _acquaintances;
    final notices = _notices;
    final history = _history;
    final neighborBlocks = _neighborBlocks;
    final houseOpen = _isOpen(MetaFeature.house);
    final gardenOpen = _isOpen(MetaFeature.garden);
    final showGardenNews =
        !_showPanHint && _winReveal == null && _isNew(MetaFeature.garden);

    return PopScope(
      canPop: !_neighborsCovering,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _neighborsKey.currentState?.handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A3D2E),
        body: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              excluding: _neighborsCovering,
              child: IgnorePointer(
                ignoring: _neighborsCovering,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Semantics(
                      image: true,
                      explicitChildNodes: true,
                      label: l10n.courtyardSemanticKind(PlotKind.house),
                      child: CourtyardWorld(
                        courtyardRewards: _courtyardRewards?.owned ?? const {},
                        pets: _pets?.yardCare() ?? const [],
                        onPetTap: _openPets,
                        onSelectLot: (kind) {
                          if (kind == PlotKind.house && houseOpen) {
                            unawaited(_openHouse());
                          }
                        },
                        showGarden: gardenOpen,
                        garden: points?.garden,
                        onBedTap: (index) => unawaited(_openBed(index)),
                        onWarehouseTap: _isOpen(MetaFeature.warehouse)
                            ? () => unawaited(_openWarehouse())
                            : null,
                        from: _winReveal?.estateFrom,
                        to: _winReveal?.estateTo ?? estate,
                        animate: _winReveal != null,
                        neighbors: _neighbors,
                        onPanHint: _panHintPending ? _markPanHintLearned : null,
                      ),
                    ),
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x99081410),
                                Color(0x00000000),
                                Color(0x00000000),
                                Color(0xB3141A12),
                              ],
                              stops: [0, 0.22, 0.52, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  6,
                                  12,
                                  0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_isOpen(
                                                MetaFeature.points,
                                              )) ...[
                                                NewFeatureMark(
                                                  active: _isNew(
                                                    MetaFeature.points,
                                                  ),
                                                  child: PointsChipLive(
                                                    onTap: () => unawaited(
                                                      _openPointsShop(),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              if (_isOpen(
                                                MetaFeature.warehouse,
                                              )) ...[
                                                NewFeatureMark(
                                                  active: _isNew(
                                                    MetaFeature.warehouse,
                                                  ),
                                                  child: PlantChipLive(
                                                    key: _plantChipKey,
                                                    onTap: () => unawaited(
                                                      _openWarehouse(),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              _StarChip(stars: stars),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _HudIconButton(
                                      tooltip: l10n.settings,
                                      icon: Icons.settings_rounded,
                                      onTap: () => unawaited(_openSettings()),
                                    ),
                                    const SizedBox(width: 8),
                                    NewFeatureMark(
                                      active: _isNew(MetaFeature.leaderboard),
                                      child: _HudIconButton(
                                        tooltip: l10n.leaderboard,
                                        icon: Icons.leaderboard_rounded,
                                        onTap: _openLeaderboard,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (houseOpen)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    0,
                                  ),
                                  child: NewFeatureMark(
                                    active: _isNew(MetaFeature.house),
                                    child: HomeUpgradePreview(
                                      state: shownHome,
                                      balance: points?.balance ?? 0,
                                      busy: _buyingHouse,
                                      seedBatch: points?.seedBatch,
                                      seedBusy:
                                          (points?.seedStartBusy ?? false) ||
                                          (points?.seedClaimBusy ?? false),
                                      onBuy: points == null
                                          ? null
                                          : _isNew(MetaFeature.house)
                                          ? () => _intro(MetaFeature.house)
                                          : _buyHouse,
                                      onStartSeed: points == null
                                          ? null
                                          : _isNew(MetaFeature.seeds)
                                          ? () => _intro(MetaFeature.seeds)
                                          : _startSeedFromYard,
                                      onClaimSeed: points == null
                                          ? null
                                          : _isNew(MetaFeature.seeds)
                                          ? () => _intro(MetaFeature.seeds)
                                          : _claimSeedFromYard,
                                      onOpenSeed: points == null
                                          ? null
                                          : _isNew(MetaFeature.seeds)
                                          ? () {
                                              unawaited(
                                                _intro(MetaFeature.seeds),
                                              );
                                            }
                                          : () {
                                              unawaited(_openHouse());
                                            },
                                      onGrowPlant: points == null || !gardenOpen
                                          ? null
                                          : _isNew(MetaFeature.garden)
                                          ? () {
                                              unawaited(
                                                _intro(MetaFeature.garden),
                                              );
                                            }
                                          : () {
                                              unawaited(_growPlant());
                                            },
                                      seeds:
                                          points?.seeds.inventory ?? const [],
                                      garden: points?.garden,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Column(
                                  children: [
                                    if (_showPanHint) ...[
                                      const CourtyardPanHint(),
                                      const SizedBox(height: 10),
                                    ],
                                    if (showGardenNews) ...[
                                      TableCoachBanner(
                                        key: const ValueKey('hub-garden-news'),
                                        text: l10n.featureNewGarden,
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    if (hubEvent != null &&
                                        hubEventText != null) ...[
                                      HubGoalBanner(
                                        icon: hubEventIcon(hubEvent),
                                        text: hubEventText,
                                        onTap: _hubEventTap(hubEvent),
                                      ),
                                      const SizedBox(height: 10),
                                    ] else if (hubGoal != null) ...[
                                      HubGoalBanner(
                                        icon: hubGoalIcon(hubGoal),
                                        text: l10n.hubGoalText(hubGoal),
                                        onTap: _hubGoalTap(hubGoal),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    if (_isOpen(MetaFeature.seeds))
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: NewFeatureMark(
                                          active: _isNew(MetaFeature.seeds),
                                          child: TextButton.icon(
                                            key: const ValueKey(
                                              'seed-storage-button',
                                            ),
                                            onPressed: points == null
                                                ? null
                                                : _openSeedStorage,
                                            icon: const Icon(
                                              Icons.spa_rounded,
                                              color: _goldSoft,
                                            ),
                                            label: Text(
                                              l10n.seedsButton(
                                                points?.seedCount ?? 0,
                                              ),
                                              style: const TextStyle(
                                                color: _goldSoft,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _woodTop,
                                        foregroundColor: _goldSoft,
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          side: BorderSide(
                                            color: _gold.withValues(
                                              alpha: 0.75,
                                            ),
                                            width: 1.4,
                                          ),
                                        ),
                                      ),
                                      onPressed: _continueGame,
                                      icon: const Icon(
                                        Icons.play_arrow_rounded,
                                      ),
                                      label: Text(
                                        l10n.continueGame,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_winReveal == null &&
                              _rankClimb == null &&
                              _isOpen(MetaFeature.neighbors))
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: NewFeatureMark(
                                  active: _isNew(MetaFeature.neighbors),
                                  onLeadingEdge: true,
                                  child: NeighborsEntryButton(
                                    unseen: _unseenNeighbors,
                                    onPressed: () =>
                                        unawaited(_openNeighborsPanel()),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_flight != null)
                      Positioned.fill(
                        child: PlantFlight(
                          species: _flight!.species,
                          from: _flight!.from,
                          to: _flight!.to,
                          onDone: () {
                            if (mounted) setState(() => _flight = null);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (acquaintances != null &&
                notices != null &&
                history != null &&
                neighborBlocks != null &&
                _neighborsMounted)
              Positioned.fill(
                child: NeighborsOverlay(
                  key: _neighborsKey,
                  visible: _neighborsOpen,
                  directory: _neighborDirectory,
                  acquaintances: acquaintances,
                  notices: notices,
                  history: history,
                  blocks: neighborBlocks,
                  gateway: const UnavailableNeighborGateway(),
                  onClose: _closeNeighborsPanel,
                  onObscuring: _onNeighborsObscuring,
                  onNoticesChanged: _refreshNeighborNotices,
                  requests: _neighborRequests,
                  raidHelp: _raidHelp,
                  social: _social,
                  onRequestsChanged: _onNeighborRequests,
                ),
              ),
            if (_winReveal != null && _rankClimb == null)
              CourtyardWinOverlay(
                onFinished: _onWinOverlayFinished,
                score: _winReveal!.score,
                stars: _winReveal!.stars,
                isNewBest: _winReveal!.isNewBest,
                points: _winReveal!.pointsAward.total,
                houseUpgradeNote: _isNew(MetaFeature.house)
                    ? l10n.winPointsHint
                    : _winReveal!.houseUpgradeNote,
              ),
            if (_rankClimb != null)
              RankClimbOverlay(
                climb: _rankClimb!,
                onFinished: _onRankClimbFinished,
              ),
          ],
        ),
      ),
    );
  }
}

class _HudIconButton extends StatelessWidget {
  const _HudIconButton({required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip ?? '',
        excludeFromSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B3E24), Color(0xFF3A2012)],
                ),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.75),
                  width: 1.4,
                ),
              ),
              child: ExcludeSemantics(
                child: Icon(icon, color: const Color(0xFFE8C96A)),
              ),
            ),
          ),
        ),
      ),
    );
    return button;
  }
}

class _StarChip extends StatelessWidget {
  const _StarChip({required this.stars});

  final int stars;

  static const _gold = Color(0xFFD4AF37);
  static const _ivory = Color(0xFFF8F1DE);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$stars',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xCC6B3E24), Color(0xCC3A2012)],
          ),
          border: Border.all(color: _gold.withValues(alpha: 0.7), width: 1.3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFE8C96A),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '$stars',
                style: const TextStyle(
                  color: _ivory,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
