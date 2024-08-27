// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/services.dart';

//se muestra la lista de dispositivos vinculados
class BondedDevicesList extends StatefulWidget {
  const BondedDevicesList({super.key});

  @override
  State<BondedDevicesList> createState() => _BondedDevicesListState();
}

class _BondedDevicesListState extends State<BondedDevicesList> {
  final BluetoothService _bluetoothService = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _bluetoothService.getBondedDevices();
      return Padding(
        padding: EdgeInsets.symmetric(vertical: SizeConstants.paddingMedium),
        child: _bluetoothService.bondedDevices.isEmpty
            ? Text(
                'Dispositivos vinculados no encontrados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: SizeConstants.textSizeMedium),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dispositivos Vinculados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConstants.textSizeLarge,
                    ),
                  ),
                  SizedBox(height: SizeConstants.paddingMedium),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _bluetoothService.bondedDevices.length,
                    itemBuilder: (context, index) {
                      final device = _bluetoothService.bondedDevices[index];
                      return DeviceTile(
                        device: device,
                        bluetoothService: _bluetoothService,
                      );
                    },
                  ),
                ],
              ),
      );
    });
  }
}

class DeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final BluetoothService _bluetoothService;

  const DeviceTile({
    required this.device,
    required BluetoothService bluetoothService,
    super.key,
  }) : _bluetoothService = bluetoothService;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // && controller.isConnected
      final isConnected = _bluetoothService.connectedDevice.value == device;
      final isConnecting = _bluetoothService.isConnecting.value;
      return ListTile(
        title: Text(
          device.name ?? '',
          style: TextStyle(
            fontSize: SizeConstants.textSizeMedium,
            color: AppColors.blackColor,
          ),
        ),
        subtitle: Text(
          device.address,
          style: const TextStyle(
            color: AppColors.blackColorWithOpacity,
          ),
        ),
        trailing: Text(
          isConnected ? 'Conectado' : 'Conectar',
          style: TextStyle(
            color: isConnected
                ? AppColors.primaryColorOrange400
                : isConnecting
                    ? AppColors.grey500
                    : AppColors.grey,
            fontSize: SizeConstants.textSizeMedium,
          ),
        ),
        onTap: () async {
          if (!isConnected) {
            if (_bluetoothService.isConnected.value) {
              SnackbarUtils.showInfo('Conexión activa',
                  'Ya está conectado al dispositivo ${_bluetoothService.connectedDevice.value?.name}.');
              print('Ya esta conectado');
            } else {
              Get.back();
              await _bluetoothService.connectToDevice(device);
              // controller.disconnectFromDevice();
            }
          } else {
            await _bluetoothService.disconnect();
            _bluetoothService.disableDataSubscription();
          }
        },
      );
    });
  }
}
