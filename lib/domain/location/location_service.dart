import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        debugPrint('Location permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        debugPrint('Location permission permanently denied');
        // Open app settings for user to manually grant permission
        await openAppSettings();
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }
  
  static Future<bool> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }
  
  static Future<String?> getCurrentLocationText() async {
    try {
      // Check if permission is granted
      if (!await checkLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          return null;
        }
      }
      
      // Note: Since geolocator package is not included, 
      // this is a placeholder implementation
      // You would need to add geolocator package and implement actual location fetching
      debugPrint('Location permission granted, but actual location fetching not implemented');
      
      // Return placeholder for now
      return 'Hồ Chí Minh, Việt Nam'; // Default location
      
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }
  
  static String getLocationPromptMessage(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return 'To find nearby restaurants and shops, please allow location access.';
      case 'ko':
        return '근처 식당과 상점을 찾으려면 위치 접근을 허용해 주세요.';
      case 'vi':
      default:
        return 'Để tìm nhà hàng và cửa hàng gần bạn, vui lòng cho phép truy cập vị trí.';
    }
  }
}