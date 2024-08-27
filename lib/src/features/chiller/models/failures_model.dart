//modelo relacionado con los datos de la tabla de fallos

class EventsInfoModel {
  final String dateEvent;
  final String timeEvent;
  final String typeEvento;
  final String circuitEvent;
  final String accumulatedTime;

  const EventsInfoModel({
    required this.dateEvent,
    required this.timeEvent,
    required this.typeEvento,
    required this.circuitEvent,
    required this.accumulatedTime,
  });
}
