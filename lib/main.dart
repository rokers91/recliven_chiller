import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:recliven_chiller/src/features/chiller/bindings/initial_bindings.dart';
import 'package:recliven_chiller/barrel/pages.dart';
import 'package:recliven_chiller/barrel/core.dart';

//archivo principal de la app

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

// aplicacion principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //se define tamaño de la app
        return ScreenUtilInit(
          minTextAdapt: true,
          designSize: ScreenUtilsConfig.getDesignSize(context),
          builder: (context, child) {
            //se inicializa el gstor del estado
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Recliven Chiller',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
                appBarTheme: const AppBarTheme(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                ),
                primarySwatch: Colors.blue,
              ),
              //se inicializan las dependencias
              initialBinding: InitialBinding(),
              home: const HomePage(),
            );
          },
        );
      },
    );
  }
}
