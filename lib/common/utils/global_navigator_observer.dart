import 'package:flutter/material.dart';
import 'package:lynk_an/common/utils/error_handler.dart';

class GlobalNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final context = route.navigator?.context;
    if (context != null) {
      ErrorHandler.setContext(context);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final context = previousRoute?.navigator?.context;
    if (context != null) {
      ErrorHandler.setContext(context);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    final context = previousRoute?.navigator?.context;
    if (context != null) {
      ErrorHandler.setContext(context);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final context = newRoute?.navigator?.context;
    if (context != null) {
      ErrorHandler.setContext(context);
    }
  }
}