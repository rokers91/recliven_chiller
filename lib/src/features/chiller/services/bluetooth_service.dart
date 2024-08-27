// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/services.dart';

//se encarga este servicio de manejar todo lo referente al bluetooth, conexion-desconexion,
//obtener dispositivos vinculados, etc.
class BluetoothService extends GetxService {
  final PermissionService _permissionService = Get.find();

  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  RxBool bluetoothStateBool = false.obs;
  var isProcessing = false.obs;

  BluetoothConnection? connection;
  Rx<bool> isConnecting = false.obs;
  var isConnected = false.obs;
  var connectedDevice = Rx<BluetoothDevice?>(null);

  RxList<BluetoothDevice> bondedDevices = <BluetoothDevice>[].obs;

  StreamSubscription? _dataSubscription;
  RxBool isFirstLoad = true.obs;

  String buffer = '';
  RxBool stream = false.obs;
  RxString lastMessage = ''.obs;

  final RxBool _shouldSendPeriodicCommands = true.obs;

  Timer? periodicCommandTimer;

  final _responseController = StreamController<String>.broadcast();

  Stream<String> get responseStream => _responseController.stream;

  @override
  void onInit() {
    super.onInit();
    //se chequea el estado de los permisos para proceder a inicializar el bluetooth
    _permissionService.requestAllPermissions();
    if (_permissionService.permissionAreGranted.value) {
      inicializeBluetooth();
    }
  }

  @override
  void onClose() {
    super.onClose();
    _responseController.close();
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    connection?.close();
    connectedDevice.value = null;
    isConnected.value = false;
    disableDataSubscription();
    stopPeriodicCommandSending();
  }

  //inicializa el bluetooth
  void inicializeBluetooth() {
    checkState();
  }

  void addResponse(String message) {
    print('Message: $message');

    _responseController.add(message);
  }

  // Escucha los cambios de estado Bluetooth
  Future<void> checkState() async {
    try {
      // Obtener el estado inicial del Bluetooth
      BluetoothState initialState = await bluetooth.state;
      _updateBluetoothState(initialState.isEnabled);

      // Escuchar los cambios en el estado del Bluetooth
      bluetooth.onStateChanged().listen((BluetoothState state) async {
        _updateBluetoothState(state.isEnabled);
        if (bluetoothStateBool.value) {
          await _handleBluetoothEnabled();
        } else {
          disconnect();
        }
      });
    } catch (e) {
      print('Error al comprobar el estado del Bluetooth: $e');
      // Manejo de error adicional si es necesario
    }
  }

//actualiza el estado del bluetooth
  void _updateBluetoothState(bool isEnabled) {
    bluetoothStateBool.value = isEnabled;
  }

//maneja los casos cuando el bluetooth esta habilitado
  Future<void> _handleBluetoothEnabled() async {
    try {
      await getBondedDevices();

      // Intentar reconectar a un dispositivo previamente conectado si está disponible
      if (connectedDevice.value != null) {
        await connectToDeviceWithRetry(connectedDevice.value!);
      }
    } catch (e) {
      print('Error al manejar Bluetooth habilitado: $e');
      // Manejo de error adicional si es necesario
    }
  }
  // Future<void> checkState() async {
  //   // Obtener el estado inicial del Bluetooth
  //   BluetoothState initialState = await bluetooth.state;
  //   bluetoothStateBool.value = initialState.isEnabled;

  //   // Manejar el estado inicial del Bluetooth
  //   if (bluetoothStateBool.value) {
  //     await getBondedDevices();
  //   } else {
  //     disconnect();
  //   }

  //   // Escuchar los cambios en el estado del Bluetooth
  //   bluetooth.onStateChanged().listen((BluetoothState state) async {
  //     bluetoothStateBool.value = state.isEnabled;
  //     if (bluetoothStateBool.value) {
  //       await getBondedDevices();
  //       // Intentar reconectar a un dispositivo previamente conectado si está disponible
  //       if (connectedDevice.value != null) {
  //         await connectToDeviceWithRetry(connectedDevice.value!);
  //       }
  //       // Realizar alguna acción cuando el Bluetooth se enciende
  //     } else {
  //       disconnect();
  //     }
  //   });
  // }

  //enciende el bluetooth
  Future<void> turnOnBluetooth() async {
    try {
      await bluetooth.requestEnable();
    } catch (e) {
      print('On bluetooth $e');
    }
  }

  //apaga el bluetooth
  Future<void> turnOffBluetooth() async {
    try {
      await bluetooth.requestDisable();
      disconnect();
    } catch (e) {
      print('Off bluetooth $e');
    }
  }

  //para on/off el bluetooth
  Future<void> toggleBluetooth() async {
    if (bluetoothStateBool.value) {
      await turnOffBluetooth();
    } else {
      await turnOnBluetooth();
    }
  }

  //abre los ajustes bluetooth del cell
  Future<void> openBluetoothSettings() async {
    await bluetooth.openSettings();
  }

  //obtener dispositivos previamente vinculados
  Future<void> getBondedDevices() async {
    try {
      final List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      bondedDevices.assignAll(devices);
    } catch (e) {
      print('Error obteniendo dispositivos vinculados: $e');
    }
  }

  //metodo para detener la transmision de datos
  void _unsubscribeFromDataStream() {
    _dataSubscription?.cancel();
    _dataSubscription = null;
  }

  //para conectarse al dispositivo
  Future<void> connectToDevice(BluetoothDevice device) async {
    isConnecting.value = true;
    try {
      connection = await BluetoothConnection.toAddress(device.address)
          .timeout(const Duration(seconds: 30));
      if (connection != null && connection!.isConnected) {
        isConnected.value = true;
        connectedDevice.value = device;
        sendCommand(BluetoothConstants.conectado);
        _subscribeToDataStream();
      } else {
        handleConnectionError('Connection failed');
      }
    } on TimeoutException catch (e) {
      print('timeout: $e');
      handleConnectionError('Tiempo de conexión agotado.');
    } on PlatformException catch (e) {
      print('platform: $e');
      handleConnectionError('Error en la conexión.');
    } catch (e) {
      print('e: $e');
      handleConnectionError('Error en la conexión.');
    } finally {
      isConnecting.value = false;
    }
  }

  //para lograr el flujo de datos, escuchar
  Future<void> _subscribeToDataStream() async {
    try {
      if (_dataSubscription == null && connection != null) {
        _dataSubscription = connection!.input!.listen((data) {
          handleIncomingData(data);
        });
      } else {
        handleConnectionError('Error de conexión');
      }
    } catch (e) {
      handleConnectionError('Error de conexión');
    }
  }

  //reintentar la conexion
  Future<void> retryConnection(BluetoothDevice device, int retries) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      print('Intento $attempt para conectar a ${device.address}');
      try {
        await connectToDevice(device);
        if (isConnected.value) {
          print('Conectado en el intento $attempt');
          return;
        }
      } catch (e) {
        print('$attempt fallidos: $e');
      }
    }
    handleConnectionError('Error al conectar luego de $retries intentos.');
  }

  //para conectarse y activar reintentos
  Future<void> connectToDeviceWithRetry(BluetoothDevice device,
      {int retries = 3}) async {
    await retryConnection(device, retries);
  }

  //para desconectarse
  Future<void> disconnect() async {
    if (isConnected.value && connection != null) {
      await connection?.close();
      connectedDevice.value = null;
      isConnected.value = false;
      _dataSubscription?.cancel();
      _dataSubscription = null;
    } else {
      await connection?.close();
      connectedDevice.value = null;
      isConnected.value = false;
      _dataSubscription?.cancel();
      _dataSubscription = null;
    }
  }

  //meneja los estados de error de conexion
  void handleConnectionError(dynamic error) {
    print('Connection error: $error');
    isConnected.value = false;
  }

  //maneja los datos que entran a la app y los envia a procesar
  void handleIncomingData(Uint8List data) {
    try {
      buffer += utf8.decode(data);
      if (buffer.contains('\n')) {
        List<String> messages = buffer.split('\n');
        for (var message in messages) {
          if (message.isNotEmpty) {
            processMessage(message);
          }
        }
        buffer = messages.last.isNotEmpty ? messages.last : '';
        print('buffer: $buffer');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //se procesa los mensajes recibidos
  void processMessage(String message) {
    if (message.contains(BluetoothConstants.ok)) {
      stream.value = true;
      sendCommand(
          BluetoothConstants.actualizarMain); // Notificar al SettingsController
    } else if (message.isEmpty) {
      //todo enviar nuevamente el comando o repetir la operacion al usuario
    } else {
      lastMessage.value = message;
      addResponse(message);
    }
  }

  //para poner la contraseña cuando es vinculado por primera vez
  Future<void> setPairing() async {
    bluetooth.setPairingRequestHandler((BluetoothPairingRequest request) {
      if (request.pairingVariant == PairingVariant.Pin) {
        return Future.value("1234");
      }
      return Future.value(null);
    });
  }

  //para el envio de comandos
  Future<dynamic> sendCommand(String command) async {
    try {
      // _shouldSendPeriodicCommands.value = false;
      if (connection != null && connection!.isConnected) {
        connection?.output.add(utf8.encode("$command\n") as Uint8List);
        print('Command sent: $command');
        var test = await connection?.output.allSent;
        return test;
      } else {
        handleConnectionError('Error en la conexión');
      }
    } catch (e) {
      handleConnectionError('Error de conexión');
    }
  }

  // Metodo para habilitar la subscripcion de datos
  void enableDataSubscription() {
    if (_dataSubscription == null) {
      _subscribeToDataStream();
    }
  }

  // Metodo para detener la subscripcion de datos
  void disableDataSubscription() {
    _unsubscribeFromDataStream();
  }

  //metodo para iniciar el envio periodico de comandos
  void startPeriodicCommandSending(String command, Duration interval) async {
    _shouldSendPeriodicCommands.value = true;
    if (_shouldSendPeriodicCommands.value) {
      periodicCommandTimer = Timer.periodic(interval, (timer) {
        if (_shouldSendPeriodicCommands.value && isConnected.value) {
          sendCommand(command);
        }
      });
    }
  }

  //metodo para detener el envio periodico de comandos
  void stopPeriodicCommandSending() {
    _shouldSendPeriodicCommands.value = false;
    periodicCommandTimer?.cancel();
  }

  //metodo para reanudar el envio periodico de comandos
  void resumePeriodicCommandSending(String command, Duration interval) {
    startPeriodicCommandSending(command, interval);
  }
}
