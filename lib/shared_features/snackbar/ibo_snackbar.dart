import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class IboSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.primary,
        duration: duration,
        behavior: behavior,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, backgroundColor: AppColors.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message, backgroundColor: AppColors.error);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message, backgroundColor: AppColors.warning);
  }

  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
