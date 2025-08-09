import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';

/// Utility class for safe text rendering and UTF-16 string handling
class TextUtils {
  TextUtils._(); // Private constructor to prevent instantiation

  /// Validates and sanitizes a string to prevent UTF-16 rendering errors
  static String sanitizeString(String input) {
    if (input.isEmpty) return input;
    
    try {
      // Check if string is well-formed UTF-16
      final codeUnits = input.codeUnits;
      final buffer = StringBuffer();
      
      for (int i = 0; i < codeUnits.length; i++) {
        final codeUnit = codeUnits[i];
        
        // Handle surrogate pairs properly
        if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF) {
          // High surrogate - check if we have a low surrogate following
          if (i + 1 < codeUnits.length) {
            final nextCodeUnit = codeUnits[i + 1];
            if (nextCodeUnit >= 0xDC00 && nextCodeUnit <= 0xDFFF) {
              // Valid surrogate pair
              buffer.writeCharCode(codeUnit);
              buffer.writeCharCode(nextCodeUnit);
              i++; // Skip the next code unit as we've processed it
              continue;
            }
          }
          // Invalid surrogate pair - replace with replacement character
          buffer.write('\uFFFD');
        } else if (codeUnit >= 0xDC00 && codeUnit <= 0xDFFF) {
          // Lone low surrogate - replace with replacement character
          buffer.write('\uFFFD');
        } else {
          // Regular character
          buffer.writeCharCode(codeUnit);
        }
      }
      
      return buffer.toString();
    } catch (e) {
      // If any error occurs during sanitization, return a safe fallback
      return input.replaceAll(RegExp(r'[\uD800-\uDFFF]'), '\uFFFD');
    }
  }

  /// Creates a safe TextSpan with proper font handling and string validation
  static TextSpan createSafeTextSpan({
    required String text,
    TextStyle? style,
    BuildContext? context,
    bool forceKoreanFont = false,
  }) {
    final sanitizedText = sanitizeString(text);
    
    TextStyle effectiveStyle;
    if (forceKoreanFont) {
      effectiveStyle = AppFonts.getKoreanTextStyle(
        fontSize: style?.fontSize,
        fontWeight: style?.fontWeight,
        color: style?.color,
      );
    } else if (context != null) {
      effectiveStyle = AppFonts.getTextStyle(
        context: context,
        fontSize: style?.fontSize,
        fontWeight: style?.fontWeight,
        color: style?.color,
        fontFamily: style?.fontFamily,
      );
    } else {
      effectiveStyle = style ?? const TextStyle();
    }
    
    return TextSpan(
      text: sanitizedText,
      style: effectiveStyle,
    );
  }

  /// Creates a safe TextPainter with proper string validation and font handling
  static TextPainter createSafeTextPainter({
    required String text,
    required TextStyle style,
    TextAlign textAlign = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    BuildContext? context,
    bool forceKoreanFont = false,
  }) {
    final safeTextSpan = createSafeTextSpan(
      text: text,
      style: style,
      context: context,
      forceKoreanFont: forceKoreanFont,
    );
    
    final textPainter = TextPainter(
      text: safeTextSpan,
      textAlign: textAlign,
      textDirection: textDirection,
    );
    
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter;
  }

  /// Checks if a string contains Korean characters
  static bool containsKorean(String text) {
    return RegExp(r'[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AF]').hasMatch(text);
  }

  /// Checks if a string contains any CJK (Chinese, Japanese, Korean) characters
  static bool containsCJK(String text) {
    return RegExp(r'[\u4E00-\u9FFF\u3400-\u4DBF\u3040-\u309F\u30A0-\u30FF\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AF]').hasMatch(text);
  }

  /// Gets the appropriate text direction for a given string
  static TextDirection getTextDirection(String text) {
    // Check for RTL languages (Arabic, Hebrew, etc.)
    if (RegExp(r'[\u0590-\u05FF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(text)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  /// Validates if a string is safe for rendering without UTF-16 errors
  static bool isValidUTF16String(String input) {
    try {
      final codeUnits = input.codeUnits;
      
      for (int i = 0; i < codeUnits.length; i++) {
        final codeUnit = codeUnits[i];
        
        // Check for invalid surrogate pairs
        if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF) {
          // High surrogate - must be followed by low surrogate
          if (i + 1 >= codeUnits.length) return false;
          final nextCodeUnit = codeUnits[i + 1];
          if (nextCodeUnit < 0xDC00 || nextCodeUnit > 0xDFFF) return false;
          i++; // Skip the low surrogate
        } else if (codeUnit >= 0xDC00 && codeUnit <= 0xDFFF) {
          // Lone low surrogate is invalid
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}