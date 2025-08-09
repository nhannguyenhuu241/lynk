package com.life.lynkan.lynk_an

import android.annotation.SuppressLint
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.lynkan.app/device_id"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceId") {
                try {
                    val deviceId = getAndroidId()
                    result.success(deviceId)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Device ID not available: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    @SuppressLint("HardwareIds")
    private fun getAndroidId(): String {
        // Get Android ID (SSAID) - persists across app reinstalls
        // Resets only on factory reset or when user manually resets advertising ID
        val androidId = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ANDROID_ID
        )
        
        // Ensure we have a valid ID
        return if (!androidId.isNullOrBlank() && androidId != "9774d56d682e549c") {
            // "9774d56d682e549c" is a known bad value on some devices
            androidId
        } else {
            // Fallback to a generated ID if Android ID is not available
            "ANDROID_FALLBACK_${System.currentTimeMillis()}"
        }
    }
}
