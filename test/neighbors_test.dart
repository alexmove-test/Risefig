import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/l10n/app_localizations.dart';
import 'package:mahjong/models/neighbor_social.dart';
import 'package:mahjong/screens/level_select_screen.dart';
import 'package:mahjong/services/neighbor_actions.dart';
import 'package:mahjong/services/neighbor_directory.dart';
import 'package:mahjong/services/neighbor_records.dart';
import 'package:mahjong/services/ugc_block_store.dart';
import 'package:mahjong/widgets/neighbors/neighbors_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _zoe = NeighborPerson(
  id: 'zoe',
  name: 'Zoe',
  stars: 4,
  levelsUnlocked: 2,
  rating: 10,
);
const _anna = NeighborPerson(
  id: 'anna',
  name: 'Anna',
  stars: 12,
  levelsUnlocked: 8,
  rating: 9,
);
const _practice = NeighborPerson(
  id: 'practice',
  name: 'Practice Garden',
  stars: 1,
  levelsUnlocked: 1,
  practice: true,
);

NeighborEvent _help({
  NeighborPhase phase = NeighborPhase.needsDecision,
  bool incoming = true,
  NeighborAttention attention = NeighborAttention.needsDecision,
  bool practice = false,
  Set<NeighborFollowUp> followUps = const {},
}) {
  return NeighborEvent(
    id: 'help-anna',
    personId: _anna.id,
    personName: _anna.name,
    kind: NeighborKind.help,
    phase: phase,
    signal: NeighborSignal.asksHelp,
    attention: attention,
    incoming: incoming,
    inbox: true,
    practice: practice,
    cost: '1 essence',
    outcome: 'The plant gets help',
    plantName: 'Fern',
    ownerKeepsPlant: true,
    followUps: followUps,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'the leading signal prefers a decision, then a result, and stays stable',
    () {
      final request = _help(
        phase: NeighborPhase.available,
        attention: NeighborAttention.request,
      ).copyWith();
      final decision = NeighborEvent(
        id: 'decision',
        personId: _anna.id,
        personName: _anna.name,
        kind: NeighborKind.help,
        phase: NeighborPhase.needsDecision,
        signal: NeighborSignal.asksHelp,
        attention: NeighborAttention.needsDecision,
        incoming: true,
        inbox: true,
      );
      final result = NeighborEvent(
        id: 'result',
        personId: _anna.id,
        personName: _anna.name,
        kind: NeighborKind.help,
        phase: NeighborPhase.completed,
        signal: NeighborSignal.helpedYou,
        attention: NeighborAttention.result,
        incoming: true,
        inbox: true,
      );
      final ended = result.copyWith(phase: NeighborPhase.expired);

      expect(
        leadingNeighborSignal([request, result, decision])?.id,
        'decision',
      );
      expect(leadingNeighborSignal([request, result])?.id, 'result');
      expect(leadingNeighborSignal([ended]), isNull);
      expect(
        leadingNeighborSignal([
          request.copyWith(),
          NeighborEvent(
            id: 'a-request',
            personId: _anna.id,
            personName: _anna.name,
            kind: NeighborKind.defense,
            phase: NeighborPhase.available,
            signal: NeighborSignal.seeksDefense,
            attention: NeighborAttention.request,
            incoming: true,
          ),
        ])?.id,
        'a-request',
      );
    },
  );

  test('new directory rows and practice events do not raise a notice', () {
    final seen = {'old'};
    final events = [
      _help(),
      _help(incoming: false, phase: NeighborPhase.awaitingReply),
      NeighborEvent(
        id: 'old',
        personId: _zoe.id,
        personName: _zoe.name,
        kind: NeighborKind.help,
        phase: NeighborPhase.needsDecision,
        signal: NeighborSignal.asksHelp,
        attention: NeighborAttention.needsDecision,
        incoming: true,
      ),
      _help(practice: true),
    ];
    expect(unseenNeighborCount(events, seen), 1);
    expect(unseenNeighborCount(const [], seen), 0);
  });

  test(
    'acquaintances are personal, stable, and restored after restart',
    () async {
      final store = await AcquaintanceStore.open();
      expect(await store.add(_practice), isFalse);
      expect(await store.add(_anna), isTrue);
      expect(await store.add(_anna), isFalse);
      expect(await store.add(_zoe), isTrue);
      expect(store.all.map((person) => person.id).toList(), ['zoe', 'anna']);

      final again = await AcquaintanceStore.open();
      expect(again.all.map((person) => person.name).toList(), ['Zoe', 'Anna']);
      await again.remove(_anna.id);
      expect((await AcquaintanceStore.open()).all.single.id, 'zoe');
    },
  );

  test(
    'opening a notice keeps the decision and does not notify twice',
    () async {
      final notices = await NeighborNoticeStore.open();
      expect(notices.hasSeen('help-anna'), isFalse);
      await notices.markSeen(['help-anna']);
      final reopened = await NeighborNoticeStore.open();
      expect(reopened.hasSeen('help-anna'), isTrue);
      expect(unseenNeighborCount([_help()], reopened.seenIds), 0);
      expect(_help().phase, NeighborPhase.needsDecision);
    },
  );

  test('history stores only a confirmed memory and survives restart', () async {
    final history = await NeighborHistoryStore.open();
    const memory = NeighborMemory(
      id: 'm1',
      personId: 'anna',
      personName: 'Anna',
      code: NeighborMemoryCode.helpedPlant,
      atMillis: 5,
    );
    await history.add(memory);
    await history.add(memory);
    expect(history.forPerson('anna').single.id, memory.id);
    expect(history.forPerson('anna'), hasLength(1));
    expect(
      (await NeighborHistoryStore.open()).forPerson('anna').single.code,
      NeighborMemoryCode.helpedPlant,
    );
  });

  test(
    'directory pages keep source order and search matches a name prefix',
    () async {
      final directory = MemoryNeighborDirectory(const [
        _zoe,
        _anna,
        _practice,
      ], pageSize: 1);
      final first = await directory.load();
      final second = await directory.load(pageToken: first.pageToken);
      expect(first.people.single.name, 'Zoe');
      expect(second.people.single.name, 'Anna');
      expect(second.hasMore, isFalse);

      final found = await directory.load(query: 'an');
      expect(found.people.single.name, 'Anna');
      final missing = await directory.load(query: 'zzz');
      expect(missing.people, isEmpty);

      directory.fail = true;
      directory.cache = const [_zoe];
      final offline = await directory.load();
      expect(offline.failed, isTrue);
      expect(offline.fromCache, isTrue);
      expect(offline.people.single.name, 'Zoe');
    },
  );

  test(
    'a live gateway reports failure and does not confirm the action',
    () async {
      const gateway = UnavailableNeighborGateway();
      final result = await gateway.submit(
        NeighborActionRequest(event: _help(), command: NeighborCommand.accept),
      );
      expect(result.confirmed, isFalse);
      expect(result.event.phase, NeighborPhase.failed);
      expect(result.event.reason, NeighborReason.unsupported);
      expect(result.event.plantName, 'Fern');
      expect(result.memory, isNull);
    },
  );

  testWidgets('the panel finds a player, saves them, and keeps list order', (
    tester,
  ) async {
    final gateway = RecordingNeighborGateway();
    await _pumpPanel(
      tester,
      directory: MemoryNeighborDirectory(const [_zoe, _anna]),
      gateway: gateway,
    );

    expect(find.text('Zoe'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Zoe')).dy,
      lessThan(tester.getTopLeft(find.text('Anna')).dy),
    );
    expect(gateway.calls, isEmpty);

    await tester.tap(find.byKey(const ValueKey('neighbors-row-anna')));
    await tester.pump();
    expect(
      find.text('Save this player to find them again in Favorites.'),
      findsOneWidget,
    );
    expect(gateway.calls, isEmpty);

    await tester.tap(find.byKey(const ValueKey('neighbors-add')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Anna is in Favorites.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('neighbors-find-again')));
    await tester.pump();
    expect(find.byKey(const ValueKey('neighbors-row-anna')), findsOneWidget);
    expect((await AcquaintanceStore.open()).contains('anna'), isTrue);

    final state = tester.state<NeighborsOverlayState>(
      find.byType(NeighborsOverlay),
    );
    state.handleBack();
    await tester.pump();
    expect(find.byKey(const ValueKey('neighbors-card')), findsNothing);
    expect((await AcquaintanceStore.open()).contains('anna'), isTrue);
  });

  testWidgets(
    'help confirms once, a failure stays retryable, and a stale offer ends',
    (tester) async {
      final gateway = RecordingNeighborGateway();
      final held = Completer<void>();
      gateway.pause = () => held.future;
      await _pumpPanel(
        tester,
        directory: MemoryNeighborDirectory(const [_anna]),
        events: [_help()],
        gateway: gateway,
      );

      expect(find.byKey(const ValueKey('neighbors-for-you')), findsOneWidget);
      expect(find.text('Asks for help'), findsWidgets);
      final notices = await NeighborNoticeStore.open();
      expect(notices.hasSeen('help-anna'), isFalse);

      await tester.tap(find.byKey(const ValueKey('neighbors-row-anna')));
      await tester.pump();
      expect((await NeighborNoticeStore.open()).hasSeen('help-anna'), isTrue);
      expect(find.textContaining('Fern'), findsWidgets);
      expect(find.text('This plant stays with its owner.'), findsOneWidget);
      expect(gateway.calls, isEmpty);

      await tester.tap(find.byKey(const ValueKey('neighbors-primary')));
      await tester.pump();
      expect(gateway.calls, isEmpty);
      expect(find.text('This uses: 1 essence'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('neighbors-confirm')));
      await tester.pump();
      expect(find.text('Working on it'), findsWidgets);
      expect(find.byKey(const ValueKey('neighbors-confirm')), findsNothing);
      expect(gateway.calls, hasLength(1));
      held.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Finished'), findsWidgets);
      expect(gateway.calls.single.command, NeighborCommand.accept);
    },
  );

  testWidgets('a failed or ended offer does not look successful', (
    tester,
  ) async {
    final gateway = RecordingNeighborGateway(confirm: false);
    await _pumpPanel(
      tester,
      directory: MemoryNeighborDirectory(const [_anna]),
      events: [_help()],
      gateway: gateway,
    );
    await tester.tap(find.byKey(const ValueKey('neighbors-row-anna')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('neighbors-primary')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('neighbors-confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.text('This did not go through. You can try again.'),
      findsWidgets,
    );
    expect(find.text('Finished'), findsNothing);

    gateway
      ..confirm = true
      ..stale = true;
    await tester.tap(find.byKey(const ValueKey('neighbors-retry-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('This offer has ended.'), findsWidgets);
    expect(find.text('Finished'), findsNothing);
  });

  testWidgets(
    'a row never starts an attack, and attack waits for confirmation',
    (tester) async {
      final gateway = RecordingNeighborGateway();
      await _pumpPanel(
        tester,
        directory: MemoryNeighborDirectory(const [_anna]),
        events: [
          NeighborEvent(
            id: 'raid-anna',
            personId: _anna.id,
            personName: _anna.name,
            kind: NeighborKind.raid,
            phase: NeighborPhase.available,
            signal: NeighborSignal.awaitsReply,
            attention: NeighborAttention.request,
            incoming: false,
            attackStrength: 20,
            defenseStrength: 15,
            lootEssence: 2,
          ),
        ],
        gateway: gateway,
      );
      await tester.tap(find.byKey(const ValueKey('neighbors-row-anna')));
      await tester.pump();
      expect(gateway.calls, isEmpty);
      expect(
        find.text('This starts an attack on this player.'),
        findsOneWidget,
      );
      expect(find.text('Attack 20'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('neighbors-attack')));
      await tester.pump();
      expect(gateway.calls, isEmpty);
      await tester.tap(find.byKey(const ValueKey('neighbors-attack-confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(gateway.calls.single.command, NeighborCommand.confirmAttack);
    },
  );

  testWidgets('practice records stay out of the live list', (tester) async {
    await _pumpPanel(
      tester,
      directory: MemoryNeighborDirectory(const [_anna, _practice]),
      events: [_help(practice: true)],
    );
    expect(find.text('Practice Garden'), findsNothing);
    expect(find.text('Anna'), findsOneWidget);
    expect(find.byKey(const ValueKey('neighbors-for-you')), findsNothing);
  });

  testWidgets('empty acquaintances offer the full list, and search can miss', (
    tester,
  ) async {
    await _pumpPanel(tester, directory: MemoryNeighborDirectory(const [_anna]));
    await tester.tap(find.byKey(const ValueKey('neighbors-tab-saved')));
    await tester.pump();
    expect(find.text('People you save for later appear here.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('neighbors-browse')));
    await tester.pump();
    expect(find.text('Anna'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('neighbors-search')),
      'zzz',
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('No name starts with this.'), findsOneWidget);
  });

  testWidgets(
    'a lost connection keeps the previous players and offers a retry',
    (tester) async {
      final directory = MemoryNeighborDirectory(const [_anna]);
      await _pumpPanel(tester, directory: directory);
      expect(find.text('Anna'), findsOneWidget);

      directory.fail = true;
      await tester.enterText(
        find.byKey(const ValueKey('neighbors-search')),
        'an',
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Anna'), findsOneWidget);
      expect(
        find.text('No connection. Previously loaded players stay here.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('large text and a long name do not throw', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpPanel(
      tester,
      directory: MemoryNeighborDirectory(const [
        NeighborPerson(
          id: 'long',
          name: 'Anastasia of the North Garden',
          stars: 3,
          levelsUnlocked: 1,
        ),
      ]),
      textScale: 1.6,
      size: const Size(320, 480),
    );
    expect(find.text('Anastasia of the North Garden'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('thanks can be sent once from a finished result', (tester) async {
    final gateway = RecordingNeighborGateway();
    await _pumpPanel(
      tester,
      directory: MemoryNeighborDirectory(const [_anna]),
      events: [
        _help(
          phase: NeighborPhase.completed,
          attention: NeighborAttention.result,
          followUps: {NeighborFollowUp.thank},
        ),
      ],
      gateway: gateway,
    );
    await tester.tap(find.byKey(const ValueKey('neighbors-row-anna')));
    await tester.pump();
    expect(find.text('Anna helped your plant.'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('neighbors-thank')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(gateway.calls.single.command, NeighborCommand.thank);
    expect(find.text('Thanks sent to Anna.'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('neighbors-thank')));
    await tester.pump();
    expect(gateway.calls, hasLength(1));
    expect(
      (await NeighborHistoryStore.open()).forPerson('anna').single.code,
      NeighborMemoryCode.thanked,
    );
  });

  testWidgets(
    'the yard button opens the panel and the close control leaves it',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'progress.maxUnlocked': 9,
        'progress.stars.1': 1,
        'progress.best.1': 400,
        'progress.lastPlayed': 1,
        'progress.courtyardPanHintDone': true,
      });
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LevelSelectScreen(),
        ),
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byKey(const ValueKey('neighbors-entry')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('neighbors-entry')));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        find.byKey(const ValueKey('feature-intro-neighbors')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('feature-intro-ok')));
      await _pumpUntil(
        tester,
        () =>
            tester
                .getTopLeft(find.byKey(const ValueKey('neighbors-close')))
                .dx <
            800,
      );
      expect(find.text('All players'), findsOneWidget);

      final continueButton = find.widgetWithText(FilledButton, 'Continue');
      final buttonBox = tester.renderObject<RenderBox>(continueButton);
      final hits = tester.hitTestOnBinding(tester.getCenter(continueButton));
      expect(
        hits.path.any((entry) => identical(entry.target, buttonBox)),
        isFalse,
      );

      final openDx = tester
          .getTopLeft(find.byKey(const ValueKey('neighbors-close')))
          .dx;
      await tester.tap(find.byKey(const ValueKey('neighbors-close')));
      await _pumpUntil(
        tester,
        () =>
            tester
                .getTopLeft(find.byKey(const ValueKey('neighbors-close')))
                .dx >
            openDx + 200,
      );
    },
  );
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (done()) return;
  }
  fail('The neighbors panel did not finish moving.');
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required NeighborDirectory directory,
  List<NeighborEvent> events = const [],
  NeighborActionGateway? gateway,
  double textScale = 1,
  Size size = const Size(800, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final acquaintances = await AcquaintanceStore.open();
  final notices = await NeighborNoticeStore.open();
  final history = await NeighborHistoryStore.open();
  final blocks = await UgcBlockStore.open();
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: NeighborsOverlay(
        visible: true,
        directory: directory,
        acquaintances: acquaintances,
        notices: notices,
        history: history,
        blocks: blocks,
        gateway: gateway ?? const UnavailableNeighborGateway(),
        events: events,
        onClose: () {},
        onObscuring: (_) {},
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
