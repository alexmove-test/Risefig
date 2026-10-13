import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/l10n/app_localizations.dart';
import 'package:mahjong/models/list_badges.dart';
import 'package:mahjong/models/neighbor_request.dart';
import 'package:mahjong/models/neighbor_social.dart';
import 'package:mahjong/models/social_connection.dart';
import 'package:mahjong/services/neighbor_actions.dart';
import 'package:mahjong/services/neighbor_directory.dart';
import 'package:mahjong/services/neighbor_records.dart';
import 'package:mahjong/services/neighbor_request_repository.dart';
import 'package:mahjong/services/points_controller.dart';
import 'package:mahjong/services/points_store.dart';
import 'package:mahjong/services/social_repository.dart';
import 'package:mahjong/services/ugc_block_store.dart';
import 'package:mahjong/widgets/neighbors/neighbors_panel.dart';
import 'package:mahjong/widgets/neighbors/social_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const anna = NeighborPerson(
  id: 'anna',
  name: 'Анна',
  stars: 12,
  levelsUnlocked: 8,
);
const friend = Friendship(
  id: 'anna__me',
  fromId: 'anna',
  fromName: 'Анна',
  toId: 'me',
  toName: 'Я',
  status: FriendshipStatus.accepted,
);
const pending = Friendship(
  id: 'anna__me',
  fromId: 'anna',
  fromName: 'Анна',
  toId: 'me',
  toName: 'Я',
  status: FriendshipStatus.pending,
);

class FakeSocial implements SocialRepository {
  List<Friendship> links = [];
  final changes = StreamController<List<Friendship>>.broadcast();
  bool failSend = false, failProfile = false;
  final sentIds = <String>[];
  FriendshipStatus? response;
  @override
  Stream<List<Friendship>> watchFriends(String me) async* {
    yield links;
    yield* changes.stream;
  }

  @override
  Stream<SocialProfile> watchProfile(String id) => failProfile
      ? Stream.error(StateError('offline'))
      : Stream.value(
          const SocialProfile(
            about: 1,
            language: 2,
            interests: 1,
            goal: 1,
            avatar: 1,
          ),
        );
  @override
  Stream<List<NeighborRequest>> watchHistory(String me, String other) =>
      Stream.value([]);
  SocialProfile? saved;
  @override
  Future<void> saveProfile(String me, SocialProfile profile) async {
    saved = profile;
  }

  DateTime? badgesUntil;
  bool failBadges = false, listed = true;
  @override
  Future<bool> ensureListed(String me) async => listed;
  @override
  Future<DateTime?> loadBadgesUntil(String me) async => badgesUntil;
  @override
  Future<void> showBadges(
    String me,
    SocialProfile profile,
    DateTime until,
  ) async {
    if (failBadges) throw StateError('offline');
    saved = profile;
    badgesUntil = until;
  }

  @override
  Future<void> invite(NeighborIdentity me, NeighborPerson other) async {}
  @override
  Future<void> respond(String me, Friendship f, FriendshipStatus status) async {
    response = status;
  }

  @override
  Stream<List<SocialMessage>> watchMessages(String id, {int limit = 50}) =>
      Stream.value([]);
  @override
  String newMessageId(String id) => 'message-${sentIds.length}';
  @override
  Future<void> sendMessage(
    String me,
    String id,
    String messageId,
    String text,
  ) async {
    sentIds.add(messageId);
    if (failSend) throw StateError('offline');
  }

  @override
  Future<void> block(String me, String other) async {}
  @override
  Future<void> syncBlocks(String me, Set<String> others) async {}
  @override
  Future<void> reportMessage(
    String me,
    Friendship f,
    SocialMessage message,
  ) async {}
}

class FakeRequests implements NeighborRequestRepository {
  @override
  Future<NeighborIdentity?> connect() async =>
      const NeighborIdentity('me', 'Я');
  @override
  Future<List<NeighborRequest>> fetch(NeighborIdentity me) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget app(Widget child) => MaterialApp(
  locale: const Locale('ru'),
  theme: ThemeData(
    fontFamily: const bool.fromEnvironment('SOCIAL_PREVIEW')
        ? 'SocialPreview'
        : null,
  ),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() async {
    if (!const bool.fromEnvironment('SOCIAL_PREVIEW')) return;
    final fonts = FontLoader('SocialPreview')
      ..addFont(
        File(
          r'C:\Windows\Fonts\arial.ttf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await fonts.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  test('profile pictures ignore free text and out-of-range indexes', () {
    final legacy = SocialProfile.fromMap({
      'about': 'Люблю выращивать цветы',
      'language': 'Русский',
      'interests': 1.0,
      'goal': 99,
      'avatar': 1,
    });
    expect(legacy.about, 0);
    expect(legacy.language, 0);
    expect(legacy.interests, 1);
    expect(legacy.goal, 0);
    expect(legacy.toMap()['about'], 0);
  });

  test('picture labels stay paired with the stored indexes', () {
    for (final code in ['en', 'ru', 'uk', 'de', 'th']) {
      final l = lookupAppLocalizations(Locale(code));
      expect(
        socialAboutOptions(l).map((option) => option.picture),
        SocialProfile.aboutPictures,
      );
      expect(
        socialInterestOptions(l).map((option) => option.picture),
        SocialProfile.interestPictures,
      );
      expect(
        socialGoalOptions(l).map((option) => option.picture),
        SocialProfile.goalPictures,
      );
      for (final option in [
        ...socialAboutOptions(l),
        ...socialInterestOptions(l),
        ...socialGoalOptions(l),
      ]) {
        expect(option.label.trim(), isNotEmpty);
      }
    }
  });

  test('friendship key is symmetric and malformed records are rejected', () {
    expect(Friendship.idFor('anna', 'me'), Friendship.idFor('me', 'anna'));
    expect(
      Friendship.fromMap('wrong', {
        'fromId': 'anna',
        'toId': 'me',
        'fromName': 'A',
        'toName': 'M',
        'status': 'accepted',
      }),
      isNull,
    );
  });

  testWidgets(
    'bookmarks never become friends; a confirmed friend opens from its own tab',
    (tester) async {
      final social = FakeSocial();
      addTearDown(social.changes.close);
      final saved = await AcquaintanceStore.open();
      await saved.add(anna);
      final boundary = GlobalKey();
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        app(
          RepaintBoundary(
            key: boundary,
            child: NeighborsOverlay(
              visible: true,
              directory: MemoryNeighborDirectory([anna]),
              acquaintances: saved,
              notices: await NeighborNoticeStore.open(),
              history: await NeighborHistoryStore.open(),
              blocks: await UgcBlockStore.open(),
              gateway: const UnavailableNeighborGateway(),
              requests: FakeRequests(),
              social: social,
              onClose: () {},
              onObscuring: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('neighbors-tab-friends')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friend-anna__me')), findsNothing);
      expect(find.textContaining('Пока нет друзей'), findsOneWidget);
      social.links = [friend];
      social.changes.add(social.links);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friend-anna__me')), findsOneWidget);
      if (const bool.fromEnvironment('SOCIAL_PREVIEW')) {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'build/social-friends-preview.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.byKey(const ValueKey('friend-anna__me')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friend-chat')), findsOneWidget);
      expect(find.text('Дружелюбный'), findsOneWidget);
      expect(find.text('Русский'), findsNothing);
      expect(find.text('Языки общения'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'incoming invitation explains consent and does not expose chat before acceptance',
    (tester) async {
      final social = FakeSocial();
      addTearDown(social.changes.close);
      await tester.pumpWidget(
        app(
          SingleChildScrollView(
            child: SocialPersonSection(
              repository: social,
              me: const NeighborIdentity('me', 'Я'),
              person: anna,
              friendship: pending,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friend-chat')), findsNothing);
      expect(find.textContaining('разрешает вам обоим'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('friend-accept')));
      await tester.pumpAndSettle();
      expect(social.response, FriendshipStatus.accepted);
      expect(find.byKey(const ValueKey('friend-chat')), findsNothing);
    },
  );

  testWidgets('failed message preserves text and retry uses the same id', (
    tester,
  ) async {
    final social = FakeSocial()..failSend = true;
    addTearDown(social.changes.close);
    await tester.pumpWidget(
      app(SocialChatScreen(repository: social, me: 'me', friendship: friend)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('social-message-input')),
      'Спасибо за цветок!',
    );
    await tester.tap(find.byKey(const ValueKey('social-message-send')));
    await tester.pumpAndSettle();
    expect(find.text('Спасибо за цветок!'), findsOneWidget);
    social.failSend = false;
    await tester.tap(find.byKey(const ValueKey('social-message-send')));
    await tester.pumpAndSettle();
    expect(social.sentIds, ['message-0', 'message-0']);
    expect(find.text('Спасибо за цветок!'), findsNothing);
  });

  testWidgets(
    'failed profile load cannot overwrite existing data with empty fields',
    (tester) async {
      final social = FakeSocial()..failProfile = true;
      addTearDown(social.changes.close);
      await tester.pumpWidget(
        app(SocialProfileEditor(repository: social, me: 'me')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Сохранить профиль'), findsNothing);
      expect(find.textContaining('Не удалось подключиться'), findsOneWidget);
    },
  );

  testWidgets('profile editor saves a picture and can clear it', (
    tester,
  ) async {
    final social = FakeSocial();
    addTearDown(social.changes.close);
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      app(SocialProfileEditor(repository: social, me: 'me')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const ValueKey('profile-about-1')));
    await tester.tap(find.byKey(const ValueKey('profile-goal-3')));
    await tester.tap(find.text('Сохранить профиль'));
    await tester.pumpAndSettle();
    expect(social.saved?.about, 0);
    expect(social.saved?.goal, 3);
    expect(social.saved?.language, 0);
  });

  testWidgets('a neighbor profile lists every field, chosen or not', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SocialProfileView(
          profile: SocialProfile(avatar: 2, interests: 2, openToFriends: false),
        ),
      ),
    );
    expect(find.text(SocialProfile.avatars[2]), findsOneWidget);
    expect(find.text('О себе'), findsOneWidget);
    expect(find.text('Интересы'), findsOneWidget);
    expect(find.text('Что ищу в игре'), findsOneWidget);
    expect(find.text('Питомцы'), findsOneWidget);
    expect(find.text('Не выбрано'), findsNWidgets(2));
    expect(find.textContaining('не принимает приглашения'), findsOneWidget);
  });

  group('paid badges in the neighbor list', () {
    final now = DateTime.utc(2026, 10, 9, 12);
    const day = ListBadgeOffer(days: 1, price: 100);
    const week = ListBadgeOffer(days: 7, price: 500);

    test('a purchase stacks on the remaining time but not past the cap', () {
      expect(
        ListBadges.extend(null, day, now),
        now.add(const Duration(days: 1)),
      );
      final running = now.add(const Duration(days: 2));
      expect(
        ListBadges.extend(running, day, now),
        now.add(const Duration(days: 3)),
      );
      final expired = now.subtract(const Duration(days: 2));
      expect(ListBadges.extend(expired, day, now), now.add(day.duration));
      expect(
        ListBadges.extend(now.add(const Duration(days: 24)), week, now),
        isNull,
      );
    });

    test('badges survive the device cache and skip empty rows', () {
      final badges = ListBadges(
        avatar: 2,
        about: 1,
        goal: 3,
        until: now.add(const Duration(days: 1)),
      );
      final person = NeighborPerson.fromJson(
        NeighborPerson(
          id: 'anna',
          name: 'Анна',
          stars: 1,
          levelsUnlocked: 2,
          badges: badges,
        ).toJson(),
      )!;
      expect(person.badges!.until, badges.until);
      expect(person.badges!.avatarPicture, SocialProfile.avatars[2]);
      expect(person.badges!.pictures, [
        SocialProfile.aboutPictures[0],
        SocialProfile.goalPictures[2],
      ]);
      expect(person.badges!.activeAt(badges.until), isFalse);
    });

    Future<PointsController> wallet(int balance) async {
      SharedPreferences.setMockInitialValues({
        'points.balance': balance,
        'points.earned': balance,
        'points.houseMigrated': true,
      });
      return PointsController(await PointsStore.open());
    }

    Future<void> openEditor(
      WidgetTester tester,
      FakeSocial social,
      PointsController points,
    ) async {
      await tester.binding.setSurfaceSize(const Size(900, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        PointsScope(
          controller: points,
          child: app(SocialProfileEditor(repository: social, me: 'me')),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('buying a day charges points and publishes the badges', (
      tester,
    ) async {
      final social = FakeSocial();
      addTearDown(social.changes.close);
      final points = await wallet(300);
      await openEditor(tester, social, points);
      expect(find.text('Сейчас в списке видно только имя.'), findsOneWidget);

      final before = DateTime.now();
      await tester.tap(find.byKey(const ValueKey('profile-badges-1')));
      await tester.pumpAndSettle();
      expect(points.balance, 200);
      expect(social.saved?.avatar, 1);
      final until = social.badgesUntil!;
      expect(
        until.difference(before).inMinutes,
        inInclusiveRange(24 * 60 - 1, 24 * 60 + 1),
      );
      expect(find.textContaining('Видны соседям до'), findsWidgets);
    });

    testWidgets('a failed publish returns the points', (tester) async {
      final social = FakeSocial()..failBadges = true;
      addTearDown(social.changes.close);
      final points = await wallet(300);
      await openEditor(tester, social, points);
      await tester.tap(find.byKey(const ValueKey('profile-badges-3')));
      await tester.pumpAndSettle();
      expect(points.balance, 300);
      expect(social.badgesUntil, isNull);
      expect(find.textContaining('Поинты возвращены'), findsOneWidget);
    });

    testWidgets('a player missing from the leaderboard is not charged', (
      tester,
    ) async {
      final social = FakeSocial()..listed = false;
      addTearDown(social.changes.close);
      final points = await wallet(300);
      await openEditor(tester, social, points);
      await tester.tap(find.byKey(const ValueKey('profile-badges-1')));
      await tester.pumpAndSettle();
      expect(points.balance, 300);
      expect(social.badgesUntil, isNull);
      expect(find.textContaining('Поинты не списаны'), findsOneWidget);
    });

    testWidgets('not enough points leaves the wallet and the list alone', (
      tester,
    ) async {
      final social = FakeSocial();
      addTearDown(social.changes.close);
      final points = await wallet(50);
      await openEditor(tester, social, points);
      await tester.tap(find.byKey(const ValueKey('profile-badges-1')));
      await tester.pumpAndSettle();
      expect(points.balance, 50);
      expect(social.badgesUntil, isNull);
      expect(find.text('Не хватает 50 поинтов'), findsOneWidget);
    });

    testWidgets('the list shows only badges that are still paid for', (
      tester,
    ) async {
      final social = FakeSocial();
      addTearDown(social.changes.close);
      final live = DateTime.now().add(const Duration(days: 1));
      final gone = DateTime.now().subtract(const Duration(minutes: 1));
      await tester.pumpWidget(
        app(
          NeighborsOverlay(
            visible: true,
            directory: MemoryNeighborDirectory([
              NeighborPerson(
                id: 'anna',
                name: 'Анна',
                stars: 3,
                levelsUnlocked: 2,
                badges: ListBadges(avatar: 2, interests: 3, until: live),
              ),
              NeighborPerson(
                id: 'boris',
                name: 'Борис',
                stars: 3,
                levelsUnlocked: 2,
                badges: ListBadges(avatar: 3, about: 2, until: gone),
              ),
            ]),
            acquaintances: await AcquaintanceStore.open(),
            notices: await NeighborNoticeStore.open(),
            history: await NeighborHistoryStore.open(),
            blocks: await UgcBlockStore.open(),
            gateway: const UnavailableNeighborGateway(),
            onClose: () {},
            onObscuring: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('neighbors-badges-anna')),
        findsOneWidget,
      );
      expect(find.text(SocialProfile.avatars[2]), findsOneWidget);
      expect(
        find.byKey(const ValueKey('neighbors-badges-boris')),
        findsNothing,
      );
      expect(find.text(SocialProfile.avatars[3]), findsNothing);
      expect(find.text('Б'), findsOneWidget);
    });
  });
}
