import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

class BodyComponent extends CircleComponent {
  BodyComponent() : super(radius: 75, anchor: Anchor.center);

  // Lưu trữ màu hiện tại và màu mặc định
  final Color defaultColor1 = const Color(0xFF7EFAF2);
  final Color defaultColor2 = const Color(0xFFADE5FD);
  late Color color1;
  late Color color2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    color1 = defaultColor1;
    color2 = defaultColor2;
    _updatePaint();
  }

  void _updatePaint() {
    paint = Paint()
      ..shader = RadialGradient(
        colors: [color1, color2],
      ).createShader(toRect());
  }

  void setColors(Color c1, Color c2) {
    color1 = c1;
    color2 = c2;
    _updatePaint();
  }
}