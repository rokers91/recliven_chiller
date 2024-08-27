import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';

import 'package:recliven_chiller/barrel/core.dart';

// se muestra la informacion de la app, su instalacion , etc.

//se emplea para los casos que se amplie la imagen del info
class ImageController extends GetxController {
  void showImageDialog(String imagePath) {
    Get.dialog(
      ResponsiveImageDialog(imagePath: imagePath),
    );
  }
}

//se define como se mostrara la imagen
class ResponsiveImageDialog extends GetResponsiveView<ImageController> {
  final String imagePath;

  ResponsiveImageDialog({super.key, required this.imagePath});

  @override
  Widget builder() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PhotoView(
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        imageProvider: AssetImage(imagePath),
      ),
    );
  }
}

const acercadereclivenString =
    'Recliven Chiller es una herramienta soportada sobre tecnologías Android, con gran utilidad para la comunicación remota entre los usuarios del controlador digital para chillers.';
const requerimientosString =
    'Para el empleo de la aplicación y su correcto funcionamiento el usuario debe contar con un dispositivo móvil con Sistema Operativo Android, versión 5.0 (LOLLIPOP , L) o superior, y con un espacio de almacenamiento de 50 MB.';
const instalacionString =
    'Una vez descargada e instalada la aplicación Recliven Chiller, cuando la ejecutamos por primera vez, se deben otorgar los permisos necesarios para el correcto funcionamiento. Para ello presione sobre el botón "Permitir solo con la app en uso".';
const conectotrodispString =
    'Después de estar conectado puede  presionar el botón “RCV” y podrá visualizar un cuadro de dialogo para confirmar realmente si desea desconectar y conectar con otro dispositivo. Si se confirma se desconectará y se listarán los dispositivos disponibles al que puede conectarse.';

//controlador de los expanded
class ExpansionController extends GetxController {
  var expandedIndex = 0.obs;

  void setExpandedIndex(int index) {
    expandedIndex.value = index;
  }
}

//pantalla que muestra la info de la app
class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Color de la barra de estado
      statusBarIconBrightness:
          Brightness.light, // Color de los íconos de la barra de estado
    ));

    final ImageController imageController = Get.put(ImageController());
    final ExpansionController expansionController =
        Get.put(ExpansionController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Acerca de Recliven Chiller',
          style: TextStyle(
            fontSize: SizeConstants.textSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppColors.backgroundColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Obx(() => ListView.builder(
            itemCount:
                _buildExpansionTileList(imageController, expansionController)
                    .length,
            itemBuilder: (BuildContext context, int index) =>
                _buildExpansionTileList(
                    imageController, expansionController)[index],
          )),
    );
  }
}

List<ExpansionTile> _buildExpansionTileList(
    ImageController imageController, ExpansionController expansionController) {
  return [
    _buildExpansionTile(0, 'Acerca de Recliven Chiller', acercadereclivenString,
        imageController, expansionController),
    _buildExpansionTile(1, 'Requerimientos', requerimientosString,
        imageController, expansionController),
    _buildExpansionTile(2, 'Instalación y configuración', instalacionString,
        imageController, expansionController, [
      _buildImageWithZoom("assets/info/inicio.png", imageController),
      // const CustomText(
      //   text:
      //       'En cada uno de los permisos que aparezcan desactivados presione sobre ellos, en cada uno de esos casos presione: “Mientras la app está en uso o Permitir”',
      // ),
      // _buildImageWithZoom("assets/info/permiso_ubicacion.png", imageController),
      // _buildImageWithZoom(
      //     "assets/info/permiso_almacenamiento.png", imageController),
      // const CustomText(
      //   text: 'Cuando todos los permisos esten aceptados, presione "Aceptar".',
      // ),
      // _buildImageWithZoom(
      //     "assets/info/permisos_aceptados.png", imageController),
    ]),
    _buildExpansionTile(3, 'Cómo acceder la aplicación', '', imageController,
        expansionController, [
      const CustomText(
          text:
              '1 - Al presionar Conectar, se mostrará un menú en el que se podrá activar el Bluetooth y observar los dispositivos disponibles para conexión.'),
      _buildImageWithZoom('assets/info/bonded_clear.png', imageController),
      const CustomText(
          text:
              '2 - Cuando se presione el botón para activar el Bluetooth, que inicialmente está desconectado, se pedirán los permisos de acceso al mismo desde la app. Presione "Permitir" para activarlo.'),
      _buildImageWithZoom('assets/info/bonded_permisos.png', imageController),
      const CustomText(
          text:
              '3- Ahora puede seleccionar el dispositivo a conectar de los que aparecen en la lista de Dispositivos Vinculados. Si el dispositivo no se encuentra en dicha lista, presione el icono de configuración para buscar nuevos. Una vez presionado se mostrará esta pantalla en la que podrá buscar y vincular el dispositivo. La clave si no ha sido modificada será 1234, pero esto no se debe de preocupar ya que se realiza automaticamente.'),
      _buildImageWithZoom('assets/info/settings_1.png', imageController),
      const CustomText(
          text:
              '4- Cuando se logre vincular se mostrará en la lista de Dispositivos Vinculados. Presione atrás para salir de esta pantalla.'),
      _buildImageWithZoom('assets/info/settings_2.png', imageController),
      const CustomText(
          text:
              '5- Ahora la lista de Dispositivos Vinculados estará actualizada con el nuevo dispositivo añadido. Presione el dispositivo deseado para conectar.'),
      _buildImageWithZoom('assets/info/bonded_list.png', imageController),
      const CustomText(
          text:
              '6- Una vez realizado todos estos pasos donde estaba Conectar aparecerá el nombre del dispositivo conectado y se visualizarán los datos recibidos.'),
      _buildImageWithZoom('assets/info/main_view.png', imageController),
    ]),
    _buildExpansionTile(
        4,
        'Recliven Chiller estructura',
        'Recliven Chiller cuenta con tres pantallas. Principal donde se visualiza el estado de los circuitos del chiller. Configuración para ajustar parámetros en el dispositivo maestro. Fallos en la que se podrá cargar los datos históricos de los fallos y limpiarlos.',
        imageController,
        expansionController, [
      const CustomText(
        text: 'Principal:',
        fontType: FontWeight.bold,
      ),
      _buildImageWithZoom('assets/info/main_view.png', imageController),
      const CustomText(
        text: 'Configuración:',
        fontType: FontWeight.bold,
      ),
      _buildImageWithZoom('assets/info/settings_view.png', imageController),
      const CustomText(
        text: 'Fallos:',
        fontType: FontWeight.bold,
      ),
      _buildImageWithZoom('assets/info/fallos_view_1.png', imageController),
    ]),
    _buildExpansionTile(
        5,
        'Configuración',
        'En esta pantalla se visualizará la configuración actual del maestro y se podrá cargar una nueva al modificar los campos y presionar Actualizar.',
        imageController,
        expansionController, [
      _buildImageWithZoom('assets/info/settings_view.png', imageController),
    ]),
    _buildExpansionTile(
        6,
        'Principal',
        'Se visualizan cada uno de los estados de los circuitos del chiller [Circuito, Tiempo trabajado (h), Fallo en caso de existir alguno y Estado (Encendido-Reposo-Apagado)], este último requiere atención ya que se muestra solamente cuando hay fallos en algún circuito.',
        imageController,
        expansionController, [
      _buildImageWithZoom('assets/info/main_view.png', imageController),
      const CustomText(
        text:
            'Cuando el usuario desee reiniciar el Tiempo Trabajado presione el icono de reiniciar, luego se mostrará la siguiente ventana de confirmación, presione Aceptar o no según desee.',
      ),
      _buildImageWithZoom(
          'assets/info/confirm_reset_time.png', imageController),
      const CustomText(
          text:
              'Lo mismo cuando se desee reiniciar el Fallo, presione el icono de reiniciar y se mostrará la ventana de confirmación.'),
      _buildImageWithZoom(
          'assets/info/fallo_view_confirm.png', imageController),
    ]),
    _buildExpansionTile(
        7,
        'Fallos',
        'En esta ventana se accede a la tabla de fallos que posee el maestro. Inicialmente no habrá datos.',
        imageController,
        expansionController, [
      _buildImageWithZoom('assets/info/fallos_view_1.png', imageController),
      const CustomText(
        text:
            'Al presionar Cargar datos, se visualizarán los datos que posee el maestro en ese momento y las opciones para exportar o limpiar esos datos.',
      ),
      _buildImageWithZoom('assets/info/fallos_table.png', imageController),
      const CustomText(
        text:
            'Al presionar Limpiar, se visualizará un cuadro de confirmación. Presione Aceptar si está seguro de limpiar la tabla.',
      ),
      _buildImageWithZoom('assets/info/fallos_view_clear.png', imageController),
      const CustomText(
        text:
            'Al presionar Exportar, se visualizará un cuadro en el que podrá seleccionar el tipo de archivo al que desea exportar los datos (Excel o txt).',
      ),
      _buildImageWithZoom('assets/info/fallos_export_1.png', imageController),
      SizedBox(
        height: SizeConstants.paddingMedium,
      ),
      _buildImageWithZoom('assets/info/fallos_export_2.png', imageController),
      const CustomText(
        text:
            'Al presionar Aceptar se mostrará un mensaje confirmando que los datos de la tabla han sido exportados satisfactoriamente, junto a la ubicación del mismo.',
      ),
      _buildImageWithZoom(
          'assets/info/fallos_view_success.png', imageController),
    ]),
    _buildExpansionTile(
        8,
        'Salir de la aplicación',
        'Cuando presione sobre el botón Salir, se mostrará esta ventana de confirmación para cerrar la app. Si es así presione Si.',
        imageController,
        expansionController, [
      _buildImageWithZoom('assets/info/exit_confitm.png', imageController),
    ]),
  ];
}

class CustomText extends StatelessWidget {
  final String text;
  final FontWeight fontType;
  const CustomText(
      {super.key, required this.text, this.fontType = FontWeight.normal});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: SizeConstants.textSizeMedium, fontWeight: fontType),
      textAlign: TextAlign.justify,
    );
  }
}

ExpansionTile _buildExpansionTile(int index, String title, String content,
    ImageController imageController, ExpansionController expansionController,
    [List<Widget>? children]) {
  return ExpansionTile(
    key: PageStorageKey<int>(index),
    initiallyExpanded: expansionController.expandedIndex.value == index,
    title: Text(
      title,
      style: TextStyle(
          fontSize: SizeConstants.textSizeLarge, fontWeight: FontWeight.bold),
    ),
    onExpansionChanged: (bool expanded) {
      if (expanded) {
        expansionController.setExpandedIndex(index);
      }
    },
    children: children != null
        ? [_buildCard(content, children)]
        : [_buildCard(content)],
  );
}

Card _buildCard(String content, [List<Widget>? additionalContent]) {
  return Card(
    elevation: SizeConstants.elevation,
    margin: EdgeInsets.symmetric(
      vertical: SizeConstants.paddingMedium,
      horizontal: SizeConstants.paddingLarge,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SizeConstants.borderRadiusMedium),
    ),
    child: Padding(
      padding: EdgeInsets.all(SizeConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: SizeConstants.textSizeMedium),
          ),
          if (additionalContent != null) ...additionalContent,
        ],
      ),
    ),
  );
}

Widget _buildImageWithZoom(String assetPath, ImageController imageController) {
  return GestureDetector(
    onTap: () {
      imageController.showImageDialog(assetPath);
    },
    child: Center(
      child: Image.asset(
        assetPath,
        height: SizeConstants.imageHeightLargeExtended,
        width: SizeConstants.imageWidthLargeExtended,
      ),
    ),
  );
}
