import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/models/meta_features.dart';
import 'package:mahjong/services/feature_intro_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('a seen intro stays seen after reopening', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await FeatureIntroStore.open();
    expect(store.isSeen(MetaFeature.garden), isFalse);

    await store.markSeen(MetaFeature.garden);
    final again = await FeatureIntroStore.open();
    expect(again.isSeen(MetaFeature.garden), isTrue);
    expect(again.isSeen(MetaFeature.house), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('intro.garden'), isTrue);
  });

  test('reset shows every intro again', () async {
    SharedPreferences.setMockInitialValues({
      'intro.house': true,
      'intro.neighbors': true,
      'tutorial.collect': true,
    });
    final store = await FeatureIntroStore.open();
    await store.reset();
    for (final feature in MetaFeature.values) {
      expect(store.isSeen(feature), isFalse, reason: '$feature');
    }
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('tutorial.collect'), isTrue);
  });
}
