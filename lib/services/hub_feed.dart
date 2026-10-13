import '../models/garden.dart';
import '../models/hub_event.dart';
import '../models/neighbor_request.dart';

/// Последнее непросмотренное событие двора для плашки над «Продолжить».
abstract final class HubFeed {
  HubFeed._();

  /// Самое свежее из заявок соседей и созревших грядок. Если их нет —
  /// свободная грядка при наличии семян. Иначе null: плашка берёт цель.
  static HubEvent? latest({
    required DateTime now,
    List<NeighborRequest> requests = const [],
    String? me,
    Set<String> seenIds = const {},
    Set<String> blockedIds = const {},
    GardenSnapshot? garden,
    int bedCount = GardenCatalog.bedCount,
    bool hasSeeds = false,
  }) {
    HubEvent? best;

    void consider(HubEvent next) {
      final current = best;
      if (current == null || next.at!.isAfter(current.at!)) best = next;
    }

    if (me != null) {
      for (final request in requests) {
        if (blockedIds.contains(request.otherId(me))) continue;
        if (!request.needsAttention(me)) continue;
        if (seenIds.contains(request.noticeKey)) continue;
        consider(
          HubEvent.neighbor(
            request,
            at: request.respondedAt ?? request.createdAt,
          ),
        );
      }
    }

    int? empty;
    if (garden != null) {
      for (var i = 0; i < bedCount; i++) {
        final bed = garden.bedAt(i);
        if (bed == null) {
          empty ??= i;
        } else if (bed.isReady(now)) {
          consider(
            HubEvent.harvest(bedIndex: i, species: bed.species, at: bed.readyAt),
          );
        }
      }
    }

    if (best != null) return best;
    if (empty != null && hasSeeds) return HubEvent.bedFree(empty);
    return null;
  }

  /// Ближайший момент, когда созреет грядка: тогда плашку надо пересчитать.
  static DateTime? nextRipening(
    GardenSnapshot? garden,
    DateTime now, {
    int bedCount = GardenCatalog.bedCount,
  }) {
    if (garden == null) return null;
    DateTime? next;
    for (var i = 0; i < bedCount; i++) {
      final bed = garden.bedAt(i);
      if (bed == null || bed.isReady(now)) continue;
      if (next == null || bed.readyAt.isBefore(next)) next = bed.readyAt;
    }
    return next;
  }
}
