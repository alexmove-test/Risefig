import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/garden.dart';
import '../models/meta_features.dart';
import '../models/plant_listing.dart';
import '../models/seed_catalog.dart';
import '../models/neighbor_social.dart';
import '../services/neighbor_actions.dart';
import '../services/neighbor_records.dart';
import '../services/neighbor_request_repository.dart';
import '../services/raid_help_repository.dart';
import '../services/firebase_neighbor_directory.dart';
import '../services/social_repository.dart';
import '../services/ugc_block_store.dart';
import '../widgets/neighbors/neighbors_panel.dart';
import '../services/plant_showcase_controller.dart';
import '../services/plant_showcase_repository.dart';
import '../services/points_controller.dart';
import '../services/ugc_report_repository.dart';
import '../widgets/feature_intro_card.dart';
import '../widgets/garden/plant_art.dart';
import '../widgets/garden/plant_card.dart';

Future<void> openPlantShowcase(
  BuildContext context, {
  bool mine = false,
  Future<void> Function(PlantListing)? onCross,
}) async {
  await showFeatureIntroOnce(context, MetaFeature.showcase);
  if (!context.mounted) return;
  final points = PointsScope.of(context);
  final reduced = MediaQuery.disableAnimationsOf(context);
  final selected = await Navigator.of(context).push<PlantListing>(
    PageRouteBuilder<PlantListing>(
      transitionDuration: reduced
          ? Duration.zero
          : const Duration(milliseconds: 260),
      reverseTransitionDuration: reduced
          ? Duration.zero
          : const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) =>
          PlantShowcaseScreen(points: points, initiallyMine: mine),
      transitionsBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
  );
  if (selected == null || !context.mounted) return;
  if (onCross != null) {
    await onCross(selected);
    return;
  }
  final acquaintances = await AcquaintanceStore.open();
  final notices = await NeighborNoticeStore.open();
  final history = await NeighborHistoryStore.open();
  final blocks = await UgcBlockStore.open();
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (routeContext) => PointsScope(
        controller: points,
        child: NeighborsOverlay(
          visible: true,
          directory: FirebaseNeighborDirectory(),
          acquaintances: acquaintances,
          notices: notices,
          history: history,
          blocks: blocks,
          gateway: const UnavailableNeighborGateway(),
          requests: FirebaseNeighborRequestRepository(),
          raidHelp: FirebaseRaidHelpRepository(),
          social: FirebaseSocialRepository(),
          initialPerson: NeighborPerson(
            id: selected.ownerId,
            name: selected.ownerName,
            stars: 0,
            levelsUnlocked: 0,
            progressKnown: false,
          ),
          initialCross: true,
          onClose: () => Navigator.of(routeContext).pop(),
          onObscuring: (_) {},
        ),
      ),
    ),
  );
}

class PlantShowcaseScreen extends StatefulWidget {
  const PlantShowcaseScreen({
    super.key,
    required this.points,
    this.repository,
    this.initiallyMine = false,
  });

  final PointsController points;
  final PlantShowcaseRepository? repository;
  final bool initiallyMine;

  @override
  State<PlantShowcaseScreen> createState() => _PlantShowcaseScreenState();
}

class _PlantShowcaseScreenState extends State<PlantShowcaseScreen> {
  late final PlantShowcaseController _controller;
  late bool _mine;

  @override
  void initState() {
    super.initState();
    _mine = widget.initiallyMine;
    _controller = PlantShowcaseController(
      points: widget.points,
      repository: widget.repository ?? FirebasePlantShowcaseRepository(),
    );
    unawaited(_controller.refresh());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: gardenGold,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: gardenWood,
        appBarTheme: const AppBarTheme(
          backgroundColor: gardenWood,
          foregroundColor: gardenIvory,
        ),
      ),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => PopScope(
          canPop: !_controller.busy,
          child: Scaffold(
            key: const ValueKey('plant-showcase-screen'),
            appBar: AppBar(
              leading: IconButton(
                tooltip: l10n.close,
                onPressed: _controller.busy
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
              title: Text(l10n.showcaseTitle),
              actions: [
                IconButton(
                  tooltip: l10n.showcaseRefresh,
                  onPressed:
                      _controller.busy ||
                          _controller.loading ||
                          _controller.loadingMore
                      ? null
                      : _controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _tab(l10n.showcaseAll, false)),
                        const SizedBox(width: 8),
                        Expanded(child: _tab(l10n.showcaseMine, true)),
                      ],
                    ),
                  ),
                  if (_controller.loading ||
                      _controller.busy ||
                      _controller.loadingMore)
                    const LinearProgressIndicator(minHeight: 3),
                  if (_controller.error != null) _error(l10n),
                  Expanded(
                    child: IndexedStack(
                      index: _mine ? 1 : 0,
                      children: [_publicList(l10n), _myList(l10n)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, bool mine) => Semantics(
    selected: _mine == mine,
    child: OutlinedButton(
      key: ValueKey(mine ? 'showcase-tab-mine' : 'showcase-tab-all'),
      style: OutlinedButton.styleFrom(
        backgroundColor: _mine == mine ? const Color(0xFF6B3E24) : null,
        foregroundColor: gardenIvory,
        minimumSize: const Size(0, 48),
      ),
      onPressed: () => setState(() => _mine = mine),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );

  Widget _error(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: Text(
      switch (_controller.error!) {
        ShowcaseError.unavailable => l10n.showcaseUnavailable,
        ShowcaseError.load => l10n.showcaseLoadFailed,
        ShowcaseError.operation => l10n.showcaseOperationFailed,
      },
      key: const ValueKey('showcase-error'),
      style: const TextStyle(color: gardenGoldSoft),
    ),
  );

  Widget _publicList(AppLocalizations l10n) => ListView(
    key: const PageStorageKey('showcase-public'),
    padding: const EdgeInsets.all(16),
    children: [
      Text(l10n.showcaseIntro, style: const TextStyle(color: gardenGoldSoft)),
      const SizedBox(height: 12),
      if (!_controller.loading &&
          _controller.items.isEmpty &&
          _controller.error == null)
        _empty(
          l10n.showcaseEmpty,
          l10n.showcaseChoose,
          () => setState(() => _mine = true),
        ),
      for (final item in _controller.items)
        _card(
          key: ValueKey('public-plant-${item.id}'),
          species: item.species,
          power: item.power,
          subtitle: item.ownerId == _controller.identity?.id
              ? '${item.ownerName} · ${l10n.you}'
              : item.ownerName,
          status: l10n.showcasePublished,
          actions: item.ownerId == _controller.identity?.id
              ? [_removeButton(item.plantId, l10n)]
              : [
                  FilledButton.icon(
                    key: ValueKey('showcase-cross-${item.id}'),
                    onPressed: () => Navigator.of(context).pop(item),
                    icon: const Icon(Icons.local_florist_outlined),
                    label: Text(l10n.neighborsActionCross),
                  ),
                  PopupMenuButton<String>(
                    tooltip: l10n.reportPlayer,
                    onSelected: (action) async {
                      if (action == 'hide') {
                        await _controller.hideOwner(item.ownerId);
                      } else {
                        await _report(item);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'hide',
                        child: Text(l10n.hidePlayer),
                      ),
                      PopupMenuItem(
                        value: 'report',
                        child: Text(l10n.reportName),
                      ),
                    ],
                  ),
                ],
        ),
      if (_controller.hasMore)
        OutlinedButton(
          key: const ValueKey('showcase-more'),
          onPressed:
              _controller.loadingMore || _controller.loading || _controller.busy
              ? null
              : _controller.loadMore,
          child: Text(l10n.showcaseMore),
        ),
      if (_controller.error != null)
        OutlinedButton(
          onPressed: _controller.loading || _controller.busy
              ? null
              : _controller.refresh,
          child: Text(l10n.retry),
        ),
    ],
  );

  Widget _myList(AppLocalizations l10n) {
    final plants = [...widget.points.garden.warehouse]
      ..sort((a, b) => b.harvestedAt.compareTo(a.harvestedAt));
    final localIds = plants.map((plant) => plant.id).toSet();
    final remoteOnly = _controller.mine.values.where(
      (item) => !localIds.contains(item.plantId),
    );
    return ListView(
      key: const PageStorageKey('showcase-mine'),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.showcaseMyIntro,
          style: const TextStyle(color: gardenGoldSoft),
        ),
        const SizedBox(height: 12),
        if (plants.isEmpty && remoteOnly.isEmpty)
          _empty(
            l10n.showcaseNoPlants,
            l10n.close,
            () => Navigator.of(context).pop(),
          ),
        for (var index = 0; index < plants.length; index++)
          _ownPlant(plants[index], index + 1, l10n),
        for (final item in remoteOnly)
          _card(
            key: ValueKey('remote-plant-${item.plantId}'),
            species: item.species,
            power: item.power,
            subtitle: l10n.showcaseMissingLocal,
            status: l10n.showcasePublished,
            actions: [_removeButton(item.plantId, l10n)],
          ),
      ],
    );
  }

  Widget _ownPlant(HarvestedPlant plant, int number, AppLocalizations l10n) {
    final published = _controller.mine.containsKey(plant.id);
    final locked = widget.points.showcaseReservations.containsKey(plant.id);
    final date = MaterialLocalizations.of(
      context,
    ).formatShortDate(plant.harvestedAt.toLocal());
    return _card(
      key: ValueKey('own-plant-${plant.id}'),
      species: plant.species,
      power: GardenCatalog.foodFor(plant.species),
      subtitle:
          '${l10n.showcaseSpecimen(number)} · ${l10n.harvestedOn(date)}'
          '${plant.lineage == null ? '' : '\n${l10n.socialGrownTogether} ${plant.lineage!.partnerName}'}',
      status: published
          ? l10n.showcasePublished
          : locked
          ? l10n.showcaseUnconfirmed
          : l10n.showcasePrivate,
      actions: [
        if (!published)
          FilledButton.icon(
            key: ValueKey('publish-${plant.id}'),
            onPressed: _controller.canAct
                ? () async {
                    final saved = await _controller.publish(plant);
                    if (saved && mounted) _notice(l10n.showcasePublishedNotice);
                  }
                : null,
            icon: Icon(locked ? Icons.refresh : Icons.public),
            label: Text(locked ? l10n.retry : l10n.showcasePublish),
          ),
        if (published || locked) _removeButton(plant.id, l10n),
      ],
    );
  }

  Widget _removeButton(String plantId, AppLocalizations l10n) =>
      OutlinedButton.icon(
        key: ValueKey('withdraw-$plantId'),
        onPressed: _controller.canAct
            ? () async {
                final removed = await _controller.remove(plantId);
                if (removed && mounted) _notice(l10n.showcaseRemovedNotice);
              }
            : null,
        icon: const Icon(Icons.remove_circle_outline),
        label: Text(l10n.showcaseWithdraw),
      );

  Widget _card({
    required Key key,
    required SeedSpecies species,
    required int power,
    required String subtitle,
    required String status,
    required List<Widget> actions,
  }) {
    final l10n = AppLocalizations.of(context);
    return Card(
      key: key,
      color: const Color(0xFF49301E),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => showPlantCard(context, species),
                  child: PlantArt(
                    species: species,
                    stage: GrowthStage.ripe,
                    size: 64,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.seedName(species),
                        style: const TextStyle(
                          color: gardenIvory,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${l10n.seedClassName(species.seedClass)} · ${l10n.plantPower(power)}',
                        style: const TextStyle(color: gardenGoldSoft),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(color: gardenIvory),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(status, style: const TextStyle(color: gardenGoldSoft)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 4, children: actions),
          ],
        ),
      ),
    );
  }

  Widget _empty(String text, String action, VoidCallback onPressed) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        const Icon(
          Icons.local_florist_outlined,
          size: 48,
          color: gardenGoldSoft,
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: gardenIvory),
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onPressed, child: Text(action)),
      ],
    ),
  );

  void _notice(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _report(PlantListing item) async {
    final sent = await UgcReportRepository.submit(
      targetUid: item.ownerId,
      targetName: item.ownerName,
      reason: UgcReportRepository.reasonName,
    ).timeout(const Duration(seconds: 15), onTimeout: () => false);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    _notice(sent ? l10n.reportThanks : l10n.showcaseLoadFailed);
  }
}
