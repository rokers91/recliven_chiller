
// import 'package:get/get.dart';
// import 'package:recliven_chiller/barrel/core.dart';
// import 'package:recliven_chiller/barrel/models.dart';

// import 'package:recliven_chiller/barrel/controllers.dart';

// class MaintenanceController extends GetxController {
//   final MainController _mainController = Get.find();

//   // Almacena el último tiempo de trabajo para cada circuito
//   final RxMap<int, int> _lastWorkingTimes = <int, int>{}.obs;
//   final RxSet<int> _alertedCircuits = <int>{}.obs; // Circuitos que ya han mostrado alertas

//   @override
//   void onInit() {
//     super.onInit();
//     ever(_mainController.circuitsData, _checkCircuits);
//   }

//   // Verifica el estado de los circuitos y muestra alertas según el umbral
//   void _checkCircuits(List<CircuitData> circuitsData) {
//     final circuitsToWarn = <CircuitData>[];
//     final circuitsToAlert = <CircuitData>[];

//     for (final circuit in circuitsData) {
//       final lastWorkingTime = _lastWorkingTimes[circuit.circuit] ?? 0;
      
//       if (circuit.workingTime > lastWorkingTime) {
//         _lastWorkingTimes[circuit.circuit] = circuit.workingTime;

//         // Clasifica los circuitos para advertencia o mantenimiento
//         if (circuit.workingTime >= MainController.warningThreshold) {
//           circuitsToWarn.add(circuit);
//           if (circuit.workingTime >= MainController.maintenanceThreshold) {
//             circuitsToAlert.add(circuit);
//           }
//         }
//       }
//     }

//     // Muestra las alertas adecuadas
//     if (circuitsToAlert.isNotEmpty) {
//       _showMaintenanceDialog(circuitsToAlert);
//     } else if (circuitsToWarn.isNotEmpty) {
//       _showWarningSnackbar(circuitsToWarn);
//     }
//   }

//   // Muestra un diálogo para los circuitos que requieren mantenimiento
//   void _showMaintenanceDialog(List<CircuitData> circuits) {
//     final circuitIds = circuits.map((c) => 'Circuito ${c.circuit}').join(', ');
//     final content = 'Los siguientes circuitos requieren mantenimiento: $circuitIds';

//     if (!_alertedCircuits.contains(circuits.first.circuit)) {
//       _alertedCircuits.addAll(circuits.map((c) => c.circuit));
//       showCustomDialog(
//         'Mantenimiento Necesario',
//         content,
//         false,
//         () {
//           // Acción para ser ejecutada cuando se acepta el diálogo
//           Get.back();
//         },
//       );
//     }
//   }

//   // Muestra un snackbar para los circuitos que están cerca del umbral de advertencia
//   void _showWarningSnackbar(List<CircuitData> circuits) {
//     final circuitIds = circuits.map((c) => 'Circuito ${c.circuit}').join(', ');
//     final content = 'Los siguientes circuitos están cerca del límite de funcionamiento: $circuitIds';

//     if (!_alertedCircuits.contains(circuits.first.circuit)) {
//       _alertedCircuits.addAll(circuits.map((c) => c.circuit));
//       if (!Get.isSnackbarOpen!) {
//         SnackbarUtils.showWarning(
//           'Advertencia de Horas',
//           content,
//         );
//       }
//     }
//   }
// }


// // import 'package:get/get.dart';
// // import 'package:recliven_chiller/barrel/models.dart';
// // import 'package:recliven_chiller/barrel/controllers.dart';
// // import 'package:recliven_chiller/barrel/core.dart';
// // import 'package:recliven_chiller/barrel/widgets.dart';

// // class CircuitMonitoringController extends GetxController {
// //   final MainController _mainController = Get.find();

// //   // Límites de horas de trabajo
// //   static const int maintenanceThreshold = 4383; // 6 meses en horas
// //   static const int warningThreshold = 60000; // Advertencia a las 60000 horas

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     // Se observa cualquier cambio en los datos de circuitos
// //     ever(_mainController.circuitsData, checkCircuitTimes);
// //   }

// //   // Verifica los tiempos de trabajo de los circuitos
// //   void checkCircuitTimes(List<CircuitData> circuits) {
// //     for (final circuit in circuits) {
// //       if (circuit.workingTime >= warningThreshold) {
// //         _showCriticalAlert(circuit);
// //       } else if (circuit.workingTime >= maintenanceThreshold) {
// //         _showWarningSnackbar(circuit);
// //       }
// //     }
// //   }

// //   // Muestra un diálogo para los casos críticos
// //   void _showCriticalAlert(CircuitData circuit) {
// //     final content =
// //         'El circuito ${circuit.circuit} ha superado el límite crítico de horas de funcionamiento.';

// //     showCustomDialog(
// //       'Alerta Crítica',
// //       content,
// //       false,
// //       () {
// //         // Acción para ser ejecutada cuando se acepta el diálogo
// //         Get.back();
// //       },
// //     );
// //   }

// //   // Muestra un Snackbar para advertencias menos graves
// //   void _showWarningSnackbar(CircuitData circuit) {
// //     final content =
// //         'El circuito ${circuit.circuit} ha superado el límite de mantenimiento.';

// //     SnackbarUtils.showWarning(
// //       'Advertencia de Mantenimiento',
// //       content,
// //     );
// //   }
// // }
