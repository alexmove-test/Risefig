import 'dart:convert';

import 'plant_cross.dart';
import 'seed_batch.dart';
import 'seed_catalog.dart';

/// Цена и срок посадки. Оба следуют классу: дольше растёт — дороже стоит.
abstract final class GardenCatalog {
  static const rulesVersion = 3;
  static const bedCount = 3;

  static Duration durationFor(SeedSpecies species, {PlantTrait? trait}) {
    final base = switch (species.seedClass) {
      SeedClass.common => const Duration(minutes: 5),
      SeedClass.nutrient => const Duration(minutes: 20),
      SeedClass.rare => const Duration(minutes: 60),
    };
    if (trait != PlantTrait.bloom) return base;
    final shortened = Duration(milliseconds: base.inMilliseconds * 7 ~/ 10);
    if (shortened < const Duration(seconds: 30)) {
      return const Duration(seconds: 30);
    }
    return shortened;
  }

  static int costFor(SeedSpecies species) =>
      SeedCatalog.pointsFor(durationFor(species));

  static int foodFor(SeedSpecies species) => SeedCatalog.foodFor(species);
}

/// Доля времени от посадки до готовности. Часы назад не дают отрицательный рост.
enum GrowthStage { sown, sprout, growing, ripe }

GrowthStage stageOf(Planting planting, DateTime now) {
  if (planting.isReady(now)) return GrowthStage.ripe;
  final done = planting.progress(now);
  if (done < 0.20) return GrowthStage.sown;
  if (done < 0.50) return GrowthStage.sprout;
  return GrowthStage.growing;
}

/// Посадка на одной грядке. Сила и вид скопированы с семени и больше не меняются.
class Planting {
  const Planting({
    required this.id,
    required this.seedId,
    required this.species,
    required this.power,
    required this.houseLevel,
    required this.source,
    required this.batchId,
    required this.plantedAt,
    required this.readyAt,
    required this.cost,
    required this.rulesVersion,
    this.variant,
    this.trait,
    this.lineage,
  });

  final String id;
  final String seedId;
  final SeedSpecies species;
  final int power;
  final int houseLevel;
  final String? variant;
  final PlantTrait? trait;
  final CrossLineage? lineage;
  final String source;
  final String batchId;
  final DateTime plantedAt;
  final DateTime readyAt;
  final int cost;
  final int rulesVersion;

  bool isReady(DateTime now) => !now.toUtc().isBefore(readyAt);

  Duration remaining(DateTime now) {
    final left = readyAt.difference(now.toUtc());
    if (left.isNegative) return Duration.zero;
    return left;
  }

  double progress(DateTime now) {
    final total = readyAt.difference(plantedAt).inMilliseconds;
    if (total <= 0) return 1;
    final done = now.toUtc().difference(plantedAt).inMilliseconds;
    if (done <= 0) return 0;
    final value = done / total;
    if (value <= 0) return 0;
    if (value >= 1) return 1;
    return value;
  }

  Planting copyWith({DateTime? readyAt}) {
    return Planting(
      id: id,
      seedId: seedId,
      species: species,
      power: power,
      houseLevel: houseLevel,
      variant: variant,
      trait: trait,
      lineage: lineage,
      source: source,
      batchId: batchId,
      plantedAt: plantedAt,
      readyAt: readyAt ?? this.readyAt,
      cost: cost,
      rulesVersion: rulesVersion,
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'seedId': seedId,
    'species': species.name,
    'power': power,
    'houseLevel': houseLevel,
    'source': source,
    'batchId': batchId,
    'plantedAt': plantedAt.millisecondsSinceEpoch,
    'readyAt': readyAt.millisecondsSinceEpoch,
    'cost': cost,
    'rules': rulesVersion,
    'variant': ?variant,
    'trait': ?trait?.name,
    'lineage': ?lineage?.toJson(),
  };

  static Planting? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final seedId = raw['seedId'];
    final speciesName = raw['species'];
    final power = raw['power'];
    final house = raw['houseLevel'];
    final source = raw['source'];
    final batchId = raw['batchId'];
    final planted = raw['plantedAt'];
    final ready = raw['readyAt'];
    final cost = raw['cost'];
    final rules = raw['rules'];
    final variantRaw = raw['variant'];
    final traitRaw = raw['trait'];
    if (id is! String ||
        id.isEmpty ||
        seedId is! String ||
        seedId.isEmpty ||
        speciesName is! String ||
        power is! int ||
        house is! int ||
        source is! String ||
        source.isEmpty ||
        batchId is! String ||
        batchId.isEmpty ||
        planted is! int ||
        ready is! int ||
        cost is! int ||
        rules is! int ||
        ready < planted) {
      return null;
    }
    if (variantRaw != null && variantRaw is! String) return null;
    if (traitRaw != null && plantTraitNamed(traitRaw) == null) return null;
    final species = _species(speciesName);
    if (species == null) return null;
    final variant = variantRaw is String && variantRaw.isNotEmpty
        ? variantRaw
        : null;
    return Planting(
      id: id,
      seedId: seedId,
      species: species,
      power: SeedCatalog.foodFor(species),
      houseLevel: house,
      source: source,
      batchId: batchId,
      plantedAt: DateTime.fromMillisecondsSinceEpoch(planted, isUtc: true),
      readyAt: DateTime.fromMillisecondsSinceEpoch(ready, isUtc: true),
      cost: cost,
      rulesVersion: rules,
      variant: variant,
      trait: plantTraitNamed(traitRaw),
      lineage: CrossLineage.fromJson(raw['lineage']),
    );
  }
}

/// Собранное растение. Один экземпляр — один идентификатор.
class HarvestedPlant {
  const HarvestedPlant({
    required this.id,
    required this.species,
    required this.power,
    required this.houseLevel,
    required this.seedId,
    required this.source,
    required this.batchId,
    required this.plantingId,
    required this.plantedAt,
    required this.maturedAt,
    required this.harvestedAt,
    this.variant,
    this.trait,
    this.lineage,
  });

  final String id;
  final SeedSpecies species;
  final int power;
  final int houseLevel;
  final String? variant;
  final PlantTrait? trait;
  final CrossLineage? lineage;
  final String seedId;
  final String source;
  final String batchId;
  final String plantingId;
  final DateTime plantedAt;
  final DateTime maturedAt;
  final DateTime harvestedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'species': species.name,
    'power': power,
    'houseLevel': houseLevel,
    'seedId': seedId,
    'source': source,
    'batchId': batchId,
    'plantingId': plantingId,
    'plantedAt': plantedAt.millisecondsSinceEpoch,
    'maturedAt': maturedAt.millisecondsSinceEpoch,
    'harvestedAt': harvestedAt.millisecondsSinceEpoch,
    'variant': ?variant,
    'trait': ?trait?.name,
    'lineage': ?lineage?.toJson(),
  };

  static HarvestedPlant? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final speciesName = raw['species'];
    final power = raw['power'];
    final house = raw['houseLevel'];
    final seedId = raw['seedId'];
    final source = raw['source'];
    final batchId = raw['batchId'];
    final plantingId = raw['plantingId'];
    final planted = raw['plantedAt'];
    final matured = raw['maturedAt'];
    final harvested = raw['harvestedAt'];
    final variantRaw = raw['variant'];
    final traitRaw = raw['trait'];
    if (id is! String ||
        id.isEmpty ||
        speciesName is! String ||
        power is! int ||
        house is! int ||
        seedId is! String ||
        seedId.isEmpty ||
        source is! String ||
        source.isEmpty ||
        batchId is! String ||
        batchId.isEmpty ||
        plantingId is! String ||
        plantingId.isEmpty ||
        planted is! int ||
        matured is! int ||
        harvested is! int ||
        matured < planted) {
      return null;
    }
    if (variantRaw != null && variantRaw is! String) return null;
    if (traitRaw != null && plantTraitNamed(traitRaw) == null) return null;
    final species = _species(speciesName);
    if (species == null) return null;
    final variant = variantRaw is String && variantRaw.isNotEmpty
        ? variantRaw
        : null;
    return HarvestedPlant(
      id: id,
      species: species,
      power: SeedCatalog.foodFor(species),
      houseLevel: house,
      seedId: seedId,
      source: source,
      batchId: batchId,
      plantingId: plantingId,
      plantedAt: DateTime.fromMillisecondsSinceEpoch(planted, isUtc: true),
      maturedAt: DateTime.fromMillisecondsSinceEpoch(matured, isUtc: true),
      harvestedAt: DateTime.fromMillisecondsSinceEpoch(harvested, isUtc: true),
      variant: variant,
      trait: plantTraitNamed(traitRaw),
      lineage: CrossLineage.fromJson(raw['lineage']),
    );
  }
}

/// Три грядки и склад. Пустой снимок — миграция игрока без посадок.
class GardenSnapshot {
  const GardenSnapshot({
    required this.beds,
    required this.warehouse,
    required this.seq,
    this.pending,
    this.lastCrossId,
    this.claimedNeighborCrosses = const {},
    this.settledRaids = const {},
  });

  static final empty = GardenSnapshot(
    beds: List<Planting?>.unmodifiable(
      List<Planting?>.filled(GardenCatalog.bedCount, null),
    ),
    warehouse: const [],
    seq: 0,
  );

  final List<Planting?> beds;
  final List<HarvestedPlant> warehouse;
  final int seq;
  final CrossPending? pending;
  final String? lastCrossId;

  /// Receipts survive planting, harvesting and feeding the awarded seed.
  final Set<String> claimedNeighborCrosses;

  /// Набеги, чья потеря или добыча уже применена к складу.
  final Set<String> settledRaids;

  int get plantCount => warehouse.length;

  Planting? bedAt(int index) {
    if (index < 0 || index >= beds.length) return null;
    return beds[index];
  }

  bool occupiesSeed(String seedId) {
    for (final bed in beds) {
      if (bed != null && bed.seedId == seedId) return true;
    }
    return false;
  }

  GardenSnapshot copyWith({
    List<Planting?>? beds,
    List<HarvestedPlant>? warehouse,
    int? seq,
    CrossPending? pending,
    bool clearPending = false,
    String? lastCrossId,
    Set<String>? claimedNeighborCrosses,
    Set<String>? settledRaids,
  }) {
    return GardenSnapshot(
      beds: beds ?? this.beds,
      warehouse: warehouse ?? this.warehouse,
      seq: seq ?? this.seq,
      pending: clearPending ? null : pending ?? this.pending,
      lastCrossId: lastCrossId ?? this.lastCrossId,
      claimedNeighborCrosses:
          claimedNeighborCrosses ?? this.claimedNeighborCrosses,
      settledRaids: settledRaids ?? this.settledRaids,
    );
  }

  Map<String, Object> toJson() => {
    'seq': seq,
    'beds': [for (final bed in beds) bed?.toJson()],
    'warehouse': [for (final plant in warehouse) plant.toJson()],
    'pending': ?pending?.toJson(),
    'lastCrossId': ?lastCrossId,
    'claimedNeighborCrosses': claimedNeighborCrosses.toList(),
    'settledRaids': settledRaids.toList(),
  };

  String encode() => jsonEncode(toJson());

  static GardenSnapshot? decode(String raw) {
    try {
      return fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static GardenSnapshot? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final seq = raw['seq'];
    if (seq is! int || seq < 0) return null;
    final bedsRaw = raw['beds'];
    final warehouseRaw = raw['warehouse'];
    if (bedsRaw is! List || bedsRaw.length != GardenCatalog.bedCount) {
      return null;
    }
    if (warehouseRaw is! List) return null;
    final pendingRaw = raw['pending'];
    CrossPending? pending;
    if (pendingRaw != null) {
      pending = CrossPending.fromJson(pendingRaw);
      if (pending == null) return null;
    }
    final lastRaw = raw['lastCrossId'];
    if (lastRaw != null && lastRaw is! String) return null;
    final lastCrossId = lastRaw is String && lastRaw.isNotEmpty
        ? lastRaw
        : null;
    final beds = <Planting?>[];
    for (final item in bedsRaw) {
      if (item == null) {
        beds.add(null);
        continue;
      }
      final planting = Planting.fromJson(item);
      if (planting == null) return null;
      beds.add(planting);
    }
    final warehouse = <HarvestedPlant>[];
    for (final item in warehouseRaw) {
      final plant = HarvestedPlant.fromJson(item);
      if (plant == null) return null;
      warehouse.add(plant);
    }
    return GardenSnapshot(
      beds: beds,
      warehouse: warehouse,
      seq: seq,
      pending: pending,
      lastCrossId: lastCrossId,
      claimedNeighborCrosses: (raw['claimedNeighborCrosses'] is List)
          ? (raw['claimedNeighborCrosses'] as List).whereType<String>().toSet()
          : const {},
      settledRaids: (raw['settledRaids'] is List)
          ? (raw['settledRaids'] as List).whereType<String>().toSet()
          : const {},
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GardenSnapshot &&
        other.seq == seq &&
        other.warehouse.length == warehouse.length &&
        other.pending?.id == pending?.id &&
        other.lastCrossId == lastCrossId &&
        _sameBeds(other.beds, beds) &&
        _sameWarehouse(other.warehouse, warehouse);
  }

  @override
  int get hashCode => Object.hash(seq, beds.length, warehouse.length);

  static bool _sameBeds(List<Planting?> a, List<Planting?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i]?.id != b[i]?.id ||
          a[i]?.power != b[i]?.power ||
          a[i]?.readyAt != b[i]?.readyAt) {
        return false;
      }
    }
    return true;
  }

  static bool _sameWarehouse(List<HarvestedPlant> a, List<HarvestedPlant> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}

enum PlantSort { power, received }

/// Группа склада: один вид, одна сила и один внешний вариант.
class PlantStack {
  const PlantStack({required this.instances});

  final List<HarvestedPlant> instances;

  HarvestedPlant get newest => instances.last;

  SeedSpecies get species => newest.species;

  int get power => newest.power;

  String? get variant => newest.variant;

  PlantTrait? get trait => newest.trait;

  int get count => instances.length;

  DateTime get receivedAt => newest.harvestedAt;
}

List<PlantStack> stackPlants(
  List<HarvestedPlant> plants, {
  PlantSort sort = PlantSort.received,
}) {
  final groups = <String, List<HarvestedPlant>>{};
  for (final plant in plants) {
    final key =
        '${plant.species.name}#${plant.power}#${plant.variant ?? ''}#${plant.trait?.name ?? ''}';
    groups.putIfAbsent(key, () => []).add(plant);
  }
  final stacks = [
    for (final group in groups.values)
      PlantStack(instances: [...group]..sort(_byHarvested)),
  ];
  switch (sort) {
    case PlantSort.power:
      stacks.sort((a, b) {
        final byPower = b.power.compareTo(a.power);
        if (byPower != 0) return byPower;
        return b.receivedAt.compareTo(a.receivedAt);
      });
    case PlantSort.received:
      stacks.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }
  return stacks;
}

int _byHarvested(HarvestedPlant a, HarvestedPlant b) =>
    a.harvestedAt.compareTo(b.harvestedAt);

enum PlantStatus {
  planted,
  occupied,
  missingSeed,
  insufficient,
  unavailable,
  failed,
}

class PlantResult {
  const PlantResult({
    required this.status,
    required this.balance,
    required this.seeds,
    required this.garden,
    this.cost = 0,
    this.shortfall = 0,
    this.planting,
  });

  final PlantStatus status;
  final int balance;
  final SeedSnapshot seeds;
  final GardenSnapshot garden;
  final int cost;
  final int shortfall;
  final Planting? planting;

  bool get planted => status == PlantStatus.planted;

  const PlantResult.unavailable({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
  }) : this(
         status: PlantStatus.unavailable,
         balance: balance,
         seeds: seeds,
         garden: garden,
       );

  const PlantResult.failed({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
  }) : this(
         status: PlantStatus.failed,
         balance: balance,
         seeds: seeds,
         garden: garden,
       );
}

enum HarvestStatus { harvested, notReady, empty, unavailable, failed, adUsed }

class HarvestResult {
  const HarvestResult({
    required this.status,
    required this.balance,
    required this.seeds,
    required this.garden,
    this.plant,
  });

  final HarvestStatus status;
  final int balance;
  final SeedSnapshot seeds;
  final GardenSnapshot garden;
  final HarvestedPlant? plant;

  bool get harvested => status == HarvestStatus.harvested;

  const HarvestResult.unavailable({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
  }) : this(
         status: HarvestStatus.unavailable,
         balance: balance,
         seeds: seeds,
         garden: garden,
       );

  const HarvestResult.failed({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
  }) : this(
         status: HarvestStatus.failed,
         balance: balance,
         seeds: seeds,
         garden: garden,
       );
}

enum PlantSpeedStatus {
  finished,
  insufficient,
  empty,
  ready,
  unavailable,
  failed,
}

class PlantSpeedResult {
  const PlantSpeedResult({
    required this.status,
    required this.balance,
    required this.seeds,
    required this.garden,
    this.cost = 0,
    this.shortfall = 0,
  });

  final PlantSpeedStatus status;
  final int balance;
  final SeedSnapshot seeds;
  final GardenSnapshot garden;
  final int cost;
  final int shortfall;

  bool get finished => status == PlantSpeedStatus.finished;

  const PlantSpeedResult.unavailable({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
  }) : this(
         status: PlantSpeedStatus.unavailable,
         balance: balance,
         seeds: seeds,
         garden: garden,
       );

  const PlantSpeedResult.failed({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
  }) : this(
         status: PlantSpeedStatus.failed,
         balance: balance,
         seeds: seeds,
         garden: garden,
       );
}

class CrossResult {
  const CrossResult({
    required this.status,
    required this.balance,
    required this.seeds,
    required this.garden,
    this.seed,
    this.band,
  });

  final CrossStatus status;
  final int balance;
  final SeedSnapshot seeds;
  final GardenSnapshot garden;
  final SeedInstance? seed;
  final CrossBand? band;

  bool get granted => status == CrossStatus.granted;

  const CrossResult.unavailable({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
  }) : this(
         status: CrossStatus.unavailable,
         balance: balance,
         seeds: seeds,
         garden: garden,
       );

  const CrossResult.failed({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
  }) : this(
         status: CrossStatus.failed,
         balance: balance,
         seeds: seeds,
         garden: garden,
       );
}

enum RaidSettleStatus { settled, unavailable, failed }

/// Итог списания потери или выдачи добычи набега.
class RaidSettleResult {
  const RaidSettleResult({
    required this.status,
    required this.balance,
    required this.seeds,
    required this.garden,
    this.plant,
  });

  final RaidSettleStatus status;
  final int balance;
  final SeedSnapshot seeds;
  final GardenSnapshot garden;

  /// Растение, пришедшее налётчику.
  final HarvestedPlant? plant;

  bool get settled => status == RaidSettleStatus.settled;
}

SeedSpecies? _species(String name) {
  for (final species in SeedSpecies.values) {
    if (species.name == name) return species;
  }
  return null;
}
