// ignore_for_file: avoid_print
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/services.dart';
import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/barrel/models.dart';
import 'package:recliven_chiller/barrel/core.dart';

class FailuresController extends GetxController {
  final BluetoothService _bluetoothService = Get.find();
  final TimerService _timerService = Get.find();
  BluetoothNotificationController controller = Get.find();
  final failureMonitorService = Get.find<FailureMonitorService>();

  var isCleanning = false.obs;
  var isLoadingTable = false.obs;
  var isUpdating = false.obs;
  var dataLoaded = false.obs; // Estado de carga de datos
  var noDataReceived = false.obs;

  var receivedFailures = 0.0.obs;
  var currentFailureIndex = 0.0.obs;
  var maxNumFailure = 143.obs;

  final int _timeoutSeconds = 5;
  final int _maxAttempts = 1;
  int _attemptCount = 0;

  var isLoadButtonVisible = true.obs;
  var isActionButtonsVisible = false.obs;

  var hasShownSnackbar = false.obs;

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
      dataLoaded.value = true; // Cambiar el estado a cargado
    }
  }

  void updateEvents() {
    if (!isCleanning.value) {
      failureMonitorService.events.clear();
      _initiateLoadingProcess();
      _updateButtonVisibility();
      dataLoaded.value = true;
    }
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
    isUpdating.value = false;
    noDataReceived.value = failureMonitorService.events.isEmpty;
    print('No data received after maximum attempts');
  }

  void _processCleanEvents() {
    try {
      print('Processing clean events');
      dataLoaded.value = false;
      failureMonitorService.events.clear();
      _resetLoadingFlags();
      failureMonitorService.resetMonitoringFlags();
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
          print('fallo, ${currentFailureIndex.value}');
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
    final List<EventsInfoModel> newEvents = [];
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
          final totalEvents = failureMonitorService.events.length;
          final maxFailures = failureMonitorService.maxFailures;

          if (totalEvents < maxFailures) {
            newEvents.add(event);
          } else {
            failureMonitorService.checkFailures();
          }
        }
      }
    }
    failureMonitorService.addEvents(newEvents);
    failureMonitorService.events.refresh();
  }

  void _handleProcessingError() {
    _resetLoadingFlags();
    SnackbarUtils.showError('Error', 'Error al procesar los fallos.');
    print('Error processing load events');
  }

  void _resetLoadingFlags() {
    isLoadingTable.value = false;
    isUpdating.value = false;
    isCleanning.value = false;
    // failureMonitorService.resetMonitoringFlags();
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
    if (isLoadingTable.value) {
      print('Loading timeout');
      _resetLoadingFlags();
      SnackbarUtils.showError('Error', 'Tiempo de carga agotado.');
      noDataReceived.value = failureMonitorService.events.isEmpty;
    } else {
      _timerService.stopTimer('loadingFailureScreenTimer');
    }
  }

  void _cleaningTimeoutAction() {
    if (isCleanning.value) {
      print('Cleaning timeout');
      _resetLoadingFlags();
      SnackbarUtils.showError('Error', 'Tiempo de limpieza agotado.');
      noDataReceived.value = failureMonitorService.events.isEmpty;
    } else {
      _timerService.stopTimer('cleaningTimer');
    }
  }

  void _stopAllTimers() {
    _timerService.stopTimer('loadingFailureScreenTimer');
    _timerService.stopTimer('cleaningTimer');
    // _timerService.stopTimer('updatingFailureScreenTimer');
  }

  void _updateButtonVisibility() {
    // Si se está actualizando, no mostrar el botón de cargar
    if (isUpdating.value) {
      isLoadButtonVisible.value = false;
      isActionButtonsVisible.value = false;
    } else {
      isLoadButtonVisible.value = failureMonitorService.events.isEmpty;
      isActionButtonsVisible.value = failureMonitorService.events.isNotEmpty;
    }
  }
}
