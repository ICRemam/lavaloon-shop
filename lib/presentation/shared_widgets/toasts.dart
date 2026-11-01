import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/data/constants/color_constants.dart';
import 'package:lavaloon_assessment/presentation/config/routes.dart';

class Toasts {
  static void showToast({required String customMsg, Color? backgroundColor}) {
    final messenger = Routes.messengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(customMsg),
          backgroundColor: backgroundColor ?? ColorConstants.normalDarkToast,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 2500),
        ),
      );
  }

  static void showError(String? message) {
    showToast(customMsg: message ?? 'Something went wrong.', backgroundColor: ColorConstants.errorToast);
  }

  static void showSuccess(String message) {
    showToast(customMsg: message, backgroundColor: ColorConstants.successColor);
  }
}
