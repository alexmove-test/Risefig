import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/garden.dart';
import '../../models/seed_catalog.dart';
import '../seeds/seed_glyph.dart';
import 'plant_art.dart';

/// Карточка вида: семя, спелое растение и строка про Solana.
Future<void> showPlantCard(BuildContext context, SeedSpecies species) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return Dialog(
        key: const ValueKey('plant-keepsake-card'),
        backgroundColor: const Color(0xFFFFFAF3),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SeedGlyph(size: 72, species: species),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.seedName(species),
                        style: const TextStyle(
                          color: Color(0xFF241C16),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                PlantArt(
                  species: species,
                  stage: GrowthStage.ripe,
                  size: 220,
                ),
                Text(
                  l10n.seedClassName(species.seedClass),
                  style: const TextStyle(color: Color(0xFF6D5848)),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.seedBlurb(species),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF241C16),
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.plantKeepsakeLine,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2F6A45),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
