import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/models/garden.dart';
import 'package:mahjong/models/pet.dart';
import 'package:mahjong/models/pet_combat.dart';
import 'package:mahjong/models/plant_cross.dart';
import 'package:mahjong/models/seed_batch.dart';
import 'package:mahjong/models/seed_catalog.dart';
import 'package:mahjong/services/points_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cross weights stay on one hundred and rare is not promised', () {
    for (final first in SeedClass.values) {
      for (final second in SeedClass.values) {
        expect(weightsFor(first, second).total, 100);
      }
    }
    final commons = weightsFor(SeedClass.common, SeedClass.common);
    expect(commons.ordinary, 70);
    expect(commons.rare, 8);
    expect(weightsFor(SeedClass.rare, SeedClass.rare).rare, 0);
    expect(weightsFor(SeedClass.nutrient, SeedClass.rare).rare, 70);
  });

  test('a miss stays in the lower class and a hit can reach rare', () {
    final miss = resolveCross(
      first: SeedSpecies.amberbell,
      second: SeedSpecies.mistfern,
      aim: CrossAim.garden,
      draw: (count) => 0,
    );
    expect(miss.band, CrossBand.ordinary);
    expect(miss.resultClass, SeedClass.common);
    expect(miss.trait, isNull);
    expect(miss.species, SeedSpecies.amberbell);

    final hit = resolveCross(
      first: SeedSpecies.amberbell,
      second: SeedSpecies.mistfern,
      aim: CrossAim.combat,
      draw: _script([99, 0]),
    );
    expect(hit.band, CrossBand.rare);
    expect(hit.resultClass, SeedClass.rare);
    expect(hit.trait, isNull);
    expect(hit.species!.seedClass, SeedClass.rare);

    final choice = resolveCross(
      first: SeedSpecies.amberbell,
      second: SeedSpecies.mistfern,
      aim: CrossAim.seeds,
      draw: (count) => 99,
    );
    expect(choice.choices, contains(SeedSpecies.nightlotus));
    expect(choice.choices, contains(SeedSpecies.amberbell));
    expect(choice.species, isNull);
  });

  test('attack feed adds experience only for an attacker', () {
    expect(
      feedXp(
        species: SeedSpecies.amberbell,
        trait: PlantTrait.attack,
        role: PetRole.attacker,
      ),
      15,
    );
    expect(
      feedXp(
        species: SeedSpecies.amberbell,
        trait: PlantTrait.attack,
        role: PetRole.defender,
      ),
      10,
    );
    expect(
      feedXp(
        species: SeedSpecies.nightlotus,
        trait: PlantTrait.defense,
        role: PetRole.defender,
      ),
      80,
    );
    expect(
      GardenCatalog.durationFor(SeedSpecies.amberbell, trait: PlantTrait.bloom),
      const Duration(minutes: 3, seconds: 30),
    );
  });

  test(
    'ordinary cross spends both plants once and keeps the same seed',
    () async {
      final first = _plant('plant-1');
      final second = _plant('plant-2', species: SeedSpecies.mistfern);
      SharedPreferences.setMockInitialValues({
        'points.balance': 40,
        'garden.state.v1': _garden([first, second]).encode(),
        'seeds.state.v1': SeedSnapshot.empty.encode(),
      });
      final store = await PointsStore.open();
      final result = await store.beginCross(
        firstId: first.id,
        secondId: second.id,
        aim: CrossAim.garden,
        opId: 'cross-1',
        roll: (count) => 0,
        now: DateTime.utc(2026, 10, 7),
      );
      expect(result.granted, isTrue);
      expect(result.band, CrossBand.ordinary);
      expect(result.seed!.source, SeedSource.cross);
      expect(result.seed!.trait, isNull);
      expect(store.garden.warehouse, isEmpty);
      expect(store.seeds.inventory, hasLength(1));

      final again = await store.beginCross(
        firstId: first.id,
        secondId: second.id,
        aim: CrossAim.garden,
        opId: 'cross-1',
        roll: (count) => 99,
      );
      expect(again.granted, isTrue);
      expect(again.seed!.id, result.seed!.id);
      expect(store.seeds.inventory, hasLength(1));
      expect(
        (await PointsStore.open()).seeds.inventory.single.batchId,
        'cross-1',
      );
    },
  );

  test('combat success waits for a trait and does not roll again', () async {
    final first = _plant('plant-1');
    final second = _plant('plant-2');
    SharedPreferences.setMockInitialValues({
      'points.balance': 40,
      'garden.state.v1': _garden([first, second]).encode(),
      'seeds.state.v1': SeedSnapshot.empty.encode(),
    });
    final store = await PointsStore.open();
    final started = await store.beginCross(
      firstId: first.id,
      secondId: second.id,
      aim: CrossAim.combat,
      opId: 'cross-2',
      roll: _script([99, 0]),
    );
    expect(started.status, CrossStatus.chooseTrait);
    expect(store.garden.warehouse, isEmpty);
    expect(store.seeds.inventory, isEmpty);
    expect(
      (await PointsStore.open()).garden.pending!.species!.seedClass,
      SeedClass.rare,
    );

    final waiting = await store.beginCross(
      firstId: 'other-a',
      secondId: 'other-b',
      aim: CrossAim.garden,
      opId: 'cross-other',
      roll: (count) => 0,
    );
    expect(waiting.status, CrossStatus.waiting);

    final unfinished = await store.finishCross(opId: 'cross-2');
    expect(unfinished.status, CrossStatus.chooseTrait);
    expect(store.seeds.inventory, isEmpty);

    final done = await store.finishCross(
      opId: 'cross-2',
      trait: PlantTrait.attack,
    );
    expect(done.granted, isTrue);
    expect(done.seed!.trait, PlantTrait.attack);
    expect(done.seed!.species.seedClass, SeedClass.rare);
    expect(store.garden.pending, isNull);

    final repeat = await store.finishCross(
      opId: 'cross-2',
      trait: PlantTrait.defense,
    );
    expect(repeat.seed!.id, done.seed!.id);
    expect(repeat.seed!.trait, PlantTrait.attack);
    expect(store.seeds.inventory, hasLength(1));
  });

  test('seed success lets the player pick one unlocked species', () async {
    final first = _plant('plant-1');
    final second = _plant('plant-2', species: SeedSpecies.mistfern);
    SharedPreferences.setMockInitialValues({
      'garden.state.v1': _garden([first, second]).encode(),
      'seeds.state.v1': SeedSnapshot.empty.encode(),
    });
    final store = await PointsStore.open();
    final started = await store.beginCross(
      firstId: first.id,
      secondId: second.id,
      aim: CrossAim.seeds,
      opId: 'cross-3',
      roll: (count) => 80,
    );
    expect(started.status, CrossStatus.chooseSeed);
    expect(store.garden.pending!.choices, contains(SeedSpecies.glassreed));
    expect(
      store.garden.pending!.choices,
      isNot(contains(SeedSpecies.nightlotus)),
    );

    final picked = await store.finishCross(
      opId: 'cross-3',
      species: SeedSpecies.glassreed,
    );
    expect(picked.seed!.species, SeedSpecies.glassreed);
    expect(picked.seed!.trait, isNull);
  });

  test(
    'a listed plant and a faster garden seed follow the cross rules',
    () async {
      final listed = _plant('plant-1');
      final free = _plant('plant-2');
      final third = _plant('plant-3', species: SeedSpecies.mistfern);
      SharedPreferences.setMockInitialValues({
        'points.balance': 100,
        'plants.showcase.reservations.v1': ['owner\tplant-1'],
        'garden.state.v1': _garden([listed, free, third]).encode(),
        'seeds.state.v1': SeedSnapshot.empty.encode(),
      });
      final store = await PointsStore.open();
      final blocked = await store.beginCross(
        firstId: listed.id,
        secondId: free.id,
        aim: CrossAim.garden,
        opId: 'cross-listed',
        roll: (count) => 99,
      );
      expect(blocked.status, CrossStatus.listed);
      expect(store.garden.warehouse, hasLength(3));

      final grown = await store.beginCross(
        firstId: free.id,
        secondId: third.id,
        aim: CrossAim.garden,
        opId: 'cross-bloom',
        roll: (count) => 70,
        now: DateTime.utc(2026, 10, 7, 12),
      );
      expect(grown.seed!.trait, PlantTrait.bloom);
      expect(grown.seed!.species.seedClass, SeedClass.nutrient);
      final planted = await store.plantSeed(
        bedIndex: 0,
        seedId: grown.seed!.id,
        now: DateTime.utc(2026, 10, 7, 12),
      );
      expect(planted.planted, isTrue);
      expect(
        planted.planting!.readyAt.difference(planted.planting!.plantedAt),
        GardenCatalog.durationFor(grown.seed!.species, trait: PlantTrait.bloom),
      );
      expect(planted.planting!.trait, PlantTrait.bloom);
    },
  );

  test('attack feed on a matching pet grants the extra experience', () async {
    final plant = _plant('plant-1', trait: PlantTrait.attack);
    final plain = _plant('plant-2');
    final started = DateTime.utc(2026, 10, 1);
    SharedPreferences.setMockInitialValues({
      'points.balance': 20,
      'pet.owned': 'cat',
      'pet.cat.hungerAt': started.millisecondsSinceEpoch,
      'pet.cat.playAt': started.millisecondsSinceEpoch,
      'pet.cat.restAt': started.millisecondsSinceEpoch,
      'garden.state.v1': _garden([plant, plain]).encode(),
    });
    final store = await PointsStore.open();
    final fed = await store.feedPet(
      kind: PetKind.cat,
      plantId: plant.id,
      now: started.add(const Duration(hours: 3)),
    );
    expect(fed.preview!.xpGain, 15);
    expect(store.roster.recordOf(PetKind.cat)!.xp, 15);
    expect(store.garden.warehouse.single.id, plain.id);
  });

  test('attack feed gives a defender only the class amount', () async {
    final plant = _plant('plant-1', trait: PlantTrait.attack);
    final started = DateTime.utc(2026, 10, 1);
    SharedPreferences.setMockInitialValues({
      'points.balance': 20,
      'pet.owned': 'dog',
      'pet.dog.hungerAt': started.millisecondsSinceEpoch,
      'pet.dog.playAt': started.millisecondsSinceEpoch,
      'pet.dog.restAt': started.millisecondsSinceEpoch,
      'garden.state.v1': _garden([plant]).encode(),
    });
    final store = await PointsStore.open();
    final fed = await store.feedPet(
      kind: PetKind.dog,
      plantId: plant.id,
      now: started.add(const Duration(hours: 3)),
    );
    expect(fed.preview!.xpGain, 10);
    expect(store.roster.recordOf(PetKind.dog)!.xp, 10);
  });
}

int Function(int count) _script(List<int> values) {
  var index = 0;
  return (count) {
    final raw = values[index];
    index += 1;
    if (count <= 1) return 0;
    if (raw < 0) return 0;
    if (raw >= count) return count - 1;
    return raw;
  };
}

HarvestedPlant _plant(
  String id, {
  SeedSpecies species = SeedSpecies.amberbell,
  PlantTrait? trait,
}) {
  final at = DateTime.utc(2026, 10, 1);
  return HarvestedPlant(
    id: id,
    species: species,
    power: SeedCatalog.foodFor(species),
    houseLevel: 1,
    seedId: 'seed-$id',
    source: SeedSource.houseProduction,
    batchId: 'batch-$id',
    plantingId: 'planting-$id',
    plantedAt: at,
    maturedAt: at.add(const Duration(minutes: 5)),
    harvestedAt: at.add(const Duration(minutes: 6)),
    trait: trait,
  );
}

GardenSnapshot _garden(List<HarvestedPlant> plants) {
  return GardenSnapshot(
    beds: List<Planting?>.filled(GardenCatalog.bedCount, null),
    warehouse: plants,
    seq: plants.length,
  );
}
