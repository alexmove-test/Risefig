import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/neighbor_social.dart';

/// Личный список для повторного взаимодействия. Это не взаимная дружба.
class AcquaintanceStore {
  AcquaintanceStore._(this._prefs);

  final SharedPreferences _prefs;

  static const storageKey = 'neighbors.acquaintances';

  static Future<AcquaintanceStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return AcquaintanceStore._(prefs);
  }

  List<NeighborPerson> get all {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded) ?NeighborPerson.fromJson(item),
      ];
    } catch (_) {
      return const [];
    }
  }

  bool contains(String id) => all.any((person) => person.id == id);

  /// Возвращает false, если запись уже есть или это учебный персонаж.
  Future<bool> add(NeighborPerson person) async {
    if (person.practice || person.id.trim().isEmpty) return false;
    final current = all;
    if (current.any((item) => item.id == person.id)) return false;
    final next = [person, ...current];
    await _write(next);
    return true;
  }

  Future<void> remove(String id) async {
    final next = [
      for (final person in all)
        if (person.id != id) person,
    ];
    await _write(next);
  }

  Future<void> _write(List<NeighborPerson> people) async {
    await _prefs.setString(
      storageKey,
      jsonEncode([for (final person in people) person.toJson()]),
    );
  }
}

/// Просмотренные входящие и уже отправленные благодарности.
class NeighborNoticeStore {
  NeighborNoticeStore._(this._prefs);

  final SharedPreferences _prefs;

  static const seenKey = 'neighbors.seenEventIds';
  static const thankedKey = 'neighbors.thankedEventIds';
  static const _cap = 1000;

  static Future<NeighborNoticeStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return NeighborNoticeStore._(prefs);
  }

  Set<String> get seenIds => _prefs.getStringList(seenKey)?.toSet() ?? const {};

  Set<String> get thankedIds =>
      _prefs.getStringList(thankedKey)?.toSet() ?? const {};

  bool hasSeen(String id) => seenIds.contains(id);

  bool hasThanked(String id) => thankedIds.contains(id);

  Future<void> markSeen(Iterable<String> ids) async {
    final next = {...seenIds, ...ids.where((id) => id.isNotEmpty)};
    await _prefs.setStringList(seenKey, _capped(next));
  }

  Future<void> markThanked(String id) async {
    if (id.isEmpty) return;
    final next = {...thankedIds, id};
    await _prefs.setStringList(thankedKey, _capped(next));
  }

  List<String> _capped(Set<String> ids) {
    final list = ids.toList()..sort();
    if (list.length <= _cap) return list;
    return list.sublist(list.length - _cap);
  }
}

/// Подтверждённые совместные действия. Запись появляется только после источника.
class NeighborHistoryStore {
  NeighborHistoryStore._(this._prefs);

  final SharedPreferences _prefs;

  static const storageKey = 'neighbors.history';
  static const _cap = 50;

  static Future<NeighborHistoryStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return NeighborHistoryStore._(prefs);
  }

  List<NeighborMemory> get all {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded) ?NeighborMemory.fromJson(item),
      ];
    } catch (_) {
      return const [];
    }
  }

  List<NeighborMemory> forPerson(String personId) => [
    for (final memory in all)
      if (memory.personId == personId) memory,
  ];

  Future<void> add(NeighborMemory memory) async {
    if (memory.personId.isEmpty || memory.id.isEmpty) return;
    final current = all;
    if (current.any((item) => item.id == memory.id)) return;
    final next = [memory, ...current];
    final capped = next.length <= _cap ? next : next.sublist(0, _cap);
    await _prefs.setString(
      storageKey,
      jsonEncode([for (final item in capped) item.toJson()]),
    );
  }
}

/// Последние успешно загруженные страницы каталога для показа без сети.
class NeighborDirectoryCache {
  NeighborDirectoryCache._(this._prefs);

  final SharedPreferences _prefs;

  static const storageKey = 'neighbors.directoryCache';

  static Future<NeighborDirectoryCache> open() async {
    final prefs = await SharedPreferences.getInstance();
    return NeighborDirectoryCache._(prefs);
  }

  List<NeighborPerson> get people {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded) ?NeighborPerson.fromJson(item),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> remember(
    List<NeighborPerson> page, {
    required bool append,
  }) async {
    final base = append ? people : const <NeighborPerson>[];
    final seen = {for (final person in base) person.id};
    final next = [...base];
    for (final person in page) {
      if (person.practice || person.id.isEmpty || !seen.add(person.id)) {
        continue;
      }
      next.add(person);
    }
    await _prefs.setString(
      storageKey,
      jsonEncode([for (final person in next) person.toJson()]),
    );
  }
}
