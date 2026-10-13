import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/l10n/app_localizations.dart';
import 'package:mahjong/models/garden.dart';
import 'package:mahjong/models/hub_event.dart';
import 'package:mahjong/models/neighbor_request.dart';
import 'package:mahjong/models/seed_catalog.dart';
import 'package:mahjong/services/hub_feed.dart';
import 'package:mahjong/widgets/neighbors/neighbor_copy.dart';

final _now = DateTime.utc(2026, 10, 9, 12);

Planting _bed(String id, {required DateTime readyAt}) => Planting(
  id: id,
  seedId: 'seed-$id',
  species: SeedSpecies.amberbell,
  power: 10,
  houseLevel: 1,
  source: SeedSource.houseProduction,
  batchId: 'batch-$id',
  plantedAt: readyAt.subtract(const Duration(minutes: 5)),
  readyAt: readyAt,
  cost: 5,
  rulesVersion: GardenCatalog.rulesVersion,
);

GardenSnapshot _garden(List<Planting?> beds) =>
    GardenSnapshot(beds: beds, warehouse: const [], seq: 0);

NeighborRequest _incoming({
  required DateTime at,
  NeighborRequestKind kind = NeighborRequestKind.defense,
  String from = 'ann',
}) => NeighborRequest(
  id: NeighborRequest.idFor(from, 'me', kind),
  fromId: from,
  fromName: 'Ann',
  toId: 'me',
  toName: 'Me',
  kind: kind,
  phrase: NeighborPhrase.hello,
  status: NeighborRequestStatus.pending,
  createdAt: at,
  power: 40,
);

void main() {
  test('the newest of neighbor requests and ripe beds wins', () {
    final request = _incoming(at: _now.subtract(const Duration(minutes: 3)));
    final garden = _garden([
      _bed('a', readyAt: _now.subtract(const Duration(minutes: 10))),
      null,
      null,
    ]);
    final event = HubFeed.latest(
      now: _now,
      requests: [request],
      me: 'me',
      garden: garden,
    );
    expect(event?.kind, HubEventKind.neighbor);

    final later = HubFeed.latest(
      now: _now,
      requests: [request],
      me: 'me',
      garden: _garden([
        _bed('a', readyAt: _now.subtract(const Duration(minutes: 1))),
        null,
        null,
      ]),
    );
    expect(later?.kind, HubEventKind.harvestReady);
    expect(later?.bedIndex, 0);
  });

  test('seen and blocked requests are skipped', () {
    final request = _incoming(at: _now);
    expect(
      HubFeed.latest(now: _now, requests: [request], me: 'me', seenIds: {
        request.noticeKey,
      }),
      isNull,
    );
    expect(
      HubFeed.latest(
        now: _now,
        requests: [request],
        me: 'me',
        blockedIds: {'ann'},
      ),
      isNull,
    );
  });

  test('a free bed is suggested only when nothing happened and seeds exist', () {
    final garden = _garden([
      _bed('a', readyAt: _now.add(const Duration(minutes: 4))),
      null,
      null,
    ]);
    expect(HubFeed.latest(now: _now, garden: garden), isNull);
    final free = HubFeed.latest(now: _now, garden: garden, hasSeeds: true);
    expect(free?.kind, HubEventKind.bedFree);
    expect(free?.bedIndex, 1);
    expect(
      HubFeed.nextRipening(garden, _now),
      _now.add(const Duration(minutes: 4)),
    );
  });

  test('neighbor lines name the person and the news', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    final request = _incoming(at: _now);
    expect(neighborHubLine(ru, request, 'me'), 'Ann: Предлагает защиту');

    final raid = NeighborRequest(
      id: NeighborRequest.idFor('me', 'ann', NeighborRequestKind.raid),
      fromId: 'me',
      fromName: 'Me',
      toId: 'ann',
      toName: 'Ann',
      kind: NeighborRequestKind.raid,
      phrase: NeighborPhrase.readyForRaid,
      status: NeighborRequestStatus.accepted,
      createdAt: _now,
      respondedAt: _now,
      power: 50,
      replyPower: 30,
    );
    expect(
      neighborHubLine(ru, raid, 'me'),
      'Ann: ${ru.neighborsRaidWon(50, 30)}',
    );
  });
}
