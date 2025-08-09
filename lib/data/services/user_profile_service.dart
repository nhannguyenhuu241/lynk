import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:lynk_an/data/model/response/auth_response.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';

class UserProfileService {
  
  /// Save user profile from AuthResponse after successful login/register
  static Future<void> saveUserProfile(AuthResponse authResponse) async {
    try {
      // Save access token and session info
      if (authResponse.accessToken != null) {
        await Globals.prefs.setString(SharedPrefsKey.accessToken, authResponse.accessToken!);
      }
      
      if (authResponse.userId != null) {
        await Globals.prefs.setString(SharedPrefsKey.userId, authResponse.userId!);
      }
      
      if (authResponse.sessionId != null) {
        await Globals.prefs.setString(SharedPrefsKey.sessionId, authResponse.sessionId!);
      }
      
      if (authResponse.phoneNumber != null) {
        await Globals.prefs.setString(SharedPrefsKey.phoneNumber, authResponse.phoneNumber!);
      }
      
      if (authResponse.deviceId != null) {
        await Globals.prefs.setString(SharedPrefsKey.deviceId, authResponse.deviceId!);
      }
      
      // Create and save profile model
      final profileModel = ProfileModel(
        name: authResponse.name ?? '',
        dateTime: DateTime.now(), // Will be updated with actual birth date later
        gender: authResponse.gender ?? '',
        birthDate: authResponse.birthDate ?? '',
        bornHour: authResponse.bornHour ?? 0,
        phoneNumber: authResponse.phoneNumber ?? '',
      );
      
      await saveProfileModel(profileModel);
      
      // Mark as initialized
      await Globals.prefs.setBool(SharedPrefsKey.is_init, true);
      
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }
  
  /// Save ProfileModel to SharedPreferences
  static Future<void> saveProfileModel(ProfileModel profileModel) async {
    try {
      final jsonString = profileModel.toJsonString();
      await Globals.prefs.setString(SharedPrefsKey.model_profile, jsonString);
    } catch (e) {
      print('Error saving profile model: $e');
      throw Exception('Failed to save profile model: $e');
    }
  }
  
  /// Load ProfileModel from SharedPreferences
  static Future<ProfileModel?> loadProfileModel() async {
    try {
      final jsonString = Globals.prefs.getString(SharedPrefsKey.model_profile);
      if (jsonString.isEmpty) {
        return null;
      }
      return ProfileModel.fromJsonString(jsonString);
    } catch (e) {
      print('Error loading profile model: $e');
      return null;
    }
  }
  
  /// Check if user is initialized (has completed registration flow)
  static bool isUserInitialized() {
    return Globals.prefs.getBool(SharedPrefsKey.is_init);
  }
  
  /// Get saved access token
  static String? getAccessToken() {
    final token = Globals.prefs.getString(SharedPrefsKey.accessToken);
    return token.isEmpty ? null : token;
  }
  
  /// Get saved user ID
  static String? getUserId() {
    final userId = Globals.prefs.getString(SharedPrefsKey.userId);
    return userId.isEmpty ? null : userId;
  }
  
  /// Get saved session ID
  static String? getSessionId() {
    final sessionId = Globals.prefs.getString(SharedPrefsKey.sessionId);
    return sessionId.isEmpty ? null : sessionId;
  }
  
  /// Get saved phone number
  static String? getPhoneNumber() {
    final phone = Globals.prefs.getString(SharedPrefsKey.phoneNumber);
    return phone.isEmpty ? null : phone;
  }
  
  /// Get saved device ID
  static String? getDeviceId() {
    final deviceId = Globals.prefs.getString(SharedPrefsKey.deviceId);
    return deviceId.isEmpty ? null : deviceId;
  }
  
  /// Clear all user data (for logout)
  static Future<void> clearUserData() async {
    try {
      // Clear individual keys by setting them to empty/false
      await Globals.prefs.setString(SharedPrefsKey.accessToken, '');
      await Globals.prefs.setString(SharedPrefsKey.userId, '');
      await Globals.prefs.setString(SharedPrefsKey.sessionId, '');
      await Globals.prefs.setString(SharedPrefsKey.phoneNumber, '');
      await Globals.prefs.setString(SharedPrefsKey.deviceId, '');
      await Globals.prefs.setString(SharedPrefsKey.model_profile, '');
      await Globals.prefs.setBool(SharedPrefsKey.is_init, false);
      
      // Also clear zodiac selection state if needed
      await clearZodiacSelectionState();
      
    } catch (e) {
      print('Error clearing user data: $e');
      throw Exception('Failed to clear user data: $e');
    }
  }
  
  /// Save zodiac selection state
  static Future<void> saveZodiacSelectionState(bool hasSelectedZodiac) async {
    await Globals.prefs.setBool(SharedPrefsKey.has_selected_zodiac, hasSelectedZodiac);
  }
  
  /// Check if user has selected zodiac
  static bool hasSelectedZodiac() {
    return Globals.prefs.getBool(SharedPrefsKey.has_selected_zodiac);
  }
  
  /// Clear zodiac selection state
  static Future<void> clearZodiacSelectionState() async {
    await Globals.prefs.setBool(SharedPrefsKey.has_selected_zodiac, false);
  }
}