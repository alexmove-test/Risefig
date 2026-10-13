import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_features.dart';

/// Какие фичи мета-игры игрок уже открывал и видел их карточку-знакомство.
class FeatureIntroStore {
  FeatureIntroStore._(this._prefs);

  final SharedPreferences _prefs;

  static String _keyFor(MetaFeature feature) => 'intro.${feature.name}';

  static Future<FeatureIntroStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return FeatureIntroStore._(prefs);
  }

  bool isSeen(MetaFeature feature) => _prefs.getBool(_keyFor(feature)) ?? false;

  Future<void> markSeen(MetaFeature feature) =>
      _prefs.setBool(_keyFor(feature), true);

  Future<void> reset() async {
    for (final feature in MetaFeature.values) {
      await _prefs.remove(_keyFor(feature));
    }
  }
}
