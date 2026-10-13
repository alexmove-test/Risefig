import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_bootstrap.dart';
import 'local_reminder_service.dart';

/// Restarts in-memory game state after account data has been erased.
abstract final class AppRestart {
  static Future<void> Function()? afterDataDeletion;

  static Future<void> notify() async {
    final action = afterDataDeletion;
    if (action != null) await action();
  }
}

/// Deletes the signed-in anonymous account, its server records, and this device.
class AccountDeletion {
  const AccountDeletion({
    this.signedIn = firebaseSignedIn,
    this.eraseOnline = FirebaseAccountErasure.deleteSignedIn,
    this.eraseLocal = clearDevice,
    this.deleteAuthentication = deleteAuthUser,
    this.signOut = firebaseSignOut,
    this.cancelReminders = LocalReminderService.cancelAll,
  });

  final bool Function() signedIn;
  final Future<void> Function() eraseOnline;
  final Future<void> Function() eraseLocal;
  final Future<void> Function() deleteAuthentication;
  final Future<void> Function() signOut;
  final Future<void> Function() cancelReminders;

  /// Online records go first. If Authentication refuses deletion, the device
  /// signs out so the same ID cannot write those records again.
  Future<void> run() async {
    if (signedIn()) {
      await eraseOnline();
      try {
        await deleteAuthentication();
      } catch (_) {
        await signOut();
      }
    }
    await eraseLocal();
    await cancelReminders();
  }

  static bool firebaseSignedIn() =>
      FirebaseBootstrap.enabled && FirebaseAuth.instance.currentUser != null;

  static Future<void> clearDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> deleteAuthUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.delete();
  }

  static Future<void> firebaseSignOut() => FirebaseAuth.instance.signOut();
}

/// Firestore deletes for the current user. Security rules allow only that user.
abstract final class FirebaseAccountErasure {
  static Future<void> deleteSignedIn() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final db = FirebaseFirestore.instance;

    await _deleteQuery(
      db.collectionGroup('offers').where('helperId', isEqualTo: uid),
    );
    final calls = await db
        .collection('raid_help')
        .where('ownerId', isEqualTo: uid)
        .get();
    for (final call in calls.docs) {
      await _deleteQuery(call.reference.collection('offers'));
      await call.reference.delete();
    }

    final friends = await db
        .collection('friendships')
        .where('members', arrayContains: uid)
        .get();
    for (final friend in friends.docs) {
      await _deleteQuery(friend.reference.collection('messages'));
      await friend.reference.delete();
    }

    await _deleteQuery(
      db.collection('neighbor_requests').where('fromId', isEqualTo: uid),
    );
    await _deleteQuery(
      db.collection('neighbor_requests').where('toId', isEqualTo: uid),
    );
    await _deleteQuery(
      db.collection('neighbor_history').where('members', arrayContains: uid),
    );
    await _deleteQuery(
      db.collection('plant_showcase').where('ownerId', isEqualTo: uid),
    );
    await _deleteQuery(
      db.collection('message_reports').where('reporterUid', isEqualTo: uid),
    );
    await _deleteQuery(
      db.collection('ugc_reports').where('reporterUid', isEqualTo: uid),
    );

    final blocks = db.collection('social_blocks').doc(uid).collection('players');
    await _deleteQuery(blocks);
    await db.collection('social_blocks').doc(uid).delete();
    await db.collection('social_profiles').doc(uid).delete();
    await db.collection(leaderboardCollection).doc(uid).delete();
  }

  static const leaderboardCollection = 'leaderboard';

  static Future<void> _deleteQuery(Query<Map<String, dynamic>> query) async {
    while (true) {
      final snapshot = await query.limit(400).get();
      if (snapshot.docs.isEmpty) return;
      final batch = FirebaseFirestore.instance.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
      if (snapshot.docs.length < 400) return;
    }
  }
}
