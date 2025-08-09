import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import 'hex_color.dart';

class Utility {
  static restartApp() {
    Globals.myApp.currentState?.onRestart();
  }

  static refreshApp() {
    Globals.myApp.currentState?.onRefresh();
  }

  static closeApp() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  static hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static fieldFocus(BuildContext context, FocusNode? focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  static toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primary,
        textColor: Colors.white);
  }

  static copyText(BuildContext context, String text,
      {String? message = "Copied to Clipboard"}) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (message != null) toast(message);
    });
  }

  static configKeyboardActions(List<KeyboardActionsItem> actions) {
    return KeyboardActionsConfig(
        keyboardBarColor: Colors.grey[200],
        actions: actions);
  }

  static KeyboardActionsItem buildKeyboardAction(FocusNode node,
      {String text = "Done", GestureTapCallback? onTap}) {
    return KeyboardActionsItem(focusNode: node, toolbarButtons: [
      (node) => InkWell(
            onTap: onTap ?? () => node.unfocus(),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
    ]);
  }

  static changeStatusBarColor(Color color, bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light));
  }

  static launch(String? url) {
    if ((url ?? "").isEmpty) {
      return;
    }
    urlLauncher.launchUrl(
      Uri.parse(url!),
      mode: urlLauncher.LaunchMode.externalApplication,
    );
  }

  static googleMap(String? lat, String? lng) async {
    launch(
        "https://www.google.com/maps/search/${lat ?? "0.0"},${lng ?? "0.0"}");
  }

  static String jsonToString(dynamic event) {
    return json.encode(event);
  }

  static dynamic stringToJson(String? event) {
    if (event == null || event == "") return null;
    return json.decode(event);
  }

  static String formatDate(DateTime? event, {DateFormat? format}) {
    if (event == null) {
      return "";
    }

    return (format ?? AppFormat.date).format(event);
  }

  static DateTime? parseDate(String? event, {DateFormat? parse}) {
    if ((event ?? "").isEmpty) {
      return null;
    }

    return (parse ?? AppFormat.dateTimeResponse).parse(event!);
  }

  static String formatMoney(double? event, {NumberFormat? format}) {
    if (event == null) {
      return "";
    }

    return (format ?? AppFormat.quantity).format(event);
  }

  static double parseMoney(String? event,
      {NumberFormat? parse, double? defaultValue}) {
    if ((event ?? "").isEmpty) {
      return defaultValue ?? 0.0;
    }

    return (parse ?? AppFormat.quantity).parse(event!) as double? ??
        defaultValue ??
        0.0;
  }

  static Color stringToColor(String? event, {Color? defaultColor}) {
    return (event ?? "").isEmpty
        ? (defaultColor ?? AppColors.primary)
        : HexColor(event);
  }

  static customPrint(dynamic object) {
    if (Globals.config.displayPrint!) {
      log(object.toString());
    }
  }

  static double getWidthOfItemPerRow(BuildContext context, int itemPerRow,
      {double? padding, double? separate}) {
    return (AppSizes.screenSize(context).width -
            (padding ?? AppSizes.maxPadding) * 2 -
            ((itemPerRow - 1) * (separate ?? AppSizes.minPadding)) -
            1) /
        itemPerRow;
  }

}

