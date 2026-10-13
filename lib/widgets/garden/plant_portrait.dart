import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/garden.dart';
import '../../models/seed_catalog.dart';

const _stem = Color(0xFF2F5C45);
const _light = Color(0xFFFFF6E4);

/// Спелый портрет вида. Росток и рост — тот же рисунок, меньше.
void paintGrownPlant(
  Canvas canvas,
  Size size,
  SeedSpecies species,
  GrowthStage stage,
) {
  final side = size.shortestSide;
  final ground = Offset(size.width / 2, size.height * 0.86);
  final scale = switch (stage) {
    GrowthStage.sprout => 0.48,
    GrowthStage.growing => 0.74,
    _ => 1.0,
  };
  canvas.save();
  canvas.translate(ground.dx, ground.dy);
  canvas.scale(scale);
  canvas.translate(-ground.dx, -ground.dy);
  final color = switch (species) {
    SeedSpecies.amberbell => const Color(0xFFE2A53A),
    SeedSpecies.mistfern => const Color(0xFF3E8F62),
    SeedSpecies.glassreed => const Color(0xFF7EC8D4),
    SeedSpecies.crimsonplum => const Color(0xFFB44A55),
    SeedSpecies.nightlotus => const Color(0xFF8E74C9),
    SeedSpecies.starbamboo => const Color(0xFF2F8F6B),
  };
  switch (species) {
    case SeedSpecies.amberbell:
      _bell(canvas, ground, side, color);
    case SeedSpecies.mistfern:
      _fern(canvas, ground, side, color);
    case SeedSpecies.glassreed:
      _reed(canvas, ground, side, color);
    case SeedSpecies.crimsonplum:
      _plum(canvas, ground, side, color);
    case SeedSpecies.nightlotus:
      _lotus(canvas, ground, side, color);
    case SeedSpecies.starbamboo:
      _bamboo(canvas, ground, side, color);
  }
  canvas.restore();
}

void _soil(Canvas canvas, Offset ground, double side) {
  canvas.drawOval(
    Rect.fromCenter(
      center: ground,
      width: side * 0.46,
      height: side * 0.1,
    ),
    Paint()..color = const Color(0xFF6A4428).withValues(alpha: 0.35),
  );
}

void _stemLine(Canvas canvas, Offset ground, double side, double height) {
  canvas.drawLine(
    ground,
    ground.translate(0, -side * height),
    Paint()
      ..color = _stem
      ..strokeWidth = side * 0.045
      ..strokeCap = StrokeCap.round,
  );
}

void _bell(Canvas canvas, Offset ground, double side, Color color) {
  _soil(canvas, ground, side);
  _stemLine(canvas, ground, side, 0.62);
  final leaf = Paint()..color = color;
  canvas.drawOval(
    Rect.fromCenter(
      center: ground.translate(-side * 0.12, -side * 0.22),
      width: side * 0.2,
      height: side * 0.1,
    ),
    leaf,
  );
  canvas.drawOval(
    Rect.fromCenter(
      center: ground.translate(side * 0.13, -side * 0.28),
      width: side * 0.22,
      height: side * 0.1,
    ),
    leaf,
  );
  final top = ground.translate(0, -side * 0.58);
  final path = Path()
    ..moveTo(top.dx, top.dy)
    ..quadraticBezierTo(
      top.dx + side * 0.24,
      top.dy + side * 0.05,
      top.dx + side * 0.18,
      top.dy + side * 0.26,
    )
    ..lineTo(top.dx - side * 0.18, top.dy + side * 0.26)
    ..quadraticBezierTo(
      top.dx - side * 0.24,
      top.dy + side * 0.05,
      top.dx,
      top.dy,
    );
  canvas.drawPath(path, Paint()..color = color);
  canvas.drawLine(
    top.translate(-side * 0.12, side * 0.2),
    top.translate(side * 0.12, side * 0.2),
    Paint()
      ..color = _light
      ..strokeWidth = side * 0.02
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawCircle(
    top.translate(0, side * 0.22),
    side * 0.028,
    Paint()..color = const Color(0xFF6B3A22),
  );
}

void _fern(Canvas canvas, Offset ground, double side, Color color) {
  _soil(canvas, ground, side);
  _stemLine(canvas, ground, side, 0.7);
  final leaf = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = side * 0.035
    ..strokeCap = StrokeCap.round;
  for (final step in [0.18, 0.32, 0.46, 0.58]) {
    final origin = ground.translate(0, -side * step);
    canvas.drawLine(origin, origin.translate(-side * 0.16, -side * 0.08), leaf);
    canvas.drawLine(origin, origin.translate(side * 0.16, -side * 0.08), leaf);
  }
}

void _reed(Canvas canvas, Offset ground, double side, Color color) {
  _soil(canvas, ground, side);
  final reed = Paint()
    ..color = color
    ..strokeWidth = side * 0.035
    ..strokeCap = StrokeCap.round;
  final shine = Paint()
    ..color = _light.withValues(alpha: 0.8)
    ..strokeWidth = side * 0.012
    ..strokeCap = StrokeCap.round;
  const marks = [-0.16, -0.05, 0.07, 0.16];
  const heights = [0.48, 0.7, 0.6, 0.4];
  for (var i = 0; i < marks.length; i++) {
    final from = ground.translate(side * marks[i], 0);
    final to = from.translate(side * marks[i] * -0.15, -side * heights[i]);
    canvas.drawLine(from, to, reed);
    canvas.drawLine(from, to, shine);
  }
  canvas.drawCircle(
    ground.translate(0, -side * 0.34),
    side * 0.045,
    Paint()
      ..color = const Color(0xFF1E6C7C).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * 0.012,
  );
}

void _plum(Canvas canvas, Offset ground, double side, Color color) {
  _soil(canvas, ground, side);
  canvas.drawLine(
    ground.translate(-side * 0.2, -side * 0.42),
    ground.translate(side * 0.22, -side * 0.5),
    Paint()
      ..color = const Color(0xFF3A2012)
      ..strokeWidth = side * 0.03
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawCircle(
    ground.translate(-side * 0.08, -side * 0.28),
    side * 0.11,
    Paint()..color = color,
  );
  canvas.drawCircle(
    ground.translate(side * 0.12, -side * 0.36),
    side * 0.09,
    Paint()..color = color,
  );
  canvas.drawCircle(
    ground.translate(-side * 0.12, -side * 0.32),
    side * 0.03,
    Paint()..color = _light.withValues(alpha: 0.7),
  );
}

void _lotus(Canvas canvas, Offset ground, double side, Color color) {
  _soil(canvas, ground, side);
  canvas.drawOval(
    Rect.fromCenter(
      center: ground.translate(0, -side * 0.06),
      width: side * 0.5,
      height: side * 0.1,
    ),
    Paint()..color = color.withValues(alpha: 0.28),
  );
  final center = ground.translate(0, -side * 0.32);
  for (var i = 0; i < 8; i++) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(i * math.pi / 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, -side * 0.11),
        width: side * 0.08,
        height: side * 0.2,
      ),
      Paint()..color = color,
    );
    canvas.restore();
  }
  canvas.drawCircle(center, side * 0.04, Paint()..color = const Color(0xFF3A2A66));
  canvas.drawCircle(
    center.translate(0, -side * 0.012),
    side * 0.016,
    Paint()..color = _light.withValues(alpha: 0.7),
  );
}

void _bamboo(Canvas canvas, Offset ground, double side, Color color) {
  _soil(canvas, ground, side);
  final culm = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: ground.translate(-side * 0.04, -side * 0.34),
      width: side * 0.1,
      height: side * 0.62,
    ),
    Radius.circular(side * 0.05),
  );
  canvas.drawRRect(culm, Paint()..color = color);
  final band = Paint()
    ..color = const Color(0xFF14382F)
    ..strokeWidth = side * 0.012;
  for (final dy in [-0.16, 0.0, 0.16]) {
    final y = ground.dy - side * 0.34 + side * dy;
    canvas.drawLine(
      Offset(ground.dx - side * 0.09, y),
      Offset(ground.dx + side * 0.01, y),
      band,
    );
  }
  _star(
    canvas,
    ground.translate(side * 0.14, -side * 0.58),
    side * 0.07,
    const Color(0xFFFFE7A3),
  );
}

void _star(Canvas canvas, Offset center, double radius, Color color) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final length = i.isEven ? radius : radius * 0.42;
    final angle = -math.pi / 2 + i * math.pi / 5;
    final point = center + Offset(length * math.cos(angle), length * math.sin(angle));
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  path.close();
  canvas.drawPath(path, Paint()..color = color);
}
