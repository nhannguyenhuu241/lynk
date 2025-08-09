import 'dart:math';

import 'package:flame/components.dart';

class Snowflake {
  Vector2 position;
  double radius;
  double speed;
  double drift;
  double driftSpeed;
  Vector2 gameBounds;

  Snowflake({required this.position, required this.radius, required this.speed, required this.drift, required this.driftSpeed, required this.gameBounds});

  void update(double dt) {
    position.y += speed * dt;
    position.x += sin(position.y / drift) * driftSpeed * dt;

    if (position.y > gameBounds.y) {
      position.y = -radius;
      position.x = Random().nextDouble() * gameBounds.x;
    }
  }
}