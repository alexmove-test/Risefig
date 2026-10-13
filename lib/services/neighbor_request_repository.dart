import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/neighbor_request.dart';
import '../models/neighbor_social.dart';
import '../models/seed_catalog.dart';
import '../models/social_connection.dart';
import 'display_name_filter.dart';
import 'firebase_bootstrap.dart';
import 'guest_name.dart';
import 'player_profile_store.dart';

class NeighborIdentity {
  const NeighborIdentity(this.id, this.name);

  final String id;
  final String name;
}

enum NeighborRequestProblem { unavailable, alreadyOpen, closed }

class NeighborRequestRejected implements Exception {
  const NeighborRequestRejected(this.problem);

  final NeighborRequestProblem problem;
}

/// Заявки между игроками. Успех возвращается только после чтения с сервера.
abstract class NeighborRequestRepository {
  /// null — сети или Firebase нет, кнопки действий не показываются.
  Future<NeighborIdentity?> connect();

  Future<List<NeighborRequest>> fetch(NeighborIdentity me);

  Future<NeighborRequest> send(
    NeighborIdentity me, {
    required NeighborPerson to,
    required NeighborRequestKind kind,
    required NeighborPhrase phrase,
    int? power,
    SeedSpecies? species,
  });

  Future<NeighborRequest> respond(
    NeighborIdentity me,
    NeighborRequest request, {
    required bool accept,
    NeighborPhrase? phrase,
    int? power,
    SeedSpecies? species,
  });

  Future<NeighborRequest> cancel(NeighborIdentity me, NeighborRequest request);

  /// Ответ на набег выбранным защитником. При поражении — что сгорело и что ушло.
  Future<NeighborRequest> defendRaid(
    NeighborIdentity me,
    NeighborRequest request, {
    required RaidDefenseOption defense,
    required RaidLoss loss,
    NeighborPhrase? phrase,
  });

  /// Отметка «семя забрано» или «добыча набега разобрана» на сервере.
  /// Сами растения меняет хранилище по ключу заявки.
  Future<NeighborRequest> markClaimed(
    NeighborIdentity me,
    NeighborRequest request,
  );
}

class FirebaseNeighborRequestRepository implements NeighborRequestRepository {
  static const collection = 'neighbor_requests';
  static const _limit = 50;
  static const _timeout = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> get _requests =>
      FirebaseFirestore.instance.collection(collection);

  @override
  Future<NeighborIdentity?> connect() async {
    if (!FirebaseBootstrap.enabled) return null;
    try {
      final user = await FirebaseBootstrap.ensureSignedIn().timeout(_timeout);
      if (user == null) return null;
      final profile = await PlayerProfileStore.open();
      return NeighborIdentity(user.uid, _publicName(profile.displayName));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<NeighborRequest>> fetch(NeighborIdentity me) async {
    final results = await Future.wait([
      _requests.where('toId', isEqualTo: me.id).limit(_limit).get(),
      _requests.where('fromId', isEqualTo: me.id).limit(_limit).get(),
    ]).timeout(_timeout);
    final byId = <String, NeighborRequest>{};
    for (final snapshot in results) {
      for (final doc in snapshot.docs) {
        final request = _decode(doc);
        if (request != null) byId[request.id] = request;
      }
    }
    final list = byId.values.toList()
      ..sort((a, b) {
        final at = a.respondedAt ?? a.createdAt;
        final bt = b.respondedAt ?? b.createdAt;
        final byTime = bt.compareTo(at);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    return list;
  }

  @override
  Future<NeighborRequest> send(
    NeighborIdentity me, {
    required NeighborPerson to,
    required NeighborRequestKind kind,
    required NeighborPhrase phrase,
    int? power,
    SeedSpecies? species,
  }) async {
    if (to.practice || to.id == me.id) {
      throw const NeighborRequestRejected(NeighborRequestProblem.closed);
    }
    final ref = _requests.doc(NeighborRequest.idFor(me.id, to.id, kind));
    await FirebaseFirestore.instance.runTransaction<void>(
      (transaction) async {
        final previous = await transaction.get(ref);
        final old = previous.exists ? _decode(previous) : null;
        if (old != null && old.blocksResend(DateTime.now())) {
          throw const NeighborRequestRejected(
            NeighborRequestProblem.alreadyOpen,
          );
        }
        if (old != null && old.accepted) {
          final preserved = previous.data();
          if (preserved != null) {
            transaction.set(
              FirebaseFirestore.instance
                  .collection('neighbor_history')
                  .doc(old.opId),
              _historyRecord(old, preserved),
            );
          }
        }
        transaction.set(ref, {
          'fromId': me.id,
          'fromName': _publicName(me.name),
          'toId': to.id,
          'toName': _publicName(to.name),
          'kind': kind.name,
          'phrase': phrase.name,
          'status': NeighborRequestStatus.pending.name,
          'createdAt': FieldValue.serverTimestamp(),
          if (kind == NeighborRequestKind.defense ||
              kind == NeighborRequestKind.raid)
            'power': power ?? 0,
          if (kind == NeighborRequestKind.cross) 'species': species?.name,
        });
      },
      timeout: _timeout,
      maxAttempts: 2,
    );
    return _confirm(ref);
  }

  @override
  Future<NeighborRequest> respond(
    NeighborIdentity me,
    NeighborRequest request, {
    required bool accept,
    NeighborPhrase? phrase,
    int? power,
    SeedSpecies? species,
  }) async {
    final ref = _requests.doc(request.id);
    await FirebaseFirestore.instance.runTransaction<void>(
      (transaction) async {
        final currentDoc = await transaction.get(ref);
        final current = _decode(currentDoc);
        if (current == null ||
            current.toId != me.id ||
            !current.pending ||
            current.kind == NeighborRequestKind.raid) {
          throw const NeighborRequestRejected(NeighborRequestProblem.closed);
        }
        final update = <String, Object>{
          'status':
              (accept
                      ? NeighborRequestStatus.accepted
                      : NeighborRequestStatus.declined)
                  .name,
          'respondedAt': FieldValue.serverTimestamp(),
          'replyPhrase': ?phrase?.name,
        };
        if (accept && current.kind == NeighborRequestKind.cross) {
          final mine = species;
          final theirs = current.species;
          if (mine == null || theirs == null) {
            throw const NeighborRequestRejected(NeighborRequestProblem.closed);
          }
          update['replySpecies'] = mine.name;
          update['resultSpecies'] = resolveNeighborCross(
            opId: current.opId,
            first: theirs,
            second: mine,
          ).name;
        }
        transaction.update(ref, update);
        if (accept) {
          final data = currentDoc.data();
          if (data != null) {
            transaction.set(
              FirebaseFirestore.instance
                  .collection('neighbor_history')
                  .doc(current.opId),
              _historyRecord(current, {...data, ...update}),
            );
          }
        }
      },
      timeout: _timeout,
      maxAttempts: 2,
    );
    return _confirm(ref);
  }

  @override
  Future<NeighborRequest> cancel(
    NeighborIdentity me,
    NeighborRequest request,
  ) async {
    final ref = _requests.doc(request.id);
    await FirebaseFirestore.instance.runTransaction<void>(
      (transaction) async {
        final current = _decode(await transaction.get(ref));
        if (current == null || current.fromId != me.id || !current.pending) {
          throw const NeighborRequestRejected(NeighborRequestProblem.closed);
        }
        transaction.update(ref, {
          'status': NeighborRequestStatus.cancelled.name,
          'respondedAt': FieldValue.serverTimestamp(),
        });
      },
      timeout: _timeout,
      maxAttempts: 2,
    );
    return _confirm(ref);
  }

  @override
  Future<NeighborRequest> defendRaid(
    NeighborIdentity me,
    NeighborRequest request, {
    required RaidDefenseOption defense,
    required RaidLoss loss,
    NeighborPhrase? phrase,
  }) async {
    final ref = _requests.doc(request.id);
    await FirebaseFirestore.instance.runTransaction<void>(
      (transaction) async {
        final currentDoc = await transaction.get(ref);
        final current = _decode(currentDoc);
        if (current == null ||
            current.toId != me.id ||
            !current.pending ||
            current.kind != NeighborRequestKind.raid ||
            current.opId != request.opId) {
          throw const NeighborRequestRejected(NeighborRequestProblem.closed);
        }
        final held = defense.holds(current.power ?? 0);
        final stolen = held ? null : loss.stolen;
        final lost = held ? null : loss.destroyed;
        final update = <String, Object>{
          'status': NeighborRequestStatus.accepted.name,
          'respondedAt': FieldValue.serverTimestamp(),
          'replyPhrase': ?phrase?.name,
          'replyPower': defense.power,
          'defenseSource': defense.source.name,
          'defenderPet': ?defense.pet?.name,
          'defenderId': ?defense.helperId,
          if (defense.helperName != null)
            'defenderName': _publicName(defense.helperName!),
          'lostSpecies': ?lost?.species.name,
          'stolenSpecies': ?stolen?.species.name,
          'stolenTrait': ?stolen?.trait?.name,
        };
        transaction.update(ref, update);
        final data = currentDoc.data();
        if (data != null) {
          transaction.set(
            FirebaseFirestore.instance
                .collection('neighbor_history')
                .doc(current.opId),
            _historyRecord(current, {...data, ...update}),
          );
        }
      },
      timeout: _timeout,
      maxAttempts: 2,
    );
    return _confirm(ref);
  }

  @override
  Future<NeighborRequest> markClaimed(
    NeighborIdentity me,
    NeighborRequest request,
  ) async {
    final ref = _requests.doc(request.id);
    await FirebaseFirestore.instance.runTransaction<void>(
      (transaction) async {
        final current = _decode(await transaction.get(ref));
        if (current == null ||
            current.opId != request.opId ||
            !current.accepted ||
            (current.kind != NeighborRequestKind.cross &&
                current.kind != NeighborRequestKind.raid)) {
          throw const NeighborRequestRejected(NeighborRequestProblem.closed);
        }
        if (current.claimedBy(me.id)) return;
        transaction.update(ref, {
          current.fromId == me.id ? 'fromClaimed' : 'toClaimed': true,
        });
      },
      timeout: _timeout,
      maxAttempts: 2,
    );
    return _confirm(ref);
  }

  /// The timestamp stays the original server value. A decoded [DateTime] can
  /// lose precision and then fail the rule that history time equals the request.
  static Map<String, Object?> _historyRecord(
    NeighborRequest request,
    Map<String, dynamic> snapshot,
  ) => {
    'members': [request.fromId, request.toId],
    'pairId': Friendship.idFor(request.fromId, request.toId),
    'requestId': request.id,
    'snapshot': snapshot,
    'createdAt': snapshot['createdAt'],
  };

  Future<NeighborRequest> _confirm(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final doc = await ref
        .get(const GetOptions(source: Source.server))
        .timeout(_timeout);
    final request = _decode(doc);
    if (request == null) throw StateError('Request was not confirmed');
    return request;
  }

  static String _publicName(String name) =>
      DisplayNameFilter.publicName(GuestName.clamp(name));

  static NeighborRequest? _decode(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;
    return NeighborRequest.fromMap(doc.id, {
      for (final entry in data.entries)
        entry.key: switch (entry.value) {
          final Timestamp stamp => stamp.toDate(),
          final other => other,
        },
    });
  }
}
