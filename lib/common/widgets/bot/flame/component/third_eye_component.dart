import 'package:flame/components.dart';
import 'package:lynk_an/common/widgets/bot/cosmic_critter_widget.dart';

import '../painter/face_painter.dart';

class ThirdEyeComponent extends PositionComponent {
  late final CustomPainterComponent painter;

  ThirdEyeComponent() : super(position: Vector2(0, -40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    painter = CustomPainterComponent(
      painter: FacePainter(shape: FaceShape.thirdEye, state: CritterState.idle),
      anchor: Anchor.center,
    );
    add(painter);
  }

  void updateState(CritterState state) {
    (painter.painter as FacePainter).state = state;
  }
}