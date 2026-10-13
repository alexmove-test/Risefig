import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/garden.dart';
import '../../models/house_upgrade.dart';
import '../../models/meta_features.dart';
import '../../models/plot_kind.dart';
import '../../models/plant_cross.dart';
import '../../models/seed_batch.dart';
import '../../models/seed_catalog.dart';
import 'courtyard_lot_build.dart';

const _ivory = Color(0xFFF8F1DE);
const _goldSoft = Color(0xFFE8C96A);
const _goldLine = Color(0xFFD4AF37);
const _actionExtent = 72.0;

/// Покупка следующего облика: миниатюра и квадратные действия.
/// Шторка раскрывает дом, семена, склад и огород.
class HomeUpgradePreview extends StatefulWidget {
  const HomeUpgradePreview({
    super.key,
    required this.state,
    required this.balance,
    this.busy = false,
    this.onBuy,
    this.seedBatch,
    this.seedBusy = false,
    this.onStartSeed,
    this.onClaimSeed,
    this.onOpenSeed,
    this.onGrowPlant,
    this.seeds = const [],
    this.garden,
  });

  /// Текущее состояние, 1…24.
  final int state;
  final int balance;
  final bool busy;
  final Future<void> Function()? onBuy;

  /// Партия семян дома. Квадрат производства виден, если задан любой колбэк семян.
  final SeedBatch? seedBatch;
  final bool seedBusy;
  final Future<void> Function()? onStartSeed;
  final Future<void> Function()? onClaimSeed;

  /// Партия уже идёт: открыть карточку дома, где её можно ускорить.
  final VoidCallback? onOpenSeed;

  /// Пустая грядка или уже посаженное растение.
  final VoidCallback? onGrowPlant;

  /// Запас семян для шторки. Пустой список — производство ещё ничего не отдало.
  final List<SeedInstance> seeds;

  /// Грядки и склад. Без снимка шторка не рассказывает про огород.
  final GardenSnapshot? garden;

  @override
  State<HomeUpgradePreview> createState() => _HomeUpgradePreviewState();
}

class _HomeUpgradePreviewState extends State<HomeUpgradePreview>
    with SingleTickerProviderStateMixin {
  var _busy = false;
  var _seedBusy = false;
  var _detailsOpen = false;
  Timer? _clock;
  late final AnimationController _curtain;

  bool get _locked => widget.busy || _busy;

  bool get _seedLocked => widget.seedBusy || _seedBusy;

  bool get _showSeed =>
      widget.onStartSeed != null ||
      widget.onClaimSeed != null ||
      widget.onOpenSeed != null;

  @override
  void initState() {
    super.initState();
    _curtain = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _syncClock();
  }

  @override
  void didUpdateWidget(covariant HomeUpgradePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncClock();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _curtain.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
  }

  @override
  void dispose() {
    _clock?.cancel();
    _curtain.dispose();
    super.dispose();
  }

  bool _gardenTicking(DateTime now) {
    if (!_detailsOpen) return false;
    final beds = widget.garden?.beds;
    if (beds == null) return false;
    for (final bed in beds) {
      if (bed != null && !bed.isReady(now)) return true;
    }
    return false;
  }

  void _syncClock() {
    final now = DateTime.now();
    final producing =
        _showSeed && phaseOf(widget.seedBatch, now) == SeedPhase.producing;
    if (!producing && !_gardenTicking(now)) {
      _clock?.cancel();
      _clock = null;
      return;
    }
    _clock ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_syncClock);
    });
  }

  void _toggleDetails() {
    setState(() => _detailsOpen = !_detailsOpen);
    if (_detailsOpen) {
      _curtain.forward();
    } else {
      _curtain.reverse();
    }
    _syncClock();
  }

  Future<void> _buy() async {
    final action = widget.onBuy;
    if (action == null || _locked) return;
    if (!HouseUpgrade.canAdvance(widget.state)) return;
    final price = HouseUpgrade.priceAfter(widget.state);
    if (widget.balance < price) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pressSeed() async {
    if (_seedLocked) return;
    final phase = phaseOf(widget.seedBatch, DateTime.now());
    switch (phase) {
      case SeedPhase.idle:
        final start = widget.onStartSeed;
        if (start == null) return;
        final price = SeedCatalog.costForLevel(widget.state);
        if (widget.balance < price) return;
        setState(() => _seedBusy = true);
        try {
          await start();
        } finally {
          if (mounted) setState(() => _seedBusy = false);
        }
      case SeedPhase.ready:
        final claim = widget.onClaimSeed;
        if (claim == null) return;
        setState(() => _seedBusy = true);
        try {
          await claim();
        } finally {
          if (mounted) setState(() => _seedBusy = false);
        }
      case SeedPhase.producing:
        widget.onOpenSeed?.call();
    }
  }

  bool _seedEnabled() {
    if (_seedLocked) return false;
    final phase = phaseOf(widget.seedBatch, DateTime.now());
    return switch (phase) {
      SeedPhase.idle =>
        widget.onStartSeed != null &&
            widget.balance >= SeedCatalog.costForLevel(widget.state),
      SeedPhase.ready => widget.onClaimSeed != null,
      SeedPhase.producing => widget.onOpenSeed != null,
    };
  }

  String _seedLabel(AppLocalizations l10n) {
    final now = DateTime.now();
    final phase = phaseOf(widget.seedBatch, now);
    return switch (phase) {
      SeedPhase.idle => l10n.yardSeedOffer(
        SeedCatalog.costForLevel(widget.state),
      ),
      SeedPhase.producing => l10n.yardSeedTimerText(
        formatSeedCountdown(widget.seedBatch?.remaining(now) ?? Duration.zero),
      ),
      SeedPhase.ready => l10n.claimSeed,
    };
  }

  List<_YardAction> _actions(
    AppLocalizations l10n, {
    required int price,
    required bool canBuy,
    bool upgrade = true,
  }) {
    return [
      if (upgrade)
        _YardAction(
          buttonKey: const ValueKey('house-upgrade-button'),
          label: l10n.upgradeHouseFor(price),
          onPressed: canBuy ? _buy : null,
        ),
      if (_showSeed)
        _YardAction(
          buttonKey: const ValueKey('yard-seed-button'),
          label: _seedLabel(l10n),
          onPressed: _seedEnabled() ? _pressSeed : null,
        ),
      if (widget.onGrowPlant != null)
        _YardAction(
          buttonKey: const ValueKey('yard-plant-button'),
          label: l10n.yardGrowPlant,
          onPressed: widget.onGrowPlant,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = HouseUpgrade.clampState(widget.state);
    final maxed = !HouseUpgrade.canAdvance(state);
    final price = maxed ? 0 : HouseUpgrade.priceAfter(state);
    final shortfall = maxed ? 0 : (price - widget.balance).clamp(0, price);
    final canBuy = !maxed && shortfall == 0 && widget.onBuy != null && !_locked;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xEB3A2012),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x88D4AF37)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (maxed) ...[
              Text(
                l10n.houseFullyUpgraded,
                key: const ValueKey('house-upgrade-max'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _goldSoft,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              if (_showSeed || widget.onGrowPlant != null) ...[
                const SizedBox(height: 8),
                _ActionStrip(
                  actions: _actions(
                    l10n,
                    price: price,
                    canBuy: false,
                    upgrade: false,
                  ),
                ),
              ],
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NextHouseArt(frame: state + 1),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionStrip(
                      actions: _actions(l10n, price: price, canBuy: canBuy),
                    ),
                  ),
                ],
              ),
            _CurtainHandle(open: _detailsOpen, onTap: _toggleDetails),
            AnimatedBuilder(
              animation: _curtain,
              builder: (context, _) {
                final t = Curves.easeOut.transform(_curtain.value);
                return ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: t == 0 ? 0 : t,
                    child: t == 0
                        ? const SizedBox(width: double.infinity, height: 0)
                        : ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: _curtainCap(context),
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              primary: false,
                              padding: EdgeInsets.zero,
                              physics: const ClampingScrollPhysics(),
                              children: [
                                _UpgradeDetails(
                                  state: state,
                                  price: price,
                                  shortfall: shortfall,
                                  maxed: maxed,
                                  showSeeds: _showSeed,
                                  seedBatch: widget.seedBatch,
                                  seeds: widget.seeds,
                                  garden: widget.garden,
                                ),
                              ],
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _YardAction {
  const _YardAction({
    required this.buttonKey,
    required this.label,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final VoidCallback? onPressed;
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({required this.actions});

  final List<_YardAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    final onlyUpgrade =
        actions.length == 1 &&
        actions.single.buttonKey == const ValueKey('house-upgrade-button');
    if (onlyUpgrade) return _WideUpgradeButton(action: actions.single);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!width.isFinite || width <= 0) return const SizedBox.shrink();
        const gap = 8.0;
        final raw = (width - gap * (actions.length - 1)) / actions.length;
        final side = math.min(_actionExtent, math.max(0.0, raw));
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: side,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  _SquareActionButton(action: actions[i], side: side),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WideUpgradeButton extends StatelessWidget {
  const _WideUpgradeButton({required this.action});

  final _YardAction action;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: action.buttonKey,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF6B3E24),
        foregroundColor: _goldSoft,
        disabledBackgroundColor: const Color(0xFF3A2012),
        disabledForegroundColor: const Color(0x88E8C96A),
        minimumSize: const Size.fromHeight(44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _goldLine.withValues(alpha: 0.75)),
        ),
      ),
      onPressed: action.onPressed,
      child: Text(
        action.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }
}

class _SquareActionButton extends StatelessWidget {
  const _SquareActionButton({required this.action, required this.side});

  final _YardAction action;
  final double side;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final painted = ((side - 10) / (3 * 1.05)).clamp(9.0, 12.0);
    final fontSize = painted / scale;
    return SizedBox(
      width: side,
      height: side,
      child: FilledButton(
        key: action.buttonKey,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6B3E24),
          foregroundColor: _goldSoft,
          disabledBackgroundColor: const Color(0xFF3A2012),
          disabledForegroundColor: const Color(0x88E8C96A),
          minimumSize: Size(side, side),
          maximumSize: Size(side, side),
          fixedSize: Size(side, side),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _goldLine.withValues(alpha: 0.75)),
          ),
        ),
        onPressed: action.onPressed,
        child: Text(
          action.label,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _CurtainHandle extends StatelessWidget {
  const _CurtainHandle({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = open ? l10n.houseDetailsHide : l10n.houseDetailsShow;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        key: const ValueKey('house-upgrade-curtain'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Icon(
            open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            color: _goldSoft,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _UpgradeDetails extends StatelessWidget {
  const _UpgradeDetails({
    required this.state,
    required this.price,
    required this.shortfall,
    required this.maxed,
    required this.showSeeds,
    required this.seedBatch,
    required this.seeds,
    required this.garden,
  });

  final int state;
  final int price;
  final int shortfall;
  final bool maxed;
  final bool showSeeds;
  final SeedBatch? seedBatch;
  final List<SeedInstance> seeds;
  final GardenSnapshot? garden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        if (!maxed) ...[
          Text(
            l10n.houseStateTitle(state, HouseUpgrade.stateCount),
            key: const ValueKey('house-state-title'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _goldSoft,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
        ],
        _HouseLookLine(
          key: const ValueKey('house-look-line'),
          stage: state.toDouble(),
        ),
        if (!maxed) ...[
          const SizedBox(height: 8),
          Text(
            l10n.houseUpgradeOffer(price),
            key: const ValueKey('house-upgrade-price'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ivory,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          _SeedUpgradeBenefit(state: state),
          if (shortfall > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.pointsShortfall(shortfall),
              key: const ValueKey('house-upgrade-shortfall'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _goldSoft,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ],
        if (showSeeds || garden != null) ...[
          const SizedBox(height: 10),
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0x55D4AF37)),
            child: SizedBox(height: 1),
          ),
          const SizedBox(height: 8),
        ],
        if (showSeeds)
          _CurtainBlock(
            blockKey: const ValueKey('yard-curtain-seeds'),
            title: l10n.featureTitle(MetaFeature.seeds),
            children: _seedLines(l10n),
          ),
        if (garden != null) ...[
          if (showSeeds) const SizedBox(height: 10),
          _CurtainBlock(
            blockKey: const ValueKey('yard-curtain-warehouse'),
            title: l10n.featureTitle(MetaFeature.warehouse),
            children: _warehouseLines(l10n, garden!),
          ),
          const SizedBox(height: 10),
          _CurtainBlock(
            blockKey: const ValueKey('yard-curtain-garden'),
            title: l10n.featureTitle(MetaFeature.garden),
            children: _gardenLines(l10n, garden!),
          ),
        ],
      ],
    );
  }

  List<Widget> _seedLines(AppLocalizations l10n) {
    final now = DateTime.now();
    final phase = phaseOf(seedBatch, now);
    final offer = SeedCatalog.offerFor(state);
    final stacks = stackSeeds(seeds);
    return [
      _DetailLine(l10n.featureBody(MetaFeature.seeds)),
      switch (phase) {
        SeedPhase.idle => _DetailLine(
          l10n.produceSeedFor(offer.cost),
          lineKey: const ValueKey('yard-seed-offer'),
        ),
        SeedPhase.producing => _DetailLine(
          l10n.seedBadgeProducing(
            formatSeedCountdown(seedBatch?.remaining(now) ?? Duration.zero),
          ),
          lineKey: const ValueKey('yard-seed-producing'),
        ),
        SeedPhase.ready => _DetailLine(
          '${l10n.seedName(seedBatch!.species)} · ${l10n.seedBadgeReady}',
          lineKey: const ValueKey('yard-seed-ready'),
        ),
      },
      if (phase == SeedPhase.idle) ...[
        _DetailLine(l10n.catalogDuration(offer.duration)),
        _DetailLine(
          l10n.seedChanceStep(l10n.seedChanceSummary(offer.chances)),
          lineKey: const ValueKey('yard-seed-chances'),
        ),
      ],
      if (stacks.isEmpty)
        _DetailLine(l10n.seedsEmptyBody)
      else
        for (final stack in stacks)
          _DetailLine(
            _stackLabel(
              l10n,
              species: stack.species,
              count: stack.count,
              trait: stack.trait,
              food: stack.power,
            ),
            lineKey: ValueKey(
              'yard-seed-stack-${stack.species.name}-${stack.power}',
            ),
          ),
    ];
  }

  List<Widget> _warehouseLines(AppLocalizations l10n, GardenSnapshot garden) {
    final stacks = stackPlants(garden.warehouse);
    return [
      _DetailLine(l10n.featureBody(MetaFeature.warehouse)),
      if (stacks.isEmpty)
        _DetailLine(l10n.warehouseEmptyBody)
      else
        for (final stack in stacks)
          _DetailLine(
            _stackLabel(
              l10n,
              species: stack.species,
              count: stack.count,
              trait: stack.trait,
              food: stack.power,
            ),
            lineKey: ValueKey(
              'yard-plant-stack-${stack.species.name}-${stack.power}',
            ),
          ),
    ];
  }

  List<Widget> _gardenLines(AppLocalizations l10n, GardenSnapshot garden) {
    final now = DateTime.now();
    return [
      _DetailLine(l10n.featureBody(MetaFeature.garden)),
      for (var index = 0; index < garden.beds.length; index++)
        _DetailLine(
          _bedLine(l10n, index, garden.beds[index], now),
          lineKey: ValueKey('yard-bed-$index'),
        ),
    ];
  }
}

double _curtainCap(BuildContext context) {
  final view = View.of(context);
  final height = view.physicalSize.height / view.devicePixelRatio;
  if (height <= 0) return double.infinity;
  return height * 0.46;
}

const _detailBody = TextStyle(
  color: _ivory,
  fontSize: 12,
  height: 1.3,
  fontWeight: FontWeight.w600,
);

class _CurtainBlock extends StatelessWidget {
  const _CurtainBlock({
    required this.blockKey,
    required this.title,
    required this.children,
  });

  final Key blockKey;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: blockKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _goldSoft,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        ...children,
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.text, {this.lineKey});

  final String text;
  final Key? lineKey;

  @override
  Widget build(BuildContext context) {
    return Text(text, key: lineKey, style: _detailBody);
  }
}

String _stackLabel(
  AppLocalizations l10n, {
  required SeedSpecies species,
  required int count,
  required PlantTrait? trait,
  required int food,
}) {
  final parts = <String>[
    '${l10n.seedName(species)} ${l10n.seedGroupCount(count)}',
    l10n.plantPower(food),
  ];
  if (trait != null) parts.add(l10n.plantTraitLabel(trait));
  return parts.join(' · ');
}

String _bedLine(
  AppLocalizations l10n,
  int index,
  Planting? planting,
  DateTime now,
) {
  final number = index + 1;
  if (planting == null) return l10n.gardenBedEmpty(number);
  final name = l10n.seedName(planting.species);
  if (planting.isReady(now)) return l10n.gardenBedReady(number, name);
  return l10n.gardenBedGrowing(
    number,
    name,
    l10n.growthStage(stageOf(planting, now)),
    formatSeedCountdown(planting.remaining(now)),
  );
}

class _SeedUpgradeBenefit extends StatelessWidget {
  const _SeedUpgradeBenefit({required this.state});

  final int state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = SeedCatalog.offerFor(state);
    final next = SeedCatalog.offerFor(state + 1);
    final band = SeedCatalog.bandChanges(state, state + 1);
    return Column(
      key: const ValueKey('seed-upgrade-benefits'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.seedDurationStep(
            l10n.catalogDuration(current.duration),
            l10n.catalogDuration(next.duration),
          ),
          key: const ValueKey('seed-duration-step'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _goldSoft, fontSize: 12, height: 1.2),
        ),
        Text(
          l10n.seedCostStep(current.cost, next.cost),
          key: const ValueKey('seed-cost-step'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _goldSoft, fontSize: 12, height: 1.2),
        ),
        if (band)
          Text(
            l10n.seedChanceStep(l10n.seedChanceSummary(next.chances)),
            key: const ValueKey('seed-chance-step'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _ivory, fontSize: 12, height: 1.2),
          ),
      ],
    );
  }
}

class _NextHouseArt extends StatefulWidget {
  const _NextHouseArt({required this.frame});

  final int frame;

  @override
  State<_NextHouseArt> createState() => _NextHouseArtState();
}

class _NextHouseArtState extends State<_NextHouseArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant _NextHouseArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.frame != oldWidget.frame + 1) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    _pulse.forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = Curves.easeOutBack.transform(_pulse.value);
        final scale = _pulse.isAnimating ? 0.86 + 0.14 * t : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Image.asset(
        PlotStages.assetOf(PlotKind.house, widget.frame),
        key: const ValueKey('next-house-image'),
        width: _actionExtent,
        height: _actionExtent,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Opaque height fraction of each 1024² house frame. Early looks sit
/// at the bottom of the canvas, so thumbnails zoom into that region.
const _houseContentSpan = <double>[
  0.322,
  0.568,
  0.593,
  0.727,
  0.572,
  0.786,
  0.791,
  0.701,
  0.795,
  0.765,
  0.852,
  0.850,
  0.766,
  0.707,
  0.872,
  0.858,
  0.828,
  0.804,
  0.857,
  0.860,
  0.881,
  0.887,
  0.908,
  0.912,
];

const _houseMistMatrix = <double>[
  0.52,
  0.34,
  0.14,
  0,
  16,
  0.46,
  0.40,
  0.14,
  0,
  20,
  0.40,
  0.36,
  0.24,
  0,
  28,
  0,
  0,
  0,
  0.92,
  0,
];

const _lookGold = Color(0xFFE8C96A);
const _lookLineHeight = 58.0;
const _lookCellWidth = 62.0;

/// All 24 house frames. Built ones are marked on a gold track; the rest are fog.
class _HouseLookLine extends StatefulWidget {
  const _HouseLookLine({super.key, required this.stage});

  final double stage;

  @override
  State<_HouseLookLine> createState() => _HouseLookLineState();
}

class _HouseLookLineState extends State<_HouseLookLine> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerCurrent());
  }

  @override
  void didUpdateWidget(covariant _HouseLookLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (PlotStages.currentFrame(oldWidget.stage) !=
        PlotStages.currentFrame(widget.stage)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerCurrent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _centerCurrent() {
    if (!mounted || !_scroll.hasClients) return;
    final current = PlotStages.currentFrame(widget.stage);
    final index = current <= 0 ? 0 : current - 1;
    final viewport = _scroll.position.viewportDimension;
    final itemCenter = index * _lookCellWidth + _lookCellWidth / 2;
    final target = itemCenter - viewport / 2;
    _scroll.jumpTo(target.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    final current = PlotStages.currentFrame(widget.stage);
    return Semantics(
      container: true,
      label: AppLocalizations.of(
        context,
      ).houseLookLine(current, PlotStages.frameCount),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x40140A06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x33D4AF37)),
        ),
        child: SizedBox(
          height: _lookLineHeight,
          child: ListView.builder(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            primary: false,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemExtent: _lookCellWidth,
            itemCount: PlotStages.frameCount,
            itemBuilder: (context, index) {
              final frame = index + 1;
              final built = current > 0 && frame <= current;
              return _HouseLookCell(
                frame: frame,
                built: built,
                here: frame == current,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HouseLookCell extends StatelessWidget {
  const _HouseLookCell({
    required this.frame,
    required this.built,
    required this.here,
  });

  final int frame;
  final bool built;
  final bool here;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: here
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _lookGold, width: 1.5),
                    )
                  : const BoxDecoration(),
              child: Padding(
                padding: EdgeInsets.all(here ? 2 : 1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ZoomedHouse(frame: frame, mist: !built),
                      if (!built)
                        CustomPaint(
                          key: ValueKey('house-look-fog-$frame'),
                          painter: const _FogVeilPainter(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _LookTrack(
            built: built,
            here: here,
            markKey: built ? ValueKey('house-look-built-$frame') : null,
          ),
        ],
      ),
    );
  }
}

class _ZoomedHouse extends StatelessWidget {
  const _ZoomedHouse({required this.frame, required this.mist});

  final int frame;
  final bool mist;

  @override
  Widget build(BuildContext context) {
    assert(_houseContentSpan.length == PlotStages.frameCount);
    final span = _houseContentSpan[frame - 1];
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxHeight / span;
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cache = (side * dpr).round().clamp(96, 512);
        Widget image = Image.asset(
          PlotStages.assetOf(PlotKind.house, frame),
          width: side,
          height: side,
          fit: BoxFit.fill,
          cacheWidth: cache,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          excludeFromSemantics: true,
        );
        if (mist) {
          image = ColorFiltered(
            colorFilter: const ColorFilter.matrix(_houseMistMatrix),
            child: image,
          );
        }
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            minWidth: side,
            maxWidth: side,
            minHeight: side,
            maxHeight: side,
            child: image,
          ),
        );
      },
    );
  }
}

class _LookTrack extends StatelessWidget {
  const _LookTrack({required this.built, required this.here, this.markKey});

  final bool built;
  final bool here;
  final Key? markKey;

  @override
  Widget build(BuildContext context) {
    final line = built ? _lookGold : const Color(0x668EACBA);
    return SizedBox(
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: SizedBox(height: 2, child: ColoredBox(color: line)),
          ),
          Container(
            key: markKey,
            width: here ? 9 : 6,
            height: here ? 9 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: built ? _lookGold : const Color(0xFF9BB0BC),
              border: Border.all(color: const Color(0xFF3A2012), width: 1),
              boxShadow: here
                  ? const [BoxShadow(color: Color(0xAAE8C96A), blurRadius: 5)]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FogVeilPainter extends CustomPainter {
  const _FogVeilPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cloud = Paint()
      ..color = const Color(0xA8F7FBFD)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.66),
        width: size.width * 1.15,
        height: size.height * 0.72,
      ),
      cloud,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.32, size.height * 0.4),
        width: size.width * 0.72,
        height: size.height * 0.42,
      ),
      cloud..color = const Color(0x8CFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant _FogVeilPainter oldDelegate) => false;
}
