import 'package:flutter/material.dart';
import 'package:recliven_chiller/barrel/core.dart';

//pantalla que muestra el estado de no conexion de la app

class NoConnection extends StatelessWidget {
  const NoConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConstants.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled, // Changed icon to Bluetooth off
              size: SizeConstants
                  .iconSizeSuperLarge, // Use ScreenUtil for responsive sizing
              color: AppColors.grey,
            ),
            SizedBox(
                height: SizeConstants
                    .paddingLarge), // Use ScreenUtil for responsive sizing
            Text(
              'No hay conexión con el dispositivo',
              style: TextStyle(
                fontSize: SizeConstants
                    .textSizeLarge, // Use ScreenUtil for responsive sizing
                fontWeight: FontWeight.bold,
              ),
              textAlign:
                  TextAlign.center, // Center align for overflow prevention
            ),
            SizedBox(
              height: SizeConstants.paddingMedium,
            ), // Use ScreenUtil for responsive sizing
            Text(
              'Verifique que el Bluetooth esté activo y el dispositivo conectado.',
              style: TextStyle(
                fontSize: SizeConstants
                    .textSizeMedium, // Use ScreenUtil for responsive sizing
                color: AppColors.grey,
              ),
              textAlign:
                  TextAlign.center, // Center align for overflow prevention
            ),
          ],
        ),
      ),
    );
  }
}
