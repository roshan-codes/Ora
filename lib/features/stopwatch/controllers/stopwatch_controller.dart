import 'dart:async';
import 'package:flutter/material.dart';
import '../models/lap_model.dart';

enum StopwatchState { stopped, running, paused }

class StopwatchController extends ChangeNotifier {
  StopwatchState _state = StopwatchState.stopped;
  Duration _accumulated = Duration.zero;
  DateTime? _startedAt;
  Timer? _ticker;

  final List<LapModel> _laps = [];
  Duration _lastLapTotal = Duration.zero;

  StopwatchState get state => _state;
  bool get isRunning => _state == StopwatchState.running;
  bool get isPaused => _state == StopwatchState.paused;
  bool get isStopped => _state == StopwatchState.stopped;

  List<LapModel> get laps => List.unmodifiable(_laps);

  Duration get elapsed {
    if (_state == StopwatchState.running && _startedAt != null) {
      return _accumulated + DateTime.now().difference(_startedAt!);
    }
    return _accumulated;
  }

  /// Formatted readout: e.g. "01:15" or "1h 15m"
  String get formattedDisplay {
    final d = elapsed;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Milliseconds string (e.g. "45")
  String get millisecondsDisplay {
    final ms = (elapsed.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return ms;
  }

  /// Wavy dial completion ratio (cycles every 60 seconds or custom cycle)
  double get progressRatio {
    final ms = elapsed.inMilliseconds;
    if (ms == 0) return 0.0;
    return (ms % 60000) / 60000.0;
  }

  void start() {
    if (_state == StopwatchState.running) return;

    _state = StopwatchState.running;
    _startedAt = DateTime.now();
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_state != StopwatchState.running) return;

    _accumulated += DateTime.now().difference(_startedAt!);
    _startedAt = null;
    _state = StopwatchState.paused;
    _stopTicker();
    notifyListeners();
  }

  void resume() {
    if (_state != StopwatchState.paused) return;

    _state = StopwatchState.running;
    _startedAt = DateTime.now();
    _startTicker();
    notifyListeners();
  }

  void reset() {
    _stopTicker();
    _state = StopwatchState.stopped;
    _accumulated = Duration.zero;
    _startedAt = null;
    _lastLapTotal = Duration.zero;
    _laps.clear();
    notifyListeners();
  }

  void recordLap() {
    if (_state != StopwatchState.running) return;

    final currentTotal = elapsed;
    final lapDuration = currentTotal - _lastLapTotal;

    Duration? diff;
    if (_laps.isNotEmpty) {
      diff = lapDuration - _laps.first.lapDuration;
    }

    final lap = LapModel(
      lapIndex: _laps.length + 1,
      lapDuration: lapDuration,
      totalElapsed: currentTotal,
      differenceFromPrevious: diff,
    );

    // Insert at front so latest lap is on top
    _laps.insert(0, lap);
    _lastLapTotal = currentTotal;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}

