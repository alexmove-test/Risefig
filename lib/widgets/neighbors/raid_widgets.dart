import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/garden.dart';
import '../../models/neighbor_request.dart';
import '../../models/raid_help.dart';
import '../garden/plant_art.dart';
import 'neighbor_copy.dart';
import 'neighbor_requests_section.dart';
import 'neighbors_style.dart';

class RaidDefenseChoice {
  const RaidDefenseChoice({
    required this.defense,
    required this.phrase,
    this.destroyId,
  });

  final RaidDefenseOption defense;
  final NeighborPhrase phrase;
  final String? destroyId;
}

/// Беззащитный двор: ни своего питомца, ни помощников.
const noRaidDefense = RaidDefenseOption(
  source: RaidDefenseSource.own,
  power: 0,
);

String raidDefenseLabel(AppLocalizations l10n, RaidDefenseOption option) {
  final pet = option.pet;
  return switch (option.source) {
    RaidDefenseSource.own || RaidDefenseSource.auto =>
      pet == null
          ? l10n.neighborsRaidOptionNone
          : l10n.neighborsRaidOptionOwn(l10n.petName(pet), option.power),
    RaidDefenseSource.guard => l10n.neighborsRaidOptionGuard(
      option.helperName ?? '',
      option.power,
    ),
    RaidDefenseSource.help => l10n.neighborsRaidOptionHelp(
      option.helperName ?? '',
      option.power,
    ),
  };
}

/// Выбор защитника и, если двор не устоит, растения, которое сгорит.
Future<RaidDefenseChoice?> showRaidDefenseSheet(
  BuildContext context, {
  required NeighborRequest raid,
  required String headline,
  required List<RaidDefenseOption> options,
  required List<HarvestedPlant> plants,
}) {
  return showModalBottomSheet<RaidDefenseChoice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (_) => RaidDefenseSheet(
      raid: raid,
      headline: headline,
      options: options,
      plants: plants,
    ),
  );
}

class RaidDefenseSheet extends StatefulWidget {
  const RaidDefenseSheet({
    super.key,
    required this.raid,
    required this.headline,
    required this.options,
    required this.plants,
  });

  final NeighborRequest raid;
  final String headline;
  final List<RaidDefenseOption> options;
  final List<HarvestedPlant> plants;

  @override
  State<RaidDefenseSheet> createState() => _RaidDefenseSheetState();
}

class _RaidDefenseSheetState extends State<RaidDefenseSheet> {
  late RaidDefenseOption _defense = widget.options.isEmpty
      ? noRaidDefense
      : widget.options.first;
  late String? _destroyId = planRaidLoss(
    opId: widget.raid.raidOpId,
    plants: widget.plants,
  ).destroyed?.id;
  NeighborPhrase _phrase = NeighborRequestRules.replies.first;

  int get _attack => widget.raid.power ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final holds = _defense.holds(_attack);
    final deadline = widget.raid.raidDeadline;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: NeighborsPalette.wood,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              key: const ValueKey('raid-defense'),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                Text(
                  l10n.neighborsRaidDefendTitle,
                  style: const TextStyle(
                    color: NeighborsPalette.danger,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.headline,
                  style: const TextStyle(color: NeighborsPalette.ivory),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.neighborsRaidDefendRule(_attack),
                  style: const TextStyle(
                    color: NeighborsPalette.goldSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (deadline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.neighborsRaidDeadline(
                      formatNeighborTime(context, deadline),
                    ),
                    style: TextStyle(
                      color: NeighborsPalette.ivory.withValues(alpha: 0.72),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                if (widget.options.isEmpty)
                  Text(
                    l10n.neighborsRaidNoDefenders,
                    key: const ValueKey('raid-defense-none'),
                    style: const TextStyle(color: NeighborsPalette.ivory),
                  )
                else
                  for (final option in widget.options)
                    _DefenderTile(
                      option: option,
                      attack: _attack,
                      selected: option.key == _defense.key,
                      onTap: () => setState(() => _defense = option),
                    ),
                if (!holds) ...[
                  const SizedBox(height: 14),
                  ..._lossSection(l10n),
                ],
                const SizedBox(height: 14),
                Text(
                  l10n.neighborsChoosePhrase,
                  style: const TextStyle(
                    color: NeighborsPalette.goldSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final phrase in NeighborRequestRules.replies)
                      ChoiceChip(
                        key: ValueKey('neighbors-phrase-${phrase.name}'),
                        label: Text(neighborPhraseLabel(l10n, phrase)),
                        selected: _phrase == phrase,
                        onSelected: (_) => setState(() => _phrase = phrase),
                        selectedColor: NeighborsPalette.woodTop,
                        backgroundColor: const Color(0xFF3A2418),
                        labelStyle: const TextStyle(
                          color: NeighborsPalette.ivory,
                        ),
                        checkmarkColor: NeighborsPalette.goldSoft,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton(
                  key: const ValueKey('raid-defense-confirm'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6E241C),
                    foregroundColor: NeighborsPalette.danger,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => Navigator.of(context).pop(
                    RaidDefenseChoice(
                      defense: _defense,
                      phrase: _phrase,
                      destroyId: holds ? null : _destroyId,
                    ),
                  ),
                  child: Text(
                    holds ? l10n.neighborsRepel : l10n.neighborsRaidAcceptLoss,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(color: NeighborsPalette.ivory),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _lossSection(AppLocalizations l10n) {
    final plants = widget.plants;
    const style = TextStyle(color: NeighborsPalette.ivory);
    if (plants.isEmpty) {
      return [Text(l10n.neighborsRaidEmptyStorage, style: style)];
    }
    if (plants.length == 1) {
      return [
        Text(
          l10n.neighborsRaidOnlyPlant(l10n.seedName(plants.single.species)),
          style: style,
        ),
      ];
    }
    return [
      Text(
        l10n.neighborsRaidChooseLoss,
        key: const ValueKey('raid-defense-loss'),
        style: style,
      ),
      const SizedBox(height: 8),
      for (final stack in stackPlants(plants, sort: PlantSort.power))
        _LossTile(
          stack: stack,
          selected: stack.instances.any((plant) => plant.id == _destroyId),
          onTap: () => setState(() => _destroyId = stack.instances.first.id),
        ),
    ];
  }
}

class _DefenderTile extends StatelessWidget {
  const _DefenderTile({
    required this.option,
    required this.attack,
    required this.selected,
    required this.onTap,
  });

  final RaidDefenseOption option;
  final int attack;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final holds = option.holds(attack);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? const Color(0xFF5A3A22) : const Color(0xFF2A1A10),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            key: ValueKey('raid-defender-${option.key}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    holds ? Icons.shield_rounded : Icons.shield_outlined,
                    color: holds
                        ? NeighborsPalette.goldSoft
                        : NeighborsPalette.danger,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      raidDefenseLabel(l10n, option),
                      style: const TextStyle(
                        color: NeighborsPalette.ivory,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    holds ? l10n.neighborsRaidHolds : l10n.neighborsRaidFalls,
                    style: TextStyle(
                      color: holds
                          ? NeighborsPalette.goldSoft
                          : NeighborsPalette.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.check_circle,
                      color: NeighborsPalette.goldSoft,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LossTile extends StatelessWidget {
  const _LossTile({
    required this.stack,
    required this.selected,
    required this.onTap,
  });

  final PlantStack stack;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trait = stack.trait;
    final name = trait == null
        ? l10n.seedName(stack.species)
        : '${l10n.seedName(stack.species)} · ${l10n.plantTraitLabel(trait)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? const Color(0xFF5A2A22) : const Color(0xFF2A1A10),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            key: ValueKey('raid-loss-${stack.newest.id}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  PlantArt(
                    species: stack.species,
                    stage: GrowthStage.ripe,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      stack.count > 1 ? '$name × ${stack.count}' : name,
                      style: const TextStyle(
                        color: NeighborsPalette.ivory,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: NeighborsPalette.danger,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Чужие зовы о помощи: можно отправить своего назначенного защитника.
class RaidHelpCallsSection extends StatelessWidget {
  const RaidHelpCallsSection({
    super.key,
    required this.calls,
    required this.answered,
    required this.busy,
    required this.guardPower,
    required this.onOffer,
  });

  final List<RaidHelpCall> calls;
  final Set<String> answered;
  final Set<String> busy;

  /// Сила своего назначенного защитника. null — помогать некем.
  final int? guardPower;
  final ValueChanged<RaidHelpCall> onOffer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final open = [
      for (final call in calls)
        if (call.open(now)) call,
    ];
    if (open.isEmpty) return const SizedBox.shrink();
    return Padding(
      key: const ValueKey('raid-help-calls'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF3A1814),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: NeighborsPalette.danger.withValues(alpha: 0.45),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.neighborsHelpTitle,
                style: const TextStyle(
                  color: NeighborsPalette.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
              for (final call in open) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.neighborsHelpCallLine(call.ownerName, call.attack),
                  style: const TextStyle(
                    color: NeighborsPalette.ivory,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.neighborsHelpUntil(
                    formatNeighborTime(context, call.expiresAt),
                  ),
                  style: TextStyle(
                    color: NeighborsPalette.ivory.withValues(alpha: 0.72),
                    fontSize: 13,
                  ),
                ),
                _offerAction(l10n, call),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _offerAction(AppLocalizations l10n, RaidHelpCall call) {
    final note = TextStyle(
      color: NeighborsPalette.ivory.withValues(alpha: 0.82),
      fontSize: 13,
    );
    if (answered.contains(call.raidId)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          l10n.neighborsHelpOffered,
          key: ValueKey('raid-help-offered-${call.raidId}'),
          style: const TextStyle(color: NeighborsPalette.goldSoft),
        ),
      );
    }
    final power = guardPower;
    if (power == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(l10n.neighborsHelpNeedGuard, style: note),
      );
    }
    final holds = raidHeld(attack: call.attack, defense: power);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            key: ValueKey('raid-help-offer-${call.raidId}'),
            style: FilledButton.styleFrom(
              backgroundColor: NeighborsPalette.woodTop,
              foregroundColor: NeighborsPalette.goldSoft,
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: busy.contains(call.raidId) ? null : () => onOffer(call),
            icon: const Icon(Icons.shield_rounded),
            label: Text(l10n.neighborsHelpSend(power)),
          ),
          if (!holds)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.neighborsRaidFalls, style: note),
            ),
        ],
      ),
    );
  }
}
