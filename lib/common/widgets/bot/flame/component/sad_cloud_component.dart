import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'lightning_component.dart';

class SadCloudComponent extends PositionComponent {
  SadCloudComponent() : super(position: Vector2(0, -100), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final cloudPaint = Paint()..color = Colors.grey.shade700;
    add(CircleComponent(radius: 20, paint: cloudPaint, position: Vector2(0, 0), anchor: Anchor.center));
    add(CircleComponent(radius: 15, paint: cloudPaint, position: Vector2(-18, 5), anchor: Anchor.center));
    add(CircleComponent(radius: 15, paint: cloudPaint, position: Vector2(18, 5), anchor: Anchor.center));

    // Timer để tạo sét
    add(TimerComponent(
      period: 2.0,
      repeat: true,
      onTick: () {
        if (Random().nextBool()) {
          add(LightningComponent());
        }
      },
    ));
  }
}