import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/widgets/widget.dart';

class ZodiacChatBubble extends StatefulWidget {
  final String message;
  final bool isTyping;
  final VoidCallback? onTypingComplete;

  const ZodiacChatBubble({
    super.key,
    required this.message,
    this.isTyping = false,
    this.onTypingComplete,
  });

  @override
  State<ZodiacChatBubble> createState() => _ZodiacChatBubbleState();
}

class _ZodiacChatBubbleState extends State<ZodiacChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    // Safely dispose animation controller
    try {
      _animationController.dispose();
    } catch (e) {
      // Handle disposal error gracefully
      debugPrint('Error disposing chat bubble animation controller: $e');
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ZodiacChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message) {
      // Restart animation when message changes
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildChatBubble(),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.85,
        minHeight: 60,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.getMintGradient(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glassmorphism overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.white.withValues(alpha: 0.2),
                  AppColors.white.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: AppSizes.paddingAll16,
            child: widget.isTyping
                ? AnimatedTypingText(
                    text: widget.message,
                    color: AppColors.white,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.font,
                      height: 1.4,
                    ),
                    onComplete: widget.onTypingComplete,
                    typingSpeed: const Duration(milliseconds: 50),
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  )
                : Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      fontFamily: AppFonts.font,
                      height: 1.4,
                    ),
                  ),
          ),
          
          // Shine effect
          if (widget.isTyping)
            Positioned.fill(
              child: _buildShineEffect(),
            ),
        ],
      ),
    );
  }

  Widget _buildShineEffect() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
            ),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.white.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: const [0.3, 0.5, 0.7],
              transform: GradientRotation(_animationController.value * 2 * 3.14159),
            ),
          ),
        );
      },
    );
  }
}