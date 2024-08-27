// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/barrel/screens.dart';
import 'package:recliven_chiller/barrel/widgets.dart';

//pantalla que muestra lo referente a los estados de los circuitos
// ignore: must_be_immutable
class MainScreen extends GetWidget<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.status) {
        case RequestState.loading:
          return LoadingIndicator(
            loadingKey: 'main',
            color: AppColors.primaryColorOrange300,
            isLoading: true,
          );
        case RequestState.error:
          return const NoConnection();
        case RequestState.success:
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(SizeConstants.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Obx(() {
                      final int numberOfSlaves = controller.circuitsData.length;
                      return Column(
                        children: List.generate(numberOfSlaves, (index) {
                          final circuitData = controller.circuitsData[index];
                          return Column(
                            children: [
                              CircuitStateInfo(
                                id: index + 1,
                                circuitData: circuitData,
                                controller: controller,
                              ),
                            ],
                          );
                        }),
                      );
                    })
                  ],
                ),
              ),
            ),
          );
        default:
          return const NoConnection();
      }
    });
  }
}
