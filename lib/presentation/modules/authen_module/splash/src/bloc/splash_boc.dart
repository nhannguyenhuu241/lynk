import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/domain/api/firestore_service.dart';
import 'package:lynk_an/domain/network_connectivity.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/data/services/api/base_api_service.dart';
import 'package:lynk_an/data/services/device_id_service.dart';
import 'package:lynk_an/data/services/user_profile_service.dart';
import 'package:lynk_an/data/repositories/auth_repository.dart';
import 'package:lynk_an/data/model/request/auth_request.dart';

class SplashBoc {
  late BuildContext context;

  // Stream controllers
  final _initializationCompleteController = StreamController<InitializationResult>.broadcast();

  // Streams
  Stream<InitializationResult> get initializationCompleteStream => _initializationCompleteController.stream;

  SplashBoc(BuildContext context) {
    this.context = context;
  }

  Future<void> initializeApp() async {
    // Delay thêm thời gian để hiển thị splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Fetch API keys from Firestore
    await _fetchAndStoreApiKeys();
    
    // Restore authentication token if available
    await _restoreAuthToken();

    // Check device registration status
    final deviceCheckResult = await _checkDeviceRegistration();
    
    _initializationCompleteController.add(deviceCheckResult);
  }

  Future<InitializationResult> _checkDeviceRegistration() async {
    try {
      // Get device ID
      final deviceId = await DeviceIdService.getDeviceId();
      
      // Call check-device API
      final authRepository = AuthRepository();
      final checkDeviceRequest = CheckDeviceRequest(deviceId: deviceId);
      final checkDeviceResponse = await authRepository.checkDevice(checkDeviceRequest);
      
      if (checkDeviceResponse.isSuccess) {
        if (checkDeviceResponse.userActive) {
          // User is active - attempt login with device ID
          return await _handleActiveUser(deviceId);
        } else {
          // User is not active or not registered - go to registration flow
          return InitializationResult(
            isInit: false,
            profileModel: null,
            shouldShowWelcomeMessage: false,
          );
        }
      } else {
        // API call failed - check local initialization
        bool isInit = UserProfileService.isUserInitialized();
        ProfileModel? model;
        if (isInit) {
          model = await UserProfileService.loadProfileModel();
        }
        
        return InitializationResult(
          isInit: isInit,
          profileModel: model,
          shouldShowWelcomeMessage: false,
        );
      }
    } catch (e) {
      print('Error checking device registration: $e');
      // Fallback to local initialization check
      bool isInit = UserProfileService.isUserInitialized();
      ProfileModel? model;
      if (isInit) {
        model = await UserProfileService.loadProfileModel();
      }
      
      return InitializationResult(
        isInit: isInit,
        profileModel: model,
        shouldShowWelcomeMessage: false,
      );
    }
  }

  Future<InitializationResult> _handleActiveUser(String deviceId) async {
    try {
      // Get saved phone number if available
      final savedPhone = UserProfileService.getPhoneNumber();
      
      if (savedPhone != null) {
        // Try login with saved phone and device ID
        final authRepository = AuthRepository();
        final loginRequest = LoginRequest(
          phoneNumber: savedPhone,
          deviceId: deviceId,
        );
        
        final loginResponse = await authRepository.login(loginRequest);
        
        if (loginResponse.isSuccess && loginResponse.accessToken != null) {
          // Save user profile from login response
          await UserProfileService.saveUserProfile(loginResponse);
          
          // Load the profile model
          final profileModel = await UserProfileService.loadProfileModel();
          
          return InitializationResult(
            isInit: true,
            profileModel: profileModel,
            shouldShowWelcomeMessage: true,
          );
        }
      }
      
      // If no saved phone or login failed, go to registration flow
      return InitializationResult(
        isInit: false,
        profileModel: null,
        shouldShowWelcomeMessage: false,
      );
      
    } catch (e) {
      print('Error handling active user: $e');
      return InitializationResult(
        isInit: false,
        profileModel: null,
        shouldShowWelcomeMessage: false,
      );
    }
  }

  Future<void> _fetchAndStoreApiKeys() async {
    try {
      // Check internet connection first
      bool isConnected = await NetworkConnectivity.isConnected();
      
      if (!isConnected) {
        // Show dialog to remind user to turn on internet
        await _showNoInternetDialog();
        return;
      }
      
      final firestoreService = FirestoreService();
      final apiKeys = await firestoreService.getApiKeys();
      
      // Get current stored keys
      final currentChatGPTKey = Globals.prefs.getString(SharedPrefsKey.chatgpt_key);
      final currentGeminiKey = Globals.prefs.getString(SharedPrefsKey.gemini_key);
      
      // Only update if keys have changed
      bool chatGPTChanged = currentChatGPTKey != apiKeys['chatgpt'];
      bool geminiChanged = currentGeminiKey != apiKeys['gemini'];
      
      if (chatGPTChanged) {
        await Globals.prefs.setString(SharedPrefsKey.chatgpt_key, apiKeys['chatgpt'] ?? '');
        print('ChatGPT key updated');
      }
      
      if (geminiChanged) {
        await Globals.prefs.setString(SharedPrefsKey.gemini_key, apiKeys['gemini'] ?? '');
        print('Gemini key updated');
      }
      
      if (!chatGPTChanged && !geminiChanged) {
        print('API keys unchanged, keeping existing values');
      }
      
      print('ChatGPT key: ${apiKeys['chatgpt']?.isNotEmpty == true ? 'Available' : 'Not available'}');
      print('Gemini key: ${apiKeys['gemini']?.isNotEmpty == true ? 'Available' : 'Not available'}');
    } catch (e) {
      print('Error fetching API keys: $e');
      // If error occurs, keep using existing keys
    }
  }

  Future<void> _showNoInternetDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                AppLocalizations.text(LangKey.connection_error),
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Vui lòng bật kết nối internet để sử dụng ứng dụng',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Retry fetching keys
                await _fetchAndStoreApiKeys();
              },
              child: Text(
                AppLocalizations.text(LangKey.continueString),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<ProfileModel?> loadProfile() async {
    try {
      final jsonString = Globals.prefs.getString(SharedPrefsKey.model_profile);
      if (jsonString.isEmpty) {
        return null;
      }
      return ProfileModel.fromJsonString(jsonString);
    } catch (e) {
      print('Error loading profile: $e');
      return null;
    }
  }

  Future<void> _restoreAuthToken() async {
    try {
      // Get saved access token
      final accessToken = Globals.prefs.getString(SharedPrefsKey.accessToken);
      if (accessToken.isNotEmpty) {
        // Restore token to API service
        BaseApiService.addAuthToken(accessToken);
        print('✅ Auth token restored from SharedPreferences');
        
        // Also log other saved data for debugging
        final userId = Globals.prefs.getString(SharedPrefsKey.userId);
        final sessionId = Globals.prefs.getString(SharedPrefsKey.sessionId);
        print('📱 User ID: ${userId.isNotEmpty ? "Available" : "Not set"}');
        print('🔑 Session ID: ${sessionId.isNotEmpty ? "Available" : "Not set"}');
      } else {
        print('⚠️ No auth token found in SharedPreferences');
      }
    } catch (e) {
      print('Error restoring auth token: $e');
    }
  }

  void dispose() {
    _initializationCompleteController.close();
  }
}

class InitializationResult {
  final bool isInit;
  final ProfileModel? profileModel;
  final bool shouldShowWelcomeMessage;

  InitializationResult({
    required this.isInit,
    this.profileModel,
    required this.shouldShowWelcomeMessage,
  });
}