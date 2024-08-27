import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/services.dart';
import 'package:recliven_chiller/barrel/widgets.dart';
import 'package:recliven_chiller/barrel/core.dart';

// muestra el sheet para conectarse al bluetooth, etc

void showBluetoothConnectionsSheetOptions(BluetoothService bluetoothService) {
  ScrollController scrollController = ScrollController();
  double sheetHeight = 0.4.sh; // Altura mínima del bottomSheet
  double maxSheetHeight =
      0.9.sh; // Altura máxima a la que se puede expandir el bottomSheet

  Get.bottomSheet(
    SingleChildScrollView(
      controller: scrollController,
      child: Container(
        padding: EdgeInsets.all(SizeConstants.paddingLarge),
        constraints: BoxConstraints(
          minHeight: sheetHeight,
          maxHeight: maxSheetHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bluetooth',
                    style: TextStyle(
                        fontSize: SizeConstants.textSizeLarge,
                        fontWeight: FontWeight.bold)),
                Obx(() {
                  return IconButton(
                    onPressed: (!bluetoothService.bluetoothStateBool.value)
                        ? null
                        : () async {
                            await bluetoothService
                                .openBluetoothSettings()
                                .whenComplete(() => bluetoothService.bluetooth
                                    .setPairingRequestHandler(null));
                            bluetoothService.setPairing();

                            // Get.back();
                          },
                    icon: Obx(() {
                      return Icon(
                        Icons.settings,
                        size: SizeConstants.iconSizeMedium,
                        color: (!bluetoothService.bluetoothStateBool.value)
                            ? AppColors.grey
                            : AppColors.blackColorWithOpacity,
                      );
                    }),
                  );
                }),
              ],
            ),
            SizedBox(height: SizeConstants.paddingMedium),
            Obx(() {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColorOrange400,
                  borderRadius:
                      BorderRadius.circular(SizeConstants.borderRadiusMedium),
                ),
                child: ListTile(
                  title: Obx(() => Text(
                      bluetoothService.bluetoothStateBool.value
                          ? 'Conectado'
                          : 'Desconectado',
                      style: const TextStyle(color: Colors.white))),
                  trailing: Switch(
                    value: bluetoothService.bluetoothStateBool.value,
                    activeColor: AppColors.primaryColorOrange100,
                    onChanged: (value) {
                      bluetoothService.toggleBluetooth();
                      bluetoothService.bluetoothStateBool.value = value;
                    },
                  ),
                ),
              );
            }),
            SizedBox(height: SizeConstants.paddingMedium),
            Obx(() {
              if (bluetoothService.bluetoothStateBool.value) {
                return const Column(
                  children: [
                    Divider(),
                    SingleChildScrollView(
                      child: BondedDevicesList(),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    ),
    backgroundColor: Colors.white,
    isScrollControlled: true, // Habilita el control de scroll
    enableDrag: true, // Permite que el bottomSheet sea arrastrable
    isDismissible:
        true, // Permite cerrar el bottomSheet al hacer clic fuera de él
  );
}
