import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/models/garden.dart';
import 'package:mahjong/models/plant_cross.dart';
import 'package:mahjong/models/seed_batch.dart';
import 'package:mahjong/models/seed_catalog.dart';
import 'package:mahjong/widgets/courtyard/courtyard_estate.dart';
import 'package:mahjong/widgets/courtyard/courtyard_world.dart';
import 'package:mahjong/widgets/courtyard/home_upgrade_preview.dart';
import 'package:mahjong/widgets/courtyard/plot_stage_view.dart';
import 'package:mahjong/services/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mahjong/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the purchase card shows the next look, price and shortfall', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<void> show({
      required int state,
      required int balance,
      bool busy = false,
      Future<void> Function()? onBuy,
      bool reduceMotion = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const [Locale('ru')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                textScaler: const TextScaler.linear(1.5),
                disableAnimations: reduceMotion,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: HomeUpgradePreview(
                    state: state,
                    balance: balance,
                    busy: busy,
                    onBuy: onBuy,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }

    await show(state: 5, balance: 1000, onBuy: () async {});
    expect(find.text('Дом · 5/24'), findsNothing);
    expect(find.text('Улучшение дома — 300'), findsNothing);
    expect(find.byKey(const ValueKey('house-look-line')), findsNothing);
    expect(find.text('Улучшить за 300'), findsOneWidget);
    expect(find.textContaining('пруд'), findsNothing);
    final preview = find.byKey(const ValueKey('next-house-image'));
    expect(
      (tester.widget<Image>(preview).image as AssetImage).assetName,
      'assets/courtyard/builds/house/06.png',
    );
    final button = tester.getRect(
      find.byKey(const ValueKey('house-upgrade-button')),
    );
    expect(button.left, greaterThan(tester.getRect(preview).right));
    expect(button.right, lessThanOrEqualTo(308));

    await tester.tap(find.byKey(const ValueKey('house-upgrade-curtain')));
    await tester.pumpAndSettle();
    expect(find.text('Дом · 5/24'), findsOneWidget);
    expect(find.text('Улучшение дома — 300'), findsOneWidget);
    final price = tester.getRect(find.text('Улучшение дома — 300'));
    expect(price.right, lessThanOrEqualTo(308));
    final title = tester.getRect(find.text('Дом · 5/24'));
    final line = tester.getRect(find.byKey(const ValueKey('house-look-line')));
    expect(line.top, greaterThan(title.bottom));
    expect(line.right, lessThanOrEqualTo(308));
    expect(find.byKey(const ValueKey('house-look-built-5')), findsOneWidget);
    expect(find.byKey(const ValueKey('house-look-fog-6')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('house-upgrade-curtain')));
    await tester.pumpAndSettle();
    expect(find.text('Дом · 5/24'), findsNothing);
    expect(find.text('Улучшение дома — 300'), findsNothing);
    expect(find.byKey(const ValueKey('house-look-line')), findsNothing);
    expect(find.text('Улучшить за 300'), findsOneWidget);

    await show(state: 5, balance: 50, onBuy: () async {});
    expect(find.text('Не хватает 250 поинтов'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('house-upgrade-curtain')));
    await tester.pumpAndSettle();
    expect(find.text('Не хватает 250 поинтов'), findsOneWidget);
    expect(find.text('Играть в махджонг'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('house-upgrade-button')),
          )
          .onPressed,
      isNull,
    );

    await show(state: 23, balance: 1200, onBuy: () async {});
    expect(find.text('Улучшить за 1\u2009200'), findsOneWidget);
    expect(
      (tester.widget<Image>(preview).image as AssetImage).assetName,
      'assets/courtyard/builds/house/24.png',
    );

    await show(state: 24, balance: 5000);
    expect(find.text('Дом полностью улучшен'), findsOneWidget);
    expect(find.byKey(const ValueKey('next-house-image')), findsNothing);
    expect(find.textContaining('пруд'), findsNothing);
    expect(find.byKey(const ValueKey('house-upgrade-button')), findsNothing);

    await show(state: 2, balance: 500, busy: true, onBuy: () async {});
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('house-upgrade-button')),
          )
          .onPressed,
      isNull,
    );

    var taps = 0;
    await show(
      state: 1,
      balance: 500,
      onBuy: () async {
        taps++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
      },
    );
    await tester.tap(find.byKey(const ValueKey('house-upgrade-button')));
    await tester.tap(find.byKey(const ValueKey('house-upgrade-button')));
    await tester.pump();
    expect(taps, 1);
    await tester.pump(const Duration(milliseconds: 40));

    await show(state: 4, balance: 400, onBuy: () async {}, reduceMotion: true);
    await show(state: 5, balance: 100, onBuy: () async {}, reduceMotion: true);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seed and plant squares sit to the right of upgrade', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var seeds = 0;
    var plants = 0;

    Future<void> show({required int balance}) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const [Locale('ru')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: HomeUpgradePreview(
                state: 1,
                balance: balance,
                onBuy: () async {},
                onStartSeed: () async {
                  seeds++;
                },
                onClaimSeed: () async {},
                onOpenSeed: () {},
                onGrowPlant: () {
                  plants++;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await show(balance: 500);
    expect(tester.takeException(), isNull);
    final upgrade = tester.getRect(
      find.byKey(const ValueKey('house-upgrade-button')),
    );
    final seed = tester.getRect(find.byKey(const ValueKey('yard-seed-button')));
    final plant = tester.getRect(
      find.byKey(const ValueKey('yard-plant-button')),
    );
    expect((upgrade.width - upgrade.height).abs(), lessThan(1));
    expect((seed.width - seed.height).abs(), lessThan(1));
    expect((plant.width - plant.height).abs(), lessThan(1));
    expect(seed.width, upgrade.width);
    expect(seed.left, greaterThan(upgrade.right - 1));
    expect(plant.left, greaterThan(seed.right - 1));
    expect(find.textContaining('Произвести'), findsOneWidget);
    expect(find.text('Вырастить растение'), findsOneWidget);
    for (final key in const [
      'house-upgrade-button',
      'yard-seed-button',
      'yard-plant-button',
    ]) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(Text),
        ),
      );
      expect(paragraph.didExceedMaxLines, isFalse, reason: key);
    }

    await tester.tap(find.byKey(const ValueKey('yard-seed-button')));
    await tester.pump();
    expect(seeds, 1);
    await tester.tap(find.byKey(const ValueKey('yard-plant-button')));
    await tester.pump();
    expect(plants, 1);

    await show(balance: 0);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('yard-seed-button')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('yard-plant-button')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('the curtain lists seeds, warehouse and garden beds', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.now().toUtc();
    final growing = Planting(
      id: 'bed-grow',
      seedId: 'seed-grow',
      species: SeedSpecies.amberbell,
      power: 10,
      houseLevel: 1,
      source: SeedSource.houseProduction,
      batchId: 'batch-grow',
      plantedAt: now.subtract(const Duration(minutes: 1)),
      readyAt: now.add(const Duration(minutes: 4)),
      cost: 5,
      rulesVersion: GardenCatalog.rulesVersion,
    );
    final ripe = Planting(
      id: 'bed-ripe',
      seedId: 'seed-ripe',
      species: SeedSpecies.glassreed,
      power: 25,
      houseLevel: 8,
      source: SeedSource.houseProduction,
      batchId: 'batch-ripe',
      plantedAt: now.subtract(const Duration(minutes: 30)),
      readyAt: now.subtract(const Duration(minutes: 1)),
      cost: 10,
      rulesVersion: GardenCatalog.rulesVersion,
      trait: PlantTrait.bloom,
    );
    final stored = HarvestedPlant(
      id: 'plant-1',
      species: SeedSpecies.mistfern,
      power: 10,
      houseLevel: 1,
      seedId: 'seed-stored',
      source: SeedSource.houseProduction,
      batchId: 'batch-stored',
      plantingId: 'planted-stored',
      plantedAt: now,
      maturedAt: now,
      harvestedAt: now,
    );
    final spare = SeedInstance(
      id: 'spare-1',
      species: SeedSpecies.crimsonplum,
      power: 25,
      houseLevel: 6,
      createdAt: now,
      source: SeedSource.houseProduction,
      batchId: 'batch-spare',
    );
    final batch = SeedBatch(
      id: 'batch-live',
      startedAt: now.subtract(const Duration(minutes: 2)),
      readyAt: now.add(const Duration(minutes: 8)),
      houseLevel: 1,
      cost: 10,
      species: SeedSpecies.nightlotus,
      power: 60,
      rulesVersion: SeedCatalog.rulesVersion,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: HomeUpgradePreview(
              state: 1,
              balance: 500,
              onBuy: () async {},
              seedBatch: batch,
              onStartSeed: () async {},
              onClaimSeed: () async {},
              onOpenSeed: () {},
              onGrowPlant: () {},
              seeds: [spare],
              garden: GardenSnapshot(
                beds: [null, growing, ripe],
                warehouse: [stored],
                seq: 1,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('yard-curtain-seeds')), findsNothing);
    expect(find.byKey(const ValueKey('yard-curtain-warehouse')), findsNothing);
    expect(find.byKey(const ValueKey('yard-curtain-garden')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('house-upgrade-curtain')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.text('Семена'), findsOneWidget);
    expect(find.textContaining('Сажайте их на грядки'), findsOneWidget);
    expect(find.byKey(const ValueKey('yard-seed-producing')), findsOneWidget);
    expect(find.textContaining('Ночной лотос'), findsNothing);
    expect(find.text('Багряная слива ×1 · Корм: 25'), findsOneWidget);

    expect(find.text('Склад'), findsOneWidget);
    expect(find.textContaining('Кормите ими питомцев'), findsOneWidget);
    expect(find.text('Туманный папоротник ×1 · Корм: 10'), findsOneWidget);

    expect(find.text('Огород'), findsOneWidget);
    expect(find.textContaining('Посадите семя на грядку'), findsOneWidget);
    expect(find.text('Грядка 1, пустая'), findsOneWidget);
    expect(find.textContaining('Грядка 2, Янтарный колокольчик'), findsOneWidget);
    expect(
      find.text('Грядка 3, Стеклянный тростник, можно собрать'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('house-upgrade-curtain')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('yard-curtain-garden')), findsNothing);
  });

  testWidgets('a bought step eases the house, and reduced motion skips it', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'progress.maxUnlocked': 1});
    final store = await ProgressStore.open();

    Future<void> show(int home, {required bool reduceMotion}) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: CourtyardWorld(
              to: CourtyardEstate.fromStore(store, purchasedHome: home),
              interactive: false,
            ),
          ),
        ),
      );
    }

    await show(1, reduceMotion: false);
    await tester.pump();
    await show(2, reduceMotion: false);
    await tester.pump(const Duration(milliseconds: 50));
    final blending = tester
        .widgetList<PlotStageView>(find.byType(PlotStageView))
        .firstWhere((view) => view.kind.name == 'house');
    expect(blending.stage, greaterThan(1));
    expect(blending.stage, lessThan(2));

    await show(1, reduceMotion: true);
    await tester.pump();
    await show(2, reduceMotion: true);
    await tester.pump();
    final jumped = tester
        .widgetList<PlotStageView>(find.byType(PlotStageView))
        .firstWhere((view) => view.kind.name == 'house');
    expect(jumped.stage, 2);
  });
}
