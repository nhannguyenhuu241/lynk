import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';
import '../../data/local/shared_prefs/shared_prefs_key.dart';
import '../globals.dart';
import 'app_localizations.dart';

class LocalizationsConfig {
  static Locale getCurrentLocale() {
    String lang = Globals.prefs.getString(SharedPrefsKey.language, value: LangKey.langDefault);
    Globals.localeType = lang == LangKey.langVi
        ? LocaleType.vi
        : lang == LangKey.langKo
            ? LocaleType.ko
            : LocaleType.en;
    return Locale(lang);
  }

  static const List<Locale> supportedLocales = [
    Locale(LangKey.langVi, 'VN'),
    Locale(LangKey.langEn, 'EN'),
    Locale(LangKey.langKo, 'KR'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    // A class which loads the translations from JSON files
    AppLocalizations.delegate,
    // Built-in localization of basic text for Material widgets
    GlobalMaterialLocalizations.delegate,
    // Built-in localization for text direction LTR/RTL
    GlobalWidgetsLocalizations.delegate,

    GlobalCupertinoLocalizations.delegate
  ];

  static Locale localeResolutionCallback(
      Locale? locale, List<Locale> supportedLocales) {
    // Check if the current device locale is supported
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale!.languageCode ||
          supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }

    // If the locale of the device is not supported, use the first one
    // from the list (English, in this case).
    return supportedLocales.first;
  }
}
