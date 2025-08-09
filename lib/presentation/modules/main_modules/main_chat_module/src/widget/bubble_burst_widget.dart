import 'dart:math';

import 'package:flutter/material.dart';

class BubbleBurstWidget extends StatefulWidget {
  final Animation<double> animation;
  final GlobalKey bubbleKey;
  final bool isUser;

  const BubbleBurstWidget({
    Key? key,
    required this.animation,
    required this.bubbleKey,
    required this.isUser,
  }) : super(key: key);

  @override
  State<BubbleBurstWidget> createState() => _BubbleBurstWidgetState();
}

class _BubbleBurstWidgetState extends State<BubbleBurstWidget> {
  Offset? _offset;
  Size? _size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = widget.bubbleKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _offset = renderBox.localToGlobal(Offset.zero);
          _size = renderBox.size;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_offset == null || _size == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: _offset!.dx,
      top: _offset!.dy,
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          return CustomPaint(
            size: _size!,
            painter: BubbleBurstPainter(
              progress: widget.animation.value,
              // Sử dụng màu trắng mờ cho các mảnh vỡ để trông giống thủy tinh
              color: Colors.white.withValues(alpha: 0.7),
            ),
          );
        },
      ),
    );
  }
}

class BubbleBurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<_GlassShard> shards;

  BubbleBurstPainter({required this.progress, required this.color})
  // Tạo ra các mảnh vỡ thay vì hạt tròn
      : shards = List.generate(40, (index) => _GlassShard(color));

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;

    final center = size.center(Offset.zero);

    for (var shard in shards) {
      // Cập nhật vị trí và góc xoay của mảnh vỡ
      shard.update(progress, center);

      // Lưu trạng thái canvas hiện tại
      canvas.save();

      // Di chuyển canvas đến vị trí của mảnh vỡ
      canvas.translate(shard.position.dx, shard.position.dy);
      // Xoay canvas
      canvas.rotate(shard.rotation);

      // Vẽ đường dẫn (path) của mảnh vỡ
      final paint = Paint()
        ..color = shard.color.withValues(alpha: 1.0 - progress) // Mờ dần khi bay xa
        ..style = PaintingStyle.fill;

      canvas.drawPath(shard.path, paint);

      // Phục hồi lại trạng thái canvas trước đó
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant BubbleBurstPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}


// Lớp mới để định nghĩa một mảnh vỡ thủy tinh
class _GlassShard {
  final Color color;
  final double speed;
  final double angle;
  final Path path; // Hình dạng của mảnh vỡ
  final double rotationSpeed;
  final double initialRotation;

  Offset position = Offset.zero;
  double rotation = 0;

  _GlassShard(this.color)
      : speed = Random().nextDouble() * 80 + 40,
        angle = Random().nextDouble() * 2 * pi,
        rotationSpeed = (Random().nextDouble() - 0.5) * 2 * pi, // Tốc độ xoay ngẫu nhiên
        initialRotation = Random().nextDouble() * 2 * pi,
        path = _createRandomShardPath();

  // Hàm tĩnh để tạo một hình dạng mảnh vỡ ngẫu nhiên
  static Path _createRandomShardPath() {
    final path = Path();
    final random = Random();
    final size = random.nextDouble() * 12 + 4; // Kích thước mảnh vỡ
    final vertexCount = random.nextInt(3) + 3; // Mảnh vỡ có từ 3 đến 5 cạnh

    final points = List.generate(vertexCount, (index) {
      final angle = (index / vertexCount) * 2 * pi;
      final radius = (random.nextDouble() * 0.5 + 0.5) * size;
      return Offset(cos(angle) * radius, sin(angle) * radius);
    });

    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    return path;
  }


  void update(double progress, Offset center) {
    final currentDistance = progress * speed;
    position = Offset(
      center.dx + cos(angle) * currentDistance,
      center.dy + sin(angle) * currentDistance,
    );
    // Cập nhật góc xoay dựa trên tiến trình
    rotation = initialRotation + rotationSpeed * progress;
  }
}