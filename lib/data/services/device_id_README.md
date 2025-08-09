# Device ID Service Documentation

## Overview
The DeviceIdService provides a unique, persistent device identifier that survives app reinstallation for both Android and iOS platforms.

## Features
- **Persistent across app reinstalls**: The device ID remains the same even after the app is uninstalled and reinstalled
- **Platform-specific implementation**: Uses the best available method for each platform
- **Fallback mechanism**: Provides fallback IDs if native methods fail
- **Caching**: Caches the device ID in memory for performance

## Platform Implementation

### Android
- Uses **Android ID (SSAID)** - Settings.Secure.ANDROID_ID
- Persists until factory reset or manual advertising ID reset
- Filters out known bad values (e.g., "9774d56d682e549c")
- Fallback: Generates timestamp-based ID if Android ID unavailable

### iOS
- Uses **Keychain Storage** for persistence across app reinstalls
- Falls back to **identifierForVendor** if not in Keychain
- Stores in Keychain with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` access level
- Fallback: Generates UUID if vendor ID unavailable

## Usage

### Basic Usage
```dart
import 'package:lynk_an/data/services/device_id_service.dart';

// Get device ID
String deviceId = await DeviceIdService.getDeviceId();
print('Device ID: $deviceId');
```

### In Authentication
```dart
// Register
final deviceId = await DeviceIdService.getDeviceId();
final request = RegisterRequest(
  phoneNumber: phoneNumber,
  deviceId: deviceId,
  name: name,
  gender: gender,
  birthDate: birthDate,
  bornHour: bornHour,
);

// Login
final deviceId = await DeviceIdService.getDeviceId();
final request = LoginRequest(
  phoneNumber: phoneNumber,
  deviceId: deviceId,
);
```

### Error Handling
```dart
try {
  final deviceId = await DeviceIdService.getDeviceId();
  // Use device ID
} catch (e) {
  print('Failed to get device ID: $e');
  // Handle error - service provides fallback IDs automatically
}
```

## Testing
To test device ID persistence:
1. Install the app and get device ID
2. Uninstall the app
3. Reinstall the app
4. Get device ID again - should be the same

## Security Considerations
- Device IDs are stored securely in iOS Keychain
- Android ID is system-provided and secure
- No personally identifiable information is included
- IDs are device-specific, not user-specific

## Troubleshooting

### Android
- Ensure the app has proper permissions (no special permissions needed for Android ID)
- Test on real devices, emulators may return generic IDs

### iOS
- Keychain access requires app to be signed
- Test on real devices for accurate behavior
- Simulator may generate different IDs

## Example Output
- Android: `8a5d3e2f9b1c4a7e`
- iOS: `550E8400-E29B-41D4-A716-446655440000`
- Fallback: `ANDROID_FALLBACK_1704096000000` or `FALLBACK_1704096000000_12345`