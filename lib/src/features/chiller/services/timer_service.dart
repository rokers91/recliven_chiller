import 'dart:async';
import 'package:get/get.dart';

class TimerService extends GetxService {
  final Map<String, Timer?> _timers = {};

  void startTimer(String timerId, Duration duration, Function callback) {
    stopTimer(
        timerId); // Cancela cualquier temporizador existente con la misma clave
    _timers[timerId] = Timer.periodic(duration, (timer) => callback());
  }

  void stopTimer(String timerId) {
    if (_timers.containsKey(timerId)) {
      _timers[timerId]?.cancel();
      _timers[timerId] = null;
      _timers.remove(timerId);
    }
    // _timers[timerId]?.cancel();
    // _timers[timerId] = null;
  }

  void stopAllTimers() {
    _timers.forEach((key, timer) => timer?.cancel());
    _timers.clear();
  }

  // bool isTimerRunning(String key) {
  //   return _timers[key]?.isActive ?? false;
  // }
}
