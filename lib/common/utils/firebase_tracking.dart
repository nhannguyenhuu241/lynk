import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseTracking {
  Future<void> logEvent({
    required String eventName,
    required String screenName,
    required String url,
    required String httpStatusCode,
    required dynamic input,
    required dynamic output,
  }) async {
    bool? result = false;
    String inputData = "";
    if (input == null) {
      inputData = "";
    } else {
      inputData = json.encode(input);
    }
    String outputData = "";
    if (output == null) {
      outputData = "";
    } else {
      outputData = json.encode(output);
    }
    try {
      Map<String, Object> commonData = {
        'url': url,
        'input': inputData,
        'output': outputData,
        'date': DateTime.now().toString(),
        'httpStatusCode': httpStatusCode
      };
      FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
      await _analytics.logScreenView(screenName: screenName);
      await _analytics.logEvent(name: eventName, parameters: commonData);
      print('===> $eventName --> $screenName --> $commonData');
      result = true;
    } on Exception {}
    print("Result logEvent: $result");
  }
}
