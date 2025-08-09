import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../painter/lightning_painter.dart';

class LightningComponent extends CustomPainterComponent {
  LightningComponent() : super(anchor: Anchor.topCenter, position: Vector2(0, 15));

  @override
  Future<void> onLoad() async {
    painter = LightningPainter();
    // Thêm hiệu ứng tự hủy sau 0.2 giây
    add(RemoveEffect(delay: 0.2));
  }
}