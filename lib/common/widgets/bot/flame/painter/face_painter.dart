import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/bot/cosmic_critter_widget.dart';

enum FaceShape { eyes, mouth, thirdEye }

class FacePainter extends CustomPainter {
  FaceShape shape;
  CritterState state;
  FacePainter({required this.shape, required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final mouthPaint = Paint()..color = const Color(0xFF006064).withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    final path = Path();
    final center = size.center(Offset.zero);

    if (shape == FaceShape.mouth) {
      switch(state) {
        case CritterState.happy: path.moveTo(center.dx - 25, center.dy); path.arcTo(Rect.fromCircle(center: Offset(center.dx, center.dy - 5), radius: 30), pi * 0.2, pi * 0.6, false); break;
        case CritterState.sadboi: case CritterState.lowenergy: path.moveTo(center.dx - 20, center.dy + 5); path.quadraticBezierTo(center.dx, center.dy, center.dx + 20, center.dy + 5); break;
        case CritterState.amazed: canvas.drawOval(Rect.fromCenter(center: center, width: 30, height: 35), mouthPaint..style=PaintingStyle.fill); return;
        default: path.moveTo(center.dx - 15, center.dy); path.quadraticBezierTo(center.dx, center.dy + 5, center.dx + 15, center.dy); break;
      }
      canvas.drawPath(path, mouthPaint);
    } else if (shape == FaceShape.eyes) {
      final eyeXOffset = 28.0;
      switch(state) {
        case CritterState.happy:
          final eyeRadius = 18.0;
          path.moveTo(center.dx - eyeXOffset - eyeRadius, center.dy + eyeRadius);
          path.arcToPoint(Offset(center.dx - eyeXOffset + eyeRadius, center.dy + eyeRadius), radius: Radius.circular(eyeRadius), clockwise: false);
          path.moveTo(center.dx + eyeXOffset - eyeRadius, center.dy + eyeRadius);
          path.arcToPoint(Offset(center.dx + eyeXOffset + eyeRadius, center.dy + eyeRadius), radius: Radius.circular(eyeRadius), clockwise: false);
          canvas.drawPath(path, mouthPaint..strokeWidth = 5);
          break;
        case CritterState.sleeping:
        case CritterState.thinking:
          final eyeRadius = 18.0;
          path.moveTo(center.dx - eyeXOffset - eyeRadius, center.dy);
          path.lineTo(center.dx - eyeXOffset + eyeRadius, center.dy);
          path.moveTo(center.dx + eyeXOffset - eyeRadius, center.dy);
          path.lineTo(center.dx + eyeXOffset + eyeRadius, center.dy);
          canvas.drawPath(path, mouthPaint);
          break;
        default:
        // SỬA LỖI: Vẽ mắt thành hai chấm tròn nhỏ, đặc và dễ thương.
          final eyeRadius = 6.0;
          final eyePaint = Paint()..color = const Color(0xFF004D40); // Màu xanh rêu đậm
          canvas.drawCircle(Offset(center.dx - eyeXOffset, center.dy), eyeRadius, eyePaint);
          canvas.drawCircle(Offset(center.dx + eyeXOffset, center.dy), eyeRadius, eyePaint);
      }
    } else if (shape == FaceShape.thirdEye) {
      final thirdEyeRadiusH = 12.0;
      if (state == CritterState.thinking) {
        path.moveTo(center.dx - thirdEyeRadiusH, center.dy); path.quadraticBezierTo(center.dx, center.dy - thirdEyeRadiusH * 1.5, center.dx + thirdEyeRadiusH, center.dy); path.quadraticBezierTo(center.dx, center.dy + thirdEyeRadiusH * 1.5, center.dx - thirdEyeRadiusH, center.dy);
        canvas.drawPath(path, Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0));
        canvas.drawCircle(center, thirdEyeRadiusH * 0.4, Paint()..color = Colors.white);
      } else {
        path.moveTo(center.dx - thirdEyeRadiusH, center.dy); path.lineTo(center.dx + thirdEyeRadiusH, center.dy);
        canvas.drawPath(path, mouthPaint..strokeWidth = 3);
      }
    }
  }
  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) => oldDelegate.state != state || oldDelegate.shape != shape;
}