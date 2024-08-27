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
      borderRadius: 8,
      margin: EdgeInsets.all(SizeConstants.paddingMedium),
      isDismissible: false,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.redAccentColor,
        size: 28, // Tamaño del icono
      ),
      // Añadir un borde alrededor del Snackbar
      borderWidth: 2, // Ancho de la línea del borde
      borderColor: AppColors.redAccentColor, // Color del borde
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
          // Título con estilo sin subrayado
          Text(
            title,
            style: TextStyle(
              color: AppColors.redAccentColor,
              fontSize: SizeConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none, // Sin subrayado
            ),
          ),
          const SizedBox(height: 5), // Espacio entre el título y el contenido
          // Contenido
          Text(
            content,
            style: TextStyle(
              color: AppColors.blackColorWithOpacity,
              fontSize: SizeConstants.textSizeMedium,
              height: 1.4, // Altura de línea para mejorar la legibilidad
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 10), // Espacio entre el contenido y el botón
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (onAccept != null) {
                  onAccept(); // Ejecuta la función pasada como callback
                }
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: AppColors.redAccentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // static void showPersistentWarningSnackbar(String title, String content,
  //     {VoidCallback? onAccept}) {
  //   Get.snackbar(
  //     title,
  //     '',
  //     snackPosition: SnackPosition.BOTTOM,
  //     snackStyle: SnackStyle.FLOATING,
  //     backgroundColor: AppColors.primaryColorOrange100,
  //     colorText: AppColors.blackColorWithOpacity,
  //     duration: const Duration(days: 365),
  //     borderRadius: 8,
  //     margin: EdgeInsets.all(SizeConstants.paddingMedium),
  //     isDismissible: false,
  //     icon: const Icon(
  //       Icons.warning_amber_rounded,
  //       color: AppColors.redAccentColor,
  //     ),
  //     messageText: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           content,
  //           style: const TextStyle(color: AppColors.blackColorWithOpacity),
  //           textAlign: TextAlign.justify,
  //         ),
  //         const SizedBox(height: 10), // Espacio entre el texto y el botón
  //         Align(
  //           alignment: Alignment.centerRight,
  //           child: TextButton(
  //             onPressed: () {
  //               if (onAccept != null) {
  //                 onAccept(); // Ejecuta la función pasada como callback
  //               }
  //               Get.back(); // Cierra el Snackbar
  //             },
  //             child: const Text(
  //               'Aceptar',
  //               style: TextStyle(color: AppColors.redAccentColor),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
