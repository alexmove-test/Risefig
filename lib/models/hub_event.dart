import 'neighbor_request.dart';
import 'seed_catalog.dart';

/// Что случилось во дворе и ждёт игрока на главном экране.
enum HubEventKind { neighbor, harvestReady, bedFree }

class HubEvent {
  const HubEvent.neighbor(NeighborRequest this.request, {required this.at})
    : kind = HubEventKind.neighbor,
      bedIndex = null,
      species = null;

  const HubEvent.harvest({
    required int this.bedIndex,
    required SeedSpecies this.species,
    required this.at,
  }) : kind = HubEventKind.harvestReady,
       request = null;

  const HubEvent.bedFree(int this.bedIndex)
    : kind = HubEventKind.bedFree,
      at = null,
      request = null,
      species = null;

  final HubEventKind kind;

  /// Когда событие случилось. У свободной грядки момента нет.
  final DateTime? at;
  final NeighborRequest? request;
  final int? bedIndex;
  final SeedSpecies? species;

  @override
  bool operator ==(Object other) {
    return other is HubEvent &&
        other.kind == kind &&
        other.at == at &&
        other.request?.noticeKey == request?.noticeKey &&
        other.bedIndex == bedIndex &&
        other.species == species;
  }

  @override
  int get hashCode =>
      Object.hash(kind, at, request?.noticeKey, bedIndex, species);
}
