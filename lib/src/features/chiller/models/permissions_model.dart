import 'package:permission_handler/permission_handler.dart';

//modelo para los permisos

class PermissionData {
  final Permission type;
  final String title;
  final bool isGranted;

  PermissionData({
    required this.type,
    required this.title,
    required this.isGranted,
  });
}
