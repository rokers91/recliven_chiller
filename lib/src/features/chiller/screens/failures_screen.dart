// ignore_for_file: unnecessary_import, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/barrel/models.dart';
import 'package:recliven_chiller/barrel/screens.dart';
import 'package:recliven_chiller/barrel/services.dart';
import 'package:recliven_chiller/barrel/widgets.dart';
import 'package:recliven_chiller/barrel/core.dart';

//pantalla que muestra lo referente a la pantalla de fallos
class FailuresScreen extends GetWidget<FailuresController> {
  FailuresScreen({super.key});

  final BluetoothService _bluetoothService = Get.find();
  final failureMonitorService = Get.find<FailureMonitorService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final connectedDevice = _bluetoothService.connectedDevice.value;
        return connectedDevice != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConstants.paddingLarge),
                  _buildHeader(),
                  SizedBox(height: SizeConstants.paddingMedium),
                  _buildDataTableOrPlaceholder(context),
                ],
              )
            : const NoConnection();
      }),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(SizeConstants.paddingMedium),
      child: Row(
        children: [
          Obx(
            () => controller.isLoadButtonVisible.value &&
                    !controller.dataLoaded.value
                ? _buildLoadButton()
                : controller.isActionButtonsVisible.value
                    ? _buildExportUpdateAndClearButtons()
                    : const SizedBox
                        .shrink(), // Opción para manejar casos inesperados
          )
        ],
      ),
    );
  }

  //boton de cargar los datos
  Widget _buildLoadButton() {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          controller.loadEvents();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.backgroundColor,
          backgroundColor: AppColors.primaryColorOrange300,
          minimumSize: Size(double.infinity, SizeConstants.buttonLarge),
        ),
        child: Text(
          'Cargar datos',
          style: TextStyle(fontSize: SizeConstants.textSizeMedium),
        ),
      ),
    );
  }

  //boton de actualizar, exportar y limpiar los datos
  Widget _buildExportUpdateAndClearButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            if (!controller.isCleanning.value ||
                !controller.isLoadingTable.value) {
              if (!Get.isSnackbarOpen &&
                  failureMonitorService.events.isNotEmpty) {
                showExportDialog(failureMonitorService);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.backgroundColor,
            backgroundColor: AppColors.primaryColorOrange300,
            minimumSize:
                Size(SizeConstants.buttonSmall, SizeConstants.buttonLarge),
          ),
          child: Text(
            'Exportar',
            style: TextStyle(fontSize: SizeConstants.textSizeMedium),
          ),
        ),
        SizedBox(width: SizeConstants.paddingSmall),
        ElevatedButton(
          onPressed: () async {
            if (!Get.isSnackbarOpen) {
              final currentFailures = failureMonitorService.events.length;
              final maxFailures = failureMonitorService.maxFailures;

              if (currentFailures < maxFailures) {
                // await Future.delayed(const Duration(seconds: 2));
                controller.isUpdating.value = true;
                controller.updateEvents();
              } else if (currentFailures >= maxFailures) {
                SnackbarUtils.showPersistentWarningSnackbar(
                  'Advertencia',
                  'La tabla de fallos está llena. \nPor favor guarde los fallos existentes para evitar pérdida de información y luego proceda a limpiar la tabla.',
                  onAccept: () {
                    Get.back();
                  },
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.backgroundColor,
            backgroundColor: AppColors.primaryColorOrange300,
            minimumSize:
                Size(SizeConstants.buttonSmall, SizeConstants.buttonLarge),
          ),
          child: Text(
            'Actualizar',
            style: TextStyle(fontSize: SizeConstants.textSizeMedium),
          ),
        ),
        SizedBox(width: SizeConstants.paddingSmall),
        ElevatedButton(
          onPressed: () async {
            if (!Get.isSnackbarOpen) {
              showCustomDialog(
                  title: 'Confirmación',
                  content:
                      '¿Estás seguro de que desea limpiar la tabla de históricos?. Esta acción no se puede deshacer.',
                  isFailureDialog: false,
                  issues: null,
                  hasCancel: true,
                  todo: () {
                    controller.clearData();
                    controller.hasShownSnackbar.value = false;
                    Get.back();
                  });
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.backgroundColor,
            backgroundColor: AppColors.primaryColorOrange300,
            minimumSize:
                Size(SizeConstants.buttonSmall, SizeConstants.buttonLarge),
          ),
          child: Text(
            'Limpiar',
            style: TextStyle(fontSize: SizeConstants.textSizeMedium),
          ),
        ),
      ],
    );
  }

  //contruccion de la tabla de fallos o no datos
  Widget _buildDataTableOrPlaceholder(BuildContext context) {
    bool isLoading =
        controller.isCleanning.value || controller.isLoadingTable.value;

    return isLoading
        ? Expanded(
            child: LoadingIndicator(
              isLoading: isLoading,
              loadingKey:
                  controller.isCleanning.value ? 'cleaning' : 'loadingData',
              color: AppColors.primaryColorOrange300,
            ),
          )
        : failureMonitorService.events.isEmpty
            ? !controller.dataLoaded.value
                ? _buildEmptyPlaceholder()
                : const SizedBox.shrink()
            : _buildDataTable(context);
  }

  //widget de no datos en la tabla
  Widget _buildEmptyPlaceholder() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConstants.paddingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_off_rounded,
                size: SizeConstants.iconSizeSuperLarge,
                color: AppColors.grey,
              ),
              SizedBox(height: SizeConstants.paddingMedium),
              Text(
                'No hay datos',
                style: TextStyle(
                    fontSize: SizeConstants.textSizeLarge,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: SizeConstants.paddingMedium,
              ),
              Text(
                'La tabla está vacía, por favor presione cargar datos.',
                style: TextStyle(
                    fontSize: SizeConstants.textSizeMedium,
                    color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //se construyen los elementos de la tabla
  Widget _buildDataTable(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(SizeConstants.paddingMedium),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(SizeConstants.borderRadiusMedium),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SizeConstants.borderRadiusMedium),
                  color: AppColors.primaryColorOrange400,
                ),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.8);
                      }
                      return AppColors.primaryColorOrange400;
                    },
                  ),
                  columnSpacing: SizeConstants.columnSpacing,
                  dividerThickness: 2.0,
                  border: TableBorder.all(
                    borderRadius:
                        BorderRadius.circular(SizeConstants.borderRadiusMedium),
                    color: Colors.blue.shade700,
                    // style: BorderStyle.solid,
                  ),
                  columns: _buildColumns(),
                  rows: _buildRows(context, failureMonitorService.events),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //se construye la columna de la tabla
  List<DataColumn> _buildColumns() {
    TextStyle columnTitlesStyles = TextStyle(
      fontSize: SizeConstants.textSizeMedium,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
    );

    return [
      DataColumn(
        label: Text(
          'No',
          style: columnTitlesStyles,
          textAlign: TextAlign.center,
        ),
      ),
      DataColumn(
        label: Text('Fecha',
            style: columnTitlesStyles, textAlign: TextAlign.center),
      ),
      DataColumn(
        label: Text('Hora',
            style: columnTitlesStyles, textAlign: TextAlign.center),
      ),
      DataColumn(
        label: Text('Fallo',
            style: columnTitlesStyles, textAlign: TextAlign.center),
      ),
      DataColumn(
        label: Text('Circuito',
            style: columnTitlesStyles, textAlign: TextAlign.center),
      ),
      DataColumn(
        label: Text('Acumulado (h)',
            style: columnTitlesStyles, textAlign: TextAlign.center),
      ),
    ];
  }

  //se construye las filas de la tabla
  List<DataRow> _buildRows(BuildContext context, List<EventsInfoModel> events) {
    return List<DataRow>.generate(events.length, (index) {
      final event = events[index];
      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
            }
            return AppColors.primaryColorOrange100;
          },
        ),
        cells: _buildCells(event, index),
      );
    });
  }

  //se construyen las celdas de la tabla
  List<DataCell> _buildCells(EventsInfoModel event, int index) {
    double tableRowTextSize = SizeConstants.tableRowTextSize;
    Dato dato = Dato(int.parse(event.typeEvento));
    List<String> fallos =
        dato.descripcionFallos.split(',').map((e) => e.trim()).toList();

    return [
      DataCell(Center(
        child: Text(
          (index + 1).toString(), // Mostrar el índice de la fila
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: tableRowTextSize),
        ),
      )),
      DataCell(Center(
        child: Text(
          event.dateEvent,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: tableRowTextSize),
        ),
      )),
      DataCell(Center(
        child: Text(
          event.timeEvent,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: tableRowTextSize),
        ),
      )),
      DataCell(
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight:
                    SizeConstants.imageHeightLarge), // ajusta según necesites
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: fallos.map((fallo) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeConstants.paddingMinumus),
                    child: Text(
                      fallo,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: tableRowTextSize),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      DataCell(Center(
        child: Text(
          event.circuitEvent,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: tableRowTextSize),
        ),
      )),
      DataCell(Center(
        child: Text(
          event.accumulatedTime,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: tableRowTextSize),
        ),
      )),
    ];
  }
}

// Widget _buildLoadButton() {
//   return Visibility(
//     visible: controller.events.isEmpty,
//     child: Expanded(
//       child: ElevatedButton(
//         onPressed: () async {
//           controller.isLoadingTable.value = true;
//           controller.isVisibleLoad.value = true;
//           await Future.delayed(const Duration(seconds: 2));
//           controller.loadEvents();
//         },
//         style: ElevatedButton.styleFrom(
//           foregroundColor: AppColors.backgroundColor,
//           backgroundColor: AppColors.primaryColorOrange300,
//           minimumSize: Size(double.infinity, SizeConstants.buttonLarge),
//         ),
//         child: Text(
//           'Cargar datos',
//           style: TextStyle(fontSize: SizeConstants.textSizeMedium),
//         ),
//       ),
//     ),
//   );
// }

// } else if (controller.events.isEmpty) {
//   return
// } else if (controller.events.isNotEmpty) {
//   return _buildDataTable(context);
// } else {
//   return _buildEmptyPlaceholder();
// }

// if (isLoading) {
//   return Expanded(
//     child: LoadingIndicator(
//       isLoading: isLoading,
//       loadingKey: controller.isCleanning.value ? 'cleaning' : 'loadingData',
//       color: AppColors.primaryColorOrange300,
//     ),
//   );
// } else if (controller.events.isEmpty) {
//   return _buildEmptyPlaceholder();
// } else if (controller.events.isNotEmpty) {
//   return _buildDataTable(context);
// } else {
//   return _buildEmptyPlaceholder();
// }

    // onPressed: () async {
          //   if (!Get.isSnackbarOpen) {
          //     if (failureMonitorService.events.length <=
          //         failureMonitorService.maxFailures) {
          //       controller.isUpdatingTable.value = true;
          //       await Future.delayed(const Duration(seconds: 2));
          //       controller.updateEvents();
          //     }
          //     if (failureMonitorService.events.length >
          //         failureMonitorService.maxFailures) {
          //       SnackbarUtils.showPersistentWarningSnackbar(
          //         'Advertencia',
          //         'La tabla de fallos está llena. \nPor favor guarde los fallos existentes para evitar pérdida de información y luego proceda a limpiar la tabla.',
          //         onAccept: () {
          //           Get.back();
          //         },
          //       );
          //     }
          //   }
          // },