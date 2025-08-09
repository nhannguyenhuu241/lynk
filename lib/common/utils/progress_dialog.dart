library progress_dialog;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../theme.dart';
import 'custom_navigator.dart';

class ProgressDialog {
  bool _isShowing = false;

  BuildContext? buildContext;

  ProgressDialog(this.buildContext);

  show() {
    _showDialog();
    _isShowing = true;
  }

  bool isShowing() {
    return _isShowing;
  }

  hide() {
    _isShowing = false;
    CustomNavigator.pop(buildContext);
  }

  _showDialog() {
    Navigator.of(buildContext!, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        settings: RouteSettings(name: AppKeys.keyHUD),
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return PopScope(
            child: Scaffold(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              body: Container(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Platform.isAndroid?CircularProgressIndicator(
                    color: AppColors.primary,
                  ):CupertinoActivityIndicator(),
                ),
              ),
            ),
            canPop: false,
          );
        },
      ),
    );
  }
}