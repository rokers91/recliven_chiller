import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';

//dialogo personalizado para los diferentes casos de uso en la app, salida, reinicio de tiempo, etc.
class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback todo;
  final bool hasCancelar;
  const CustomDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.todo,
      required this.hasCancelar});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
            fontSize: SizeConstants.textSizeLarge, fontWeight: FontWeight.bold),
      ),
      content: Text(
        content,
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: SizeConstants.textSizeMedium),
      ),
      actions: <Widget>[
        hasCancelar
            ? TextButton(
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                      fontSize: SizeConstants.textSizeMedium,
                      color: AppColors.blackColorWithOpacity),
                ),
                onPressed: () {
                  Get.back();
                },
              )
            : const SizedBox.shrink(),
        ElevatedButton(
          onPressed: todo,
          child: Text(
            'Aceptar',
            style: TextStyle(
                fontSize: SizeConstants.textSizeMedium,
                color: AppColors.primaryColorOrange400),
          ),
        ),
      ],
    );
  }
}

void showCustomDialog(
    String title, String content, bool hasCancel, VoidCallback todo) {
  if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
    Get.dialog(
      WillPopScope(
        // canPop: false,
        onWillPop: () async {
          return false;
        },
        child: CustomDialog(
          title: title,
          content: content,
          hasCancelar: hasCancel,
          todo: todo,
        ),
      ),
    );
  }
}
