import 'dart:async';

import 'package:flutter/material.dart';

import '../models/garden.dart';
import '../models/plant_cross.dart';
import '../models/seed_catalog.dart';
import '../models/house_upgrade.dart';
import '../models/pet.dart';
import '../models/pet_roster.dart';
import '../models/points_award.dart';
import '../models/seed_batch.dart';
import 'points_store.dart';
import 'progress_store.dart';

/// Баланс баллов и купленный дом. Начисление и покупка пишут один кошелёк.
class PointsController extends ChangeNotifier {
  PointsController(this._store)
    : _balance = _store.balance,
      _houseState = _store.houseState,
      _seeds = _store.seeds,
      _garden = _store.garden,
      _roster = _store.roster;

  PointsStore _store;
  int _balance;
  int _houseState;
  SeedSnapshot _seeds;
  GardenSnapshot _garden;
  PetRosterSnapshot _roster;
  int _pendingEarned = 0;
  int _pendingPurchased = 0;
  int _lastGain = 0;
  int _revision = 0;
  Future<HouseBuyResult>? _purchase;
  Future<SeedStartResult>? _seedStart;
  Future<SeedClaimResult>? _seedClaim;
  Future<SeedSpeedResult>? _seedSpeed;
  Future<PlantResult>? _plant;
  Future<PlantSpeedResult>? _plantSpeed;
  int? _plantSpeedBed;
  String? _plantKey;
  Future<HarvestResult>? _harvest;
  int? _harvestBed;
  Future<HarvestResult>? _adHarvest;
  Future<CrossResult>? _cross;
  Future<FeedResult>? _feed;
  String? _feedPlantId;
  Future<AssignResult>? _assign;

  int get balance => _balance;

  bool get isPersistent => _store.isPersistent;

  bool get houseMigrated => _store.houseMigrated;

  /// 1…24. До миграции — бесплатное первое состояние.
  int get houseState => _houseState;

  SeedSnapshot get seeds => _seeds;

  SeedBatch? get seedBatch => _seeds.batch;

  int get seedCount => _seeds.inventory.length;

  GardenSnapshot get garden => _garden;

  Map<String, String> get showcaseReservations => _store.showcaseReservations;

  Future<bool> reserveShowcasePlant(String plantId, String ownerId) async {
    final saved = await _store.reserveShowcasePlant(plantId, ownerId);
    notifyListeners();
    return saved;
  }

  Future<bool> releaseShowcasePlant(String plantId, String ownerId) async {
    final saved = await _store.releaseShowcasePlant(plantId, ownerId);
    notifyListeners();
    return saved;
  }

  /// Только собранные растения. Растущие на грядках сюда не входят.
  int get plantCount => _garden.plantCount;

  PetRosterSnapshot get roster => _roster;

  bool get seedStartBusy => _seedStart != null;

  bool get seedClaimBusy => _seedClaim != null;

  bool get seedSpeedBusy => _seedSpeed != null;

  bool get plantBusy => _plant != null;

  bool get harvestBusy => _harvest != null;

  bool get feedBusy => _feed != null;

  bool get assignBusy => _assign != null;

  /// Размер последнего зачисления — чип подсвечивает именно его.
  int get lastGain => _lastGain;

  void attachStore(PointsStore store) {
    _store = store;
    final earned = _pendingEarned;
    final purchased = _pendingPurchased;
    _pendingEarned = 0;
    _pendingPurchased = 0;
    final houseChanged = store.houseMigrated && store.houseState != _houseState;
    final nextSeeds = store.seeds;
    final nextGarden = store.garden;
    final nextRoster = store.roster;
    final seedsChanged =
        nextSeeds != _seeds ||
        nextGarden != _garden ||
        nextRoster.encode() != _roster.encode();
    _seeds = nextSeeds;
    _garden = nextGarden;
    _roster = nextRoster;
    if (store.houseMigrated) _houseState = store.houseState;
    if (earned > 0 || purchased > 0) {
      unawaited(_flush(store, earned: earned, purchased: purchased));
      notifyListeners();
      return;
    }
    if (store.balance == _balance && !houseChanged && !seedsChanged) return;
    _balance = store.balance;
    notifyListeners();
  }

  Future<void> _flush(
    PointsStore store, {
    required int earned,
    required int purchased,
  }) async {
    if (earned > 0) await store.add(earned);
    if (purchased > 0) await store.add(purchased, purchased: true);
    if (!identical(_store, store)) return;
    _balance = store.balance;
    _seeds = store.seeds;
    _garden = store.garden;
    _roster = store.roster;
    if (store.houseMigrated) _houseState = store.houseState;
    notifyListeners();
  }

  /// Повторный вызов ничего не меняет: миграция уже записана.
  Future<void> migrateHouse(ProgressStore progress) async {
    if (!_store.isPersistent || _store.houseMigrated) {
      if (_store.houseMigrated && _houseState != _store.houseState) {
        _houseState = _store.houseState;
        notifyListeners();
      }
      return;
    }
    final ticket = ++_revision;
    await _store.migrateFromCampaign(progress);
    if (ticket != _revision) {
      _houseState = _store.houseState;
      notifyListeners();
      return;
    }
    _houseState = _store.houseState;
    _balance = _store.balance;
    _seeds = _store.seeds;
    _garden = _store.garden;
    notifyListeners();
  }

  /// Экран вернулся на передний план: оставшееся время считается заново.
  void noteClock() {
    notifyListeners();
  }

  /// Повторное нажатие, пока запуск идёт, возвращает тот же результат.
  Future<SeedStartResult> startSeedBatch({
    DateTime? now,
    int? speciesIndex,
    int Function(int count)? roll,
  }) {
    final pending = _seedStart;
    if (pending != null) return pending;
    final run = _startSeedBatch(
      now: now,
      speciesIndex: speciesIndex,
      roll: roll,
    );
    _seedStart = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_seedStart, run)) _seedStart = null;
      }),
    );
    return run;
  }

  Future<SeedStartResult> _startSeedBatch({
    DateTime? now,
    int? speciesIndex,
    int Function(int count)? roll,
  }) async {
    if (!_store.isPersistent) {
      return SeedStartResult.unavailable(balance: _balance, seeds: _seeds);
    }
    final ticket = ++_revision;
    final result = await _store.startSeedBatch(
      now: now,
      speciesIndex: speciesIndex,
      roll: roll,
    );
    _publishSeeds(ticket, balance: result.balance, seeds: result.seeds);
    return result;
  }

  /// Повтор того же нажатия возвращает ту же операцию и не сажает семя дважды.
  Future<PlantResult> plantSeed({
    required int bedIndex,
    required String seedId,
    DateTime? now,
  }) {
    final key = '$bedIndex|$seedId';
    final pending = _plant;
    if (pending != null && _plantKey == key) return pending;
    final run = _plantSeed(bedIndex: bedIndex, seedId: seedId, now: now);
    _plant = run;
    _plantKey = key;
    unawaited(
      run.whenComplete(() {
        if (identical(_plant, run)) {
          _plant = null;
          _plantKey = null;
        }
      }),
    );
    return run;
  }

  Future<PlantResult> _plantSeed({
    required int bedIndex,
    required String seedId,
    DateTime? now,
  }) async {
    if (!_store.isPersistent) {
      return PlantResult.unavailable(
        balance: _balance,
        seeds: _seeds,
        garden: _garden,
      );
    }
    final ticket = ++_revision;
    final result = await _store.plantSeed(
      bedIndex: bedIndex,
      seedId: seedId,
      now: now,
    );
    _publishSeeds(
      ticket,
      balance: result.balance,
      seeds: result.seeds,
      garden: result.garden,
    );
    return result;
  }

  /// Предложение «собрать растущее растение за ролик» ещё не потрачено сегодня.
  bool plantAdOfferAvailable({DateTime? now}) =>
      _store.plantAdOfferAvailable(now: now);

  /// Дозревает грядку и собирает растение без списания поинтов.
  Future<HarvestResult> collectPlantForAd({
    required int bedIndex,
    DateTime? now,
  }) {
    final pending = _adHarvest;
    if (pending != null) return pending;
    final run = _runAdHarvest(bedIndex: bedIndex, now: now);
    _adHarvest = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_adHarvest, run)) _adHarvest = null;
      }),
    );
    return run;
  }

  Future<HarvestResult> _runAdHarvest({
    required int bedIndex,
    DateTime? now,
  }) async {
    if (!_store.isPersistent) {
      return HarvestResult.unavailable(
        balance: _balance,
        seeds: _seeds,
        garden: _garden,
      );
    }
    final ticket = ++_revision;
    final result = await _store.collectPlantForAd(bedIndex: bedIndex, now: now);
    _publishSeeds(
      ticket,
      balance: result.balance,
      seeds: result.seeds,
      garden: result.garden,
    );
    return result;
  }

  /// Повторный сбор той же грядки не выдаёт второе растение.
  Future<HarvestResult> harvestBed({required int bedIndex, DateTime? now}) {
    final pending = _harvest;
    if (pending != null && _harvestBed == bedIndex) return pending;
    final run = _runHarvest(bedIndex: bedIndex, now: now);
    _harvest = run;
    _harvestBed = bedIndex;
    unawaited(
      run.whenComplete(() {
        if (identical(_harvest, run)) {
          _harvest = null;
          _harvestBed = null;
        }
      }),
    );
    return run;
  }

  Future<HarvestResult> _runHarvest({
    required int bedIndex,
    DateTime? now,
  }) async {
    if (!_store.isPersistent) {
      return HarvestResult.unavailable(
        balance: _balance,
        seeds: _seeds,
        garden: _garden,
      );
    }
    final ticket = ++_revision;
    final result = await _store.harvestBed(bedIndex: bedIndex, now: now);
    _publishSeeds(
      ticket,
      balance: result.balance,
      seeds: result.seeds,
      garden: result.garden,
    );
    return result;
  }

  /// Повторное получение не создаёт второе семя.
  Future<SeedClaimResult> claimSeed({DateTime? now}) {
    final pending = _seedClaim;
    if (pending != null) return pending;
    final run = _claimSeed(now: now);
    _seedClaim = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_seedClaim, run)) _seedClaim = null;
      }),
    );
    return run;
  }

  Future<SeedClaimResult> _claimSeed({DateTime? now}) async {
    if (!_store.isPersistent) {
      return SeedClaimResult.unavailable(balance: _balance, seeds: _seeds);
    }
    final ticket = ++_revision;
    final result = await _store.claimSeed(now: now);
    _publishSeeds(ticket, balance: result.balance, seeds: result.seeds);
    return result;
  }

  /// Повторное нажатие, пока списание идёт, не платит второй раз.
  Future<SeedSpeedResult> speedUpSeed({DateTime? now}) {
    final pending = _seedSpeed;
    if (pending != null) return pending;
    final run = _speedUpSeed(now: now);
    _seedSpeed = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_seedSpeed, run)) _seedSpeed = null;
      }),
    );
    return run;
  }

  Future<SeedSpeedResult> _speedUpSeed({DateTime? now}) async {
    if (!_store.isPersistent) {
      return SeedSpeedResult.unavailable(balance: _balance, seeds: _seeds);
    }
    final ticket = ++_revision;
    final result = await _store.speedUpSeed(now: now);
    _publishSeeds(ticket, balance: result.balance, seeds: result.seeds);
    return result;
  }

  /// Повтор той же грядки не списывает поинты дважды.
  Future<PlantSpeedResult> speedUpPlant({
    required int bedIndex,
    DateTime? now,
  }) {
    final pending = _plantSpeed;
    if (pending != null && _plantSpeedBed == bedIndex) return pending;
    final run = _runPlantSpeed(bedIndex: bedIndex, now: now);
    _plantSpeed = run;
    _plantSpeedBed = bedIndex;
    unawaited(
      run.whenComplete(() {
        if (identical(_plantSpeed, run)) {
          _plantSpeed = null;
          _plantSpeedBed = null;
        }
      }),
    );
    return run;
  }

  Future<PlantSpeedResult> _runPlantSpeed({
    required int bedIndex,
    DateTime? now,
  }) async {
    if (!_store.isPersistent) {
      return PlantSpeedResult.unavailable(
        balance: _balance,
        seeds: _seeds,
        garden: _garden,
      );
    }
    final ticket = ++_revision;
    final result = await _store.speedUpPlant(bedIndex: bedIndex, now: now);
    _publishSeeds(
      ticket,
      balance: result.balance,
      seeds: result.seeds,
      garden: result.garden,
    );
    return result;
  }

  void _publishSeeds(
    int ticket, {
    required int balance,
    required SeedSnapshot seeds,
    GardenSnapshot? garden,
    PetRosterSnapshot? roster,
  }) {
    if (ticket != _revision) {
      _balance = _store.balance;
      _seeds = _store.seeds;
      _garden = _store.garden;
      _roster = _store.roster;
      notifyListeners();
      return;
    }
    _balance = balance;
    _seeds = seeds;
    if (garden != null) _garden = garden;
    if (roster != null) _roster = roster;
    notifyListeners();
  }

  bool get crossBusy => _cross != null;

  /// Повтор того же скрещивания возвращает прежний жребий и не списывает растения снова.
  Future<CrossResult> beginCross({
    required String firstId,
    required String secondId,
    required CrossAim aim,
    required String opId,
    int Function(int count)? roll,
    DateTime? now,
  }) {
    final pending = _cross;
    if (pending != null) return pending;
    final run = _runCross(
      () => _store.beginCross(
        firstId: firstId,
        secondId: secondId,
        aim: aim,
        opId: opId,
        roll: roll,
        now: now,
      ),
    );
    _cross = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_cross, run)) _cross = null;
      }),
    );
    return run;
  }

  Future<CrossResult> finishCross({
    required String opId,
    PlantTrait? trait,
    SeedSpecies? species,
    DateTime? now,
  }) {
    final pending = _cross;
    if (pending != null) return pending;
    final run = _runCross(
      () => _store.finishCross(
        opId: opId,
        trait: trait,
        species: species,
        now: now,
      ),
    );
    _cross = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_cross, run)) _cross = null;
      }),
    );
    return run;
  }

  /// Семя от скрещивания с соседом. Повтор с тем же [opId] безопасен.
  Future<CrossResult> claimNeighborCross({
    required String opId,
    required SeedSpecies give,
    required SeedSpecies receive,
    String? preferPlantId,
    CrossLineage? lineage,
  }) {
    final pending = _cross;
    if (pending != null) return pending;
    final run = _runCross(
      () => _store.claimNeighborCross(
        opId: opId,
        give: give,
        receive: receive,
        preferPlantId: preferPlantId,
        lineage: lineage,
      ),
    );
    _cross = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_cross, run)) _cross = null;
      }),
    );
    return run;
  }

  List<HarvestedPlant> get raidablePlants => _store.raidablePlants;

  /// Списывает потерю набега. Повтор с тем же [opId] безопасен.
  Future<RaidSettleResult> settleRaidLoss({
    required String opId,
    String? destroyId,
    SeedSpecies? destroySpecies,
    String? stealId,
    SeedSpecies? stealSpecies,
  }) => _runRaid(
    () => _store.settleRaidLoss(
      opId: opId,
      destroyId: destroyId,
      destroySpecies: destroySpecies,
      stealId: stealId,
      stealSpecies: stealSpecies,
    ),
  );

  /// Добыча набега на склад. Повтор с тем же [opId] безопасен.
  Future<RaidSettleResult> takeRaidLoot({
    required String opId,
    required SeedSpecies species,
    PlantTrait? trait,
  }) => _runRaid(
    () => _store.takeRaidLoot(opId: opId, species: species, trait: trait),
  );

  Future<RaidSettleResult> _runRaid(
    Future<RaidSettleResult> Function() body,
  ) async {
    if (!_store.isPersistent) {
      return RaidSettleResult(
        status: RaidSettleStatus.unavailable,
        balance: _balance,
        seeds: _seeds,
        garden: _garden,
      );
    }
    final ticket = ++_revision;
    final result = await body();
    _publishSeeds(
      ticket,
      balance: result.balance,
      seeds: result.seeds,
      garden: result.garden,
    );
    return result;
  }

  Future<CrossResult> _runCross(Future<CrossResult> Function() body) async {
    if (!_store.isPersistent) {
      return CrossResult.unavailable(
        balance: _balance,
        seeds: _seeds,
        garden: _garden,
      );
    }
    final ticket = ++_revision;
    final result = await body();
    _publishSeeds(
      ticket,
      balance: result.balance,
      seeds: result.seeds,
      garden: result.garden,
    );
    return result;
  }

  /// Повторный вызов не затирает уже накопленный опыт.
  Future<void> syncOwnedPets() async {
    if (!_store.isPersistent) return;
    final ticket = ++_revision;
    await _store.syncOwnedPets();
    if (ticket != _revision) {
      _roster = _store.roster;
      notifyListeners();
      return;
    }
    _roster = _store.roster;
    notifyListeners();
  }

  /// Повтор того же растения, пока первое кормление не закончилось, не списывает второе.
  Future<FeedResult> feedPet({
    required PetKind kind,
    required String plantId,
    DateTime? now,
  }) {
    final pending = _feed;
    if (pending != null && _feedPlantId == plantId) return pending;
    final run = _runFeed(kind: kind, plantId: plantId, now: now);
    _feed = run;
    _feedPlantId = plantId;
    unawaited(
      run.whenComplete(() {
        if (identical(_feed, run)) {
          _feed = null;
          _feedPlantId = null;
        }
      }),
    );
    return run;
  }

  Future<FeedResult> _runFeed({
    required PetKind kind,
    required String plantId,
    DateTime? now,
  }) async {
    if (!_store.isPersistent) {
      return FeedResult.unavailable(
        balance: _balance,
        seeds: _seeds,
        garden: _garden,
        roster: _roster,
      );
    }
    final ticket = ++_revision;
    final result = await _store.feedPet(kind: kind, plantId: plantId, now: now);
    _publishSeeds(
      ticket,
      balance: result.balance,
      seeds: result.seeds,
      garden: result.garden,
      roster: result.roster,
    );
    return result;
  }

  Future<AssignResult> assignPet({
    required PetKind kind,
    required bool active,
  }) {
    final pending = _assign;
    if (pending != null) return pending;
    final run = _runAssign(kind: kind, active: active);
    _assign = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_assign, run)) _assign = null;
      }),
    );
    return run;
  }

  Future<AssignResult> _runAssign({
    required PetKind kind,
    required bool active,
  }) async {
    if (!_store.isPersistent) {
      return AssignResult.unavailable(
        balance: _balance,
        seeds: _seeds,
        garden: _garden,
        roster: _roster,
      );
    }
    final ticket = ++_revision;
    final result = await _store.assignPet(kind: kind, active: active);
    _publishSeeds(
      ticket,
      balance: result.balance,
      seeds: result.seeds,
      garden: result.garden,
      roster: result.roster,
    );
    return result;
  }

  /// Второе нажатие, пока первое ещё идёт, возвращает тот же результат.
  Future<HouseBuyResult> buyNextHouse() {
    final pending = _purchase;
    if (pending != null) return pending;
    final run = _buyNextHouse();
    _purchase = run;
    return run.whenComplete(() {
      if (identical(_purchase, run)) _purchase = null;
    });
  }

  Future<HouseBuyResult> _buyNextHouse() async {
    if (!_store.isPersistent) {
      return HouseBuyResult.unavailable(
        balance: _balance,
        houseState: _houseState,
      );
    }
    final ticket = ++_revision;
    final result = await _store.buyNextHouse();
    if (result.purchased) _houseState = result.houseState;
    if (ticket == _revision) {
      _balance = result.balance;
      _seeds = _store.seeds;
      _garden = _store.garden;
      _roster = _store.roster;
      notifyListeners();
    } else if (result.purchased) {
      _seeds = _store.seeds;
      _garden = _store.garden;
      _roster = _store.roster;
      notifyListeners();
    }
    return result;
  }

  Future<PointsSpendResult> spend(int amount) async {
    if (!_store.isPersistent) {
      return PointsSpendResult(
        status: PointsSpendStatus.unavailable,
        balance: _balance,
      );
    }
    ++_revision;
    final result = await _store.spend(amount);
    _balance = _store.balance;
    notifyListeners();
    return result;
  }

  Future<void> refund(int amount) async {
    if (!_store.isPersistent || amount <= 0) return;
    ++_revision;
    await _store.refund(amount);
    _balance = _store.balance;
    notifyListeners();
  }

  Future<void> award(PointsAward award) => earn(award.total);

  Future<void> earn(int amount) => _credit(amount, purchased: false);

  Future<void> creditPurchase(int amount) => _credit(amount, purchased: true);

  Future<void> _credit(int amount, {required bool purchased}) async {
    if (amount <= 0) return;
    _lastGain = amount;
    if (!_store.isPersistent) {
      _balance = (_balance + amount).clamp(0, PointsStore.maxBalance);
      if (purchased) {
        _pendingPurchased += amount;
      } else {
        _pendingEarned += amount;
      }
      notifyListeners();
      return;
    }
    final ticket = ++_revision;
    final next = await _store.add(amount, purchased: purchased);
    if (ticket != _revision) return;
    _balance = next;
    _seeds = _store.seeds;
    _garden = _store.garden;
    _roster = _store.roster;
    notifyListeners();
  }
}

class PointsScope extends InheritedNotifier<PointsController> {
  const PointsScope({
    super.key,
    required PointsController controller,
    required super.child,
  }) : super(notifier: controller);

  PointsController get controller => notifier!;

  static PointsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PointsScope>();
    assert(scope != null, 'PointsScope not found');
    return scope!.controller;
  }

  static PointsController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PointsScope>()
        ?.controller;
  }

  /// Для обработчиков вне build: берёт кошелёк, но не подписывает на него.
  static PointsController? read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<PointsScope>()?.controller;
  }

  /// Зачисление за победу. Запись стоит в той же очереди, что и покупка дома.
  static void credit(BuildContext context, PointsAward award) {
    if (award.isEmpty) return;
    final controller = read(context);
    if (controller == null) return;
    unawaited(controller.award(award));
  }
}
