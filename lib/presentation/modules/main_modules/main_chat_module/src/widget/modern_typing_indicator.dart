import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';

class ModernTypingIndicator extends StatefulWidget {
  final Color? backgroundColor;
  final Color? dotColor;
  final double size;
  final Duration animationDuration;

  const ModernTypingIndicator({
    Key? key,
    this.backgroundColor,
    this.dotColor,
    this.size = 60.0,
    this.animationDuration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<ModernTypingIndicator> createState() => _ModernTypingIndicatorState();
}

class _ModernTypingIndicatorState extends State<ModernTypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Create staggered animations for each dot
    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          0.6 + index * 0.2,
          curve: Curves.easeInOut,
        ),
      ));
    });

    _animationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final backgroundColor = widget.backgroundColor ?? AppColors.neutral50;
    final dotColor = widget.dotColor ?? AppColors.neutral600;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size * 0.3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size * 0.3),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(widget.size * 0.3),
                    border: Border.all(
                      color: AppColors.neutral300.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neutral400.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return AnimatedBuilder(
                              animation: _dotAnimations[index],
                              builder: (context, child) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: widget.size * 0.02,
                                  ),
                                  child: Transform.scale(
                                    scale: _dotAnimations[index].value,
                                    child: Container(
                                      width: widget.size * 0.08,
                                      height: widget.size * 0.08,
                                      decoration: BoxDecoration(
                                        color: dotColor.withValues(alpha: 
                                          0.6 + (_dotAnimations[index].value * 0.4),
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: dotColor.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        );
                      },
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
}

/// Enhanced typing indicator with cosmic theme
class CosmicTypingIndicator extends StatefulWidget {
  final double size;
  final Duration animationDuration;

  const CosmicTypingIndicator({
    Key? key,
    this.size = 70.0,
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<CosmicTypingIndicator> createState() => _CosmicTypingIndicatorState();
}

class _CosmicTypingIndicatorState extends State<CosmicTypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _waveController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _waveController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _glowController]),
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size * 0.6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.size * 0.3),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.size * 0.3),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.magic.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 
                        0.2 * _glowAnimation.value,
                      ),
                      blurRadius: 16 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.3;
                      final progress = (_waveAnimation.value + delay) % 1.0;
                      final scale = 0.6 + (0.4 * (1 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0));
                      
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: widget.size * 0.025,
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: widget.size * 0.1,
                            height: widget.size * 0.1,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.9),
                                  AppColors.magic.withValues(alpha: 0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}