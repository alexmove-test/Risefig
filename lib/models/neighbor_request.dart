import 'garden.dart';
import 'pet.dart';
import 'pet_combat.dart';
import 'pet_roster.dart';
import 'plant_cross.dart';
import 'raid_help.dart';
import 'seed_catalog.dart';

/// Что один игрок отправляет другому. Одна открытая заявка каждого вида на пару.
enum NeighborRequestKind { message, defense, cross, raid }

enum NeighborRequestStatus { pending, accepted, declined, cancelled }

/// Кто встретил набег: свой питомец, сосед-охранник, откликнувшийся на зов
/// помощи или назначенный защитник, сработавший сам по истечении срока.
enum RaidDefenseSource { own, guard, help, auto }

/// Готовые фразы. Свободного текста нет, поэтому модерация не нужна.
enum NeighborPhrase {
  hello,
  goodLuck,
  thanks,
  niceGarden,
  letsCross,
  iWillGuard,
  readyForRaid,
  wellPlayed,
}

abstract final class NeighborRequestRules {
  static const protection = Duration(hours: 24);

  /// Ответ на скрещивание можно перекрыть новым, если партнёр так и не забрал семя.
  static const crossClaimWindow = Duration(days: 7);

  /// Срок ответа на набег. Потом срабатывает назначенный защитник.
  static const raidAnswerWindow = Duration(hours: 24);

  /// Новый набег на тот же двор — не раньше, чем через сутки после прошлого.
  static const raidCooldown = Duration(hours: 24);

  /// Неразобранная добыча не держит пару дольше недели.
  static const raidSettleWindow = Duration(days: 7);

  /// Зов о помощи всем игрокам. Друзьям — бесплатно.
  static const helpEveryonePrice = 50;

  /// Сколько друзей видят один зов.
  static const helpMaxViewers = 50;

  static const maxPower = 1000;

  static List<NeighborPhrase> phrasesFor(NeighborRequestKind kind) =>
      switch (kind) {
        NeighborRequestKind.message => const [
          NeighborPhrase.hello,
          NeighborPhrase.goodLuck,
          NeighborPhrase.thanks,
          NeighborPhrase.niceGarden,
          NeighborPhrase.wellPlayed,
        ],
        NeighborRequestKind.defense => const [
          NeighborPhrase.iWillGuard,
          NeighborPhrase.hello,
          NeighborPhrase.goodLuck,
        ],
        NeighborRequestKind.cross => const [
          NeighborPhrase.letsCross,
          NeighborPhrase.niceGarden,
          NeighborPhrase.hello,
        ],
        NeighborRequestKind.raid => const [
          NeighborPhrase.readyForRaid,
          NeighborPhrase.goodLuck,
          NeighborPhrase.wellPlayed,
        ],
      };

  static List<NeighborPhrase> get replies => const [
    NeighborPhrase.thanks,
    NeighborPhrase.hello,
    NeighborPhrase.goodLuck,
    NeighborPhrase.niceGarden,
    NeighborPhrase.wellPlayed,
  ];
}

class NeighborRequest {
  const NeighborRequest({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.kind,
    required this.phrase,
    required this.status,
    required this.createdAt,
    this.power,
    this.species,
    this.respondedAt,
    this.replyPhrase,
    this.replyPower,
    this.replySpecies,
    this.resultSpecies,
    this.fromClaimed = false,
    this.toClaimed = false,
    this.defenseSource,
    this.defenderId,
    this.defenderName,
    this.defenderPet,
    this.lostSpecies,
    this.stolenSpecies,
    this.stolenTrait,
  });

  final String id;
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final NeighborRequestKind kind;
  final NeighborPhrase phrase;
  final NeighborRequestStatus status;
  final DateTime createdAt;

  /// Сила защитника или налётчика отправителя на момент отправки.
  final int? power;

  /// Вид растения, который отправитель отдаёт в скрещивание.
  final SeedSpecies? species;
  final DateTime? respondedAt;
  final NeighborPhrase? replyPhrase;

  /// Защита двора получателя, которой он встретил набег.
  final int? replyPower;
  final SeedSpecies? replySpecies;
  final SeedSpecies? resultSpecies;
  final bool fromClaimed;
  final bool toClaimed;

  final RaidDefenseSource? defenseSource;

  /// Чужой защитник: сосед-охранник или откликнувшийся на зов помощи.
  final String? defenderId;
  final String? defenderName;
  final PetKind? defenderPet;

  /// Растение, которое сгорело при удачном набеге.
  final SeedSpecies? lostSpecies;

  /// Растение, которое забрал налётчик.
  final SeedSpecies? stolenSpecies;
  final PlantTrait? stolenTrait;

  static String idFor(String fromId, String toId, NeighborRequestKind kind) =>
      '${fromId}__${toId}__${kind.name}';

  bool get pending => status == NeighborRequestStatus.pending;

  bool get accepted => status == NeighborRequestStatus.accepted;

  bool outgoingFor(String me) => fromId == me;

  String otherId(String me) => fromId == me ? toId : fromId;

  String otherName(String me) => fromId == me ? toName : fromName;

  /// Ключ одной отправки. Повторная заявка с тем же id получает новый ключ.
  String get opId => 'ncross-$id-${createdAt.millisecondsSinceEpoch}';

  /// Ключ набега для склада. Повторная заявка с тем же id получает новый ключ.
  String get raidOpId => 'nraid-$id-${createdAt.millisecondsSinceEpoch}';

  /// Двор устоял, только если защитник строго сильнее атаки.
  bool? get raidSucceeded {
    if (kind != NeighborRequestKind.raid || !accepted) return null;
    final attack = power;
    final defense = replyPower;
    if (attack == null || defense == null) return null;
    return !raidHeld(attack: attack, defense: defense);
  }

  DateTime? get raidDeadline => kind == NeighborRequestKind.raid
      ? createdAt.add(NeighborRequestRules.raidAnswerWindow)
      : null;

  /// Входящий набег без ответа, срок которого вышел.
  bool raidOverdue(String me, DateTime now) {
    final deadline = raidDeadline;
    return deadline != null &&
        pending &&
        toId == me &&
        !now.isBefore(deadline);
  }

  bool get _raidLoot =>
      raidSucceeded == true && (lostSpecies != null || stolenSpecies != null);

  /// Налётчик ещё не забрал растение к себе на склад.
  bool canTakeLoot(String me) =>
      fromId == me && _raidLoot && stolenSpecies != null && !fromClaimed;

  /// Потеря от набега ещё не списана с моего склада.
  bool owesRaidLoss(String me) => toId == me && _raidLoot && !toClaimed;

  DateTime? get protectionUntil {
    if (kind != NeighborRequestKind.defense || !accepted) return null;
    return respondedAt?.add(NeighborRequestRules.protection);
  }

  bool protects(DateTime now) {
    final until = protectionUntil;
    return until != null && until.isAfter(now);
  }

  bool claimedBy(String me) => fromId == me ? fromClaimed : toClaimed;

  /// Своё растение в скрещивании: отправитель отдаёт [species], получатель — [replySpecies].
  SeedSpecies? givenBy(String me) => fromId == me ? species : replySpecies;

  bool canClaim(String me) =>
      kind == NeighborRequestKind.cross &&
      accepted &&
      resultSpecies != null &&
      givenBy(me) != null &&
      !claimedBy(me);

  /// Входящая заявка ждёт решения, на свою пришёл ответ или семя ещё не забрано.
  bool needsAttention(String me) =>
      (toId == me && pending) ||
      (fromId == me &&
          (accepted || status == NeighborRequestStatus.declined)) ||
      canClaim(me) ||
      canTakeLoot(me);

  /// Новую заявку того же вида пока создавать нельзя. Зеркало правила `canReplace`.
  bool blocksResend(DateTime now) {
    if (pending) return true;
    if (!accepted) return false;
    final responded = respondedAt;
    if (responded == null) return false;
    final age = now.difference(responded);
    switch (kind) {
      case NeighborRequestKind.message:
      case NeighborRequestKind.defense:
        return false;
      case NeighborRequestKind.cross:
        if (fromClaimed && toClaimed) return false;
        return age < NeighborRequestRules.crossClaimWindow;
      case NeighborRequestKind.raid:
        if (age < NeighborRequestRules.raidCooldown) return true;
        if (age >= NeighborRequestRules.raidSettleWindow) return false;
        final lootTaken = stolenSpecies == null || fromClaimed;
        final lossTaken =
            (stolenSpecies == null && lostSpecies == null) || toClaimed;
        return !(lootTaken && lossTaken);
    }
  }

  /// Каждое новое состояние заявки отмечается просмотренным отдельно.
  String get noticeKey =>
      'req:$id@${(respondedAt ?? createdAt).millisecondsSinceEpoch}';

  NeighborRequest copyWith({
    NeighborRequestStatus? status,
    DateTime? respondedAt,
    NeighborPhrase? replyPhrase,
    int? replyPower,
    SeedSpecies? replySpecies,
    SeedSpecies? resultSpecies,
    bool? fromClaimed,
    bool? toClaimed,
    RaidDefenseSource? defenseSource,
    String? defenderId,
    String? defenderName,
    PetKind? defenderPet,
    SeedSpecies? lostSpecies,
    SeedSpecies? stolenSpecies,
    PlantTrait? stolenTrait,
  }) {
    return NeighborRequest(
      id: id,
      fromId: fromId,
      fromName: fromName,
      toId: toId,
      toName: toName,
      kind: kind,
      phrase: phrase,
      status: status ?? this.status,
      createdAt: createdAt,
      power: power,
      species: species,
      respondedAt: respondedAt ?? this.respondedAt,
      replyPhrase: replyPhrase ?? this.replyPhrase,
      replyPower: replyPower ?? this.replyPower,
      replySpecies: replySpecies ?? this.replySpecies,
      resultSpecies: resultSpecies ?? this.resultSpecies,
      fromClaimed: fromClaimed ?? this.fromClaimed,
      toClaimed: toClaimed ?? this.toClaimed,
      defenseSource: defenseSource ?? this.defenseSource,
      defenderId: defenderId ?? this.defenderId,
      defenderName: defenderName ?? this.defenderName,
      defenderPet: defenderPet ?? this.defenderPet,
      lostSpecies: lostSpecies ?? this.lostSpecies,
      stolenSpecies: stolenSpecies ?? this.stolenSpecies,
      stolenTrait: stolenTrait ?? this.stolenTrait,
    );
  }

  /// Разбор документа. Даты приходят уже как [DateTime], чтобы модель не знала Firestore.
  static NeighborRequest? fromMap(String id, Map<String, Object?> data) {
    final fromId = data['fromId'];
    final fromName = data['fromName'];
    final toId = data['toId'];
    final toName = data['toName'];
    final kind = _named(NeighborRequestKind.values, data['kind']);
    final phrase = _named(NeighborPhrase.values, data['phrase']);
    final status = _named(NeighborRequestStatus.values, data['status']);
    final createdAt = data['createdAt'];
    if (fromId is! String ||
        fromId.isEmpty ||
        toId is! String ||
        toId.isEmpty ||
        fromName is! String ||
        toName is! String ||
        kind == null ||
        phrase == null ||
        status == null ||
        createdAt is! DateTime) {
      return null;
    }
    final respondedAt = data['respondedAt'];
    return NeighborRequest(
      id: id,
      fromId: fromId,
      fromName: fromName,
      toId: toId,
      toName: toName,
      kind: kind,
      phrase: phrase,
      status: status,
      createdAt: createdAt,
      power: _power(data['power']),
      species: _named(SeedSpecies.values, data['species']),
      respondedAt: respondedAt is DateTime ? respondedAt : null,
      replyPhrase: _named(NeighborPhrase.values, data['replyPhrase']),
      replyPower: _power(data['replyPower']),
      replySpecies: _named(SeedSpecies.values, data['replySpecies']),
      resultSpecies: _named(SeedSpecies.values, data['resultSpecies']),
      fromClaimed: data['fromClaimed'] == true,
      toClaimed: data['toClaimed'] == true,
      defenseSource: _named(RaidDefenseSource.values, data['defenseSource']),
      defenderId: data['defenderId'] is String
          ? data['defenderId'] as String
          : null,
      defenderName: data['defenderName'] is String
          ? data['defenderName'] as String
          : null,
      defenderPet: _named(PetKind.values, data['defenderPet']),
      lostSpecies: _named(SeedSpecies.values, data['lostSpecies']),
      stolenSpecies: _named(SeedSpecies.values, data['stolenSpecies']),
      stolenTrait: plantTraitNamed(data['stolenTrait']),
    );
  }
}

int unseenRequestCount(
  Iterable<NeighborRequest> requests,
  String me,
  Set<String> seenIds, {
  Set<String> blockedIds = const {},
}) {
  var count = 0;
  for (final request in requests) {
    if (blockedIds.contains(request.otherId(me))) continue;
    if (!request.needsAttention(me) || seenIds.contains(request.noticeKey)) {
      continue;
    }
    count++;
  }
  return count;
}

int petPowerOf(PetRosterSnapshot roster, PetKind kind) {
  final record = roster.recordOf(kind) ?? PetCombatRecord.fresh(kind);
  final progress = PetLevelProgress.of(record.level, record.xp);
  return PetStrength.of(level: progress.level).total;
}

/// Сила назначенного питомца роли. Без назначения действие недоступно.
int? assignedPetPower(
  PetRosterSnapshot roster,
  List<PetKind> owned,
  PetRole role,
) {
  final kind = role == PetRole.defender
      ? roster.guarding(owned)
      : roster.raiding(owned);
  if (kind == null) return null;
  return petPowerOf(roster, kind);
}

bool raidHeld({required int attack, required int defense}) => defense > attack;

/// Один защитник, которым можно встретить набег.
class RaidDefenseOption {
  const RaidDefenseOption({
    required this.source,
    required this.power,
    this.pet,
    this.helperId,
    this.helperName,
  });

  final RaidDefenseSource source;
  final int power;
  final PetKind? pet;
  final String? helperId;
  final String? helperName;

  String get key => '${source.name}:${helperId ?? pet?.name ?? ''}';

  bool holds(int attack) => raidHeld(attack: attack, defense: power);
}

/// Свои защитники, охранники соседей и отклики на зов помощи, сильные первыми.
List<RaidDefenseOption> raidDefenseOptions({
  required PetRosterSnapshot roster,
  required List<PetKind> owned,
  required Iterable<NeighborRequest> requests,
  required String me,
  required DateTime now,
  Iterable<RaidHelpOffer> help = const [],
}) {
  final options = <RaidDefenseOption>[
    for (final kind in owned)
      if (PetCombatRules.roleOf(kind) == PetRole.defender)
        RaidDefenseOption(
          source: RaidDefenseSource.own,
          power: petPowerOf(roster, kind),
          pet: kind,
        ),
    for (final request in requests)
      if (request.kind == NeighborRequestKind.defense &&
          request.toId == me &&
          request.protects(now) &&
          (request.power ?? 0) > 0)
        RaidDefenseOption(
          source: RaidDefenseSource.guard,
          power: request.power!,
          helperId: request.fromId,
          helperName: request.fromName,
        ),
    for (final offer in help)
      if (offer.helperId != me)
        RaidDefenseOption(
          source: RaidDefenseSource.help,
          power: offer.power,
          pet: offer.pet,
          helperId: offer.helperId,
          helperName: offer.helperName,
        ),
  ];
  options.sort((a, b) => b.power.compareTo(a.power));
  return options;
}

/// Ответ без игрока: назначенный защитник. Без него двор беззащитен.
RaidDefenseOption autoRaidDefense(
  PetRosterSnapshot roster,
  List<PetKind> owned,
) {
  final kind = roster.guarding(owned);
  return RaidDefenseOption(
    source: RaidDefenseSource.auto,
    power: kind == null ? 0 : petPowerOf(roster, kind),
    pet: kind,
  );
}

class RaidLoss {
  const RaidLoss({this.destroyed, this.stolen});

  final HarvestedPlant? destroyed;
  final HarvestedPlant? stolen;

  bool get empty => destroyed == null && stolen == null;
}

/// Что теряет двор после удачного набега. Сгорает выбранное растение
/// (без выбора — самое слабое), налётчик забирает случайное из остальных.
/// Если растение одно, оно уходит налётчику. Жребий зависит только от [opId].
RaidLoss planRaidLoss({
  required String opId,
  required List<HarvestedPlant> plants,
  String? destroyId,
}) {
  if (plants.isEmpty) return const RaidLoss();
  if (plants.length == 1) return RaidLoss(stolen: plants.single);
  HarvestedPlant? destroyed;
  for (final plant in plants) {
    if (plant.id == destroyId) destroyed = plant;
  }
  destroyed ??= ([...plants]..sort(_weakestFirst)).first;
  final rest = [
    for (final plant in plants)
      if (plant.id != destroyed.id) plant,
  ]..sort((a, b) => a.id.compareTo(b.id));
  final draw = _drawFor(opId);
  return RaidLoss(destroyed: destroyed, stolen: rest[draw(rest.length)]);
}

int _weakestFirst(HarvestedPlant a, HarvestedPlant b) {
  final byPower = a.power.compareTo(b.power);
  if (byPower != 0) return byPower;
  final byAge = a.harvestedAt.compareTo(b.harvestedAt);
  if (byAge != 0) return byAge;
  return a.id.compareTo(b.id);
}

int Function(int count) _drawFor(String opId) {
  var state = 0x811c9dc5;
  for (final unit in opId.codeUnits) {
    state = ((state ^ unit) * 0x01000193) & 0xffffffff;
  }
  return (count) {
    if (count <= 1) return 0;
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    return state % count;
  };
}

/// Итог скрещивания с соседом. Жребий зависит только от id заявки,
/// поэтому оба устройства получают один и тот же вид.
SeedSpecies resolveNeighborCross({
  required String opId,
  required SeedSpecies first,
  required SeedSpecies second,
}) {
  final draw = _drawFor(opId);
  return resolveCross(
        first: first,
        second: second,
        aim: CrossAim.garden,
        draw: draw,
      ).species ??
      first;
}

T? _named<T extends Enum>(List<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}

int? _power(Object? raw) {
  if (raw is! num) return null;
  final value = raw.toInt();
  if (value < 0 || value > NeighborRequestRules.maxPower) return null;
  return value;
}
