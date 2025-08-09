import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  // ============ PRIMARY BRAND COLORS ============
  // Cosmic Purple - Màu chính cho AI/Tech brand, gợi cảm giác thông minh và tương lai
  static const primary = Color(0xFF6366F1); // Indigo 500 - Modern & Tech-savvy
  static const primaryLight = Color(0xFF818CF8); // Indigo 400 - Lighter variant
  static const primaryDark = Color(0xFF4F46E5); // Indigo 600 - Darker variant
  static const primarySoft = Color(0xFFF0F0FF); // Very light indigo for backgrounds
  
  // ============ SECONDARY COLORS ============
  // Mystical Teal - Màu phụ tạo sự cân bằng và hỗ trợ
  static const secondary = Color(0xFF14B8A6); // Teal 500 - Complementary to purple
  static const secondaryLight = Color(0xFF5EEAD4); // Teal 300
  static const secondaryDark = Color(0xFF0F766E); // Teal 700
  static const secondarySoft = Color(0xFFF0FDFA); // Very light teal
  
  // ============ NEUTRAL SCALE ============
  // Professional grayscale với warm undertones
  static const neutral900 = Color(0xFF0F172A); // Darkest - Text primary
  static const neutral800 = Color(0xFF1E293B); // Very dark
  static const neutral700 = Color(0xFF334155); // Dark - Text secondary
  static const neutral600 = Color(0xFF475569); // Medium dark
  static const neutral500 = Color(0xFF64748B); // Medium - Text tertiary
  static const neutral400 = Color(0xFF94A3B8); // Medium light
  static const neutral300 = Color(0xFFCBD5E1); // Light - Borders
  static const neutral200 = Color(0xFFE2E8F0); // Very light - Dividers
  static const neutral100 = Color(0xFFF1F5F9); // Ultra light - Backgrounds
  static const neutral50 = Color(0xFFF8FAFC); // White-ish
  static const white = Color(0xFFFFFFFF); // Pure white
  static const black = Color(0xFF000000); // Pure black
  
  // ============ SEMANTIC COLORS ============
  // Success - Emerald green cho trạng thái thành công
  static const success = Color(0xFF10B981); // Emerald 500
  static const successLight = Color(0xFF6EE7B7); // Emerald 300
  static const successDark = Color(0xFF047857); // Emerald 700
  static const successSoft = Color(0xFFF0FDF4); // Very light green
  
  // Warning - Amber cho cảnh báo
  static const warning = Color(0xFFF59E0B); // Amber 500
  static const warningLight = Color(0xFFFCD34D); // Amber 300
  static const warningDark = Color(0xFFD97706); // Amber 600
  static const warningSoft = Color(0xFFFFFBEB); // Very light amber
  
  // Error - Red cho lỗi
  static const error = Color(0xFFEF4444); // Red 500
  static const errorLight = Color(0xFFF87171); // Red 400
  static const errorDark = Color(0xFFDC2626); // Red 600
  static const errorSoft = Color(0xFFFEF2F2); // Very light red
  
  // Info - Blue cho thông tin
  static const info = Color(0xFF3B82F6); // Blue 500
  static const infoLight = Color(0xFF93C5FD); // Blue 300
  static const infoDark = Color(0xFF1D4ED8); // Blue 700
  static const infoSoft = Color(0xFFEFF6FF); // Very light blue
  
  // ============ SPECIAL COLORS FOR AI/BOT ============
  // Magical colors cho bot personality và animations
  static const magic = Color(0xFF8B5CF6); // Violet 500 - Bot magic effects
  static const magicLight = Color(0xFFA78BFA); // Violet 400
  static const magicSoft = Color(0xFFF5F3FF); // Very light violet
  
  // Cosmic colors cho background effects
  static const cosmic = Color(0xFF7C3AED); // Violet 600 - Deep space
  static const cosmicLight = Color(0xFF8B5CF6); // Violet 500
  static const cosmicSoft = Color(0xFFFAF5FF); // Ultra light violet

  // ============ BRIGHT GEN Z COLORS ============
  // Vibrant, playful colors phù hợp cho giới trẻ
  
  // Coral - Warm và friendly
  static const coral = Color(0xFFFF6B6B); // Bright coral
  static const coralLight = Color(0xFFFF9F9F); // Light coral
  static const coralSoft = Color(0xFFFFF5F5); // Very light coral
  
  // Mint - Fresh và calming
  static const mint = Color(0xFF4ECDC4); // Bright mint
  static const mintLight = Color(0xFF7FEBE6); // Light mint
  static const mintSoft = Color(0xFFF0FFFE); // Very light mint
  
  // Lavender - Gentle và dreamy
  static const lavender = Color(0xFFB39CD0); // Soft lavender
  static const lavenderLight = Color(0xFFD4C4E0); // Light lavender
  static const lavenderSoft = Color(0xFFFAF7FC); // Very light lavender
  
  // Sunny Yellow - Energetic và optimistic
  static const sunnyYellow = Color(0xFFFFE66D); // Bright sunny yellow
  static const sunnyYellowLight = Color(0xFFFFF2A6); // Light yellow
  static const sunnyYellowSoft = Color(0xFFFFFDF0); // Very light yellow
  
  // Peach - Warm và soft
  static const peach = Color(0xFFFFB4A2); // Soft peach
  static const peachLight = Color(0xFFFFC9BB); // Light peach
  static const peachSoft = Color(0xFFFFF8F6); // Very light peach
  
  // Sky Blue - Clean và fresh
  static const skyBlue = Color(0xFF6BCF7F); // Fresh sky blue (actually mint green)
  static const skyBlueLight = Color(0xFF95E0A3); // Light sky
  static const skyBlueSoft = Color(0xFFF4FDF6); // Very light sky
  
  // ============ OPACITY CONSTANTS ============
  // Standard opacity values for consistent transparency
  static const double opacity5 = 0.05;
  static const double opacity10 = 0.10;
  static const double opacity15 = 0.15;
  static const double opacity20 = 0.20;
  static const double opacity25 = 0.25;
  static const double opacity30 = 0.30;
  static const double opacity40 = 0.40;
  static const double opacity50 = 0.50;
  static const double opacity60 = 0.60;
  static const double opacity70 = 0.70;
  static const double opacity80 = 0.80;
  static const double opacity90 = 0.90;
  static const double opacity95 = 0.95;
  
  // ============ GLASSMORPHISM COLORS ============
  // Cho các glass effects và modern UI elements
  static const glassWhite = Color(0x1AFFFFFF); // 10% white
  static const glassLight = Color(0x33FFFFFF); // 20% white
  static const glassMedium = Color(0x4DFFFFFF); // 30% white
  static const glassDark = Color(0x1A000000); // 10% black
  static const glassBlur = Color(0x80FFFFFF); // 50% white với blur
  
  // ============ COMMON GLASS/OVERLAY COLORS ============
  // Pre-defined opacity colors for common use cases
  
  // White overlays - for glass effects và light overlays
  static Color get glassWhite5 => white.withValues(alpha: opacity5);
  static Color get glassWhite10 => white.withValues(alpha: opacity10);
  static Color get glassWhite15 => white.withValues(alpha: opacity15);
  static Color get glassWhite20 => white.withValues(alpha: opacity20);
  static Color get glassWhite25 => white.withValues(alpha: opacity25);
  static Color get glassWhite30 => white.withValues(alpha: opacity30);
  static Color get glassWhite40 => white.withValues(alpha: opacity40);
  static Color get glassWhite50 => white.withValues(alpha: opacity50);
  static Color get glassWhite60 => white.withValues(alpha: opacity60);
  static Color get glassWhite70 => white.withValues(alpha: opacity70);
  static Color get glassWhite80 => white.withValues(alpha: opacity80);
  static Color get glassWhite90 => white.withValues(alpha: opacity90);
  
  // Black overlays - for shadows và dark overlays
  static Color get glassBlack5 => black.withValues(alpha: opacity5);
  static Color get glassBlack10 => black.withValues(alpha: opacity10);
  static Color get glassBlack15 => black.withValues(alpha: opacity15);
  static Color get glassBlack20 => black.withValues(alpha: opacity20);
  static Color get glassBlack25 => black.withValues(alpha: opacity25);
  static Color get glassBlack30 => black.withValues(alpha: opacity30);
  static Color get glassBlack40 => black.withValues(alpha: opacity40);
  static Color get glassBlack50 => black.withValues(alpha: opacity50);
  static Color get glassBlack60 => black.withValues(alpha: opacity60);
  static Color get glassBlack70 => black.withValues(alpha: opacity70);
  static Color get glassBlack80 => black.withValues(alpha: opacity80);
  static Color get glassBlack90 => black.withValues(alpha: opacity90);
  
  // Primary color overlays - for brand-colored glass effects
  static Color get glassPrimary10 => primary.withValues(alpha: opacity10);
  static Color get glassPrimary20 => primary.withValues(alpha: opacity20);
  static Color get glassPrimary30 => primary.withValues(alpha: opacity30);
  static Color get glassPrimary50 => primary.withValues(alpha: opacity50);
  
  // Secondary color overlays
  static Color get glassSecondary10 => secondary.withValues(alpha: opacity10);
  static Color get glassSecondary20 => secondary.withValues(alpha: opacity20);
  static Color get glassSecondary30 => secondary.withValues(alpha: opacity30);
  static Color get glassSecondary50 => secondary.withValues(alpha: opacity50);
  
  // Common overlay colors for UI states
  static Color get overlayHover => black.withValues(alpha: opacity5);
  static Color get overlayPressed => black.withValues(alpha: opacity10);
  static Color get overlayDisabled => black.withValues(alpha: opacity30);
  static Color get overlayLoading => white.withValues(alpha: opacity80);
  static Color get overlayModal => black.withValues(alpha: opacity50);
  static Color get overlayScrim => black.withValues(alpha: opacity60);
  
  // Helper method to create overlay color with any opacity
  static Color getOverlay(Color color, double opacity) {
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }
  
  // ============ SHADOW COLORS ============
  // Modern shadow system
  static const shadowLight = Color(0x1A000000); // 10% black shadow
  static const shadowMedium = Color(0x33000000); // 20% black shadow
  static const shadowDark = Color(0x4D000000); // 30% black shadow
  static const shadowColorful = Color(0x336366F1); // 20% primary shadow
  
  // ============ TIME-BASED DYNAMIC COLORS ============
  // Giữ lại concept thời gian trong ngày nhưng refined hơn
  
  // Sunrise - Soft pastels với warm tones
  static const sunriseTop = Color(0xFFFED7E2); // Pink 100 - Soft morning pink
  static const sunriseMiddle = Color(0xFFFEF3C7); // Yellow 100 - Warm light
  static const sunriseBottom = Color(0xFFDDD6FE); // Purple 100 - Morning mist
  
  // Day - Bright và energetic
  static const dayTop = Color(0xFF93C5FD); // Blue 300 - Clear sky
  static const dayMiddle = Color(0xFFBAE6FD); // Sky 200 - Clouds
  static const dayBottom = Color(0xFFE0F2FE); // Sky 100 - Horizon
  
  // Sunset - Warm và dramatic
  static const sunsetTop = Color(0xFFFB7185); // Rose 400 - Sunset pink
  static const sunsetMiddle = Color(0xFFFBBF24); // Yellow 400 - Golden hour
  static const sunsetBottom = Color(0xFFA855F7); // Purple 500 - Deep evening
  
  // Night - Cool và mysterious
  static const nightTop = Color(0xFF1E293B); // Slate 800 - Dark sky
  static const nightMiddle = Color(0xFF334155); // Slate 700 - Night depth
  static const nightBottom = Color(0xFF64748B); // Slate 500 - Horizon glow
}

// ============ THEME UTILITIES ============
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // Light mode only color getters
  static Color getBackground(BuildContext context) => AppColors.white;
  
  static Color getSurface(BuildContext context) => AppColors.neutral50;
  
  static Color getCard(BuildContext context) => AppColors.white;
  
  static Color getPrimary(BuildContext context) => AppColors.primary;
  
  static Color getSecondary(BuildContext context) => AppColors.secondary;
  
  static Color getTextPrimary(BuildContext context) => AppColors.neutral900;
  
  static Color getTextSecondary(BuildContext context) => AppColors.neutral700;
  
  static Color getBorder(BuildContext context) => AppColors.neutral300;
  
  // Semantic colors with dark mode support
  static Color getSuccess() => AppColors.success;
  static Color getWarning() => AppColors.warning;
  static Color getError() => AppColors.error;
  static Color getInfo() => AppColors.info;
  
  // Time-based gradient getters
  static List<Color> getSunriseGradient() => [
    AppColors.sunriseTop,
    AppColors.sunriseMiddle,
    AppColors.sunriseBottom,
  ];
  
  static List<Color> getDayGradient() => [
    AppColors.dayTop,
    AppColors.dayMiddle,
    AppColors.dayBottom,
  ];
  
  static List<Color> getSunsetGradient() => [
    AppColors.sunsetTop,
    AppColors.sunsetMiddle,
    AppColors.sunsetBottom,
  ];
  
  static List<Color> getNightGradient() => [
    AppColors.nightTop,
    AppColors.nightMiddle,
    AppColors.nightBottom,
  ];
  
  // Get gradient based on time of day
  static List<Color> getTimeBasedGradient() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 8) return getSunriseGradient();
    if (hour >= 8 && hour < 17) return getDayGradient();
    if (hour >= 17 && hour < 20) return getSunsetGradient();
    return getNightGradient();
  }

  // Get bright gradient based on time of day
  static List<Color> getBrightTimeBasedGradient() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return getBrightMorningGradient();
    if (hour >= 12 && hour < 17) return getBrightDayGradient();
    if (hour >= 17 && hour < 21) return getBrightEveningGradient();
    return getBrightNightGradient();
  }
  
  // Accessibility helpers
  static Color getContrastColor(Color backgroundColor) {
    // Calculate contrast ratio and return appropriate text color
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.neutral900 : AppColors.white;
  }
  
  // Glass effect color for light mode
  static Color getGlassColor(BuildContext context) => AppColors.glassWhite;
  
  static Color getGlassBlur() => AppColors.glassBlur;
  
  // Magic/Bot colors for special effects
  static Color getMagicColor() => AppColors.magic;
  static Color getCosmicColor() => AppColors.cosmic;
  
  // Shadow helpers
  static List<BoxShadow> getLightShadow() => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> getMediumShadow() => [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> getColorfulShadow() => [
    BoxShadow(
      color: AppColors.shadowColorful,
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  // Color opacity helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }
  
  // Gradient builders
  static LinearGradient getPrimaryGradient() => const LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient getSecondaryGradient() => const LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient getMagicGradient() => const LinearGradient(
    colors: [AppColors.magic, AppColors.cosmic],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============ BRIGHT GEN Z GRADIENTS ============
  
  // Coral to Peach - Warm và inviting
  static LinearGradient getCoralGradient() => const LinearGradient(
    colors: [AppColors.coral, AppColors.peach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Mint to Sky Blue - Fresh và clean
  static LinearGradient getMintGradient() => const LinearGradient(
    colors: [AppColors.mint, AppColors.skyBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Lavender to Sunny Yellow - Playful và energetic
  static LinearGradient getPlayfulGradient() => const LinearGradient(
    colors: [AppColors.lavender, AppColors.sunnyYellow],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
  
  // Multi-color bright gradient - Ultimate Gen Z
  static LinearGradient getBrightMultiGradient() => const LinearGradient(
    colors: [
      AppColors.coral,
      AppColors.sunnyYellow,
      AppColors.mint,
      AppColors.lavender,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  // Pastel rainbow gradient - Soft và dreamy
  static LinearGradient getPastelRainbowGradient() => const LinearGradient(
    colors: [
      AppColors.coralLight,
      AppColors.peachLight,
      AppColors.sunnyYellowLight,
      AppColors.mintLight,
      AppColors.lavenderLight,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Time-based bright gradients
  static List<Color> getBrightMorningGradient() => [
    AppColors.sunnyYellow,
    AppColors.coral,
    AppColors.peach,
  ];
  
  static List<Color> getBrightDayGradient() => [
    AppColors.skyBlue,
    AppColors.mint,
    AppColors.mintLight,
  ];
  
  static List<Color> getBrightEveningGradient() => [
    AppColors.coral,
    AppColors.lavender,
    AppColors.peach,
  ];
  
  static List<Color> getBrightNightGradient() => [
    AppColors.lavender,
    AppColors.lavenderLight,
    AppColors.mint,
  ];
  
  // Create Material Theme Data
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primarySoft,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondarySoft,
        tertiary: AppColors.magic,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.neutral900,
        onError: AppColors.white,
      ),
      fontFamily: AppFonts.font,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
  
}

class AppFonts {
  static const font = "Baloo 2";
  static const fontKorean = "Noto Sans KR";
  // Comprehensive fallback fonts for better international support
  static const fontFallback = [
    "Baloo 2", 
    "Noto Sans KR", 
    "NotoSans", 
    ".SF UI Text", 
    "Roboto", 
    "Apple SD Gothic Neo",
    "Malgun Gothic",
    "sans-serif"
  ];
  
  // Helper to get font family based on locale with comprehensive fallbacks
  static String getFontFamily(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ko') {
      return fontKorean;
    }
    return font;
  }
  
  // Get TextStyle with proper font fallbacks for international text
  static TextStyle getTextStyle({
    required BuildContext context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
  }) {
    final effectiveFontFamily = fontFamily ?? getFontFamily(context);
    
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: effectiveFontFamily,
      fontFamilyFallback: fontFallback,
      // Ensure proper text rendering for all languages
      textBaseline: TextBaseline.alphabetic,
    );
  }
  
  // Specialized method for Korean text rendering
  static TextStyle getKoreanTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontKorean,
      fontFamilyFallback: fontFallback,
      textBaseline: TextBaseline.alphabetic,
      // Korean-specific optimizations
      letterSpacing: 0.0,
      wordSpacing: 0.0,
    );
  }
}

class AppSizes {
  // ============ SPACING CONSTANTS (4px grid system) ============
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing36 = 36.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;
  
  // ============ LEGACY PADDING NAMES (for backward compatibility) ============
  static const double ultraPadding = spacing32; // 32.0
  static const double largePadding = spacing24; // 24.0 (fixed typo)
  static const double lagePadding = spacing24; // 24.0 (keep for backward compatibility)
  static const double maxPadding = spacing16; // 16.0
  static const double minPadding = spacing8; // 8.0
  
  // ============ COMMON EDGEINSETS PATTERNS ============
  // All sides padding
  static const EdgeInsets paddingAll2 = EdgeInsets.all(spacing2);
  static const EdgeInsets paddingAll4 = EdgeInsets.all(spacing4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(spacing12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(spacing20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(spacing32);
  
  // Horizontal padding
  static const EdgeInsets paddingHorizontal4 = EdgeInsets.symmetric(horizontal: spacing4);
  static const EdgeInsets paddingHorizontal8 = EdgeInsets.symmetric(horizontal: spacing8);
  static const EdgeInsets paddingHorizontal12 = EdgeInsets.symmetric(horizontal: spacing12);
  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingHorizontal20 = EdgeInsets.symmetric(horizontal: spacing20);
  static const EdgeInsets paddingHorizontal24 = EdgeInsets.symmetric(horizontal: spacing24);
  static const EdgeInsets paddingHorizontal32 = EdgeInsets.symmetric(horizontal: spacing32);
  
  // Vertical padding
  static const EdgeInsets paddingVertical4 = EdgeInsets.symmetric(vertical: spacing4);
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(vertical: spacing8);
  static const EdgeInsets paddingVertical12 = EdgeInsets.symmetric(vertical: spacing12);
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(vertical: spacing16);
  static const EdgeInsets paddingVertical20 = EdgeInsets.symmetric(vertical: spacing20);
  static const EdgeInsets paddingVertical24 = EdgeInsets.symmetric(vertical: spacing24);
  static const EdgeInsets paddingVertical32 = EdgeInsets.symmetric(vertical: spacing32);
  
  // Common symmetric patterns
  static const EdgeInsets paddingSymmetric8x4 = EdgeInsets.symmetric(horizontal: spacing8, vertical: spacing4);
  static const EdgeInsets paddingSymmetric12x8 = EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8);
  static const EdgeInsets paddingSymmetric16x8 = EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8);
  static const EdgeInsets paddingSymmetric16x12 = EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12);
  static const EdgeInsets paddingSymmetric20x12 = EdgeInsets.symmetric(horizontal: spacing20, vertical: spacing12);
  static const EdgeInsets paddingSymmetric20x16 = EdgeInsets.symmetric(horizontal: spacing20, vertical: spacing16);
  static const EdgeInsets paddingSymmetric24x16 = EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16);
  static const EdgeInsets paddingSymmetric32x24 = EdgeInsets.symmetric(horizontal: spacing32, vertical: spacing24);
  
  // Common custom patterns
  static const EdgeInsets paddingCard = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingPage = EdgeInsets.all(spacing20);
  static const EdgeInsets paddingDialog = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingListItem = EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing12);
  static const EdgeInsets paddingButtonSmall = EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8);
  static const EdgeInsets paddingButtonLarge = EdgeInsets.symmetric(horizontal: spacing32, vertical: spacing16);
  
  // Zero padding
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  
  // ============ OTHER UI CONSTANTS ============
  static const double onTap = 48.0;
  static const double icon = 24;
  static const double line = 0.5;
  static const double radius = 5.0;
  static const double bottomBarHeight = kBottomNavigationBarHeight;
  static const double paddingBottomBar = kBottomNavigationBarHeight + 40;
  static const double sizeDesktop = 1100;
  static const double sizeTablet = 650;
  static late EdgeInsets screenPadding;

  static init(BuildContext context){
    screenPadding = MediaQuery.of(context).padding;
  }

  static Size screenSize(BuildContext context) => MediaQuery.sizeOf(context);
  
  // ============ HELPER METHODS FOR DYNAMIC PADDING ============
  
  // Create custom EdgeInsets with all sides
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  
  // Create custom symmetric EdgeInsets
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) => 
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  
  // Create custom EdgeInsets with individual sides
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  
  // Create horizontal padding
  static EdgeInsets horizontal(double value) => 
      EdgeInsets.symmetric(horizontal: value);
  
  // Create vertical padding
  static EdgeInsets vertical(double value) => 
      EdgeInsets.symmetric(vertical: value);
  
  // Create padding based on screen size percentage
  static EdgeInsets screenPercentage(BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    final size = screenSize(context);
    return EdgeInsets.symmetric(
      horizontal: size.width * horizontal,
      vertical: size.height * vertical,
    );
  }
  
  // Get responsive padding based on screen width
  static EdgeInsets responsive(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = screenSize(context).width;
    double value = mobile;
    
    if (width >= sizeDesktop && desktop != null) {
      value = desktop;
    } else if (width >= sizeTablet && tablet != null) {
      value = tablet;
    }
    
    return EdgeInsets.all(value);
  }
  
  // Safe area aware padding
  static EdgeInsets safeArea(BuildContext context, {
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
  }) {
    final padding = MediaQuery.of(context).padding;
    return EdgeInsets.only(
      left: left ? padding.left : 0,
      top: top ? padding.top : 0,
      right: right ? padding.right : 0,
      bottom: bottom ? padding.bottom : 0,
    );
  }
}

class AppKeys {
  static const String keyHUD = "HUD";
}

class AppTextSizes {
  static double tiny = 12.0;
  static double subBody = 14.0;
  static double body = 16.0;
  static double subTitle = 18.0;
  static double title = 20.0;
  static double header = 26.0;

  static update(double size) {
    body = size;
    subBody = body - 2;
    tiny = subBody - 2;
    subTitle = body + 2;
    title = subTitle + 2;
    header = title + 6;
  }
}

class AppAnimation {
  static Duration duration = Duration(milliseconds: 500);
  static Curve curve = Curves.fastOutSlowIn;
}

class AppFormat {
  static DateFormat date = DateFormat("dd/MM/yyyy");
  static DateFormat time = DateFormat("HH:mm");
  static DateFormat fullTime = DateFormat("HH:mm:ss");
  static DateFormat dateTime = DateFormat("dd/MM/yyyy HH:mm");
  static DateFormat dateTimeResponse = DateFormat("yyyy-MM-dd HH:mm:ss");
  static DateFormat dateTime2Response = DateFormat("M/d/yyyy hh:mm:ss a");
  static DateFormat dateRequest = DateFormat("yyyy/MM/dd");
  static DateFormat year = DateFormat("yyyy");
  static NumberFormat quantity = NumberFormat("#,###.###");
  static NumberFormat chart = NumberFormat("#,###.#");
}

enum AnimationType {
  /// Hiệu ứng trượt mặc định của nền tảng.
  normal,
  /// Hiệu ứng mờ dần.
  fade,
  /// Hiệu ứng trượt từ phải sang.
  slide,
  /// Hiệu ứng phóng to.
  scale,
  /// Hiệu ứng xoay.
  rotate,
}