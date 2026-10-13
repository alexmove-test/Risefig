import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/l10n/app_localizations.dart';
import 'package:mahjong/models/garden.dart';
import 'package:mahjong/models/pet.dart';
import 'package:mahjong/models/pet_roster.dart';
import 'package:mahjong/models/plant_listing.dart';
import 'package:mahjong/models/seed_catalog.dart';
import 'package:mahjong/screens/plant_showcase_screen.dart';
import 'package:mahjong/services/plant_showcase_controller.dart';
import 'package:mahjong/services/plant_showcase_repository.dart';
import 'package:mahjong/services/points_controller.dart';
import 'package:mahjong/services/points_store.dart';
import 'package:mahjong/widgets/garden/garden_sheets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!const bool.fromEnvironment('SHOWCASE_PREVIEW')) return;
    final loader = FontLoader('ShowcasePreview')
      ..addFont(
        File(
          r'C:\Windows\Fonts\arial.ttf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  test(
    'publication is visible to another player and reserves only its specimen',
    () async {
      final points = await _points([_plant('plant-1'), _plant('plant-2')]);
      final repo = _Repository();
      final controller = PlantShowcaseController(
        points: points,
        repository: repo,
      );
      await controller.refresh();
      expect(await controller.publish(points.garden.warehouse.first), isTrue);
      expect(controller.mine.keys, ['plant-1']);
      expect(points.showcaseReservations, {'plant-1': 'alice'});
      expect(points.plantCount, 2);
      final other = _Repository(database: repo.database, owner: 'bob');
      expect((await other.fetchPage()).items.single.ownerName, 'Alice');
      expect((await other.fetchPage()).items.single.plantId, 'plant-1');
      final rejected = await points.feedPet(
        kind: PetKind.cat,
        plantId: 'plant-1',
      );
      expect(rejected.status, FeedStatus.listed);
      expect(
        (await points.feedPet(kind: PetKind.cat, plantId: 'plant-2')).fed,
        isTrue,
      );
      expect(points.plantCount, 1);
      controller.dispose();
      points.dispose();
    },
  );

  test(
    'a lost publication response survives restart and can be safely withdrawn',
    () async {
      final points = await _points([_plant('plant-1')]);
      final repo = _Repository()..failAfterCommit = true;
      final controller = PlantShowcaseController(
        points: points,
        repository: repo,
      );
      await controller.refresh();
      expect(await controller.publish(points.garden.warehouse.single), isFalse);
      expect(repo.database, hasLength(1));
      expect(controller.error, ShowcaseError.operation);
      final reopened = await PointsStore.open();
      expect(reopened.showcaseReservations, {'plant-1': 'alice'});
      expect(
        (await reopened.feedPet(kind: PetKind.cat, plantId: 'plant-1')).status,
        FeedStatus.listed,
      );
      controller.dispose();
      points.dispose();

      final restoredPoints = PointsController(reopened);
      final restored = PlantShowcaseController(
        points: restoredPoints,
        repository: repo,
      );
      await restored.refresh();
      expect(restored.mine, hasLength(1));
      repo.failRemove = true;
      expect(await restored.remove('plant-1'), isFalse);
      expect(restoredPoints.showcaseReservations, isNotEmpty);
      repo.failRemove = false;
      expect(await restored.remove('plant-1'), isTrue);
      expect(repo.database, isEmpty);
      expect((await PointsStore.open()).showcaseReservations, isEmpty);
      expect(
        (await restoredPoints.feedPet(
          kind: PetKind.cat,
          plantId: 'plant-1',
        )).fed,
        isTrue,
      );
      restored.dispose();
      restoredPoints.dispose();
    },
  );

  test('failed publication without a remote card can be cancelled', () async {
    final points = await _points([_plant('plant-1')]);
    final repo = _Repository()..failBeforeCommit = true;
    final controller = PlantShowcaseController(
      points: points,
      repository: repo,
    );
    await controller.refresh();
    expect(await controller.publish(points.garden.warehouse.single), isFalse);
    expect(repo.database, isEmpty);
    expect(points.showcaseReservations, isNotEmpty);
    expect(await controller.remove('plant-1'), isTrue);
    expect(points.showcaseReservations, isEmpty);
    controller.dispose();
    points.dispose();
  });

  test(
    'rapid repeated publish does not send a second request; retry keeps one card',
    () async {
      final points = await _points([_plant('plant-1')]);
      final repo = _Repository()..gate = Completer<void>();
      final controller = PlantShowcaseController(
        points: points,
        repository: repo,
      );
      await controller.refresh();
      final first = controller.publish(points.garden.warehouse.single);
      expect(await controller.publish(points.garden.warehouse.single), isFalse);
      repo.gate!.complete();
      expect(await first, isTrue);
      expect(repo.publishCalls, 1);
      expect(await controller.publish(points.garden.warehouse.single), isTrue);
      expect(repo.database, hasLength(1));
      controller.dispose();
      points.dispose();
    },
  );

  test('feeding and reservation share the inventory operation queue', () async {
    final points = await _points([_plant('plant-1')]);
    final reserved = points.reserveShowcasePlant('plant-1', 'alice');
    final fed = points.feedPet(kind: PetKind.cat, plantId: 'plant-1');
    expect(await reserved, isTrue);
    expect((await fed).status, FeedStatus.listed);
    expect(await points.releaseShowcasePlant('plant-1', 'bob'), isFalse);
    expect(await points.releaseShowcasePlant('plant-1', 'alice'), isTrue);
    final feeding = points.feedPet(kind: PetKind.cat, plantId: 'plant-1');
    final reservation = points.reserveShowcasePlant('plant-1', 'alice');
    expect((await feeding).fed, isTrue);
    expect(await reservation, isFalse);
    points.dispose();
  });

  test('unavailable connection never fabricates a publication', () async {
    final points = await _points([_plant('plant-1')]);
    final repo = _Repository()..unavailable = true;
    final controller = PlantShowcaseController(
      points: points,
      repository: repo,
    );
    await controller.refresh();
    expect(controller.error, ShowcaseError.unavailable);
    expect(await controller.publish(points.garden.warehouse.single), isFalse);
    expect(points.showcaseReservations, isEmpty);
    controller.dispose();
    points.dispose();
  });

  test(
    'pagination deduplicates and hiding an owner persists across refresh',
    () async {
      final points = await _points([]);
      final repo = _Repository();
      for (var i = 0; i < 5; i++) {
        final plant = _plant('plant-$i');
        await repo.publish(
          ShowcaseIdentity(i.isEven ? 'bob' : 'carol', 'Neighbor'),
          plant,
        );
      }
      final controller = PlantShowcaseController(
        points: points,
        repository: repo,
      );
      await controller.refresh();
      expect(controller.items, hasLength(2));
      expect(controller.hasMore, isTrue);
      await controller.loadMore();
      await controller.loadMore();
      expect(controller.items.map((item) => item.id).toSet(), hasLength(5));
      expect(controller.hasMore, isFalse);
      await controller.hideOwner('bob');
      expect(controller.items.every((item) => item.ownerId == 'carol'), isTrue);
      await controller.refresh();
      await controller.loadMore();
      await controller.loadMore();
      expect(controller.items, hasLength(2));
      expect(controller.items.every((item) => item.ownerId == 'carol'), isTrue);
      controller.dispose();
      points.dispose();
    },
  );

  testWidgets(
    'publish, view in public list, and withdraw a specific specimen',
    (tester) async {
      final points = await _points([_plant('plant-1'), _plant('plant-2')]);
      final repo = _Repository();
      await tester.pumpWidget(_app(points, repo, mine: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('publish-plant-1')));
      await tester.pumpAndSettle();
      expect(repo.database, hasLength(1));
      await tester.tap(find.byKey(const ValueKey('showcase-tab-all')));
      await tester.pumpAndSettle();
      expect(find.text('Alice · You'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('withdraw-plant-1')));
      await tester.pumpAndSettle();
      expect(repo.database, isEmpty);
      expect(points.plantCount, 2);
      expect(points.showcaseReservations, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      points.dispose();
    },
  );

  testWidgets('Russian showcase fits a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final points = await _points([_plant('plant-1')]);
    final repo = _Repository();
    await repo.publish(
      const ShowcaseIdentity('bob', 'Сосед с очень длинным именем'),
      _plant('plant-2', species: SeedSpecies.nightlotus),
    );
    await tester.pumpWidget(
      _app(points, repo, locale: const Locale('ru'), scale: 1.5),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Сосед с очень длинным именем'), findsOneWidget);
    if (const bool.fromEnvironment('SHOWCASE_PREVIEW')) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('showcase-preview')),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build').create(recursive: true);
        await File(
          'build/showcase-preview.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.tap(find.byKey(const ValueKey('showcase-tab-mine')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    points.dispose();
  });

  testWidgets(
    'warehouse opens the full-screen showcase and returns to inventory',
    (tester) async {
      final points = await _points([_plant('plant-1')]);
      await tester.pumpWidget(
        PointsScope(
          controller: points,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: WarehouseSheet(height: 500)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('warehouse-showcase')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('feature-intro-showcase')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('feature-intro-ok')));
      await tester.pumpAndSettle();
      final screen = find.byKey(const ValueKey('plant-showcase-screen'));
      expect(screen, findsOneWidget);
      expect(
        tester.getSize(screen),
        tester.view.physicalSize / tester.view.devicePixelRatio,
      );
      expect(find.byKey(const ValueKey('own-plant-plant-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('warehouse-title')), findsNothing);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('warehouse-title')), findsOneWidget);
      expect(points.plantCount, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      points.dispose();
    },
  );
}

Widget _app(
  PointsController points,
  PlantShowcaseRepository repo, {
  bool mine = false,
  Locale locale = const Locale('en'),
  double scale = 1,
}) => MaterialApp(
  theme: ThemeData(
    fontFamily: const bool.fromEnvironment('SHOWCASE_PREVIEW')
        ? 'ShowcasePreview'
        : null,
  ),
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: RepaintBoundary(
    key: const ValueKey('showcase-preview'),
    child: PlantShowcaseScreen(
      points: points,
      repository: repo,
      initiallyMine: mine,
    ),
  ),
);

Future<PointsController> _points(List<HarvestedPlant> plants) async {
  SharedPreferences.setMockInitialValues({
    'points.balance': 100,
    'points.houseMigrated': true,
    'points.houseState': 1,
    'pet.owned': 'cat',
    'garden.state.v1': GardenSnapshot(
      beds: List.filled(GardenCatalog.bedCount, null),
      warehouse: plants,
      seq: 10,
    ).encode(),
  });
  return PointsController(await PointsStore.open());
}

HarvestedPlant _plant(
  String id, {
  SeedSpecies species = SeedSpecies.amberbell,
}) {
  final time = DateTime.utc(2026, 10, 7);
  return HarvestedPlant(
    id: id,
    species: species,
    power: SeedCatalog.foodFor(species),
    houseLevel: 1,
    seedId: 'seed-$id',
    source: 'house_production',
    batchId: 'batch-1',
    plantingId: 'planting-$id',
    plantedAt: time,
    maturedAt: time,
    harvestedAt: time,
  );
}

class _Repository implements PlantShowcaseRepository {
  _Repository({Map<String, PlantListing>? database, this.owner = 'alice'})
    : database = database ?? {};
  final Map<String, PlantListing> database;
  final String owner;
  bool failBeforeCommit = false;
  bool failAfterCommit = false;
  bool failRemove = false;
  bool unavailable = false;
  Completer<void>? gate;
  int publishCalls = 0;

  @override
  Future<ShowcaseIdentity> connect() async {
    if (unavailable) throw ShowcaseUnavailable();
    return ShowcaseIdentity(owner, owner == 'alice' ? 'Alice' : 'Bob');
  }

  @override
  Future<List<PlantListing>> fetchMine(String ownerId) async =>
      database.values.where((item) => item.ownerId == ownerId).toList();

  @override
  Future<PlantListingPage> fetchPage({Object? cursor}) async {
    final start = cursor as int? ?? 0;
    final all = database.values.toList();
    final end = (start + 2).clamp(0, all.length);
    return PlantListingPage(
      items: all.sublist(start, end),
      cursor: end < all.length ? end : null,
    );
  }

  @override
  Future<PlantListing> publish(
    ShowcaseIdentity owner,
    HarvestedPlant plant,
  ) async {
    publishCalls++;
    if (gate != null) await gate!.future;
    if (failBeforeCommit) throw StateError('Offline');
    final id = '${owner.id}__${plant.id}';
    final item = PlantListing(
      id: id,
      ownerId: owner.id,
      ownerName: owner.name,
      plantId: plant.id,
      species: plant.species,
      power: plant.power,
      publishedAt: database[id]?.publishedAt ?? DateTime.utc(2026, 10, 7),
    );
    database[id] = item;
    if (failAfterCommit) throw StateError('Response lost');
    return item;
  }

  @override
  Future<void> remove(ShowcaseIdentity owner, String plantId) async {
    if (failRemove) throw StateError('Offline');
    database.remove('${owner.id}__$plantId');
  }
}
