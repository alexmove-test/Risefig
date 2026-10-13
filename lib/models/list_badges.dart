import 'social_connection.dart';

/// Сколько дней показа и за сколько поинтов.
class ListBadgeOffer {
  const ListBadgeOffer({required this.days, required this.price});

  final int days;
  final int price;

  Duration get duration => Duration(days: days);
}

/// Аватар и значки профиля рядом с именем в списке соседей. Видны до [until].
///
/// Копия выбора из [SocialProfile] на момент покупки или сохранения профиля.
class ListBadges {
  const ListBadges({
    this.avatar = 0,
    this.about = 0,
    this.interests = 0,
    this.goal = 0,
    required this.until,
  });

  factory ListBadges.of(SocialProfile profile, DateTime until) => ListBadges(
    avatar: profile.avatar,
    about: profile.about,
    interests: profile.interests,
    goal: profile.goal,
    until: until,
  );

  final int avatar, about, interests, goal;
  final DateTime until;

  static const offers = [
    ListBadgeOffer(days: 1, price: 100),
    ListBadgeOffer(days: 3, price: 250),
    ListBadgeOffer(days: 7, price: 500),
  ];

  /// Дальше этого срок не продлевается. Правила Firestore держат тот же предел с запасом.
  static const maxAhead = Duration(days: 30);

  bool activeAt(DateTime now) => until.isAfter(now);

  String get avatarPicture => SocialProfile.avatars[avatar];

  /// Выбранные значки по порядку: о себе, интересы, цель. Пустые пропускаются.
  List<String> get pictures => [
    if (about > 0) SocialProfile.aboutPictures[about - 1],
    if (interests > 0) SocialProfile.interestPictures[interests - 1],
    if (goal > 0) SocialProfile.goalPictures[goal - 1],
  ];

  /// Новый конец показа после покупки [offer]. null — срок ушёл бы дальше [maxAhead].
  static DateTime? extend(
    DateTime? current,
    ListBadgeOffer offer,
    DateTime now,
  ) {
    final start = current != null && current.isAfter(now) ? current : now;
    final next = start.add(offer.duration);
    if (next.isAfter(now.add(maxAhead))) return null;
    return next;
  }

  Map<String, Object> toMap() => {
    'avatar': avatar,
    'about': about,
    'interests': interests,
    'goal': goal,
  };

  Map<String, Object> toJson() => {
    ...toMap(),
    'until': until.millisecondsSinceEpoch,
  };

  static ListBadges? fromMap(Object? raw, DateTime? until) {
    if (raw is! Map || until == null) return null;
    final profile = SocialProfile.fromMap(Map<String, dynamic>.from(raw));
    return ListBadges.of(profile, until.toUtc());
  }

  static ListBadges? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final until = raw['until'];
    if (until is! num) return null;
    return fromMap(
      raw,
      DateTime.fromMillisecondsSinceEpoch(until.toInt(), isUtc: true),
    );
  }
}
