import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/models/levels.dart';
import 'package:mahjong/models/meta_features.dart';

void main() {
  test('a fresh save already has the yard, pets, garden and neighbors', () {
    final cleared = MetaFeatures.clearedFrom(1);
    expect(cleared, 0);
    for (final feature in [
      MetaFeature.pets,
      MetaFeature.garden,
      MetaFeature.warehouse,
      MetaFeature.neighbors,
      MetaFeature.leaderboard,
    ]) {
      expect(MetaFeatures.isOpen(feature, cleared), isTrue, reason: '$feature');
    }
    for (final feature in [
      MetaFeature.house,
      MetaFeature.points,
      MetaFeature.seeds,
      MetaFeature.cross,
      MetaFeature.showcase,
    ]) {
      expect(
        MetaFeatures.isOpen(feature, cleared),
        isFalse,
        reason: '$feature',
      );
    }
  });

  test('features open one group at a time', () {
    expect(MetaFeatures.isOpen(MetaFeature.house, 0), isFalse);
    expect(MetaFeatures.isOpen(MetaFeature.house, 1), isTrue);
    expect(MetaFeatures.isOpen(MetaFeature.points, 1), isTrue);
    expect(MetaFeatures.isOpen(MetaFeature.garden, 0), isTrue);
    expect(MetaFeatures.isOpen(MetaFeature.warehouse, 0), isTrue);
    expect(MetaFeatures.isOpen(MetaFeature.neighbors, 0), isTrue);
    expect(MetaFeatures.isOpen(MetaFeature.seeds, 4), isFalse);
    expect(MetaFeatures.isOpen(MetaFeature.seeds, 5), isTrue);
    expect(MetaFeatures.isOpen(MetaFeature.leaderboard, 0), isTrue);
    expect(MetaFeatures.isOpen(MetaFeature.showcase, 7), isFalse);
    expect(MetaFeatures.isOpen(MetaFeature.showcase, 8), isTrue);
  });

  test('next locked feature counts the levels left', () {
    expect(MetaFeatures.nextLocked(0), (
      feature: MetaFeature.house,
      remaining: 1,
    ));
    expect(MetaFeatures.nextLocked(1), isNull);
    expect(MetaFeatures.nextLocked(8), isNull);
  });

  test('older saves far into the campaign have everything open', () {
    final cleared = MetaFeatures.clearedFrom(Levels.maxLevelId);
    for (final feature in MetaFeature.values) {
      expect(MetaFeatures.isOpen(feature, cleared), isTrue, reason: '$feature');
    }
    expect(MetaFeatures.nextLocked(cleared), isNull);
  });
}
