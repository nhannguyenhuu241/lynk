import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';

class LiquidGlassInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback? onVoicePressed;
  final bool isEnabled;

  const LiquidGlassInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onSend,
    this.onVoicePressed,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<LiquidGlassInput> createState() => _LiquidGlassInputState();
}

class _LiquidGlassInputState extends State<LiquidGlassInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shimmerAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to text changes
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }
  
  void _handleButtonPress() {
    if (_hasText) {
      widget.onSend();
    } else {
      widget.onVoicePressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        enabled: widget.isEnabled,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontSize: AppTextSizes.title,
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 8,
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: Colors.black.withValues(alpha: 0.5),
                            fontSize: AppTextSizes.title,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => widget.onSend(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: widget.isEnabled ? _handleButtonPress : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: Container(
          key: ValueKey(_hasText),
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _hasText && widget.isEnabled
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.6),
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !_hasText || !widget.isEnabled 
                ? Colors.white.withValues(alpha: 0.1) 
                : null,
            border: Border.all(
              color: widget.isEnabled
                  ? (_hasText 
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.3))
                  : Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: _hasText && widget.isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: _hasText
              ? Icon(
                  Icons.send_rounded,
                  color: widget.isEnabled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  size: 22,
                )
              : Image.asset(
                  'assets/icons/icon_voice.png',
                  width: 24,
                  height: 24,
                  color: widget.isEnabled
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.3),
                ),
        ),
      ),
    );
  }
}