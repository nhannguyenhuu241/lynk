import 'package:flutter/material.dart';
import 'package:lynk_an/common/analystic.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/extension.dart';
import 'package:lynk_an/common/utils/progress_dialog.dart';
import 'package:lynk_an/common/widgets/widget.dart';

class CustomNavigator {
  static push(
      BuildContext context,
      Widget screen, {
        bool root = true,
        bool opaque = true,
        AnimationType animationType = AnimationType.normal,
      }) {
    if (opaque) {
      Analysis.accessApplication(screen);
    }
    Navigator.of(context, rootNavigator: root).removeHUD();
    return Navigator.of(context, rootNavigator: root).push(
      opaque
      // Truyền animationType vào CustomRoute
          ? CustomRoute(page: screen, animationType: animationType)
          : CustomRouteDialog(page: screen),
    );
  }

  static pop(BuildContext? context, {dynamic object, bool root = true}) {
    if (object == null)
      Navigator.of(context!, rootNavigator: root).pop();
    else
      Navigator.of(context!, rootNavigator: root).pop(object);
  }
  static popToScreen(BuildContext context, Widget screen, {bool root = true}) {
    Navigator.of(context, rootNavigator: root).popUntil(
            (route) => route.settings.name == screen.runtimeType.toString());
  }

  static popToRoot(BuildContext context, {bool root = true}) {
    Navigator.of(context, rootNavigator: root)
        .popUntil((route) => route.isFirst);
  }

  static canPop(BuildContext context) {
    ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    return parentRoute?.canPop ?? false;
  }

  static pushReplacement(
      BuildContext context,
      Widget screen, {
        bool root = true,
        bool isHero = false,
        AnimationType animationType = AnimationType.normal,
      }) {
    Analysis.accessApplication(screen);
    Navigator.of(context, rootNavigator: root).removeHUD();
    Navigator.of(context, rootNavigator: root).pushReplacement(
      isHero ? CustomRouteHero(page: screen) : CustomRoute(page: screen, animationType: animationType),
    );
  }

  static popToRootAndPushReplacement(
      BuildContext context,
      Widget screen, {
        bool root = true,
        bool isHero = false,
        AnimationType animationType = AnimationType.normal,
      }) {
    Analysis.accessApplication(screen);
    Navigator.of(context, rootNavigator: root).popUntil((route) => route.isFirst);
    Navigator.of(context, rootNavigator: root).pushReplacement(
      isHero
          ? CustomRouteHero(page: screen)
          : CustomRoute(page: screen, animationType: animationType),
    );
  }

  static ProgressDialog? _pr;
  static showProgressDialog(BuildContext? context) {
    if (_pr == null) {
      _pr = ProgressDialog(context);
      _pr!.show();
    }
  }

  static hideProgressDialog() {
    if (_pr != null && _pr!.isShowing()) {
      _pr!.hide();
      _pr = null;
    }
  }

}