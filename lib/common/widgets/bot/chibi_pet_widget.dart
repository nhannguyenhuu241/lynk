import 'dart:math';
import 'package:flutter/material.dart';

/// Enum định nghĩa các trạng thái của Pet.
enum PetState {
  /// Trạng thái bình thường.
  idle,
  /// Trạng thái vui vẻ.
  happy,
  /// Trạng thái buồn bã.
  sad,
  /// Trạng thái tức giận.
  angry,
  /// Trạng thái buồn ngủ.
  sleepy,
  /// Trạng thái tò mò, nghiêng qua một bên.
  curious,
  /// Trạng thái phấn khích.
  excited,
  /// Trạng thái "cợt nhã", nháy mắt.
  winking,
}

/// Một widget để hiển thị một Pet Chibi dễ thương.
///
/// Widget này sẽ tự quản lý animation của mình, tạo ra hiệu ứng
/// nảy và biểu cảm sống động.
class ChibiPetWidget extends StatefulWidget {
  final double size;
  final PetState state;
  final VoidCallback? onTap;

  const ChibiPetWidget({
    super.key,
    this.size = 100.0,
    this.state = PetState.idle,
    this.onTap,
  });

  @override
  State<ChibiPetWidget> createState() => _ChibiPetWidgetState();
}

class _ChibiPetWidgetState extends State<ChibiPetWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
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
        size: Size(widget.size, widget.size),
        painter: _ChibiPetPainter(
          animation: _controller,
          state: widget.state,
        ),
      ),
    );
  }
}

class _ChibiPetPainter extends CustomPainter {
  final Animation<double> animation;
  final PetState state;

  _ChibiPetPainter({
    required this.animation,
    required this.state,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2.2;
    final animValue = animation.value;

    _drawBody(canvas, center, baseRadius, animValue);
    _drawFaceFeatures(canvas, center, baseRadius, animValue);
  }

  Path _createBodyPath(Canvas canvas, Offset center, double radius, double time) {
    final path = Path();
    final anglePoints = 12; // Tăng số điểm để đường cong mượt hơn

    // Animation cho hiệu ứng nảy và đàn hồi (squishy)
    final verticalSquish = sin(time * 2 * pi) * radius * 0.05;
    final horizontalSquish = cos(time * 2 * pi) * radius * 0.05;

    // Animation cho trạng thái tò mò
    double curiousTilt = 0;
    if (state == PetState.curious) {
      curiousTilt = sin(time * 2 * pi) * (pi / 12); // Nghiêng qua lại
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(curiousTilt);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i <= anglePoints; i++) {
      final angle = (i / anglePoints) * 2 * pi;

      final rX = radius + horizontalSquish;
      final rY = radius - verticalSquish;

      double x = center.dx + cos(angle) * rX;
      double y = center.dy + sin(angle) * rY;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Phục hồi canvas sau khi xoay
    canvas.restore();
    return path;
  }

  void _drawBody(Canvas canvas, Offset center, double radius, double animValue) {
    // --- Định nghĩa màu sắc và Paint ---
    Color bodyColor = const Color(0xFF4DD0E1); // Cyan
    Color outlineColor = const Color(0xFF00838F); // Dark Cyan
    Color shadowColor = const Color(0x33006064); // Darker Cyan with opacity

    // --- Thay đổi màu sắc theo trạng thái ---
    switch (state) {
      case PetState.happy:
      case PetState.excited:
      case PetState.winking:
        bodyColor = const Color(0xFFFFD54F); // Yellow
        outlineColor = const Color(0xFFF57F17); // Dark Yellow/Orange
        shadowColor = const Color(0x33BF360C);
        break;
      case PetState.sad:
        bodyColor = const Color(0xFF90A4AE); // Blue Grey
        outlineColor = const Color(0xFF455A64); // Dark Blue Grey
        shadowColor = const Color(0x33263238);
        break;
      case PetState.angry:
        bodyColor = const Color(0xFFE57373); // Light Red
        outlineColor = const Color(0xFFC62828); // Dark Red
        shadowColor = const Color(0x33B71C1C);
        break;
      default:
        break;
    }

    final bodyPaint = Paint()..color = bodyColor;
    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // --- Vẽ thân ---
    final path = _createBodyPath(canvas,center, radius, animValue);

    // Vẽ bóng đổ bên trong để tạo chiều sâu
    canvas.save();
    canvas.translate(0, radius * 0.1);
    final shadowPaint = Paint()..color = shadowColor;
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Vẽ thân chính
    canvas.drawPath(path, bodyPaint);

    // Vẽ viền
    canvas.drawPath(path, outlinePaint);
  }

  void _drawFaceFeatures(Canvas canvas, Offset center, double radius, double animValue) {
    final eyePaint = Paint()..color = const Color(0xFF3A2E2E);
    final mouthPaint = Paint()
      ..color = const Color(0xFF3A2E2E).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..strokeCap = StrokeCap.round;

    final eyeRadius = radius * 0.12;
    final eyeY = center.dy - radius * 0.15;
    final eyeXOffset = radius * 0.35;

    // Animation nháy mắt
    final blink = pow(sin(animValue * 2 * pi * 0.5 + 1.5), 20).toDouble();

    // Vẽ mắt
    if (state == PetState.sleepy) {
      final sleepyEyePath = Path();
      sleepyEyePath.moveTo(center.dx - eyeXOffset - eyeRadius, eyeY);
      sleepyEyePath.arcToPoint(Offset(center.dx - eyeXOffset + eyeRadius, eyeY), radius: Radius.circular(eyeRadius));
      sleepyEyePath.moveTo(center.dx + eyeXOffset - eyeRadius, eyeY);
      sleepyEyePath.arcToPoint(Offset(center.dx + eyeXOffset + eyeRadius, eyeY), radius: Radius.circular(eyeRadius));
      canvas.drawPath(sleepyEyePath, mouthPaint);
    } else if (state == PetState.happy || state == PetState.excited) {
      final happyEyePath = Path();
      happyEyePath.moveTo(center.dx - eyeXOffset - eyeRadius, eyeY + eyeRadius);
      happyEyePath.arcToPoint(Offset(center.dx - eyeXOffset + eyeRadius, eyeY + eyeRadius), radius: Radius.circular(eyeRadius), clockwise: false);
      happyEyePath.moveTo(center.dx + eyeXOffset - eyeRadius, eyeY + eyeRadius);
      happyEyePath.arcToPoint(Offset(center.dx + eyeXOffset + eyeRadius, eyeY + eyeRadius), radius: Radius.circular(eyeRadius), clockwise: false);
      canvas.drawPath(happyEyePath, mouthPaint..strokeWidth = radius * 0.08);
    } else if (state == PetState.winking) {
      // Mắt trái mở
      canvas.drawCircle(Offset(center.dx - eyeXOffset, eyeY), eyeRadius, eyePaint);
      // Mắt phải nháy
      final winkPath = Path();
      winkPath.moveTo(center.dx + eyeXOffset - eyeRadius, eyeY + eyeRadius * 0.5);
      winkPath.arcToPoint(Offset(center.dx + eyeXOffset + eyeRadius, eyeY + eyeRadius * 0.5), radius: Radius.circular(eyeRadius), clockwise: false);
      canvas.drawPath(winkPath, mouthPaint..strokeWidth = radius * 0.08);
    } else {
      if (blink > 0.1) { // Chỉ vẽ mắt mở khi không nháy
        canvas.drawCircle(Offset(center.dx - eyeXOffset, eyeY), eyeRadius, eyePaint);
        canvas.drawCircle(Offset(center.dx + eyeXOffset, eyeY), eyeRadius, eyePaint);
      }
    }

    // Vẽ miệng và các chi tiết khác theo trạng thái
    final mouthY = center.dy + radius * 0.2;
    final mouthPath = Path();
    switch (state) {
      case PetState.happy:
      case PetState.excited:
        mouthPath.moveTo(center.dx - radius * 0.3, mouthY);
        mouthPath.arcTo(Rect.fromCircle(center: Offset(center.dx, mouthY - radius * 0.1), radius: radius * 0.35), pi * 0.2, pi * 0.6, false);
        break;
      case PetState.sad:
        mouthPath.moveTo(center.dx - radius * 0.25, mouthY + radius * 0.1);
        mouthPath.quadraticBezierTo(center.dx, mouthY, center.dx + radius * 0.25, mouthY + radius * 0.1);
        break;
      case PetState.angry:
        mouthPath.moveTo(center.dx - radius * 0.25, mouthY + radius * 0.1);
        mouthPath.lineTo(center.dx + radius * 0.25, mouthY - radius * 0.1);
        break;
      case PetState.winking:
        mouthPath.moveTo(center.dx - radius * 0.25, mouthY);
        mouthPath.quadraticBezierTo(center.dx - radius * 0.1, mouthY + radius * 0.2, center.dx, mouthY + radius * 0.1);
        mouthPath.quadraticBezierTo(center.dx + radius * 0.1, mouthY, center.dx + radius * 0.2, mouthY + radius * 0.15); // Lè lưỡi
        break;
      case PetState.idle:
      case PetState.curious:
        mouthPath.moveTo(center.dx - radius * 0.2, mouthY);
        mouthPath.quadraticBezierTo(center.dx, mouthY + radius * 0.15, center.dx + radius * 0.2, mouthY);
        break;
      default:
        break;
    }
    canvas.drawPath(mouthPath, mouthPaint);
  }


  @override
  bool shouldRepaint(covariant _ChibiPetPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.state != state;
  }
}
