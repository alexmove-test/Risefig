import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/leaderboard_entry.dart';
import '../models/list_badges.dart';
import '../models/neighbor_social.dart';
import '../services/firebase_bootstrap.dart';
import '../services/firebase_leaderboard_repository.dart';
import '../services/neighbor_directory.dart';
import '../services/neighbor_records.dart';
import '../services/player_profile_store.dart';
import '../services/progress_store.dart';
import '../services/ugc_block_store.dart';

/// Страницы общего рейтинга. Поиск — префикс сохранённого имени, как его умеет Firestore.
class FirebaseNeighborDirectory implements NeighborDirectory {
  FirebaseNeighborDirectory({this.progress});

  final ProgressStore? Function()? progress;

  static const pageSize = 20;

  final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> _cursors = {};
  var _token = 0;

  FirebaseFirestore? get _db =>
      FirebaseBootstrap.enabled ? FirebaseFirestore.instance : null;

  @override
  Future<NeighborPage> load({String? pageToken, String query = ''}) async {
    final blocked = (await UgcBlockStore.open()).blockedIds;
    final trimmed = query.trim();
    try {
      final db = _db;
      if (db == null) return _offline(trimmed, blocked);
      final user = await FirebaseBootstrap.ensureSignedIn();
      if (user == null) return _offline(trimmed, blocked);
      if (pageToken == null && trimmed.isEmpty) {
        await _syncQuietly();
      }

      Query<Map<String, dynamic>> request = db.collection(
        FirebaseLeaderboardRepository.collection,
      );
      if (trimmed.isEmpty) {
        request = request.orderBy('rating', descending: true);
      } else {
        request = request.orderBy('name').startAt([trimmed]).endAt([
          '$trimmed\uf8ff',
        ]);
      }
      request = request.limit(pageSize);
      final cursor = pageToken == null ? null : _cursors[pageToken];
      if (pageToken != null && cursor == null) {
        return const NeighborPage(people: [], hasMore: false, online: true);
      }
      if (cursor != null) request = request.startAfterDocument(cursor);

      final snapshot = await request.get();
      final people = <NeighborPerson>[];
      String? next;
      for (final doc in snapshot.docs) {
        final entry = FirebaseLeaderboardRepository.entryFromDoc(
          doc,
          currentUid: user.uid,
        );
        if (entry.isCurrentPlayer || blocked.contains(entry.id)) continue;
        people.add(_person(entry, doc.data()));
        final token = 'n${_token++}';
        _cursors[token] = doc;
        next = token;
      }
      final hasMore = snapshot.docs.length == pageSize;
      if (trimmed.isEmpty) {
        final cache = await NeighborDirectoryCache.open();
        await cache.remember(people, append: pageToken != null);
      }
      return NeighborPage(
        people: people,
        hasMore: hasMore,
        pageToken: hasMore ? next : null,
        online: true,
      );
    } catch (error) {
      debugPrint('Neighbor directory failed: $error');
      if (pageToken != null) {
        return const NeighborPage(
          people: [],
          hasMore: false,
          online: false,
          failed: true,
        );
      }
      return _offline(trimmed, blocked);
    }
  }

  Future<void> _syncQuietly() async {
    final store = progress?.call();
    if (store == null) return;
    final profile = await PlayerProfileStore.open();
    await FirebaseLeaderboardRepository.syncProgress(
      progress: store,
      profile: profile,
    );
  }

  Future<NeighborPage> _offline(String query, Set<String> blocked) async {
    final cache = await NeighborDirectoryCache.open();
    final people = filterNeighborPeople(
      cache.people,
      query,
      blockedIds: blocked,
    );
    return NeighborPage(
      people: people,
      hasMore: false,
      online: false,
      fromCache: people.isNotEmpty,
      failed: true,
    );
  }
}

NeighborPerson _person(LeaderboardEntry entry, Map<String, dynamic> data) {
  final until = data['badgesUntil'];
  return NeighborPerson(
    id: entry.id,
    name: entry.name,
    stars: entry.totalStars,
    levelsUnlocked: entry.levelsUnlocked,
    rating: entry.rating,
    badges: ListBadges.fromMap(
      data['badges'],
      until is Timestamp ? until.toDate() : null,
    ),
  );
}
