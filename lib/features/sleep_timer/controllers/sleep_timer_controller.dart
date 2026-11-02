import 'dart:async';
import 'package:flutter/material.dart';
import '../../alarm/controllers/alarm_controller.dart';
import '../../alarm/models/alarm_model.dart';
import '../../../data/local_storage/preferences_service.dart';
import '../../../shared/services/sound_preview_service.dart';

class SleepTimerController extends ChangeNotifier {
  final PreferencesService _prefsService;
  final AlarmController? _alarmController;

  int _alarmHour = 7;
  int _alarmMinute = 0;
  List<int> _selectedDays = [2]; // Tuesday highlighted in design
  bool _sunriseAlarm = false;
  bool _vibrate = true;
  String _soundTitle = 'Default (miui_week_ringtone.ogg)';

  // Countdown timer state
  Duration _timerDuration = const Duration(minutes: 45);
  Duration _remaining = const Duration(minutes: 45);
  DateTime? _timerEndTime;
  Timer? _countdownTicker;
  bool _isTimerActive = false;
  bool _isTimerPaused = false;

  SleepTimerController({
    PreferencesService? prefsService,
    AlarmController? alarmController,
  })  : _prefsService = prefsService ?? PreferencesService.instance,
        _alarmController = alarmController {
    _loadSettings();
  }

  int get alarmHour => _alarmHour;
  int get alarmMinute => _alarmMinute;
  List<int> get selectedDays => List.unmodifiable(_selectedDays);
  bool get sunriseAlarm => _sunriseAlarm;
  bool get vibrate => _vibrate;
  String get soundTitle => _soundTitle;

  bool get isTimerActive => _isTimerActive;
  bool get isTimerPaused => _isTimerPaused;
  Duration get remainingTime => _remaining;
  Duration get timerDuration => _timerDuration;

  String get formattedAlarmTime {
    final displayHour = _alarmHour % 12 == 0 ? 12 : _alarmHour % 12;
    return '$displayHour:${_alarmMinute.toString().padLeft(2, '0')}';
  }

  String get alarmPeriod => _alarmHour >= 12 ? 'pm' : 'am';

  Future<void> _loadSettings() async {
    final raw = await _prefsService.getSleepTimerRaw();
    if (raw != null) {
      _alarmHour = (raw['hour'] as num?)?.toInt() ?? 7;
      _alarmMinute = (raw['minute'] as num?)?.toInt() ?? 0;
      _selectedDays = (raw['days'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [2];
      _sunriseAlarm = (raw['sunrise'] as bool?) ?? false;
      _vibrate = (raw['vibrate'] as bool?) ?? true;
      _soundTitle = (raw['sound'] as String?) ?? 'Default (miui_week_ringtone.ogg)';
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    await _prefsService.saveSleepTimerRaw({
      'hour': _alarmHour,
      'minute': _alarmMinute,
      'days': _selectedDays,
      'sunrise': _sunriseAlarm,
      'vibrate': _vibrate,
      'sound': _soundTitle,
    });
  }

  void incrementAlarmTime() {
    _alarmMinute += 15;
    if (_alarmMinute >= 60) {
      _alarmMinute = 0;
      _alarmHour = (_alarmHour + 1) % 24;
    }
    notifyListeners();
    _saveSettings();
  }

  void decrementAlarmTime() {
    _alarmMinute -= 15;
    if (_alarmMinute < 0) {
      _alarmMinute = 45;
      _alarmHour = (_alarmHour - 1 + 24) % 24;
    }
    notifyListeners();
    _saveSettings();
  }

  void toggleDay(int dayIndex) {
    if (_selectedDays.contains(dayIndex)) {
      _selectedDays.remove(dayIndex);
    } else {
      _selectedDays.add(dayIndex);
    }
    notifyListeners();
    _saveSettings();
  }

  void toggleSunriseAlarm() {
    _sunriseAlarm = !_sunriseAlarm;
    notifyListeners();
    _saveSettings();
  }

  void toggleVibrate() {
    _vibrate = !_vibrate;
    notifyListeners();
    _saveSettings();
  }

  // --- Countdown Sleep Timer ---
  void startTimer({Duration? duration}) {
    final d = duration ?? _timerDuration;
    _timerDuration = d;
    _remaining = d;
    _timerEndTime = DateTime.now().add(d);
    _isTimerActive = true;
    _isTimerPaused = false;

    _startCountdown();
    notifyListeners();
  }

  void pauseTimer() {
    if (!_isTimerActive || _isTimerPaused) return;
    _countdownTicker?.cancel();
    _isTimerPaused = true;
    if (_timerEndTime != null) {
      _remaining = _timerEndTime!.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    }
    notifyListeners();
  }

  void resumeTimer() {
    if (!_isTimerActive || !_isTimerPaused) return;
    _timerEndTime = DateTime.now().add(_remaining);
    _isTimerPaused = false;
    _startCountdown();
    notifyListeners();
  }

  void cancelTimer() {
    _countdownTicker?.cancel();
    _isTimerActive = false;
    _isTimerPaused = false;
    _remaining = _timerDuration;
    notifyListeners();
  }

  void _startCountdown() {
    _countdownTicker?.cancel();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timerEndTime == null) return;
      final diff = _timerEndTime!.difference(DateTime.now());
      if (diff <= Duration.zero) {
        _remaining = Duration.zero;
        _countdownTicker?.cancel();
        _isTimerActive = false;
        _isTimerPaused = false;
        notifyListeners();
        _onTimerFinished();
      } else {
        _remaining = diff;
        notifyListeners();
      }
    });
  }

  void _onTimerFinished() {
    // Play gentle chime on timer completion
    SoundPreviewService.instance.playPreview('assets/audio/gentle_chime.wav');
  }

  /// Create and schedule the regular wake-up alarm in AlarmController
  Future<void> saveAndScheduleWakeUpAlarm() async {
    await _saveSettings();

    if (_alarmController != null) {
      final alarm = AlarmModel(
        id: 999, // Reserved ID for Sleep Timer wake up alarm
        hour: _alarmHour,
        minute: _alarmMinute,
        label: 'Wake Up',
        isEnabled: true,
        repeatDays: _selectedDays,
        vibrate: _vibrate,
        sunriseAlarm: _sunriseAlarm,
      );

      // Check if already exists, else add
      final existing = _alarmController.alarms.any((a) => a.id == 999);
      if (existing) {
        await _alarmController.updateAlarm(alarm);
      } else {
        await _alarmController.addAlarm(alarm);
      }
    }
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    super.dispose();
  }
}

