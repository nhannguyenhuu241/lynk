import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/utils/text_utils.dart';

//==============================================================================
// --- WIDGET LINH VẬT (COSMIC CRITTER) ---
//==============================================================================

/// Enum định nghĩa các trạng thái của Critter.
enum CritterState {
  /// Trạng thái bình thường thở mặc định
  idle,
  /// Trạng thái ngủ sẽ nhắm mắt 2 tay nằm 1 bên như bé đang nằm dựa vào và có chữ zzz như đang ngủ
  sleeping,
  /// Cảm xúc hạnh phúc tươi cười và 2 tay hoạt động phấn khởi
  happy,
  /// Bé nắm mắt 2 tay chập lại con mắt thứ 3 trên tráng mở ra suy nghĩ
  thinking,
  /// 2 tay từ trong thân thể hiện ra và chào mừng
  welcoming,
  /// Bé chuyển màu đỏ mắt miệng và tay thể hiện tức giận
  angry,
  /// Bé sẽ thể hiện ngạc nhiên
  amazed,
  /// Đeo mắt kính tay say hi
  trolling,
  /// Mặt xụ xuống buồn bã bé chuyển màu tái nhạt , mắt có nước mắt trên đầu có cục mây xám có tia điện sét
  sadboi,
  /// Trạng thái lắng nghe câu hỏi (khi người dùng đang gõ)
  listening,
  /// Cảm thấy sốc sợ hãi
  scared,
  /// Cảm thấy chóng mặt, đôi mắt là xoắn ốc xoay xoay miện chảy nước miếng
  dizzy,
  /// Ngáp ngủ giống mới thức dậy
  sleepy,
  /// Trạng thái màu xanh lá, mặt buồn hết sức sống
  lowenergy,
}


/// Một widget để hiển thị một "Sinh Vật" dễ thương, biểu cảm.
class CosmicCritterWidget extends StatefulWidget {
  final double size;
  final CritterState state;
  final VoidCallback? onTap;
  // Thêm ValueNotifier để nhận hướng nhìn
  final ValueNotifier<Offset?>? lookDirection;

  const CosmicCritterWidget({
    super.key,
    this.size = 150.0,
    this.state = CritterState.idle,
    this.onTap,
    this.lookDirection,
  });

  @override
  State<CosmicCritterWidget> createState() => _CosmicCritterWidgetState();
}

class _CosmicCritterWidgetState extends State<CosmicCritterWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: CustomPaint(
        size: Size(widget.size, widget.size * 1.2), // Tăng chiều cao để có không gian cho hiệu ứng
        painter: _CosmicCritterPainter(
          animation: _controller,
          state: widget.state,
          lookDirection: widget.lookDirection, // Truyền hướng nhìn vào painter
        ),
      ),
    );
  }
}

class _CosmicCritterPainter extends CustomPainter {
  final Animation<double> animation;
  final CritterState state;
  final ValueNotifier<Offset?>? lookDirection;

  _CosmicCritterPainter({
    required this.animation,
    required this.state,
    this.lookDirection,
  }) : super(repaint: Listenable.merge([animation, lookDirection]));


  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2.5;
    final animValue = animation.value;

    // Vẽ các hiệu ứng đặc biệt (như mây, zzz) trước
    _drawSpecialEffects(canvas, center, baseRadius, animValue);

    // Sau đó vẽ tay, thân và mặt
    _drawBody(canvas, center, baseRadius, animValue);
    _drawHands(canvas, center, baseRadius, animValue);
    _drawFaceFeatures(canvas, center, baseRadius, animValue);
  }

  Path _createBodyPath(Offset center, double radius, double time) {
    final path = Path();

    double verticalSquish = sin(time * 2 * pi) * radius * 0.05;
    double horizontalSquish = cos(time * 2 * pi) * radius * 0.05;

    // Hiệu ứng run rẩy khi sợ hãi
    if (state == CritterState.scared) {
      verticalSquish += sin(time * 2 * pi * 10) * 3;
      horizontalSquish += cos(time * 2 * pi * 10) * 3;
    }

    final rect = Rect.fromCenter(
        center: center,
        width: (radius + horizontalSquish) * 2,
        height: (radius - verticalSquish) * 2
    );

    path.addOval(rect);
    return path;
  }

  void _drawBody(Canvas canvas, Offset center, double radius, double animValue) {
    Color color1 = const Color(0xFF7EFAF2); // Base Color 1
    Color color2 = const Color(0xFFADE5FD); // Base Color 2

    switch(state) {
      case CritterState.angry:
        color1 = const Color(0xFFE57373); // Red
        color2 = const Color(0xFFF44336);
        break;
      case CritterState.sadboi:
        color1 = const Color(0xFFB0BEC5); // Pale Grey
        color2 = const Color(0xFF90A4AE);
        break;
      case CritterState.lowenergy:
        color1 = const Color(0xFFA5D6A7); // Light Green
        color2 = const Color(0xFF81C784); // Green
        break;
      default:
        break;
    }

    final path = _createBodyPath(center, radius, animValue);

    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [color1.withValues(alpha: 0.6), color2.withValues(alpha: 0.7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, bodyPaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));

    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3), radius: radius * 0.8));

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPaint(highlightPaint);
    canvas.restore();
  }

  void _drawHands(Canvas canvas, Offset center, double radius, double animValue) {
    if (state == CritterState.welcoming) return; // Tay được vẽ riêng trong trường hợp này

    Color color1 = const Color(0xFF80DEEA);
    Color color2 = const Color(0xFF4DD0E1);

    switch(state) {
      case CritterState.angry: color1 = const Color(0xFFE57373); color2 = const Color(0xFFF44336); break;
      case CritterState.sadboi: color1 = const Color(0xFFB0BEC5); color2 = const Color(0xFF90A4AE); break;
      case CritterState.lowenergy: color1 = const Color(0xFFA5D6A7); color2 = const Color(0xFF81C784); break;
      default: break;
    }

    final handPaint = Paint()
      ..shader = RadialGradient(
        colors: [color1.withValues(alpha: 0.7), color2.withValues(alpha: 0.8)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final handRadius = radius * 0.25;
    final bodySquishY = sin(animValue * 2 * pi) * radius * 0.05;
    final baseY = center.dy + radius * 0.2 - bodySquishY;
    final bodySquishX = cos(animValue * 2 * pi) * radius * 0.05;
    final baseXOffset = radius * 0.9 + bodySquishX;

    double leftHandYOffset = sin(animValue * 2 * pi * 1.1 + 0.5) * 6 + cos(animValue * 2 * pi * 2.5 + 1.0) * 4;
    double rightHandYOffset = cos(animValue * 2 * pi * 1.3 + 2.5) * 6 + sin(animValue * 2 * pi * 3.2 + 0.8) * 4;
    double leftHandXOffset = 0;
    double rightHandXOffset = 0;

    switch (state) {
      case CritterState.happy: leftHandYOffset -= 20; rightHandYOffset -= 20; break;
      case CritterState.sadboi:
      case CritterState.lowenergy:
        leftHandYOffset += 15; rightHandYOffset += 15; break;
      case CritterState.thinking:
        leftHandXOffset = baseXOffset * 0.6; rightHandXOffset = -baseXOffset * 0.6;
        leftHandYOffset = 10; rightHandYOffset = 10;
        break;
      case CritterState.angry: leftHandYOffset -= 5; rightHandYOffset -= 5; break;
      case CritterState.scared:
        leftHandXOffset = baseXOffset * 0.4; rightHandXOffset = -baseXOffset * 0.4;
        leftHandYOffset = -radius * 0.2; rightHandYOffset = -radius * 0.2;
        break;
      case CritterState.listening:
        leftHandXOffset = baseXOffset * 0.2; // Tay đưa về phía trước
        rightHandXOffset = -baseXOffset * 0.2;
        leftHandYOffset = -radius * 0.1; // Tay hơi nhấc lên
        rightHandYOffset = -radius * 0.1;
        break;
      case CritterState.sleepy:
        leftHandXOffset = baseXOffset * 0.5; leftHandYOffset = -radius * 0.4; // Tay dụi mắt
        break;
      case CritterState.sleeping:
        leftHandXOffset = baseXOffset * 0.2; rightHandXOffset = -baseXOffset * 0.1;
        leftHandYOffset = 0; rightHandYOffset = 5;
        break;
      case CritterState.trolling:
        leftHandYOffset -= 15; rightHandYOffset -=15; break; // Giơ tay say hi
      default: break;
    }

    final leftHandCenter = Offset(center.dx - baseXOffset + leftHandXOffset, baseY + leftHandYOffset);
    final rightHandCenter = Offset(center.dx + baseXOffset + rightHandXOffset, baseY + rightHandYOffset);

    canvas.drawCircle(leftHandCenter, handRadius, handPaint);
    canvas.drawCircle(rightHandCenter, handRadius, handPaint);
  }

  void _drawFaceFeatures(Canvas canvas, Offset center, double radius, double animValue) {
    final featurePaint = Paint()..color = const Color(0xFF006064).withValues(alpha: 0.6);
    final mouthPaint = Paint()
      ..color = const Color(0xFF006064).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke..strokeWidth = radius * 0.05..strokeCap = StrokeCap.round;

    final eyeRadius = radius * 0.12;
    final eyeY = center.dy + radius * 0.05;
    final eyeXOffset = radius * 0.35;

    // Tính toán độ lệch của con ngươi dựa trên hướng nhìn được truyền vào
    Offset pupilOffset = Offset.zero;
    if (lookDirection?.value != null) {
      final maxPupilOffset = eyeRadius * 0.6;
      // Ưu tiên nhìn xuống nhiều hơn
      final lookY = max(0.0, lookDirection!.value!.dy);
      pupilOffset = Offset(
        lookDirection!.value!.dx * maxPupilOffset * 0.5, // Giảm độ liếc ngang
        lookY * maxPupilOffset,
      );
    }

    // --- Vẽ mắt ---
    switch(state) {
      case CritterState.happy:
        final happyEyePath = Path();
        happyEyePath.moveTo(center.dx - eyeXOffset - eyeRadius, eyeY + eyeRadius);
        happyEyePath.arcToPoint(Offset(center.dx - eyeXOffset + eyeRadius, eyeY + eyeRadius), radius: Radius.circular(eyeRadius), clockwise: false);
        happyEyePath.moveTo(center.dx + eyeXOffset - eyeRadius, eyeY + eyeRadius);
        happyEyePath.arcToPoint(Offset(center.dx + eyeXOffset + eyeRadius, eyeY + eyeRadius), radius: Radius.circular(eyeRadius), clockwise: false);
        canvas.drawPath(happyEyePath, mouthPaint..strokeWidth = radius * 0.07);
        break;
      case CritterState.sleeping:
      case CritterState.thinking:
        final closedEyePath = Path();
        closedEyePath.moveTo(center.dx - eyeXOffset - eyeRadius, eyeY);
        closedEyePath.lineTo(center.dx - eyeXOffset + eyeRadius, eyeY);
        closedEyePath.moveTo(center.dx + eyeXOffset - eyeRadius, eyeY);
        closedEyePath.lineTo(center.dx + eyeXOffset + eyeRadius, eyeY);
        canvas.drawPath(closedEyePath, mouthPaint);
        break;
      case CritterState.angry:
        final angryEyePath = Path();
        angryEyePath.moveTo(center.dx - eyeXOffset - eyeRadius, eyeY - eyeRadius * 0.5);
        angryEyePath.lineTo(center.dx - eyeXOffset + eyeRadius, eyeY + eyeRadius * 0.5);
        angryEyePath.moveTo(center.dx + eyeXOffset - eyeRadius, eyeY + eyeRadius * 0.5);
        angryEyePath.lineTo(center.dx + eyeXOffset + eyeRadius, eyeY - eyeRadius * 0.5);
        canvas.drawPath(angryEyePath, mouthPaint..strokeWidth = radius * 0.08);
        break;
      case CritterState.amazed:
      case CritterState.scared:
        final bigEyeRadius = (state == CritterState.scared) ? eyeRadius * 1.1 : eyeRadius * 1.2;
        final pupilRadius = (state == CritterState.scared) ? eyeRadius * 0.3 : eyeRadius * 0.5;
        canvas.drawCircle(Offset(center.dx - eyeXOffset, eyeY), bigEyeRadius, featurePaint);
        canvas.drawCircle(Offset(center.dx + eyeXOffset, eyeY), bigEyeRadius, featurePaint);
        canvas.drawCircle(Offset(center.dx - eyeXOffset, eyeY), pupilRadius, Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9));
        canvas.drawCircle(Offset(center.dx + eyeXOffset, eyeY), pupilRadius, Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9));
        break;
      case CritterState.dizzy:
        final swirlPaint = mouthPaint..style=PaintingStyle.stroke;
        for(var i = 0; i < 2; i++) {
          final eCenter = Offset(center.dx + (i == 0 ? -eyeXOffset : eyeXOffset), eyeY);
          canvas.save();
          canvas.translate(eCenter.dx, eCenter.dy);
          canvas.rotate(animValue * 4 * pi);
          canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: eyeRadius), 0, pi * 1.5, false, swirlPaint);
          canvas.restore();
        }
        break;
      case CritterState.sleepy:
      case CritterState.lowenergy:
        final sleepyEyePath = Path();
        sleepyEyePath.moveTo(center.dx - eyeXOffset - eyeRadius, eyeY + eyeRadius * 0.5);
        sleepyEyePath.arcToPoint(Offset(center.dx - eyeXOffset + eyeRadius, eyeY + eyeRadius * 0.5), radius: Radius.circular(eyeRadius), clockwise: false);
        sleepyEyePath.moveTo(center.dx + eyeXOffset - eyeRadius, eyeY + eyeRadius * 0.5);
        sleepyEyePath.arcToPoint(Offset(center.dx + eyeXOffset + eyeRadius, eyeY + eyeRadius * 0.5), radius: Radius.circular(eyeRadius), clockwise: false);
        canvas.drawPath(sleepyEyePath, mouthPaint..strokeWidth = radius * 0.07);
        break;
      case CritterState.trolling:
      // Vẽ kính
        final glassesPaint = Paint()..color = Colors.black;
        final glassesRect = Rect.fromCenter(center: Offset(center.dx, eyeY), width: eyeXOffset * 2 + eyeRadius * 2.5, height: eyeRadius * 2);
        canvas.drawRRect(RRect.fromRectAndRadius(glassesRect, Radius.circular(eyeRadius * 0.5)), glassesPaint);
        break;
      default: // idle, welcoming, listening
        final leftEyeCenter = Offset(center.dx - eyeXOffset, eyeY);
        canvas.drawCircle(leftEyeCenter, eyeRadius, featurePaint);
        _drawSparkles(canvas, leftEyeCenter + pupilOffset, eyeRadius, animValue);

        final rightEyeCenter = Offset(center.dx + eyeXOffset, eyeY);
        canvas.drawCircle(rightEyeCenter, eyeRadius, featurePaint);
        _drawSparkles(canvas, rightEyeCenter + pupilOffset, eyeRadius, animValue);
        break;
    }

    // --- Vẽ con mắt thứ ba ---
    if (state != CritterState.trolling) {
      final thirdEyeY = center.dy - radius * 0.5;
      final thirdEyeRadiusH = radius * 0.15;
      double thirdEyeOpen = (state == CritterState.thinking) ? 1.0 : 0.0;
      if (thirdEyeOpen > 0.1) {
        final thirdEyePath = Path();
        thirdEyePath.moveTo(center.dx - thirdEyeRadiusH, thirdEyeY);
        thirdEyePath.quadraticBezierTo(center.dx, thirdEyeY - thirdEyeRadiusH * 1.5 * thirdEyeOpen, center.dx + thirdEyeRadiusH, thirdEyeY);
        thirdEyePath.quadraticBezierTo(center.dx, thirdEyeY + thirdEyeRadiusH * 1.5 * thirdEyeOpen, center.dx - thirdEyeRadiusH, thirdEyeY);
        final glowPaint = Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.8)..maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 * thirdEyeOpen);
        canvas.drawPath(thirdEyePath, glowPaint);
        canvas.drawCircle(Offset(center.dx, thirdEyeY), thirdEyeRadiusH * 0.4 * thirdEyeOpen, Paint()..color = Colors.white);
      } else {
        final closedEyePath = Path();
        closedEyePath.moveTo(center.dx - thirdEyeRadiusH, thirdEyeY);
        closedEyePath.quadraticBezierTo(
          center.dx,
          thirdEyeY + thirdEyeRadiusH * 0.4, // Độ cong của mí mắt
          center.dx + thirdEyeRadiusH,
          thirdEyeY,
        );
        canvas.drawPath(closedEyePath, mouthPaint..strokeWidth = radius * 0.04);
      }
    }

    // --- Vẽ miệng ---
    final mouthY = center.dy + radius * 0.4;
    final mouthPath = Path();
    switch(state) {
      case CritterState.happy:
        mouthPath.moveTo(center.dx - radius * 0.3, mouthY);
        mouthPath.arcTo(Rect.fromCircle(center: Offset(center.dx, mouthY - radius * 0.1), radius: radius * 0.35), pi * 0.2, pi * 0.6, false);
        break;
      case CritterState.sadboi:
      case CritterState.lowenergy:
        mouthPath.moveTo(center.dx - radius * 0.25, mouthY + radius * 0.1);
        mouthPath.quadraticBezierTo(center.dx, mouthY, center.dx + radius * 0.25, mouthY + radius * 0.1);
        break;
      case CritterState.angry:
        mouthPath.moveTo(center.dx - radius * 0.3, mouthY + radius * 0.05);
        mouthPath.lineTo(center.dx + radius * 0.3, mouthY - radius * 0.05);
        break;
      case CritterState.amazed:
        canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, mouthY + radius * 0.1), width: radius * 0.4, height: radius * 0.5), featurePaint);
        break;
      case CritterState.dizzy:
        mouthPath.moveTo(center.dx - radius * 0.2, mouthY);
        mouthPath.quadraticBezierTo(center.dx, mouthY + radius * 0.15, center.dx + radius * 0.2, mouthY);
        // Nước miếng
        canvas.drawLine(Offset(center.dx - radius * 0.15, mouthY + radius * 0.02), Offset(center.dx - radius * 0.2, mouthY + radius * 0.2), mouthPaint);
        break;
      case CritterState.sleepy:
        canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, mouthY + radius * 0.1), width: radius * 0.5, height: radius * 0.6 * (0.5 + (sin(animValue * 2 * pi) + 1)/4)), featurePaint);
        break;
      case CritterState.listening:
        mouthPath.moveTo(center.dx - radius * 0.15, mouthY);
        mouthPath.quadraticBezierTo(center.dx, mouthY + radius * 0.15, center.dx + radius * 0.15, mouthY);
        break;
      default:
        mouthPath.moveTo(center.dx - radius * 0.2, mouthY);
        mouthPath.quadraticBezierTo(center.dx, mouthY + radius * 0.05, center.dx + radius * 0.2, mouthY);
        break;
    }
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawSparkles(Canvas canvas, Offset eyeCenter, double eyeRadius, double animValue) {
    canvas.drawCircle(Offset(eyeCenter.dx + eyeRadius * 0.3, eyeCenter.dy - eyeRadius * 0.3), eyeRadius * 0.35, Paint()..color = Colors.white.withValues(alpha: 0.9));
    final sparkleOpacity = (sin(animValue * 2 * pi * 2.5 + eyeCenter.dx) + 1) / 2;
    canvas.drawCircle(Offset(eyeCenter.dx - eyeRadius * 0.4, eyeCenter.dy + eyeRadius * 0.2), eyeRadius * 0.15, Paint()..color = Colors.white.withValues(alpha: sparkleOpacity * 0.8));
  }

  void _drawSpecialEffects(Canvas canvas, Offset center, double radius, double animValue) {
    switch(state) {
      case CritterState.sleeping:
        final textStyle = TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: radius * 0.3, fontWeight: FontWeight.bold);
        for (int i = 0; i < 3; i++) {
          final progress = (animValue * 1.5 + i * 0.33) % 1.0;
          final yPos = center.dy - radius * 0.8 - (progress * 40);
          final xPos = center.dx + radius * 0.8 + sin(progress * pi) * 10;
          final opacity = (1 - progress);
          final effectiveStyle = textStyle.copyWith(color: textStyle.color?.withValues(alpha: opacity));
          final textPainter = TextUtils.createSafeTextPainter(
            text: 'Z',
            style: effectiveStyle,
            textAlign: TextAlign.center,
          );
          textPainter.paint(canvas, Offset(xPos, yPos));
        }
        break;
      case CritterState.sadboi:
      // Vẽ mây
        final cloudCenter = Offset(center.dx, center.dy - radius * 1.2);
        final cloudPaint = Paint()..color = Colors.grey.shade700;
        canvas.drawCircle(cloudCenter, radius * 0.3, cloudPaint);
        canvas.drawCircle(Offset(cloudCenter.dx - radius * 0.25, cloudCenter.dy + radius * 0.1), radius * 0.25, cloudPaint);
        canvas.drawCircle(Offset(cloudCenter.dx + radius * 0.25, cloudCenter.dy + radius * 0.1), radius * 0.25, cloudPaint);
        // Vẽ sét
        if ((animValue * 10).floor() % 2 == 0) {
          final lightningPaint = Paint()..color=Colors.yellow.shade300..style=PaintingStyle.stroke..strokeWidth=3;
          final lightningPath = Path();
          final start = Offset(cloudCenter.dx, cloudCenter.dy + radius * 0.2);
          lightningPath.moveTo(start.dx, start.dy);
          lightningPath.lineTo(start.dx - 5, start.dy + 10);
          lightningPath.lineTo(start.dx + 5, start.dy + 12);
          lightningPath.lineTo(start.dx, start.dy + 22);
          canvas.drawPath(lightningPath, lightningPaint);
        }
        // Vẽ nước mắt
        final tearProgress = (animValue * 2.0) % 1.0;
        final tearY = center.dy + radius * 0.15;
        final tearX = center.dx - radius * 0.35;
        canvas.drawCircle(Offset(tearX, tearY + 30 * tearProgress), 3 * (1-tearProgress), Paint()..color=Colors.blue.withValues(alpha: 1-tearProgress));
        break;
      case CritterState.welcoming:
        final handRadius = radius * 0.25;
        final handPaint = Paint()..color = const Color(0xFF80DEEA).withValues(alpha: 0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        // Tay hiện ra từ thân
        final emergeProgress = min(1.0, (animation.value * 10) % 1.5);
        canvas.drawCircle(Offset(center.dx - radius * 0.5 * emergeProgress, center.dy + radius * 0.2), handRadius, handPaint);
        canvas.drawCircle(Offset(center.dx + radius * 0.5 * emergeProgress, center.dy + radius * 0.2), handRadius, handPaint);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicCritterPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.state != state || oldDelegate.lookDirection != lookDirection;
  }
}