import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/garden.dart';
import '../../models/meta_features.dart';
import '../../models/plant_cross.dart';
import '../../models/seed_catalog.dart';
import '../../services/analytics_service.dart';
import '../../services/points_controller.dart';
import '../feature_intro_card.dart';
import 'plant_art.dart';

/// Скрещивание двух растений со склада. Выбор после удачи остаётся, пока его не закроют.
Future<void> showPlantCross(BuildContext context) async {
  await showFeatureIntroOnce(context, MetaFeature.cross);
  if (!context.mounted) return;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (ctx) {
      return PlantCrossSheet(height: MediaQuery.sizeOf(ctx).height * 0.78);
    },
  );
}

class PlantCrossSheet extends StatefulWidget {
  const PlantCrossSheet({super.key, required this.height});

  final double height;

  @override
  State<PlantCrossSheet> createState() => _PlantCrossSheetState();
}

class _PlantCrossSheetState extends State<PlantCrossSheet> {
  final _selected = <String>[];
  var _aim = CrossAim.combat;
  var _busy = false;
  String? _opId;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final points = PointsScope.of(context);
    return ListenableBuilder(
      listenable: points,
      builder: (context, _) {
        final pending = points.garden.pending;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: gardenWood,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: widget.height,
              child: pending == null
                  ? _picker(context, l10n, points)
                  : _choice(context, l10n, pending),
            ),
          ),
        );
      },
    );
  }

  Widget _picker(
    BuildContext context,
    AppLocalizations l10n,
    PointsController points,
  ) {
    final reserved = points.showcaseReservations;
    final plants = points.garden.warehouse;
    final first = _plant(plants, 0);
    final second = _plant(plants, 1);
    final weights = first == null || second == null
        ? null
        : weightsFor(first.species.seedClass, second.species.seedClass);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(child: _grabber()),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            l10n.crossTitle,
            key: const ValueKey('cross-title'),
            style: const TextStyle(
              color: gardenGoldSoft,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            l10n.crossNeedTwo,
            style: const TextStyle(color: gardenIvory),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            children: [
              for (final aim in CrossAim.values)
                ChoiceChip(
                  key: ValueKey('cross-aim-${aim.name}'),
                  label: Text(_aimLabel(l10n, aim)),
                  selected: _aim == aim,
                  onSelected: _busy ? null : (_) => setState(() => _aim = aim),
                ),
            ],
          ),
        ),
        if (weights != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.crossOdds(weights.ordinary, weights.raised, weights.rare),
              key: const ValueKey('cross-odds'),
              style: const TextStyle(color: gardenGoldSoft),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              _error!,
              key: const ValueKey('cross-error'),
              style: const TextStyle(color: gardenGoldSoft),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            children: [
              for (final plant in plants)
                _PlantPick(
                  plant: plant,
                  selected: _selected.contains(plant.id),
                  locked: reserved.containsKey(plant.id),
                  onTap: _busy || reserved.containsKey(plant.id)
                      ? null
                      : () => _toggle(plant.id),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(
            key: const ValueKey('cross-confirm'),
            onPressed: _busy || _selected.length != 2 ? null : _confirm,
            child: Text(l10n.crossConfirm),
          ),
        ),
      ],
    );
  }

  Widget _choice(
    BuildContext context,
    AppLocalizations l10n,
    CrossPending pending,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(child: _grabber()),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            pending.choosesTrait
                ? l10n.crossChooseTrait
                : l10n.crossChooseSpecies,
            key: const ValueKey('cross-choice-title'),
            style: const TextStyle(
              color: gardenGoldSoft,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(_error!, style: const TextStyle(color: gardenIvory)),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (pending.choosesTrait) ...[
                _ChoiceButton(
                  label: l10n.crossAttack,
                  valueKey: 'cross-attack',
                  onPressed: _busy
                      ? null
                      : () => _finish(trait: PlantTrait.attack),
                ),
                const SizedBox(height: 8),
                _ChoiceButton(
                  label: l10n.crossDefense,
                  valueKey: 'cross-defense',
                  onPressed: _busy
                      ? null
                      : () => _finish(trait: PlantTrait.defense),
                ),
              ] else
                for (final species in pending.choices) ...[
                  _ChoiceButton(
                    label: l10n.seedName(species),
                    valueKey: 'cross-species-${species.name}',
                    onPressed: _busy ? null : () => _finish(species: species),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      ],
    );
  }

  HarvestedPlant? _plant(List<HarvestedPlant> plants, int index) {
    if (_selected.length <= index) return null;
    for (final plant in plants) {
      if (plant.id == _selected[index]) return plant;
    }
    return null;
  }

  void _toggle(String id) {
    setState(() {
      _error = null;
      if (_selected.contains(id)) {
        _selected.remove(id);
        return;
      }
      if (_selected.length == 2) _selected.removeAt(0);
      _selected.add(id);
    });
  }

  Future<void> _confirm() async {
    if (_busy || _selected.length != 2) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final points = PointsScope.of(context);
    final opId = _opId ?? 'cross-${DateTime.now().microsecondsSinceEpoch}';
    _opId = opId;
    final result = await points.beginCross(
      firstId: _selected[0],
      secondId: _selected[1],
      aim: _aim,
      opId: opId,
    );
    if (!mounted) return;
    await _after(result);
  }

  Future<void> _finish({PlantTrait? trait, SeedSpecies? species}) async {
    final pending = PointsScope.of(context).garden.pending;
    if (_busy || pending == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await PointsScope.of(
      context,
    ).finishCross(opId: pending.id, trait: trait, species: species);
    if (!mounted) return;
    await _after(result);
  }

  Future<void> _after(CrossResult result) async {
    final l10n = AppLocalizations.of(context);
    if (result.status == CrossStatus.chooseTrait ||
        result.status == CrossStatus.chooseSeed) {
      setState(() => _busy = false);
      return;
    }
    if (!result.granted) {
      setState(() {
        _busy = false;
        _error = _failure(l10n, result.status);
      });
      return;
    }
    final seed = result.seed;
    AnalyticsService.log('plant_cross', {
      'aim': _aim.name,
      'band': result.band?.name ?? 'unknown',
    });
    final message = result.band == CrossBand.ordinary
        ? l10n.crossOrdinary
        : l10n.crossGranted;
    final notice = seed == null
        ? message
        : '$message ${l10n.seedName(seed.species)}';
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(notice)));
  }

  String _failure(AppLocalizations l10n, CrossStatus status) {
    return switch (status) {
      CrossStatus.listed => l10n.crossListed,
      CrossStatus.waiting => l10n.crossWaiting,
      CrossStatus.missing ||
      CrossStatus.needTwo ||
      CrossStatus.samePlant => l10n.crossNeedTwo,
      _ => l10n.crossFailed,
    };
  }
}

String _aimLabel(AppLocalizations l10n, CrossAim aim) => switch (aim) {
  CrossAim.combat => l10n.crossAimCombat,
  CrossAim.garden => l10n.crossAimGarden,
  CrossAim.seeds => l10n.crossAimSeeds,
};

class _PlantPick extends StatelessWidget {
  const _PlantPick({
    required this.plant,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final HarvestedPlant plant;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? const Color(0xFF5A3A22) : const Color(0xFF2A1A10),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: ValueKey('cross-plant-${plant.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                PlantArt(
                  species: plant.species,
                  stage: GrowthStage.ripe,
                  size: 42,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.seedName(plant.species),
                    style: const TextStyle(
                      color: gardenIvory,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (locked)
                  const Icon(Icons.public, color: gardenGoldSoft, size: 18)
                else if (selected)
                  const Icon(Icons.check_circle, color: gardenGoldSoft),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.valueKey,
    required this.onPressed,
  });

  final String label;
  final String valueKey;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: ValueKey(valueKey),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

Widget _grabber() {
  return Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: gardenGold.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
