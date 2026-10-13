import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/l10n/app_localizations.dart';
import 'package:mahjong/models/garden.dart';
import 'package:mahjong/models/neighbor_request.dart';
import 'package:mahjong/models/neighbor_social.dart';
import 'package:mahjong/models/plant_cross.dart';
import 'package:mahjong/models/seed_batch.dart';
import 'package:mahjong/models/seed_catalog.dart';
import 'package:mahjong/services/neighbor_actions.dart';
import 'package:mahjong/services/neighbor_directory.dart';
import 'package:mahjong/services/neighbor_records.dart';
import 'package:mahjong/services/neighbor_request_repository.dart';
import 'package:mahjong/services/points_store.dart';
import 'package:mahjong/services/ugc_block_store.dart';
import 'package:mahjong/widgets/neighbors/neighbors_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _anna = NeighborPerson(
  id: 'anna',
  name: 'Anna',
  stars: 12,
  levelsUnlocked: 8,
  rating: 9,
);

final _at = DateTime.utc(2026, 10, 8, 9);

NeighborRequest _request({
  String fromId = 'anna',
  String toId = 'me',
  NeighborRequestKind kind = NeighborRequestKind.message,
  NeighborRequestStatus status = NeighborRequestStatus.pending,
  int? power,
  SeedSpecies? species,
  int? replyPower,
  DateTime? respondedAt,
}) {
  return NeighborRequest(
    id: NeighborRequest.idFor(fromId, toId, kind),
    fromId: fromId,
    fromName: fromId == 'me' ? 'Me' : 'Anna',
    toId: toId,
    toName: toId == 'me' ? 'Me' : 'Anna',
    kind: kind,
    phrase: NeighborRequestRules.phrasesFor(kind).first,
    status: status,
    createdAt: _at,
    power: power,
    species: species,
    replyPower: replyPower,
    respondedAt: respondedAt,
  );
}

class _FakeRequests implements NeighborRequestRepository {
  _FakeRequests({this.online = true, List<NeighborRequest>? initial})
    : items = [...?initial];

  static const me = NeighborIdentity('me', 'Me');

  bool online;
  final List<NeighborRequest> items;
  final responses = <({bool accept, int? power, NeighborPhrase? phrase})>[];

  NeighborRequest _put(NeighborRequest request) {
    items.removeWhere((item) => item.id == request.id);
    items.insert(0, request);
    return request;
  }

  @override
  Future<NeighborIdentity?> connect() async => online ? me : null;

  @override
  Future<List<NeighborRequest>> fetch(NeighborIdentity me) async => [...items];

  @override
  Future<NeighborRequest> send(
    NeighborIdentity me, {
    required NeighborPerson to,
    required NeighborRequestKind kind,
    required NeighborPhrase phrase,
    int? power,
    SeedSpecies? species,
  }) async {
    final id = NeighborRequest.idFor(me.id, to.id, kind);
    if (items.any((item) => item.id == id && item.pending)) {
      throw const NeighborRequestRejected(NeighborRequestProblem.alreadyOpen);
    }
    return _put(
      NeighborRequest(
        id: id,
        fromId: me.id,
        fromName: me.name,
        toId: to.id,
        toName: to.name,
        kind: kind,
        phrase: phrase,
        status: NeighborRequestStatus.pending,
        createdAt: _at,
        power: power,
        species: species,
      ),
    );
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
    responses.add((accept: accept, power: power, phrase: phrase));
    return _put(
      request.copyWith(
        status: accept
            ? NeighborRequestStatus.accepted
            : NeighborRequestStatus.declined,
        respondedAt: _at.add(const Duration(minutes: 1)),
        replyPhrase: phrase,
        replyPower: request.kind == NeighborRequestKind.raid ? power : null,
      ),
    );
  }

  @override
  Future<NeighborRequest> cancel(
    NeighborIdentity me,
    NeighborRequest request,
  ) async {
    return _put(
      request.copyWith(
        status: NeighborRequestStatus.cancelled,
        respondedAt: _at.add(const Duration(minutes: 1)),
      ),
    );
  }

  @override
  Future<NeighborRequest> markClaimed(
    NeighborIdentity me,
    NeighborRequest request,
  ) async {
    return _put(
      request.fromId == me.id
          ? request.copyWith(fromClaimed: true)
          : request.copyWith(toClaimed: true),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a raid succeeds only with a strictly stronger attack', () {
    final tie = _request(
      kind: NeighborRequestKind.raid,
      status: NeighborRequestStatus.accepted,
      power: 20,
      replyPower: 20,
    );
    expect(tie.raidSucceeded, isFalse);
    final win = _request(
      kind: NeighborRequestKind.raid,
      status: NeighborRequestStatus.accepted,
      power: 21,
      replyPower: 20,
    );
    expect(win.raidSucceeded, isTrue);
    expect(_request(kind: NeighborRequestKind.raid).raidSucceeded, isNull);
  });

  test('yard defense adds the strongest active protection only', () {
    final now = _at.add(const Duration(hours: 2));
    final strong = _request(
      kind: NeighborRequestKind.defense,
      status: NeighborRequestStatus.accepted,
      power: 30,
      respondedAt: _at,
    );
    final weak = _request(
      fromId: 'zoe',
      kind: NeighborRequestKind.defense,
      status: NeighborRequestStatus.accepted,
      power: 12,
      respondedAt: _at,
    );
    final expired = _request(
      fromId: 'old',
      kind: NeighborRequestKind.defense,
      status: NeighborRequestStatus.accepted,
      power: 90,
      respondedAt: _at.subtract(const Duration(days: 2)),
    );
    final pending = _request(
      fromId: 'new',
      kind: NeighborRequestKind.defense,
      power: 80,
    );
    expect(
      yardDefense(
        own: 15,
        requests: [strong, weak, expired, pending],
        me: 'me',
        now: now,
      ),
      45,
    );
    expect(yardDefense(own: null, requests: const [], me: 'me', now: now), 0);
  });

  test('both sides resolve the same neighbor cross seed', () {
    for (var i = 0; i < 40; i++) {
      final opId = 'ncross-a__b__cross-$i';
      final first = resolveNeighborCross(
        opId: opId,
        first: SeedSpecies.amberbell,
        second: SeedSpecies.glassreed,
      );
      final again = resolveNeighborCross(
        opId: opId,
        first: SeedSpecies.amberbell,
        second: SeedSpecies.glassreed,
      );
      expect(again, first);
    }
  });

  test('attention and unseen counts follow each new request state', () {
    final incoming = _request();
    final waiting = _request(fromId: 'me', toId: 'anna');
    final answered = _request(
      fromId: 'me',
      toId: 'anna',
      kind: NeighborRequestKind.defense,
      status: NeighborRequestStatus.accepted,
      power: 10,
      respondedAt: _at,
    );
    expect(incoming.needsAttention('me'), isTrue);
    expect(waiting.needsAttention('me'), isFalse);
    expect(answered.needsAttention('me'), isTrue);
    final all = [incoming, waiting, answered];
    expect(unseenRequestCount(all, 'me', const {}), 2);
    expect(unseenRequestCount(all, 'me', {incoming.noticeKey}), 1);
    expect(unseenRequestCount(all, 'me', const {}, blockedIds: {'anna'}), 0);
  });

  test('a document without a known kind or date is rejected', () {
    expect(
      NeighborRequest.fromMap('x', {
        'fromId': 'a',
        'fromName': 'A',
        'toId': 'b',
        'toName': 'B',
        'kind': 'gift',
        'phrase': 'hello',
        'status': 'pending',
        'createdAt': _at,
      }),
      isNull,
    );
    expect(
      NeighborRequest.fromMap('x', {
        'fromId': 'a',
        'fromName': 'A',
        'toId': 'b',
        'toName': 'B',
        'kind': 'raid',
        'phrase': 'hello',
        'status': 'pending',
        'createdAt': _at,
        'power': 5000,
      })!.power,
      isNull,
    );
  });

  test(
    'a neighbor cross spends one own plant once and adds one seed',
    () async {
      final mine = _plant('plant-1', SeedSpecies.amberbell);
      final other = _plant('plant-2', SeedSpecies.mistfern);
      SharedPreferences.setMockInitialValues({
        'points.balance': 40,
        'garden.state.v1': GardenSnapshot(
          beds: List<Planting?>.filled(GardenCatalog.bedCount, null),
          warehouse: [mine, other],
          seq: 2,
        ).encode(),
        'seeds.state.v1': SeedSnapshot.empty.encode(),
      });
      final store = await PointsStore.open();
      final missing = await store.claimNeighborCross(
        opId: 'ncross-1',
        give: SeedSpecies.nightlotus,
        receive: SeedSpecies.glassreed,
      );
      expect(missing.status, CrossStatus.missing);
      expect(store.garden.warehouse, hasLength(2));

      final first = await store.claimNeighborCross(
        opId: 'ncross-1',
        give: SeedSpecies.amberbell,
        receive: SeedSpecies.glassreed,
        lineage: const CrossLineage(
          partnerId: 'anna',
          partnerName: 'Anna',
          parentSpecies: ['amberbell', 'mistfern'],
          ownPlantId: '',
        ),
      );
      expect(first.status, CrossStatus.granted);
      expect(first.seed!.species, SeedSpecies.glassreed);
      expect(first.seed!.source, SeedSource.cross);
      expect(store.garden.warehouse.single.id, other.id);

      final again = await store.claimNeighborCross(
        opId: 'ncross-1',
        give: SeedSpecies.mistfern,
        receive: SeedSpecies.glassreed,
      );
      expect(again.status, CrossStatus.granted);
      expect(again.seed!.id, first.seed!.id);
      expect(store.garden.warehouse, hasLength(1));
      expect((await PointsStore.open()).seeds.inventory, hasLength(1));
      final planted = await store.plantSeed(
        bedIndex: 0,
        seedId: first.seed!.id,
        now: _at,
      );
      expect(planted.status, PlantStatus.planted);
      expect(store.garden.beds.first!.lineage!.partnerName, 'Anna');
      final reopened = await PointsStore.open();
      final afterPlanting = await reopened.claimNeighborCross(
        opId: 'ncross-1',
        give: SeedSpecies.mistfern,
        receive: SeedSpecies.glassreed,
      );
      expect(afterPlanting.status, CrossStatus.granted);
      expect(reopened.seeds.inventory, isEmpty);
      expect(reopened.garden.warehouse, hasLength(1));
    },
  );

  testWidgets('a neighbor card offers messages and the three game actions', (
    tester,
  ) async {
    final requests = _FakeRequests();
    await _pumpPanel(tester, requests: requests);
    await tester.tap(find.byKey(const ValueKey('neighbors-row-anna')));
    await tester.pump();

    expect(find.text('Send a message'), findsOneWidget);
    expect(find.text('Protect'), findsOneWidget);
    expect(find.text('Offer a cross'), findsOneWidget);
    expect(find.text('Attack'), findsWidgets);
    expect(
      find.text('Assign a guarding pet in the pet yard first.'),
      findsOneWidget,
    );
    expect(
      find.text('Assign a raiding pet in the pet yard first.'),
      findsOneWidget,
    );
    expect(find.text('You need a harvested plant in storage.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('neighbors-action-message')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('neighbors-phrase-niceGarden')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('neighbors-compose-send')));
    await tester.pumpAndSettle();

    final sent = requests.items.single;
    expect(sent.kind, NeighborRequestKind.message);
    expect(sent.phrase, NeighborPhrase.niceGarden);
    expect(find.text('You: “Lovely garden!”'), findsOneWidget);
    expect(find.text('Waiting for a reply'), findsWidgets);

    await tester.tap(
      find.byKey(ValueKey('neighbors-request-cancel-${sent.id}')),
    );
    await tester.pumpAndSettle();
    expect(requests.items.single.status, NeighborRequestStatus.cancelled);
    expect(find.text('This offer was cancelled.'), findsOneWidget);
  });

  testWidgets('an incoming raid is answered with the yard defense', (
    tester,
  ) async {
    final raid = _request(kind: NeighborRequestKind.raid, power: 15);
    final requests = _FakeRequests(initial: [raid]);
    await _pumpPanel(tester, requests: requests);

    expect(find.byKey(const ValueKey('neighbors-for-you')), findsOneWidget);
    expect(find.text('Raiding your yard'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('neighbors-row-anna')));
    await tester.pump();
    expect(find.text('Anna is raiding your yard. Attack 15.'), findsOneWidget);
    expect(
      find.byKey(ValueKey('neighbors-request-decline-${raid.id}')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(ValueKey('neighbors-request-accept-${raid.id}')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your yard defense: 0'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('neighbors-compose-send')));
    await tester.pumpAndSettle();

    expect(requests.responses.single.accept, isTrue);
    expect(requests.responses.single.power, 0);
    expect(
      find.text('The raid succeeded: attack 15 against defense 0.'),
      findsOneWidget,
    );
    final history = await NeighborHistoryStore.open();
    expect(
      history.forPerson('anna').single.code,
      NeighborMemoryCode.raidReport,
    );
  });

  testWidgets('without a connection the actions say why they are missing', (
    tester,
  ) async {
    await _pumpPanel(tester, requests: _FakeRequests(online: false));
    await tester.tap(find.byKey(const ValueKey('neighbors-row-anna')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('neighbors-actions-offline')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('neighbors-action-message')),
      findsNothing,
    );
  });
}

HarvestedPlant _plant(String id, SeedSpecies species) {
  final at = DateTime.utc(2026, 10, 1);
  return HarvestedPlant(
    id: id,
    species: species,
    power: SeedCatalog.foodFor(species),
    houseLevel: 1,
    seedId: 'seed-$id',
    source: SeedSource.houseProduction,
    batchId: 'batch-$id',
    plantingId: 'planting-$id',
    plantedAt: at,
    maturedAt: at.add(const Duration(minutes: 5)),
    harvestedAt: at.add(const Duration(minutes: 6)),
  );
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required NeighborRequestRepository requests,
}) async {
  tester.view.physicalSize = const Size(800, 2000);
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
      home: NeighborsOverlay(
        visible: true,
        directory: MemoryNeighborDirectory(const [_anna]),
        acquaintances: acquaintances,
        notices: notices,
        history: history,
        blocks: blocks,
        gateway: const UnavailableNeighborGateway(),
        requests: requests,
        onClose: () {},
        onObscuring: (_) {},
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
