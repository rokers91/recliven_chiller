// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

//utilidad para definir los tamaños de pantalla de la app en dependencia de las dimensiones
//del cell en que se instale al app.

class ScreenUtilsConfig {
  static Size getDesignSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Se definen los tamaños de diseño base según las características del dispositivo
    if (width > 1440) {
      // Para dispositivos ultra grandes
      return const Size(1440, 3040);
    } else if (width > 1200) {
      // Para tablets grandes y pantallas muy grandes
      return const Size(1200, 1600);
    } else if (width > 800) {
      // Para tablets
      return const Size(800, 1024);
    } else if (width > 600) {
      // Para teléfonos grandes
      return const Size(480, 853);
    } else if (width > 500) {
      // Para teléfonos muy grandes
      return const Size(414, 896);
    } else if (width > 400) {
      // Para teléfonos grandes
      return const Size(400, 844);
    } else if (width > 360) {
      // Para teléfonos medianos
      return const Size(375, 667);
    } else {
      // Para teléfonos pequeños
      return const Size(360, 690);
    }
  }
}

// double getWidthDimensions(BuildContext context) {
//   print('Width: ${MediaQuery.of(context).size.width}');
//   return MediaQuery.of(context).size.width;
// }

// double getHeightDimensions(BuildContext context) {
//   print('Height: ${MediaQuery.of(context).size.height}');
//   return MediaQuery.of(context).size.height;
// }

// class Responsive extends StatelessWidget {
//   final Widget? mobile;
//   final Widget? tablet;

//   const Responsive({
//     super.key,
//     this.mobile,
//     this.tablet,
//   });

//   static bool isMobile(BuildContext context) =>
//       MediaQuery.of(context).size.width < 850;

//   static bool isTablet(BuildContext context) =>
//       MediaQuery.of(context).size.width < 1100 &&
//       MediaQuery.of(context).size.width >= 850;

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//     if (size.width >= 850 && tablet != null) {
//       return tablet!;
//     } else {
//       return mobile!;
//     }
//   }
// }
