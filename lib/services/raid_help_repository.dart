import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/neighbor_request.dart';
import '../models/pet.dart';
import '../models/raid_help.dart';
import 'display_name_filter.dart';
import 'guest_name.dart';
import 'neighbor_request_repository.dart';

/// Зов о помощи против набега и отклики защитников на него.
abstract class RaidHelpRepository {
  /// Открывает зов или расширяет его с друзей на всех игроков.
  Future<void> call(
    NeighborIdentity me,
    NeighborRequest raid, {
    required RaidHelpAudience audience,
    required List<String> friendIds,
  });

  /// Свой зов и пришедшие на него защитники.
  Future<RaidHelpStatus> status(NeighborRequest raid);

  /// Чужие открытые зовы, которые мне видны.
  Future<List<RaidHelpCall>> open(NeighborIdentity me);

  /// Зовы, на которые я уже отправил защитника.
  Future<Set<String>> answered(NeighborIdentity me, List<RaidHelpCall> calls);

  Future<void> offer(
    NeighborIdentity me,
    RaidHelpCall call, {
    required int power,
    required PetKind pet,
  });
}

class FirebaseRaidHelpRepository implements RaidHelpRepository {
  static const collection = 'raid_help';
  static const _limit = 30;
  static const _timeout = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> get _calls =>
      FirebaseFirestore.instance.collection(collection);

  @override
  Future<void> call(
    NeighborIdentity me,
    NeighborRequest raid, {
    required RaidHelpAudience audience,
    required List<String> friendIds,
  }) async {
    final deadline = raid.raidDeadline;
    if (raid.kind != NeighborRequestKind.raid ||
        raid.toId != me.id ||
        !raid.pending ||
        deadline == null) {
      throw const NeighborRequestRejected(NeighborRequestProblem.closed);
    }
    final raidRef = FirebaseFirestore.instance
        .collection(FirebaseNeighborRequestRepository.collection)
        .doc(raid.id);
    final viewers = [
      for (final id in friendIds.toSet())
        if (id != me.id && id != raid.fromId) id,
    ].take(NeighborRequestRules.helpMaxViewers).toList();
    await FirebaseFirestore.instance.runTransaction<void>(
      (transaction) async {
        final raidDoc = await transaction.get(raidRef);
        final raidData = raidDoc.data();
        final createdAt = raidData?['createdAt'];
        if (raidData == null ||
            raidData['status'] != NeighborRequestStatus.pending.name ||
            createdAt is! Timestamp) {
          throw const NeighborRequestRejected(NeighborRequestProblem.closed);
        }
        final raidMs = createdAt.millisecondsSinceEpoch;
        transaction.set(_calls.doc(raid.id), {
          'ownerId': me.id,
          'ownerName': _publicName(me.name),
          'attackerId': raid.fromId,
          'attack': raidData['power'],
          'audience': audience.name,
          'viewers': viewers,
          'raidMs': raidMs,
          'expiresAt': Timestamp.fromMillisecondsSinceEpoch(
            raidMs + NeighborRequestRules.raidAnswerWindow.inMilliseconds,
          ),
          'createdAt': FieldValue.serverTimestamp(),
        });
      },
      timeout: _timeout,
      maxAttempts: 2,
    );
  }

  @override
  Future<RaidHelpStatus> status(NeighborRequest raid) async {
    final ref = _calls.doc(raid.id);
    final doc = await ref.get().timeout(_timeout);
    final call = _decodeCall(doc);
    if (call == null ||
        call.raidMs != raid.createdAt.millisecondsSinceEpoch) {
      return RaidHelpStatus.none;
    }
    final offers = await ref.collection('offers').get().timeout(_timeout);
    return RaidHelpStatus(
      audience: call.audience,
      offers: [
        for (final item in offers.docs)
          if (_decodeOffer(item.data()) case final offer?
              when offer.raidMs == call.raidMs)
            offer,
      ],
    );
  }

  @override
  Future<List<RaidHelpCall>> open(NeighborIdentity me) async {
    final now = Timestamp.now();
    final results = await Future.wait([
      _calls
          .where('viewers', arrayContains: me.id)
          .where('attackerId', isNotEqualTo: me.id)
          .orderBy('attackerId')
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .limit(_limit)
          .get(),
      _calls
          .where('audience', isEqualTo: RaidHelpAudience.everyone.name)
          .where('attackerId', isNotEqualTo: me.id)
          .orderBy('attackerId')
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .limit(_limit)
          .get(),
    ]).timeout(_timeout);
    final byId = <String, RaidHelpCall>{};
    for (final snapshot in results) {
      for (final doc in snapshot.docs) {
        final call = _decodeCall(doc);
        if (call == null ||
            call.ownerId == me.id ||
            call.attackerId == me.id) {
          continue;
        }
        byId[call.raidId] = call;
      }
    }
    return byId.values.toList()
      ..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
  }

  @override
  Future<Set<String>> answered(
    NeighborIdentity me,
    List<RaidHelpCall> calls,
  ) async {
    final docs = await Future.wait([
      for (final call in calls)
        _calls.doc(call.raidId).collection('offers').doc(me.id).get(),
    ]).timeout(_timeout);
    final done = <String>{};
    for (var i = 0; i < calls.length; i++) {
      final offer = _decodeOffer(docs[i].data());
      if (offer != null && offer.raidMs == calls[i].raidMs) {
        done.add(calls[i].raidId);
      }
    }
    return done;
  }

  @override
  Future<void> offer(
    NeighborIdentity me,
    RaidHelpCall call, {
    required int power,
    required PetKind pet,
  }) async {
    await _calls
        .doc(call.raidId)
        .collection('offers')
        .doc(me.id)
        .set({
          'helperId': me.id,
          'helperName': _publicName(me.name),
          'power': power,
          'pet': pet.name,
          'raidMs': call.raidMs,
          'createdAt': FieldValue.serverTimestamp(),
        })
        .timeout(_timeout);
  }

  static String _publicName(String name) =>
      DisplayNameFilter.publicName(GuestName.clamp(name));

  static Map<String, Object?> _dates(Map<String, dynamic> data) => {
    for (final entry in data.entries)
      entry.key: switch (entry.value) {
        final Timestamp stamp => stamp.toDate(),
        final other => other,
      },
  };

  static RaidHelpCall? _decodeCall(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;
    return RaidHelpCall.fromMap(doc.id, _dates(data));
  }

  static RaidHelpOffer? _decodeOffer(Map<String, dynamic>? data) {
    if (data == null) return null;
    return RaidHelpOffer.fromMap(_dates(data));
  }
}
