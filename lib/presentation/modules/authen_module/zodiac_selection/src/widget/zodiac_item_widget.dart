import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import '../model/zodiac_model.dart';

class ZodiacItemWidget extends StatefulWidget {
  final ZodiacModel zodiac;
  final bool isSelected;
  final VoidCallback onTap;
  final int index; // For staggered animation

  const ZodiacItemWidget({
    super.key,
    required this.zodiac,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<ZodiacItemWidget> createState() => _ZodiacItemWidgetState();
}

class _ZodiacItemWidgetState extends State<ZodiacItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
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
      curve: Curves.easeInOut,
    ));

    // Staggered animation delay
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    // Safely dispose animation controller
    try {
      _animationController.dispose();
    } catch (e) {
      // Handle disposal error gracefully
      debugPrint('Error disposing zodiac item animation controller: $e');
    }
    super.dispose();
  }

  Color _getZodiacColor() {
    // Map zodiac to theme colors
    switch (widget.zodiac.id) {
      case 'aries':
      case 'leo':
      case 'sagittarius':
        return AppColors.coral;
      case 'taurus':
      case 'virgo':
      case 'capricorn':
        return AppColors.mint;
      case 'gemini':
      case 'libra':
      case 'aquarius':
        return AppColors.sunnyYellow;
      case 'cancer':
      case 'scorpio':
      case 'pisces':
        return AppColors.lavender;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildZodiacItem(),
          ),
        );
      },
    );
  }

  Widget _buildZodiacItem() {
    final zodiacColor = _getZodiacColor();
    
    return Semantics(
      label: 'Cung mệnh ${widget.zodiac.nameVi}, ${widget.zodiac.dateRange}',
      hint: widget.isSelected 
          ? 'Đã chọn ${widget.zodiac.nameVi}, nhấn để bỏ chọn'
          : 'Nhấn để chọn cung mệnh ${widget.zodiac.nameVi}',
      button: true,
      selected: widget.isSelected,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: widget.isSelected
              ? LinearGradient(
                  colors: [
                    zodiacColor,
                    zodiacColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    AppColors.white,
                    AppColors.neutral50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: widget.isSelected ? zodiacColor : AppColors.neutral300,
            width: widget.isSelected ? 3 : 1,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: zodiacColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zodiac Symbol
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: widget.isSelected ? 50 : 40,
              height: widget.isSelected ? 50 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected 
                    ? AppColors.white.withValues(alpha: 0.9)
                    : zodiacColor.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  widget.zodiac.symbol,
                  style: TextStyle(
                    fontSize: widget.isSelected ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected ? zodiacColor : AppColors.neutral700,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Zodiac Name
            Text(
              widget.zodiac.nameVi,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isSelected ? AppColors.white : AppColors.neutral900,
                fontFamily: AppFonts.font,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Date Range
            Text(
              widget.zodiac.dateRange,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: widget.isSelected 
                    ? AppColors.white.withValues(alpha: 0.9)
                    : AppColors.neutral600,
                fontFamily: AppFonts.font,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      ),
    );
  }
}