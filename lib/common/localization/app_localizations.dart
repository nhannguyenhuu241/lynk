import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lynk_an/common/lang_key.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    try {
      // Load the language JSON file from the "lang" folder
      var jsonString =
          await rootBundle.loadString('assets/json/${locale.languageCode}.json');
      
      // Ensure the JSON string is properly decoded as UTF-8
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        final stringValue = value.toString();
        // Pre-validate each string during load to catch issues early
        return MapEntry(key, _sanitizeUTF16String(stringValue));
      });

      return true;
    } catch (e) {
      // Log error and return false to indicate load failure
      debugPrint('AppLocalizations load error: $e');
      _localizedStrings = {};
      return false;
    }
  }

  // This method will be called from every widget which needs a localized text
  static String text(String key) {
    final rawText = _localizedStrings[key] ?? "";
    return _sanitizeUTF16String(rawText);
  }

  // Helper method to sanitize UTF-16 strings and prevent rendering errors
  static String _sanitizeUTF16String(String input) {
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
}

// LocalizationsDelegate is a factory for a set of localized resources
// ignore: lines_longer_than_80_chars
// In this case, the localized strings will be gotten in an AppLocalizations object
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return [LangKey.langVi, LangKey.langEn, LangKey.langKo].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    var localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
