import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import '../model/zodiac_model.dart';

class ZodiacChipWidget extends StatelessWidget {
  final ZodiacModel zodiac;
  final bool isSelected;
  final VoidCallback onTap;

  const ZodiacChipWidget({
    super.key,
    required this.zodiac,
    required this.isSelected,
    required this.onTap,
  });

  /// Lấy màu gradient dựa trên index trong danh sách
  List<Color> _getGradientColors() {
    final index = ZodiacModel.allZodiacs.indexWhere((z) => z.id == zodiac.id);
    final gradientStrings = zodiac.getChipGradient(index);
    
    return gradientStrings.map((colorString) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors();
    
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${zodiac.localizedName} ${zodiac.symbol}',
      hint: isSelected 
          ? 'Đã chọn cung ${zodiac.localizedName}' 
          : 'Nhấn để chọn cung ${zodiac.localizedName}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected 
                  ? gradientColors
                  : gradientColors.map((c) => c.withValues(alpha: 0.7)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: isSelected 
                ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zodiac symbol
              Text(
                zodiac.symbol,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              
              // Zodiac name
              Text(
                zodiac.localizedName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.white,
                  fontFamily: AppFonts.font,
                ),
              ),
              
              // Check icon for selected state
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}