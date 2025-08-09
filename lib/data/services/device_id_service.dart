import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const MethodChannel _channel = MethodChannel('com.lynkan.app/device_id');
  
  static String? _cachedDeviceId;
  
  /// Get unique device ID that persists across app reinstalls
  /// For Android: Uses Android ID (SSAID)
  /// For iOS: Uses Keychain-stored UUID or Identifier for Vendor
  static Future<String> getDeviceId() async {

    if (Platform.isIOS) {
      return await DeviceId.get();
    } else {
      if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }
      try {
        final String? deviceId = await _channel.invokeMethod('getDeviceId');
        
        if (deviceId != null && deviceId.isNotEmpty) {
          _cachedDeviceId = deviceId;
          debugPrint('Device ID retrieved: $deviceId');
          return deviceId;
        } else {
          throw Exception('Failed to get device ID: returned null or empty');
        }
      } on PlatformException catch (e) {
        debugPrint('Failed to get device ID: ${e.message}');
        // Generate fallback UUID if native method fails
        final fallbackId = _generateFallbackId();
        _cachedDeviceId = fallbackId;
        return fallbackId;
      }
    }
  }
  
  /// Clear cached device ID (useful for testing)
  static void clearCache() {
    _cachedDeviceId = null;
  }
  
  /// Generate a fallback ID if native method fails
  static String _generateFallbackId() {
    // This is just a fallback - the native implementation should be used
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 100000;
    return 'FALLBACK_${timestamp}_$random';
  }
}

class DeviceId {
  static FlutterSecureStorage? storage;
  static String key = "lynk_an_session_id_key";
  static Future<String> create() async {
    initialize();
    String? deviceId = await storage!.read(key: key);

    if (deviceId == null) {
      // Tạo một Device ID mới
      deviceId = const Uuid().v4(); // UUID ngẫu nhiên
      await storage!.write(key: key, value: deviceId);
    }
    return deviceId;
  }

  // just for IOS
  static Future<String> get() async {
     try{
        initialize();
        String? result = await storage!.read(key: key);
        if(result != null) {
          return result;
        }
        else {
          return await create();
        }
      } catch(e){
        return '';
      }
  }
  
  static initialize() {
    if(storage != null) {
      return;
    }
    storage = const FlutterSecureStorage();
  }
}
