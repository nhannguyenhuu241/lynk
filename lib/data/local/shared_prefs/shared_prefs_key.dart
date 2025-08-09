class SharedPrefsKey {
  static const String language = 'language';
  static const String platform = 'platform';
  static const String is_init = 'is_init';
  static const String is_done_profile = 'is_done_profile';
  static const String font_size = 'font_size';
  static const String model_profile = 'model_profile';
  static const String language_selected = 'language_selected';
  static const String chatgpt_key = 'chatgpt_key';
  static const String gemini_key = 'gemini_key';
  
  // Authentication keys
  static const String accessToken = 'access_token';
  static const String userId = 'user_id';
  static const String sessionId = 'session_id';
  
  // User profile keys
  static const String userName = 'user_name';
  static const String phoneNumber = 'phone_number';
  static const String deviceId = 'device_id';
  static const String userPhone = 'user_phone';
  static const String userGender = 'user_gender';
  static const String userBirthDate = 'user_birth_date';
  static const String userBornHour = 'user_born_hour';
  static const String userZodiac = 'user_zodiac';
  static const String has_selected_zodiac = 'has_selected_zodiac';
}

/// Additional keys for socket functionality
class KeySharePreferences {
  static const String keyUserId = 'user_id';
  static const String keyAuthToken = 'auth_token';
  static const String keySocketEnvironment = 'socket_environment';
}
