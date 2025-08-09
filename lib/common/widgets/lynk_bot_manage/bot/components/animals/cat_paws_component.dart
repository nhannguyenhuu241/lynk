import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Component chịu trách nhiệm vẽ tay mèo cute cho Lynk.
class CatPawsComponent extends PositionComponent {
  late Paint _pawPaint;
  late Paint _padPaint;
  late Paint _clawPaint;

  double animationTime = 0.0;
  bool isWaving = false;
  bool isKneading = false; // Động tác "nhào bột" của mèo
  double pawRotation = 0.0;

  CatPawsComponent({required Vector2 size}) {
    this.size = size;
    anchor = Anchor.topLeft;
    _initPaints();
  }

  void _initPaints() {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;

    // Paint cho phần chính của bàn chân mèo
    _pawPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          const Color(0xFFFFC0CB).withValues(alpha: 0.9), // Hồng pastel
          const Color(0xFFFFB6C1).withValues(alpha: 0.7),
        ],
        [0.3, 1.0],
      );

    // Paint cho miếng đệm chân (paw pads)
    _padPaint = Paint()
      ..color = const Color(0xFFFF69B4).withValues(alpha: 0.8);

    // Paint cho móng vuốt
    _clawPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
  }

  @override
  void render(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;

    // Vẽ tay trái
    canvas.save();
    canvas.translate(center.dx - radius * 1.2, center.dy + radius * 0.3);
    if (isWaving) {
      canvas.rotate(sin(animationTime * 3) * 0.3);
    }
    _drawCatPaw(canvas, radius * 0.25, isLeft: true);
    canvas.restore();

    // Vẽ tay phải
    canvas.save();
    canvas.translate(center.dx + radius * 1.2, center.dy + radius * 0.3);
    if (isKneading) {
      canvas.rotate(cos(animationTime * 2) * 0.2);
    }
    _drawCatPaw(canvas, radius * 0.25, isLeft: false);
    canvas.restore();
  }

  void _drawCatPaw(Canvas canvas, double pawRadius, {required bool isLeft}) {
    // Vẽ phần cổ tay (hình oval)
    final wristRect = Rect.fromCenter(
      center: Offset(0, -pawRadius * 0.3),
      width: pawRadius * 1.2,
      height: pawRadius * 1.8,
    );
    canvas.drawOval(wristRect, _pawPaint);

    // Vẽ bàn chân chính (hình tròn mở rộng)
    final pawPath = Path();
    pawPath.addOval(Rect.fromCircle(center: Offset.zero, radius: pawRadius));

    // Thêm các ngón chân (4 ngón nhỏ)
    for (int i = 0; i < 4; i++) {
      final angle = (i - 1.5) * 0.3 - (isLeft ? 0.2 : -0.2);
      final toeCenter = Offset(
        sin(angle) * pawRadius * 0.8,
        -cos(angle) * pawRadius * 0.8,
      );
      pawPath.addOval(Rect.fromCircle(
        center: toeCenter,
        radius: pawRadius * 0.28,
      ));

      // Vẽ móng vuốt nhỏ
      if (!isKneading || i % 2 == 0) {
        _drawClaw(canvas, toeCenter, angle, pawRadius * 0.15);
      }
    }

    canvas.drawPath(pawPath, _pawPaint);

    // Vẽ miếng đệm chân chính
    final mainPadPath = Path();
    mainPadPath.moveTo(0, pawRadius * 0.2);
    mainPadPath.quadraticBezierTo(
      -pawRadius * 0.3, -pawRadius * 0.1,
      0, -pawRadius * 0.3,
    );
    mainPadPath.quadraticBezierTo(
      pawRadius * 0.3, -pawRadius * 0.1,
      0, pawRadius * 0.2,
    );
    canvas.drawPath(mainPadPath, _padPaint);

    // Vẽ các miếng đệm ngón chân
    for (int i = 0; i < 4; i++) {
      final angle = (i - 1.5) * 0.3 - (isLeft ? 0.2 : -0.2);
      final padCenter = Offset(
        sin(angle) * pawRadius * 0.7,
        -cos(angle) * pawRadius * 0.7,
      );
      canvas.drawCircle(padCenter, pawRadius * 0.12, _padPaint);
    }

    // Thêm highlight cho hiệu ứng 3D
    final highlightPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(-pawRadius * 0.2, -pawRadius * 0.2),
        pawRadius * 0.5,
        [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(
      Offset(-pawRadius * 0.2, -pawRadius * 0.2),
      pawRadius * 0.4,
      highlightPaint,
    );
  }

  void _drawClaw(Canvas canvas, Offset position, double angle, double length) {
    final clawPath = Path();
    final startPoint = position + Offset(
      sin(angle) * length * 0.5,
      -cos(angle) * length * 0.5,
    );
    final endPoint = position + Offset(
      sin(angle) * length,
      -cos(angle) * length,
    );

    clawPath.moveTo(startPoint.dx, startPoint.dy);
    clawPath.quadraticBezierTo(
      position.dx + sin(angle) * length * 0.7,
      position.dy - cos(angle) * length * 0.7,
      endPoint.dx,
      endPoint.dy,
    );

    canvas.drawPath(clawPath, _clawPaint);
  }

  /// Bắt đầu animation vẫy tay
  void startWaving() {
    isWaving = true;
    isKneading = false;
  }

  /// Bắt đầu animation nhào bột
  void startKneading() {
    isKneading = true;
    isWaving = false;
  }

  /// Dừng mọi animation
  void stopAnimations() {
    isWaving = false;
    isKneading = false;
  }
}