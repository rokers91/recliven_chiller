// // ignore_for_file: avoid_print, unused_import
// import 'dart:async';
// import 'dart:convert';
// import 'dart:core';
// import 'dart:io';
// import 'package:excel/excel.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'package:recliven_chiller/src/constants/constants.dart';
// import 'package:recliven_chiller/src/pages/chiller/models.dart';
// import 'package:recliven_chiller/src/pages/chiller/services/permission_service.dart';
// import 'package:recliven_chiller/src/pages/chiller/widgets.dart';
// import 'package:recliven_chiller/src/utils/utils.dart';

// enum RequestState { loading, success, error }

// // enum DeviceAvailability { no, maybe, yes }

// // enum ConnectionStatus { loading, success, error }

// class BluetoothController extends GetxController {
//   final PermissionService _permissionService = Get.find();

//   FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
//   BluetoothConnection? connection;
//   RxList<CircuitData> circuitsData = <CircuitData>[].obs;
//   Rx<BluetoothState> bluetoothState = BluetoothState.STATE_OFF.obs;
//   RxBool bluetoothStateBool = false.obs;
//   RxBool connectionStateBool = false.obs;
//   var connectedDevice = Rx<BluetoothDevice?>(null);
//   var connectionStates = <String, RxBool>{}.obs;
//   RxInt existingIndex = 0.obs;
//   RxList<BluetoothDevice> discoveredDevices = <BluetoothDevice>[].obs;
//   RxList<BluetoothDiscoveryResult> results =
//       RxList<BluetoothDiscoveryResult>.empty(growable: true);
//   RxList<BluetoothDevice> boundedDevices = <BluetoothDevice>[].obs;
//   StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
//   String buffer = '';
//   Rx<bool> autoAcceptPairingRequests = false.obs;
//   Rx<bool> isDiscovering = false.obs;
//   Rx<bool> isLoading = false.obs;
//   Rx<bool> settingsIsLoading = false.obs;
//   Rx<bool> isConnecting = false.obs;
//   Rx<bool> isCleaning = false.obs;
//   Rx<bool> isLoadingTable = false.obs;
//   final _isConnected = false.obs;
//   bool get isConnected => _isConnected.value;
//   Rx<bool> isDisconnecting = false.obs;
//   Rx<bool> isProcessing = false.obs;
//   Rx<bool> isProcessingConnection = false.obs;
//   Rx<bool> stream = false.obs;
//   Rx<bool> estadoDeUpdate = false.obs;
//   final _isErrorDialogShown = false.obs;
//   bool get isErrorDialogShown => _isErrorDialogShown.value;
//   var setpointTempController = TextEditingController().obs;
//   var difTotalController = TextEditingController().obs;
//   var numEsclavosController = TextEditingController().obs;
//   var anticicloCortoController = TextEditingController().obs;
//   var setpointTempControllerFocus = FocusNode();
//   var difTotalControllerFocus = FocusNode();
//   var numEsclavosControllerFocus = FocusNode();
//   var anticicloCortoControllerFocus = FocusNode();
//   RxList<String> subParts = <String>[].obs;
//   StreamSubscription? _dataSubscription;
//   Timer? periodicCommandTimer;
//   RxList<EventsInfoModel> events = <EventsInfoModel>[].obs;
//   // dialog
//   final exportTypeOptions = ['Excel', 'TXT'];
//   String? selectedExportType;
//   //main
//   final _status = Rx<RequestState>(RequestState.loading);
//   RequestState get status => _status.value;
//   final RxBool _isFirstLoad = true.obs;
//   //StreamController para el estado de conexión
//   final _connectionStateController = StreamController<bool>.broadcast();
//   Stream<bool> get connectionState => _connectionStateController.stream;
//   // para los intentos de reconexion.
//   final int maxRetries = 3;
//   final int retryDelay = 5; // seconds
//   // var permissionAreGranted = false.obs;
//   // RxBool locationGranted = false.obs;
//   // RxBool bluetoothGranted = false.obs;
//   // RxBool bluetoothScanGranted = false.obs;
//   // RxBool bluetoothConnectGranted = false.obs;
//   // RxBool storageGranted = false.obs;

//   // @override
//   // void onInit() async {
//   //   super.onInit();
//   //   // inicializeBluetooth();

//   // }

//   // @override
//   // void onInit() {
//   //   super.onInit();
//   //   _permissionService.requestAllPermissions();
//   //   if (_permissionService.permissionAreGranted.value) {
//   //     inicializeBluetooth();
//   //   }
//     // else {
//     //   showCustomDialog(
//     //       'Permisos requeridos',
//     //       'Hay permisos que no han sido otorgados, estos son requeridos para el correcto funcionamiento de Recliven Chiller.',
//     //       false, () {
//     //     openAppSettings();
//     //     turnOffBluetooth();
//     //     Get.back();
//     //   });
//     // }
//   }

//   @override
//   void onClose() {
//     super.onClose();
//     FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
//     _streamSubscription?.cancel();
//     _connectionStateController.close();
//     disableDataSubscription();
//     connection?.dispose();
//     disposeTextControllerAndFocusNode();
//     disconnectFromDevice();
//   }

//   void disposeTextControllerAndFocusNode() {
//     setpointTempController.value.dispose();
//     difTotalController.value.dispose();
//     numEsclavosController.value.dispose();
//     anticicloCortoController.value.dispose();
//     setpointTempControllerFocus.dispose();
//     difTotalControllerFocus.dispose();
//     numEsclavosControllerFocus.dispose();
//     anticicloCortoControllerFocus.dispose();
//   }

//   void unfocusTextFields() {
//     setpointTempControllerFocus.unfocus();
//     difTotalControllerFocus.unfocus();
//     numEsclavosControllerFocus.unfocus();
//     anticicloCortoControllerFocus.unfocus();
//   }

//   void showSnackbar(String title, String message,
//       {SnackPosition position = SnackPosition.BOTTOM}) {
//     Get.snackbar(title, message,
//         snackPosition: position,
//         backgroundColor: AppColors.primaryColorOrange100,
//         dismissDirection: DismissDirection.horizontal,
//         snackStyle: SnackStyle.FLOATING,
//         mainButton: TextButton.icon(
//             onPressed: () {
//               Get.back();
//             },
//             icon: const Icon(Icons.close),
//             label: Container()));
//   }

//   void inicializeBluetooth() {
//     turnOffBluetooth();
//     checkState();
//   }

//   // Future<void> requestPermission(Permission permission) async {
//   //   final status = await permission.request();
//   //   if (status.isGranted) {
//   //     checkPermission();
//   //   } else if (status.isPermanentlyDenied) {
//   //     showCustomDialog(
//   //         'Permisos requeridos',
//   //         'Hay permisos que no han sido otorgados, estos son requeridos para el correcto funcionamiento de Recliven Chiller.',
//   //         false, () {
//   //       openAppSettings();
//   //       turnOffBluetooth();
//   //       Get.back();
//   //     });
//   //   } else {
//   //     showPermissionBottomSheet;
//   //   }
//   // }

//   // Future<void> checkPermission() async {
//   //   locationGranted.value = await Permission.location.isGranted;
//   //   bluetoothGranted.value = await Permission.bluetooth.isGranted;
//   //   bluetoothScanGranted.value = await Permission.bluetoothScan.isGranted;
//   //   bluetoothConnectGranted.value = await Permission.bluetoothConnect.isGranted;
//   //   storageGranted.value = await Permission.storage.isGranted;

//   //   permissionAreGranted.value = locationGranted.value &&
//   //       bluetoothGranted.value &&
//   //       bluetoothScanGranted.value &&
//   //       bluetoothConnectGranted.value &&
//   //       storageGranted.value;
//   // }

//   void checkState() async {
//     bluetooth.state.then((state) async {
//       bluetoothState.value = await bluetooth.state;
//       bluetoothStateBool.value = state.isEnabled;
//     });

//     bluetooth.onStateChanged().listen((state) async {
//       bluetoothState.value = state;
//       bluetoothStateBool.value = state.isEnabled;
//       print('El estado del bluetooth es: $state');
//       if (bluetoothStateBool.value) {
//         if (_permissionService.permissionAreGranted.value) {
//           await getBondedDevices();
//         } else {
//           // showCustomDialog(
//           //     'Permisos requeridos',
//           //     'Hay permisos que no han sido otorgados, estos son requeridos para el correcto funcionamiento de Recliven Chiller.',
//           //     false, () {
//           //   openAppSettings();
//           //   turnOffBluetooth();
//           //   Get.back();
//           // }
//           // );
//         }
//       } else {
//         handleDisconnection();
//       }
//     });
//   }

//   Future<void> openBluetoothSettings() async {
//     await bluetooth.openSettings();
//   }

//   Future<void> turnOnBluetooth() async {
//     await bluetooth.requestEnable();
//     bluetoothState.value = await bluetooth.state;
//     bluetoothStateBool.value = bluetoothState.value.isEnabled;
//     print('Bluetooth encendido');
//   }

//   Future<void> turnOffBluetooth() async {
//     if (connectedDevice.value != null) {
//       handleDisconnection();
//     }
//     disableDataSubscription();
//     await bluetooth.requestDisable();
//     bluetoothState.value = await bluetooth.state;
//     bluetoothStateBool.value = bluetoothState.value.isEnabled;
//     print('Bluetooth apagado');
//   }

//   Future<void> toggleBluetooth() async {
//     if (isProcessing.value) return;
//     isProcessing.value = true;
//     try {
//       if (bluetoothState.value.isEnabled) {
//         await turnOffBluetooth();
//       } else {
//         await turnOnBluetooth();
//       }
//     } finally {
//       isProcessing.value = false;
//     }
//   }

//   void setPairing() async {
//     if (connectedDevice.value == null) {
//       bluetooth.setPairingRequestHandler((BluetoothPairingRequest request) {
//         //print("Trying to auto-pair with Pin 1234");
//         if (request.pairingVariant == PairingVariant.Pin) {
//           return Future.value("1234");
//         }
//         return Future.value(null);
//       });
//     }
//   }

// // hay que pasarle la mano para q se desvincule del seleccionado
//   Future<void> disconnectFromDevice() async {
//     if (isConnected && connection != null) {
//       connectionStateBool.value = false;
//       await connection?.close();
//       _isConnected.value = false;
//       connectedDevice.value = null;
//       disableDataSubscription();
//       isLoadingTable.value = false;
//     }
//   }

//   Future<void> autoConnectToPairedDevices() async {
//     if (!isConnected) {
//       for (BluetoothDevice device in boundedDevices) {
//         connectedDevice.value = device;
//         if (isConnected) {
//           break; // Detén el intento de conexión si ya está conectado
//         }
//       }
//     }
//   }

//   // void startDiscovery({int durationInSeconds = 10}) async {
//   //   try {
//   //     if (!permissionAreGranted.value) {
//   //       showSnackbar('Permisos',
//   //           'No se otorgaron los permisos necesarios para el descubrimiento');
//   //       return;
//   //     }
//   //     isDiscovering.value = true;
//   //     discoveredDevices.clear();

//   //     _streamSubscription = bluetooth.startDiscovery().listen((result) {
//   //       discoveredDevices.add(result.device);
//   //       // results.add(result);
//   //     });

//   //     await _streamSubscription?.asFuture();

//   //     Timer(Duration(seconds: durationInSeconds), () {
//   //       stopDiscovery();
//   //     });

//   //     _streamSubscription!.onDone(() {
//   //       stopDiscovery();
//   //     });
//   //     discoveredDevices.refresh();
//   //   } catch (e) {
//   //     print('Error al iniciar el descubrimiento: $e');
//   //   }
//   // }

//   // void stopDiscovery() {
//   //   _streamSubscription?.cancel();
//   //   isDiscovering.value = false;
//   //   print('El descubrimiento de dispositivos ha sido detenido');
//   // }

//   void startDataFetching() async {
//     if (_isFirstLoad.value) {
//       startPeriodicCommandSending(
//           BluetoothConstants.actualizarMain, const Duration(seconds: 5));
//       enableDataSubscription();
//       _isFirstLoad.value = false;
//     } else {
//       startPeriodicCommandSending(
//           BluetoothConstants.actualizarMain, const Duration(seconds: 5));
//       enableDataSubscription();
//     }
//   }

//   Future<void> connectToDevice(BluetoothDevice device) async {
//     isConnecting.value = true;
//     try {
//       // Intentar conectar con un timeout
//       connection = await BluetoothConnection.toAddress(device.address)
//           .timeout(const Duration(seconds: 30));
//       isConnecting.value = false;
//       connectedDevice.value = device;
//       // Notificar que la conexión está activa
//       _connectionStateController.sink.add(true);
//       _isConnected.value = true;
//       // deviceConnected.value = DeviceModel(
//       //     device.name, device.address, _isConnected.value, device.type);
//       connectionStateBool.value = true;

//       _subscribeToDataStream();
//       await sendCommand('C');
//       isConnecting.value = false;
//     } on TimeoutException catch (e) {
//       print('timeout: $e');
//       // Notificar que la conexión está activa
//       _connectionStateController.sink.add(false);
//       showSnackbar('Error de solicitud', 'Tiempo de solicitud agotado.');
//     } on PlatformException catch (e) {
//       print('platform: $e');
//       _connectionStateController.sink.add(false);
//       showSnackbar('Error de conexión',
//           'No se pudo establecer conexión con el dispositivo. ');
//     } catch (e) {
//       print('Catch: $e');
//       _connectionStateController.sink.add(false);
//       showSnackbar('Error  de conexión',
//           'Se ha producido un error inesperado en la conexión.');
//     } finally {
//       isConnecting.value = false;
//     }
//     update();
//   }

//   Future<void> reconnectToDevice(BluetoothDevice device) async {
//     print('Attempting to reconnect...');
//     await handleConnection(device);
//   }

//   Future<void> handleConnection(BluetoothDevice device) async {
//     print('Device name: ${device.name}');
//     print('Device address: ${device.address}');
//     try {
//       await connectToDevice(device);
//       // _connectionStream.sink.add(device);
//       if (isConnected) {
//         Get.back();
//       } else {
//         showSnackbar('Error de Conexión',
//             'No se pudo conectar al dispositivo ${device.name}.');
//       }
//     } catch (e) {
//       handleConnectionError(device);
//     }
//   }

//   Future<void> handleDisconnection() async {
//     try {
//       await disconnectFromDevice();
//       // _connectionState.value = ConnectionState.none;
//       // _connectionStream.sink.add(null);
//     } catch (e) {
//       showSnackbar(
//           'Error de desconexión', 'No se pudo desconectar del dispositivo');
//     }
//   }

//   // Method to subscribe to data stream
//   Future<void> _subscribeToDataStream() async {
//     try {
//       if (_dataSubscription == null && connection != null) {
//         _dataSubscription = connection!.input!.listen((data) {
//           handleIncomingData(data);
//         });
//       }
//     } catch (e) {
//       showErrorDialog();
//     }
//   }

//   // Method to unsubscribe from data stream
//   void _unsubscribeFromDataStream() {
//     _dataSubscription?.cancel();
//     _dataSubscription = null;
//   }

//   void enableDataSubscription() {
//     if (_dataSubscription == null) {
//       _subscribeToDataStream();
//     }
//   }

//   // Method to disable data subscription
//   void disableDataSubscription() {
//     _unsubscribeFromDataStream();
//   }

//   // Method to start periodic command sending
//   void startPeriodicCommandSending(String command, Duration interval) async {
//     periodicCommandTimer = Timer.periodic(interval, (timer) {
//       sendCommand(command);
//     });
//   }

//   // Method to stop periodic command sending
//   void stopPeriodicCommandSending() {
//     periodicCommandTimer?.cancel();
//     periodicCommandTimer = null;
//   }

//   // Method to reset working time
//   Future<void> resetWorkingTime(String circuit) async {
//     stopPeriodicCommandSending();

//     await sendCommand(BluetoothConstants.reiniciarTiempo + circuit);
//     print('Sent reset command for circuit: $circuit');

//     // enableDataSubscription();
//     startPeriodicCommandSending(
//         BluetoothConstants.actualizarMain, const Duration(seconds: 5));
//   }

//   Future<void> resetEvent(String circuit) async {
//     // disableDataSubscription();
//     stopPeriodicCommandSending();

//     await sendCommand(BluetoothConstants.atenderFalla + circuit);
//     // Wait for a response or a specific condition
//     print('Sent reset command for circuit: $circuit');

//     // enableDataSubscription();
//     startPeriodicCommandSending(
//         BluetoothConstants.actualizarMain, const Duration(seconds: 5));
//   }

//   Future<void> getBondedDevices() async {
//     try {
//       final List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
//       boundedDevices.assignAll(devices);
//     } on PlatformException {
//       print('NO se ortorgaron los permisos de localización den la app');

//       // showCustomDialog('Permisos',
//       //     'No se otorgaron los permisos de localización. Para utilizar el Bluetooth en Recliven Chiller debe de aceptarlos. Al presionar "Aceptar" otorgará los permisos que requiere Recliven Chiller para funcionar.',
//       //     () {
//       //   Get.back();
//       // });
//       // showSnackbar('Permisos',
//       //     'No se otorgaron los permisos de localización. Para utilizar el Bluetooth en Recliven Chiller debe de aceptarlos.');
//     } catch (e) {
//       print('Error al obtener dispositivos emparejados: $e');
//       showSnackbar('Permisos',
//           'No se otorgaron los permisos para utilizar el Bluetooth en Recliven Chiller.');
//     }
//   }

//   Future<void> unpairDevice(BluetoothDevice device) async {
//     try {
//       await bluetooth.removeDeviceBondWithAddress(device.address);
//       boundedDevices.remove(device);
//     } catch (e) {
//       print('Error al desvincular el dispositivo ${device.name}: $e');
//     }
//   }

//   void handleIncomingData(Uint8List data) {
//     try {
//       buffer += utf8.decode(data);
//       if (buffer.contains('\n')) {
//         List<String> messages = buffer.split('\n');
//         for (var message in messages) {
//           if (message.isNotEmpty) {
//             processMessage(message);
//           }
//         }
//         buffer = messages.last.isNotEmpty ? messages.last : '';
//       }

//       _connectionStateController.sink.add(true);
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   void processMessage(String message) {
//     print('Processing Message: $message');
//     print('stream ${stream.value}');

//     if (message.contains('O')) {
//       stream.value = true;
//       sendCommand(BluetoothConstants.tramaInicial);
//     }
//     if (stream.value) {
//       if (message.contains('F')) {
//         if (message.contains('I') || message.contains('U')) {
//           processSettingsData(message);
//         } else if (message.contains('R')) {
//           processMainData(message);
//         } else if (message.contains('Z')) {
//           processResetTime(message);
//         } else if (message.contains('W')) {
//           processToResetEvent(message);
//         } else if (message.contains('E')) {
//           processToCleanEvents();
//         } else if (message.contains('L')) {
//           processToLoadEvents(message);
//         }
//       }
//       // stream.refresh();
//     } else {
//       showSnackbar('Error', 'No se recibió respuesta del master');
//       handleDisconnection();
//     }
//   }

//   void processResetTime(String message) {
//     String circuitId = message[2];
//     print('Mensaje con el circuito $circuitId');
//     for (final c in circuitsData) {
//       if (c.circuit == int.parse(circuitId)) {
//         print('circuito e del for es ${c.circuit}');
//         c.workingTime = 0;
//         break;
//       }
//     }
//     circuitsData.refresh();
//   }

//   void processToResetEvent(String message) {
//     String circuitId = message[2];
//     print('Mensaje con el circuito $circuitId');
//     for (final c in circuitsData) {
//       if (c.circuit == int.parse(circuitId)) {
//         print('circuito e del for es ${c.circuit}');
//         c.failure = 0;
//         break;
//       }
//     }
//     circuitsData.refresh();
//   }

//   void handleRemoteDisconnection() {
//     connectionStateBool.value = false;
//     isConnecting.value = false;
//     _isConnected.value = false;
//     stream.value = false;
//     // if (connectedDevice.value != null) {
//     //   connectionStates[connectedDevice.value!.address]?.value = false;
//     // }
//     connectedDevice.value = null;
//     connection?.dispose();
//   }

//   void handleConnectionError(BluetoothDevice device) {
//     _isConnected.value = false;
//     connectionStateBool.value = false;
//     connectedDevice.value = null;
//     stream.value = false;
//     disableDataSubscription();
//     stopPeriodicCommandSending();
//     connection = null;
//     isConnecting.value = false;
//     connectionStates[device.address]?.value = false;
//     connection?.dispose();
//     showSnackbar('Error de conexión',
//         'No se pudo conectar con el dispositivo ${device.name}');
//   }

//   Future<void> sendCommand(String command) async {
//     try {
//       if (connection != null && connection!.isConnected) {
//         connection!.output.add(utf8.encode('$command\n'));
//         await connection!.output.allSent;
//         print('Comando enviado $command');
//         _connectionStateController.sink.add(true);

//         // Timer(const Duration(seconds: 10), () {
//         //   // para el caso de que no se reciba la respuesta en 10s se mostrara el mensaje de error
//         //   if (!responseCompleter.isCompleted) {
//         //     responseCompleter.complete();
//         //     showErrorDialog();
//         //   }
//         // });

//         // // Esperar por la respuesta del dispositivo
//         // await responseCompleter.future;
//       } else {
//         _connectionStateController.sink.add(false);
//         showErrorDialog();
//       }
//     } catch (e) {
//       _connectionStateController.sink.add(false);
//       showErrorDialog();
//     }
//   }

//   void processToCleanEvents() {
//     try {
//       events.clear();
//       isCleaning.value = false;
//       _connectionStateController.sink.add(true);

//       update();
//     } catch (e) {
//       _connectionStateController.sink.add(false);

//       showErrorDialog();
//     }
//   }

//   void processToLoadEvents(String data) {
//     try {
//       // Dividir la cadena de datos en partes individuales utilizando 'F' como separador
//       final parts = data.split('F');
//       print('Parts main: $parts');

//       events.clear();
//       isLoadingTable.value = true; // Start loading

//       for (final part in parts) {
//         if (part.isNotEmpty) {
//           // Dividir cada parte utilizando 'S' como separador
//           final subParts = part.split('S');
//           print('Subparts main: $subParts');
//           // Asegurar que la parte tenga al menos 6 subpartes (día, mes, año, hora, minuto, evento, circuito, tiempo acumulado)
//           if (subParts.length >= 6) {
//             final String dateEvent = subParts[1];
//             final String timeEvent = subParts[2];
//             final String typeEvent = subParts[3];
//             final String circuit = subParts[4];
//             final String accumulatedTime = subParts[5];

//             // Agregar los datos al circuito
//             events.add(EventsInfoModel(
//               dateEvent: dateEvent,
//               timeEvent: timeEvent,
//               typeEvento: typeEvent,
//               circuitEvent: circuit,
//               accumulatedTime: accumulatedTime,
//             ));
//           } else {
//             print('Valor numérico de los datos inválidos');
//           }
//         }
//       }
//       _connectionStateController.sink.add(true);
//       isLoadingTable.value = false; // Finish loading
//       update();
//     } catch (e) {
//       // showSnackbar('Error', 'Error processing main data: $e');
//       _connectionStateController.sink.add(false);
//       print('Error processing main data');
//     }
//   }

//   void processMainData(String data) {
//     try {
//       // Dividir la cadena de datos en partes individuales utilizando 'F' como separador
//       final parts = data.split('F');
//       print('Parts main: $parts');

//       circuitsData.clear();

//       for (final part in parts) {
//         if (part.isNotEmpty) {
//           // Dividir cada parte utilizando 'S' como separador
//           final subParts = part.split('S');
//           print('Subparts main: $subParts');
//           // Asegurar que la parte tenga al menos 3 subpartes (circuito, fallo, tiempo trabajado)
//           if (subParts.length >= 4) {
//             final String idStr = subParts[1];
//             final String value1Str = subParts[2];
//             final String value2Str = subParts[3];
//             // Validar si los valores pueden ser convertidos a enteros
//             if (isNumeric(idStr) &&
//                 isNumeric(value1Str) &&
//                 isNumeric(value2Str)) {
//               final int id = int.parse(idStr);
//               final int value1 = int.parse(value1Str);
//               final int value2 = int.parse(value2Str);

//               // Agregar los datos al circuito
//               circuitsData.add(CircuitData(id, value1, value2));
//               _status.value = RequestState.success;
//             } else {
//               print(
//                   'Valor numerico de los datos invalidos: $idStr, $value1Str, $value2Str');
//             }
//           } else {
//             print('Insuficiente numero de datos $subParts');
//           }
//         }
//         buffer = '';
//       }
//     } catch (e) {
//       showSnackbar('Error', 'Error al procesar los datos: $e');
//       _status.value = RequestState.error;
//     }
//   }

//   bool isNumeric(String? str) => str != null && int.tryParse(str) != null;

//   void processSettingsData(String data) {
//     try {
//       final parts = data.split('F');
//       print('Parts settings: $parts');
//       for (final part in parts) {
//         if (part.isNotEmpty) {
//           // Dividir cada parte utilizando 'S' como delimitador
//           subParts.value = part.split('S');

//           // Asegurar que la parte tenga al menos 4 subpartes (setpointTemp, difTotal, numEsclavos, anticicloCorto)
//           if (subParts.length >= 5) {
//             setpointTempController.value.text = subParts[1];
//             difTotalController.value.text = subParts[2];
//             numEsclavosController.value.text = subParts[3];
//             anticicloCortoController.value.text = subParts[4];
//           }
//         }
//       }
//       settingsIsLoading.value = false;
//       update();
//       // showSnackbar('Confirmación', 'Configuración actualizada');
//     } catch (e) {
//       print('Error al procesar los datos de configuracion: $e');
//     }
//   }

//   void loadInitialSettings() {
//     if (stream.value) {
//       sendCommand(BluetoothConstants.tramaInicial);
//     }
//   }

//   //manejo de los eventos en el EventsScreen
//   void loadEvents() {
//     sendCommand(BluetoothConstants.loadEvents);
//   }

//   void clearData() {
//     sendCommand(BluetoothConstants.eraseEvents);
//   }

//   void sendConfigToDevice(String data) {
//     sendCommand(data);
//   }

//   void updateConnectionStatus(bool status) {
//     connectionStateBool.value = status;
//   }
// }
