import 'dart:math' as math;

import 'package:flutter/material.dart';

/// CustomPainter for the holographic energy orb.
///
/// Creates a pulsating, reactive orb with multiple energy layers
/// that respond to audio volume input.
class EnergyOrbPainter extends CustomPainter {
  /// Creates an energy orb painter.
  ///
  /// [animation] controls the continuous rotation of energy strands.
  /// [volume] controls the intensity of deformation (0.0 to 1.0).
  /// [primaryColor] is the main color theme for the orb.
  /// [secondaryColor] is the accent color for energy layers.
  EnergyOrbPainter({
    required this.animation,
    required this.volume,
    this.primaryColor = const Color(0xFF00FFFF),
    this.secondaryColor = const Color(0xFFFF00FF),
  }) : super(repaint: animation);

  /// Animation controller value (0.0 to 1.0).
  final Animation<double> animation;

  /// Current volume level (0.0 to 1.0).
  final double volume;

  /// Primary orb color.
  final Color primaryColor;

  /// Secondary orb color.
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius =
        (size.width / 3) + (math.sin(animation.value * math.pi * 2) * 2);
    final t = animation.value * 2 * math.pi;

    final paint = Paint()..blendMode = BlendMode.plus;

    // Layer 1: Primary color (fast rotation)
    _drawEnergyStrand(
      canvas,
      center,
      baseRadius,
      t,
      volume,
      color: primaryColor,
      rotationSpeed: 1,
      waveCount: 3,
      complexity: 1.5,
      paint: paint,
    );

    // Layer 2: Secondary color (medium, reverse rotation)
    _drawEnergyStrand(
      canvas,
      center,
      baseRadius,
      t,
      volume,
      color: secondaryColor,
      rotationSpeed: -0.7,
      waveCount: 4,
      complexity: 1.2,
      paint: paint,
    );

    // Layer 3: Violet accent (slow rotation)
    _drawEnergyStrand(
      canvas,
      center,
      baseRadius,
      t,
      volume,
      color: const Color(0xFF9D00FF),
      rotationSpeed: 0.3,
      waveCount: 2,
      complexity: 2,
      paint: paint,
    );

    // Core: White energy center
    _drawCore(canvas, center, baseRadius, volume);

    // Outer aura glow
    _drawAura(canvas, center, baseRadius, volume);
  }

  void _drawEnergyStrand(
    Canvas canvas,
    Offset center,
    double radius,
    double time,
    double vol, {
    required Color color,
    required double rotationSpeed,
    required int waveCount,
    required double complexity,
    required Paint paint,
  }) {
    final path = Path();

    paint
      ..color = color.withValues(alpha: 0.3 + (vol * 0.3))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + (vol * 3.0)
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);

    const points = 120;

    for (var i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * math.pi;

      // Wave formula with superposition
      final offset = math.sin(angle * waveCount + (time * rotationSpeed));
      final secondary = math.cos(angle * (waveCount * 2) - time);

      // Deformation intensity based on volume
      final intensity = 10 + (vol * 40);

      final r =
          radius +
          (offset * intensity * complexity) +
          (secondary * intensity * 0.5);

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCore(Canvas canvas, Offset center, double baseRadius, double vol) {
    final coreRadius = (baseRadius * 0.4) + (vol * 20);

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          primaryColor.withValues(alpha: 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius * 2));

    canvas.drawCircle(center, coreRadius, corePaint);
  }

  void _drawAura(Canvas canvas, Offset center, double baseRadius, double vol) {
    final auraRadius = baseRadius * (1.2 + (vol * 0.5));

    final auraPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.1 + (vol * 0.1))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(center, auraRadius, auraPaint);
  }

  @override
  bool shouldRepaint(covariant EnergyOrbPainter oldDelegate) => true;
}
