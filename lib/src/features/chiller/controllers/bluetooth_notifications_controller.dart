import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';
import '../services/bluetooth_service.dart';

//este controlador se emplea para el manejo de los mensajes cuando se
// produce la conexion/desconexion del dispositivo conectado

class BluetoothNotificationController extends GetxController {
  final BluetoothService _bluetoothService = Get.find();
  @override
  void onInit() {
    super.onInit();
    //se escucha si se esta conectado o no
    ever(_bluetoothService.isConnected, handleConnectionState);
  }

  //se maneja en dependencia del estado de la variable isConnected
  void handleConnectionState(bool isConnected) {
    if (isConnected) {
      SnackbarUtils.showSuccess('Conectado', 'El dispositivo se ha conectado.');
    } else {
      _bluetoothService.disconnect();
      SnackbarUtils.showError(
          'Desconectado', 'El dispositivo se encuentra desconectado.');
    }
  }
}
