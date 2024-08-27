// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/services.dart';
import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/barrel/core.dart';

// Controlador de la pantalla settings
class SettingsController extends GetxController {
  final BluetoothService _bluetoothService = Get.find();
  final TimerService _timerService = Get.find();
  BluetoothNotificationController controller = Get.find();

  final Rx<RequestState> _status = Rx<RequestState>(RequestState.noChange);
  RequestState get status => _status.value;

  // Definen los TextEditingControllers y FocusNodes
  final setpointTempController = TextEditingController().obs;
  final difTotalController = TextEditingController().obs;
  final numEsclavosController = TextEditingController().obs;
  final anticicloCortoController = TextEditingController().obs;
  final startingFlowController = TextEditingController().obs;

  final setpointTempFocus = FocusNode();
  final difTotalFocus = FocusNode();
  final numEsclavosFocus = FocusNode();
  final anticicloCortoFocus = FocusNode();
  final startingFlowFocus = FocusNode();

  final currentConfig = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSettings();
  }

  void _initializeSettings() async {
    _status.value = RequestState.loading;
    await Future.delayed(const Duration(seconds: 2));
    _bluetoothService.sendCommand(BluetoothConstants.tramaInicial);
    ever(_bluetoothService.lastMessage, _handleBluetoothMessage);
  }

  @override
  void onClose() {
    _disposeControllersAndFocusNodes();
    // Detener el temporizador al recibir una respuesta válida
    _timerService.stopTimer('settingsLoadingTimer');
    super.onClose();
  }

  void _disposeControllersAndFocusNodes() {
    setpointTempController.value.dispose();
    difTotalController.value.dispose();
    numEsclavosController.value.dispose();
    anticicloCortoController.value.dispose();
    startingFlowController.value.dispose();

    setpointTempFocus.dispose();
    difTotalFocus.dispose();
    numEsclavosFocus.dispose();
    anticicloCortoFocus.dispose();
    startingFlowFocus.dispose();
  }

  void unfocusTextFields() {
    setpointTempFocus.unfocus();
    difTotalFocus.unfocus();
    numEsclavosFocus.unfocus();
    anticicloCortoFocus.unfocus();
    startingFlowFocus.unfocus();
  }

  Future<void> sendConfigToDevice(String dataFrame) async {
    if (_isConfigSame()) {
      _showNoChangeMessage();
    } else {
      await _updateDeviceConfig(dataFrame);
    }
  }

  bool _isConfigSame() {
    final configParts = currentConfig.value.split('S');
    if (configParts.length < 6) {
      print(
          'La configuración actual no tiene suficientes partes: $configParts');
      return false;
    }

    // Limpiar los valores recibidos y los de los controladores de espacios en blanco y caracteres no deseados
    final setpointTemp = setpointTempController.value.text.trim();
    final difTotal = difTotalController.value.text.trim();
    final numEsclavos = numEsclavosController.value.text.trim();
    final anticicloCorto = anticicloCortoController.value.text.trim();
    final startingFlow = startingFlowController.value.text.trim();
    // final receivedAnticicloCorto = configParts[4].replaceAll('F', '').trim();
    final receivedStartingFlow = configParts[5].replaceAll('F', '').trim();

    final isSame = setpointTemp == configParts[1] &&
        difTotal == configParts[2] &&
        numEsclavos == configParts[3] &&
        anticicloCorto == configParts[4] &&
        startingFlow == receivedStartingFlow;

    // Logs detallados con longitud y valores en formato delimitado
    print('Comparación de Configuraciones:');
    print(
        'Setpoint Temp: "$setpointTemp" (${setpointTemp.length}) == "${configParts[1]}" (${configParts[1].length})');
    print(
        'Dif Total: "$difTotal" (${difTotal.length}) == "${configParts[2]}" (${configParts[2].length})');
    print(
        'Num Esclavos: "$numEsclavos" (${numEsclavos.length}) == "${configParts[3]}" (${configParts[3].length})');
    print(
        'Anticiclo Corto: "$anticicloCorto" (${anticicloCorto.length}) == "${configParts[4]}" (${{
      configParts[4]
    }.length})');
    print(
        'Starting Flow: "$startingFlow" (${startingFlow.length}) == "$receivedStartingFlow" (${receivedStartingFlow.length})');
    print('¿Son iguales?: $isSame');

    return isSame;
  }

  void _showNoChangeMessage() {
    SnackbarUtils.showInfo(
      'Información',
      'La configuración no ha sido modificada.',
    );
    _status.value = RequestState.noChange;
  }

  Future<void> _updateDeviceConfig(String dataFrame) async {
    try {
      _status.value = RequestState.loading;
      await Future.delayed(const Duration(seconds: 2));
      _bluetoothService.sendCommand(dataFrame);
      currentConfig.value = dataFrame;
      _status.value = RequestState.success;
    } catch (e) {
      _status.value = RequestState.error;
    }
  }

  void _handleBluetoothMessage(String data) async {
    try {
      print('Mensaje Bluetooth Recibido: $data');
      if (_isValidData(data)) {
        currentConfig.value = data;
        _processData(data);
        if (_areAllFieldsEmpty()) {
          SnackbarUtils.showWarning('Advertencia', 'Los campos están vacíos.');
        } else {
          SnackbarUtils.showSuccess('Éxito', 'Configuración actualizada.');
        }
      } else {
        _status.value = RequestState.error;
      }
    } catch (e) {
      print('Error al procesar el mensaje Bluetooth: $e');
      _status.value = RequestState.error;
      SnackbarUtils.showError(
          'Error', 'Se ha producido un error inesperado al actualizar');
    } finally {
      _status.value = RequestState.noChange;
    }
  }

  bool _isValidData(String data) {
    return data.contains('I') || data.contains('U');
  }

  void _processData(String data) {
    final parts = data.split('F');
    for (final part in parts.where((part) => part.isNotEmpty)) {
      final subParts = part.split('S');
      if (subParts.length >= 6) {
        print('SubParts procesados: $subParts');
        _updateControllers(subParts);
        _status.value = RequestState.success;
      }
    }
  }

  void _updateControllers(List<String> subParts) {
    setpointTempController.value.text = subParts[1];
    difTotalController.value.text = subParts[2];
    numEsclavosController.value.text = subParts[3];
    anticicloCortoController.value.text = subParts[4];
    startingFlowController.value.text = subParts[5].replaceAll('F', '');
  }

  bool _areAllFieldsEmpty() {
    return setpointTempController.value.text.isEmpty &&
        difTotalController.value.text.isEmpty &&
        numEsclavosController.value.text.isEmpty &&
        anticicloCortoController.value.text.isEmpty &&
        startingFlowController.value.text.isEmpty;
  }
}
