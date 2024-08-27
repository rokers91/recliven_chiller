import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

//este servicio se encarga de todo lo referente al manejo de los permisos de la app
class PermissionService extends GetxService {
  var permissionAreGranted = false.obs;
  var hasPermissionsGranted = false;
  var locationGranted = false.obs;

  PermissionStatus status = PermissionStatus.denied;

  //solicitar estado de los permisos y se almacena en permissionAreGranted
  Future<void> requestAllPermissions() async {
    final permissions = [
      Permission.location,
    ];

    hasPermissionsGranted = await hasAllPermissions(permissions);

    if (!hasPermissionsGranted) {
      Map<Permission, PermissionStatus> status = await permissions.request();
      permissionAreGranted.value =
          status.values.every((element) => element.isGranted);
    }
  }

  //solicitar estado de todos los permisos
  Future<bool> hasAllPermissions(List<Permission> permissions) async {
    bool hasPermissions = true;

    for (var permission in permissions) {
      PermissionStatus status = await permission.status;
      if (!status.isGranted) {
        hasPermissions = false;
        break;
      }
    }
    return hasPermissions;
  }

  //chequea el estado de los permisos
  Future<bool> checkPermissionStatus(Permission permission) async {
    status = await permission.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  //abre los ajustes de la app
  Future<bool> openReclivenChillerSettings() async {
    //se retorna true si se abre
    return await openAppSettings();
  }
}
