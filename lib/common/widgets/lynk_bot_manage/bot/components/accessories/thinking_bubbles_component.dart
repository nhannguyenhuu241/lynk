import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Component vẽ bong bóng suy nghĩ cho trạng thái 'thinking'.
class ThinkingBubblesComponent extends PositionComponent {
  final bubblePaint = Paint();
  double animationTime = 0.0;
  double componentOpacity = 1.0;

  ThinkingBubblesComponent({required Vector2 size}) {
    this.size = size;
    // SỬA LỖI: Đồng bộ anchor về topLeft giống các component khác.
    anchor = Anchor.topLeft;
  }

  @override
  void render(Canvas canvas) {
    if (componentOpacity <= 0) return;

    // Logic vẽ vẫn sử dụng center, tương thích với anchor mới.
    final center = size.toOffset() / 2;
    final radius = size.x / 2;
    final time = animationTime;

    // Small bubble
    final smallBubbleProgress = (sin(time * 2.0) + 1) / 2;
    final smallBubbleRadius = radius * 0.05 * smallBubbleProgress;
    final smallBubbleOffset = Offset(center.dx + radius * 0.5, center.dy - radius * 0.8 - (smallBubbleProgress * 10));
    bubblePaint.color = Colors.white.withValues(alpha: 0.7 * smallBubbleProgress * componentOpacity);
    canvas.drawCircle(smallBubbleOffset, smallBubbleRadius, bubblePaint);

    // Medium bubble
    final medBubbleProgress = (sin(time * 2.0 - 1.0) + 1) / 2;
    final medBubbleRadius = radius * 0.08 * medBubbleProgress;
    final medBubbleOffset = Offset(center.dx + radius * 0.7, center.dy - radius * 1.0 - (medBubbleProgress * 15));
    bubblePaint.color = Colors.white.withValues(alpha: 0.8 * medBubbleProgress * componentOpacity);
    canvas.drawCircle(medBubbleOffset, medBubbleRadius, bubblePaint);

    // Large bubble
    final largeBubbleProgress = (sin(time * 2.0 - 2.0) + 1) / 2;
    final largeBubbleRadius = radius * 0.11 * largeBubbleProgress;
    final largeBubbleOffset = Offset(center.dx + radius * 1.0, center.dy - radius * 1.3 - (largeBubbleProgress * 20));
    bubblePaint.color = Colors.white.withValues(alpha: 0.9 * largeBubbleProgress * componentOpacity);
    canvas.drawCircle(largeBubbleOffset, largeBubbleRadius, bubblePaint);
  }
}
