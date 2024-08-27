// import 'dart:async';

// import 'package:flutter/services.dart';
// import 'package:recliven_chiller/src/core.dart';

// //maneja los estados d error

// class ErrorHandler {
//   static void handleError(Object error) {
//     if (error is PlatformException) {
//       SnackbarUtils.showError(
//           'Error de conexión', 'No se pudo conectar con el maestro.');
//     } else if (error is TimeoutException) {
//       SnackbarUtils.showWarning(
//           'Tiempo de Espera', 'La solicitud ha tardado demasiado.');
//     } else {
//       SnackbarUtils.showError('Error', 'Ha ocurrido un error inesperado.');
//     }
//   }
// }
