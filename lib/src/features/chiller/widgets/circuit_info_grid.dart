// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class CircuitStateInfoGrid extends StatelessWidget {
//   final String circuitName;
//   final String timeWorked;
//   final String circuitState;
//   // final Function onResetTime;

//   const CircuitStateInfoGrid({
//     super.key,
//     required this.circuitName,
//     required this.timeWorked,
//     required this.circuitState,
//     // required this.onResetTime,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: Card(
//         elevation: 8.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15.0),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(10.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 circuitName,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange,
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Text(
//                     'Estado:',
//                     style: TextStyle(
//                       fontSize: 8.sp,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   SizedBox(width: 4.w),
//                   Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8.w),
//                       color: circuitState == 'Trabajando'
//                           //incorporar una logica para manejar los colores en dependencia de este estado
//                           ? Colors.green
//                           : Colors.red,
//                     ),
//                     child: Text(
//                       circuitState,
//                       style: TextStyle(
//                         fontSize: 8.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 8.h),
//               Container(
//                 padding: EdgeInsets.all(6.w),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.w),
//                   color: Colors.grey[200],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Tiempo trabajado:',
//                       style: TextStyle(
//                         fontSize: 8.sp,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 8.w, vertical: 4.w),
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8.w),
//                               color: const Color.fromARGB(255, 50, 129, 225)),
//                           child: Text(
//                             timeWorked,
//                             style: TextStyle(
//                               fontSize: 8.sp,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text('Confirmación'),
//                                   content: const Text(
//                                       '¿Estás seguro de que quieres reiniciar el contador?'),
//                                   actions: <Widget>[
//                                     TextButton(
//                                       child: const Text('Cancelar'),
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                       },
//                                     ),
//                                     TextButton(
//                                       child: const Text('Aceptar'),
//                                       onPressed: () {
//                                         // onResetTime(); // Llama a la función para reiniciar el tiempo
//                                         Navigator.of(context).pop();
//                                       },
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                           icon: const Icon(Icons.refresh, color: Colors.orange),
//                           padding: EdgeInsets.all(8.w),
//                           splashRadius: 12.w,
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
