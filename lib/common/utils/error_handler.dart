import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lynk_an/common/widgets/lynk_error_dialog.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';

class ErrorHandler {
  static BuildContext? _currentContext;

  static void setContext(BuildContext context) {
    _currentContext = context;
  }

  static void clearContext() {
    _currentContext = null;
  }

  static void handleDioError(DioException error) {
    if (_currentContext == null || !_currentContext!.mounted) return;

    String? errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = AppLocalizations.text(LangKey.timeout_error);
        break;
      case DioExceptionType.connectionError:
        errorMessage = AppLocalizations.text(LangKey.connection_error);
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          errorMessage = AppLocalizations.text(LangKey.token_expired);
        } else if (statusCode == 500) {
          errorMessage = AppLocalizations.text(LangKey.server_error);
        } else {
          errorMessage = null; // Use default message
        }
        break;
      default:
        errorMessage = null; // Use default message
    }

    // Show custom error dialog
    if (_currentContext!.mounted) {
      LynkErrorDialog.show(_currentContext!, message: errorMessage);
    }
  }

  static void handleException(dynamic exception) {
    if (_currentContext == null || !_currentContext!.mounted) return;

    if (exception is DioException) {
      handleDioError(exception);
    } else {
      // Show generic error dialog
      if (_currentContext!.mounted) {
        LynkErrorDialog.show(_currentContext!);
      }
    }
  }
}