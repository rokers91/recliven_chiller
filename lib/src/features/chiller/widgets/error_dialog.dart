import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/screens.dart';
import 'package:recliven_chiller/barrel/services.dart';

//muestra dialogo de error en la conexion
class ErrorDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;

  const ErrorDialogWidget({
    super.key,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: SizeConstants.textSizeLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: SizeConstants.textSizeMedium,
        ),
      ),
      actions: actions.isNotEmpty
          ? actions
          : [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Aceptar'),
              ),
            ],
    );
  }
}

void showErrorDialog() {
  BluetoothService controller = Get.find();
  if (!Get.isDialogOpen! && !Get.isSnackbarOpen) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: ErrorDialogWidget(
          title: 'Error de conexión',
          message:
              'Se ha producido un error en la conexión. Verifique si el dispositivo se encuentra disponible para conexión.',
          actions: [
            TextButton(
              onPressed: () {
                controller.disconnect();
                Get.back();
                Get.off(() => const MainScreen());
                Get.off(() => SettingsScreen());
                Get.off(() => FailuresScreen());
                Get.to(() => const NoConnection());
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }
}
