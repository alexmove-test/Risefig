import 'pet.dart';

/// Кто видит зов о помощи: друзья бесплатно, все игроки — за поинты.
enum RaidHelpAudience { friends, everyone }

/// Зов о помощи против одного набега. Живёт, пока набег ждёт ответа.
class RaidHelpCall {
  const RaidHelpCall({
    required this.raidId,
    required this.ownerId,
    required this.ownerName,
    required this.attackerId,
    required this.attack,
    required this.audience,
    required this.raidMs,
    required this.expiresAt,
  });

  /// Совпадает с id заявки набега.
  final String raidId;
  final String ownerId;
  final String ownerName;
  final String attackerId;
  final int attack;
  final RaidHelpAudience audience;

  /// Время создания набега в миллисекундах. Отличает повторный набег с тем же id.
  final int raidMs;
  final DateTime expiresAt;

  bool open(DateTime now) => now.isBefore(expiresAt);

  static RaidHelpCall? fromMap(String id, Map<String, Object?> data) {
    final ownerId = data['ownerId'];
    final ownerName = data['ownerName'];
    final attackerId = data['attackerId'];
    final attack = data['attack'];
    final audience = switch (data['audience']) {
      'friends' => RaidHelpAudience.friends,
      'everyone' => RaidHelpAudience.everyone,
      _ => null,
    };
    final raidMs = data['raidMs'];
    final expiresAt = data['expiresAt'];
    if (ownerId is! String ||
        ownerName is! String ||
        attackerId is! String ||
        attack is! num ||
        audience == null ||
        raidMs is! num ||
        expiresAt is! DateTime) {
      return null;
    }
    return RaidHelpCall(
      raidId: id,
      ownerId: ownerId,
      ownerName: ownerName,
      attackerId: attackerId,
      attack: attack.toInt(),
      audience: audience,
      raidMs: raidMs.toInt(),
      expiresAt: expiresAt,
    );
  }
}

/// Защитник, которого игрок предложил на чужой набег.
class RaidHelpOffer {
  const RaidHelpOffer({
    required this.helperId,
    required this.helperName,
    required this.power,
    required this.pet,
    required this.raidMs,
  });

  final String helperId;
  final String helperName;
  final int power;
  final PetKind pet;
  final int raidMs;

  static RaidHelpOffer? fromMap(Map<String, Object?> data) {
    final helperId = data['helperId'];
    final helperName = data['helperName'];
    final power = data['power'];
    final raidMs = data['raidMs'];
    PetKind? pet;
    for (final kind in PetKind.values) {
      if (kind.name == data['pet']) pet = kind;
    }
    if (helperId is! String ||
        helperName is! String ||
        power is! num ||
        pet == null ||
        raidMs is! num) {
      return null;
    }
    return RaidHelpOffer(
      helperId: helperId,
      helperName: helperName,
      power: power.toInt(),
      pet: pet,
      raidMs: raidMs.toInt(),
    );
  }
}

/// Что владелец набега знает о своём зове.
class RaidHelpStatus {
  const RaidHelpStatus({this.audience, this.offers = const []});

  static const none = RaidHelpStatus();

  final RaidHelpAudience? audience;
  final List<RaidHelpOffer> offers;
}
