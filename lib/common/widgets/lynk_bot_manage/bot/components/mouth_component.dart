import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/avatar_expressions.dart';

/// Component chịu trách nhiệm vẽ miệng của Lynk.
class MouthComponent extends PositionComponent {
  MouthExpression expression = MouthExpression.normal;
  double componentOpacity = 1.0;

  final _linePaint = Paint()
    ..color = const Color(0xFF0C253A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;
  final _fillPaint = Paint()..color = const Color(0xFF333333);
  final _tearPaint = Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.8);

  MouthComponent({required Vector2 size}) {
    this.size = size;
    // SỬA LỖI: Đồng bộ anchor về topLeft giống EyesComponent.
    anchor = Anchor.topLeft;
  }

  @override
  void render(Canvas canvas) {
    if (componentOpacity <= 0) return;

    // SỬA LỖI: Đồng bộ saveLayer giống EyesComponent.
    canvas.saveLayer(size.toRect(), Paint()..color = Colors.white.withValues(alpha: componentOpacity));

    _renderMouth(canvas);

    canvas.restore();
  }

  void _renderMouth(Canvas canvas) {
    switch (expression) {
      case MouthExpression.happy: _drawMouthHappy(canvas); break;
      case MouthExpression.sad: _drawMouthSad(canvas); break;
      case MouthExpression.angry: _drawMouthAngry(canvas); break;
      case MouthExpression.listening: _drawMouthListening(canvas); break;
      case MouthExpression.dizzy: _drawMouthDizzy(canvas); break;
      case MouthExpression.trolling: _drawMouthDefault(canvas, smileOffset: 0.2, mouthWidth: 0.4); break;
      default: _drawMouthDefault(canvas); break;
    }
  }

  // SỬA LỖI: Tất cả các hàm vẽ được cập nhật để sử dụng `center = size / 2` giống EyesComponent.

  void _drawMouthDefault(Canvas canvas, {double mouthWidth = 0.2, double smileOffset = 0.2}) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final mouthPath = Path();
    final mouthY = center.dy + radius * 0.3;
    mouthPath.moveTo(center.dx - radius * mouthWidth, mouthY);
    mouthPath.quadraticBezierTo(center.dx, mouthY + radius * smileOffset, center.dx + radius * mouthWidth, mouthY);
    canvas.drawPath(mouthPath, _linePaint..strokeWidth = 4);
  }

  void _drawMouthListening(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final mouthY = center.dy + radius * 0.35;
    final mouthWidth = radius * 0.15;
    final mouthHeight = radius * 0.2;
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, mouthY), width: mouthWidth, height: mouthHeight), _fillPaint..style=PaintingStyle.fill);
  }

  void _drawMouthHappy(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final mouthY = center.dy + radius * 0.2;
    final mouthRect = Rect.fromCenter(center: Offset(center.dx, mouthY + radius * 0.25), width: radius * 0.7, height: radius * 0.5);
    canvas.drawArc(mouthRect, 0, pi, true, _fillPaint);
    final tonguePaint = Paint()..color = const Color(0xFFE57373);
    final tongueRect = Rect.fromCenter(center: Offset(center.dx, mouthY + radius * 0.4), width: radius * 0.4, height: radius * 0.2);
    canvas.drawArc(tongueRect, 0, pi, true, tonguePaint);
  }

  void _drawMouthAngry(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final mouthY = center.dy + radius * 0.4;
    final path = Path();
    path.moveTo(center.dx - radius * 0.4, mouthY + radius * 0.1);
    path.quadraticBezierTo(center.dx, mouthY - radius * 0.2, center.dx + radius * 0.4, mouthY + radius * 0.1);
    canvas.drawPath(path, _linePaint..strokeWidth = 4);
  }

  void _drawMouthSad(Canvas canvas) {
    _drawMouthDefault(canvas, smileOffset: -0.1);
  }

  void _drawMouthDizzy(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final mouthY = center.dy + radius * 0.3;
    final mouthRect = Rect.fromCenter(center: Offset(center.dx, mouthY), width: radius * 0.3, height: radius * 0.3);
    canvas.drawArc(mouthRect, 0, pi, false, _linePaint..strokeWidth = 4);
    final droolPath = Path()
      ..moveTo(center.dx + radius * 0.15, mouthY + radius * 0.15)
      ..quadraticBezierTo(center.dx + radius * 0.25, mouthY + radius * 0.3, center.dx + radius * 0.2, mouthY + radius * 0.4);
    canvas.drawPath(droolPath, _tearPaint..strokeWidth=2);
  }
}
