import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';

class MysticalSuggestionChips extends StatefulWidget {
  final Function(String) onSuggestionTap;
  final bool isVisible;
  final String language;

  const MysticalSuggestionChips({
    Key? key,
    required this.onSuggestionTap,
    this.isVisible = true,
    this.language = 'vi',
  }) : super(key: key);

  @override
  State<MysticalSuggestionChips> createState() => _MysticalSuggestionChipsState();
}

class _MysticalSuggestionChipsState extends State<MysticalSuggestionChips> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(MysticalSuggestionChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getSuggestionsForLanguage(String language) {
    switch (language) {
      case 'vi':
        return [
          {
            'text': 'Ăn gì nè?',
            'icon': Icons.restaurant_rounded,
            'gradient': [AppColors.coral, AppColors.peach],
          },
          {
            'text': 'Mặc gì ta?',
            'icon': Icons.checkroom_rounded,
            'gradient': [AppColors.lavender, AppColors.magicLight],
          },
          {
            'text': 'Tối nay sao nè?',
            'icon': Icons.star_rounded,
            'gradient': [AppColors.sunsetTop, AppColors.sunriseMiddle],
          },
          {
            'text': 'Tôi hợp màu nào?',
            'icon': Icons.palette_rounded,
            'gradient': [AppColors.mint, AppColors.skyBlue],
          },
          {
            'text': 'Có duyên không?',
            'icon': Icons.favorite_rounded,
            'gradient': [AppColors.sunsetTop, AppColors.sunsetMiddle],
          },
        ];
      case 'en':
        return [
          {
            'text': 'What to eat?',
            'icon': Icons.restaurant_rounded,
            'gradient': [AppColors.coral, AppColors.peach],
          },
          {
            'text': 'What to wear?',
            'icon': Icons.checkroom_rounded,
            'gradient': [AppColors.lavender, AppColors.magicLight],
          },
          {
            'text': 'Tonight\'s stars?',
            'icon': Icons.star_rounded,
            'gradient': [AppColors.sunsetTop, AppColors.sunriseMiddle],
          },
          {
            'text': 'Lucky color?',
            'icon': Icons.palette_rounded,
            'gradient': [AppColors.mint, AppColors.skyBlue],
          },
          {
            'text': 'Love fortune?',
            'icon': Icons.favorite_rounded,
            'gradient': [AppColors.sunsetTop, AppColors.sunsetMiddle],
          },
        ];
      case 'ko':
        return [
          {
            'text': '뭘 먹을까?',
            'icon': Icons.restaurant_rounded,
            'gradient': [AppColors.coral, AppColors.peach],
          },
          {
            'text': '뭘 입을까?',
            'icon': Icons.checkroom_rounded,
            'gradient': [AppColors.lavender, AppColors.magicLight],
          },
          {
            'text': '오늘 운세는?',
            'icon': Icons.star_rounded,
            'gradient': [AppColors.sunsetTop, AppColors.sunriseMiddle],
          },
          {
            'text': '행운의 색은?',
            'icon': Icons.palette_rounded,
            'gradient': [AppColors.mint, AppColors.skyBlue],
          },
          {
            'text': '연애운은?',
            'icon': Icons.favorite_rounded,
            'gradient': [AppColors.sunsetTop, AppColors.sunsetMiddle],
          },
        ];
      default:
        return [
          {
            'text': 'Ăn gì nè?',
            'icon': Icons.restaurant_rounded,
            'gradient': [AppColors.coral, AppColors.peach],
          },
          {
            'text': 'Mặc gì hả?',
            'icon': Icons.checkroom_rounded,
            'gradient': [AppColors.lavender, AppColors.magicLight],
          },
          {
            'text': 'Tối nay sao nè?',
            'icon': Icons.star_rounded,
            'gradient': [AppColors.sunriseTop, AppColors.sunriseMiddle],
          },
          {
            'text': 'Màu gì hợp?',
            'icon': Icons.palette_rounded,
            'gradient': [AppColors.mint, AppColors.skyBlue],
          },
          {
            'text': 'Có duyên không?',
            'icon': Icons.favorite_rounded,
            'gradient': [AppColors.sunsetTop, AppColors.sunsetMiddle],
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final suggestions = _getSuggestionsForLanguage(widget.language);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: 38, // Smaller height
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < suggestions.length - 1 ? 8 : 0,
                    ),
                    child: _buildLiquidGlassChip(
                      text: suggestion['text'],
                      icon: suggestion['icon'],
                      gradientColors: suggestion['gradient'],
                      onTap: () => widget.onSuggestionTap(suggestion['text']),
                      index: index,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiquidGlassChip({
    required String text,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int index,
  }) {
    final isHovered = _hoveredIndex == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(
            begin: 0.0,
            end: isHovered ? 1.0 : 0.0,
          ),
          builder: (context, hoverValue, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.maxPadding),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10 + (hoverValue * 5),
                    sigmaY: 10 + (hoverValue * 5),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gradientColors[0].withValues(alpha: 0.15 + (hoverValue * 0.2)),
                          gradientColors[1].withValues(alpha: 0.2 + (hoverValue * 0.2)),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3 + (hoverValue * 0.2)),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.2 * hoverValue),
                          blurRadius: 12,
                          spreadRadius: -2,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween<double>(
                            begin: 14.0,
                            end: isHovered ? 16.0 : 14.0,
                          ),
                          builder: (context, iconSize, child) {
                            return Icon(
                              icon,
                              size: iconSize,
                              color: gradientColors[0],
                              shadows: [
                                Shadow(
                                  color: gradientColors[0],
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          text,
                          style: TextStyle(
                            color: gradientColors[0],
                            fontSize: AppTextSizes.body, // Smaller font size
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: gradientColors[0].withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}