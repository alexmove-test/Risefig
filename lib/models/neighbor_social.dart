import 'list_badges.dart';

/// Публичная карточка игрока из рейтинга. Это не хозяйство и не присутствие.
class NeighborPerson {
  const NeighborPerson({
    required this.id,
    required this.name,
    required this.stars,
    required this.levelsUnlocked,
    this.rating = 0,
    this.practice = false,
    this.progressKnown = true,
    this.badges,
  });

  final String id;
  final String name;
  final int stars;
  final int levelsUnlocked;
  final int rating;

  /// Учебная запись. Живой каталог такие записи не отдаёт.
  final bool practice;

  /// Ложь, если источник не прислал звёзды и уровень. Ноль тогда не показываем.
  final bool progressKnown;

  /// Оплаченный показ значков профиля. Истёкший срок строка не показывает.
  final ListBadges? badges;

  NeighborPerson copyWith({
    String? name,
    int? stars,
    int? levelsUnlocked,
    int? rating,
  }) {
    return NeighborPerson(
      id: id,
      name: name ?? this.name,
      stars: stars ?? this.stars,
      levelsUnlocked: levelsUnlocked ?? this.levelsUnlocked,
      rating: rating ?? this.rating,
      practice: practice,
      progressKnown: progressKnown,
      badges: badges,
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'stars': stars,
    'levels': levelsUnlocked,
    'rating': rating,
    if (badges != null) 'badges': badges!.toJson(),
  };

  static NeighborPerson? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    if (id is! String || id.isEmpty || name is! String || name.trim().isEmpty) {
      return null;
    }
    return NeighborPerson(
      id: id,
      name: name,
      stars: _asInt(raw['stars']),
      levelsUnlocked: _asInt(raw['levels']),
      rating: _asInt(raw['rating']),
      badges: ListBadges.fromJson(raw['badges']),
    );
  }
}

/// Одна страница каталога. Порядок [people] задаёт источник и дальше не сортируется.
class NeighborPage {
  const NeighborPage({
    required this.people,
    required this.hasMore,
    required this.online,
    this.pageToken,
    this.fromCache = false,
    this.failed = false,
  });

  final List<NeighborPerson> people;
  final bool hasMore;
  final String? pageToken;
  final bool online;
  final bool fromCache;
  final bool failed;

  static const emptyOffline = NeighborPage(
    people: [],
    hasMore: false,
    online: false,
    failed: true,
  );
}

enum NeighborSignal {
  asksHelp,
  seeksDefense,
  offersCross,
  awaitsReply,
  helpedYou,
}

/// Чем важнее сигнал, тем раньше он в перечислении.
enum NeighborAttention { needsDecision, result, request }

enum NeighborKind { help, defense, cross, raid, thanks }

enum NeighborPhase {
  available,
  awaitingReply,
  needsDecision,
  inProgress,
  completed,
  declined,
  cancelled,
  expired,
  unavailable,
  failed,
}

enum NeighborFollowUp { thank, save, offerAgain }

enum NeighborReason { unsupported, notAllowed, missingPet, missingPlant }

enum NeighborMemoryCode {
  helpedPlant,
  petDefended,
  crossed,
  thanked,
  raidReport,
}

enum NeighborCommand {
  accept,
  decline,
  confirmAttack,
  thank,
  retry,
  offerAgain,
}

/// Событие, которое уже подтвердил источник данных. Клиент его не выдумывает.
class NeighborEvent {
  const NeighborEvent({
    required this.id,
    required this.personId,
    required this.personName,
    required this.kind,
    required this.phase,
    required this.signal,
    required this.attention,
    required this.incoming,
    this.inbox = false,
    this.practice = false,
    this.cost,
    this.outcome,
    this.plantName,
    this.ownerKeepsPlant,
    this.protectorName,
    this.untilMillis,
    this.attackStrength,
    this.defenseStrength,
    this.lootEssence,
    this.reason,
    this.followUps = const {},
  });

  final String id;
  final String personId;
  final String personName;
  final NeighborKind kind;
  final NeighborPhase phase;
  final NeighborSignal signal;
  final NeighborAttention attention;
  final bool incoming;
  final bool inbox;
  final bool practice;
  final String? cost;
  final String? outcome;
  final String? plantName;
  final bool? ownerKeepsPlant;
  final String? protectorName;
  final int? untilMillis;
  final int? attackStrength;
  final int? defenseStrength;
  final int? lootEssence;
  final NeighborReason? reason;
  final Set<NeighborFollowUp> followUps;

  bool get showsSignal => switch (phase) {
    NeighborPhase.available ||
    NeighborPhase.awaitingReply ||
    NeighborPhase.needsDecision ||
    NeighborPhase.inProgress ||
    NeighborPhase.completed => true,
    _ => false,
  };

  bool get closed => switch (phase) {
    NeighborPhase.declined ||
    NeighborPhase.cancelled ||
    NeighborPhase.expired => true,
    _ => false,
  };

  NeighborEvent copyWith({
    NeighborPhase? phase,
    NeighborReason? reason,
    bool clearReason = false,
    Set<NeighborFollowUp>? followUps,
  }) {
    return NeighborEvent(
      id: id,
      personId: personId,
      personName: personName,
      kind: kind,
      phase: phase ?? this.phase,
      signal: signal,
      attention: attention,
      incoming: incoming,
      inbox: inbox,
      practice: practice,
      cost: cost,
      outcome: outcome,
      plantName: plantName,
      ownerKeepsPlant: ownerKeepsPlant,
      protectorName: protectorName,
      untilMillis: untilMillis,
      attackStrength: attackStrength,
      defenseStrength: defenseStrength,
      lootEssence: lootEssence,
      reason: clearReason ? null : (reason ?? this.reason),
      followUps: followUps ?? this.followUps,
    );
  }
}

class NeighborMemory {
  const NeighborMemory({
    required this.id,
    required this.personId,
    required this.personName,
    required this.code,
    required this.atMillis,
  });

  final String id;
  final String personId;
  final String personName;
  final NeighborMemoryCode code;
  final int atMillis;

  Map<String, Object> toJson() => {
    'id': id,
    'personId': personId,
    'name': personName,
    'code': code.name,
    'at': atMillis,
  };

  static NeighborMemory? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final personId = raw['personId'];
    final name = raw['name'];
    final codeName = raw['code'];
    if (id is! String ||
        personId is! String ||
        name is! String ||
        codeName is! String) {
      return null;
    }
    NeighborMemoryCode? code;
    for (final value in NeighborMemoryCode.values) {
      if (value.name == codeName) code = value;
    }
    if (code == null) return null;
    return NeighborMemory(
      id: id,
      personId: personId,
      personName: name,
      code: code,
      atMillis: _asInt(raw['at']),
    );
  }
}

/// Главный сигнал строки. Ничья разрешается по id, поэтому смена порядка списка её не двигает.
NeighborEvent? leadingNeighborSignal(Iterable<NeighborEvent> events) {
  NeighborEvent? best;
  for (final event in events) {
    if (!event.showsSignal) continue;
    if (best == null) {
      best = event;
      continue;
    }
    final byAttention = event.attention.index.compareTo(best.attention.index);
    if (byAttention < 0 ||
        (byAttention == 0 && event.id.compareTo(best.id) < 0)) {
      best = event;
    }
  }
  return best;
}

int unseenNeighborCount(Iterable<NeighborEvent> events, Set<String> seenIds) {
  var count = 0;
  for (final event in events) {
    if (event.practice || !event.incoming) continue;
    if (seenIds.contains(event.id)) continue;
    count++;
  }
  return count;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
