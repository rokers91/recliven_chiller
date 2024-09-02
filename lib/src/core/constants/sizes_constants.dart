//se definen los tamaños de las fuentes, espaciado, iconos, etc.

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SizeConstants {
  // Información del tamaño de la pantalla
  static double screenWidth = Get.size.width;
  static double screenHeight = Get.size.height;

  //espaciado
  static final double paddingMinumus = 2.0.w;
  static final double paddingSmall = 4.0.w;
  static final double paddingMedium = 8.0.w;
  static final double paddingLarge = 16.0.w;
  static final double paddingLargeExtended = 20.0.w;

  //elevations
  static final double elevation = 8.0.w;

  //textos
  static final double textSizeSmall = 14.0.sp;
  static final double textSizeMedium = 16.0.sp;
  static final double textSizeLarge = 18.0.sp;
  static final double textSizeLargeExtended = 22.0.sp;

  //bordes
  static final double borderRadiusMinimus = 2.0.w;
  static final double borderRadiusSmall = 8.0.w;
  static final double borderRadiusMedium = 10.0.w;
  static final double borderRadiusLarge = 15.0.w;

  //tamaño de los iconos
  static final double iconSizeMinimus = 8.0.w;
  static final double iconSizeSmall = 12.0.w;
  static final double iconSizeMedium = 24.0.w;
  static final double iconSizeMediumExtended30 = 30.0.w;
  static final double iconSizeMediumExtended = 40.0.w;
  static final double iconSizeLarge = 48.0.w;
  static final double iconSizeSuperLarge = 80.0.w;

  //radio de los widgets
  static final double radioLarge = 15.0.r;
  static final double radioSmall = 8.0.r;

  //tamaño de los botones
  static final double buttonSmall = 10.0.w;
  static final double buttonMedium = 15.0.w;
  static final double buttonLarge = 40.0.w;

  //tamaño de la imagenes width
  static final double imageWidthLargeExtended = 250.0.w;
  static final double imageWidthLarge = 150.0.w;
  static final double imageWidthMedium = 100.0.w;
  static final double imageWidthSmall = 50.0.w;

  //tamaño de la imagenes height
  static final double imageHeightLargeExtended = 350.0.h;
  static final double imageHeightLarge = 150.0.w;
  static final double imageHeightMedium = 100.0.w;
  static final double imageHeightSmallExtended = 70.0.w;
  static final double imageHeightSmall = 50.0.w;

  //dimensiones de la tabla
  static final double columnSpacing = 50.0.w;
  static final double tableRowTextSize = 12.0.w;
}
