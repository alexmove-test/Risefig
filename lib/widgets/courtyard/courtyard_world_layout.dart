import 'dart:math' as math;
import 'dart:ui';

import '../../models/courtyard_reward.dart';
import 'courtyard_lot_build.dart';

/// Нормированная раскладка `country_base.png` (9:16): двор по центру экрана.
abstract final class CourtyardWorldLayout {
  static const mapWidth = 720.0;
  static const mapHeight = 1280.0;
  static const mapAspect = mapWidth / mapHeight;

  static const countryBase = 'assets/courtyard/world/country_base.png';

  /// Лужайка внутри ограды, в долях карты. Небо над ней закрывает верхняя панель.
  static const lawn = Rect.fromLTRB(0.06, 0.38, 0.94, 0.70);

  /// Дом на каменном круге: левый верхний угол лужайки.
  static const homeYard = Rect.fromLTWH(0.111, 0.359, 0.278, 0.156);

  /// Пруд в верхней середине, между домом и складом, выше креста дорожек.
  static const pondYard = Rect.fromLTWH(0.46, 0.418, 0.14, 0.078);

  /// Знак производства семян: узкий зазор между домом и прудом.
  static const seedBadge = Rect.fromLTWH(0.392, 0.49, 0.042, 0.026);

  static const gardenPlotAsset = 'assets/courtyard/garden/garden_plot.png';
  static const warehouseAsset = 'assets/courtyard/garden/warehouse.png';

  /// Пропорции спрайтов в пикселях: рамки держат их без искажений.
  static const _gardenPlotAspect = 904 / 628;
  static const _warehouseAspect = 848 / 893;

  /// Огород в левом нижнем углу. Ширина 0.30 — размер до того,
  /// как участок ужали, чтобы обойти старую развилку.
  static final gardenPlot = _sprite(0.145, 0.582, 0.30, _gardenPlotAspect);

  /// Склад в правом верхнем углу, той же ширины 0.16, что была раньше.
  static final warehouse = _standingSprite(
    0.735,
    0.520,
    0.16,
    _warehouseAspect,
  );

  /// Огород и склад стоят по диагонали, поэтому общий прямоугольник
  /// накрыл бы центр лужайки. Для проверок берут каждое место отдельно.
  static Rect get gardenYard => gardenPlot.expandToInclude(warehouse);

  /// Грядки лежат на трёх рядах земли подложки — доли внутри [gardenPlot].
  static final gardenBeds = <Rect>[
    _inPlot(const Rect.fromLTWH(0.18, 0.32, 0.20, 0.24)),
    _inPlot(const Rect.fromLTWH(0.395, 0.395, 0.20, 0.24)),
    _inPlot(const Rect.fromLTWH(0.615, 0.47, 0.20, 0.24)),
  ];

  static Rect gardenBed(int index) => gardenBeds[index];

  static Rect _inPlot(Rect frac) => Rect.fromLTWH(
    gardenPlot.left + frac.left * gardenPlot.width,
    gardenPlot.top + frac.top * gardenPlot.height,
    frac.width * gardenPlot.width,
    frac.height * gardenPlot.height,
  );

  /// Рамка спрайта с пропорцией [aspect] (ширина к высоте в пикселях).
  static Rect _sprite(double left, double top, double width, double aspect) {
    return Rect.fromLTWH(left, top, width, width * mapAspect / aspect);
  }

  static Rect _standingSprite(
    double x,
    double ground,
    double width,
    double aspect,
  ) {
    final height = width * mapAspect / aspect;
    return Rect.fromLTWH(x - width / 2, ground - height, width, height);
  }

  /// Питомцы в правом нижнем углу. Размер как до уменьшения площадки.
  static const petYard = Rect.fromLTWH(0.53, 0.558, 0.32, 0.14);

  /// Соседние дворы вырезаны из кадра, тапать на карте нечего.
  static const neighbors = <Rect>[];

  static int get neighborCount => neighbors.length;

  /// Кадр камеры: вся лужайка с запасом на ограду.
  static Rect get yardCover => lawn.inflate(0.02);

  /// Награды стоят на свободной траве, в стороне от дома и питомца.
  /// Спрайты квадратные, поэтому рамка тоже квадратная в пикселях карты:
  /// доля высоты больше доли ширины во столько же раз, во сколько карта шире.
  static Rect rewardOf(CourtyardReward reward) => switch (reward) {
    CourtyardReward.pond => _standing(0.53, 0.496, 0.11),
    CourtyardReward.swing => _standing(0.905, 0.50, 0.06),
    CourtyardReward.flowerBed => _standing(0.905, 0.66, 0.055),
  };

  /// Квадратная рамка ширины [width], стоящая низом на точке ([x], [ground]).
  static Rect _standing(double x, double ground, double width) {
    final height = width * mapAspect;
    return Rect.fromLTWH(x - width / 2, ground - height, width, height);
  }

  static Rect neighborOf(int slot) => neighbors[slot];

  static Rect mapRect(Rect norm) {
    return Rect.fromLTWH(
      norm.left * mapWidth,
      norm.top * mapHeight,
      norm.width * mapWidth,
      norm.height * mapHeight,
    );
  }

  /// Масштаб, при котором карта закрывает весь [viewport] — без полей по бокам.
  static double coverScale(Size viewport) {
    if (viewport.width < 1 || viewport.height < 1) return 1;
    return math.max(viewport.width / mapWidth, viewport.height / mapHeight);
  }

  /// Камера: участок в кадре, карта всегда до краёв экрана.
  static ({double scale, double tx, double ty}) camera({
    required Size viewport,
    required Rect focusNorm,
    double coverage = 0.78,
  }) {
    final focus = mapRect(focusNorm);
    final cover = coverScale(viewport);
    var scale = math.min(
      viewport.width * coverage / focus.width,
      viewport.height * coverage / focus.height,
    );
    if (scale < cover) scale = cover;

    var tx = viewport.width / 2 - focus.center.dx * scale;
    var ty = viewport.height / 2 - focus.center.dy * scale;
    final minTx = viewport.width - mapWidth * scale;
    final minTy = viewport.height - mapHeight * scale;
    if (minTx <= 0) tx = tx.clamp(minTx, 0);
    if (minTy <= 0) ty = ty.clamp(minTy, 0);
    return (scale: scale, tx: tx, ty: ty);
  }

  static List<String> get allAssets => [
    countryBase,
    gardenPlotAsset,
    warehouseAsset,
    ...PlotStages.allAssets,
  ];
}
