import 'dart:math';

import 'package:flame/components.dart';

class Raindrop {
  Vector2 position;
  double length;
  double speed;
  Vector2 gameBounds;

  Raindrop({required this.position, required this.length, required this.speed, required this.gameBounds});

  void update(double dt) {
    position.y += speed * dt;
    if (position.y > gameBounds.y) {
      position.y = -length;
      position.x = Random().nextDouble() * gameBounds.x;
    }
  }
}