import 'meta_features.dart';
import 'plot_kind.dart';
import 'weekly_quests.dart';

/// Один ближайший шаг мета-игры на главном экране.
enum HubGoalKind {
  questClaim,
  dailyReward,
  featureUnlock,
  questRemain,
  plotUnlock,
  petUnlock,
  plotLook,
}

class HubGoal {
  const HubGoal({
    required this.kind,
    required this.remaining,
    this.plot,
    this.levelId,
    this.quest,
    this.pointsCost,
    this.pointsShort,
    this.feature,
  });

  final HubGoalKind kind;
  final int remaining;
  final PlotKind? plot;
  final int? levelId;
  final QuestProgress? quest;

  /// Цена следующего облика дома и сколько поинтов не хватает.
  final int? pointsCost;
  final int? pointsShort;

  /// Какая часть мета-игры откроется через [remaining] уровней.
  final MetaFeature? feature;

  int get _priority => switch (kind) {
    HubGoalKind.questClaim => 0,
    HubGoalKind.dailyReward => 1,
    HubGoalKind.featureUnlock => 2,
    HubGoalKind.questRemain => 3,
    HubGoalKind.plotUnlock => 4,
    HubGoalKind.petUnlock => 5,
    HubGoalKind.plotLook => 6,
  };

  bool nearerThan(HubGoal other) {
    if (remaining != other.remaining) return remaining < other.remaining;
    return _priority < other._priority;
  }

  @override
  bool operator ==(Object other) {
    return other is HubGoal &&
        other.kind == kind &&
        other.remaining == remaining &&
        other.plot == plot &&
        other.levelId == levelId &&
        other.quest?.def.id == quest?.def.id &&
        other.pointsCost == pointsCost &&
        other.pointsShort == pointsShort &&
        other.feature == feature;
  }

  @override
  int get hashCode => Object.hash(
    kind,
    remaining,
    plot,
    levelId,
    quest?.def.id,
    pointsCost,
    pointsShort,
    feature,
  );
}
