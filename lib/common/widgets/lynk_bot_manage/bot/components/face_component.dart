import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Component chịu trách nhiệm vẽ phần thân/mặt chính của Lynk.
class FaceComponent extends PositionComponent {
  late Paint bodyPaint;
  final _shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.1)
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);

  bool showShadow = true;

  FaceComponent({required Vector2 size}) {
    this.size = size;
    anchor = Anchor.topLeft;
    updateColor();
  }

  void updateColor([Color centerColor = const Color(0xFF61CFF8), Color edgeColor = Colors.white]) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    bodyPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [centerColor, edgeColor],
        [0.6, 1.0],
      );
  }

  @override
  void render(Canvas canvas) {
    final center = size.toOffset() / 2;
    if (showShadow) {
      final shadowCenter = Offset(center.dx, size.y * 1.05);
      final shadowRect = Rect.fromCenter(center: shadowCenter, width: size.x * 0.8, height: size.y * 0.2);
      canvas.drawOval(shadowRect, _shadowPaint);
    }
    // Vẽ thân
    canvas.drawCircle(center, size.x / 2, bodyPaint);
  }
}
