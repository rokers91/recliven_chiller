import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/controllers.dart';

import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/screens.dart';
import 'package:recliven_chiller/barrel/services.dart';
import 'package:recliven_chiller/barrel/widgets.dart';

// Pantalla que muestra lo referente a la configuración del master

class SettingsScreen extends GetWidget<SettingsController> {
  SettingsScreen({super.key});

  final BluetoothService _bluetoothService = Get.find();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.status) {
        case RequestState.loading:
          return LoadingIndicator(
            loadingKey: 'settings',
            color: AppColors.primaryColorOrange300,
            isLoading: true,
          );
        case RequestState.error:
          return SingleChildScrollView(
            child: _buildSettingsContent(),
          );
        case RequestState.noChange:
        case RequestState.success:
          if (_bluetoothService.connectedDevice.value != null) {
            return SingleChildScrollView(
              child: _buildSettingsContent(),
            );
          } else {
            return const NoConnection();
          }
        default:
          return SingleChildScrollView(
            child: _buildSettingsContent(),
          );
      }
    });
  }

  Widget _buildSettingsContent() {
    return Padding(
      padding: EdgeInsets.all(SizeConstants.paddingLarge),
      child: _settingsForm(),
    );
  }

  Form _settingsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsContainer(
            children: [
              _updateButton(),
              SizedBox(height: SizeConstants.paddingMedium),
              _buildSettingItem(
                label: 'Temperatura del Setpoint (°C)',
                focus: controller.setpointTempFocus,
                controller: controller.setpointTempController.value,
                hintText: '6 - 15',
              ),
              _buildSettingItem(
                label: 'Diferencial Total (°C)',
                focus: controller.difTotalFocus,
                controller: controller.difTotalController.value,
                hintText: '5 - 10',
              ),
              _buildSettingItem(
                label: 'Número de Esclavos',
                focus: controller.numEsclavosFocus,
                controller: controller.numEsclavosController.value,
                hintText: '1 - 8',
              ),
              _buildSettingItem(
                label: 'Tiempo Anticiclo Corto (min)',
                focus: controller.anticicloCortoFocus,
                controller: controller.anticicloCortoController.value,
                hintText: '4 - 10',
              ),
              _buildSettingItem(
                label: 'Tiempo flujo de arranque (min)',
                focus: controller.startingFlowFocus,
                controller: controller.startingFlowController.value,
                hintText: '1 - 10',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _updateButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final setpointTemp = controller.setpointTempController.value.text;
          final difTotal = controller.difTotalController.value.text;
          final numEsclavos = controller.numEsclavosController.value.text;
          final anticicloCorto = controller.anticicloCortoController.value.text;
          final startFlow = controller.startingFlowController.value.text;

          final dataFrame = 'US$setpointTemp'
              'S$difTotal'
              'S$numEsclavos'
              'S$anticicloCorto'
              'S$startFlow'
              'F';

          controller.unfocusTextFields();
          await controller.sendConfigToDevice(dataFrame);
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.backgroundColor,
        backgroundColor: AppColors.primaryColorOrange300,
        minimumSize: Size(double.infinity, SizeConstants.buttonLarge),
      ),
      child: Text(
        'Actualizar',
        style: TextStyle(fontSize: SizeConstants.textSizeLarge),
      ),
    );
  }

  Widget _buildSettingItem({
    required String label,
    required FocusNode focus,
    required TextEditingController controller,
    required String hintText,
  }) {
    final hintValues = hintText.split(' - ');
    final minValue = int.parse(hintValues[0]);
    final maxValue = int.parse(hintValues[1]);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConstants.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: SizeConstants.textSizeSmall,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: SizeConstants.paddingSmall),
          Padding(
            padding: EdgeInsets.symmetric(vertical: SizeConstants.paddingSmall),
            child: TextFormField(
              controller: controller,
              focusNode: focus,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: hintText,
                labelStyle: TextStyle(fontSize: SizeConstants.textSizeSmall),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SizeConstants.iconSizeSmall)),
                filled: true,
                fillColor: AppColors.backgroundColor,
                contentPadding: EdgeInsets.symmetric(
                  vertical: SizeConstants.paddingSmall,
                  horizontal: SizeConstants.paddingMedium,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo no puede estar vacío';
                }
                final numericValue = int.tryParse(value);
                if (numericValue == null ||
                    numericValue < minValue ||
                    numericValue > maxValue) {
                  return 'Debe estar entre $minValue y $maxValue';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsContainer extends StatelessWidget {
  final List<Widget> children;

  const SettingsContainer({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.primaryColorOrange100,
        borderRadius: BorderRadius.circular(SizeConstants.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
