//se definen los comandos que emplea la app

class BluetoothConstants {
  //tramas
  static const String tramaInicial =
      'I'; //me mandas la configuracion actual del master
  static const String finDeTrama = 'F';

  //confirmacion
  static const String ok = 'O';

  //separador
  static const String separador = 'S';

  //solicitudes actualizar los screeens (envio U+trama config new)
  static const String updateSettings =
      'U'; // envio de configuracion nueva se responde ok
  static const String actualizarMain = 'R'; //cada 5 seg con el timer

  //solicitudes de conexion
  static const String conectado = 'C';
  static const String disconneted = 'D';

  //atender eventos en el main
  static const String reiniciarTiempo = 'Z'; //circuito,
  static const String atenderFalla = 'W'; //circuito

  //para los eventos screeen
  static const String loadEvents = 'L';
  static const String eraseEvents = 'E';
  static const String exportEvents = 'X';
  static const String separatorEvents = 'T';
  //poner dos botones cargar(L), exportar(X), limpiar(E) (para evitar)
}

/*
eventos: apagado por ...
bit 0: on/off
bit 1: presion de alta 1-activo 0-normal
bit 2: presion de baja 1-activo 0-normal
bit 3: presion de aceite 1-activo 0-normal

cualquiera que tenga fallo se apagara 
el evento es Apagado por: tal cosa [segun el bit activo tengo q reparar el codigo para mostrar los tres]

*/

/*
primero se envia C


 */

//'U'-update configuracion
//'R'-actualizar el principal
//'C'-connectado me confirmas con O + numero de esclavos
//'D'-disconneted
//'I'-trama inicial contiene (configuracion de master actual)
//'R'-leer configuracion actual -
//'O'-ok para todas las peticiones que se hagan
//'S' separador
//'F' fin de trama
//'Z'-reiniciar el tiempo
//'W'-falla atendida