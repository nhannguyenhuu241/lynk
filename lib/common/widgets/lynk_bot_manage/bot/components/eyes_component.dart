import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/avatar_expressions.dart';

/// Component chịu trách nhiệm vẽ mắt của Lynk.
class EyesComponent extends PositionComponent {
  EyeExpression expression = EyeExpression.normal;
  double componentOpacity = 1.0;

  final _eyeWhitePaint = Paint()..color = Colors.white;
  final _pupilPaint = Paint()..color = const Color(0xFF333333);
  final _linePaint = Paint()
    ..color = const Color(0xFF0C253A)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final _tearPaint = Paint()..color = const Color(0xFF81D4FA);

  double animationTime = 0.0;
  double dizzyRotationTime = 0.0;

  EyesComponent({required Vector2 size}) {
    this.size = size;
    anchor = Anchor.topLeft;
  }

  @override
  void render(Canvas canvas) {
    if (componentOpacity <= 0) return;
    canvas.saveLayer(size.toRect(), Paint()..color = Colors.white.withValues(alpha: componentOpacity));

    _renderEyes(canvas);

    canvas.restore();
  }

  void _renderEyes(Canvas canvas) {
    switch (expression) {
      case EyeExpression.normal: _drawEyesDefault(canvas); break;
      case EyeExpression.blinking: _drawEyesClosed(canvas); break;
      case EyeExpression.happy: _drawEyesHappy(canvas); break;
      case EyeExpression.closed: _drawEyesClosed(canvas, curve: 0.3); break;
      case EyeExpression.angry: _drawEyesAngry(canvas); break;
      case EyeExpression.sad: _drawEyesSad(canvas); break;
      case EyeExpression.thinking: _drawEyesThinking(canvas); break;
      case EyeExpression.listening: _drawEyesListening(canvas); break;
      case EyeExpression.dizzy: _drawEyesDizzy(canvas); break;
      case EyeExpression.lowEnergy: _drawEyesClosed(canvas, curve: 0.1); break;
    }
  }

  void _drawEyesDefault(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final eyeRadius = radius * 0.15;
    final eyeOffsetY = -radius * 0.18;
    final eyeOffsetX = radius * 0.35;
    final leftEyeCenter = center + Offset(-eyeOffsetX, eyeOffsetY);
    final rightEyeCenter = center + Offset(eyeOffsetX, eyeOffsetY);
    canvas.drawCircle(leftEyeCenter, eyeRadius, _pupilPaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, _pupilPaint);
    final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final sparkleRadius = eyeRadius * 0.3;
    final sparkleOffset = Offset(-eyeRadius * 0.4, -eyeRadius * 0.4);
    canvas.drawCircle(leftEyeCenter + sparkleOffset, sparkleRadius, sparklePaint);
    canvas.drawCircle(rightEyeCenter + sparkleOffset, sparkleRadius, sparklePaint);
  }

  void _drawEyesThinking(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final eyeRadius = radius * 0.15;
    final eyeOffsetY = -radius * 0.18;
    final eyeOffsetX = radius * 0.35;
    final pupilOffset = Offset(0.0, -4.0);
    _drawEye(canvas, center, -eyeOffsetX, eyeOffsetY, eyeRadius, pupilOffset: pupilOffset);
    _drawEye(canvas, center, eyeOffsetX, eyeOffsetY, eyeRadius, pupilOffset: pupilOffset);
  }

  void _drawEyesListening(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final eyeRadius = radius * 0.22;
    final eyeOffsetY = -radius * 0.2;
    final eyeOffsetX = radius * 0.35;
    final pupilOffsetX = sin(animationTime * 2.5) * 2.0;
    final pupilOffsetY = 3.0;
    _drawEye(canvas, center, -eyeOffsetX, eyeOffsetY, eyeRadius, pupilOffset: Offset(pupilOffsetX, pupilOffsetY));
    _drawEye(canvas, center, eyeOffsetX, eyeOffsetY, eyeRadius, pupilOffset: Offset(pupilOffsetX, pupilOffsetY));
  }

  void _drawEyesHappy(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final eyeOffsetY = -radius * 0.15;
    final eyeOffsetX = radius * 0.4;
    final path = Path();
    path.moveTo(center.dx - eyeOffsetX - radius * 0.2, center.dy + eyeOffsetY);
    path.quadraticBezierTo(center.dx - eyeOffsetX, center.dy + eyeOffsetY - radius * 0.3, center.dx - eyeOffsetX + radius * 0.2, center.dy + eyeOffsetY);
    path.moveTo(center.dx + eyeOffsetX - radius * 0.2, center.dy + eyeOffsetY);
    path.quadraticBezierTo(center.dx + eyeOffsetX, center.dy + eyeOffsetY - radius * 0.3, center.dx + eyeOffsetX + radius * 0.2, center.dy + eyeOffsetY);
    canvas.drawPath(path, _linePaint..strokeWidth = 4);
  }

  void _drawEyesClosed(Canvas canvas, {double curve = 0.5}) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final eyeRadius = radius * 0.19;
    final eyeOffsetY = -radius * 0.2;
    final eyeOffsetX = radius * 0.35;
    final eyeCenterLeft = Offset(center.dx - eyeOffsetX, center.dy + eyeOffsetY);
    final eyeCenterRight = Offset(center.dx + eyeOffsetX, center.dy + eyeOffsetY);
    final blinkPath = Path();
    blinkPath.moveTo(eyeCenterLeft.dx - eyeRadius * 0.8, eyeCenterLeft.dy);
    blinkPath.quadraticBezierTo(eyeCenterLeft.dx, eyeCenterLeft.dy + eyeRadius * curve, eyeCenterLeft.dx + eyeRadius * 0.8, eyeCenterLeft.dy);
    blinkPath.moveTo(eyeCenterRight.dx - eyeRadius * 0.8, eyeCenterRight.dy);
    blinkPath.quadraticBezierTo(eyeCenterRight.dx, eyeCenterRight.dy + eyeRadius * curve, eyeCenterRight.dx + eyeRadius * 0.8, eyeCenterRight.dy);
    canvas.drawPath(blinkPath, _linePaint..strokeWidth = 3);
  }

  void _drawEyesAngry(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final eyeOffsetY = -radius * 0.2;
    final eyeOffsetX = radius * 0.35;
    final path = Path();
    final eyeWidth = radius * 0.3;
    final eyeHeight = radius * 0.3;
    path.moveTo(center.dx - eyeOffsetX + eyeWidth, center.dy + eyeOffsetY - eyeHeight);
    path.lineTo(center.dx - eyeOffsetX - eyeWidth, center.dy + eyeOffsetY + eyeHeight);
    path.moveTo(center.dx + eyeOffsetX - eyeWidth, center.dy + eyeOffsetY - eyeHeight);
    path.lineTo(center.dx + eyeOffsetX + eyeWidth, center.dy + eyeOffsetY + eyeHeight);
    canvas.drawPath(path, _linePaint..strokeWidth = 5);
  }

  void _drawEyesSad(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    _drawEyesDefault(canvas);
    final eyeOffsetY = -radius * 0.18;
    final eyeOffsetX = radius * 0.35;
    final tearStartY = center.dy + eyeOffsetY + radius * 0.15;
    final tearDropLength = radius * 0.2 + (sin(animationTime*5)+1)/2 * 5;
    final tearPath = Path()
      ..moveTo(center.dx - eyeOffsetX, tearStartY)
      ..lineTo(center.dx - eyeOffsetX, tearStartY + tearDropLength)
      ..moveTo(center.dx + eyeOffsetX, tearStartY)
      ..lineTo(center.dx + eyeOffsetX, tearStartY + tearDropLength);
    canvas.drawPath(tearPath, _tearPaint..style=PaintingStyle.stroke..strokeWidth=4..strokeCap=StrokeCap.round);
  }

  void _drawEyesDizzy(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final eyeRadius = radius * 0.18;
    final eyeOffsetY = -radius * 0.2;
    final eyeOffsetX = radius * 0.35;
    canvas.save();
    canvas.translate(center.dx - eyeOffsetX, center.dy + eyeOffsetY);
    _drawSpiral(canvas, eyeRadius, dizzyRotationTime);
    canvas.restore();
    canvas.save();
    canvas.translate(center.dx + eyeOffsetX, center.dy + eyeOffsetY);
    _drawSpiral(canvas, eyeRadius, -dizzyRotationTime);
    canvas.restore();
  }

  void _drawSpiral(Canvas canvas, double radius, double startAngle) {
    final path = Path();
    final turns = 3;
    for (var i = 0; i < 360 * turns; i++) {
      final angle = (i * pi / 180) + startAngle;
      final r = radius * i / (360 * turns);
      final x = r * cos(angle);
      final y = r * sin(angle);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, _linePaint..strokeWidth = 2);
  }

  void _drawEye(Canvas canvas, Offset center, double offsetX, double offsetY, double radius, {required Offset pupilOffset, double pupilScale = 0.5}) {
    final eyeCenter = center + Offset(offsetX, offsetY);
    canvas.drawCircle(eyeCenter, radius, _eyeWhitePaint);
    final pupilCenter = eyeCenter + pupilOffset;
    canvas.drawCircle(pupilCenter, radius * pupilScale, _pupilPaint);
    final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(pupilCenter.dx - radius * 0.2, pupilCenter.dy - radius * 0.2), radius * 0.2, sparklePaint);
  }
}
