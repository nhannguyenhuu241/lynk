import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import '../services/api/base_api_service.dart';
import '../model/request/auth_request.dart';
import '../model/response/auth_response.dart';
import '../model/response/check_device_response.dart';

class AuthRepository {
  static const String _registerEndpoint = '/api/v1/auth/register';
  static const String _loginEndpoint = '/api/v1/auth/login';
  static const String _checkDeviceEndpoint = '/api/v1/auth/check-device';

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      debugPrint('\n════════════════════════════════════════════════');
      debugPrint('🚀 REGISTER API CALL');
      debugPrint('Endpoint: $_registerEndpoint');
      debugPrint('Request Data: ${request.toJson()}');
      debugPrint('════════════════════════════════════════════════\n');
      
      final response = await BaseApiService.dio.post(
        _registerEndpoint,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      
      debugPrint('\n════════════════════════════════════════════════');
      debugPrint('✅ REGISTER SUCCESS');
      debugPrint('Access Token: ${authResponse.accessToken}');
      debugPrint('User ID: ${authResponse.userId}');
      debugPrint('Session ID: ${authResponse.sessionId}');
      debugPrint('════════════════════════════════════════════════\n');
      
      return authResponse;
    } on DioException catch (e) {
      debugPrint('Register error: ${e.message}');
      if (e.response != null) {
        // Try to parse error response
        return AuthResponse(
          error: e.response?.data['error'] ?? 
                 e.response?.data['message'] ?? 
                 AppLocalizations.text(LangKey.error_general_message),
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error during registration: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      debugPrint('\n════════════════════════════════════════════════');
      debugPrint('🚀 LOGIN API CALL');
      debugPrint('Endpoint: $_loginEndpoint');
      debugPrint('Request Data: ${request.toJson()}');
      debugPrint('════════════════════════════════════════════════\n');
      
      final response = await BaseApiService.dio.post(
        _loginEndpoint,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      
      debugPrint('\n════════════════════════════════════════════════');
      debugPrint('✅ LOGIN SUCCESS');
      debugPrint('Access Token: ${authResponse.accessToken}');
      debugPrint('User ID: ${authResponse.userId}');
      debugPrint('════════════════════════════════════════════════\n');
      
      // Save token if login successful
      if (authResponse.isSuccess && authResponse.accessToken != null) {
        BaseApiService.addAuthToken(authResponse.accessToken!);
        // You might want to save the token to SharedPreferences here
      }

      return authResponse;
    } on DioException catch (e) {
      debugPrint('Login error: ${e.message}');
      if (e.response != null) {
        // Try to parse error response
        return AuthResponse(
          error: e.response?.data['error'] ?? 
                 e.response?.data['message'] ?? 
                 'Login failed',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    BaseApiService.removeAuthToken();
  }

  Future<CheckDeviceResponse> checkDevice(CheckDeviceRequest request) async {
    try {
      debugPrint('\n════════════════════════════════════════════════');
      debugPrint('🔍 CHECK DEVICE API CALL');
      debugPrint('Endpoint: $_checkDeviceEndpoint');
      debugPrint('Request Data: ${request.toJson()}');
      debugPrint('════════════════════════════════════════════════\n');
      
      final response = await BaseApiService.dio.post(
        _checkDeviceEndpoint,
        data: request.toJson(),
      );

      final checkDeviceResponse = CheckDeviceResponse.fromJson(response.data);
      
      debugPrint('\n════════════════════════════════════════════════');
      debugPrint('✅ CHECK DEVICE SUCCESS');
      debugPrint('Exists: ${checkDeviceResponse.exists}');
      debugPrint('User Registered: ${checkDeviceResponse.userRegistered}');
      debugPrint('Phone Number: ${checkDeviceResponse.phoneNumber}');
      debugPrint('User Active: ${checkDeviceResponse.userActive}');
      debugPrint('Message: ${checkDeviceResponse.message}');
      debugPrint('════════════════════════════════════════════════\n');
      
      return checkDeviceResponse;
    } on DioException catch (e) {
      debugPrint('Check device error: ${e.message}');
      if (e.response != null) {
        return CheckDeviceResponse.fromJson({
          'exists': false,
          'user_registered': false,
          'phone_number': null,
          'user_active': false,
          'message': null,
          'error': e.response?.data['error'] ?? 
                   e.response?.data['message'] ?? 
                   'Check device failed',
        });
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error during check device: $e');
      throw Exception('Check device failed: $e');
    }
  }
}