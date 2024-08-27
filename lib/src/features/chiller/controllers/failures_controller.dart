// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/services.dart';
import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/barrel/models.dart';
import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/widgets.dart';

class FailuresController extends GetxController {
  final BluetoothService _bluetoothService = Get.find();
  final TimerService _timerService = Get.find();
  BluetoothNotificationController controller = Get.find();

  RxList<EventsInfoModel> events = <EventsInfoModel>[].obs;
  var isCleanning = false.obs;
  var isLoadingTable = false.obs;
  var isUpdatingTable = false.obs;
  var noDataReceived = false.obs;
  var maxTotalFailures = 143.obs;
  var receivedFailures = 0.0.obs;
  var currentFailureIndex = 0.0.obs;

  final int _timeoutSeconds = 5;
  final int _maxAttempts = 1;
  int _attemptCount = 0;

  var isLoadButtonVisible = true.obs;
  var isActionButtonsVisible = false.obs;

  @override
  void onInit() {
    _bluetoothService.responseStream.listen(handleBluetoothMessage);
    super.onInit();
  }

  @override
  void onClose() {
    _stopAllTimers();
    super.onClose();
  }

  // Método para configurar el estado de carga de la tabla
  void setLoadingTable(bool isLoading) {
    isLoadingTable.value = isLoading;
  }

  // Método para cargar eventos con retraso simulado
  Future<void> loadEventsWithDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    loadEvents();
    setLoadingTable(false); // Detiene el indicador de carga
  }

  void handleBluetoothMessage(String message) {
    print('Received Bluetooth message: $message');
    _stopAllTimers();

    if (message.startsWith('L')) {
      _handleLoadMessage(message);
    } else if (message.startsWith('S')) {
      _processLoadEvents(message);
    } else if (message.contains('E')) {
      _processCleanEvents();
    }

    _updateButtonVisibility();
  }

  void _handleLoadMessage(String message) {
    final total = double.tryParse(message.substring(2, message.length - 1));
    if (total != null) {
      receivedFailures.value = total;
      isLoadingTable.value = true;
      print('Total failures set to $total');
      _startTimer('loadingFailureScreenTimer', _loadingTimeoutAction);
    }
  }

  void loadEvents() {
    if (!isCleanning.value) {
      _initiateLoadingProcess();
      _updateButtonVisibility();
    }
  }

  void updateEvents() {
    if (!isCleanning.value) {
      events.clear();
      _initiateLoadingProcess();
      _updateButtonVisibility();
    }
  }

  void _initiateLoadingProcess() {
    isLoadingTable.value = true;
    noDataReceived.value = false;
    _attemptCount = 0;
    _sendLoadCommand();
    _startTimer('loadingFailureScreenTimer', _loadingTimeoutAction);
  }

  void _sendLoadCommand() {
    if (_attemptCount < _maxAttempts) {
      _attemptCount++;
      print('Sending load command');
      _bluetoothService.sendCommand(BluetoothConstants.loadEvents);
      _startTimer('loadingFailureScreenTimer', _loadingTimeoutAction);
    } else {
      _handleNoDataReceived();
    }
  }

  void _handleNoDataReceived() {
    isLoadingTable.value = false;
    isUpdatingTable.value = false;
    noDataReceived.value = events.isEmpty;
    print('No data received after maximum attempts');
  }

  void clearData() {
    if (!isLoadingTable.value) {
      isCleanning.value = true;
      print('Sending clear command');
      _bluetoothService.sendCommand(BluetoothConstants.eraseEvents);
      _startTimer('cleaningTimer', _cleaningTimeoutAction);
    } else {
      isCleanning.value = false;
    }
    _updateButtonVisibility();
  }

  void _processCleanEvents() {
    try {
      print('Processing clean events');
      events.clear();
      _resetLoadingFlags();
      SnackbarUtils.showSuccess('Éxito', 'Tabla de históricos eliminada.');
    } catch (e) {
      _resetLoadingFlags();
      SnackbarUtils.showError(
          'Error', 'Error al eliminar la tabla de históricos.');
    }
  }

  void _processLoadEvents(String data) {
    try {
      print('Processing load events: $data');
      if (data.contains('F')) {
        _resetLoadingFlags();
      } else {
        _addEvents(data);
        currentFailureIndex.value++;
        if (currentFailureIndex.value < receivedFailures.value) {
          print('Fallo, $currentFailureIndex');
          _sendLoadCommand();
        } else {
          _resetLoadingFlags();
        }
      }
      update();
    } catch (e) {
      _handleProcessingError();
    }
  }

  void _addEvents(String data) {
    final parts = data.split('T');
    for (final part in parts) {
      if (part.isNotEmpty) {
        final subParts = part.split('S');
        if (subParts.length >= 6) {
          final event = EventsInfoModel(
            dateEvent: subParts[1],
            timeEvent: formatTime(subParts[2]),
            typeEvento: subParts[3],
            circuitEvent: subParts[4],
            accumulatedTime: subParts[5],
          );
          events.add(event);
          print('Event added: ${event.dateEvent}, ${event.timeEvent}');
          if (events.length >= maxTotalFailures * 0.85) {
            SnackbarUtils.showWarning('Advertencia',
                'Queda poco espacio en la tabla, por favor guarde los datos.');
          } else if (events.length >= maxTotalFailures.value) {
            showCustomDialog(
                'Advertencia',
                'A llegado al límite de fallos permitidos en la tabla, por lo que puede que halla perdida de datos. Presione confirmar para salir de este dialogo',
                false, () {
              Get.back();
            });
          }
        }
      }
    }
  }

  void _handleProcessingError() {
    _resetLoadingFlags();
    SnackbarUtils.showError('Error', 'Error al procesar los fallos.');
    print('Error processing load events');
  }

  void _resetLoadingFlags() {
    isLoadingTable.value = false;
    isUpdatingTable.value = false;
    isCleanning.value = false;
  }

  String formatTime(String rawTime) {
    final parts = rawTime.split(':');
    if (parts.length == 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return rawTime;
  }

  void _startTimer(String timerName, Function() action) {
    _timerService.startTimer(
        timerName, Duration(seconds: _timeoutSeconds), action);
  }

  void _loadingTimeoutAction() {
    if (isLoadingTable.value || isUpdatingTable.value) {
      print('Loading timeout');
      _resetLoadingFlags();
      SnackbarUtils.showError('Error', 'Tiempo de carga agotado.');
      noDataReceived.value = events.isEmpty;
    } else {
      _timerService.stopTimer('loadingFailureScreenTimer');
    }
  }

  void _cleaningTimeoutAction() {
    if (isCleanning.value) {
      print('Cleaning timeout');
      _resetLoadingFlags();
      SnackbarUtils.showError('Error', 'Tiempo de limpieza agotado.');
      noDataReceived.value = events.isEmpty;
    } else {
      _timerService.stopTimer('cleaningTimer');
    }
  }

  void _stopAllTimers() {
    _timerService.stopTimer('loadingFailureScreenTimer');
    _timerService.stopTimer('cleaningTimer');
    _timerService.stopTimer('updatingFailureScreenTimer');
  }

  void _updateButtonVisibility() {
    isLoadButtonVisible.value = events.isEmpty;
    isActionButtonsVisible.value = events.isNotEmpty;
  }
}




// // ignore_for_file: avoid_print

// import 'package:get/get.dart';
// import 'package:recliven_chiller/barrel/services.dart';
// import 'package:recliven_chiller/barrel/controllers.dart';
// import 'package:recliven_chiller/barrel/models.dart';
// import 'package:recliven_chiller/barrel/core.dart';

// class FailuresController extends GetxController {
//   final BluetoothService _bluetoothService = Get.find();
//   final TimerService _timerService = Get.find();
//   BluetoothNotificationController controller = Get.find();

//   RxList<EventsInfoModel> events = <EventsInfoModel>[].obs;

//   var isCleanning = false.obs;
//   var isLoadingTable = false.obs;
//   var isUpdatingTable = false.obs;
//   var noDataReceived = false.obs;
//   var maxTotalFailures = 143.0.obs; // Modificación para que sea un RxInt
//   var receivedFailures = 0.0.obs;
//   var currentFailureIndex = 0.0.obs;

//   final int _cleaningTimeoutSeconds = 5;
//   final int _loadingTimeoutSeconds = 5;
//   final int _maxAttempts = 1;
//   int _attemptCount = 0;

//   // Nuevas variables para manejar la visibilidad de los botones
//   var isLoadButtonVisible = true.obs;
//   var isActionButtonsVisible = false.obs;

//   @override
//   void onInit() {
//     _bluetoothService.responseStream.listen(handleBluetoothMessage);
//     super.onInit();
//   }

//   @override
//   void onClose() {
//     _timerService.stopTimer('loadingFailureScreenTimer');
//     _timerService.stopTimer('cleaningTimer');
//     _timerService.stopTimer('updatingFailureScreenTimer');
//     super.onClose();
//   }

//   void handleBluetoothMessage(String message) {
//     print('Received Bluetooth message: $message');
//     _timerService.stopTimer('loadingFailureScreenTimer');
//     _timerService.stopTimer('updatingFailureScreenTimer');

//     if (message.startsWith('L')) {
//       final total = double.tryParse(message.substring(2, message.length - 1));
//       if (total != null) {
//         receivedFailures.value = total;
//         isLoadingTable.value = true;
//         print('Total failures set to $total');
//         _startLoadingTimer();
//       }
//     } else if (message.startsWith('S')) {
//       processToLoadEvents(message);
//     } else if (message.contains('E')) {
//       processToCleanEvents();
//     }
//     // Actualizar visibilidad de los botones
//     _updateButtonVisibility();
//   }

//   void _updateButtonVisibility() {
//     if (events.isEmpty) {
//       isLoadButtonVisible.value = true;
//       isActionButtonsVisible.value = false;
//     } else {
//       isLoadButtonVisible.value = false;
//       isActionButtonsVisible.value = true;
//     }
//   }

//   void loadEvents() {
//     if (!isCleanning.value) {
//       isLoadingTable.value = true;
//       noDataReceived.value = false;
//       _attemptCount = 0;
//       _sendLoadCommand();
//       _startLoadingTimer();
//       _updateButtonVisibility();
//     }
//   }

//   void updateEvents() {
//     if (!isCleanning.value) {
//       events.clear();
//       isUpdatingTable.value = true;
//       noDataReceived.value = false;
//       _attemptCount = 0;
//       _sendLoadCommand();
//       _startLoadingTimer();
//       _updateButtonVisibility();
//     }
//   }

//   void _sendLoadCommand() {
//     if (_attemptCount < _maxAttempts) {
//       _attemptCount++;
//       isLoadingTable.value = true;
//       isUpdatingTable.value = true;
//       print('Sending load command'); // Debug log
//       _bluetoothService.sendCommand(BluetoothConstants.loadEvents);
//       _startLoadingTimer();
//     } else {
//       isLoadingTable.value = false;
//       isUpdatingTable.value = false;
//       noDataReceived.value = events.isEmpty;
//       print('No data received after maximum attempts'); // Debug log
//     }
//   }

//   void clearData() {
//     if (!isLoadingTable.value) {
//       isCleanning.value = true;
//       print('Sending clear command'); // Debug log
//       _bluetoothService.sendCommand(BluetoothConstants.eraseEvents);
//       _startCleaningTimer();
//     } else {
//       isCleanning.value = false;
//     }
//     _updateButtonVisibility();
//   }

//   void processToCleanEvents() {
//     try {
//       print('Processing clean events'); // Debug log
//       events.clear();
//       isCleanning.value = false;
//       isLoadingTable.value = false;
//       isUpdatingTable.value = false;
//       SnackbarUtils.showSuccess('Éxito', 'Tabla de históricos eliminada.');
//       _timerService.stopTimer('cleaningTimer');
//     } catch (e) {
//       isCleanning.value = false;
//       isLoadingTable.value = false;
//       isUpdatingTable.value = false;
//       SnackbarUtils.showError('Error',
//           'Se ha producido un error al eliminar la tabla de históricos.');
//     }
//   }

//   void processToLoadEvents(String data) {
//     try {
//       print('Processing load events: $data'); // Debug log
//       if (data.contains('F')) {
//         isLoadingTable.value = false;
//         isUpdatingTable.value = false;
//       } else {
//         final parts = data.split('T');
//         for (final part in parts) {
//           if (part.isNotEmpty) {
//             final subParts = part.split('S');
//             if (subParts.length >= 6) {
//               final String dateEvent = subParts[1];
//               final String rawTimeEvent = subParts[2];
//               final String typeEvent = subParts[3];
//               final String circuit = subParts[4];
//               final String accumulatedTime = subParts[5];
//               final timeEvent = formatTime(rawTimeEvent);
//               events.add(EventsInfoModel(
//                 dateEvent: dateEvent,
//                 timeEvent: timeEvent,
//                 typeEvento: typeEvent,
//                 circuitEvent: circuit,
//                 accumulatedTime: accumulatedTime,
//               ));
//               print('Event added: $dateEvent, $timeEvent'); // Debug log

//               // Check if the table is reaching 95% capacity
//               if (events.length >= maxTotalFailures * 0.85) {
//                 SnackbarUtils.showWarning('Advertencia',
//                     'Queda poco espacio en la tabla, por favor guarde los datos.');
//               }
//             }
//           }
//         }
//         currentFailureIndex.value++;
//         if (currentFailureIndex.value < receivedFailures.value) {
//           print('Fallo, $currentFailureIndex');
//           _sendLoadCommand();
//         } else {
//           isLoadingTable.value = false;
//           isUpdatingTable.value = false;
//         }
//       }
//       update();
//     } catch (e) {
//       isLoadingTable.value = false;
//       isUpdatingTable.value = false;
//       isCleanning.value = false;
//       SnackbarUtils.showError('Error', 'Error al procesar los fallos.');
//       print('Error processing load events: $e'); // Debug log
//     }
//   }

//   String formatTime(String rawTime) {
//     final parts = rawTime.split(':');
//     if (parts.length == 2) {
//       final hours = parts[0].padLeft(2, '0');
//       final minutes = parts[1].padLeft(2, '0');
//       return '$hours:$minutes';
//     }
//     return rawTime;
//   }

//   void _startCleaningTimer() {
//     _timerService.startTimer(
//         'cleaningTimer', Duration(seconds: _cleaningTimeoutSeconds), () {
//       if (isCleanning.value) {
//         print('Cleaning timeout'); // Debug log
//         isCleanning.value = false;
//         isLoadingTable.value = false;
//         SnackbarUtils.showError('Error', 'Tiempo de limpieza agotado.');
//         noDataReceived.value = events.isEmpty;
//       } else {
//         _timerService.stopTimer('cleaningTimer');
//       }
//     });
//   }

//   void _startLoadingTimer() {
//     _timerService.startTimer(
//         'loadingFailureScreenTimer', Duration(seconds: _loadingTimeoutSeconds),
//         () {
//       if (isLoadingTable.value || isUpdatingTable.value) {
//         print('Loading timeout');
//         isLoadingTable.value = false;
//         isUpdatingTable.value = false;
//         SnackbarUtils.showError('Error', 'Tiempo de carga agotado.');
//         noDataReceived.value = events.isEmpty;
//       } else {
//         _timerService.stopTimer('loadingFailureScreenTimer');
//       }
//     });
//   }
// }
