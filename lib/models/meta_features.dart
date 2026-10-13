/// Части мета-игры, которые новичок видит не сразу.
enum MetaFeature {
  house,
  points,
  garden,
  warehouse,
  seeds,
  cross,
  neighbors,
  showcase,
  leaderboard,
  pets,
}

/// Когда фича появляется на хабе (без I/O).
abstract final class MetaFeatures {
  MetaFeatures._();

  /// Сколько уровней кампании нужно пройти, чтобы фича открылась.
  /// Огород, склад, соседи и общий рейтинг видны с первого экрана: прятать
  /// их за уровнями оставляло лужайку пустой и убирало кнопку рейтинга.
  static int unlockAfter(MetaFeature feature) => switch (feature) {
    MetaFeature.pets ||
    MetaFeature.garden ||
    MetaFeature.warehouse ||
    MetaFeature.neighbors ||
    MetaFeature.leaderboard => 0,
    MetaFeature.house || MetaFeature.points => 1,
    MetaFeature.seeds || MetaFeature.cross => 5,
    MetaFeature.showcase => 8,
  };

  /// Пройдено уровней при [maxUnlocked]: старые сейвы сразу видят всё.
  static int clearedFrom(int maxUnlocked) =>
      maxUnlocked < 1 ? 0 : maxUnlocked - 1;

  static bool isOpen(MetaFeature feature, int cleared) =>
      cleared >= unlockAfter(feature);

  /// Порядок, в котором фичи открываются; первая из группы называет группу.
  static const unlockOrder = [
    MetaFeature.house,
    MetaFeature.garden,
    MetaFeature.warehouse,
    MetaFeature.neighbors,
  ];

  /// Ближайшая закрытая фича и сколько уровней до неё.
  static ({MetaFeature feature, int remaining})? nextLocked(int cleared) {
    for (final feature in unlockOrder) {
      final need = unlockAfter(feature);
      if (cleared < need) return (feature: feature, remaining: need - cleared);
    }
    return null;
  }
}
