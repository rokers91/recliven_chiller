import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/barrel/models.dart';
import 'package:recliven_chiller/barrel/widgets.dart';

//se conforma la tarjeta en la que se muestra la info de los circuitos

class CircuitStateInfo extends StatelessWidget {
  final int id;
  final CircuitData circuitData;
  final MainController controller;

  const CircuitStateInfo({
    super.key,
    required this.circuitData,
    required this.id,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    Dato dato = Dato(circuitData.failure);
    bool isCircuitOn = dato.isOn;
    String estadoCircuito = dato.descripcionFallos;
    List<String> fallos =
        dato.descripcionFallos.split(',').map((e) => e.trim()).toList();

    const totalTime = 65530;

    // Calcular el porcentaje de tiempo trabajado
    double workingTimePercentage = (circuitData.workingTime / totalTime) * 100;

    // Determinar el color basado en el porcentaje de tiempo trabajado
    Color workingTimeColor;
    if (workingTimePercentage < 50) {
      workingTimeColor = AppColors.primaryColorBlue;
    } else if (workingTimePercentage < 90) {
      workingTimeColor = AppColors.yellowColor;
    } else {
      workingTimeColor = AppColors.redAccentColor;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Card(
              color: AppColors.primaryColorOrange100,
              elevation: SizeConstants.elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConstants.radioSmall),
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeConstants.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Text(
                            'Circuito ${circuitData.circuit}',
                            style: TextStyle(
                              fontSize: SizeConstants.textSizeLarge,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackColorWithOpacity,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estado:',
                                style: TextStyle(
                                  fontSize: SizeConstants.textSizeMedium,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey700,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConstants.paddingSmall,
                                  vertical: SizeConstants.paddingSmall,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeConstants.radioSmall),
                                  color: isCircuitOn
                                      ? AppColors.greenColor400
                                      : (estadoCircuito == 'Reposo')
                                          ? AppColors.redColor200
                                          : AppColors.redAccentColor,
                                ),
                                child: Text(
                                  isCircuitOn
                                      ? 'Encendido'
                                      : (estadoCircuito == 'Reposo'
                                          ? 'Reposo'
                                          : 'Apagado'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: SizeConstants.textSizeSmall,
                                    color: AppColors.backgroundColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConstants.paddingSmall),
                    Container(
                      padding: EdgeInsets.all(SizeConstants.paddingSmall),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(SizeConstants.radioSmall),
                        color: AppColors.primaryColorOrange100,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Tiempo trabajado:',
                            style: TextStyle(
                              fontSize: SizeConstants.textSizeMedium,
                              color: AppColors.grey700,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConstants.paddingMedium,
                              vertical: SizeConstants.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConstants.radioSmall),
                              color: workingTimeColor,
                            ),
                            child: Text(
                              // '1000 h',
                              '${circuitData.workingTime} h',
                              style: TextStyle(
                                fontSize: SizeConstants.textSizeSmall,
                                fontWeight: FontWeight.bold,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: (circuitData.workingTime != 0)
                                ? () async {
                                    showCustomDialog(
                                        title: 'Confirmación',
                                        content:
                                            '¿Estás seguro de que quieres reiniciar el tiempo trabajado por el circuito?',
                                        isFailureDialog: false,
                                        issues: null,
                                        hasCancel: true,
                                        todo: () {
                                          controller
                                              .resetWorkingTime(id.toString());
                                          Get.back();
                                        });
                                  }
                                : null,
                            icon: Icon(Icons.refresh,
                                color: (circuitData.workingTime == 0)
                                    ? AppColors.grey
                                    : AppColors.primaryColorOrange400),
                            splashRadius: SizeConstants.iconSizeMedium,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !isCircuitOn && estadoCircuito != 'Reposo',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (fallos.length == 1)
                            Flexible(
                              child: Text(
                                fallos.first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: SizeConstants.textSizeMedium,
                                  color: AppColors.blackColorWithOpacity,
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: fallos.map((estado) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: SizeConstants.paddingMinumus),
                                    child: Text(
                                      estado,
                                      style: TextStyle(
                                        fontSize: SizeConstants.textSizeMedium,
                                        color: AppColors.blackColorWithOpacity,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          // Condición adicional para el IconButton
                          if (estadoCircuito
                              .contains('Apagado por presión de aceite'))
                            IconButton(
                              onPressed: () async {
                                if (!isCircuitOn &&
                                    estadoCircuito != 'Reposo') {
                                  showCustomDialog(
                                    title: 'Confirmación',
                                    content:
                                        '¿Está seguro de que desea reiniciar los fallos en el circuito?',
                                    issues:
                                        null, // No es un diálogo de fallos, por lo que issues es null
                                    hasCancel: true,
                                    todo: () {
                                      controller.resetEvent(id.toString());
                                      Get.back();
                                    },
                                    isFailureDialog: false,
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.refresh,
                                color: isCircuitOn
                                    ? AppColors.grey
                                    : AppColors.primaryColorOrange,
                              ),
                              splashRadius: SizeConstants.iconSizeMedium,
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
