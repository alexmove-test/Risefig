import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/meta_features.dart';
import '../services/feature_intro_store.dart';
import 'premium_ui.dart';
import 'tutorial_coach.dart';

const _ivory = Color(0xFFF8F1DE);
const _woodDark = Color(0xFF3A2012);

IconData featureIcon(MetaFeature feature) => switch (feature) {
  MetaFeature.house => Icons.home_rounded,
  MetaFeature.points => Icons.toll_rounded,
  MetaFeature.garden => Icons.grass_rounded,
  MetaFeature.warehouse => Icons.inventory_2_rounded,
  MetaFeature.seeds => Icons.spa_rounded,
  MetaFeature.cross => Icons.spa_outlined,
  MetaFeature.neighbors => Icons.people_alt_rounded,
  MetaFeature.showcase => Icons.public,
  MetaFeature.leaderboard => Icons.leaderboard_rounded,
  MetaFeature.pets => Icons.pets_rounded,
};

/// Показывает карточку-знакомство с [feature] один раз за всю игру.
///
/// Флаг ставится до показа: карточка не должна вернуться, даже если её закрыли
/// системной кнопкой «назад».
Future<void> showFeatureIntroOnce(
  BuildContext context,
  MetaFeature feature, {
  FeatureIntroStore? store,
}) async {
  final intros = store ?? await FeatureIntroStore.open();
  if (intros.isSeen(feature) || !context.mounted) return;
  await intros.markSeen(feature);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => FeatureIntroCard(feature: feature),
  );
}

/// Иконка, название и одна-две фразы «что это даёт» с кнопкой «Понятно».
class FeatureIntroCard extends StatelessWidget {
  const FeatureIntroCard({super.key, required this.feature});

  final MetaFeature feature;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: DecoratedBox(
          key: ValueKey('feature-intro-${feature.name}'),
          decoration: EmbossedDecoration.panel(
            borderRadius: BorderRadius.circular(18),
            borderWidth: 1.5,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  featureIcon(feature),
                  color: EmbossedDecoration.goldSoft,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.featureTitle(feature),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: EmbossedDecoration.goldSoft,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.featureBody(feature),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _ivory,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  key: const ValueKey('feature-intro-ok'),
                  style: FilledButton.styleFrom(
                    backgroundColor: EmbossedDecoration.gold,
                    foregroundColor: _woodDark,
                    minimumSize: const Size(140, 44),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.featureGotIt,
                    style: const TextStyle(fontWeight: FontWeight.w800),
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

/// Пульс и плашка «NEW» на кнопке, пока игрок не открыл новую фичу.
class NewFeatureMark extends StatelessWidget {
  const NewFeatureMark({
    super.key,
    required this.active,
    required this.child,
    this.onLeadingEdge = false,
  });

  final bool active;
  final Widget child;

  /// Плашка у левого края. Нужна шторке, прижатой к правому краю экрана.
  final bool onLeadingEdge;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TutorialSpotlight(active: true, child: child),
        Positioned(
          top: -7,
          right: onLeadingEdge ? null : -6,
          left: onLeadingEdge ? -6 : null,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFC0392B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _ivory, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                child: Text(
                  AppLocalizations.of(context).featureNewBadge,
                  style: const TextStyle(
                    color: _ivory,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
