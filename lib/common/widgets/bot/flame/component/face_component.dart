import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/widgets/bot/cosmic_critter_widget.dart';
import 'package:lynk_an/common/widgets/bot/flame/component/third_eye_component.dart';

import '../painter/face_painter.dart';


class FaceComponent extends PositionComponent {
  late final CustomPainterComponent eyes, mouth;
  late final ThirdEyeComponent thirdEye;
  // Thêm components má hồng
  late final CircleComponent leftBlush, rightBlush;

  FaceComponent() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    eyes = CustomPainterComponent(painter: FacePainter(shape: FaceShape.eyes, state: CritterState.idle), position: Vector2(0, 5), anchor: Anchor.center);
    mouth = CustomPainterComponent(painter: FacePainter(shape: FaceShape.mouth, state: CritterState.idle), position: Vector2(0, 45), anchor: Anchor.center);
    thirdEye = ThirdEyeComponent();

    // Khởi tạo má hồng
    final blushPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.pink.withValues(alpha: 0.4), Colors.pink.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 15));

    leftBlush = CircleComponent(radius: 15, paint: blushPaint, position: Vector2(-40, 20), anchor: Anchor.center);
    rightBlush = CircleComponent(radius: 15, paint: blushPaint, position: Vector2(40, 20), anchor: Anchor.center);

    await addAll([eyes, mouth, thirdEye, leftBlush, rightBlush]);
  }

  void updateLook(CritterState state) {
    (eyes.painter as FacePainter).state = state;
    (mouth.painter as FacePainter).state = state;
    thirdEye.updateState(state);

    // Điều khiển hiển thị má hồng
    final blushOpacity = (state == CritterState.happy || state == CritterState.welcoming) ? 0.7 : 0.0;
    leftBlush.add(OpacityEffect.to(blushOpacity, EffectController(duration: 0.3)));
    rightBlush.add(OpacityEffect.to(blushOpacity, EffectController(duration: 0.3)));
  }
}
