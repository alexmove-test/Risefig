import 'pet.dart';

/// Роль задаётся видом и живёт в каталоге, а не в сохранении питомца.
enum PetRole { attacker, defender }

/// Числа развития. Виджеты читают готовые значения, не формулы.
abstract final class PetCombatRules {
  static const maxLevel = 20;
  static const minLevel = 1;

  /// Стоимость перехода с уровня L на L + 1: 20 × L.
  static const xpFactor = 20;
  static const basePower = 10;
  static const powerPerLevel = 5;

  static PetRole roleOf(PetKind kind) => switch (kind) {
    PetKind.cat || PetKind.fox || PetKind.raccoon => PetRole.attacker,
    PetKind.dog || PetKind.hamster => PetRole.defender,
  };

  /// Опыт одного перехода. На максимальном уровне следующего порога нет.
  static int xpToAdvance(int level) {
    if (level < minLevel || level >= maxLevel) return 0;
    return xpFactor * level;
  }

  /// Сила растёт только с уровнем, а уровень — только от корма.
  static int baseStrength(int level) {
    final clamped = level.clamp(minLevel, maxLevel);
    return basePower + powerPerLevel * (clamped - 1);
  }
}

/// Уровень и остаток опыта до следующего перехода. Итоговая сила здесь не хранится.
class PetLevelProgress {
  const PetLevelProgress._({required this.level, required this.xp});

  final int level;
  final int xp;

  factory PetLevelProgress.of(int level, int xp) {
    var nextLevel = level.clamp(
      PetCombatRules.minLevel,
      PetCombatRules.maxLevel,
    );
    var nextXp = xp < 0 ? 0 : xp;
    if (nextLevel >= PetCombatRules.maxLevel) {
      return const PetLevelProgress._(level: PetCombatRules.maxLevel, xp: 0);
    }
    while (nextLevel < PetCombatRules.maxLevel) {
      final need = PetCombatRules.xpToAdvance(nextLevel);
      if (need <= 0 || nextXp < need) break;
      nextXp -= need;
      nextLevel += 1;
    }
    if (nextLevel >= PetCombatRules.maxLevel) {
      return const PetLevelProgress._(level: PetCombatRules.maxLevel, xp: 0);
    }
    return PetLevelProgress._(level: nextLevel, xp: nextXp);
  }

  bool get maxed => level >= PetCombatRules.maxLevel;

  int get xpForNext => PetCombatRules.xpToAdvance(level);

  double get fraction {
    if (maxed || xpForNext <= 0) return 1;
    final value = xp / xpForNext;
    if (value <= 0) return 0;
    if (value >= 1) return 1;
    return value;
  }

  /// Одно начисление может закрыть несколько уровней. Остаток остаётся.
  /// На максимуме опыт не копится и сила от него не растёт.
  PetLevelProgress gain(int amount) {
    if (maxed || amount <= 0) {
      if (maxed) {
        return const PetLevelProgress._(level: PetCombatRules.maxLevel, xp: 0);
      }
      return this;
    }
    return PetLevelProgress.of(level, xp + amount);
  }
}

class PetStrength {
  const PetStrength(this.total);

  final int total;

  static PetStrength of({required int level}) {
    return PetStrength(PetCombatRules.baseStrength(level));
  }
}

class FeedPreview {
  const FeedPreview({
    required this.xpGain,
    required this.before,
    required this.after,
    required this.beforeStrength,
    required this.afterStrength,
    required this.restoresHunger,
    required this.pointless,
  });

  final int xpGain;
  final PetLevelProgress before;
  final PetLevelProgress after;
  final PetStrength beforeStrength;
  final PetStrength afterStrength;
  final bool restoresHunger;
  final bool pointless;

  bool get leveled => after.level != before.level;

  bool get strengthChanged => afterStrength.total != beforeStrength.total;
}

/// Опыт равен корму класса растения, пока питомец не достиг максимума.
FeedPreview previewFeed({
  required int level,
  required int xp,
  required int plantPower,
  required double hunger,
}) {
  final before = PetLevelProgress.of(level, xp);
  final restoresHunger = hunger < 1;
  final pointless = before.maxed && !restoresHunger;
  final gain = before.maxed ? 0 : plantPower;
  final after = pointless ? before : before.gain(gain);
  return FeedPreview(
    xpGain: gain,
    before: before,
    after: after,
    beforeStrength: PetStrength.of(level: before.level),
    afterStrength: PetStrength.of(level: after.level),
    restoresHunger: restoresHunger,
    pointless: pointless,
  );
}
