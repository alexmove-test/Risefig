import 'neighbor_social.dart';

/// Small, voluntary public profile. No location or presence is inferred.
///
/// [about], [interests] and [goal] are indexes into the picture lists below.
/// Zero means the player left that row empty. [language] stays zero: the
/// profile does not ask for or show a language. Older free-text values are
/// ignored so they are not shown.
class SocialProfile {
  const SocialProfile({
    this.about = 0,
    this.language = 0,
    this.interests = 0,
    this.goal = 0,
    this.avatar = 0,
    this.openToFriends = true,
  });

  final int about, language, interests, goal;
  final int avatar;
  final bool openToFriends;
  static const avatars = ['🌱', '🌸', '🐱', '🐶', '🦊', '🌳'];
  static const aboutPictures = ['😊', '😌', '😄', '🌸', '🌙', '🤓'];
  static const interestPictures = ['🌿', '🐾', '🀄', '🏡', '🌱', '⭐'];
  static const goalPictures = ['🪷', '🏠', '🤝', '🏆', '💬', '🌼'];

  Map<String, Object> toMap() => {
    'about': about,
    'language': language,
    'interests': interests,
    'goal': goal,
    'avatar': avatar,
    'openToFriends': openToFriends,
  };

  factory SocialProfile.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const SocialProfile();
    final avatar = data['avatar'];
    return SocialProfile(
      about: _choice(data['about'], aboutPictures.length),
      language: _choice(data['language'], 5),
      interests: _choice(data['interests'], interestPictures.length),
      goal: _choice(data['goal'], goalPictures.length),
      avatar: avatar is num && avatar >= 0 && avatar < avatars.length
          ? avatar.toInt()
          : 0,
      openToFriends: data['openToFriends'] != false,
    );
  }

  static int _choice(Object? value, int count) {
    if (value is! num) return 0;
    final index = value.toInt();
    if (value != index || index < 0 || index > count) return 0;
    return index;
  }
}

enum FriendshipStatus { pending, accepted, declined, cancelled, removed }

class Friendship {
  const Friendship({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.status,
  });
  final String id, fromId, fromName, toId, toName;
  final FriendshipStatus status;

  static String idFor(String first, String second) {
    final ids = [first, second]..sort();
    return ids.join('__');
  }

  bool includes(String id) => fromId == id || toId == id;
  bool get accepted => status == FriendshipStatus.accepted;
  bool get pending => status == FriendshipStatus.pending;
  String otherId(String me) => fromId == me ? toId : fromId;
  String otherName(String me) => fromId == me ? toName : fromName;
  NeighborPerson person(String me) => NeighborPerson(
    id: otherId(me),
    name: otherName(me),
    stars: 0,
    levelsUnlocked: 0,
    progressKnown: false,
  );

  static Friendship? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null ||
        data['fromId'] is! String ||
        data['toId'] is! String ||
        data['fromName'] is! String ||
        data['toName'] is! String) {
      return null;
    }
    final statuses = FriendshipStatus.values.where(
      (s) => s.name == data['status'],
    );
    if (statuses.isEmpty ||
        data['fromId'] == data['toId'] ||
        id != idFor(data['fromId'], data['toId'])) {
      return null;
    }
    return Friendship(
      id: id,
      fromId: data['fromId'],
      fromName: data['fromName'],
      toId: data['toId'],
      toName: data['toName'],
      status: statuses.first,
    );
  }
}

class SocialMessage {
  const SocialMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });
  final String id, senderId, text;
  final DateTime? sentAt;
}
