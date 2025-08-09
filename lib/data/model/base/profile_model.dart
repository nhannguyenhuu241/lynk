import 'dart:convert';

class ProfileModel {
  final String name;
  final DateTime dateTime;
  late final String gender;
  final String? phoneNumber;
  final String? selectedZodiac;
  final String? birthDate;
  final int? bornHour;

  ProfileModel({
    required this.name,
    required this.dateTime,
    required this.gender,
    this.phoneNumber,
    this.selectedZodiac,
    this.birthDate,
    this.bornHour,
  });

  // Convert ProfileModel to Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'gender': gender,
      'phoneNumber': phoneNumber,
      'selectedZodiac': selectedZodiac,
      'birthDate': birthDate,
      'bornHour': bornHour,
    };
  }

  // Create ProfileModel from Map
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      gender: json['gender'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      selectedZodiac: json['selectedZodiac'] as String?,
      birthDate: json['birthDate'] as String?,
      bornHour: json['bornHour'] as int?,
    );
  }

  // Convert to JSON String
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create from JSON String
  factory ProfileModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ProfileModel.fromJson(json);
  }
}
