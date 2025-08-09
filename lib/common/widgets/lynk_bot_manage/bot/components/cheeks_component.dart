import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Component vẽ má hồng cho Lynk.
class CheeksComponent extends PositionComponent {
  final _cheekPaint = Paint()
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6.0);

  double opacity = 0.7;

  CheeksComponent({required Vector2 size}) {
    this.size = size;
    anchor = Anchor.topLeft;
  }

  @override
  void render(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final cheekWidth = radius * 0.35;
    final cheekHeight = radius * 0.15;
    final cheekOffsetY = radius * 0.15;
    final cheekOffsetX = radius * 0.45;

    _cheekPaint.color = Colors.white.withValues(alpha: opacity);

    final leftCheekRect = Rect.fromCenter(
        center: Offset(center.dx - cheekOffsetX, center.dy + cheekOffsetY),
        width: cheekWidth,
        height: cheekHeight);
    final rightCheekRect = Rect.fromCenter(
        center: Offset(center.dx + cheekOffsetX, center.dy + cheekOffsetY),
        width: cheekWidth,
        height: cheekHeight);

    canvas.drawOval(leftCheekRect, _cheekPaint);
    canvas.drawOval(rightCheekRect, _cheekPaint);
  }
}
