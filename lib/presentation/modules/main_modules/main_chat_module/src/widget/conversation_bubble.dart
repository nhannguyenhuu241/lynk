import 'package:flutter/animation.dart';

class ConversationBubble {
  final String text;
  final bool isUser;
  final Animation<double> animation;
  final bool isSinking;

  ConversationBubble({
    required this.text,
    required this.isUser,
    required Animation<double> riseAnimation,
  })  : animation = riseAnimation,
        isSinking = false;

  ConversationBubble._sinking({
    required this.text,
    required this.isUser,
    required this.animation,
  }) : isSinking = true;

  // Creates a new instance that is sinking
  ConversationBubble startSinking(Animation<double> sinkAnimation) {
    return ConversationBubble._sinking(
      text: text,
      isUser: isUser,
      animation: sinkAnimation,
    );
  }
}