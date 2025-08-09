import 'dart:ui';

import 'package:flame/components.dart';

class Cloud {
  Vector2 position;
  double size;
  double speed;
  Vector2 gameBounds;
  List<Rect> parts = [];

  Cloud({required this.position, required this.size, required this.speed, required this.gameBounds}) {
    _createParts();
  }

  void _createParts() {
    parts.add(Rect.fromCircle(center: Offset(0, 0), radius: size / 2));
    parts.add(Rect.fromCircle(center: Offset(-size/2.5, size/6), radius: size / 3));
    parts.add(Rect.fromCircle(center: Offset(size/2.5, size/8), radius: size / 2.8));
  }

  void update(double dt) {
    position.x += speed * dt;
    if (position.x - size > gameBounds.x) {
      position.x = -size;
    }
  }

  void render(Canvas canvas, Paint paint) {
    canvas.save();
    canvas.translate(position.x, position.y);
    for (var rect in parts) {
      canvas.drawOval(rect, paint);
    }
    canvas.restore();
  }
}