import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';

//util para conformar los snackbar que se emplean en la app para los diferentes casos, error, exito, info
class SnackbarUtils {
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: AppColors.primaryColorOrange100,
      colorText: AppColors.blackColorWithOpacity,
      icon: Icon(Icons.check_circle, color: AppColors.greenColor400),
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String title, String message) {
    if (!Get.isSnackbarOpen && !Get.isDialogOpen!) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColorOrange100,
        colorText: AppColors.blackColorWithOpacity,
        snackStyle: SnackStyle.FLOATING,
        icon: Icon(Icons.error,
            color: AppColors.backgroundColor,
            size: SizeConstants.iconSizeMedium),
        duration: const Duration(seconds: 3),
      );
    }
  }

  static void showInfo(String title, String message) {
    if (!Get.isSnackbarOpen && !Get.isDialogOpen!) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColorOrange100,
        colorText: AppColors.blackColorWithOpacity,
        snackStyle: SnackStyle.FLOATING,
        icon: Icon(Icons.info,
            color: AppColors.backgroundColor,
            size: SizeConstants.iconSizeMedium),
        duration: const Duration(seconds: 3),
      );
    }
  }

  static void showWarning(String title, String message) {
    if (!Get.isSnackbarOpen && !Get.isDialogOpen!) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColorOrange100,
        snackStyle: SnackStyle.FLOATING,
        colorText: AppColors.blackColorWithOpacity,
        icon: Icon(Icons.warning,
            color: AppColors.backgroundColor,
            size: SizeConstants.iconSizeMedium),
        duration: const Duration(seconds: 3),
      );
    }
  }

  static void showOverwriteSnackbar(
    String title,
    String message,
    bool isExcel,
    File file,
    String? data,
    Excel? excel,
    String path,
  ) {
    if (!Get.isSnackbarOpen && !Get.isDialogOpen!) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColorOrange100,
        colorText: AppColors.blackColorWithOpacity,
        snackStyle: SnackStyle.FLOATING,
        icon: Icon(Icons.info,
            color: AppColors.backgroundColor,
            size: SizeConstants.iconSizeMedium),
        duration: const Duration(seconds: 3),
      );
    }
  }
}
