import 'package:flutter/material.dart';

class Constant {
  // DateTime
  static final DateTime minDateTime = DateTime(1900, 1, 1);

  // int
  static const phoneLength = 10;

  // Regex
  static const String regexPhoneNumber = r'(0)+([0-9]{9,10})\b';
  static const String regexEmail = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
}

// typedef
typedef CustomRefreshCallback = Future<void> Function();
typedef CustomBodyBuilder = Widget Function();