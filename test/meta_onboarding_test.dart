import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/l10n/l10n.dart';
import 'package:mahjong/models/hub_goal.dart';
import 'package:mahjong/models/meta_features.dart';
import 'package:mahjong/screens/level_select_screen.dart';
import 'package:mahjong/services/hub_goals.dart';
import 'package:mahjong/services/progress_store.dart';
import 'package:mahjong/widgets/feature_intro_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('the hub goal names the next feature to unlock', () async {
    SharedPreferences.setMockInitialValues({'progress.maxUnlocked': 1});
    final progress = await ProgressStore.open();
    final goal = HubGoals.pick(progress: progress, featureUnlocks: true);
    expect(goal?.kind, HubGoalKind.featureUnlock);
    expect(goal?.feature, MetaFeature.house);
    expect(goal?.remaining, 1);

    final en = lookupAppLocalizations(const Locale('en'));
    final ru = lookupAppLocalizations(const Locale('ru'));
    expect(en.hubGoalText(goal!), '1 more level to unlock: House');
    expect(ru.hubGoalText(goal), 'Ещё 1 уровень — откроется: Дом');
  });

  test('without the flag the hub goal ignores feature unlocks', () async {
    SharedPreferences.setMockInitialValues({'progress.maxUnlocked': 2});
    final progress = await ProgressStore.open();
    final goal = HubGoals.pick(progress: progress);
    expect(goal?.kind, isNot(HubGoalKind.featureUnlock));
  });

  testWidgets('an early hub keeps the yard and hides later shops', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'progress.maxUnlocked': 2,
      'progress.stars.1': 1,
      'progress.best.1': 400,
      'progress.lastPlayed': 1,
      'progress.courtyardPanHintDone': true,
    });
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LevelSelectScreen(),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const ValueKey('neighbors-entry')), findsOneWidget);
    expect(find.byKey(const ValueKey('courtyard-warehouse')), findsOneWidget);
    expect(find.byKey(const ValueKey('courtyard-garden-plot')), findsOneWidget);
    expect(find.byKey(const ValueKey('seed-storage-button')), findsNothing);
    expect(find.byTooltip('Leaderboard'), findsNothing);
    expect(find.text('NEW'), findsWidgets);
  });

  testWidgets('a feature intro shows once and then stays quiet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    showFeatureIntroOnce(context, MetaFeature.garden);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('feature-intro-garden')), findsOneWidget);
    expect(find.text('Garden'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('feature-intro-ok')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('feature-intro-garden')), findsNothing);

    showFeatureIntroOnce(context, MetaFeature.garden);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('feature-intro-garden')), findsNothing);
  });
}
