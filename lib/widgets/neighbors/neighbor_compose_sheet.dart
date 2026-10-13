import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/garden.dart';
import '../../models/neighbor_request.dart';
import '../../models/seed_catalog.dart';
import '../garden/plant_art.dart';
import 'neighbor_copy.dart';
import 'neighbors_style.dart';

class NeighborComposeResult {
  const NeighborComposeResult({required this.phrase, this.species});

  final NeighborPhrase phrase;
  final SeedSpecies? species;
}

/// Фраза и, для скрещивания, вид своего растения. Отправку делает вызывающий.
Future<NeighborComposeResult?> showNeighborComposeSheet(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required List<NeighborPhrase> phrases,
  String? explain,
  String? detail,
  Map<SeedSpecies, int>? plants,
  bool danger = false,
}) {
  return showModalBottomSheet<NeighborComposeResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (ctx) => NeighborComposeSheet(
      title: title,
      confirmLabel: confirmLabel,
      phrases: phrases,
      explain: explain,
      detail: detail,
      plants: plants,
      danger: danger,
    ),
  );
}

class NeighborComposeSheet extends StatefulWidget {
  const NeighborComposeSheet({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.phrases,
    this.explain,
    this.detail,
    this.plants,
    this.danger = false,
  });

  final String title;
  final String confirmLabel;
  final List<NeighborPhrase> phrases;
  final String? explain;
  final String? detail;
  final Map<SeedSpecies, int>? plants;
  final bool danger;

  @override
  State<NeighborComposeSheet> createState() => _NeighborComposeSheetState();
}

class _NeighborComposeSheetState extends State<NeighborComposeSheet> {
  late NeighborPhrase _phrase = widget.phrases.first;
  SeedSpecies? _species;

  @override
  void initState() {
    super.initState();
    final plants = widget.plants;
    if (plants != null && plants.length == 1) _species = plants.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plants = widget.plants;
    final ready = plants == null || _species != null;
    final accent = widget.danger
        ? NeighborsPalette.danger
        : NeighborsPalette.goldSoft;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: NeighborsPalette.wood,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              key: const ValueKey('neighbors-compose'),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                if (widget.explain != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.explain!,
                    style: const TextStyle(color: NeighborsPalette.ivory),
                  ),
                ],
                if (widget.detail != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.detail!,
                    key: const ValueKey('neighbors-compose-detail'),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (plants != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    l10n.neighborsChoosePlant,
                    style: const TextStyle(
                      color: NeighborsPalette.goldSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final entry in plants.entries)
                    _PlantChoice(
                      species: entry.key,
                      count: entry.value,
                      selected: _species == entry.key,
                      onTap: () => setState(() => _species = entry.key),
                    ),
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
                    for (final phrase in widget.phrases)
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
                        side: BorderSide(
                          color: NeighborsPalette.gold.withValues(
                            alpha: _phrase == phrase ? 0.9 : 0.35,
                          ),
                        ),
                        checkmarkColor: NeighborsPalette.goldSoft,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton(
                  key: const ValueKey('neighbors-compose-send'),
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.danger
                        ? const Color(0xFF6E241C)
                        : NeighborsPalette.woodTop,
                    foregroundColor: accent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: ready
                      ? () => Navigator.of(context).pop(
                          NeighborComposeResult(
                            phrase: _phrase,
                            species: _species,
                          ),
                        )
                      : null,
                  child: Text(widget.confirmLabel),
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
}

class _PlantChoice extends StatelessWidget {
  const _PlantChoice({
    required this.species,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final SeedSpecies species;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? const Color(0xFF5A3A22) : const Color(0xFF2A1A10),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            key: ValueKey('neighbors-plant-${species.name}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  PlantArt(species: species, stage: GrowthStage.ripe, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      count > 1
                          ? '${l10n.seedName(species)} × $count'
                          : l10n.seedName(species),
                      style: const TextStyle(
                        color: NeighborsPalette.ivory,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: NeighborsPalette.goldSoft,
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
