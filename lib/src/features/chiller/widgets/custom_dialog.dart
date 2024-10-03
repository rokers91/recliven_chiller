import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String? content;
  final List<TextSpan>? issues;
  final VoidCallback todo;
  final bool hasCancel;
  final bool isFailureDialog;

  const CustomDialog({
    Key? key,
    required this.title,
    this.content,
    this.issues,
    required this.todo,
    required this.hasCancel,
    required this.isFailureDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ajuste de altura de diálogo basado en el contenido
    double dialogHeight = _calculateDialogHeight();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConstants.borderRadiusLarge),
      ),
      elevation: SizeConstants.elevation,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.paddingLargeExtended),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(),
            SizedBox(height: SizeConstants.paddingLargeExtended),
            _buildContent(dialogHeight),
            SizedBox(height: SizeConstants.paddingLargeExtended),
            _buildActionsRow(),
          ],
        ),
      ),
    );
  }

  // Método para calcular la altura del diálogo
  double _calculateDialogHeight() {
    if (isFailureDialog && issues != null && issues!.isNotEmpty) {
      double baseHeight = SizeConstants.screenHeight * 0.05;
      return baseHeight +
          SizeConstants.screenHeight * 0.06 * (issues!.length - 1);
    } else {
      return content != null && content!.length > 100
          ? SizeConstants.screenHeight * 0.2
          : SizeConstants.screenHeight * 0.1;
    }
  }

  // Método para construir la fila del título
  Widget _buildTitleRow() {
    return Row(
      children: [
        Icon(
          isFailureDialog ? Icons.warning_amber_rounded : Icons.info_outline,
          color: Colors.orangeAccent,
          size: SizeConstants.iconSizeMediumExtended30,
        ),
        SizedBox(width: SizeConstants.paddingMedium),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: SizeConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
        ),
      ],
    );
  }

  // Método para construir el contenido principal del diálogo
  Widget _buildContent(double dialogHeight) {
    if (isFailureDialog && issues != null && issues!.isNotEmpty) {
      return SizedBox(
        height: dialogHeight,
        child: ListView.builder(
          itemCount: issues!.length,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  EdgeInsets.symmetric(vertical: SizeConstants.paddingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle,
                      size: SizeConstants.iconSizeMinimus, color: Colors.grey),
                  SizedBox(width: SizeConstants.paddingMedium),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: SizeConstants.textSizeMedium,
                          color: AppColors.blackColor,
                        ),
                        children: [issues![index]],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else if (content != null) {
      return Text(
        content!,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: SizeConstants.textSizeSmall,
          color: AppColors.blackColor,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Método para construir la fila de acciones
  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasCancel)
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: SizeConstants.textSizeMedium,
                color: AppColors.blackColorWithOpacity,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: todo,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.paddingLarge,
              vertical: SizeConstants.paddingMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(SizeConstants.borderRadiusMedium),
            ),
          ),
          child: Text(
            'Aceptar',
            style: TextStyle(
              fontSize: isFailureDialog
                  ? SizeConstants.textSizeSmall
                  : SizeConstants.textSizeMedium,
              color: AppColors.primaryColorOrange400,
            ),
          ),
        ),
      ],
    );
  }
}

// Función para mostrar el diálogo
void showCustomDialog({
  required String title,
  String? content,
  List<TextSpan>? issues,
  required bool hasCancel,
  required VoidCallback todo,
  required bool isFailureDialog,
}) {
  if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: CustomDialog(
          title: title,
          content: content,
          issues: issues,
          hasCancel: hasCancel,
          todo: todo,
          isFailureDialog: isFailureDialog,
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:recliven_chiller/barrel/core.dart';

// class CustomDialog extends StatelessWidget {
//   final String title;
//   final String? content;
//   final List<TextSpan>? issues;
//   final VoidCallback todo;
//   final bool hasCancelar;
//   final bool isFailureDialog;

//   const CustomDialog({
//     super.key,
//     required this.title,
//     this.content,
//     this.issues,
//     required this.todo,
//     required this.hasCancelar,
//     required this.isFailureDialog,
//   });

//   @override
//   Widget build(BuildContext context) {
//     double dialogHeight;
//     if (isFailureDialog && issues != null && issues!.isNotEmpty) {
//       // Altura mínima para el primer elemento
//       dialogHeight = SizeConstants.screenHeight * 0.05;

//       // Incrementa la altura por cada elemento adicional
//       if (issues!.length > 1) {
//         dialogHeight +=
//             SizeConstants.screenHeight * 0.06 * (issues!.length - 1);
//       }
//     } else {
//       dialogHeight = content != null && content!.length > 100
//           ? SizeConstants.screenHeight * 0.2
//           : SizeConstants.screenHeight * 0.1;
//     }

//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(SizeConstants.borderRadiusLarge),
//       ),
//       elevation: SizeConstants.elevation,
//       backgroundColor: Colors.white,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(SizeConstants.paddingLargeExtended),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       isFailureDialog
//                           ? Icons.warning_amber_rounded
//                           : Icons.info_outline,
//                       color: isFailureDialog
//                           ? Colors.redAccent
//                           : Colors.orangeAccent,
//                       size: SizeConstants.iconSizeMediumExtended30,
//                     ),
//                     SizedBox(width: SizeConstants.paddingMedium),
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: SizeConstants.textSizeLarge,
//                           fontWeight: FontWeight.bold,
//                           color: isFailureDialog
//                               ? Colors.redAccent
//                               : Colors.orangeAccent,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: SizeConstants.paddingLargeExtended),
//                 if (isFailureDialog && issues != null && issues!.isNotEmpty)
//                   SizedBox(
//                     height: dialogHeight,
//                     child: ListView.builder(
//                       itemCount: issues!.length,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: SizeConstants.paddingSmall),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               //TODO: Mejorar esto de forma que se vea como en el Word
//                               Icon(Icons.circle,
//                                   size: SizeConstants.iconSizeMinimus,
//                                   color: Colors.grey),
//                               SizedBox(width: SizeConstants.paddingMedium),
//                               Expanded(
//                                 child: RichText(
//                                   textAlign: TextAlign.justify,
//                                   text: TextSpan(
//                                     style: TextStyle(
//                                       fontSize: SizeConstants.textSizeMedium,
//                                       color: AppColors.blackColor,
//                                     ),
//                                     children: [
//                                       issues![index]
//                                     ], // Envuelves el TextSpan en una lista
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                 else if (content != null)
//                   Text(
//                     content!,
//                     textAlign: TextAlign.justify,
//                     style: TextStyle(
//                       fontSize: SizeConstants.textSizeSmall,
//                       color: AppColors.blackColor,
//                     ),
//                   ),
//                 SizedBox(height: SizeConstants.paddingLargeExtended),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (hasCancelar)
//                       TextButton(
//                         onPressed: () => Get.back(),
//                         child: Text(
//                           'Cancelar',
//                           style: TextStyle(
//                             fontSize: SizeConstants.textSizeMedium,
//                             color: AppColors.blackColorWithOpacity,
//                           ),
//                         ),
//                       ),
//                     ElevatedButton(
//                       onPressed: todo,
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: SizeConstants.paddingLarge,
//                           vertical: SizeConstants.paddingMedium,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                               SizeConstants.borderRadiusMedium),
//                         ),
//                       ),
//                       child: Text(
//                         'Aceptar',
//                         style: TextStyle(
//                           fontSize: SizeConstants.textSizeMedium,
//                           color: AppColors.primaryColorOrange400,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void showCustomDialog({
//   required String title,
//   String? content,
//   List<TextSpan>? issues,
//   required bool hasCancel,
//   required VoidCallback todo,
//   required bool isFailureDialog,
// }) {
//   if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async {
//           return false;
//         },
//         child: CustomDialog(
//           title: title,
//           content: content,
//           issues: issues,
//           hasCancelar: hasCancel,
//           todo: todo,
//           isFailureDialog: isFailureDialog,
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:recliven_chiller/barrel/core.dart';

// class CustomDialog extends StatelessWidget {
//   final String title;
//   final String? content;
//   final List<String>? issues;
//   final VoidCallback todo;
//   final bool hasCancelar;
//   final bool isFailureDialog;

//   const CustomDialog({
//     super.key,
//     required this.title,
//     this.content,
//     this.issues,
//     required this.todo,
//     required this.hasCancelar,
//     required this.isFailureDialog,
//   });

//   @override
//   Widget build(BuildContext context) {
//     double dialogHeight;
//     if (isFailureDialog && issues != null && issues!.isNotEmpty) {
//       dialogHeight = issues!.length > 5
//           ? SizeConstants.screenHeight * 0.7
//           : SizeConstants.screenHeight * 0.25;
//     } else {
//       dialogHeight = content != null && content!.length > 100
//           ? SizeConstants.screenHeight * 0.2
//           : SizeConstants.screenHeight * 0.1;
//     }

//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(SizeConstants.borderRadiusLarge),
//       ),
//       elevation: SizeConstants.elevation,
//       backgroundColor: Colors.white,
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(SizeConstants.paddingLargeExtended),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.grey),
//                   onPressed: () => Get.back(),
//                 ),
//                 Row(
//                   children: [
//                     Icon(
//                       isFailureDialog
//                           ? Icons.warning_amber_rounded
//                           : Icons.info_outline,
//                       color: isFailureDialog
//                           ? Colors.redAccent
//                           : Colors.orangeAccent,
//                       size: SizeConstants.iconSizeMedium,
//                     ),
//                     SizedBox(width: SizeConstants.paddingMedium),
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: SizeConstants.textSizeLarge,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primaryColorOrange,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: SizeConstants.paddingLargeExtended),
//                 if (isFailureDialog && issues != null && issues!.isNotEmpty)
//                   SizedBox(
//                     height: dialogHeight,
//                     child: ListView.builder(
//                       itemCount: issues!.length,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 5.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Icon(Icons.circle,
//                                   size: SizeConstants.iconSizeMinimus,
//                                   color: Colors.grey),
//                               SizedBox(width: SizeConstants.paddingMedium),
//                               Expanded(
//                                 child: Text(
//                                   issues![index],
//                                   textAlign: TextAlign.justify,
//                                   style: TextStyle(
//                                     fontSize: SizeConstants.textSizeMedium,
//                                     color: AppColors.blackColor,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                 else if (content != null)
//                   Text(
//                     content!,
//                     textAlign: TextAlign.justify,
//                     style: TextStyle(
//                       fontSize: SizeConstants.textSizeMedium,
//                       color: AppColors.blackColor,
//                     ),
//                   ),
//                 SizedBox(width: SizeConstants.paddingLargeExtended),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (hasCancelar)
//                       TextButton(
//                         onPressed: () => Get.back(),
//                         child: Text(
//                           'Cancelar',
//                           style: TextStyle(
//                             fontSize: SizeConstants.textSizeMedium,
//                             color: AppColors.blackColorWithOpacity,
//                           ),
//                         ),
//                       ),
//                     ElevatedButton(
//                       onPressed: todo,
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: SizeConstants.paddingLarge,
//                           vertical: SizeConstants.paddingMedium,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                               SizeConstants.borderRadiusMedium),
//                         ),
//                       ),
//                       child: Text(
//                         'Aceptar',
//                         style: TextStyle(
//                           fontSize: SizeConstants.textSizeMedium,
//                           color: AppColors.primaryColorOrange400,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void showCustomDialog({
//   required String title,
//   String? content,
//   List<String>? issues,
//   required bool hasCancel,
//   required VoidCallback todo,
//   required bool isFailureDialog,
// }) {
//   if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async {
//           return false;
//         },
//         child: CustomDialog(
//           title: title,
//           content: content,
//           issues: issues,
//           hasCancelar: hasCancel,
//           todo: todo,
//           isFailureDialog: isFailureDialog,
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:recliven_chiller/barrel/core.dart';

// class CustomDialog extends StatelessWidget {
//   final String title;
//   final String? content;
//   final List<String>? issues;
//   final VoidCallback todo;
//   final bool hasCancelar;
//   final bool isFailureDialog;

//   const CustomDialog({
//     super.key,
//     required this.title,
//     this.content,
//     this.issues,
//     required this.todo,
//     required this.hasCancelar,
//     required this.isFailureDialog,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Determinar la altura del SizedBox según la cantidad de issues
//     double dialogHeight;
//     if (isFailureDialog && issues != null && issues!.isNotEmpty) {
//       // Si hay muchos issues, usar un 90% del tamaño de la pantalla
//       dialogHeight = issues!.length > 5
//           ? SizeConstants.screenHeight * 0.9
//           // : SizeConstants.screenHeight * 0.4 + (issues!.length * 40.0);
//           : SizeConstants.screenHeight * 0.25;
//     } else {
//       // Ajustar el tamaño en función de la longitud del contenido si no hay issues
//       dialogHeight = content != null && content!.length > 100
//           ? SizeConstants.screenHeight * 0.2
//           : SizeConstants.screenHeight * 0.1;
//     }

//     return AlertDialog(
//       title: Padding(
//         padding: EdgeInsets.all(SizeConstants.paddingMinumus),
//         child: Text(
//           title,
//           style: TextStyle(
//             fontSize: SizeConstants.textSizeLarge,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       content: Padding(
//         padding: EdgeInsets.symmetric(horizontal: SizeConstants.paddingLarge),
//         child: isFailureDialog && issues != null && issues!.isNotEmpty
//             ? SizedBox(
//                 height: dialogHeight,
//                 width: double.maxFinite,
//                 child: ListView.builder(
//                   itemCount: issues!.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: EdgeInsets.symmetric(
//                           vertical: SizeConstants.paddingSmall),
//                       child: Text(
//                         issues![index],
//                         textAlign: TextAlign.justify,
//                         style: TextStyle(fontSize: SizeConstants.textSizeSmall),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             : SizedBox(
//                 height: dialogHeight,
//                 child: Text(
//                   content ?? '',
//                   textAlign: TextAlign.justify,
//                   style: TextStyle(fontSize: SizeConstants.textSizeMedium),
//                 ),
//               ),
//       ),
//       actions: <Widget>[
//         hasCancelar
//             ? TextButton(
//                 child: Text(
//                   'Cancelar',
//                   style: TextStyle(
//                     fontSize: SizeConstants.textSizeMedium,
//                     color: AppColors.blackColorWithOpacity,
//                   ),
//                 ),
//                 onPressed: () {
//                   Get.back();
//                 },
//               )
//             : const SizedBox.shrink(),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             padding: EdgeInsets.symmetric(
//               horizontal: SizeConstants.paddingLarge,
//               vertical: SizeConstants.paddingMedium,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(SizeConstants.borderRadiusMedium),
//             ),
//           ),
//           onPressed: todo,
//           child: Text(
//             'Aceptar',
//             style: TextStyle(
//               fontSize: SizeConstants.textSizeMedium,
//               color: AppColors.primaryColorOrange400,
//             ),
//           ),
//         ),
//       ],
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(SizeConstants.radioLarge),
//       ),
//       elevation: SizeConstants.elevation,
//     );
//   }
// }

// void showCustomDialog({
//   required String title,
//   String? content,
//   List<String>? issues,
//   required bool hasCancel,
//   required VoidCallback todo,
//   required bool isFailureDialog,
// }) {
//   if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async {
//           return false;
//         },
//         child: CustomDialog(
//           title: title,
//           content: content,
//           issues: issues,
//           hasCancelar: hasCancel,
//           todo: todo,
//           isFailureDialog: isFailureDialog,
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:recliven_chiller/barrel/core.dart';

// class CustomDialog extends StatelessWidget {
//   final String title;
//   final String? content;
//   final List<String>? issues;
//   final VoidCallback todo;
//   final bool hasCancelar;
//   final bool isFailureDialog;

//   const CustomDialog({
//     super.key,
//     required this.title,
//     this.content,
//     this.issues,
//     required this.todo,
//     required this.hasCancelar,
//     required this.isFailureDialog,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Padding(
//         padding: EdgeInsets.all(SizeConstants.paddingMedium),
//         child: Text(
//           title,
//           style: TextStyle(
//             fontSize: SizeConstants.textSizeLarge,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       content: Padding(
//         padding: EdgeInsets.symmetric(horizontal: SizeConstants.paddingLarge),
//         child: isFailureDialog && issues != null && issues!.isNotEmpty
//             ? SizedBox(
//                 height: SizeConstants.screenHeight * 0.9,
//                 width: double.maxFinite,
//                 child: ListView.builder(
//                   itemCount: issues!.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: EdgeInsets.symmetric(
//                           vertical: SizeConstants.paddingSmall),
//                       child: Text(
//                         issues![index],
//                         textAlign: TextAlign.justify,
//                         style:
//                             TextStyle(fontSize: SizeConstants.textSizeMedium),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             : Text(
//                 content ?? '',
//                 textAlign: TextAlign.justify,
//                 style: TextStyle(fontSize: SizeConstants.textSizeMedium),
//               ),
//       ),
//       actions: <Widget>[
//         hasCancelar
//             ? TextButton(
//                 child: Text(
//                   'Cancelar',
//                   style: TextStyle(
//                     fontSize: SizeConstants.textSizeMedium,
//                     color: AppColors.blackColorWithOpacity,
//                   ),
//                 ),
//                 onPressed: () {
//                   Get.back();
//                 },
//               )
//             : const SizedBox.shrink(),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             padding: EdgeInsets.symmetric(
//               horizontal: SizeConstants.paddingLarge,
//               vertical: SizeConstants.paddingMedium,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(SizeConstants.borderRadiusMedium),
//             ),
//           ),
//           onPressed: todo,
//           child: Text(
//             'Aceptar',
//             style: TextStyle(
//               fontSize: SizeConstants.textSizeMedium,
//               color: AppColors.primaryColorOrange400,
//             ),
//           ),
//         ),
//       ],
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(SizeConstants.radioLarge),
//       ),
//       elevation: SizeConstants.elevation,
//     );
//   }
// }

// void showCustomDialog({
//   required String title,
//   String? content,
//   List<String>? issues,
//   required bool hasCancel,
//   required VoidCallback todo,
//   required bool isFailureDialog,
// }) {
//   if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async {
//           return false;
//         },
//         child: CustomDialog(
//           title: title,
//           content: content,
//           issues: issues,
//           hasCancelar: hasCancel,
//           todo: todo,
//           isFailureDialog: isFailureDialog,
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:recliven_chiller/barrel/core.dart';

// class CustomDialog extends StatelessWidget {
//   final String title;
//   final String? content;
//   final List<String>? issues;
//   final VoidCallback todo;
//   final bool hasCancelar;
//   final bool isFailureDialog; // Nuevo parámetro

//   const CustomDialog({
//     super.key,
//     required this.title,
//     this.content,
//     this.issues,
//     required this.todo,
//     required this.hasCancelar,
//     required this.isFailureDialog, // Inicializa el nuevo parámetro
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: SizeConstants.textSizeLarge,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       content: isFailureDialog && issues != null && issues!.isNotEmpty
//           ? SizedBox(
//               height: 200, // Ajusta la altura según sea necesario
//               width: double.maxFinite,
//               child: ListView.builder(
//                 itemCount: issues!.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: Text(
//                       issues![index],
//                       textAlign: TextAlign.justify,
//                       style: TextStyle(fontSize: SizeConstants.textSizeMedium),
//                     ),
//                   );
//                 },
//               ),
//             )
//           : Text(
//               content ?? '',
//               textAlign: TextAlign.justify,
//               style: TextStyle(fontSize: SizeConstants.textSizeMedium),
//             ),
//       actions: <Widget>[
//         hasCancelar
//             ? TextButton(
//                 child: Text(
//                   'Cancelar',
//                   style: TextStyle(
//                     fontSize: SizeConstants.textSizeMedium,
//                     color: AppColors.blackColorWithOpacity,
//                   ),
//                 ),
//                 onPressed: () {
//                   Get.back();
//                 },
//               )
//             : const SizedBox.shrink(),
//         ElevatedButton(
//           onPressed: todo,
//           child: Text(
//             'Aceptar',
//             style: TextStyle(
//               fontSize: SizeConstants.textSizeMedium,
//               color: AppColors.primaryColorOrange400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// void showCustomDialog(
//     String title, {
//     String? content,
//     List<String>? issues,
//     required bool hasCancel,
//     required VoidCallback todo,
//     required bool isFailureDialog, // Nuevo parámetro
//   }) {
//   if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async {
//           return false;
//         },
//         child: CustomDialog(
//           title: title,
//           content: content,
//           issues: issues,
//           hasCancelar: hasCancel,
//           todo: todo,
//           isFailureDialog: isFailureDialog, // Pasa el nuevo parámetro
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:recliven_chiller/barrel/core.dart';

// // class CustomDialog extends StatelessWidget {
// //   final String title;
// //   final String? content;
// //   final List<String>? issues;
// //   final VoidCallback todo;
// //   final bool hasCancelar;

// //   const CustomDialog({
// //     super.key,
// //     required this.title,
// //     this.content,
// //     this.issues,
// //     required this.todo,
// //     required this.hasCancelar,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return AlertDialog(
// //       title: Text(
// //         title,
// //         style: TextStyle(
// //           fontSize: SizeConstants.textSizeLarge,
// //           fontWeight: FontWeight.bold,
// //         ),
// //       ),
// //       content: issues != null && issues!.isNotEmpty
// //           ? SizedBox(
// //               height: 200, // Ajusta la altura según sea necesario
// //               width: double.maxFinite,
// //               child: ListView.builder(
// //                 itemCount: issues!.length,
// //                 itemBuilder: (context, index) {
// //                   return Padding(
// //                     padding: const EdgeInsets.symmetric(vertical: 4.0),
// //                     child: Text(
// //                       issues![index],
// //                       textAlign: TextAlign.justify,
// //                       style: TextStyle(fontSize: SizeConstants.textSizeMedium),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             )
// //           : Text(
// //               content ?? '',
// //               textAlign: TextAlign.justify,
// //               style: TextStyle(fontSize: SizeConstants.textSizeMedium),
// //             ),
// //       actions: <Widget>[
// //         hasCancelar
// //             ? TextButton(
// //                 child: Text(
// //                   'Cancelar',
// //                   style: TextStyle(
// //                     fontSize: SizeConstants.textSizeMedium,
// //                     color: AppColors.blackColorWithOpacity,
// //                   ),
// //                 ),
// //                 onPressed: () {
// //                   Get.back();
// //                 },
// //               )
// //             : const SizedBox.shrink(),
// //         ElevatedButton(
// //           onPressed: todo,
// //           child: Text(
// //             'Aceptar',
// //             style: TextStyle(
// //               fontSize: SizeConstants.textSizeMedium,
// //               color: AppColors.primaryColorOrange400,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // void showCustomDialog(
// //     String title, List<String> issues, bool hasCancel, VoidCallback todo) {
// //   if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
// //     Get.dialog(
// //       WillPopScope(
// //         onWillPop: () async {
// //           return false;
// //         },
// //         child: CustomDialog(
// //           title: title,
// //           issues: issues,
// //           hasCancelar: hasCancel,
// //           todo: todo,
// //         ),
// //       ),
// //     );
// //   }
// // }


// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:recliven_chiller/barrel/core.dart';

// // //dialogo personalizado para los diferentes casos de uso en la app, salida, reinicio de tiempo, etc.
// // class CustomDialog extends StatelessWidget {
// //   final String title;
// //   final String content;
// //   final VoidCallback todo;
// //   final bool hasCancelar;
// //   const CustomDialog(
// //       {super.key,
// //       required this.title,
// //       required this.content,
// //       required this.todo,
// //       required this.hasCancelar});

// //   @override
// //   Widget build(BuildContext context) {
// //     return AlertDialog(
// //       title: Text(
// //         title,
// //         style: TextStyle(
// //             fontSize: SizeConstants.textSizeLarge, fontWeight: FontWeight.bold),
// //       ),
// //       content: Text(
// //         content,
// //         textAlign: TextAlign.justify,
// //         style: TextStyle(fontSize: SizeConstants.textSizeMedium),
// //       ),
// //       actions: <Widget>[
// //         hasCancelar
// //             ? TextButton(
// //                 child: Text(
// //                   'Cancelar',
// //                   style: TextStyle(
// //                       fontSize: SizeConstants.textSizeMedium,
// //                       color: AppColors.blackColorWithOpacity),
// //                 ),
// //                 onPressed: () {
// //                   Get.back();
// //                 },
// //               )
// //             : const SizedBox.shrink(),
// //         ElevatedButton(
// //           onPressed: todo,
// //           child: Text(
// //             'Aceptar',
// //             style: TextStyle(
// //                 fontSize: SizeConstants.textSizeMedium,
// //                 color: AppColors.primaryColorOrange400),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // void showCustomDialog(
// //     String title, String content, bool hasCancel, VoidCallback todo) {
// //   if (!Get.isDialogOpen! || !Get.isSnackbarOpen) {
// //     Get.dialog(
// //       WillPopScope(
// //         // canPop: false,
// //         onWillPop: () async {
// //           return false;
// //         },
// //         child: CustomDialog(
// //           title: title,
// //           content: content,
// //           hasCancelar: hasCancel,
// //           todo: todo,
// //         ),
// //       ),
// //     );
// //   }
// // }
