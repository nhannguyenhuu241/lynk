class RegisterRequest {
  final String? phoneNumber;
  final String deviceId;
  final String name;
  final String gender;
  final String birthDate;
  final int bornHour;

  RegisterRequest({
    this.phoneNumber,
    required this.deviceId,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.bornHour,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'device_id': deviceId,
      'name': name,
      'gender': gender,
      'birth_date': birthDate,
      'born_hour': bornHour,
    };
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      json['phone_number'] = phoneNumber!;
    }
    return json;
  }
}

class LoginRequest {
  final String phoneNumber;
  final String deviceId;

  LoginRequest({
    required this.phoneNumber,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'device_id': deviceId,
      };
}

class CheckDeviceRequest {
  final String deviceId;

  CheckDeviceRequest({required this.deviceId});

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
      };
}