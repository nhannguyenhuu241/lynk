import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/utils/text_utils.dart';

/// Enum định nghĩa các nguyên tố Ngũ Hành.
enum GhostElement {
  /// Không có nguyên tố.
  none,
  /// Hành Kim.
  metal,
  /// Hành Mộc.
  wood,
  /// Hành Thủy.
  water,
  /// Hành Hỏa.
  fire,
  /// Hành Thổ.
  earth,
}

/// Enum định nghĩa các trạng thái cảm xúc của bé ma.
enum GhostEmotion {
  /// Trạng thái thở, nghỉ ngơi bình thường.
  idle,
  /// Trạng thái đang ngủ.
  sleeping,
  /// Trạng thái vui vẻ, hạnh phúc.
  happy,
  /// Trạng thái đang suy nghĩ.
  thinking,
  /// Trạng thái chào mừng, dang rộng vòng tay.
  welcoming,
  /// Trạng thái cảm thán, ngạc nhiên.
  amazed,
  /// Trạng thái tức giận.
  angry,
  /// Trạng thái lầy lội, cợt nhã.
  trolling,
  /// Trạng thái buồn bã, "suy".
  sadboi,
  /// Trạng thái lắng nghe câu hỏi.
  listening,
  /// Trạng thái sợ hãi khi bốc phải lá bài xấu.
  scared,
  /// Trạng thái chóng mặt khi bị lắc.
  dizzy,
  /// (MỚI) Trạng thái ngáp ngủ.
  sleepy,
}

/// Một widget để hiển thị bé ma chibi với các trạng thái cảm xúc khác nhau.
///
/// Widget này sẽ tự quản lý animation của mình và có thể nhận biết bối cảnh
/// như thời gian, pin, và tương tác từ người dùng.
class GhostWidget extends StatefulWidget {
  final double size;
  final GhostEmotion emotion;
  final GhostElement element;

  // Các tham số về bối cảnh
  final bool isNightTime;
  final bool isBatteryLow;
  final bool isCharging;
  final VoidCallback? onTap;
  /// (MỚI) Bật/tắt hiệu ứng hào quang.
  final bool hasAura;

  const GhostWidget({
    super.key,
    this.size = 60.0,
    this.emotion = GhostEmotion.idle,
    this.element = GhostElement.none,
    this.isNightTime = false,
    this.isBatteryLow = false,
    this.isCharging = false,
    this.onTap,
    this.hasAura = false,
  });

  @override
  State<GhostWidget> createState() => _GhostWidgetState();
}

class _GhostWidgetState extends State<GhostWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _eyeAnimationTimer;
  final Random _random = Random();

  // Các biến trạng thái cho hành động của mắt
  double _pupilOffsetX = 0.0;
  bool _isLeftEyeBlinking = false;
  bool _isRightEyeBlinking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Làm chậm nhịp thở một chút
      vsync: this,
    )..repeat();

    if (widget.emotion == GhostEmotion.idle) {
      _startEyeAnimationTimer();
    }
  }

  @override
  void didUpdateWidget(covariant GhostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu cảm xúc thay đổi, hãy bắt đầu hoặc dừng bộ đếm thời gian của mắt
    if (widget.emotion != oldWidget.emotion) {
      if (widget.emotion == GhostEmotion.idle) {
        _startEyeAnimationTimer();
      } else {
        _eyeAnimationTimer?.cancel();
        // Reset trạng thái mắt khi chuyển sang cảm xúc khác
        _pupilOffsetX = 0.0;
        _isLeftEyeBlinking = false;
        _isRightEyeBlinking = false;
      }
    }
  }

  /// Bắt đầu bộ đếm thời gian cho các hành động ngẫu nhiên của mắt.
  void _startEyeAnimationTimer() {
    _eyeAnimationTimer?.cancel();
    // Hành động tiếp theo sẽ xảy ra sau 2 đến 5 giây
    _eyeAnimationTimer = Timer(
      Duration(milliseconds: 2000 + _random.nextInt(3000)),
      _triggerRandomEyeAction,
    );
  }

  /// Kích hoạt một hành động ngẫu nhiên cho mắt.
  void _triggerRandomEyeAction() {
    if (!mounted) return;

    setState(() {
      // Reset trạng thái trước đó
      _pupilOffsetX = 0.0;
      _isLeftEyeBlinking = false;
      _isRightEyeBlinking = false;

      final action = _random.nextInt(10); // Số ngẫu nhiên từ 0-9

      switch (action) {
        case 0: // Nháy mắt trái
          _isLeftEyeBlinking = true;
          Timer(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _isLeftEyeBlinking = false);
          });
          break;

        case 1: // Nháy mắt phải
          _isRightEyeBlinking = true;
          Timer(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _isRightEyeBlinking = false);
          });
          break;

        case 2: // Chớp cả hai mắt
          _isLeftEyeBlinking = true;
          _isRightEyeBlinking = true;
          Timer(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _isLeftEyeBlinking = false;
                _isRightEyeBlinking = false;
              });
            }
          });
          break;

        case 3: // Liếc trái
        case 4:
          _pupilOffsetX = -1.0;
          // Giữ ánh nhìn trong 1-2.5 giây
          Timer(Duration(milliseconds: 1000 + _random.nextInt(1500)), () {
            if (mounted) setState(() => _pupilOffsetX = 0.0);
          });
          break;

        case 5: // Liếc phải
        case 6:
          _pupilOffsetX = 1.0;
          Timer(Duration(milliseconds: 1000 + _random.nextInt(1500)), () {
            if (mounted) setState(() => _pupilOffsetX = 0.0);
          });
          break;

        default: // 7, 8, 9: Không làm gì, chỉ nhìn thẳng
          _pupilOffsetX = 0.0;
          break;
      }
    });

    // Lên lịch cho hành động ngẫu nhiên tiếp theo
    _startEyeAnimationTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _eyeAnimationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: CustomPaint(
        size: Size(widget.size * 1.8, widget.size * 1.1),
        painter: _GhostPainter(
          animation: _controller,
          emotion: widget.emotion,
          element: widget.element,
          // Truyền các trạng thái mắt vào painter
          pupilOffsetX: _pupilOffsetX,
          isLeftEyeBlinking: _isLeftEyeBlinking,
          isRightEyeBlinking: _isRightEyeBlinking,
          // Truyền các trạng thái bối cảnh
          isNightTime: widget.isNightTime,
          isBatteryLow: widget.isBatteryLow,
          isCharging: widget.isCharging,
          hasAura: widget.hasAura,
        ),
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  final Animation<double> animation;
  final GhostEmotion emotion;
  final GhostElement element;
  // Các tham số cho trạng thái idle
  final double pupilOffsetX;
  final bool isLeftEyeBlinking;
  final bool isRightEyeBlinking;
  // Các tham số bối cảnh
  final bool isNightTime;
  final bool isBatteryLow;
  final bool isCharging;
  final bool hasAura;

  _GhostPainter({
    required this.animation,
    required this.emotion,
    required this.element,
    this.pupilOffsetX = 0.0,
    this.isLeftEyeBlinking = false,
    this.isRightEyeBlinking = false,
    required this.isNightTime,
    required this.isBatteryLow,
    required this.isCharging,
    required this.hasAura,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // --- Các định nghĩa màu sắc và vị trí cơ bản ---
    final ghostPaint = Paint()..color = isBatteryLow ? Colors.white.withValues(alpha: 0.7) : Colors.white;
    final blushPaint = Paint()..color = Colors.pink.shade100;
    final eyePaint = Paint()..color = Colors.black87;
    final blackHandPaint = Paint()..color = Colors.black87;
    final whiteHandPaint = Paint()..color = Colors.white;
    final whiteHandBorderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final headRadius = (size.height / 1.1) / 2;
    final breathValue = sin(animation.value * 2 * pi);
    final ghostCenter = Offset(size.width / 2, headRadius + breathValue * 2);

    // (MỚI) Vẽ hào quang nếu được bật
    if (hasAura) {
      _drawAura(canvas, ghostCenter, headRadius, animation.value);
    }

    // Vẽ bóng của bé ma
    final shadowPaint = Paint();
    final heightFactor = (breathValue + 1) / 2;
    final shadowOpacity = 0.15 * (1 - heightFactor * 0.7);
    final shadowWidth = headRadius * 1.6 * (1 - heightFactor * 0.4);
    final shadowHeight = headRadius * 0.3 * (1 - heightFactor * 0.4);
    shadowPaint.color = Colors.black.withValues(alpha: shadowOpacity);
    shadowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final shadowRect = Rect.fromCenter(
      center: Offset(ghostCenter.dx, size.height - shadowHeight),
      width: shadowWidth,
      height: shadowHeight,
    );
    canvas.drawOval(shadowRect, shadowPaint);

    // --- Vẽ thân, đuôi và má hồng (không đổi) ---
    canvas.drawCircle(ghostCenter, headRadius, ghostPaint);
    final path = Path();
    path.moveTo(ghostCenter.dx - headRadius, ghostCenter.dy);
    path.quadraticBezierTo(ghostCenter.dx - headRadius / 2,
        ghostCenter.dy + headRadius, ghostCenter.dx, ghostCenter.dy + headRadius * 0.8);
    path.quadraticBezierTo(ghostCenter.dx + headRadius / 2,
        ghostCenter.dy + headRadius, ghostCenter.dx + headRadius, ghostCenter.dy);
    canvas.drawPath(path, ghostPaint);
    if (emotion != GhostEmotion.angry && emotion != GhostEmotion.sadboi) {
      final blushY = ghostCenter.dy + headRadius * 0.27;
      final blushXOffset = headRadius * 0.5;
      final blushRadius = headRadius * 0.17;
      canvas.drawCircle(Offset(ghostCenter.dx - blushXOffset, blushY), blushRadius, blushPaint);
      canvas.drawCircle(Offset(ghostCenter.dx + blushXOffset, blushY), blushRadius, blushPaint);
    }

    // --- Vẽ mắt và tay dựa trên cảm xúc ---
    switch (emotion) {
      case GhostEmotion.sleeping:
        _drawSleeping(canvas, ghostCenter, headRadius, eyePaint, animation.value);
        break;
      case GhostEmotion.happy:
        _drawHappy(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint,
            whiteHandPaint, whiteHandBorderPaint, breathValue);
        break;
      case GhostEmotion.thinking:
        _drawThinking(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint,
            whiteHandPaint, whiteHandBorderPaint, animation.value);
        break;
      case GhostEmotion.welcoming:
        _drawWelcoming(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint,
            whiteHandPaint, whiteHandBorderPaint, breathValue);
        break;
      case GhostEmotion.amazed:
        _drawAmazed(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint,
            whiteHandPaint, whiteHandBorderPaint, animation.value);
        break;
      case GhostEmotion.angry:
        _drawAngry(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint,
            whiteHandPaint, whiteHandBorderPaint, breathValue);
        break;
      case GhostEmotion.trolling:
        _drawTrolling(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint,
            whiteHandPaint, whiteHandBorderPaint, animation.value);
        break;
      case GhostEmotion.sadboi:
        _drawSadboi(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint,
            whiteHandPaint, whiteHandBorderPaint, animation.value);
        break;
      case GhostEmotion.listening:
        _drawListening(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint, whiteHandPaint, whiteHandBorderPaint);
        break;
      case GhostEmotion.scared:
        _drawScared(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint, whiteHandPaint, whiteHandBorderPaint, animation.value);
        break;
      case GhostEmotion.dizzy:
        _drawDizzy(canvas, ghostCenter, headRadius, eyePaint, animation.value);
        break;
      case GhostEmotion.sleepy:
        _drawSleepy(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint, whiteHandPaint, whiteHandBorderPaint, animation.value);
        break;
      case GhostEmotion.idle:
      default:
        _drawIdle(canvas, ghostCenter, headRadius, eyePaint, blackHandPaint,
            whiteHandPaint, whiteHandBorderPaint, breathValue);
        break;
    }

    // Vẽ phụ kiện Ngũ Hành, trừ khi đang "suy"
    if (emotion != GhostEmotion.sadboi) {
      switch (element) {
        case GhostElement.metal:
          _drawMetalAccessory(canvas, ghostCenter, headRadius, animation.value);
          break;
        case GhostElement.wood:
          _drawWoodAccessory(canvas, ghostCenter, headRadius);
          break;
        case GhostElement.water:
          _drawWaterAccessory(canvas, ghostCenter, headRadius, animation.value);
          break;
        case GhostElement.fire:
          _drawFireAccessory(canvas, ghostCenter, headRadius, animation.value);
          break;
        case GhostElement.earth:
          _drawEarthAccessory(canvas, ghostCenter, headRadius);
          break;
        case GhostElement.none:
          break;
      }
    }

    // Vẽ hiệu ứng sạc pin
    if (isCharging) {
      _drawChargingEffect(canvas, ghostCenter, headRadius, animation.value);
    }
  }

  // --- Các hàm trợ giúp để vẽ từng trạng thái ---

  void _drawIdle(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double breathValue) {
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final pupilRadius = headRadius * 0.13;

    void drawClosedEye(Offset center) {
      final eyePath = Path();
      final paint = eyePaint..style = PaintingStyle.stroke..strokeWidth = 2;
      final eyeWidth = headRadius * 0.25;
      eyePath.moveTo(center.dx - eyeWidth, center.dy);
      eyePath.lineTo(center.dx + eyeWidth, center.dy);
      canvas.drawPath(eyePath, paint);
    }

    if (isLeftEyeBlinking) {
      drawClosedEye(Offset(ghostCenter.dx - eyeXOffset, eyeY));
    } else {
      final finalPupilOffsetX = pupilOffsetX * (headRadius * 0.1);
      canvas.drawCircle(Offset(ghostCenter.dx - eyeXOffset + finalPupilOffsetX, eyeY), pupilRadius, eyePaint..style=PaintingStyle.fill);
    }

    if (isRightEyeBlinking) {
      drawClosedEye(Offset(ghostCenter.dx + eyeXOffset, eyeY));
    } else {
      final finalPupilOffsetX = pupilOffsetX * (headRadius * 0.1);
      canvas.drawCircle(Offset(ghostCenter.dx + eyeXOffset + finalPupilOffsetX, eyeY), pupilRadius, eyePaint..style=PaintingStyle.fill);
    }

    final handY = ghostCenter.dy + headRadius * 0.3 + breathValue * 3;
    final handXOffset = headRadius * 1.3;
    final handRadius = headRadius * 0.25;
    canvas.drawCircle(Offset(ghostCenter.dx - handXOffset, handY), handRadius, blackHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandBorderPaint);
  }

  void _drawSleeping(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, double animationValue) {
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyeWidth = headRadius * 0.2;
    final eyePath = Path();
    final paint = eyePaint..style = PaintingStyle.stroke..strokeWidth = 2;
    eyePath.moveTo(ghostCenter.dx - eyeXOffset - eyeWidth, eyeY);
    eyePath.quadraticBezierTo(ghostCenter.dx - eyeXOffset, eyeY + eyeWidth, ghostCenter.dx - eyeXOffset + eyeWidth, eyeY);
    eyePath.moveTo(ghostCenter.dx + eyeXOffset - eyeWidth, eyeY);
    eyePath.quadraticBezierTo(ghostCenter.dx + eyeXOffset, eyeY + eyeWidth, ghostCenter.dx + eyeXOffset + eyeWidth, eyeY);
    canvas.drawPath(eyePath, paint);

    final textStyle = TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.bold);
    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + i * 0.33) % 1.0;
      final yPos = ghostCenter.dy - 20 - (progress * 40);
      final xPos = ghostCenter.dx + 20 + sin(progress * pi) * 10;
      final opacity = (1 - progress);

      final effectiveStyle = textStyle.copyWith(color: textStyle.color?.withValues(alpha: opacity));
      final textPainter = TextUtils.createSafeTextPainter(
        text: 'Z',
        style: effectiveStyle,
        textAlign: TextAlign.center,
      );
      textPainter.paint(canvas, Offset(xPos, yPos));
    }

    if (isNightTime) {
      final hatPaint = Paint()..color = Colors.deepPurple.shade300;
      final hatPath = Path();
      final hatTop = Offset(ghostCenter.dx + headRadius * 0.5, ghostCenter.dy - headRadius * 1.2);
      hatPath.moveTo(ghostCenter.dx - headRadius * 0.5, ghostCenter.dy - headRadius * 0.8);
      hatPath.lineTo(ghostCenter.dx + headRadius * 0.5, ghostCenter.dy - headRadius * 0.8);
      hatPath.lineTo(hatTop.dx, hatTop.dy);
      hatPath.close();
      canvas.drawPath(hatPath, hatPaint);
      canvas.drawCircle(hatTop, headRadius * 0.15, Paint()..color=Colors.yellow.shade200);
    }
  }

  void _drawHappy(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double breathValue) {
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyeWidth = headRadius * 0.2;
    final eyeHeight = headRadius * 0.15;
    final eyePath = Path();
    final paint = eyePaint..style = PaintingStyle.stroke..strokeWidth = 2.5;
    eyePath.moveTo(ghostCenter.dx - eyeXOffset - eyeWidth, eyeY + eyeHeight);
    eyePath.lineTo(ghostCenter.dx - eyeXOffset, eyeY - eyeHeight / 2);
    eyePath.lineTo(ghostCenter.dx - eyeXOffset + eyeWidth, eyeY + eyeHeight);
    eyePath.moveTo(ghostCenter.dx + eyeXOffset - eyeWidth, eyeY + eyeHeight);
    eyePath.lineTo(ghostCenter.dx + eyeXOffset, eyeY - eyeHeight / 2);
    eyePath.lineTo(ghostCenter.dx + eyeXOffset + eyeWidth, eyeY + eyeHeight);
    canvas.drawPath(eyePath, paint);

    final handY = ghostCenter.dy - headRadius * 0.1 + breathValue * 5;
    final handXOffset = headRadius * 1.0;
    final handRadius = headRadius * 0.25;
    canvas.drawCircle(Offset(ghostCenter.dx - handXOffset, handY), handRadius, blackHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandBorderPaint);
  }

  void _drawThinking(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double timeValue) {
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyeRadius = headRadius * 0.13;
    final pupilOffset = Offset(eyeRadius * 0.5, 0);
    canvas.drawCircle(Offset(ghostCenter.dx - eyeXOffset + pupilOffset.dx, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(ghostCenter.dx + eyeXOffset + pupilOffset.dx, eyeY), eyeRadius, eyePaint);

    final handRadius = headRadius * 0.25;
    final blackHandY = ghostCenter.dy + headRadius * 0.8;
    final blackHandX = ghostCenter.dx - headRadius * 0.3;
    canvas.drawCircle(Offset(blackHandX, blackHandY), handRadius, blackHandPaint);

    final whiteHandY = ghostCenter.dy + headRadius * 0.3;
    final whiteHandXOffset = headRadius * 1.3;
    canvas.drawCircle(Offset(ghostCenter.dx + whiteHandXOffset, whiteHandY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + whiteHandXOffset, whiteHandY), handRadius, whiteHandBorderPaint);

    final bulbCenter = Offset(ghostCenter.dx + headRadius * 0.8, ghostCenter.dy - headRadius * 0.8);
    final bulbRadius = headRadius * 0.2;
    final isFlashing = (timeValue * 10).floor() % 2 == 0;
    final bulbPaint = Paint()..color = isFlashing ? Colors.yellow.shade600 : Colors.grey.shade600;
    canvas.drawRect(Rect.fromCenter(center: Offset(bulbCenter.dx, bulbCenter.dy + bulbRadius), width: bulbRadius, height: bulbRadius * 0.5), bulbPaint);
    canvas.drawCircle(bulbCenter, bulbRadius, bulbPaint);
  }

  void _drawWelcoming(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double breathValue) {
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyeRadius = headRadius * 0.13;
    canvas.drawCircle(Offset(ghostCenter.dx - eyeXOffset, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(ghostCenter.dx + eyeXOffset, eyeY), eyeRadius, eyePaint);

    final handY = ghostCenter.dy + headRadius * 0.2;
    final handXOffset = headRadius * 1.4 + (sin(animation.value * pi).abs()) * 4;
    final handRadius = headRadius * 0.25;
    canvas.drawCircle(Offset(ghostCenter.dx - handXOffset, handY), handRadius, blackHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandBorderPaint);

    final textStyle = TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold);
    final textPainter = TextUtils.createSafeTextPainter(
      text: 'Hi!',
      style: textStyle,
      textAlign: TextAlign.center,
    );
    textPainter.paint(canvas, Offset(ghostCenter.dx + handXOffset - (textPainter.width/2), handY - handRadius * 2));
  }

  void _drawAmazed(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double timeValue) {
    // Mắt mở to, nháy nhanh
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final isBlinking = (timeValue * 20).floor() % 2 == 0; // Nháy mắt rất nhanh

    if (isBlinking) {
      final eyePath = Path();
      final paint = eyePaint..style = PaintingStyle.stroke..strokeWidth = 2;
      final eyeWidth = headRadius * 0.25;
      eyePath.moveTo(ghostCenter.dx - eyeXOffset - eyeWidth, eyeY); eyePath.lineTo(ghostCenter.dx - eyeXOffset + eyeWidth, eyeY);
      eyePath.moveTo(ghostCenter.dx + eyeXOffset - eyeWidth, eyeY); eyePath.lineTo(ghostCenter.dx + eyeXOffset + eyeWidth, eyeY);
      canvas.drawPath(eyePath, paint);
    } else {
      final eyeRadius = headRadius * 0.2; // Mắt mở to hơn bình thường
      final sparklePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(ghostCenter.dx - eyeXOffset, eyeY), eyeRadius, eyePaint);
      canvas.drawCircle(Offset(ghostCenter.dx + eyeXOffset, eyeY), eyeRadius, eyePaint);
      // Thêm lấp lánh trong mắt
      canvas.drawCircle(Offset(ghostCenter.dx - eyeXOffset + eyeRadius*0.3, eyeY - eyeRadius*0.3), eyeRadius*0.2, sparklePaint);
      canvas.drawCircle(Offset(ghostCenter.dx + eyeXOffset + eyeRadius*0.3, eyeY - eyeRadius*0.3), eyeRadius*0.2, sparklePaint);
    }

    // Tay vỗ mạnh
    final clapValue = sin(timeValue * 2 * pi * 4); // Tần số vỗ tay nhanh
    final handY = ghostCenter.dy + headRadius * 0.4;
    final handXOffset = headRadius * 0.3 + clapValue.abs() * headRadius * 0.5;
    final handRadius = headRadius * 0.25;
    canvas.drawCircle(Offset(ghostCenter.dx - handXOffset, handY), handRadius, blackHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandBorderPaint);
  }

  void _drawAngry(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double breathValue) {
    // Mắt xếch lên giận dữ
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyePath = Path();
    final paint = eyePaint..style = PaintingStyle.stroke..strokeWidth = 2.5;
    // Mắt trái
    eyePath.moveTo(ghostCenter.dx - eyeXOffset - headRadius * 0.2, eyeY + headRadius * 0.1);
    eyePath.lineTo(ghostCenter.dx - eyeXOffset + headRadius * 0.2, eyeY - headRadius * 0.1);
    // Mắt phải
    eyePath.moveTo(ghostCenter.dx + eyeXOffset - headRadius * 0.2, eyeY - headRadius * 0.1);
    eyePath.lineTo(ghostCenter.dx + eyeXOffset + headRadius * 0.2, eyeY + headRadius * 0.1);
    canvas.drawPath(eyePath, paint);

    // Hiệu ứng phồng má giận dỗi
    final angryBlushPaint = Paint()..color = Colors.red.shade300;
    canvas.drawCircle(Offset(ghostCenter.dx - headRadius*0.5, ghostCenter.dy + headRadius*0.3), headRadius*0.25, angryBlushPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + headRadius*0.5, ghostCenter.dy + headRadius*0.3), headRadius*0.25, angryBlushPaint);

    // Vẽ dấu giận trên trán
    final angryMarkPaint = Paint()
      ..color = Colors.blue.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final markPath = Path();
    final markCenter = Offset(ghostCenter.dx, ghostCenter.dy - headRadius * 0.5);
    final markSize = headRadius * 0.15;

    markPath.moveTo(markCenter.dx - markSize, markCenter.dy + markSize);
    markPath.lineTo(markCenter.dx + markSize, markCenter.dy - markSize);
    markPath.moveTo(markCenter.dx, markCenter.dy + markSize);
    markPath.lineTo(markCenter.dx, markCenter.dy - markSize);

    canvas.drawPath(markPath, angryMarkPaint);

    // Tay nắm chặt ở hai bên hông
    final handY = ghostCenter.dy + headRadius * 0.5;
    final handXOffset = headRadius * 0.9;
    final handRadius = headRadius * 0.25;
    canvas.drawCircle(Offset(ghostCenter.dx - handXOffset, handY), handRadius, blackHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandBorderPaint);
  }

  void _drawTrolling(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double timeValue) {
    // Kính "Deal With It"
    final glassesPaint = Paint()..color = Colors.black;
    final glassesHeight = headRadius * 0.3;
    final glassesY = ghostCenter.dy;
    final glassesWidth = headRadius * 1.5;
    final glassesRect = Rect.fromCenter(center: Offset(ghostCenter.dx, glassesY), width: glassesWidth, height: glassesHeight);
    canvas.drawRect(glassesRect, glassesPaint);

    // Miệng cười nhếch mép
    final mouthPath = Path();
    final mouthY = ghostCenter.dy + headRadius * 0.4;
    mouthPath.moveTo(ghostCenter.dx - headRadius * 0.3, mouthY);
    mouthPath.quadraticBezierTo(ghostCenter.dx, mouthY + headRadius * 0.2, ghostCenter.dx + headRadius * 0.3, mouthY);
    canvas.drawPath(mouthPath, eyePaint..style = PaintingStyle.stroke);

    // (MỚI) Animation xào bài Tarot
    final cardPaint = Paint()..color = Colors.purple.shade200;
    final cardBorder = Paint()..color=Colors.yellow.shade600..style=PaintingStyle.stroke..strokeWidth=2;
    final cardWidth = headRadius * 0.5;
    final cardHeight = headRadius * 0.8;

    // Vẽ nhiều lá bài bay xung quanh
    for (int i = 0; i < 5; i++) {
      final progress = (timeValue + i * 0.2) % 1.0;
      final angle = progress * 2 * pi;

      // Quỹ đạo bay hình elip
      final orbitX = ghostCenter.dx + cos(angle) * headRadius * 1.5;
      final orbitY = ghostCenter.dy + sin(angle) * headRadius * 0.5;

      canvas.save();
      canvas.translate(orbitX, orbitY);
      canvas.rotate(progress * 4 * pi); // Xoay lá bài

      final cardRect = Rect.fromCenter(center: Offset.zero, width: cardWidth, height: cardHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(4)), cardPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(4)), cardBorder);
      canvas.restore();
    }

    // Tay dang ra như đang điều khiển các lá bài
    final handY = ghostCenter.dy + headRadius * 0.4;
    final handXOffset = headRadius * 1.1;
    final handRadius = headRadius * 0.25;
    canvas.drawCircle(Offset(ghostCenter.dx - handXOffset, handY), handRadius, blackHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandBorderPaint);
  }

  void _drawSadboi(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double timeValue) {
    // Mắt rưng rưng lệ
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyeRadius = headRadius * 0.15;
    final tearPaint = Paint()..shader = LinearGradient(
      colors: [Colors.blue.shade200, Colors.blue.shade400.withValues(alpha: 0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromCircle(center: ghostCenter, radius: headRadius));

    // Giọt lệ rơi
    final tearProgress = (timeValue * 1.5) % 1.0;
    final tearPath = Path();
    final startPoint = Offset(ghostCenter.dx - eyeXOffset, eyeY + eyeRadius);
    final endPoint = Offset(startPoint.dx, startPoint.dy + 30 * tearProgress);
    final dropRadius = 4 * (1 - tearProgress); // Giọt nước nhỏ dần
    tearPath.moveTo(startPoint.dx, startPoint.dy);
    tearPath.lineTo(endPoint.dx, endPoint.dy);
    canvas.drawPath(tearPath, tearPaint..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawCircle(endPoint, dropRadius, tearPaint..style=PaintingStyle.fill);

    canvas.drawCircle(Offset(ghostCenter.dx - eyeXOffset, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(ghostCenter.dx + eyeXOffset, eyeY), eyeRadius, eyePaint);

    // Đám mây mưa trên đầu
    final cloudPaint = Paint()..color = Colors.grey.shade600;
    final cloudCenter = Offset(ghostCenter.dx, ghostCenter.dy - headRadius * 1.2);
    canvas.drawCircle(cloudCenter, headRadius * 0.3, cloudPaint);
    canvas.drawCircle(Offset(cloudCenter.dx - headRadius * 0.25, cloudCenter.dy + headRadius * 0.1), headRadius * 0.25, cloudPaint);
    canvas.drawCircle(Offset(cloudCenter.dx + headRadius * 0.25, cloudCenter.dy + headRadius * 0.1), headRadius * 0.25, cloudPaint);

    // Hiệu ứng sấm chớp
    final lightningProgress = (timeValue * 4) % 1.0;
    if (lightningProgress < 0.1) {
      final lightningPaint = Paint()..color=Colors.yellow.shade300..style=PaintingStyle.stroke..strokeWidth=3;
      final lightningPath = Path();
      final start = Offset(cloudCenter.dx, cloudCenter.dy + headRadius * 0.2);
      lightningPath.moveTo(start.dx, start.dy);
      lightningPath.lineTo(start.dx - 5, start.dy + 10);
      lightningPath.lineTo(start.dx + 5, start.dy + 12);
      lightningPath.lineTo(start.dx, start.dy + 22);
      canvas.drawPath(lightningPath, lightningPaint);
    }

    // Tay buông thõng
    final handY = ghostCenter.dy + headRadius * 0.6;
    final handXOffset = headRadius * 1.1;
    final handRadius = headRadius * 0.25;
    canvas.drawCircle(Offset(ghostCenter.dx - handXOffset, handY), handRadius, blackHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + handXOffset, handY), handRadius, whiteHandBorderPaint);
  }

  void _drawListening(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint) {
    // Mắt mở to, tập trung
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyeRadius = headRadius * 0.15;
    canvas.drawCircle(Offset(ghostCenter.dx - eyeXOffset, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(ghostCenter.dx + eyeXOffset, eyeY), eyeRadius, eyePaint);

    // Một tay đưa lên tai
    final handRadius = headRadius * 0.25;
    final listeningHandY = ghostCenter.dy + headRadius * 0.1;
    final listeningHandX = ghostCenter.dx - headRadius * 0.8;
    canvas.drawCircle(Offset(listeningHandX, listeningHandY), handRadius, blackHandPaint);

    // Tay còn lại để xuôi
    final otherHandY = ghostCenter.dy + headRadius * 0.3;
    final otherHandXOffset = headRadius * 1.3;
    canvas.drawCircle(Offset(ghostCenter.dx + otherHandXOffset, otherHandY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + otherHandXOffset, otherHandY), handRadius, whiteHandBorderPaint);
  }

  void _drawScared(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double timeValue) {
    // Hiệu ứng run rẩy
    final shakeX = sin(timeValue * 2 * pi * 10) * 2;
    final shakeY = cos(timeValue * 2 * pi * 10) * 2;
    final scaredCenter = Offset(ghostCenter.dx + shakeX, ghostCenter.dy + shakeY);

    // Mắt mở to, con ngươi nhỏ lại
    final eyeY = scaredCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyeRadius = headRadius * 0.2;
    final pupilRadius = headRadius * 0.05;
    canvas.drawCircle(Offset(scaredCenter.dx - eyeXOffset, eyeY), eyeRadius, Paint()..color=Colors.white);
    canvas.drawCircle(Offset(scaredCenter.dx + eyeXOffset, eyeY), eyeRadius, Paint()..color=Colors.white);
    canvas.drawCircle(Offset(scaredCenter.dx - eyeXOffset, eyeY), pupilRadius, eyePaint);
    canvas.drawCircle(Offset(scaredCenter.dx + eyeXOffset, eyeY), pupilRadius, eyePaint);

    // Tay giơ lên che miệng
    final handRadius = headRadius * 0.25;
    final handY = scaredCenter.dy + headRadius * 0.4;
    final handXOffset = headRadius * 0.3;
    canvas.drawCircle(Offset(scaredCenter.dx - handXOffset, handY), handRadius, blackHandPaint);
    canvas.drawCircle(Offset(scaredCenter.dx + handXOffset, handY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(scaredCenter.dx + handXOffset, handY), handRadius, whiteHandBorderPaint);
  }

  void _drawDizzy(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, double timeValue) {
    // Mắt xoáy tròn
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyeRadius = headRadius * 0.15;
    final swirlPaint = eyePaint..style=PaintingStyle.stroke..strokeWidth=2;
    canvas.save();
    canvas.translate(ghostCenter.dx - eyeXOffset, eyeY);
    canvas.rotate(timeValue * 2 * pi * 2);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: eyeRadius), 0, pi, false, swirlPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: eyeRadius), pi, pi, false, swirlPaint..color=Colors.grey);
    canvas.restore();

    canvas.save();
    canvas.translate(ghostCenter.dx + eyeXOffset, eyeY);
    canvas.rotate(timeValue * 2 * pi * 2);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: eyeRadius), 0, pi, false, swirlPaint..color=Colors.black87);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: eyeRadius), pi, pi, false, swirlPaint..color=Colors.grey);
    canvas.restore();

    // Sao bay quanh đầu
    final starPaint = Paint()..color = Colors.yellow.shade600;
    for (int i = 0; i < 3; i++) {
      final progress = (timeValue + i * 0.33) % 1.0;
      final angle = progress * 2 * pi;
      final starCenter = Offset(
        ghostCenter.dx + cos(angle) * headRadius * 1.2,
        ghostCenter.dy - headRadius * 0.5 + sin(angle) * headRadius * 0.3,
      );
      canvas.drawCircle(starCenter, headRadius * 0.1, starPaint);
    }
  }

  void _drawSleepy(Canvas canvas, Offset ghostCenter, double headRadius, Paint eyePaint, Paint blackHandPaint, Paint whiteHandPaint, Paint whiteHandBorderPaint, double timeValue) {
    // Mắt lim dim
    final eyeY = ghostCenter.dy;
    final eyeXOffset = headRadius * 0.33;
    final eyePath = Path();
    final paint = eyePaint..style = PaintingStyle.stroke..strokeWidth = 2;
    final eyeWidth = headRadius * 0.25;
    eyePath.moveTo(ghostCenter.dx - eyeXOffset - eyeWidth, eyeY + headRadius * 0.05);
    eyePath.lineTo(ghostCenter.dx - eyeXOffset + eyeWidth, eyeY + headRadius * 0.05);
    eyePath.moveTo(ghostCenter.dx + eyeXOffset - eyeWidth, eyeY + headRadius * 0.05);
    eyePath.lineTo(ghostCenter.dx + eyeXOffset + eyeWidth, eyeY + headRadius * 0.05);
    canvas.drawPath(eyePath, paint);

    // Miệng ngáp
    final mouthY = ghostCenter.dy + headRadius * 0.4;
    final mouthWidth = headRadius * 0.5;
    final mouthHeight = headRadius * 0.4 * (0.5 + (sin(timeValue * 2 * pi) + 1)/4); // Miệng mở ra và đóng lại
    final mouthRect = Rect.fromCenter(center: Offset(ghostCenter.dx, mouthY), width: mouthWidth, height: mouthHeight);
    canvas.drawOval(mouthRect, eyePaint..style=PaintingStyle.fill);

    // Tay dụi mắt
    final handRadius = headRadius * 0.25;
    final rubbingHandY = ghostCenter.dy + headRadius * 0.1;
    final rubbingHandX = ghostCenter.dx - headRadius * 0.5;
    canvas.drawCircle(Offset(rubbingHandX, rubbingHandY), handRadius, blackHandPaint);

    // Tay còn lại để xuôi
    final otherHandY = ghostCenter.dy + headRadius * 0.3;
    final otherHandXOffset = headRadius * 1.3;
    canvas.drawCircle(Offset(ghostCenter.dx + otherHandXOffset, otherHandY), handRadius, whiteHandPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + otherHandXOffset, otherHandY), handRadius, whiteHandBorderPaint);
  }

  // --- Các hàm trợ giúp để vẽ phụ kiện Ngũ Hành ---

  void _drawMetalAccessory(Canvas canvas, Offset ghostCenter, double headRadius, double timeValue) {
    // Dây chuyền Bling Bling
    final paint = Paint()..color = Colors.yellow.shade600..style=PaintingStyle.stroke..strokeWidth=4;
    final rect = Rect.fromCircle(center: ghostCenter, radius: headRadius * 0.7);
    canvas.drawArc(rect, pi * 0.2, pi * 0.6, false, paint);

    // Mặt dây chuyền
    final pendantPaint = Paint()..color = Colors.yellow.shade600;
    final pendantCenter = Offset(ghostCenter.dx, ghostCenter.dy + headRadius * 0.7);
    canvas.drawCircle(pendantCenter, headRadius * 0.2, pendantPaint);
    final textStyle = TextStyle(color: Colors.yellow.shade900, fontSize: 16, fontWeight: FontWeight.bold);
    final textPainter = TextUtils.createSafeTextPainter(
      text: '\$',
      style: textStyle,
      textAlign: TextAlign.center,
    );
    textPainter.paint(canvas, Offset(pendantCenter.dx - textPainter.width/2, pendantCenter.dy - textPainter.height/2));

    // Hiệu ứng lấp lánh
    final sparklePaint = Paint()..color = Colors.white;
    final sparkleProgress = (timeValue * 3) % 1.0;
    if (sparkleProgress < 0.15) {
      final sparkleSize = headRadius * 0.1 * (1 - (sparkleProgress/0.15));
      canvas.drawCircle(Offset(pendantCenter.dx, pendantCenter.dy - headRadius * 0.2), sparkleSize, sparklePaint);
    }
  }

  void _drawWoodAccessory(Canvas canvas, Offset ghostCenter, double headRadius) {
    final paint = Paint()..color = Colors.green.shade600;
    final path = Path();
    final topY = ghostCenter.dy - headRadius * 0.9;
    path.moveTo(ghostCenter.dx, topY);
    path.quadraticBezierTo(ghostCenter.dx + headRadius * 0.8, topY - headRadius * 0.2, ghostCenter.dx + headRadius * 0.2, topY - headRadius * 0.9);
    path.quadraticBezierTo(ghostCenter.dx, topY - headRadius * 0.6, ghostCenter.dx, topY - headRadius * 1.2);
    path.quadraticBezierTo(ghostCenter.dx, topY - headRadius * 0.6, ghostCenter.dx - headRadius * 0.2, topY - headRadius * 0.9);
    path.quadraticBezierTo(ghostCenter.dx - headRadius * 0.8, topY - headRadius * 0.2, ghostCenter.dx, topY);
    canvas.drawPath(path, paint);
  }

  void _drawWaterAccessory(Canvas canvas, Offset ghostCenter, double headRadius, double timeValue) {
    // Ly trà sữa
    final cupPaint = Paint()..color = Colors.brown.shade100.withValues(alpha: 0.8);
    final cupPath = Path();
    final cupBottomY = ghostCenter.dy - headRadius * 0.9;
    final cupTopY = cupBottomY - headRadius * 0.6;
    cupPath.moveTo(ghostCenter.dx - headRadius * 0.3, cupBottomY);
    cupPath.lineTo(ghostCenter.dx - headRadius * 0.4, cupTopY);
    cupPath.lineTo(ghostCenter.dx + headRadius * 0.4, cupTopY);
    cupPath.lineTo(ghostCenter.dx + headRadius * 0.3, cupBottomY);
    cupPath.close();
    canvas.drawPath(cupPath, cupPaint);

    // Trân châu
    final pearlPaint = Paint()..color = Colors.black87;
    for (int i = 0; i < 4; i++) {
      final yPos = cupBottomY - 5 - (i*5);
      final xPos = ghostCenter.dx + sin(timeValue*pi + i*2) * 8;
      canvas.drawCircle(Offset(xPos, yPos), 3, pearlPaint);
    }

    // Ống hút
    final strawPaint = Paint()..color=Colors.green.shade300..style=PaintingStyle.stroke..strokeWidth=5;
    canvas.drawLine(Offset(ghostCenter.dx + headRadius * 0.1, cupBottomY), Offset(ghostCenter.dx + headRadius * 0.3, cupTopY - 10), strawPaint);
  }

  void _drawFireAccessory(Canvas canvas, Offset ghostCenter, double headRadius, double timeValue) {
    final paint = Paint()..color = Colors.orange.shade700;
    final path = Path();
    final topY = ghostCenter.dy - headRadius;
    final flicker1 = sin(timeValue * 2 * pi * 3) * 4;
    final flicker2 = cos(timeValue * 2 * pi * 2) * 3;
    path.moveTo(ghostCenter.dx, topY);
    path.quadraticBezierTo(ghostCenter.dx + headRadius * 0.4 + flicker1, topY - headRadius * 0.5, ghostCenter.dx + flicker2, topY - headRadius * 0.9);
    path.quadraticBezierTo(ghostCenter.dx - headRadius * 0.4 - flicker1, topY - headRadius * 0.5, ghostCenter.dx, topY);
    canvas.drawPath(path, paint);
  }

  void _drawEarthAccessory(Canvas canvas, Offset ghostCenter, double headRadius) {
    // Cây nấm
    final stemPaint = Paint()..color = Colors.brown.shade200;
    final capPaint = Paint()..color = Colors.red.shade400;
    final spotPaint = Paint()..color = Colors.white;

    final stemHeight = headRadius * 0.3;
    final stemWidth = headRadius * 0.2;
    final capRadius = headRadius * 0.4;
    final topY = ghostCenter.dy - headRadius;

    final stemRect = Rect.fromCenter(center: Offset(ghostCenter.dx, topY - stemHeight/2), width: stemWidth, height: stemHeight);
    canvas.drawRect(stemRect, stemPaint);

    final capCenter = Offset(ghostCenter.dx, topY - stemHeight);
    canvas.drawCircle(capCenter, capRadius, capPaint);
    canvas.drawCircle(Offset(capCenter.dx - capRadius*0.4, capCenter.dy), capRadius*0.15, spotPaint);
    canvas.drawCircle(Offset(capCenter.dx + capRadius*0.4, capCenter.dy), capRadius*0.15, spotPaint);
    canvas.drawCircle(Offset(capCenter.dx, capCenter.dy - capRadius*0.3), capRadius*0.15, spotPaint);
  }

  void _drawChargingEffect(Canvas canvas, Offset ghostCenter, double headRadius, double timeValue) {
    final sparkPaint = Paint()..color=Colors.yellow.shade600..style=PaintingStyle.stroke..strokeWidth=2;
    final random = Random();
    for(int i = 0; i < 3; i++) {
      final progress = (timeValue + i * 0.33) % 1.0;
      if (progress < 0.1) {
        final angle = random.nextDouble() * 2 * pi;
        final start = Offset(ghostCenter.dx + cos(angle) * headRadius, ghostCenter.dy + sin(angle) * headRadius);
        final end = Offset(start.dx + cos(angle) * 10, start.dy + sin(angle) * 10);
        canvas.drawLine(start, end, sparkPaint);
      }
    }
  }

  void _drawAura(Canvas canvas, Offset ghostCenter, double headRadius, double timeValue) {
    final auraPaint = Paint();
    final colors = [
      Colors.purple.shade200.withValues(alpha: 0.5),
      Colors.purple.shade400.withValues(alpha: 0.3),
      Colors.transparent,
    ];
    // Hào quang tỏa ra và co lại theo nhịp
    final radius = headRadius * 1.2 + sin(timeValue * 2 * pi * 0.5).abs() * 10;
    auraPaint.shader = RadialGradient(
      colors: colors,
      stops: const [0.3, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: ghostCenter, radius: radius));
    canvas.drawCircle(ghostCenter, radius, auraPaint);
  }

  @override
  bool shouldRepaint(covariant _GhostPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.emotion != emotion ||
        oldDelegate.element != element ||
        oldDelegate.pupilOffsetX != pupilOffsetX ||
        oldDelegate.isLeftEyeBlinking != isLeftEyeBlinking ||
        oldDelegate.isRightEyeBlinking != isRightEyeBlinking ||
        oldDelegate.isNightTime != isNightTime ||
        oldDelegate.isBatteryLow != isBatteryLow ||
        oldDelegate.isCharging != isCharging ||
        oldDelegate.hasAura != hasAura;
  }
}
