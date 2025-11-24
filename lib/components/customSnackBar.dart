import 'package:flutter/material.dart';
import 'package:sonoris/theme/colors.dart';

class CustomSnackBar {
  static SnackBar show({
    required String message,
    Color backgroundColor = AppColors.blue500,
    Duration duration = const Duration(seconds: 2),
    Color textColor = AppColors.white100,
  }) {
    return SnackBar(
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      content: Text(message, style: TextStyle(color: textColor)),
    );
  }

  static SnackBar success(String message) {
    return show(message: message, backgroundColor: AppColors.blue500);
  }

  static SnackBar error(String message) {
    return show(message: message, backgroundColor: AppColors.rose500);
  }
}
