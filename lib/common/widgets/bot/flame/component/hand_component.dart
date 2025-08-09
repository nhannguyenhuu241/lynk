import 'dart:ui';

import 'package:flame/components.dart';

class HandComponent extends CircleComponent {
  HandComponent() : super(radius: 18); // Bán kính nhỏ hơn

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = const Color(0xFF80DEEA).withValues(alpha: 0.8);
  }
}
