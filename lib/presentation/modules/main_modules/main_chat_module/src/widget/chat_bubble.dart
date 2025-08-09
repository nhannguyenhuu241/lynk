import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/widgets/widget.dart';

class ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final Color? userBubbleColor;
  final Color? botBubbleColor;
  final Color? textColor;
  final Duration animationDuration;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
    this.userBubbleColor,
    this.botBubbleColor,
    this.textColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    // Start entrance animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Modern color scheme with better contrast
    final Color effectiveUserColor = widget.userBubbleColor ?? AppColors.primary;
    final Color effectiveBotColor = widget.botBubbleColor ?? AppColors.neutral100;
    final Color effectiveTextColor = widget.textColor ?? 
        AppTheme.getTextPrimary(context);

    final bubbleColor = widget.isUser ? effectiveUserColor : effectiveBotColor;
    
    // Modern opacity levels for better readability
    final double backgroundOpacity = widget.isUser 
        ? 0.85 
        : 0.95;
    
    final glassColor = bubbleColor.withValues(alpha: backgroundOpacity);

    // Adaptive corner radius based on modern design patterns
    final double cornerRadius = _getAdaptiveCornerRadius();
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              onTapDown: (_) => _handleTapDown(),
              onTapUp: (_) => _handleTapUp(),
              onTapCancel: () => _handleTapUp(),
              child: AnimatedScale(
                scale: _isPressed ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                    minWidth: 60,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSizes.minPadding,
                    vertical: AppSizes.minPadding / 2,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getHorizontalPadding(),
                          vertical: _getVerticalPadding(),
                        ),
                        decoration: BoxDecoration(
                          color: glassColor,
                          borderRadius: BorderRadius.circular(cornerRadius),
                          gradient: _getModernGradient(),
                          border: Border.all(
                            color: _getBorderColor(),
                            width: widget.isUser ? 0.0 : 1.0,
                          ),
                          boxShadow: _getModernShadow(),
                        ),
                        child: CustomText(
                          text: widget.text,
                          color: widget.isUser 
                              ? AppColors.white
                              : effectiveTextColor,
                          fontSize: AppTextSizes.body,
                          fontWeight: widget.isUser ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTapDown() {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp() {
    setState(() {
      _isPressed = false;
    });
  }

  double _getAdaptiveCornerRadius() {
    // Modern messaging apps use 18-20px for most bubbles
    final textLength = widget.text.length;
    if (textLength < 20) return 20.0;
    if (textLength < 50) return 18.0;
    return 16.0;
  }

  double _getHorizontalPadding() {
    final textLength = widget.text.length;
    if (textLength < 10) return 16.0;
    if (textLength < 30) return 18.0;
    return 20.0;
  }

  double _getVerticalPadding() {
    return widget.text.contains('\n') ? 14.0 : 12.0;
  }

  LinearGradient? _getModernGradient() {
    if (!widget.isUser) return null;
    
    return LinearGradient(
      colors: [
        AppColors.primary,
        AppColors.primaryDark,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _getBorderColor() {
    if (widget.isUser) return Colors.transparent;
    
    return AppColors.neutral300.withValues(alpha: 0.6);
  }

  List<BoxShadow> _getModernShadow() {
    if (!widget.isUser) {
      return [
        BoxShadow(
          color: AppColors.neutral400.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.15),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

/// Dữ liệu cho hiệu ứng vỡ bong bóng
class BubbleBurstData {
  final GlobalKey key;
  final String text;
  final bool isUser;
  BubbleBurstData({required this.key, required this.text, required this.isUser});
}