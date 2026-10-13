import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/courtyard_reward.dart';
import '../../models/garden.dart';
import '../../models/pet.dart';
import '../../models/plot_kind.dart';
import '../../services/fox_adventure_store.dart';
import '../pets/pet_portrait.dart';
import 'courtyard_estate.dart';
import 'courtyard_lot_build.dart';
import 'courtyard_reward_choice.dart';
import 'courtyard_world_layout.dart';
import '../garden/plant_art.dart';
import 'plot_stage_view.dart';

const courtyardHomeKey = ValueKey('courtyard-home');
const courtyardPondKey = ValueKey('courtyard-pond');
const courtyardPetAreaKey = ValueKey('courtyard-pet-area');
const courtyardPetStartAdventureKey = ValueKey('courtyard-pet-start-adventure');
const courtyardPetVisitKey = ValueKey('courtyard-pet-visit');

/// Изометрический двор: одна лужайка игрока, без соседних дворов.
class CourtyardWorld extends StatefulWidget {
  const CourtyardWorld({
    super.key,
    required this.to,
    this.from,
    this.animate = false,
    this.neighbors = const [],
    this.onSelectLot,
    this.onLockedLot,
    this.onNeighborTap,
    this.onPanHint,
    this.inspectKind,
    this.interactive = true,
    this.foxAdventure,
    this.onFoxTap,
    this.pets = const [],
    this.onPetTap,
    this.courtyardRewards = const {},
    this.showGarden = false,
    this.garden,
    this.onBedTap,
    this.onWarehouseTap,
  });

  final CourtyardEstate to;
  final CourtyardEstate? from;
  final bool animate;
  final List<NeighborYard> neighbors;
  final ValueChanged<PlotKind>? onSelectLot;
  final ValueChanged<PlotKind>? onLockedLot;
  final ValueChanged<NeighborYard>? onNeighborTap;
  final VoidCallback? onPanHint;
  final PlotKind? inspectKind;
  final bool interactive;
  final FoxAdventureStore? foxAdventure;
  final VoidCallback? onFoxTap;

  final List<PetCare> pets;
  final VoidCallback? onPetTap;
  final Set<CourtyardReward> courtyardRewards;

  /// Огород и склад только на своём дворе.
  final bool showGarden;
  final GardenSnapshot? garden;
  final ValueChanged<int>? onBedTap;
  final VoidCallback? onWarehouseTap;

  static const growDuration = Duration(milliseconds: 2400);

  @override
  State<CourtyardWorld> createState() => _CourtyardWorldState();
}

class _CourtyardWorldState extends State<CourtyardWorld>
    with TickerProviderStateMixin {
  late final AnimationController _grow;
  late final AnimationController _pulse;
  late final TransformationController _transform;
  int? _blendFrom;
  NeighborYard? _tappedNeighbor;
  var _didFit = false;
  Size? _viewport;

  static const _gold = Color(0xFFE8C96A);
  static const _ivory = Color(0xFFF8F1DE);
  static const _wood = Color(0xFF3A2012);

  @override
  void initState() {
    super.initState();
    _transform = TransformationController();
    _grow = AnimationController(
      vsync: this,
      duration: CourtyardWorld.growDuration,
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    if (widget.animate) _grow.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(CourtyardWorldLayout.countryBase), context);
    precacheImage(
      const AssetImage(CourtyardWorldLayout.gardenPlotAsset),
      context,
    );
    precacheImage(
      const AssetImage(CourtyardWorldLayout.warehouseAsset),
      context,
    );
    for (final reward in CourtyardReward.values) {
      precacheImage(AssetImage(reward.asset), context);
    }
    for (var frame = 1; frame <= PlotStages.frameCount; frame++) {
      precacheImage(
        AssetImage(PlotStages.assetOf(PlotKind.house, frame)),
        context,
      );
    }
    for (var frame = 1; frame <= PlotStages.framesOf(PlotKind.pond); frame++) {
      precacheImage(
        AssetImage(PlotStages.assetOf(PlotKind.pond, frame)),
        context,
      );
    }
  }

  @override
  void didUpdateWidget(covariant CourtyardWorld oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate &&
        (oldWidget.from != widget.from || oldWidget.to != widget.to)) {
      _grow.forward(from: 0);
    }
    final prev = oldWidget.to.purchasedHome;
    final next = widget.to.purchasedHome;
    final stepped =
        !widget.animate && prev != null && next != null && next == prev + 1;
    if (!stepped || MediaQuery.disableAnimationsOf(context)) {
      _blendFrom = null;
      if (_pulse.isAnimating) _pulse.stop();
      return;
    }
    _blendFrom = prev;
    _pulse.forward(from: 0);
  }

  @override
  void dispose() {
    _grow.dispose();
    _pulse.dispose();
    _transform.dispose();
    super.dispose();
  }

  CourtyardEstate get _estate {
    final from = widget.from;
    if (!widget.animate || from == null) return widget.to;
    return CourtyardEstate.lerp(
      from,
      widget.to,
      Curves.easeInOutCubic.transform(_grow.value),
    );
  }

  double _visualHome(double stage) {
    final from = _blendFrom;
    if (from == null) return stage;
    final t = Curves.easeOutCubic.transform(_pulse.value);
    return from + (stage - from) * t;
  }

  void _fitIfNeeded(Size viewport) {
    if (viewport.width < 1 || viewport.height < 1) return;
    if (_viewport == viewport && _didFit) return;
    _viewport = viewport;
    _didFit = true;
    _applyCamera(viewport);
  }

  void _applyCamera(Size viewport) {
    _transform.value = _matrixFor(
      viewport,
      CourtyardWorldLayout.yardCover,
      0.72,
    );
  }

  Matrix4 _matrixFor(Size viewport, Rect focusNorm, double coverage) {
    final cam = CourtyardWorldLayout.camera(
      viewport: viewport,
      focusNorm: focusNorm,
      coverage: coverage,
    );
    return Matrix4.identity()
      ..translate(cam.tx, cam.ty)
      ..scale(cam.scale);
  }

  void _onHouseTap() {
    widget.onSelectLot?.call(PlotKind.house);
    final lot = _estate.lot(PlotKind.house);
    if (!lot.unlocked) widget.onLockedLot?.call(PlotKind.house);
  }

  void _onNeighborTap(NeighborYard yard) {
    setState(() => _tappedNeighbor = yard);
    widget.onNeighborTap?.call(yard);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _fitIfNeeded(viewport);
        });
        final cover = CourtyardWorldLayout.coverScale(viewport);
        return AnimatedBuilder(
          animation: Listenable.merge([_grow, _pulse]),
          builder: (context, _) {
            final estate = _estate;
            final homeStage = _visualHome(estate.homeStage);
            return SizedBox(
              width: viewport.width,
              height: viewport.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const IgnorePointer(
                    child: Image(
                      image: AssetImage(CourtyardWorldLayout.countryBase),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                      gaplessPlayback: true,
                    ),
                  ),
                  ClipRect(
                    child: InteractiveViewer(
                      transformationController: _transform,
                      constrained: false,
                      minScale: cover,
                      maxScale: math.max(2.8, cover),
                      boundaryMargin: EdgeInsets.zero,
                      panEnabled: widget.interactive,
                      scaleEnabled: widget.interactive,
                      onInteractionStart: widget.interactive
                          ? (_) => widget.onPanHint?.call()
                          : null,
                      child: SizedBox(
                        width: CourtyardWorldLayout.mapWidth,
                        height: CourtyardWorldLayout.mapHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Positioned.fill(
                              child: Image(
                                image: AssetImage(
                                  CourtyardWorldLayout.countryBase,
                                ),
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.high,
                                gaplessPlayback: true,
                              ),
                            ),
                            _homeBuild(homeStage),
                            _groundPlaque(
                              CourtyardWorldLayout.mapRect(
                                CourtyardWorldLayout.homeYard,
                              ),
                              AppLocalizations.of(context).houseCardTitle,
                            ),
                            if (estate.pondStage > 0)
                              _pondBuild(estate.pondStage),
                            ..._rewardViews(hidePondGift: estate.pondStage > 0),
                            _petYard(),
                            if (estate.festival > 0.02 ||
                                estate.streakLife > 0.08)
                              Positioned.fromRect(
                                rect: CourtyardWorldLayout.mapRect(
                                  CourtyardWorldLayout.yardCover,
                                ),
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: FestivalLanternsPainter(
                                      strength:
                                          (estate.festival * 0.7 +
                                                  estate.streakLife * 0.5)
                                              .clamp(0.0, 1.0),
                                      t: widget.animate ? _grow.value : 0.35,
                                    ),
                                  ),
                                ),
                              ),
                            _homeHit(),
                            if (widget.showGarden) ..._gardenPlots(),
                            for (final yard in widget.neighbors)
                              _neighborHit(yard),
                            if (_tappedNeighbor != null)
                              _neighborLabel(_tappedNeighbor!),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _homeBuild(double stage) {
    final pad = CourtyardWorldLayout.mapRect(CourtyardWorldLayout.homeYard);
    return Positioned.fromRect(
      key: courtyardHomeKey,
      rect: pad,
      child: IgnorePointer(
        child: PlotStageView(kind: PlotKind.house, stage: stage),
      ),
    );
  }

  Widget _pondBuild(double stage) {
    final pad = CourtyardWorldLayout.mapRect(CourtyardWorldLayout.pondYard);
    return Positioned.fromRect(
      key: courtyardPondKey,
      rect: pad,
      child: IgnorePointer(
        child: PlotStageView(kind: PlotKind.pond, stage: stage),
      ),
    );
  }

  Widget _homeHit() {
    final rect = CourtyardWorldLayout.mapRect(
      CourtyardWorldLayout.homeYard,
    ).inflate(8);
    return Positioned.fromRect(
      rect: rect,
      child: Semantics(
        button: true,
        label: AppLocalizations.of(context).homeSemantic,
        child: GestureDetector(
          key: const ValueKey('courtyard-lot-house'),
          onTap: widget.interactive ? _onHouseTap : null,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  List<Widget> _gardenPlots() {
    final garden = widget.garden ?? GardenSnapshot.empty;
    final plot = CourtyardWorldLayout.mapRect(CourtyardWorldLayout.gardenPlot);
    final warehouse = CourtyardWorldLayout.mapRect(
      CourtyardWorldLayout.warehouse,
    );
    return [
      Positioned(
        left: plot.left + plot.width * 0.04,
        top: plot.bottom - plot.height * 0.16,
        width: plot.width * 0.92,
        height: plot.height * 0.2,
        child: const IgnorePointer(
          child: CustomPaint(painter: ContactShadowPainter(strength: 0.6)),
        ),
      ),
      Positioned.fromRect(
        key: const ValueKey('courtyard-garden-plot'),
        rect: plot,
        child: const IgnorePointer(
          child: ClipPath(
            clipper: _YardOvalClipper(),
            child: Image(
              image: AssetImage(CourtyardWorldLayout.gardenPlotAsset),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
      Positioned(
        left: plot.left,
        width: plot.width * 0.7,
        top: plot.bottom - plot.height * 0.22,
        child: IgnorePointer(
          child: Center(
            child: CourtyardPlaque(
              title: AppLocalizations.of(context).featureTitleGarden,
            ),
          ),
        ),
      ),
      for (var index = 0; index < GardenCatalog.bedCount; index++)
        Positioned.fromRect(
          rect: CourtyardWorldLayout.mapRect(
            CourtyardWorldLayout.gardenBed(index),
          ),
          child: GardenBedView(
            index: index,
            planting: garden.bedAt(index),
            onTap: widget.interactive
                ? () => widget.onBedTap?.call(index)
                : null,
          ),
        ),
      Positioned(
        left: warehouse.left + warehouse.width * 0.06,
        top: warehouse.bottom - warehouse.height * 0.12,
        width: warehouse.width * 0.9,
        height: warehouse.height * 0.16,
        child: const IgnorePointer(
          child: CustomPaint(painter: ContactShadowPainter()),
        ),
      ),
      Positioned.fromRect(
        rect: warehouse,
        child: WarehouseBuilding(
          count: garden.plantCount,
          onTap: widget.interactive ? widget.onWarehouseTap : null,
        ),
      ),
    ];
  }

  Widget _groundPlaque(Rect anchor, String title) {
    return Positioned(
      left: anchor.left,
      width: anchor.width,
      top: anchor.bottom - 10,
      child: IgnorePointer(
        child: Center(child: CourtyardPlaque(title: title)),
      ),
    );
  }

  Widget _petYard() {
    return Positioned.fromRect(
      rect: CourtyardWorldLayout.mapRect(CourtyardWorldLayout.petYard),
      child: _PetYardArea(
        cares: widget.pets,
        onTap: widget.onPetTap ?? widget.onFoxTap,
      ),
    );
  }

  List<Widget> _rewardViews({required bool hidePondGift}) {
    return [
      for (final reward in widget.courtyardRewards)
        if (!hidePondGift || reward != CourtyardReward.pond)
          Positioned.fromRect(
            rect: CourtyardWorldLayout.mapRect(
              CourtyardWorldLayout.rewardOf(reward),
            ),
            child: IgnorePointer(child: _GroundedProp(reward: reward)),
          ),
    ];
  }

  Widget _neighborHit(NeighborYard yard) {
    final rect = CourtyardWorldLayout.mapRect(
      CourtyardWorldLayout.neighborOf(yard.slot),
    );
    return Positioned.fromRect(
      rect: rect,
      child: GestureDetector(
        key: ValueKey('courtyard-neighbor-${yard.slot}'),
        onTap: () => _onNeighborTap(yard),
        behavior: HitTestBehavior.opaque,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _neighborLabel(NeighborYard yard) {
    final rect = CourtyardWorldLayout.mapRect(
      CourtyardWorldLayout.neighborOf(yard.slot),
    );
    return Positioned(
      left: rect.left - 20,
      top: rect.top - 36,
      width: rect.width + 40,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _wood.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _gold.withValues(alpha: 0.7)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text(
              _neighborCaption(context, yard),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ivory,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _neighborCaption(BuildContext context, NeighborYard yard) {
    final l10n = AppLocalizations.of(context);
    if (!yard.named) return l10n.neighboringCourtyard;
    if (yard.rating != null) {
      return l10n.neighborRating(yard.name!, yard.rating!);
    }
    return l10n.neighborYard(yard.name!);
  }
}

class _PetYardSlot {
  const _PetYardSlot({
    required this.care,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final PetCare care;
  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
}

List<_PetYardSlot> _yardSlots(List<PetCare> cares, double w, double h) {
  final n = cares.length;
  if (n == 0) return const [];
  final petWidth = n <= 1
      ? w * 0.58
      : n == 2
      ? w * 0.46
      : n == 3
      ? w * 0.36
      : w * 0.30;
  final petHeight = n <= 1
      ? h * 0.50
      : n == 2
      ? h * 0.44
      : n == 3
      ? h * 0.38
      : h * 0.34;
  final feet = h * 0.88;
  if (n == 1) {
    return [
      _PetYardSlot(
        care: cares.first,
        left: (w - petWidth) / 2,
        top: feet - petHeight,
        width: petWidth,
        height: petHeight,
      ),
    ];
  }
  final span = w * 0.94;
  final start = (w - span) / 2;
  final step = (span - petWidth) / (n - 1);
  return [
    for (var i = 0; i < n; i++)
      _PetYardSlot(
        care: cares[i],
        left: start + i * step,
        top: feet - petHeight + (i.isOdd ? h * 0.05 : -h * 0.015),
        width: petWidth,
        height: petHeight,
      ),
  ];
}

class _PetYardArea extends StatelessWidget {
  const _PetYardArea({required this.cares, this.onTap});

  final List<PetCare> cares;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final cares = this.cares;
    final status = cares.isEmpty
        ? l.chooseAPetStatus
        : cares.map((care) => l.petMoodLine(care.kind, care.mood)).join(' ');
    return Semantics(
      button: true,
      label: '${l.pets}. $status',
      child: GestureDetector(
        key: const ValueKey('courtyard-pets'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            final slots = _yardSlots(cares, w, h);
            return SizedBox.expand(
              child: Stack(
                key: courtyardPetAreaKey,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Center(
                      child: CourtyardPlaque(
                        key: courtyardPetVisitKey,
                        title: l.pets,
                      ),
                    ),
                  ),
                  if (cares.isEmpty)
                    Positioned(
                      left: 8,
                      right: 8,
                      top: h * 0.34,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pets_rounded, color: accent, size: 36),
                          const SizedBox(height: 4),
                          Text(
                            l.chooseAPetYard,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFF8F1DE),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              shadows: [
                                Shadow(color: Color(0xAA000000), blurRadius: 6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    for (final slot in slots)
                      Positioned(
                        left: slot.left + slot.width * 0.07,
                        top: slot.top + slot.height * 0.88,
                        width: slot.width * 0.86,
                        height: h * 0.13,
                        child: const IgnorePointer(
                          child: CustomPaint(painter: ContactShadowPainter()),
                        ),
                      ),
                    for (final slot in [
                      ...slots,
                    ]..sort((a, b) => a.top.compareTo(b.top)))
                      Positioned(
                        key: ValueKey('courtyard-pet-${slot.care.kind.name}'),
                        left: slot.left,
                        top: slot.top,
                        width: slot.width,
                        height: slot.height,
                        child: PetPortrait(kind: slot.care.kind),
                      ),
                    for (final slot in slots)
                      if (slot.care.mood != PetMood.content)
                        Positioned(
                          left: slot.right - w * 0.04,
                          top: slot.top + h * 0.04,
                          width: w * 0.20,
                          height: w * 0.20,
                          child: _PetMoodBubble(
                            mood: slot.care.mood,
                            accent: switch (slot.care.mood) {
                              PetMood.starving => const Color(0xFFE37A67),
                              PetMood.asking => const Color(0xFFF0B45A),
                              PetMood.content => const Color(0xFFFFD980),
                            },
                          ),
                        ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Пузырь над питомцем — только когда он голоден или просит внимания.
class _PetMoodBubble extends StatelessWidget {
  const _PetMoodBubble({required this.mood, required this.accent});

  final PetMood mood;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xF2FFF6E0),
        border: Border.all(color: accent, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            mood == PetMood.starving
                ? Icons.restaurant_rounded
                : Icons.favorite_rounded,
            color: accent,
          ),
        ),
      ),
    );
  }
}

/// Декор вместе с тенью: спрайты нарисованы без неё, чтобы свет во дворе
/// шёл из одного места для дома, питомца и построек сразу.
class _GroundedProp extends StatelessWidget {
  const _GroundedProp({required this.reward});

  final CourtyardReward reward;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Смещена вправо: солнце на карте стоит слева сверху.
            Positioned(
              left: w * 0.16,
              width: w * 0.76,
              top: h * 0.87,
              height: h * 0.15,
              child: const CustomPaint(painter: ContactShadowPainter()),
            ),
            Positioned.fill(child: CourtyardRewardView(reward: reward)),
          ],
        );
      },
    );
  }
}

/// Мягкая тень под объектом: без неё спрайт висит над травой.
class ContactShadowPainter extends CustomPainter {
  const ContactShadowPainter({this.strength = 1});

  /// Насколько плотная тень: у мелкого декора она слабее, чем у дома.
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 2 || size.height < 2) return;
    final box = Offset.zero & size;
    // Ореол растекается по траве, ядро держит место касания — только с ним
    // спрайт перестаёт выглядеть наклейкой поверх лужайки.
    canvas.drawOval(
      box,
      Paint()
        ..color = const Color(0xFF12190D).withValues(alpha: 0.30 * strength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.25),
    );
    canvas.drawOval(
      box.deflate(size.height * 0.22),
      Paint()
        ..color = const Color(0xFF0D1409).withValues(alpha: 0.50 * strength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant ContactShadowPainter oldDelegate) =>
      oldDelegate.strength != strength;
}

/// Гирлянда фонарей поверх двора на неделю события и за серию.
class FestivalLanternsPainter extends CustomPainter {
  const FestivalLanternsPainter({required this.strength, required this.t});

  final double strength;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    final sway = 6 * math.sin(t * 2 * math.pi);
    final line = Paint()
      ..color = const Color(0xFFE8C96A).withValues(alpha: 0.55 * strength)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final glow = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.42 * strength)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final core = Paint()
      ..color = const Color(0xFFFFF3C4).withValues(alpha: 0.9 * strength);

    final y = size.height * 0.18;
    final points = <Offset>[
      Offset(size.width * 0.12 + sway * 0.15, y + 10),
      Offset(size.width * 0.28, y - 4),
      Offset(size.width * 0.46 + sway * 0.08, y + 6),
      Offset(size.width * 0.64, y - 2),
      Offset(size.width * 0.82 - sway * 0.12, y + 8),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy - 14);
    for (final p in points) {
      path.lineTo(p.dx, p.dy - 14);
    }
    canvas.drawPath(path, line);
    for (final p in points) {
      canvas.drawCircle(p, 9, glow);
      canvas.drawCircle(p, 4.2, core);
    }
  }

  @override
  bool shouldRepaint(covariant FestivalLanternsPainter oldDelegate) {
    return oldDelegate.strength != strength || oldDelegate.t != t;
  }
}

/// Срезает жёлтый ореол по краю спрайта огорода, чтобы грядки легли на траву.
class _YardOvalClipper extends CustomClipper<Path> {
  const _YardOvalClipper();

  @override
  Path getClip(Size size) {
    return Path()..addOval(
      Rect.fromLTWH(
        size.width * 0.045,
        size.height * 0.07,
        size.width * 0.91,
        size.height * 0.86,
      ),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
