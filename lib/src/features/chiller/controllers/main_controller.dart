// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/models.dart';
import 'package:recliven_chiller/barrel/services.dart';
import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/barrel/core.dart';

// Este controlador maneja todo lo relacionado a la pantalla principal
class MainController extends GetxController {
  final BluetoothService _bluetoothService = Get.find();
  BluetoothNotificationController controller = Get.find();

  final _status = Rx<RequestState>(RequestState.loading);
  RequestState get status => _status.value;

  RxList<CircuitData> circuitsData = <CircuitData>[].obs;

  int mainDelayMessage = 5;

  // Límites de horas de trabajo
  static const int maxWorkingTime = 65530;
  static const int maintenanceThreshold = 4383; // 6 meses en horas
  static const int warningThreshold = 60000; // Advertencia a las 60000 horas

  @override
  void onInit() {
    super.onInit();
    // Cuando inicia se escuchan los nuevos mensajes que envía el servicio y los maneja
    // en caso de que sean referidos al main los procesa, también se inicia el envío de
    // comandos periódicos
    ever(_bluetoothService.lastMessage, handleBluetoothMessage);
    startPeriodicCommandSending();
  }

  // Para el envío de comandos periódicos
  void startPeriodicCommandSending() {
    _bluetoothService.startPeriodicCommandSending(
        BluetoothConstants.actualizarMain, Duration(seconds: mainDelayMessage));
  }

  // Detiene el envío de comandos periódicos
  void stopPeriodicCommandSending() {
    _bluetoothService.stopPeriodicCommandSending();
  }

  // Reinicia el envío de comandos periódicos
  void resumePeriodicCommandSending() {
    _bluetoothService.resumePeriodicCommandSending(
        BluetoothConstants.actualizarMain, Duration(seconds: mainDelayMessage));
  }

  // Maneja los mensajes entrantes y los compara con los datos que deben de llegar al main
  void handleBluetoothMessage(String data) {
    if (data.contains('R')) {
      processMainData(data);
    } else if (data.contains('Z')) {
      processResetTime(data);
    } else if (data.contains('W')) {
      processToResetEvent(data);
    }
  }

  // Procesa para obtener los datos de los circuitos
  void processMainData(String data) {
    try {
      final parts = data.split('F');
      circuitsData.clear();

      for (final part in parts) {
        if (part.isNotEmpty) {
          final subParts = part.split('S');
          if (subParts.length >= 4) {
            final String idStr = subParts[1];
            final String value1Str = subParts[2];
            final String value2Str = subParts[3];
            if (isNumeric(idStr) &&
                isNumeric(value1Str) &&
                isNumeric(value2Str)) {
              final int id = int.parse(idStr);
              final int value1 = int.parse(value1Str);
              final int value2 = int.parse(value2Str);
              circuitsData.add(CircuitData(id, value1, value2));
              _status.value = RequestState.success;

              // // Actualiza el controlador de monitoreo de circuitos
              // final monitoringController =
              //     Get.find<CircuitMonitoringController>();
              // monitoringController._checkCircuits();
            }
          }
        }
      }
      circuitsData.refresh();
    } catch (e) {
      _status.value = RequestState.error;
    }
  }

  bool isNumeric(String? str) => str != null && int.tryParse(str) != null;

  // Procesa para reiniciar el tiempo de trabajo
  void processResetTime(String message) {
    String circuitId = message[2];
    for (final c in circuitsData) {
      if (c.circuit == int.parse(circuitId)) {
        c.workingTime = 0;
        break;
      }
    }
    circuitsData.refresh();
  }

  // Procesa para reiniciar el fallo
  void processToResetEvent(String message) {
    String circuitId = message[2];
    for (final c in circuitsData) {
      if (c.circuit == int.parse(circuitId)) {
        c.failure = 0;
        break;
      }
    }
    circuitsData.refresh();
  }

  // Para reiniciar tiempo de trabajo
  Future<void> resetWorkingTime(String circuit) async {
    stopPeriodicCommandSending();
    await _bluetoothService
        .sendCommand('${BluetoothConstants.reiniciarTiempo}S${circuit}F');
    resumePeriodicCommandSending();
  }

  // Para reiniciar los fallos
  Future<void> resetEvent(String circuit) async {
    stopPeriodicCommandSending();
    await _bluetoothService
        .sendCommand('${BluetoothConstants.atenderFalla}S${circuit}F');
    resumePeriodicCommandSending();
  }

  // Para conectarse
  void connectToDevice(BluetoothDevice device) {
    _bluetoothService.connectToDeviceWithRetry(device, retries: 3);
  }

  // Para desconectarse
  void disconnectFromDevice() {
    _bluetoothService.disconnect();
  }

  // Muestra diálogo de error
  void showErrorDialog() {
    _bluetoothService.handleConnectionError('Error de conexión');
  }
}


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:get/get.dart';
// import 'package:recliven_chiller/barrel/models.dart';
// import 'package:recliven_chiller/barrel/services.dart';
// import 'package:recliven_chiller/barrel/controllers.dart';
// import 'package:recliven_chiller/barrel/core.dart';

// class MainController extends GetxController {
//   final BluetoothService _bluetoothService = Get.find();
//   BluetoothNotificationController controller = Get.find();

//   final _status = Rx<RequestState>(RequestState.loading);
//   RequestState get status => _status.value;

//   RxList<CircuitData> circuitsData = <CircuitData>[].obs;

//   int mainDelayMessage = 5;

//   static const int maxWorkingTime = 65530;
//   static const int maintenanceThreshold = 4383; // 6 meses en horas
//   static const int warningThreshold = 60000; // Advertencia a las 60000 horas

//   @override
//   void onInit() {
//     super.onInit();
//     ever(_bluetoothService.lastMessage, handleBluetoothMessage);
//     startPeriodicCommandSending();
//   }

//   void startPeriodicCommandSending() {
//     _bluetoothService.startPeriodicCommandSending(
//         BluetoothConstants.actualizarMain, Duration(seconds: mainDelayMessage));
//   }

//   void stopPeriodicCommandSending() {
//     _bluetoothService.stopPeriodicCommandSending();
//   }

//   void resumePeriodicCommandSending() {
//     _bluetoothService.resumePeriodicCommandSending(
//         BluetoothConstants.actualizarMain, Duration(seconds: mainDelayMessage));
//   }

//   void handleBluetoothMessage(String data) {
//     if (data.contains('R')) {
//       processMainData(data);
//     } else if (data.contains('Z')) {
//       processResetTime(data);
//     } else if (data.contains('W')) {
//       processToResetEvent(data);
//     }
//   }

//   void processMainData(String data) {
//     try {
//       final parts = data.split('F');
//       circuitsData.clear();

//       for (final part in parts) {
//         if (part.isNotEmpty) {
//           final subParts = part.split('S');
//           if (subParts.length >= 4) {
//             final String idStr = subParts[1];
//             final String value1Str = subParts[2];
//             final String value2Str = subParts[3];
//             if (isNumeric(idStr) &&
//                 isNumeric(value1Str) &&
//                 isNumeric(value2Str)) {
//               final int id = int.parse(idStr);
//               final int value1 = int.parse(value1Str);
//               final int value2 = int.parse(value2Str);
//               circuitsData.add(CircuitData(id, value1, value2));
//               _status.value = RequestState.success;

//               if (value2 >= maintenanceThreshold) {
//                 showMaintenanceAlert(id, value2);
//               }

//               if (value2 >= warningThreshold) {
//                 showWarningAlert(id, value1, value2);
//               }
//             }
//           }
//         }
//       }
//       circuitsData.refresh();
//     } catch (e) {
//       _status.value = RequestState.error;
//     }
//   }

//   bool isNumeric(String? str) => str != null && int.tryParse(str) != null;

//   void processResetTime(String message) {
//     String circuitId = message[2];
//     for (final c in circuitsData) {
//       if (c.circuit == int.parse(circuitId)) {
//         c.workingTime = 0;
//         break;
//       }
//     }
//     circuitsData.refresh();
//   }

//   void processToResetEvent(String message) {
//     String circuitId = message[2];
//     for (final c in circuitsData) {
//       if (c.circuit == int.parse(circuitId)) {
//         c.failure = 0;
//         break;
//       }
//     }
//     circuitsData.refresh();
//   }

//   Future<void> resetWorkingTime(String circuit) async {
//     stopPeriodicCommandSending();
//     await _bluetoothService
//         .sendCommand('${BluetoothConstants.reiniciarTiempo}S${circuit}F');
//     resumePeriodicCommandSending();
//   }

//   Future<void> resetEvent(String circuit) async {
//     stopPeriodicCommandSending();
//     await _bluetoothService
//         .sendCommand('${BluetoothConstants.atenderFalla}S${circuit}F');
//     resumePeriodicCommandSending();
//   }

//   void connectToDevice(BluetoothDevice device) {
//     _bluetoothService.connectToDeviceWithRetry(device, retries: 3);
//   }

//   void disconnectFromDevice() {
//     _bluetoothService.disconnect();
//   }

//   void showErrorDialog() {
//     _bluetoothService.handleConnectionError('Error de conexión');
//   }

//   void showMaintenanceAlert(int circuitId, int workingHours) {
//     final String message =
//         'El circuito $circuitId ha alcanzado o superado el límite de mantenimiento.\n'
//         'Horas de funcionamiento: $workingHours.\n'
//         'Por favor, realice el mantenimiento necesario.';
//     SnackbarUtils.showWarning('Mantenimiento Necesario', message);
//   }

//   void showWarningAlert(int circuitId, int currentHours, int maxHours) {
//     final int remainingHours = maxHours - currentHours;
//     final String message =
//         'El circuito $circuitId está cerca del límite de horas de funcionamiento.\n'
//         'Horas de funcionamiento actual: $currentHours.\n'
//         'Horas restantes estimadas: $remainingHours.\n'
//         'Recomendamos revisar y considerar el mantenimiento.';
//     SnackbarUtils.showWarning('Advertencia de Horas', message);
//   }
// }


// // // ignore_for_file: avoid_print

// // import 'dart:async';
// // import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// // import 'package:get/get.dart';
// // import 'package:recliven_chiller/barrel/models.dart';
// // import 'package:recliven_chiller/barrel/services.dart';
// // import 'package:recliven_chiller/barrel/controllers.dart';
// // import 'package:recliven_chiller/barrel/core.dart';

// // //este controlador maneja todo lo relacionado a la pantalla principal

// // class MainController extends GetxController {
// //   final BluetoothService _bluetoothService = Get.find();
// //   BluetoothNotificationController controller = Get.find();

// //   final _status = Rx<RequestState>(RequestState.loading);
// //   RequestState get status => _status.value;

// //   RxList<CircuitData> circuitsData = <CircuitData>[].obs;

// //   int mainDelayMessage = 5;

// //   // Límites de horas de trabajo
// //   static const int maxWorkingTime = 65530;
// //   static const int maintenanceThreshold = 4383; // 6 meses en horas
// //   static const int warningThreshold = 60000; // Advertencia a las 60000 horas

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     //cuando inicia se escuchan los nuevos mensajes que envia el servicio y los maneja
// //     //en caso de que sean referidos al main los procesa, tambien se inicia el envio de
// //     //comandos periodicos
// //     ever(_bluetoothService.lastMessage, handleBluetoothMessage);
// //     startPeriodicCommandSending();
// //   }

// //   //para el envio de comandos periodicos
// //   void startPeriodicCommandSending() {
// //     _bluetoothService.startPeriodicCommandSending(
// //         BluetoothConstants.actualizarMain, Duration(seconds: mainDelayMessage));
// //   }

// //   //detiene el envio de comandos periodicos
// //   void stopPeriodicCommandSending() {
// //     _bluetoothService.stopPeriodicCommandSending();
// //   }

// //   //reinicia el envio de comandos periodicos
// //   void resumePeriodicCommandSending() {
// //     _bluetoothService.resumePeriodicCommandSending(
// //         BluetoothConstants.actualizarMain, Duration(seconds: mainDelayMessage));
// //   }

// //   //maneja los mensajes entrantes y los compara con los datos que deben de llegar al main
// //   handleBluetoothMessage(String data) {
// //     if (data.contains('R')) {
// //       processMainData(data);
// //     } else if (data.contains('Z')) {
// //       processResetTime(data);
// //     } else if (data.contains('W')) {
// //       processToResetEvent(data);
// //     }
// //   }

// //   //procesa para obtener los datos de los circuitos
// //   void processMainData(String data) {
// //     try {
// //       final parts = data.split('F');
// //       circuitsData.clear();

// //       for (final part in parts) {
// //         if (part.isNotEmpty) {
// //           final subParts = part.split('S');
// //           if (subParts.length >= 4) {
// //             final String idStr = subParts[1];
// //             final String value1Str = subParts[2];
// //             final String value2Str = subParts[3];
// //             if (isNumeric(idStr) &&
// //                 isNumeric(value1Str) &&
// //                 isNumeric(value2Str)) {
// //               final int id = int.parse(idStr);
// //               final int value1 = int.parse(value1Str);
// //               final int value2 = int.parse(value2Str);
// //               circuitsData.add(CircuitData(id, value1, value2));
// //               _status.value = RequestState.success;

// //               // Verificar si se ha alcanzado el límite de horas de mantenimiento
// //               if (value2 >= maintenanceThreshold) {
// //                 showMaintenanceAlert(id);
// //               }

// //               // Verificar si se ha alcanzado el límite de advertencia de horas
// //               if (value2 >= warningThreshold) {
// //                 showWarningAlert(id, maxWorkingTime - value1);
// //               }
// //             }
// //           }
// //         }
// //       }
// //       circuitsData.refresh();
// //     } catch (e) {
// //       _status.value = RequestState.error;
// //     }
// //   }

// //   bool isNumeric(String? str) => str != null && int.tryParse(str) != null;

// //   //procesa para reiniciar el tiempo de trabajo
// //   void processResetTime(String message) {
// //     String circuitId = message[2];
// //     for (final c in circuitsData) {
// //       if (c.circuit == int.parse(circuitId)) {
// //         c.workingTime = 0;
// //         break;
// //       }
// //     }
// //     circuitsData.refresh();
// //   }

// //   //procesa para reiniciar el fallo
// //   void processToResetEvent(String message) {
// //     String circuitId = message[2];
// //     for (final c in circuitsData) {
// //       if (c.circuit == int.parse(circuitId)) {
// //         c.failure = 0;
// //         break;
// //       }
// //     }
// //     circuitsData.refresh();
// //   }

// //   //para reinicar tiempo de trabajo
// //   Future<void> resetWorkingTime(String circuit) async {
// //     stopPeriodicCommandSending();
// //     await _bluetoothService
// //         .sendCommand('${BluetoothConstants.reiniciarTiempo}S${circuit}F');
// //     resumePeriodicCommandSending();
// //   }

// //   //para reinicar los fallos
// //   Future<void> resetEvent(String circuit) async {
// //     stopPeriodicCommandSending();
// //     await _bluetoothService
// //         .sendCommand('${BluetoothConstants.atenderFalla}S${circuit}F');
// //     resumePeriodicCommandSending();
// //   }

// //   //para conectarse
// //   void connectToDevice(BluetoothDevice device) {
// //     _bluetoothService.connectToDeviceWithRetry(device, retries: 3);
// //   }

// //   //para desconectarse
// //   void disconnectFromDevice() {
// //     _bluetoothService.disconnect();
// //   }

// //   //muestra dialog de error
// //   void showErrorDialog() {
// //     _bluetoothService.handleConnectionError('Error de conexión');
// //   }

// //   //muestra alerta de mantenimiento necesario
// //   void showMaintenanceAlert(int circuitId) {
// //     SnackbarUtils.showWarning('Mantenimiento Necesario',
// //         'El circuito $circuitId requiere mantenimiento.');
// //   }

// //   //muestra advertencia de horas de funcionamiento efectivo
// //   void showWarningAlert(int circuitId, int remainingHours) {
// //     SnackbarUtils.showWarning('Advertencia de Horas',
// //         'Al circuito $circuitId le quedan $remainingHours horas de funcionamiento efectivo.');
// //   }
// // }
