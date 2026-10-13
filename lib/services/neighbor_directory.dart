import '../models/neighbor_social.dart';

/// Постраничный источник игроков. Реализация не должна подменять людей вымыслом.
abstract class NeighborDirectory {
  Future<NeighborPage> load({String? pageToken, String query = ''});
}

/// Каталог в памяти для проверок. Сохраняет исходный порядок и не сортирует его заново.
class MemoryNeighborDirectory implements NeighborDirectory {
  MemoryNeighborDirectory(
    this.people, {
    this.pageSize = 20,
    this.fail = false,
    List<NeighborPerson>? cache,
  }) : cache = cache ?? const [];

  final List<NeighborPerson> people;
  final int pageSize;
  bool fail;
  List<NeighborPerson> cache;

  @override
  Future<NeighborPage> load({String? pageToken, String query = ''}) async {
    final source = fail ? cache : people;
    final filtered = _filter(source, query);
    final start = int.tryParse(pageToken ?? '') ?? 0;
    if (fail && filtered.isEmpty) return NeighborPage.emptyOffline;
    if (start < 0 || start > filtered.length) {
      return NeighborPage(
        people: const [],
        hasMore: false,
        online: !fail,
        failed: fail,
        fromCache: fail,
      );
    }
    final slice = filtered.skip(start).take(pageSize).toList(growable: false);
    final next = start + slice.length;
    final hasMore = !fail && next < filtered.length;
    if (!fail && query.trim().isEmpty && pageToken == null) {
      cache = List<NeighborPerson>.of(people);
    }
    return NeighborPage(
      people: slice,
      hasMore: hasMore,
      pageToken: hasMore ? '$next' : null,
      online: !fail,
      fromCache: fail && slice.isNotEmpty,
      failed: fail,
    );
  }
}

List<NeighborPerson> filterNeighborPeople(
  List<NeighborPerson> people,
  String query, {
  Set<String> blockedIds = const {},
}) {
  return _filter(people, query, blockedIds: blockedIds);
}

List<NeighborPerson> _filter(
  List<NeighborPerson> people,
  String query, {
  Set<String> blockedIds = const {},
}) {
  final prefix = query.trim().toLowerCase();
  return [
    for (final person in people)
      if (!person.practice &&
          !blockedIds.contains(person.id) &&
          (prefix.isEmpty || person.name.toLowerCase().startsWith(prefix)))
        person,
  ];
}
