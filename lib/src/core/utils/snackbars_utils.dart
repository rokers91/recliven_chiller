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

  static void showPersistentWarningSnackbar(String title, String content,
      {VoidCallback? onAccept}) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: AppColors.primaryColorOrange100,
      colorText: AppColors.blackColorWithOpacity,
      duration: const Duration(days: 365),
      borderRadius: SizeConstants.borderRadiusMedium,
      margin: EdgeInsets.all(SizeConstants.paddingMedium),
      isDismissible: false,
      // icon: Icon(
      //   Icons.warning_amber_rounded,
      //   color: AppColors.redAccentColor,
      //   size: SizeConstants.iconSizeLarge, // Tamaño del icono
      // ),
      borderWidth: SizeConstants.borderRadiusMinimus,
      borderColor: AppColors.backgroundColor,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.redAccentColor,
              fontSize: SizeConstants.textSizeMedium,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: SizeConstants.paddingMedium),
          Text(
            content,
            style: TextStyle(
              color: AppColors.blackColorWithOpacity,
              fontSize: SizeConstants.textSizeSmall,
              height: 1.4,
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: SizeConstants.paddingMedium),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (onAccept != null) {
                  onAccept();
                }
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                    color: AppColors.redAccentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConstants.textSizeSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
