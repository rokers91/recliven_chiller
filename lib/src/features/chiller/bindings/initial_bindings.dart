import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/barrel/services.dart';

//se maneja el inicio de los controladores de la app

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(PermissionService());
    Get.put(BluetoothService());
    Get.put(TimerService());
    Get.put(BluetoothNotificationController());

    Get.put(MainController());

    Get.lazyPut<MyTabController>(() => MyTabController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<FailuresController>(() => FailuresController());
    // Get.lazyPut<CircuitMonitoringController>(
    //     () => CircuitMonitoringController());
  }
}
