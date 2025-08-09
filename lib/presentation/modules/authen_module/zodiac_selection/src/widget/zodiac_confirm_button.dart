import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';

class ZodiacConfirmButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final String text;

  const ZodiacConfirmButton({
    super.key,
    required this.isEnabled,
    this.onPressed,
    this.text = 'Xác nhận cung mệnh',
  });

  @override
  State<ZodiacConfirmButton> createState() => _ZodiacConfirmButtonState();
}

class _ZodiacConfirmButtonState extends State<ZodiacConfirmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    // Safely dispose animation controller
    try {
      _animationController.dispose();
    } catch (e) {
      // Handle disposal error gracefully
      debugPrint('Error disposing confirm button animation controller: $e');
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ZodiacConfirmButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isEnabled ? _pulseAnimation.value : 1.0,
          child: Semantics(
            button: true,
            enabled: widget.isEnabled,
            label: widget.text,
            hint: widget.isEnabled 
                ? 'Nhấn để xác nhận cung mệnh đã chọn' 
                : 'Chọn một cung mệnh trước để có thể tiếp tục',
            child: GestureDetector(
            onTapDown: widget.isEnabled ? _onTapDown : null,
            onTapUp: widget.isEnabled ? _onTapUp : null,
            onTapCancel: widget.isEnabled ? _onTapCancel : null,
            onTap: widget.isEnabled ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()
                ..scale(_isPressed ? 0.95 : 1.0),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: widget.isEnabled
                      ? AppTheme.getCoralGradient()
                      : LinearGradient(
                          colors: [
                            AppColors.neutral300,
                            AppColors.neutral400,
                          ],
                        ),
                  boxShadow: widget.isEnabled
                      ? [
                          BoxShadow(
                            color: AppColors.coral.withValues(alpha: _glowAnimation.value),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Stack(
                  children: [
                    // Glassmorphism overlay
                    if (widget.isEnabled)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
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
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isEnabled) ...[
                            Icon(
                              Icons.star_rounded,
                              color: AppColors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.isEnabled 
                                  ? AppColors.white 
                                  : AppColors.neutral600,
                              fontFamily: AppFonts.font,
                            ),
                          ),
                          
                          if (widget.isEnabled) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Shimmer effect when enabled
                    if (widget.isEnabled)
                      _buildShimmerEffect(),
                  ],
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.white.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_animationController.value * 2 * 3.14159),
            ),
          ),
        );
      },
    );
  }
}