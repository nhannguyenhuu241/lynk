import Flutter
import UIKit
import Security

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller = window?.rootViewController as! FlutterViewController
    let deviceIdChannel = FlutterMethodChannel(name: "com.lynkan.app/device_id",
                                               binaryMessenger: controller.binaryMessenger)
    
    deviceIdChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getDeviceId" {
        result(self?.getDeviceId())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func getDeviceId() -> String {
    // First, try to get ID from Keychain (persists across app reinstalls)
    if let storedId = getStoredDeviceId() {
      return storedId
    }
    
    // If not in Keychain, generate new ID
    let deviceId: String
    
    // Use identifierForVendor if available
    if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
      deviceId = vendorId
    } else {
      // Fallback to generated UUID
      deviceId = UUID().uuidString
    }
    
    // Store in Keychain for persistence
    saveDeviceId(deviceId)
    return deviceId
  }
  
  private func getStoredDeviceId() -> String? {
    let service = "com.lynkan.app"
    let account = "deviceId"
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    if status == errSecSuccess,
       let data = result as? Data,
       let deviceId = String(data: data, encoding: .utf8) {
      return deviceId
    }
    
    return nil
  }
  
  private func saveDeviceId(_ deviceId: String) {
    let service = "com.lynkan.app"
    let account = "deviceId"
    
    guard let data = deviceId.data(using: .utf8) else { return }
    
    // First, delete any existing item
    let deleteQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ]
    SecItemDelete(deleteQuery as CFDictionary)
    
    // Then add new item
    let addQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ]
    
    SecItemAdd(addQuery as CFDictionary, nil)
  }
}
