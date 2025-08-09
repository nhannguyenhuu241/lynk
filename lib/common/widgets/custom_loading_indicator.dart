part of widget;

enum LoadingEffectType {
  ripples,
  orbitingShapes,
  pulsingCore,
  bouncingDots,
}
class CustomLoadingIndicator extends StatefulWidget {
  final LoadingEffectType effectType;
  final Color color;
  final double size;

  const CustomLoadingIndicator({
    super.key,
    required this.effectType,
    this.color = Colors.blue,
    this.size = 50.0,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: _getDuration()),
      vsync: this,
    )..repeat();
  }

  int _getDuration() {
    switch (widget.effectType) {
      case LoadingEffectType.orbitingShapes:
        return 3000;
      case LoadingEffectType.pulsingCore:
        return 1500;
      case LoadingEffectType.bouncingDots:
        return 1200; // Tốc độ cho hiệu ứng 3 chấm
      case LoadingEffectType.ripples:
      default:
        return 2000;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _getPainter(),
          );
        },
      ),
    );
  }

  CustomPainter _getPainter() {
    switch (widget.effectType) {
      case LoadingEffectType.orbitingShapes:
        return _OrbitingShapesPainter(
          animation: _controller,
          color: widget.color,
        );
      case LoadingEffectType.pulsingCore:
        return _PulsingCorePainter(animation: _controller, color: widget.color);
      case LoadingEffectType.bouncingDots:
        return _BouncingDotsPainter(animation: _controller, color: widget.color);
      case LoadingEffectType.ripples:
      default:
        return _RipplesPainter(animation: _controller, color: widget.color);
    }
  }
}

//--- CÁC PAINTER CHO HIỆU ỨNG LOADING ---

class _RipplesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _RipplesPainter({required this.animation, required this.color}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    for (int wave = 3; wave >= 0; wave--) {
      _drawWave(canvas, rect, wave);
    }
  }

  void _drawWave(Canvas canvas, Rect rect, int wave) {
    final double radius = rect.width / 2 * (animation.value + wave) / 3;
    final double opacity = (1.0 - (animation.value + wave / 3).clamp(0.0, 1.0));
    final paint = Paint()..color = color.withValues(alpha: opacity);
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _OrbitingShapesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _OrbitingShapesPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  Path _createTrianglePath(double size) {
    return Path()
      ..moveTo(0, -size)
      ..lineTo(size * 0.87, size * 0.5)
      ..lineTo(-size * 0.87, size * 0.5)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    final shapePaint = Paint()..color = color..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final trailPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawCircle(center, radius, trailPaint);

    final particleCount = 5;
    final tailLength = 2 * pi * 0.8; // Độ dài của "đuôi"

    for (int i = 0; i < particleCount; i++) {
      final headAngle = animation.value * 2 * pi;
      final angle = headAngle - (i / particleCount) * tailLength;

      final pulse = (sin(angle * 2) + 1) / 2;
      final shapeSize = size.width / 15 * (0.7 + pulse * 0.6);

      final orbitX = center.dx + radius * cos(angle);
      final orbitY = center.dy + radius * sin(angle);

      canvas.save();
      canvas.translate(orbitX, orbitY);
      canvas.rotate(angle + pi / 2);

      final path = _createTrianglePath(shapeSize);
      glowPaint.color = color.withValues(alpha: 0.7 * (1 - i / particleCount));

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, shapePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _PulsingCorePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _PulsingCorePainter({required this.animation, required this.color}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pulseValue = sin(animation.value * pi);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * pulseValue)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.2 * pulseValue);
    canvas.drawCircle(center, size.width * 0.4, glowPaint);

    final corePaint = Paint()..color = color.withValues(alpha: 0.5 + pulseValue * 0.5);
    final coreRadius = size.width / 4 * (0.8 + pulseValue * 0.2);
    canvas.drawCircle(center, coreRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BouncingDotsPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final int dotCount = 3;

  _BouncingDotsPainter({required this.animation, required this.color}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final double dotRadius = size.width / 12;
    final double totalWidth = (dotCount * dotRadius * 2) + (dotRadius * (dotCount - 1) * 1.5);
    final double startX = (size.width - totalWidth) / 2 + dotRadius;
    final double y = size.height / 2;

    for (int i = 0; i < dotCount; i++) {
      final double delay = i * 0.15;
      final double t = (animation.value + (1.0 - delay)) % 1.0;

      final double bounce;
      if (t < 0.5) {
        bounce = Curves.easeOut.transform(t * 2);
      } else {
        bounce = Curves.easeIn.transform((1 - t) * 2);
      }
      final double x = startX + i * (dotRadius * 3.5);
      final double bounceHeight = -size.height / 3 * bounce;

      canvas.drawCircle(Offset(x, y + bounceHeight), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

