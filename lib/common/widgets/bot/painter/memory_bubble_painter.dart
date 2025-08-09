import 'dart:math';

import 'package:flutter/material.dart';

class MemoryBubblePainter extends StatefulWidget {
  final Animation<double> animation;
  const MemoryBubblePainter({required this.animation, Key? key}) : super(key: key);

  @override
  State<MemoryBubblePainter> createState() => _MemoryBubblePainterState();
}

class _MemoryBubblePainterState extends State<MemoryBubblePainter> {
  late List<MemoryBubbleParticle> particles;

  @override
  void initState() {
    super.initState();
    particles = List.generate(15, (index) => MemoryBubbleParticle(Random()));
    widget.animation.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _Painter(particles: particles, t: widget.animation.value),
      child: Container(),
    );
  }
}

class _Painter extends CustomPainter {
  final List<MemoryBubbleParticle> particles;
  final double t;

  _Painter({required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);

    for (var particle in particles) {
      var yPos = size.height - (size.height * ((t + particle.offset) % 1.0));
      var xPos = particle.x * size.width;
      canvas.drawCircle(Offset(xPos, yPos), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MemoryBubbleParticle {
  final Random random;
  late double size;
  late double x;
  late double offset;

  MemoryBubbleParticle(this.random) {
    size = random.nextDouble() * 4.0 + 1.0;
    x = random.nextDouble();
    offset = random.nextDouble();
  }
}