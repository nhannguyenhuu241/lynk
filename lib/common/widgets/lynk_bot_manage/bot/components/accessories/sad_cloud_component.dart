import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Component vẽ đám mây buồn và sấm sét cho trạng thái 'sadboi'.
class SadCloudComponent extends PositionComponent {
  final _sadCloudPaint = Paint();
  final _lightningPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3;

  double animationTime = 0.0;
  double _lightningTimer = 0.0;
  bool _showLightning = false;
  double componentOpacity = 1.0;

  SadCloudComponent({required Vector2 size}) {
    this.size = size;
    // SỬA LỖI: Đồng bộ anchor về topLeft giống các component khác.
    anchor = Anchor.topLeft;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (componentOpacity > 0) {
      _updateLightning(dt);
    }
  }

  void _updateLightning(double dt) {
    _lightningTimer += dt;
    if (_lightningTimer > 4.0 + Random().nextDouble() * 4.0) {
      _lightningTimer = 0;
      _showLightning = true;
    }
    if (_showLightning && _lightningTimer > 0.15) {
      _showLightning = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (componentOpacity <= 0) return;

    _sadCloudPaint.color = const Color(0xFF9E9E9E).withValues(alpha: componentOpacity);
    _lightningPaint.color = const Color(0xFFFFEB3B).withValues(alpha: componentOpacity);

    // Logic vẽ vẫn sử dụng center, tương thích với anchor mới.
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final bobble = sin(animationTime * 2) * 3;
    final cloudCenter = Offset(center.dx, center.dy - radius * 1.2 + bobble);

    final cloudPath = Path()
      ..addOval(Rect.fromCenter(center: cloudCenter, width: radius * 1.2, height: radius * 0.5))
      ..addOval(Rect.fromCenter(center: Offset(cloudCenter.dx-radius*0.4, cloudCenter.dy + 5), width: radius * 0.7, height: radius * 0.4))
      ..addOval(Rect.fromCenter(center: Offset(cloudCenter.dx+radius*0.4, cloudCenter.dy + 5), width: radius * 0.8, height: radius * 0.5));
    canvas.drawPath(cloudPath, _sadCloudPaint);

    if (_showLightning) {
      final lightningPath = Path()
        ..moveTo(cloudCenter.dx, cloudCenter.dy + radius * 0.2)
        ..lineTo(cloudCenter.dx - 10, cloudCenter.dy + radius * 0.4)
        ..lineTo(cloudCenter.dx + 5, cloudCenter.dy + radius * 0.45)
        ..lineTo(cloudCenter.dx - 5, cloudCenter.dy + radius * 0.7);
      canvas.drawPath(lightningPath, _lightningPaint);
    }
  }
}
