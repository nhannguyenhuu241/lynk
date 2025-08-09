class CheckDeviceResponse {
  final bool exists;
  final bool userRegistered;
  final String? phoneNumber;
  final bool userActive;
  final String? message;
  final String? error;

  CheckDeviceResponse({
    required this.exists,
    required this.userRegistered,
    this.phoneNumber,
    required this.userActive,
    this.message,
    this.error,
  });

  factory CheckDeviceResponse.fromJson(Map<String, dynamic> json) =>
      CheckDeviceResponse(
        exists: json['exists'] ?? false,
        userRegistered: json['user_registered'] ?? false,
        phoneNumber: json['phone_number'],
        userActive: json['user_active'] ?? false,
        message: json['message'],
        error: json['error'],
      );

  bool get isSuccess => error == null;
}