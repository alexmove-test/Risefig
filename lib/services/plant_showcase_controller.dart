import 'package:flutter/foundation.dart';

import '../models/garden.dart';
import '../models/plant_listing.dart';
import 'plant_showcase_repository.dart';
import 'points_controller.dart';
import 'ugc_block_store.dart';

enum ShowcaseError { unavailable, load, operation }

/// Coordinates public cards and durable local inventory reservations.
class PlantShowcaseController extends ChangeNotifier {
  PlantShowcaseController({required this.points, required this.repository}) {
    points.addListener(_changed);
  }

  final PointsController points;
  final PlantShowcaseRepository repository;
  ShowcaseIdentity? identity;
  List<PlantListing> items = [];
  Map<String, PlantListing> mine = {};
  Set<String> _blocked = {};
  Object? _cursor;
  bool loading = false;
  bool loadingMore = false;
  bool busy = false;
  bool _disposed = false;
  ShowcaseError? error;

  bool get hasMore => _cursor != null;
  bool get canAct => identity != null && !loading && !loadingMore && !busy;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() async {
    if (loading || loadingMore || busy) return;
    loading = true;
    error = null;
    _changed();
    try {
      final owner = await repository.connect();
      if (_disposed) return;
      identity = owner;
      _blocked = (await UgcBlockStore.open()).blockedIds;
      final own = await repository
          .fetchMine(owner.id)
          .timeout(const Duration(seconds: 20));
      if (_disposed) return;
      for (final item in own) {
        await points.reserveShowcasePlant(item.plantId, owner.id);
      }
      mine = {for (final item in own) item.plantId: item};
      final page = await repository.fetchPage().timeout(
        const Duration(seconds: 20),
      );
      items = page.items
          .where((item) => !_blocked.contains(item.ownerId))
          .toList();
      _cursor = page.cursor;
    } on ShowcaseUnavailable {
      error = ShowcaseError.unavailable;
    } catch (_) {
      error = ShowcaseError.load;
    } finally {
      loading = false;
      _changed();
    }
  }

  Future<void> loadMore() async {
    if (loading || loadingMore || busy || !hasMore) return;
    loadingMore = true;
    error = null;
    _changed();
    try {
      final page = await repository
          .fetchPage(cursor: _cursor)
          .timeout(const Duration(seconds: 20));
      final existing = items.map((item) => item.id).toSet();
      items = [
        ...items,
        ...page.items.where(
          (item) =>
              !existing.contains(item.id) && !_blocked.contains(item.ownerId),
        ),
      ];
      _cursor = page.cursor;
    } catch (_) {
      error = ShowcaseError.load;
    } finally {
      loadingMore = false;
      _changed();
    }
  }

  Future<bool> publish(HarvestedPlant plant) async {
    final owner = identity;
    if (!canAct || owner == null) return false;
    busy = true;
    error = null;
    _changed();
    try {
      if (!await points.reserveShowcasePlant(plant.id, owner.id)) {
        throw StateError('Plant no longer available');
      }
      final item = await repository.publish(owner, plant);
      mine[plant.id] = item;
      items = [item, ...items.where((other) => other.id != item.id)];
      return true;
    } catch (_) {
      // A lost response can hide a successful commit. Keep the lock until
      // an idempotent retry or a server-confirmed withdrawal resolves it.
      error = ShowcaseError.operation;
      return false;
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<bool> remove(String plantId) async {
    final owner = identity;
    if (!canAct || owner == null) return false;
    final lockedBy = points.showcaseReservations[plantId];
    if (lockedBy != null && lockedBy != owner.id) {
      error = ShowcaseError.operation;
      _changed();
      return false;
    }
    busy = true;
    error = null;
    _changed();
    try {
      await repository.remove(owner, plantId);
      if (!await points.releaseShowcasePlant(plantId, owner.id)) {
        throw StateError('Could not save withdrawal');
      }
      mine.remove(plantId);
      items = items
          .where(
            (item) => !(item.ownerId == owner.id && item.plantId == plantId),
          )
          .toList();
      return true;
    } catch (_) {
      error = ShowcaseError.operation;
      return false;
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<void> hideOwner(String ownerId) async {
    try {
      final store = await UgcBlockStore.open();
      await store.block(ownerId);
      _blocked = {..._blocked, ownerId};
      items = items.where((item) => item.ownerId != ownerId).toList();
    } catch (_) {
      error = ShowcaseError.operation;
    }
    _changed();
  }

  @override
  void dispose() {
    _disposed = true;
    points.removeListener(_changed);
    super.dispose();
  }
}
