// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/models.dart';

class FailureMonitorService extends GetxService {
  final RxList<EventsInfoModel> events = <EventsInfoModel>[].obs;
  final int maxFailures = 143;
  final RxBool hasShownWarning80 = false.obs;
  final RxBool hasShownMaxLimitWarning = false.obs;

  void addEvents(List<EventsInfoModel> newEvents) {
    events.addAll(newEvents);
    checkFailures();
  }

  void checkFailures() {
    final totalEvents = events.length;

    if (totalEvents >= maxFailures * 0.8 && totalEvents < maxFailures * 0.99) {
      if (!hasShownWarning80.value) {
        print('*****************************estoy ejecutandome en el servicio');
        _showWarning(
          'Advertencia',
          'Queda poco espacio en la tabla, por favor guarde los fallos para evitar pérdida de información.',
        );
        hasShownWarning80.value = true;
      }
    }

    if (totalEvents >= maxFailures) {
      if (!hasShownMaxLimitWarning.value) {
        print('*****************************estoy ejecutandome en el servicio');

        _showWarning(
          'Advertencia',
          'La tabla de fallos está llena. \nPor favor guarde los fallos existentes para evitar pérdida de información y luego proceda a limpiar la tabla.',
        );
        hasShownMaxLimitWarning.value = true;
      }
    }
  }

  void _showWarning(String title, String message) {
    SnackbarUtils.showPersistentWarningSnackbar(
      title,
      message,
      onAccept: () {
        Get.back();
      },
    );
  }

  void resetMonitoringFlags() {
    hasShownWarning80.value = false;
    hasShownMaxLimitWarning.value = false;
  }
}
