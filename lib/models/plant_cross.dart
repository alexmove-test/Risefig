import 'pet_combat.dart';
import 'seed_catalog.dart';

/// Зачем игрок отдаёт два растения. Удача не обещана ни для одной цели.
enum CrossAim { combat, garden, seeds }

enum CrossStatus {
  granted,
  chooseTrait,
  chooseSeed,
  needTwo,
  samePlant,
  listed,
  missing,
  waiting,
  unavailable,
  failed,
}

/// Отдельное свойство экземпляра. Корм класса от него не зависит.
enum PlantTrait { attack, defense, bloom }

/// Куда попал жребий из ста. Обычный исход не улучшает растение.
enum CrossBand { ordinary, raised, rare }

/// Доли одного броска. Сумма всегда 100.
class CrossWeights {
  const CrossWeights({
    required this.ordinary,
    required this.raised,
    required this.rare,
  });

  final int ordinary;
  final int raised;
  final int rare;

  int get total => ordinary + raised + rare;
}

/// Незавершённый выбор после удачного скрещивания. Растения уже списаны.
class CrossPending {
  const CrossPending({
    required this.id,
    required this.aim,
    required this.band,
    required this.resultClass,
    required this.houseLevel,
    this.species,
    this.choices = const [],
  });

  final String id;
  final CrossAim aim;
  final CrossBand band;
  final SeedClass resultClass;
  final int houseLevel;
  final SeedSpecies? species;
  final List<SeedSpecies> choices;

  bool get choosesTrait => aim == CrossAim.combat;

  bool get choosesSeed => aim == CrossAim.seeds;

  Map<String, Object> toJson() => {
    'id': id,
    'aim': aim.name,
    'band': band.name,
    'resultClass': resultClass.name,
    'houseLevel': houseLevel,
    'species': ?species?.name,
    'choices': [for (final species in choices) species.name],
  };

  static CrossPending? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final aimName = raw['aim'];
    final bandName = raw['band'];
    final className = raw['resultClass'];
    final house = raw['houseLevel'];
    final speciesName = raw['species'];
    final choiceRaw = raw['choices'];
    if (id is! String ||
        id.isEmpty ||
        aimName is! String ||
        bandName is! String ||
        className is! String ||
        house is! int ||
        house < 1 ||
        choiceRaw is! List) {
      return null;
    }
    final aim = _aim(aimName);
    final band = _bandNamed(bandName);
    final resultClass = _class(className);
    if (aim == null ||
        aim == CrossAim.garden ||
        band == null ||
        band == CrossBand.ordinary ||
        resultClass == null) {
      return null;
    }
    if (speciesName != null && speciesName is! String) return null;
    final species = speciesName is String ? _species(speciesName) : null;
    if (speciesName is String && species == null) return null;
    if (aim == CrossAim.combat && species == null) return null;
    final choices = <SeedSpecies>[];
    for (final item in choiceRaw) {
      if (item is! String) return null;
      final parsed = _species(item);
      if (parsed == null) return null;
      choices.add(parsed);
    }
    if (aim == CrossAim.seeds && choices.isEmpty) return null;
    if (aim == CrossAim.combat && choices.isNotEmpty) return null;
    return CrossPending(
      id: id,
      aim: aim,
      band: band,
      resultClass: resultClass,
      houseLevel: house,
      species: species,
      choices: choices,
    );
  }
}

class CrossResolution {
  const CrossResolution({
    required this.band,
    required this.resultClass,
    required this.species,
    required this.choices,
    required this.trait,
  });

  final CrossBand band;
  final SeedClass resultClass;
  final SeedSpecies? species;
  final List<SeedSpecies> choices;
  final PlantTrait? trait;

  bool get success => band != CrossBand.ordinary;
}

/// Доли по классам родителей. Редкое возможно, но не обещано.
CrossWeights weightsFor(SeedClass first, SeedClass second) {
  final low = first.index <= second.index ? first : second;
  final high = first.index >= second.index ? first : second;
  if (low == SeedClass.common && high == SeedClass.common) {
    return const CrossWeights(ordinary: 70, raised: 22, rare: 8);
  }
  if (low == SeedClass.common && high == SeedClass.nutrient) {
    return const CrossWeights(ordinary: 55, raised: 30, rare: 15);
  }
  if (low == SeedClass.common && high == SeedClass.rare) {
    return const CrossWeights(ordinary: 40, raised: 20, rare: 40);
  }
  if (low == SeedClass.nutrient && high == SeedClass.nutrient) {
    return const CrossWeights(ordinary: 40, raised: 35, rare: 25);
  }
  if (low == SeedClass.nutrient && high == SeedClass.rare) {
    return const CrossWeights(ordinary: 30, raised: 0, rare: 70);
  }
  return const CrossWeights(ordinary: 40, raised: 60, rare: 0);
}

/// Один жребий на пару растений и цель. [draw] — это `Random.nextInt`.
CrossResolution resolveCross({
  required SeedSpecies first,
  required SeedSpecies second,
  required CrossAim aim,
  required int Function(int count) draw,
}) {
  final weights = weightsFor(first.seedClass, second.seedClass);
  final ticket = _ticket(draw(100));
  final band = _band(weights, ticket);
  final resultClass = _resultClass(first.seedClass, second.seedClass, band);
  final parents = [first, second];
  if (band == CrossBand.ordinary) {
    return CrossResolution(
      band: band,
      resultClass: resultClass,
      species: _speciesInClass(resultClass, parents, draw),
      choices: const [],
      trait: null,
    );
  }
  if (aim == CrossAim.seeds) {
    return CrossResolution(
      band: band,
      resultClass: resultClass,
      species: null,
      choices: unlockedSeeds(parents, band, resultClass),
      trait: null,
    );
  }
  if (aim == CrossAim.garden) {
    return CrossResolution(
      band: band,
      resultClass: resultClass,
      species: _speciesInClass(resultClass, parents, draw),
      choices: const [],
      trait: PlantTrait.bloom,
    );
  }
  return CrossResolution(
    band: band,
    resultClass: resultClass,
    species: _speciesInClass(resultClass, parents, draw),
    choices: const [],
    trait: null,
  );
}

/// Виды, которые игрок может забрать после удачной цели «семена».
List<SeedSpecies> unlockedSeeds(
  List<SeedSpecies> parents,
  CrossBand band,
  SeedClass resultClass,
) {
  if (band == CrossBand.ordinary || parents.isEmpty) return const [];
  final chosen = <SeedSpecies>{...parents};
  var high = parents.first.seedClass;
  for (final parent in parents) {
    if (parent.seedClass.index > high.index) high = parent.seedClass;
  }
  final next = high == SeedClass.rare ? null : SeedClass.values[high.index + 1];
  if (next != null && resultClass.index >= next.index) {
    for (final species in SeedSpecies.values) {
      if (species.seedClass == next) chosen.add(species);
    }
  }
  if (band == CrossBand.rare) {
    for (final species in SeedSpecies.values) {
      if (species.seedClass == SeedClass.rare) chosen.add(species);
    }
  }
  for (final species in SeedSpecies.values) {
    if (species.seedClass == resultClass) chosen.add(species);
  }
  chosen.removeWhere(
    (species) =>
        species.seedClass == SeedClass.rare &&
        resultClass != SeedClass.rare &&
        band != CrossBand.rare,
  );
  return [
    for (final species in SeedSpecies.values)
      if (chosen.contains(species)) species,
  ];
}

/// Опыт кормления. Свойство добавляется только подходящей роли.
int feedXp({
  required SeedSpecies species,
  required PlantTrait? trait,
  required PetRole role,
}) {
  final base = SeedCatalog.foodFor(species);
  final matches = switch (trait) {
    PlantTrait.attack => role == PetRole.attacker,
    PlantTrait.defense => role == PetRole.defender,
    PlantTrait.bloom || null => false,
  };
  if (!matches) return base;
  return switch (species.seedClass) {
    SeedClass.common => 15,
    SeedClass.nutrient => 35,
    SeedClass.rare => 80,
  };
}

PlantTrait? plantTraitNamed(Object? raw) {
  if (raw is! String) return null;
  for (final trait in PlantTrait.values) {
    if (trait.name == raw) return trait;
  }
  return null;
}

CrossBand _band(CrossWeights weights, int ticket) {
  if (ticket < weights.ordinary) return CrossBand.ordinary;
  if (ticket < weights.ordinary + weights.raised) return CrossBand.raised;
  return CrossBand.rare;
}

SeedClass _resultClass(SeedClass first, SeedClass second, CrossBand band) {
  final low = first.index <= second.index ? first : second;
  final high = first.index >= second.index ? first : second;
  return switch (band) {
    CrossBand.ordinary => low,
    CrossBand.rare => SeedClass.rare,
    CrossBand.raised => switch ((low, high)) {
      (SeedClass.rare, SeedClass.rare) => SeedClass.rare,
      (SeedClass.nutrient, SeedClass.nutrient) => SeedClass.nutrient,
      (SeedClass.common, SeedClass.common) => SeedClass.nutrient,
      _ => high,
    },
  };
}

SeedSpecies _speciesInClass(
  SeedClass seedClass,
  List<SeedSpecies> parents,
  int Function(int count) draw,
) {
  final matching = <SeedSpecies>[];
  for (final parent in parents) {
    if (parent.seedClass == seedClass && !matching.contains(parent)) {
      matching.add(parent);
    }
  }
  final pool = [
    for (final species in SeedSpecies.values)
      if (species.seedClass == seedClass) species,
  ];
  if (matching.isEmpty) return pool[draw(pool.length)];
  if (matching.length == 1 && pool.length > 1) {
    final sibling = pool.firstWhere((species) => species != matching.first);
    return draw(100) < 85 ? matching.first : sibling;
  }
  return matching[draw(matching.length)];
}

int _ticket(int raw) {
  if (raw < 0) return 0;
  if (raw > 99) return 99;
  return raw;
}

CrossBand? _bandNamed(String name) {
  for (final band in CrossBand.values) {
    if (band.name == name) return band;
  }
  return null;
}

CrossAim? _aim(String name) {
  for (final aim in CrossAim.values) {
    if (aim.name == name) return aim;
  }
  return null;
}

SeedClass? _class(String name) {
  for (final seedClass in SeedClass.values) {
    if (seedClass.name == name) return seedClass;
  }
  return null;
}

SeedSpecies? _species(String name) {
  for (final species in SeedSpecies.values) {
    if (species.name == name) return species;
  }
  return null;
}
