//este archivo se emplea para manejar la logica de los datos recibidos que
//contienen info de los fallos, de manera que sea entendible por el usuario

enum CircuitState { presionDown, presionHigh, oil, on, off, none }

class Dato {
  int valor;

  Dato(this.valor);

  // Obtener el estado del bit 0 (on/off)
  bool get isOn => valor & 0x01 == 0x01;

  // Obtener los estados de los fallos
  List<CircuitState> get fallos {
    List<CircuitState> estados = [];

    if (!isOn) {
      if (valor & 0x08 == 0x08) {
        estados.add(CircuitState.oil);
      }
      if (valor & 0x04 == 0x04) {
        estados.add(CircuitState.presionDown);
      }
      if (valor & 0x02 == 0x02) {
        estados.add(CircuitState.presionHigh);
      }
      if (estados.isEmpty) {
        estados.add(CircuitState.off);
      }
    } else {
      estados.add(CircuitState.on);
    }

    if (estados.isEmpty) {
      estados.add(CircuitState.none);
    }

    return estados;
  }

  // Obtener la descripción de todos los fallos
  String get descripcionFallos {
    return fallos.map((estado) => estado.descripcion).join(', ');
  }
}

extension FailureStateExtension on CircuitState {
  String get descripcion {
    switch (this) {
      case CircuitState.on:
        return 'Trabajando';
      case CircuitState.off:
        return 'Reposo';
      case CircuitState.presionDown:
        return 'Apagado por presión de baja';
      case CircuitState.presionHigh:
        return 'Apagado por presión de alta';
      case CircuitState.oil:
        return 'Apagado por presión de aceite';
      default:
        return 'Desconocido';
    }
  }
}
