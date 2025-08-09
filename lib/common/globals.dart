import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import '../data/local/shared_prefs/shared_prefs.dart';
import '../data/local/shared_prefs/shared_prefs_key.dart';
import '../main.dart';
import 'config.dart';

class Globals {
  static late SharedPrefs prefs;
  static late Config config;
  static late GlobalKey<MyAppState> myApp;
  static late String applicationMode;
  static late LocaleType localeType;

  static http.Client client = http.Client();
  
  static String getChatGPTKey() {
    return prefs.getString(SharedPrefsKey.chatgpt_key);
  }
  
  static String getGeminiKey() {
    return prefs.getString(SharedPrefsKey.gemini_key);
  }
}
