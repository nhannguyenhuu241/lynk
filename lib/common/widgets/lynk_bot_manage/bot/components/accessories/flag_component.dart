import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../enum/avatar_expressions.dart';

class FlagComponent extends PositionComponent {
  final FlagType flagType;
  final double flagSize;
  late Paint flagPaint;
  late Paint polePaint;
  
  double componentOpacity = 1.0;

  FlagComponent({
    required this.flagType,
    this.flagSize = 40.0,
    super.position,
  }) : super(size: Vector2(flagSize * 1.5, flagSize));

  @override
  void onLoad() {
    super.onLoad();
    flagPaint = Paint()..style = PaintingStyle.fill;
    polePaint = Paint()
      ..color = const Color(0xFF8B4513) // Brown color for pole
      ..style = PaintingStyle.fill;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (componentOpacity <= 0) return;
    
    // Set opacity for pole
    polePaint.color = polePaint.color.withValues(alpha: componentOpacity);
    
    // Draw flag pole
    // final poleRect = Rect.fromLTWH(0, 0, 3, size.y);
    // canvas.drawRect(poleRect, polePaint);
    
    // Draw flag based on type
    final flagRect = Rect.fromLTWH(3, 0, size.x - 3, size.y * 0.6);
    _drawFlag(canvas, flagRect);
  }

  void _drawFlag(Canvas canvas, Rect flagRect) {
    switch (flagType) {
      case FlagType.vietnam:
        _drawVietnamFlag(canvas, flagRect);
        break;
      case FlagType.usa:
        _drawUSAFlag(canvas, flagRect);
        break;
      case FlagType.southKorea:
        _drawSouthKoreaFlag(canvas, flagRect);
        break;
    }
  }

  void _drawVietnamFlag(Canvas canvas, Rect rect) {
    // Red background
    flagPaint.color = const Color(0xFFDA020E).withValues(alpha: componentOpacity);
    canvas.drawRect(rect, flagPaint);
    
    // Yellow star
    flagPaint.color = const Color(0xFFFFFF00).withValues(alpha: componentOpacity);
    final center = rect.center;
    final starSize = rect.height * 0.4;
    _drawSimpleStar(canvas, center, starSize);
  }

  void _drawUSAFlag(Canvas canvas, Rect rect) {
    // Draw 13 stripes (7 red, 6 white)
    final stripeHeight = rect.height / 13;
    
    for (int i = 0; i < 13; i++) {
      flagPaint.color = (i % 2 == 0 ? const Color(0xFFB22234) : Colors.white).withValues(alpha: componentOpacity);
      final stripeRect = Rect.fromLTWH(
        rect.left,
        rect.top + i * stripeHeight,
        rect.width,
        stripeHeight,
      );
      canvas.drawRect(stripeRect, flagPaint);
    }
    
    // Blue canton (union)
    flagPaint.color = const Color(0xFF3C3B6E).withValues(alpha: componentOpacity);
    final cantonRect = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width * 0.4,
      rect.height * 0.54, // 7 stripes height
    );
    canvas.drawRect(cantonRect, flagPaint);
    
    // Draw simplified stars
    flagPaint.color = Colors.white.withValues(alpha: componentOpacity);
    final starSize = cantonRect.width * 0.08;
    
    // 5 rows with alternating 6 and 5 stars
    for (int row = 0; row < 9; row++) {
      final starsInRow = (row % 2 == 0) ? 6 : 5;
      final startX = cantonRect.left + (cantonRect.width / (starsInRow + 1));
      final y = cantonRect.top + (cantonRect.height / 10) * (row + 1);
      
      for (int star = 0; star < starsInRow; star++) {
        final x = startX + (cantonRect.width / (starsInRow + 1)) * star;
        _drawSimpleStar(canvas, Offset(x, y), starSize);
      }
    }
  }

  void _drawSouthKoreaFlag(Canvas canvas, Rect rect) {
    // White background
    flagPaint.color = Colors.white.withValues(alpha: componentOpacity);
    canvas.drawRect(rect, flagPaint);
    
    final center = rect.center;
    final radius = rect.height * 0.15;
    
    // Draw Taegeuk (yin-yang symbol)
    _drawTaegeuk(canvas, center, radius);
    
    // Draw four trigrams
    _drawTrigrams(canvas, rect);
  }
  
  void _drawTaegeuk(Canvas canvas, Offset center, double radius) {
    // Blue (yin) semicircle
    flagPaint.color = const Color(0xFF003478).withValues(alpha: componentOpacity);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -π/2 (start from top)
      3.14159, // π radians (180 degrees)
      true,
      flagPaint,
    );
    
    // Red (yang) semicircle
    flagPaint.color = const Color(0xFFCD2E3A).withValues(alpha: componentOpacity);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.5708, // π/2 (start from bottom)
      3.14159, // π radians (180 degrees)
      true,
      flagPaint,
    );
    
    // Small circles in center
    final smallRadius = radius * 0.25;
    
    // Red dot in blue area
    flagPaint.color = const Color(0xFFCD2E3A).withValues(alpha: componentOpacity);
    canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.5), smallRadius, flagPaint);
    
    // Blue dot in red area
    flagPaint.color = const Color(0xFF003478).withValues(alpha: componentOpacity);
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.5), smallRadius, flagPaint);
  }
  
  void _drawTrigrams(Canvas canvas, Rect rect) {
    final center = rect.center;
    final distance = rect.width * 0.25;
    final lineWidth = 2.0;
    final lineLength = rect.width * 0.08;
    final lineSpacing = rect.height * 0.02;
    
    // 건 (☰) - top left
    _drawTrigram(canvas, Offset(center.dx - distance * 0.7, center.dy - distance * 0.7), 
                 lineLength, lineWidth, lineSpacing, [true, true, true]);
    
    // 곤 (☷) - bottom right  
    _drawTrigram(canvas, Offset(center.dx + distance * 0.7, center.dy + distance * 0.7), 
                 lineLength, lineWidth, lineSpacing, [false, false, false]);
    
    // 감 (☵) - top right
    _drawTrigram(canvas, Offset(center.dx + distance * 0.7, center.dy - distance * 0.7), 
                 lineLength, lineWidth, lineSpacing, [false, true, false]);
    
    // 리 (☲) - bottom left
    _drawTrigram(canvas, Offset(center.dx - distance * 0.7, center.dy + distance * 0.7), 
                 lineLength, lineWidth, lineSpacing, [true, false, true]);
  }
  
  void _drawTrigram(Canvas canvas, Offset center, double lineLength, double lineWidth, 
                    double lineSpacing, List<bool> lines) {
    flagPaint.color = Colors.black.withValues(alpha: componentOpacity);
    flagPaint.strokeWidth = lineWidth;
    flagPaint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 3; i++) {
      final y = center.dy + (i - 1) * lineSpacing;
      
      if (lines[i]) {
        // Solid line
        canvas.drawLine(
          Offset(center.dx - lineLength / 2, y),
          Offset(center.dx + lineLength / 2, y),
          flagPaint,
        );
      } else {
        // Broken line (two segments)
        final gap = lineLength * 0.2;
        canvas.drawLine(
          Offset(center.dx - lineLength / 2, y),
          Offset(center.dx - gap / 2, y),
          flagPaint,
        );
        canvas.drawLine(
          Offset(center.dx + gap / 2, y),
          Offset(center.dx + lineLength / 2, y),
          flagPaint,
        );
      }
    }
    
    // Reset paint style
    flagPaint.style = PaintingStyle.fill;
  }

  void _drawStar(Canvas canvas, Offset center, double size) {
    final path = Path();
    final angle = 3.14159 * 2 / 5; // 72 degrees in radians
    
    for (int i = 0; i < 5; i++) {
      final x = center.dx + size * 0.5 * (i % 2 == 0 ? 1 : 0.4) * 
               (i == 0 ? 0 : (i % 2 == 0 ? 
               -0.951 * (i ~/ 2) + 0.309 * ((i ~/ 2) % 2 == 0 ? 1 : -1) * (i ~/ 2) :
               -0.588 * ((i - 1) ~/ 2) + 0.809 * (((i - 1) ~/ 2) % 2 == 0 ? 1 : -1) * ((i - 1) ~/ 2)));
      final y = center.dy + size * 0.5 * (i % 2 == 0 ? 1 : 0.4) * 
               (i == 0 ? -1 : (i % 2 == 0 ? 
               0.309 * (i ~/ 2) + 0.951 * ((i ~/ 2) % 2 == 0 ? 1 : -1) * (i ~/ 2) :
               0.809 * ((i - 1) ~/ 2) + 0.588 * (((i - 1) ~/ 2) % 2 == 0 ? 1 : -1) * ((i - 1) ~/ 2)));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, flagPaint);
  }

  // Simplified star drawing
  void _drawSimpleStar(Canvas canvas, Offset center, double size) {
    final path = Path();
    
    // Simple 5-pointed star
    final points = <Offset>[
      Offset(center.dx, center.dy - size * 0.5), // Top
      Offset(center.dx + size * 0.2, center.dy - size * 0.1), // Top right inner
      Offset(center.dx + size * 0.5, center.dy - size * 0.1), // Right
      Offset(center.dx + size * 0.2, center.dy + size * 0.1), // Bottom right inner
      Offset(center.dx + size * 0.3, center.dy + size * 0.5), // Bottom right
      Offset(center.dx, center.dy + size * 0.2), // Bottom inner
      Offset(center.dx - size * 0.3, center.dy + size * 0.5), // Bottom left
      Offset(center.dx - size * 0.2, center.dy + size * 0.1), // Bottom left inner
      Offset(center.dx - size * 0.5, center.dy - size * 0.1), // Left
      Offset(center.dx - size * 0.2, center.dy - size * 0.1), // Top left inner
    ];
    
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    canvas.drawPath(path, flagPaint);
  }

}