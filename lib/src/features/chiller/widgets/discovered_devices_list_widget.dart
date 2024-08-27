// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:get/get.dart';

// import 'package:recliven_chiller/src/constants/constants.dart';
// import 'package:recliven_chiller/src/pages/chiller/controllers.dart';

// class DiscoveredDevicesList extends StatelessWidget {
//   const DiscoveredDevicesList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     BluetoothController controller = Get.find();
//     return Obx(() {
//       if (!controller.isDiscovering.value && controller.results.isEmpty) {
//         return Padding(
//           padding: EdgeInsets.symmetric(vertical: SizeConstants.paddingMedium),
//           child: ListTile(
//             title: Text(
//               'Ningún dispositivo encontrado.',
//               style: TextStyle(fontSize: SizeConstants.textSizeLarge),
//             ),
//           ),
//         );
//       } else if (controller.results.isNotEmpty) {
//         return _buildDevicesList(controller);
//       } else if (controller.isDiscovering.value) {
//         return _buildSearchingIndicator();
//       } else {
//         return Container();
//       }
//     });
//   }
// }

// Widget _buildDevicesList(BluetoothController controller) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Dispositivos Disponibles',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: SizeConstants.textSizeLarge,
//             ),
//           ),
//           SizedBox(width: SizeConstants.paddingMedium),
//         ],
//       ),
//       Obx(() {
//         return ListView.builder(
//           shrinkWrap: true,
//           itemCount: controller.discoveredDevices.length,
//           itemBuilder: (context, index) {
//             final result = controller.discoveredDevices[index];
//             return DeviceListTile(result: result, controller: controller);
//           },
//         );
//       }),
//     ],
//   );
// }

// Widget _buildSearchingIndicator() {
//   return Padding(
//     padding: EdgeInsets.symmetric(vertical: SizeConstants.paddingMedium),
//     child: Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: Text(
//             'Nuevos Disponibles',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: SizeConstants.textSizeLarge,
//             ),
//           ),
//         ),
//         SizedBox(width: SizeConstants.paddingMedium),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Buscando...',
//               style: TextStyle(
//                 color: AppColors.primaryColorOrange300,
//                 fontWeight: FontWeight.w400,
//                 fontSize: SizeConstants.textSizeSmall,
//               ),
//             ),
//             SizedBox(width: SizeConstants.paddingMedium),
//             SizedBox(
//               width: SizeConstants.textSizeLarge,
//               height: SizeConstants.textSizeLarge,
//               child: const CircularProgressIndicator(
//                 color: AppColors.primaryColorOrange,
//                 strokeWidth: 2,
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// class DeviceListTile extends StatelessWidget {
//   final BluetoothDevice result;
//   final BluetoothController controller;

//   const DeviceListTile({
//     required this.result,
//     required this.controller,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final address = result.address;
//     final name = result.name;

//     return ListTile(
//       title: Text(name ?? ''),
//       subtitle: Text(address),
//       trailing: IconButton(
//         icon: const Icon(Icons.link),
//         onPressed: () async {
//           // await controller.bondToDevice(result.device);
//         },
//       ),
//     );
//   }
// }
