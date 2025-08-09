import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/data/model/base/analytic_model.dart';

class Analysis {
  static FirebaseAnalytics? analytics;
  static init() {
     analytics = FirebaseAnalytics.instance;
  }

  static accessApplication(Widget screen) {
    analytics?.logEvent(
      name: 'screen_tracking',
      parameters: AnalyticModel(
          screenName: screen.runtimeType.toString()
      ).toJson(),
    );
    analytics?.logScreenView(screenName: screen.runtimeType.toString());
  }
  static errorApi(Map<String,dynamic> parameters) {
    _sendAnalyticsEvent("errorApi", parameters);
  }
  static trackingNotification(Map<String,dynamic> parameters) {
    _sendAnalyticsEvent("trackingNotification", parameters);
  }
  static Future<void> _sendAnalyticsEvent(String name, Map<String,dynamic> parameters) async {
    try {
      analytics?.logEvent(
        name: name,
        parameters: {
          "log": "$parameters"
        },
      );
    }catch(_) {}
  }
}