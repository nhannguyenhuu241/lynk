class AuthResponse {
  final String? accessToken;
  final String? tokenType;
  final String? userId;
  final String? sessionId;
  final String? phoneNumber;
  final String? deviceId;
  final String? name;
  final String? gender;
  final String? birthDate;
  final int? bornHour;
  final String? error;

  AuthResponse({
    this.accessToken,
    this.tokenType,
    this.userId,
    this.sessionId,
    this.phoneNumber,
    this.deviceId,
    this.name,
    this.gender,
    this.birthDate,
    this.bornHour,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['access_token'],
        tokenType: json['token_type'],
        userId: json['user_id'],
        sessionId: json['session_id'],
        phoneNumber: json['phone_number'],
        deviceId: json['device_id'],
        name: json['name'],
        gender: json['gender'],
        birthDate: json['birth_date'],
        bornHour: json['born_hour'],
        error: json['error'],
      );

  bool get isSuccess => accessToken != null && accessToken!.isNotEmpty;
}