import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Component vẽ kính râm cho trạng thái 'trolling'.
class SunglassesComponent extends PositionComponent {
  final _sunglassesPaint = Paint();
  final _sunglassesShinePaint = Paint();
  double componentOpacity = 1.0;

  SunglassesComponent({required Vector2 size}) {
    this.size = size;
    // SỬA LỖI: Đồng bộ anchor về topLeft giống các component khác.
    anchor = Anchor.topLeft;
  }

  @override
  void render(Canvas canvas) {
    if (componentOpacity <= 0) return;

    _sunglassesPaint.color = Colors.black.withValues(alpha: componentOpacity);
    _sunglassesShinePaint.color = Colors.white.withValues(alpha: 0.6 * componentOpacity);

    // Logic vẽ vẫn sử dụng center, tương thích với anchor mới.
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final eyeOffsetY = -radius * 0.2;
    final glassWidth = radius * 0.9;
    final glassHeight = radius * 0.35;

    final bridge = Path()
      ..moveTo(center.dx - glassWidth * 0.2, center.dy + eyeOffsetY)
      ..quadraticBezierTo(center.dx, center.dy + eyeOffsetY + 5, center.dx + glassWidth * 0.2, center.dy + eyeOffsetY);
    canvas.drawPath(bridge, _sunglassesPaint..style=PaintingStyle.stroke..strokeWidth=4);

    final leftGlassRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.4, center.dy + eyeOffsetY), width: glassWidth, height: glassHeight),
      const Radius.circular(10),
    );
    final rightGlassRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx + radius * 0.4, center.dy + eyeOffsetY), width: glassWidth, height: glassHeight),
      const Radius.circular(10),
    );
    canvas.drawRRect(leftGlassRect, _sunglassesPaint..style=PaintingStyle.fill);
    canvas.drawRRect(rightGlassRect, _sunglassesPaint..style=PaintingStyle.fill);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(leftGlassRect.left + 5, leftGlassRect.top + 5, 15, 5), Radius.circular(5)), _sunglassesShinePaint);
  }
}
