import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lynk_an/common/utils/text_utils.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/conversation_bubble.dart';

class ConversationPainter extends CustomPainter {
  final List<ConversationBubble> bubbles;
  final Animation<double> rippleAnimation;

  ConversationPainter({required this.bubbles, required this.rippleAnimation})
      : super(repaint: Listenable.merge([rippleAnimation, ...bubbles.map((b) => b.animation)]));

  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final t = bubble.animation.value;
      final paint = Paint()..color = bubble.isUser ? const Color(0xFF005C4B) : const Color(0xFF2A3942);
      final textPainter = _prepareText(bubble.text, size.width * 0.6);

      double yPos;
      double scale;
      double opacity;

      if (bubble.isSinking) {
        yPos = lerpDouble(size.height * 0.6, size.height * 1.5, t)!;
        scale = lerpDouble(1.0, 0.2, t)!;
        opacity = lerpDouble(1.0, 0.0, t)!;
      } else {
        yPos = lerpDouble(size.height * 1.2, size.height * 0.6, t)!;
        scale = lerpDouble(0.1, 1.0, t)!;
        opacity = lerpDouble(0.0, 1.0, Curves.easeIn.transform(t))!;
      }

      paint.color = paint.color.withValues(alpha: opacity);

      final bubbleWidth = textPainter.width + 32;
      final bubbleHeight = textPainter.height + 20;
      final xPos = bubble.isUser ? size.width - bubbleWidth - 20 : 20.0;

      final rect = Rect.fromLTWH(xPos, yPos, bubbleWidth, bubbleHeight);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.scale(scale);
      canvas.translate(-rect.center.dx, -rect.center.dy);

      canvas.drawRRect(rrect, paint);
      textPainter.paint(canvas, rrect.outerRect.topLeft + const Offset(16, 10));

      canvas.restore();

      if (!bubble.isSinking && rippleAnimation.status == AnimationStatus.forward) {
        final rippleT = rippleAnimation.value;
        final ripplePaint = Paint()
          ..color = Colors.white.withValues(alpha: lerpDouble(0.2, 0.0, rippleT)!)
          ..style = PaintingStyle.stroke
          ..strokeWidth = lerpDouble(1.0, 4.0, rippleT)!;
        canvas.drawCircle(Offset(rect.center.dx, yPos), 50 * rippleT, ripplePaint);
      }
    }
  }

  TextPainter _prepareText(String text, double maxWidth) {
    final textStyle = const TextStyle(color: Colors.white, fontSize: 16);
    return TextUtils.createSafeTextPainter(
      text: text,
      style: textStyle,
      textAlign: TextAlign.left,
      maxWidth: maxWidth,
      forceKoreanFont: TextUtils.containsKorean(text),
    );
  }

  @override
  bool shouldRepaint(covariant ConversationPainter oldDelegate) {
    return true;
  }
}