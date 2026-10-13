import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/list_badges.dart';
import '../models/neighbor_social.dart';
import '../models/neighbor_request.dart';
import '../models/social_connection.dart';
import 'firebase_leaderboard_repository.dart';
import 'neighbor_request_repository.dart';
import 'player_profile_store.dart';
import 'progress_store.dart';
import 'ugc_block_store.dart';

abstract class SocialRepository {
  Stream<List<NeighborRequest>> watchHistory(String me, String other);
  Stream<List<Friendship>> watchFriends(String me);
  Stream<SocialProfile> watchProfile(String id);
  Future<void> saveProfile(String me, SocialProfile profile);

  /// До какого момента значки видны в списке соседей. null — не покупались.
  Future<DateTime?> loadBadgesUntil(String me);

  /// Профиль и его значки для списка одной записью.
  Future<void> showBadges(String me, SocialProfile profile, DateTime until);

  /// Есть ли строка игрока в рейтинге: значки пишутся только в неё.
  /// Если строки нет, сначала пробует выгрузить прогресс.
  Future<bool> ensureListed(String me);
  Future<void> invite(NeighborIdentity me, NeighborPerson other);
  Future<void> respond(
    String me,
    Friendship friendship,
    FriendshipStatus status,
  );
  Stream<List<SocialMessage>> watchMessages(
    String friendshipId, {
    int limit = 50,
  });
  Future<void> sendMessage(
    String me,
    String friendshipId,
    String messageId,
    String text,
  );
  String newMessageId(String friendshipId);
  Future<void> block(String me, String other);
  Future<void> syncBlocks(String me, Set<String> others);
  Future<void> reportMessage(
    String me,
    Friendship friendship,
    SocialMessage message,
  );
}

class FirebaseSocialRepository implements SocialRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  static const timeout = Duration(seconds: 15);
  @override
  Stream<List<NeighborRequest>> watchHistory(String me, String other) => _db
      .collection('neighbor_history')
      .where('members', arrayContains: me)
      .where('pairId', isEqualTo: Friendship.idFor(me, other))
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (snapshot) => [
          for (final doc in snapshot.docs)
            ?NeighborRequest.fromMap(doc.data()['requestId'] as String, {
              for (final entry
                  in (doc.data()['snapshot'] as Map<String, dynamic>).entries)
                entry.key: entry.value is Timestamp
                    ? (entry.value as Timestamp).toDate()
                    : entry.value,
            }),
        ],
      );
  CollectionReference<Map<String, dynamic>> get _friends =>
      _db.collection('friendships');

  @override
  Stream<List<Friendship>> watchFriends(String me) => _friends
      .where('members', arrayContains: me)
      .snapshots(includeMetadataChanges: true)
      .where((snapshot) => !snapshot.metadata.hasPendingWrites)
      .map(
        (snapshot) => [
          for (final doc in snapshot.docs)
            ?Friendship.fromMap(doc.id, doc.data()),
        ],
      );

  @override
  Stream<SocialProfile> watchProfile(String id) => _db
      .collection('social_profiles')
      .doc(id)
      .snapshots()
      .map((doc) => SocialProfile.fromMap(doc.data()));

  @override
  Future<void> saveProfile(String me, SocialProfile profile) => _db
      .collection('social_profiles')
      .doc(me)
      .set(profile.toMap())
      .timeout(timeout);

  DocumentReference<Map<String, dynamic>> _board(String me) =>
      _db.collection(FirebaseLeaderboardRepository.collection).doc(me);

  @override
  Future<DateTime?> loadBadgesUntil(String me) async {
    final doc = await _board(me).get().timeout(timeout);
    final until = doc.data()?['badgesUntil'];
    return until is Timestamp ? until.toDate().toUtc() : null;
  }

  @override
  Future<void> showBadges(String me, SocialProfile profile, DateTime until) {
    // update, not set: the leaderboard row must already exist with its rating.
    final batch = _db.batch()
      ..set(_db.collection('social_profiles').doc(me), profile.toMap())
      ..update(_board(me), {
        'badges': ListBadges.of(profile, until).toMap(),
        'badgesUntil': Timestamp.fromDate(until),
      });
    return batch.commit().timeout(timeout);
  }

  @override
  Future<bool> ensureListed(String me) async {
    final doc = await _board(me).get().timeout(timeout);
    if (doc.exists) return true;
    await FirebaseLeaderboardRepository.syncProgress(
      progress: await ProgressStore.open(),
      profile: await PlayerProfileStore.open(),
    ).timeout(timeout);
    final again = await _board(me).get().timeout(timeout);
    return again.exists;
  }

  @override
  Future<void> invite(NeighborIdentity me, NeighborPerson other) async {
    if (other.practice || other.id == me.id) {
      throw StateError('Invalid recipient');
    }
    final ref = _friends.doc(Friendship.idFor(me.id, other.id));
    await _db.runTransaction((tx) async {
      final previous = await tx.get(ref);
      final old = Friendship.fromMap(ref.id, previous.data());
      // Reciprocal invitations never silently count as consent.
      if (old != null && (old.pending || old.accepted)) {
        throw StateError('Already connected');
      }
      tx.set(ref, {
        'members': [me.id, other.id]..sort(),
        'fromId': me.id,
        'fromName': me.name,
        'toId': other.id,
        'toName': other.name,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }, timeout: timeout);
  }

  @override
  Future<void> respond(
    String me,
    Friendship friendship,
    FriendshipStatus status,
  ) async {
    final ref = _friends.doc(friendship.id);
    await _db.runTransaction((tx) async {
      final current = Friendship.fromMap(ref.id, (await tx.get(ref)).data());
      if (current == null ||
          !current.includes(me) ||
          current.status != friendship.status) {
        throw StateError('Connection changed');
      }
      tx.update(ref, {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }, timeout: timeout);
  }

  @override
  Stream<List<SocialMessage>> watchMessages(
    String friendshipId, {
    int limit = 50,
  }) => _friends
      .doc(friendshipId)
      .collection('messages')
      .orderBy('sentAt', descending: true)
      .limit(limit)
      .snapshots(includeMetadataChanges: true)
      .where((snapshot) => !snapshot.metadata.hasPendingWrites)
      .map(
        (snapshot) => [
          for (final doc in snapshot.docs)
            SocialMessage(
              id: doc.id,
              senderId: doc.data()['senderId'] as String,
              text: doc.data()['text'] as String,
              sentAt: (doc.data()['sentAt'] as Timestamp?)?.toDate(),
            ),
        ],
      );

  @override
  String newMessageId(String friendshipId) =>
      _friends.doc(friendshipId).collection('messages').doc().id;

  @override
  Future<void> sendMessage(
    String me,
    String friendshipId,
    String messageId,
    String text,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > 1000) {
      throw ArgumentError('Invalid message');
    }
    final ref = _friends
        .doc(friendshipId)
        .collection('messages')
        .doc(messageId);
    // Stable id makes retry after an ambiguous network error safe.
    await _db.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) {
        if (existing.data()?['senderId'] != me ||
            existing.data()?['text'] != trimmed) {
          throw StateError('Message id reused');
        }
        return;
      }
      tx.set(ref, {
        'senderId': me,
        'text': trimmed,
        'sentAt': FieldValue.serverTimestamp(),
      });
    }, timeout: timeout);
  }

  @override
  Future<void> block(String me, String other) async {
    if (me == other) throw ArgumentError('Cannot block self');
    await _db
        .collection('social_blocks')
        .doc(me)
        .collection('players')
        .doc(other)
        .set({'createdAt': FieldValue.serverTimestamp()})
        .timeout(timeout);
    await (await UgcBlockStore.open()).block(other);
  }

  @override
  Future<void> syncBlocks(String me, Set<String> others) async {
    // Both directions: preserve blocks on another device and upload legacy local blocks.
    final collection = _db
        .collection('social_blocks')
        .doc(me)
        .collection('players');
    final snapshot = await collection
        .get(const GetOptions(source: Source.server))
        .timeout(timeout);
    final remote = snapshot.docs.map((d) => d.id).toSet();
    final local = await UgcBlockStore.open();
    for (final id in remote) {
      await local.block(id);
    }
    for (final id in others.difference(remote)) {
      if (id != me) await block(me, id);
    }
  }

  @override
  Future<void> reportMessage(
    String me,
    Friendship friendship,
    SocialMessage message,
  ) async {
    if (message.senderId == me) throw ArgumentError('Own message');
    await _db
        .collection('message_reports')
        .add({
          'reporterUid': me,
          'targetUid': message.senderId,
          'friendshipId': friendship.id,
          'messageId': message.id,
          'createdAt': FieldValue.serverTimestamp(),
        })
        .timeout(timeout);
  }
}
