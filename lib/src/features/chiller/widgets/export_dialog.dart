// ignore_for_file: avoid_print

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/models.dart';
import 'package:recliven_chiller/barrel/services.dart';

//muestra dialogo para exportar los archivos

class ExportDialog extends StatefulWidget {
  final List<EventsInfoModel> eventsData;
  final List<String> exportTypeOptions;
  final Function(String) onExport;

  const ExportDialog({
    super.key,
    required this.eventsData,
    required this.exportTypeOptions,
    required this.onExport,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String? selectedExportType;
  @override
  void initState() {
    super.initState();
    selectedExportType = widget.exportTypeOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Exportar tabla de históricos',
          style: TextStyle(
              fontSize: SizeConstants.textSizeLarge,
              fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Selecciona el tipo de archivo:',
              style: TextStyle(fontSize: SizeConstants.textSizeMedium)),
          SizedBox(height: SizeConstants.paddingLarge),
          DropdownButtonFormField<String>(
            value: selectedExportType,
            items: widget.exportTypeOptions.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type,
                    style: TextStyle(fontSize: SizeConstants.textSizeMedium)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedExportType = value;
              });
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.paddingLarge,
                  vertical: SizeConstants.paddingMedium),
            ),
          ),
          SizedBox(height: SizeConstants.paddingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Get.back(); // Cierra el diálogo
                },
                child: Text('Cancelar',
                    style: TextStyle(
                        fontSize: SizeConstants.textSizeMedium,
                        color: AppColors.blackColorWithOpacity)),
              ),
              SizedBox(width: SizeConstants.paddingLarge),
              ElevatedButton(
                onPressed: () {
                  if (selectedExportType != null) {
                    widget.onExport(selectedExportType!);
                    Get.back(); // Cierra el diálogo
                  }
                },
                child: Text('Aceptar',
                    style: TextStyle(
                        fontSize: SizeConstants.textSizeMedium,
                        color: AppColors.primaryColorOrange400)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Directory> getExportDirectory() async {
  Directory? directory = await getExternalStorageDirectory();
  String path = '${directory!.path}/Recliven Chiller exports';
  Directory exportDir = Directory(path);
  if (!await exportDir.exists()) {
    await exportDir.create(recursive: true);
  }
  return exportDir;
}

void showExportDialog(FailureMonitorService controller) {
  if (controller.events.isEmpty) {
    SnackbarUtils.showWarning(
        'Advertencia', 'No hay datos en la tabla para exportar.');
    return;
  }

  Get.dialog(
    ExportDialog(
      eventsData: controller.events,
      exportTypeOptions: const ['Excel', 'TXT'],
      onExport: (selectedType) {
        if (selectedType == 'Excel') {
          exportToExcel(controller);
        } else if (selectedType == 'TXT') {
          exportToTxt(controller);
        }
      },
    ),
  );
}

void exportToExcel(FailureMonitorService controller) async {
  try {
    // Crear un nuevo documento Excel
    Excel excel = Excel.createExcel();

    // Obtener la hoja activa
    Sheet sheet = excel['Events'];

    // Encabezados
    List<String> headers = [
      'Fecha',
      'Hora',
      'Evento',
      'Circuito',
      'Tiempo Acumulado'
    ];
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(bold: true);
    }

    // Agregar datos
    for (int i = 0; i < controller.events.length; i++) {
      var event = controller.events[i];
      Dato dato = Dato(int.parse(event.typeEvento));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(event.dateEvent);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(event.timeEvent);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(dato.descripcionFallos);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = TextCellValue(event.circuitEvent);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(event.accumulatedTime);
    }

    // Obtener la ruta del almacenamiento interno
    Directory exportDir = await getExportDirectory();
    String path = exportDir.path;

    File file = File(
        '$path/Tabla de históricos-${DateTime.now().toIso8601String().replaceAll(':', '-')}.xlsx');

    // Guardar el archivo Excel
    if (await file.exists()) {
      showOverwriteSnackbar(
        'Información',
        'El archivo a exportar ya existe en el dispositivo.',
        true,
        file,
        null,
        excel,
        path,
        // controller
      );
    } else {
      List<int>? fileBytes = excel.save();
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      // Mostrar un mensaje de éxito
      print('Exito al exportar');
      SnackbarUtils.showSuccess(
          'Éxito', 'Tabla de históricos exportada al archivo excel.');
    }
  } on StateError catch (e) {
    print('state error: $e');
  } catch (e) {
    // Mostrar un mensaje de error
    print('No se pudo exportar los fallos a un archivo excel');
    SnackbarUtils.showError(
        'Error', 'Error al exportar la tabla de históricos.');
  }
}

void exportToTxt(FailureMonitorService controller) async {
  try {
    // Obtener la ruta del almacenamiento interno
    Directory exportDir = await getExportDirectory();
    String path = exportDir.path;

    // Crear el archivo
    File file = File(
        '$path/Tabla de históricos-${DateTime.now().toIso8601String().replaceAll(':', '-')}.txt');

    // Escribir los datos en el archivo
    StringBuffer data = StringBuffer();
    for (var event in controller.events) {
      Dato dato = Dato(int.parse(event.typeEvento));
      data.write(
          'Fecha: ${event.dateEvent}, Hora: ${event.timeEvent}, Evento: ${dato.descripcionFallos}, Circuito: ${event.circuitEvent}, Tiempo trabajado: ${event.accumulatedTime}\n');
      // data +=
      //     'Fecha: ${event.dateEvent}, Hora: ${event.timeEvent}, Evento: ${dato.descripcionFallos}, Circuito: ${event.circuitEvent}, Tiempo trabajado: ${event.accumulatedTime}\n';
    }

    if (await file.exists()) {
      showOverwriteSnackbar(
        'Información',
        'El archivo a exportar ya existe en el dispositivo. ¿Qué operación desea realizar?',
        false,
        file,
        data,
        null,
        path,
      );
    } else {
      await file.writeAsString(data.toString());
      SnackbarUtils.showSuccess(
          'Éxito', 'Tabla de históricos exportada al archivo de texto.');
      print('Los fallos se han exportado a la siguiente ubicación: $path');
    }
  } catch (e) {
    SnackbarUtils.showError(
        'Error', 'Error al exportar la tabla de históricos.');
    print('Los fallos se han exportado a la siguiente ubicación: $e');
  }
}

void showOverwriteSnackbar(
  String title,
  String message,
  bool isExcel,
  File file,
  StringBuffer? data,
  Excel? excel,
  String path,
) {
  if (!Get.isSnackbarOpen && !Get.isDialogOpen!) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      titleText: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: SizeConstants.textSizeLarge,
        ),
      ),
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: SizeConstants.textSizeMedium,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    await file.delete();
                    if (isExcel && excel != null) {
                      List<int>? fileBytes = excel.save();
                      file
                        ..createSync(recursive: true)
                        ..writeAsBytesSync(fileBytes!);
                      SnackbarUtils.showSuccess(
                          'Éxito', 'Archivo Excel sobrescrito exitosamente.');
                    } else if (data != null) {
                      await file.writeAsString(data.toString());
                      SnackbarUtils.showSuccess('Éxito',
                          'Archivo de texto sobrescrito exitosamente.');
                    }
                    Get.back();
                  },
                  child: const Text('Sobrescribir'),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back();
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ],
      ),
      isDismissible: false,
      duration: const Duration(minutes: 1),
      backgroundColor: AppColors.primaryColorOrange100,
    );
  }
}
