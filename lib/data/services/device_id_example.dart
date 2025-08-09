import 'package:flutter/material.dart';
import 'device_id_service.dart';

/// Example usage of DeviceIdService
class DeviceIdExample extends StatefulWidget {
  @override
  _DeviceIdExampleState createState() => _DeviceIdExampleState();
}

class _DeviceIdExampleState extends State<DeviceIdExample> {
  String? _deviceId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      setState(() {
        _deviceId = deviceId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _deviceId = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device ID Example')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Device ID:', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  SelectableText(
                    _deviceId ?? 'Not available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      DeviceIdService.clearCache();
                      _loadDeviceId();
                    },
                    child: Text('Reload Device ID'),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Example of using device ID in authentication
class AuthenticationExample {
  static Future<void> registerUser({
    required String phoneNumber,
    required String name,
    required String gender,
    required String birthDate,
    required int bornHour,
  }) async {
    try {
      // Get device ID
      final deviceId = await DeviceIdService.getDeviceId();
      
      // Use device ID in API call
      print('Registering user with device ID: $deviceId');
      
      // Make your API call here
      // final response = await apiService.register(
      //   phoneNumber: phoneNumber,
      //   deviceId: deviceId,
      //   name: name,
      //   gender: gender,
      //   birthDate: birthDate,
      //   bornHour: bornHour,
      // );
      
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }
  
  static Future<void> loginUser({required String phoneNumber}) async {
    try {
      // Get device ID
      final deviceId = await DeviceIdService.getDeviceId();
      
      // Use device ID in API call
      print('Logging in user with device ID: $deviceId');
      
      // Make your API call here
      // final response = await apiService.login(
      //   phoneNumber: phoneNumber,
      //   deviceId: deviceId,
      // );
      
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }
}