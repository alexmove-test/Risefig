import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/garden.dart';
import '../../models/seed_batch.dart';
import '../../models/seed_catalog.dart';
import '../courtyard/courtyard_world_layout.dart';
import '../seeds/seed_glyph.dart';
import 'plant_portrait.dart';

const gardenIvory = Color(0xFFF8F1DE);
const gardenGold = Color(0xFFD4AF37);
const gardenGoldSoft = Color(0xFFE8C96A);
const gardenWood = Color(0xFF3A2012);
const gardenSoil = Color(0xFF6A4428);

Color plantColor(SeedSpecies species) => switch (species) {
  SeedSpecies.amberbell => const Color(0xFFE2A53A),
  SeedSpecies.mistfern => const Color(0xFF3E8F62),
  SeedSpecies.glassreed => const Color(0xFF7EC8D4),
  SeedSpecies.crimsonplum => const Color(0xFFB44A55),
  SeedSpecies.nightlotus => const Color(0xFF8E74C9),
  SeedSpecies.starbamboo => const Color(0xFF2F8F6B),
};

/// Растение на грядке. Стадия читается из сохранённого времени, не из таймера.
class PlantArt extends StatelessWidget {
  const PlantArt({
    super.key,
    required this.species,
    required this.stage,
    this.size = 36,
  });

  final SeedSpecies species;
  final GrowthStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (stage == GrowthStage.sown) {
      return SeedGlyph(size: size, species: species);
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlantPainter(species: species, stage: stage),
      ),
    );
  }
}

class _PlantPainter extends CustomPainter {
  const _PlantPainter({required this.species, required this.stage});

  final SeedSpecies species;
  final GrowthStage stage;

  @override
  void paint(Canvas canvas, Size size) {
    paintGrownPlant(canvas, size, species, stage);
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) =>
      oldDelegate.species != species || oldDelegate.stage != stage;
}

class GardenBedView extends StatefulWidget {
  const GardenBedView({
    super.key,
    required this.index,
    required this.planting,
    required this.onTap,
    this.now,
  });

  final int index;
  final Planting? planting;
  final VoidCallback? onTap;
  final DateTime Function()? now;

  @override
  State<GardenBedView> createState() => _GardenBedViewState();
}

class _GardenBedViewState extends State<GardenBedView>
    with WidgetsBindingObserver {
  Timer? _timer;

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant GardenBedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(_syncTicker);
    }
  }

  void _syncTicker() {
    final planting = widget.planting;
    final ticking =
        widget.now == null && planting != null && !planting.isReady(_now());
    if (!ticking) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_syncTicker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final planting = widget.planting;
    final now = _now();
    final stage = planting == null ? null : stageOf(planting, now);
    final ready = stage == GrowthStage.ripe;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final number = widget.index + 1;
    final label = planting == null || stage == null
        ? l10n.gardenBedEmpty(number)
        : l10n.gardenBedLabel(
            number: number,
            name: l10n.seedName(planting.species),
            stage: l10n.growthStage(stage),
            time: formatSeedCountdown(planting.remaining(now)),
            ready: ready,
          );
    return Semantics(
      button: widget.onTap != null,
      label: label,
      child: GestureDetector(
        key: ValueKey('garden-bed-${widget.index}'),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ExcludeSemantics(
          child: LayoutBuilder(
            builder: (context, box) {
              final side = math.min(box.maxWidth, box.maxHeight);
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (ready)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              gardenGoldSoft.withValues(
                                alpha: reduced ? 0.35 : 0.55,
                              ),
                              gardenGoldSoft.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (planting == null || stage == null)
                    _EmptyBedMark(size: side * 0.62)
                  else
                    Positioned.fill(
                      bottom: box.maxHeight * 0.14,
                      child: FittedBox(
                        child: PlantArt(
                          species: planting.species,
                          stage: stage,
                        ),
                      ),
                    ),
                  if (ready)
                    Positioned(
                      bottom: -2,
                      child: _BedTag(
                        key: ValueKey('garden-ready-${widget.index}'),
                        text: l10n.harvestMark,
                        highlight: true,
                      ),
                    )
                  else if (planting != null && stage != null)
                    Positioned(
                      bottom: -2,
                      child: _BedTag(
                        text: formatSeedCountdown(planting.remaining(now)),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Пустая грядка: земля уже на подложке, поверх только приглашение посадить.
class _EmptyBedMark extends StatelessWidget {
  const _EmptyBedMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gardenWood.withValues(alpha: 0.45),
        border: Border.all(color: gardenGoldSoft.withValues(alpha: 0.8)),
      ),
      child: const FittedBox(
        child: Icon(Icons.add_rounded, color: gardenGoldSoft),
      ),
    );
  }
}

class _BedTag extends StatelessWidget {
  const _BedTag({super.key, required this.text, this.highlight = false});

  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlight
            ? gardenGold.withValues(alpha: 0.95)
            : gardenWood.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            color: highlight ? gardenWood : gardenIvory,
            fontSize: highlight ? 8 : 7,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class WarehouseBuilding extends StatelessWidget {
  const WarehouseBuilding({
    super.key,
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: onTap != null,
      label: l10n.warehouseSemantic(count),
      child: GestureDetector(
        key: const ValueKey('courtyard-warehouse'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ExcludeSemantics(
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final h = box.maxHeight;
              final badge = math.max(14.0, w * 0.2);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(
                    child: Image(
                      image: AssetImage(CourtyardWorldLayout.warehouseAsset),
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      filterQuality: FilterQuality.high,
                      gaplessPlayback: true,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      right: w * 0.02,
                      top: h * 0.1,
                      width: badge,
                      height: badge,
                      child: _WarehouseCountBadge(count: count),
                    ),
                  Positioned(
                    left: -w * 0.1,
                    right: -w * 0.1,
                    bottom: -h * 0.06,
                    child: Center(
                      child: CourtyardPlaque(title: l10n.warehouseTitle),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WarehouseCountBadge extends StatelessWidget {
  const _WarehouseCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('courtyard-warehouse-count'),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFE9A8), gardenGold],
          center: Alignment(-0.3, -0.4),
        ),
        border: Border.all(color: gardenWood, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: FittedBox(
          child: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(
              color: gardenWood,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Короткая деревянная табличка у места на лужайке.
class CourtyardPlaque extends StatelessWidget {
  const CourtyardPlaque({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gardenWood.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gardenGoldSoft.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: gardenIvory,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
