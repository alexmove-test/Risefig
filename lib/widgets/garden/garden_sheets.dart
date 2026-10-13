import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/garden.dart';
import '../../models/seed_batch.dart';
import '../../models/seed_catalog.dart';
import '../../screens/plant_showcase_screen.dart';
import '../../services/ad_bootstrap.dart';
import '../../services/analytics_service.dart';
import '../../services/points_controller.dart';
import '../../services/rewarded_ad_service.dart';
import '../seeds/seed_glyph.dart';
import 'cross_sheet.dart';
import 'plant_art.dart';
import 'plant_card.dart';

enum SeedPickerResult { planted, produce, play }

/// Выбор семени для пустой грядки. Посадка идёт одной операцией кошелька.
Future<SeedPickerResult?> showSeedPicker(
  BuildContext context, {
  required int bedIndex,
}) {
  return showModalBottomSheet<SeedPickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (ctx) {
      return SeedPickerSheet(
        height: MediaQuery.sizeOf(ctx).height * 0.78,
        bedIndex: bedIndex,
      );
    },
  );
}

class SeedPickerSheet extends StatefulWidget {
  const SeedPickerSheet({
    super.key,
    required this.height,
    required this.bedIndex,
  });

  final double height;
  final int bedIndex;

  @override
  State<SeedPickerSheet> createState() => _SeedPickerSheetState();
}

class _SeedPickerSheetState extends State<SeedPickerSheet> {
  var _sort = SeedSort.received;
  String? _selectedId;
  var _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final points = PointsScope.of(context);
    return ListenableBuilder(
      listenable: points,
      builder: (context, _) {
        final seeds = points.seeds.inventory;
        final stacks = stackSeeds(seeds, sort: _sort);
        final selected = _resolve(stacks);
        final cost = selected == null
            ? 0
            : GardenCatalog.costFor(selected.species);
        final shortfall = (cost - points.balance).clamp(0, cost);
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: gardenWood,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: widget.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(child: _grabber()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      l10n.chooseSeedTitle,
                      key: const ValueKey('seed-picker-title'),
                      style: const TextStyle(
                        color: gardenGoldSoft,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (seeds.isEmpty)
                    Expanded(
                      child: _EmptySeeds(
                        onProduce: () =>
                            Navigator.of(context).pop(SeedPickerResult.produce),
                      ),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _SortChip(
                            label: l10n.seedSortTime,
                            selected: _sort == SeedSort.received,
                            onTap: () =>
                                setState(() => _sort = SeedSort.received),
                          ),
                          _SortChip(
                            label: l10n.seedSortPower,
                            selected: _sort == SeedSort.power,
                            onTap: () => setState(() => _sort = SeedSort.power),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        itemCount: stacks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final stack = stacks[index];
                          final id = stack.instances.first.id;
                          return _SeedChoice(
                            stack: stack,
                            selected: selected?.id == id,
                            minutes: GardenCatalog.durationFor(
                              stack.species,
                            ).inMinutes,
                            cost: GardenCatalog.costFor(stack.species),
                            onTap: () => setState(() => _selectedId = id),
                          );
                        },
                      ),
                    ),
                    if (shortfall > 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: Text(
                          l10n.pointsShortfall(shortfall),
                          key: const ValueKey('plant-shortfall'),
                          style: const TextStyle(
                            color: gardenGoldSoft,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: Text(
                          _error!,
                          key: const ValueKey('plant-error'),
                          style: const TextStyle(color: gardenGoldSoft),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: FilledButton(
                        key: const ValueKey('plant-seed-button'),
                        style: _buttonStyle(),
                        onPressed: _busy || shortfall > 0 || selected == null
                            ? null
                            : () => _plant(selected),
                        child: Text(
                          l10n.plantAction(1, cost),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    if (shortfall > 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: TextButton(
                          key: const ValueKey('plant-play-mahjong'),
                          onPressed: () =>
                              Navigator.of(context).pop(SeedPickerResult.play),
                          child: Text(l10n.seedPlayMahjong),
                        ),
                      )
                    else
                      const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SeedInstance? _resolve(List<SeedStack> stacks) {
    if (stacks.isEmpty) return null;
    for (final stack in stacks) {
      for (final seed in stack.instances) {
        if (seed.id == _selectedId) return seed;
      }
    }
    return stacks.first.instances.first;
  }

  Future<void> _plant(SeedInstance seed) async {
    if (_busy) return;
    final points = PointsScope.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await points.plantSeed(
      bedIndex: widget.bedIndex,
      seedId: seed.id,
    );
    if (!mounted) return;
    if (result.planted) {
      Navigator.of(context).pop(SeedPickerResult.planted);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = false;
      _error = result.status == PlantStatus.insufficient
          ? l10n.pointsShortfall(result.shortfall)
          : l10n.gardenSaveFailed;
    });
  }
}

class _SeedChoice extends StatelessWidget {
  const _SeedChoice({
    required this.stack,
    required this.selected,
    required this.minutes,
    required this.cost,
    required this.onTap,
  });

  final SeedStack stack;
  final bool selected;
  final int minutes;
  final int cost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seed = stack.instances.first;
    return Material(
      color: selected ? const Color(0xFF4A2A18) : const Color(0xFF2A1A10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey('plant-choice-${seed.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SeedGlyph(size: 48, species: seed.species),
              const SizedBox(width: 8),
              PlantArt(
                species: seed.species,
                stage: GrowthStage.ripe,
                size: 48,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.seedName(seed.species),
                      style: const TextStyle(
                        color: gardenIvory,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l10n.seedClassName(seed.species.seedClass),
                      style: const TextStyle(color: gardenGoldSoft),
                    ),
                    Text(
                      l10n.seedPowerLabel(GardenCatalog.foodFor(seed.species)),
                      style: const TextStyle(color: gardenGoldSoft),
                    ),
                    Text(
                      l10n.seedsAvailable(stack.count),
                      style: const TextStyle(color: gardenIvory),
                    ),
                    Text(
                      l10n.plantCostLabel(cost),
                      style: const TextStyle(color: gardenIvory),
                    ),
                    Text(
                      l10n.growDurationLabel(minutes),
                      style: const TextStyle(color: gardenIvory),
                    ),
                    Semantics(
                      label: l10n.plantPreviewLabel,
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySeeds extends StatelessWidget {
  const _EmptySeeds({required this.onProduce});

  final VoidCallback onProduce;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.noSeedsBody,
            key: const ValueKey('plant-no-seeds'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: gardenIvory, height: 1.35),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('plant-open-production'),
            style: _buttonStyle(),
            onPressed: onProduce,
            child: Text(
              l10n.openHouseProduction,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Занятая грядка: вид, стадия и срок. Сбор только у созревшего растения.
Future<HarvestedPlant?> showGardenBed(
  BuildContext context, {
  required int bedIndex,
  DateTime Function()? now,
  bool? adsLive,
  Future<RewardedAdShowResult> Function(BuildContext context)? showAd,
}) {
  return showModalBottomSheet<HarvestedPlant>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (ctx) {
      return GardenBedSheet(
        bedIndex: bedIndex,
        now: now,
        adsLive: adsLive,
        showAd: showAd,
      );
    },
  );
}

class GardenBedSheet extends StatefulWidget {
  const GardenBedSheet({
    super.key,
    required this.bedIndex,
    this.now,
    this.adsLive,
    this.showAd,
  });

  final int bedIndex;
  final DateTime Function()? now;

  /// В тестах кнопка ролика видна, даже если AdMob не инициализирован.
  final bool? adsLive;

  final Future<RewardedAdShowResult> Function(BuildContext context)? showAd;

  @override
  State<GardenBedSheet> createState() => _GardenBedSheetState();
}

class _GardenBedSheetState extends State<GardenBedSheet> {
  var _busy = false;
  String? _note;
  Timer? _timer;

  bool get _adsLive => widget.adsLive ?? AdBootstrap.available;

  static Future<RewardedAdShowResult> _showRewarded(BuildContext context) {
    return RewardedAdService.instance.show(context: context);
  }

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    if (widget.now != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final points = PointsScope.of(context);
    return ListenableBuilder(
      listenable: points,
      builder: (context, _) {
        final planting = points.garden.bedAt(widget.bedIndex);
        final now = _now();
        final stage = planting == null ? null : stageOf(planting, now);
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: gardenWood,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                if (planting == null || stage == null)
                  Text(
                    l10n.gardenBedEmpty(widget.bedIndex + 1),
                    style: const TextStyle(color: gardenIvory),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _grabber(),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => showPlantCard(context, planting.species),
                        child: PlantArt(
                          species: planting.species,
                          stage: stage,
                          size: 140,
                        ),
                      ),
                      TextButton(
                        key: const ValueKey('open-plant-card'),
                        onPressed: () =>
                            showPlantCard(context, planting.species),
                        child: Text(
                          l10n.openPlantCard,
                          style: const TextStyle(
                            color: gardenGoldSoft,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.seedName(planting.species),
                        key: const ValueKey('bed-species'),
                        style: const TextStyle(
                          color: gardenIvory,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        l10n.bedTitle(widget.bedIndex + 1),
                        style: const TextStyle(color: gardenGoldSoft),
                      ),
                      Text(
                        l10n.growthStage(stage),
                        key: const ValueKey('bed-stage'),
                        style: const TextStyle(color: gardenIvory),
                      ),
                      Text(
                        l10n.plantPower(
                          GardenCatalog.foodFor(planting.species),
                        ),
                        key: const ValueKey('bed-power'),
                        style: const TextStyle(color: gardenIvory),
                      ),
                      if (!planting.isReady(now))
                        Text(
                          l10n.seedTimeLeft(
                            planting.remaining(now).inMinutes,
                            planting.remaining(now).inSeconds % 60,
                          ),
                          key: const ValueKey('bed-remaining'),
                          style: const TextStyle(color: gardenGoldSoft),
                        ),
                      const SizedBox(height: 12),
                      if (stage == GrowthStage.ripe)
                        FilledButton(
                          key: const ValueKey('harvest-button'),
                          style: _buttonStyle(),
                          onPressed: _busy ? null : _harvest,
                          child: Text(
                            l10n.harvestAction,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        )
                      else
                        _SpeedUpButton(
                          planting: planting,
                          now: now,
                          balance: points.balance,
                          busy: _busy,
                          note: _note,
                          offerAd:
                              _adsLive &&
                              points.plantAdOfferAvailable(now: now),
                          onSpeedUp: _speedUp,
                          onWatchAd: _watchAd,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _harvest() async {
    if (_busy) return;
    final points = PointsScope.of(context);
    setState(() => _busy = true);
    final result = await points.harvestBed(
      bedIndex: widget.bedIndex,
      now: _now(),
    );
    if (!mounted) return;
    if (result.harvested && result.plant != null) {
      Navigator.of(context).pop(result.plant);
      return;
    }
    setState(() => _busy = false);
  }

  Future<void> _speedUp() async {
    if (_busy) return;
    final points = PointsScope.of(context);
    setState(() => _busy = true);
    final result = await points.speedUpPlant(
      bedIndex: widget.bedIndex,
      now: _now(),
    );
    if (!mounted) return;
    if (result.finished) {
      AnalyticsService.log('plant_speed', <String, Object>{
        'cost': result.cost,
        'bed': widget.bedIndex,
      });
    }
    setState(() => _busy = false);
  }

  Future<void> _watchAd() async {
    if (_busy) return;
    final points = PointsScope.of(context);
    final now = _now();
    if (!points.plantAdOfferAvailable(now: now)) return;
    setState(() {
      _busy = true;
      _note = null;
    });
    try {
      if (widget.showAd == null && !AdBootstrap.simulation) {
        if (!AdBootstrap.initFinished || !AdBootstrap.enabled) {
          await AdBootstrap.prepareForAdRequest();
        }
        if (!mounted) return;
        if (!AdBootstrap.available) {
          setState(() => _note = AppLocalizations.of(context).adUnavailable);
          return;
        }
      }
      final result = await (widget.showAd ?? _showRewarded)(context);
      if (!mounted) return;
      if (result != RewardedAdShowResult.earned) {
        setState(() {
          _note = result == RewardedAdShowResult.skipped
              ? AppLocalizations.of(context).rewardNotEarned
              : AppLocalizations.of(context).adUnavailable;
        });
        return;
      }
      final harvested = await points.collectPlantForAd(
        bedIndex: widget.bedIndex,
        now: _now(),
      );
      if (!mounted) return;
      if (harvested.harvested && harvested.plant != null) {
        unawaited(
          AnalyticsService.log('plant_ad_harvest', <String, Object>{
            'bed': widget.bedIndex,
          }),
        );
        Navigator.of(context).pop(harvested.plant);
        return;
      }
      setState(() {
        _note = harvested.status == HarvestStatus.adUsed
            ? AppLocalizations.of(context).plantAdUsed
            : AppLocalizations.of(context).adUnavailable;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _note = AppLocalizations.of(context).adUnavailable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _SpeedUpButton extends StatelessWidget {
  const _SpeedUpButton({
    required this.planting,
    required this.now,
    required this.balance,
    required this.busy,
    required this.offerAd,
    required this.onSpeedUp,
    required this.onWatchAd,
    this.note,
  });

  final Planting planting;
  final DateTime now;
  final int balance;
  final bool busy;
  final bool offerAd;
  final String? note;
  final VoidCallback onSpeedUp;
  final VoidCallback onWatchAd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cost = SeedCatalog.speedUpCost(planting.remaining(now));
    final shortfall = (cost - balance).clamp(0, cost);
    final canSpeed = !busy && shortfall == 0 && cost > 0;
    return Column(
      children: [
        if (shortfall > 0) ...[
          Text(
            l10n.pointsShortfall(shortfall),
            key: const ValueKey('bed-speed-shortfall'),
            style: const TextStyle(
              color: gardenGoldSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton(
          key: const ValueKey('bed-speed-button'),
          style: _buttonStyle(),
          onPressed: canSpeed ? onSpeedUp : null,
          child: Text(
            l10n.speedUpFor(cost),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        if (offerAd) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            key: const ValueKey('bed-ad-harvest'),
            style: OutlinedButton.styleFrom(
              foregroundColor: gardenGoldSoft,
              side: const BorderSide(color: gardenGoldSoft),
              minimumSize: const Size.fromHeight(46),
            ),
            onPressed: busy ? null : onWatchAd,
            child: Text(
              l10n.watchAdHarvest,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
        if (note != null) ...[
          const SizedBox(height: 8),
          Text(
            note!,
            key: const ValueKey('bed-ad-note'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: gardenGoldSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

/// Склад собранных растений. Семена и растущие грядки сюда не входят.
Future<bool> showWarehouse(BuildContext context, {bool showcase = true}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (ctx) {
      return WarehouseSheet(
        height: MediaQuery.sizeOf(ctx).height * 0.78,
        showcase: showcase,
      );
    },
  ).then((value) => value ?? false);
}

class WarehouseSheet extends StatefulWidget {
  const WarehouseSheet({super.key, required this.height, this.showcase = true});

  final double height;

  /// Кнопка витрины появляется вместе с соседями.
  final bool showcase;

  @override
  State<WarehouseSheet> createState() => _WarehouseSheetState();
}

class _WarehouseSheetState extends State<WarehouseSheet> {
  var _sort = PlantSort.received;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final points = PointsScope.of(context);
    return ListenableBuilder(
      listenable: points,
      builder: (context, _) {
        final plants = points.garden.warehouse;
        final stacks = stackPlants(plants, sort: _sort);
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: gardenWood,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: widget.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(child: _grabber()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      l10n.warehouseTitle,
                      key: const ValueKey('warehouse-title'),
                      style: const TextStyle(
                        color: gardenGoldSoft,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                    child: Text(
                      '${plants.length}',
                      key: const ValueKey('warehouse-count'),
                      style: const TextStyle(
                        color: gardenIvory,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton.icon(
                      key: const ValueKey('warehouse-cross'),
                      style: TextButton.styleFrom(
                        foregroundColor: gardenGoldSoft,
                      ),
                      onPressed:
                          plants.length >= 2 || points.garden.pending != null
                          ? () => showPlantCross(context)
                          : null,
                      icon: const Icon(Icons.spa_outlined),
                      label: Text(
                        points.garden.pending == null
                            ? l10n.crossOpen
                            : l10n.crossWaiting,
                      ),
                    ),
                  ),
                  if (widget.showcase)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextButton.icon(
                        key: const ValueKey('warehouse-showcase'),
                        style: TextButton.styleFrom(
                          foregroundColor: gardenGoldSoft,
                        ),
                        onPressed: () => openPlantShowcase(context, mine: true),
                        icon: const Icon(Icons.public),
                        label: Text(l10n.showcaseManage),
                      ),
                    ),
                  if (plants.isEmpty)
                    Expanded(
                      child: _EmptyWarehouse(
                        onOpenGarden: () => Navigator.of(context).pop(true),
                      ),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _SortChip(
                            label: l10n.seedSortTime,
                            selected: _sort == PlantSort.received,
                            onTap: () =>
                                setState(() => _sort = PlantSort.received),
                          ),
                          _SortChip(
                            label: l10n.seedSortPower,
                            selected: _sort == PlantSort.power,
                            onTap: () =>
                                setState(() => _sort = PlantSort.power),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.86,
                            ),
                        itemCount: stacks.length,
                        itemBuilder: (context, index) {
                          final stack = stacks[index];
                          return _PlantStackCard(
                            stack: stack,
                            onTap: () => _showDetails(context, stack),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDetails(BuildContext context, PlantStack stack) {
    final l10n = AppLocalizations.of(context);
    final plant = stack.newest;
    final material = MaterialLocalizations.of(context);
    String stamp(DateTime time) {
      final local = time.toLocal();
      return '${material.formatShortDate(local)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
    }

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          key: const ValueKey('plant-details'),
          backgroundColor: gardenWood,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: gardenGold.withValues(alpha: 0.7)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => showPlantCard(ctx, plant.species),
                child: PlantArt(
                  species: plant.species,
                  stage: GrowthStage.ripe,
                  size: 140,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.seedName(plant.species),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: gardenIvory,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.seedClassName(plant.species.seedClass),
                style: const TextStyle(color: gardenIvory),
              ),
              Text(
                l10n.plantPower(GardenCatalog.foodFor(plant.species)),
                style: const TextStyle(color: gardenIvory),
              ),
              if (plant.trait != null)
                Text(
                  l10n.plantTraitLabel(plant.trait!),
                  key: const ValueKey('plant-detail-trait'),
                  style: const TextStyle(color: gardenGoldSoft),
                ),
              if (plant.variant != null)
                Text(
                  l10n.plantVariant(plant.variant!),
                  key: const ValueKey('plant-detail-variant'),
                  style: const TextStyle(color: gardenIvory),
                ),
              Text(
                plant.lineage == null
                    ? l10n.plantOrigin(plant.source)
                    : '${l10n.socialGrownTogether} ${plant.lineage!.partnerName}',
                key: const ValueKey('plant-detail-origin'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: gardenGoldSoft),
              ),
              Text(
                l10n.plantedOn(stamp(plant.plantedAt)),
                style: const TextStyle(color: gardenIvory),
              ),
              Text(
                l10n.maturedOn(stamp(plant.maturedAt)),
                style: const TextStyle(color: gardenIvory),
              ),
              Text(
                l10n.harvestedOn(stamp(plant.harvestedAt)),
                key: const ValueKey('plant-detail-harvested'),
                style: const TextStyle(color: gardenIvory),
              ),
              if (stack.count > 1)
                Text(
                  l10n.seedGroupCount(stack.count),
                  style: const TextStyle(color: gardenGoldSoft),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PlantStackCard extends StatelessWidget {
  const _PlantStackCard({required this.stack, required this.onTap});

  final PlantStack stack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final variant = stack.variant ?? '';
    return Semantics(
      button: true,
      label: l10n.seedStackLabel(
        l10n.seedName(stack.species),
        stack.power,
        stack.count,
      ),
      child: Material(
        color: const Color(0xFF2A1A10),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: ValueKey(
            'plant-stack-${stack.species.name}-${stack.power}-$variant${stack.trait == null ? '' : '-${stack.trait!.name}'}',
          ),
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: PlantArt(
                    species: stack.species,
                    stage: GrowthStage.ripe,
                  ),
                ),
                Text(
                  l10n.seedName(stack.species),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: gardenIvory,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l10n.plantPower(GardenCatalog.foodFor(stack.species)),
                  style: const TextStyle(color: gardenGoldSoft, fontSize: 12),
                ),
                Text(
                  l10n.seedGroupCount(stack.count),
                  style: const TextStyle(color: gardenIvory),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyWarehouse extends StatelessWidget {
  const _EmptyWarehouse({required this.onOpenGarden});

  final VoidCallback onOpenGarden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.warehouseEmptyBody,
            key: const ValueKey('warehouse-empty'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: gardenIvory, height: 1.35),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('warehouse-open-garden'),
            style: _buttonStyle(),
            onPressed: onOpenGarden,
            child: Text(
              l10n.openGarden,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF6B3E24),
      labelStyle: const TextStyle(color: gardenIvory),
      backgroundColor: const Color(0xFF2A1A10),
      side: BorderSide(color: gardenGold.withValues(alpha: 0.7)),
    );
  }
}

Widget _grabber() {
  return Container(
    width: 42,
    height: 4,
    decoration: BoxDecoration(
      color: gardenGold.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

ButtonStyle _buttonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: const Color(0xFF6B3E24),
    foregroundColor: gardenGoldSoft,
    disabledBackgroundColor: const Color(0xFF4A3424),
    disabledForegroundColor: gardenGoldSoft,
    minimumSize: const Size.fromHeight(46),
  );
}
