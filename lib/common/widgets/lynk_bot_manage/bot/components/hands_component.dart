import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/avatar_expressions.dart';
import 'dart:ui' as ui;

/// Component chịu trách nhiệm vẽ tay của Lynk.
class HandsComponent extends PositionComponent {
  HandPose pose = HandPose.normal;
  Paint bodyPaint = Paint();

  double handOffsetY = 0.0;
  double animationTime = 0.0;

  HandsComponent({required Vector2 size}) {
    this.size = size;
    anchor = Anchor.topLeft;
    updateColor();
  }

  @override
  void render(Canvas canvas) {
    switch (pose) {
      case HandPose.listening: _drawHandsListening(canvas); break;
      case HandPose.thinking: _drawHandOnChin(canvas); break;
      case HandPose.angry: _drawHandsAngry(canvas); break;
      case HandPose.lowEnergy: _drawHandsDefault(canvas, handOffsetY: 15); break;
      case HandPose.sleeping: _drawHandsSleeping(canvas); break;
      case HandPose.trolling: _drawHandsTrolling(canvas); break;
      case HandPose.holdingFlag: _drawHandsHoldingFlag(canvas); break;
      default: _drawHandsDefault(canvas); break;
    }
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

  void _drawHandsDefault(Canvas canvas, {double? handOffsetY}) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final handRadius = radius * 0.18;
    final yOffset = handOffsetY ?? this.handOffsetY;
    canvas.drawCircle(Offset(center.dx - radius * 1.2, center.dy + radius * 0.3 + yOffset), handRadius, bodyPaint);
    canvas.drawCircle(Offset(center.dx + radius * 1.2, center.dy + radius * 0.3 + yOffset), handRadius, bodyPaint);
  }

  void _drawHandsListening(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final handRadius = radius * 0.18;
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy + radius * 0.5), handRadius, bodyPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.3, center.dy + radius * 0.5), handRadius, bodyPaint);
  }

  void _drawHandOnChin(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final handRadius = radius * 0.18;
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.6), handRadius, bodyPaint);
    canvas.drawCircle(Offset(center.dx + radius * 1.2, center.dy + radius * 0.4), handRadius, bodyPaint);
  }

  void _drawHandsAngry(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final handRadius = radius * 0.2;
    canvas.drawCircle(Offset(center.dx - radius * 1.2, center.dy + radius * 0.3), handRadius, bodyPaint);
    canvas.drawCircle(Offset(center.dx + radius * 1.2, center.dy + radius * 0.3), handRadius, bodyPaint);
  }

  void _drawHandsSleeping(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final handRadius = radius * 0.18;
    canvas.drawCircle(Offset(center.dx - radius * 0.8, center.dy + radius * 0.4), handRadius, bodyPaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.5, center.dy + radius * 0.5), handRadius, bodyPaint);
  }

  void _drawHandsTrolling(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final handRadius = radius * 0.18;
    canvas.drawCircle(Offset(center.dx - radius * 1.2, center.dy + radius * 0.3), handRadius, bodyPaint);
    canvas.save();
    canvas.translate(center.dx + radius * 1.2, center.dy + radius * 0.1 + sin(animationTime * 5) * 5);
    canvas.rotate(0.2);
    canvas.drawCircle(Offset.zero, handRadius, bodyPaint);
    canvas.restore();
  }

  void _drawHandsHoldingFlag(Canvas canvas) {
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final handRadius = radius * 0.18;
    
    // Tay trái bình thường
    canvas.drawCircle(Offset(center.dx - radius * 1.2, center.dy + radius * 0.3 + handOffsetY), handRadius, bodyPaint);
    
    // Tay phải giơ lên để cầm cờ - vẽ rõ ràng hơn
    canvas.drawCircle(Offset(center.dx + radius * 0.9, center.dy - radius * 0.1 + handOffsetY), handRadius, bodyPaint);
  }
}
