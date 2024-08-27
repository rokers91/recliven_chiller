// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/barrel/core.dart';
import 'package:recliven_chiller/barrel/services.dart';
import 'package:recliven_chiller/barrel/controllers.dart';
import 'package:recliven_chiller/src/features/chiller/pages/info_page.dart';
import 'package:recliven_chiller/barrel/screens.dart';
import 'package:recliven_chiller/barrel/widgets.dart';

//estructura principal de la app, aca se integran todos los screen y se muestra el tabbar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BluetoothService _bluetoothService = Get.find();
  MyTabController tabController = Get.find();
  final MainController _mainController = Get.find();

  @override
  void initState() {
    //se escucha por los cambios de indice y se procede en cada caso a detener o iniciar el envio
    // de comandos periodicos
    ever(tabController.currentIndex, (index) {
      if (index == 0) {
        _mainController.stopPeriodicCommandSending();
      } else if (index == 1) {
        _mainController.startPeriodicCommandSending();
      } else if (index == 2) {
        _mainController.stopPeriodicCommandSending();
      }
    });
    //se escucha por el estado de la conexion
    _bluetoothService.isConnected.listen((isConnected) {
      if (!isConnected) {
        _bluetoothService.handleConnectionError('Error de conexión');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                _buildHeader(),
                Positioned(
                  top: SizeConstants.paddingSmall,
                  right: SizeConstants.paddingSmall,
                  child: IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      size: SizeConstants.iconSizeMedium,
                    ),
                    onPressed: () {
                      if (!Get.isSnackbarOpen) {
                        Get.to(() => const InfoPage());
                      }
                    },
                  ),
                ),
              ],
            ),
            Obx(() {
              if (_bluetoothService.isConnecting.value) {
                return Expanded(
                  child: LoadingIndicator(
                    loadingKey: 'startingConnection',
                    color: AppColors.primaryColorOrange300,
                    isLoading: _bluetoothService.isConnecting.value,
                  ),
                );
              } else {
                final isConnected =
                    _bluetoothService.connectedDevice.value?.isConnected;
                final isBonded =
                    _bluetoothService.connectedDevice.value?.isBonded;
                if (isConnected != null ||
                    (isBonded != null && isBonded == true)) {
                  //se define los elementos del tabbar
                  return Expanded(
                    child: TabBarView(
                      controller: tabController.tabController,
                      children: [
                        FailuresScreen(),
                        const MainScreen(),
                        SettingsScreen(),
                      ],
                    ),
                  );
                } else {
                  return const Expanded(child: Center(child: NoConnection()));
                }
              }
            }),
          ],
        ),
        bottomNavigationBar: Obx(() {
          final isConnected =
              _bluetoothService.connectedDevice.value?.isConnected != null &&
                  _bluetoothService.isConnected.value;
          return isConnected
              ? _buildBottomNavigationBar()
              : const SizedBox.shrink();
        }),
      ),
    );
  }

  //se construye el header de la app
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeConstants.paddingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SizeConstants.borderRadiusLarge),
          bottomRight: Radius.circular(SizeConstants.borderRadiusLarge),
        ),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            AppColors.primaryColorOrange400,
            AppColors.primaryColorOrange100
          ],
        ),
      ),
      child: Column(
        children: [
          //imagen con el logo de recliven
          Image.asset('assets/images/recliven_logo.png',
              width: SizeConstants.imageWidthLarge,
              height: SizeConstants.imageHeightMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() {
                final isConnected = _bluetoothService.isConnected.value;
                final name = _bluetoothService.connectedDevice.value?.name;
                //boton de conexion
                return OptionsMainButtons(
                  title: (isConnected) ? name ?? '' : 'Conectar',
                  icon: Icons.bluetooth,
                  onTap: () {
                    if (!Get.isSnackbarOpen) {
                      showBluetoothConnectionsSheetOptions(_bluetoothService);
                    }
                  },
                );
              }),
              //boton de salir de la app
              OptionsMainButtons(
                title: 'Salir',
                icon: Icons.exit_to_app,
                onTap: () {
                  if (!Get.isSnackbarOpen) {
                    showCustomDialog('Confirmación',
                        'Seguro desea abandonar la aplicación?', true, () {
                      _bluetoothService.disconnect();
                      exit(0);
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //se construye el tabbar con los elementos definidos anteriormente
  Widget _buildBottomNavigationBar() {
    return Material(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(SizeConstants.borderRadiusMedium),
        topRight: Radius.circular(SizeConstants.borderRadiusMedium),
      ),
      color: AppColors.primaryColorOrange400,
      child: TabBar(
        controller: tabController.tabController,
        indicatorColor: AppColors.blackColorWithOpacity,
        indicatorWeight: 2.0,
        labelColor: Colors.black54,
        unselectedLabelColor: AppColors.blackColorWithOpacity,
        labelStyle: TextStyle(
            fontSize: SizeConstants.textSizeLarge, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(
            color: AppColors.blackColorWithOpacity,
            fontSize: SizeConstants.textSizeMedium),
        tabs: [
          Tab(
              height: kToolbarHeight,
              child: Text('Fallos',
                  style: TextStyle(
                      color: AppColors.blackColorWithOpacity,
                      fontSize: SizeConstants.textSizeLarge),
                  overflow: TextOverflow.ellipsis)),
          Tab(
              child: Text('Principal',
                  style: TextStyle(
                      color: AppColors.blackColorWithOpacity,
                      fontSize: SizeConstants.textSizeLarge),
                  overflow: TextOverflow.ellipsis)),
          Tab(
              child: Text('Configuración',
                  style: TextStyle(
                      color: AppColors.blackColorWithOpacity,
                      fontSize: SizeConstants.textSizeLarge),
                  overflow: TextOverflow.ellipsis)),
        ],
        onTap: (int index) {
          tabController.onTabBarChange(index);
        },
      ),
    );
  }
}

//se define la apariencia de los botones del header
class OptionsMainButtons extends StatelessWidget {
  final void Function()? onTap;
  final IconData? icon;
  final String title;
  final Color? color;

  const OptionsMainButtons({
    super.key,
    this.onTap,
    this.icon,
    this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          IconButton(
            color: color,
            onPressed: onTap,
            icon: Icon(icon,
                size: SizeConstants.iconSizeLarge, color: Colors.black54),
          ),
          Text(
            title,
            style: TextStyle(
                color: Colors.black54,
                fontSize: SizeConstants.textSizeLargeExtended,
                fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
