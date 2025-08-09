import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class SleepingZComponent extends PositionComponent {
  @override
  Future<void> onLoad() async {
    // Timer để tạo chữ Z
    add(TimerComponent(
      period: 1.5,
      repeat: true,
      onTick: () {
        final z = TextComponent(
          text: 'Z',
          textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white.withValues(alpha: 0.7))),
          position: Vector2(60, -60),
        );
        // Hiệu ứng cho chữ Z: bay lên, mờ dần rồi biến mất
        z.add(MoveByEffect(Vector2(15, -30), EffectController(duration: 1.4)));
        z.add(OpacityEffect.fadeOut(EffectController(duration: 1.5), onComplete: () => z.removeFromParent()));
        add(z);
      },
    ));
  }
}