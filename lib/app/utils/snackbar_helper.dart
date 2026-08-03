import 'package:flutter/material.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';

class AppSnackBarHelper {
  AppSnackBarHelper._();

  static GlobalKey<NavigatorState>? _navigatorKey;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static void show({
    required String title,
    required String message,
    bool isError = false,
    Duration? duration,
    IconData? icon,
    AppSnackbarType? type,
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    AppSnackbarManager.showSnackbar(
      context: context,
      title: title,
      message: message,
      type: type ?? (isError ? AppSnackbarType.error : AppSnackbarType.success),
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
  }

  static void success({required String title, required String message}) {
    show(title: title, message: message, type: AppSnackbarType.success);
  }

  static void info({required String title, required String message}) {
    inform(title: title, message: message);
  }

  static void inform({required String title, required String message}) {
    show(title: title, message: message, type: AppSnackbarType.inform);
  }

  static void error({required String title, required String message}) {
    show(title: title, message: message, type: AppSnackbarType.error);
  }
}
