import 'dart:convert';

import 'garden.dart';
import 'pet.dart';
import 'pet_combat.dart';
import 'plant_cross.dart';
import 'seed_batch.dart';

/// Боевой прогресс одного питомца. Итоговая сила каждый раз считается заново.
class PetCombatRecord {
  const PetCombatRecord({
    required this.kind,
    required this.level,
    required this.xp,
  });

  final PetKind kind;
  final int level;
  final int xp;

  static PetCombatRecord fresh(PetKind kind) =>
      PetCombatRecord(kind: kind, level: PetCombatRules.minLevel, xp: 0);

  PetCombatRecord copyWith({int? level, int? xp}) {
    return PetCombatRecord(
      kind: kind,
      level: level ?? this.level,
      xp: xp ?? this.xp,
    );
  }

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'level': level,
    'xp': xp,
  };

  /// Старые поля `main` и `accessory` игнорируются: сила больше не зависит от вещей.
  static PetCombatRecord? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final kind = _kind(raw['kind']);
    final level = raw['level'];
    final xp = raw['xp'];
    if (kind == null || level is! int || xp is! int) return null;
    final progress = PetLevelProgress.of(level, xp);
    return PetCombatRecord(kind: kind, level: progress.level, xp: progress.xp);
  }
}

class PetRosterSnapshot {
  const PetRosterSnapshot({
    required this.records,
    required this.seq,
    this.defender,
    this.raider,
  });

  static const empty = PetRosterSnapshot(records: [], seq: 0);

  final List<PetCombatRecord> records;
  final PetKind? defender;
  final PetKind? raider;
  final int seq;

  PetCombatRecord? recordOf(PetKind kind) {
    for (final record in records) {
      if (record.kind == kind) return record;
    }
    return null;
  }

  /// Назначение защитника, если вид всё ещё защитник.
  PetKind? guarding(List<PetKind> owned) {
    final kind = defender;
    if (kind == null || !owned.contains(kind)) return null;
    if (PetCombatRules.roleOf(kind) != PetRole.defender) return null;
    return kind;
  }

  PetKind? raiding(List<PetKind> owned) {
    final kind = raider;
    if (kind == null || !owned.contains(kind)) return null;
    if (PetCombatRules.roleOf(kind) != PetRole.attacker) return null;
    return kind;
  }

  bool ownsDefenderSpecies(List<PetKind> owned) =>
      owned.any((kind) => PetCombatRules.roleOf(kind) == PetRole.defender);

  PetRosterSnapshot ensureOwned(List<PetKind> owned) {
    final missing = [
      for (final kind in owned)
        if (recordOf(kind) == null) kind,
    ];
    if (missing.isEmpty) return this;
    return copyWith(
      records: [
        ...records,
        for (final kind in missing) PetCombatRecord.fresh(kind),
      ],
    );
  }

  PetRosterSnapshot copyWith({
    List<PetCombatRecord>? records,
    int? seq,
    PetKind? defender,
    PetKind? raider,
    bool clearDefender = false,
    bool clearRaider = false,
  }) {
    return PetRosterSnapshot(
      records: records ?? this.records,
      seq: seq ?? this.seq,
      defender: clearDefender ? null : (defender ?? this.defender),
      raider: clearRaider ? null : (raider ?? this.raider),
    );
  }

  Map<String, Object?> toJson() => {
    'seq': seq,
    'defender': defender?.name,
    'raider': raider?.name,
    'records': [for (final record in records) record.toJson()],
  };

  String encode() => jsonEncode(toJson());

  static PetRosterSnapshot? decode(String raw) {
    try {
      return fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static PetRosterSnapshot? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final seq = raw['seq'];
    if (seq is! int || seq < 0) return null;
    final recordsRaw = raw['records'];
    if (recordsRaw is! List) return null;
    final records = <PetCombatRecord>[];
    final seen = <PetKind>{};
    for (final item in recordsRaw) {
      final record = PetCombatRecord.fromJson(item);
      if (record == null || !seen.add(record.kind)) return null;
      records.add(record);
    }
    var defender = _kindOrNull(raw['defender']);
    var raider = _kindOrNull(raw['raider']);
    if (raw['defender'] != null &&
        defender == null &&
        raw['defender'] is! String) {
      return null;
    }
    if (raw['raider'] != null && raider == null && raw['raider'] is! String) {
      return null;
    }
    if (defender != null &&
        PetCombatRules.roleOf(defender) != PetRole.defender) {
      defender = null;
    }
    if (raider != null && PetCombatRules.roleOf(raider) != PetRole.attacker) {
      raider = null;
    }
    return PetRosterSnapshot(
      records: records,
      seq: seq,
      defender: defender,
      raider: raider,
    );
  }
}

enum FeedStatus {
  fed,
  notOwned,
  missingPlant,
  listed,
  pointless,
  unavailable,
  failed,
}

class FeedResult {
  const FeedResult({
    required this.status,
    required this.balance,
    required this.seeds,
    required this.garden,
    required this.roster,
    this.preview,
    this.plant,
  });

  final FeedStatus status;
  final int balance;
  final SeedSnapshot seeds;
  final GardenSnapshot garden;
  final PetRosterSnapshot roster;
  final FeedPreview? preview;
  final HarvestedPlant? plant;

  bool get fed => status == FeedStatus.fed;

  const FeedResult.unavailable({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
    required PetRosterSnapshot roster,
  }) : this(
         status: FeedStatus.unavailable,
         balance: balance,
         seeds: seeds,
         garden: garden,
         roster: roster,
       );

  const FeedResult.failed({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
    required PetRosterSnapshot roster,
  }) : this(
         status: FeedStatus.failed,
         balance: balance,
         seeds: seeds,
         garden: garden,
         roster: roster,
       );
}

class FeedPlan {
  const FeedPlan({
    required this.status,
    this.garden,
    this.roster,
    this.preview,
    this.plant,
    this.hungerMillis,
  });

  final FeedStatus status;
  final GardenSnapshot? garden;
  final PetRosterSnapshot? roster;
  final FeedPreview? preview;
  final HarvestedPlant? plant;
  final int? hungerMillis;

  bool get fed => status == FeedStatus.fed;
}

FeedPlan planFeed({
  required PetRosterSnapshot roster,
  required GardenSnapshot garden,
  required List<PetKind> owned,
  required PetKind kind,
  required String plantId,
  required double hunger,
  required DateTime now,
}) {
  if (!owned.contains(kind)) {
    return const FeedPlan(status: FeedStatus.notOwned);
  }
  HarvestedPlant? plant;
  for (final item in garden.warehouse) {
    if (item.id == plantId) {
      plant = item;
      break;
    }
  }
  if (plant == null) return const FeedPlan(status: FeedStatus.missingPlant);
  final ready = roster.ensureOwned(owned);
  final record = ready.recordOf(kind);
  if (record == null) return const FeedPlan(status: FeedStatus.notOwned);
  final preview = previewFeed(
    level: record.level,
    xp: record.xp,
    plantPower: feedXp(
      species: plant.species,
      trait: plant.trait,
      role: PetCombatRules.roleOf(kind),
    ),
    hunger: hunger,
  );
  if (preview.pointless) {
    return FeedPlan(
      status: FeedStatus.pointless,
      preview: preview,
      plant: plant,
    );
  }
  final progressed = record.copyWith(
    level: preview.after.level,
    xp: preview.after.xp,
  );
  return FeedPlan(
    status: FeedStatus.fed,
    garden: garden.copyWith(
      warehouse: [
        for (final item in garden.warehouse)
          if (item.id != plant.id) item,
      ],
      seq: garden.seq + 1,
    ),
    roster: ready.copyWith(
      records: [
        for (final item in ready.records)
          if (item.kind == kind) progressed else item,
      ],
      seq: ready.seq + 1,
    ),
    preview: preview,
    plant: plant,
    hungerMillis: now.millisecondsSinceEpoch,
  );
}

enum AssignStatus {
  assigned,
  cleared,
  notOwned,
  wrongRole,
  unavailable,
  failed,
}

class AssignResult {
  const AssignResult({
    required this.status,
    required this.balance,
    required this.seeds,
    required this.garden,
    required this.roster,
  });

  final AssignStatus status;
  final int balance;
  final SeedSnapshot seeds;
  final GardenSnapshot garden;
  final PetRosterSnapshot roster;

  bool get saved =>
      status == AssignStatus.assigned || status == AssignStatus.cleared;

  const AssignResult.unavailable({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
    required PetRosterSnapshot roster,
  }) : this(
         status: AssignStatus.unavailable,
         balance: balance,
         seeds: seeds,
         garden: garden,
         roster: roster,
       );

  const AssignResult.failed({
    required int balance,
    required SeedSnapshot seeds,
    required GardenSnapshot garden,
    required PetRosterSnapshot roster,
  }) : this(
         status: AssignStatus.failed,
         balance: balance,
         seeds: seeds,
         garden: garden,
         roster: roster,
       );
}

class AssignPlan {
  const AssignPlan({required this.status, this.roster});

  final AssignStatus status;
  final PetRosterSnapshot? roster;
}

AssignPlan planAssign({
  required PetRosterSnapshot roster,
  required List<PetKind> owned,
  required PetKind kind,
  required bool active,
}) {
  if (!owned.contains(kind)) {
    return const AssignPlan(status: AssignStatus.notOwned);
  }
  final role = PetCombatRules.roleOf(kind);
  final ready = roster.ensureOwned(owned);
  if (active) {
    return AssignPlan(
      status: AssignStatus.assigned,
      roster: role == PetRole.defender
          ? ready.copyWith(defender: kind)
          : ready.copyWith(raider: kind),
    );
  }
  if (role == PetRole.defender && ready.defender == kind) {
    return AssignPlan(
      status: AssignStatus.cleared,
      roster: ready.copyWith(clearDefender: true),
    );
  }
  if (role == PetRole.attacker && ready.raider == kind) {
    return AssignPlan(
      status: AssignStatus.cleared,
      roster: ready.copyWith(clearRaider: true),
    );
  }
  return AssignPlan(status: AssignStatus.cleared, roster: ready);
}

PetKind? _kind(Object? raw) {
  if (raw is! String) return null;
  for (final kind in PetKind.values) {
    if (kind.name == raw) return kind;
  }
  return null;
}

PetKind? _kindOrNull(Object? raw) {
  if (raw == null) return null;
  return _kind(raw);
}
