part of widget;


class MysticalLoadingWidget extends StatefulWidget {
  @override
  State<MysticalLoadingWidget> createState() => _MysticalLoadingWidgetState();
}

class _MysticalLoadingWidgetState extends State<MysticalLoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _textTimer;
  late String _currentText;

  static const List<String> _funkyTexts = [
    "Đang đun lẩu tiên tri...",
    "Bé ma đang gieo quẻ, chờ chút nha!",
    "Rót một chút phép thuật...",
    "Xin miếng năng lượng vũ trụ...",
    "Chờ một 'chíu' là có kết quả ngay...",
    "Loading sự cute này...",
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Tốc độ của animation
      vsync: this,
    )..repeat();

    // Timer để thay đổi text
    _currentText = _funkyTexts.first;
    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        String newText;
        do {
          newText = _funkyTexts[Random().nextInt(_funkyTexts.length)];
        } while (newText == _currentText);
        _currentText = newText;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2A4A), // Tông màu tím pastel nền
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CustomPaint để vẽ animation dễ thương
            // CustomPaint(
            //   size: const Size(200, 200),
            //   painter: CuteLoadingPainter(animation: _controller),
            // ),
            const SizedBox(height: 32),
            // Text hài hước, dễ thương
            // AnimatedSwitcher(
            //   duration: const Duration(milliseconds: 500),
            //   transitionBuilder: (child, animation) {
            //     return FadeTransition(
            //       opacity: animation,
            //       child: ScaleTransition(scale: animation, child: child),
            //     );
            //   },
            //   child:
            // ),
            Text(
              _currentText,
              key: ValueKey<String>(_currentText),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.pink.shade100,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            GhostWidget(
              size: 100,
              onTap: () {},
            ),
            ChibiPetWidget(),
            CosmicCritterWidget(
              state: CritterState.lowenergy,
            )
          ],
        ),
      ),
    );
  }
}

class CuteLoadingPainter extends CustomPainter {
  final Animation<double> animation;

  CuteLoadingPainter({required this.animation}) : super(repaint: animation);

  // Hàm tiện ích vẽ cỏ 4 lá
  void _drawClover(Canvas canvas, Paint paint, Offset center, double radius) {
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final angle = (pi / 2) * i + (pi / 4);
      final offset = Offset(
        center.dx + cos(angle) * radius * 0.6,
        center.dy + sin(angle) * radius * 0.6,
      );
      canvas.drawCircle(offset, radius * 0.5, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ghostY = center.dy - 40 + sin(animation.value * 2 * pi) * 5; // Bé ma bay lên xuống
    final ghostPaint = Paint()..color = Colors.white;
    final blushPaint = Paint()..color = Colors.pink.shade100;
    final eyePaint = Paint()..color = Colors.black87;
    final potPaint = Paint()..color = const Color(0xFF4A4A6A);
    final bubblePaint = Paint()
      ..color = Colors.purple.shade100.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // 1. Vẽ cái nồi/vạc
    final potRect = Rect.fromCenter(center: Offset(center.dx, center.dy + 50), width: 80, height: 60);
    canvas.drawRRect(RRect.fromRectAndRadius(potRect, const Radius.circular(15)), potPaint);
    final potTop = Rect.fromCenter(center: Offset(center.dx, center.dy + 25), width: 90, height: 20);
    canvas.drawRRect(RRect.fromRectAndRadius(potTop, const Radius.circular(10)), potPaint);


    // 2. Vẽ bé ma
    final ghostCenter = Offset(center.dx, ghostY);
    // Thân ma
    canvas.drawCircle(ghostCenter, 30, ghostPaint);
    final path = Path();
    path.moveTo(ghostCenter.dx - 30, ghostCenter.dy);
    path.quadraticBezierTo(ghostCenter.dx - 15, ghostCenter.dy + 30, ghostCenter.dx, ghostCenter.dy + 20);
    path.quadraticBezierTo(ghostCenter.dx + 15, ghostCenter.dy + 30, ghostCenter.dx + 30, ghostCenter.dy);
    canvas.drawPath(path, ghostPaint);
    // Mắt
    canvas.drawCircle(Offset(ghostCenter.dx - 10, ghostCenter.dy), 4, eyePaint);
    canvas.drawCircle(Offset(ghostCenter.dx + 10, ghostCenter.dy), 4, eyePaint);
    // Má hồng
    canvas.drawCircle(Offset(ghostCenter.dx - 15, ghostCenter.dy + 8), 5, blushPaint);
    canvas.drawCircle(Offset(ghostCenter.dx + 15, ghostCenter.dy + 8), 5, blushPaint);


    // 3. Vẽ các bong bóng bay lên từ nồi
    // Chúng ta sẽ tạo 3 bong bóng, mỗi cái có tốc độ, kích thước và vị trí khác nhau
    for (int i = 0; i < 3; i++) {
      final progress = (animation.value + i * 0.33) % 1.0; // Vòng lặp của mỗi bong bóng
      final bubbleY = (center.dy + 20) - progress * 100; // Bay từ nồi lên
      final bubbleX = center.dx + sin(progress * pi) * (20 * (i % 2 == 0 ? 1 : -1)); // Lắc qua lại
      final bubbleRadius = 10 + progress * 5;
      final bubbleOpacity = (1 - progress);

      bubblePaint.color = Colors.purple.shade100.withValues(alpha: bubbleOpacity * 0.6);
      final bubbleCenter = Offset(bubbleX, bubbleY);
      canvas.drawCircle(bubbleCenter, bubbleRadius, bubblePaint);

      // Vẽ icon bên trong bong bóng
      final iconPaint = Paint()..color = Colors.white.withValues(alpha: bubbleOpacity);
      final textStyle = TextStyle(color: iconPaint.color, fontSize: bubbleRadius * 1.2, fontWeight: FontWeight.bold);

      // Thay đổi icon theo từng bong bóng
      String iconSymbol = "?";
      if (i == 1) { // Bong bóng thứ 2 vẽ cỏ 4 lá
        _drawClover(canvas, iconPaint, bubbleCenter, bubbleRadius*0.7);
        continue; // Bỏ qua vẽ text
      } else if (i == 2) {
        iconSymbol = "✨";
      }

      final textPainter = TextUtils.createSafeTextPainter(
        text: iconSymbol,
        style: textStyle,
        textAlign: TextAlign.center,
      );
      textPainter.paint(canvas, Offset(bubbleCenter.dx - textPainter.width / 2, bubbleCenter.dy - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Luôn vẽ lại để animation mượt
  }
}