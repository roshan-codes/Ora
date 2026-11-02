import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/alarm_scheduler_service.dart';
import '../../../data/local_storage/preferences_service.dart';

class AlarmController extends ChangeNotifier {
  final PreferencesService _prefsService;
  final AlarmSchedulerService _schedulerService;

  List<AlarmModel> _alarms = [];
  AlarmModel? _currentlyRingingAlarm;
  StreamSubscription? _ringSubscription;
  bool _isLoading = true;
  bool _customSet = false;

  AlarmController({
    PreferencesService? prefsService,
    AlarmSchedulerService? schedulerService,
    List<AlarmModel>? initialAlarms,
    bool autoInit = true,
  })  : _prefsService = prefsService ?? PreferencesService.instance,
        _schedulerService = schedulerService ?? AlarmSchedulerService.instance {
    if (initialAlarms != null) {
      _customSet = true;
      _alarms = List.from(initialAlarms);
      _isLoading = false;
    } else if (autoInit) {
      init();
    }
  }

  List<AlarmModel> get alarms => List.unmodifiable(_alarms);
  AlarmModel? get currentlyRingingAlarm => _currentlyRingingAlarm;
  bool get isLoading => _isLoading;

  @visibleForTesting
  void setAlarmsForTesting(List<AlarmModel> testAlarms) {
    _customSet = true;
    _alarms = List.from(testAlarms);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> init() async {
    if (_customSet) return;
    await _loadAlarms();
    _listenToRingingStream();
  }

  void _listenToRingingStream() {
    _ringSubscription?.cancel();
    _ringSubscription = _schedulerService.ringingStream.listen((alarmSettings) {
      debugPrint('[AlarmController] Received ringing event for ID: ${alarmSettings.id}');
      final matched = _alarms.firstWhere(
        (a) => a.id == alarmSettings.id,
        orElse: () => AlarmModel(
          id: alarmSettings.id,
          hour: alarmSettings.dateTime.hour,
          minute: alarmSettings.dateTime.minute,
          label: alarmSettings.notificationSettings.title,
          audioPath: alarmSettings.assetAudioPath,
        ),
      );

      _currentlyRingingAlarm = matched;
      notifyListeners();
    });
  }

  Future<void> _loadAlarms() async {
    if (_customSet) return;
    _isLoading = true;
    notifyListeners();

    try {
      final rawList = await _prefsService.getAlarmsRaw();
      if (rawList.isEmpty) {
        // Pre-seed an initial alarm (7:00 AM) matching the reference Sleep Timer UI
        const defaultAlarm = AlarmModel(
          id: 1,
          hour: 7,
          minute: 0,
          label: 'Wake Up',
          isEnabled: true,
          repeatDays: [2], // Tuesday selected in reference design
          vibrate: true,
        );
        _alarms = [defaultAlarm];
        await _saveAlarmsToStorage();
        await _schedulerService.scheduleAlarm(defaultAlarm);
      } else {
        _alarms = rawList.map((m) => AlarmModel.fromJson(m)).toList();
        // Reschedule/sync with OS
        await _schedulerService.syncAllAlarms(_alarms);
      }
    } catch (e) {
      debugPrint('[AlarmController] Error loading alarms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAlarmsToStorage() async {
    final rawList = _alarms.map((a) => a.toJson()).toList();
    await _prefsService.saveAlarmsRaw(rawList);
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    _alarms.add(alarm);
    notifyListeners();

    await _saveAlarmsToStorage();
    if (alarm.isEnabled) {
      await _schedulerService.scheduleAlarm(alarm);
    }
  }

  Future<void> updateAlarm(AlarmModel updated) async {
    final index = _alarms.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _alarms[index] = updated;
      notifyListeners();

      await _saveAlarmsToStorage();
      if (updated.isEnabled) {
        await _schedulerService.scheduleAlarm(updated);
      } else {
        await _schedulerService.cancelAlarm(updated.id);
      }
    }
  }

  Future<void> toggleAlarm(int id, bool isEnabled) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final current = _alarms[index];
      final updated = current.copyWith(isEnabled: isEnabled);
      _alarms[index] = updated;
      notifyListeners();

      await _saveAlarmsToStorage();
      if (isEnabled) {
        await _schedulerService.scheduleAlarm(updated);
      } else {
        await _schedulerService.cancelAlarm(id);
      }
    }
  }

  Future<void> deleteAlarm(int id) async {
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();

    await _saveAlarmsToStorage();
    await _schedulerService.cancelAlarm(id);
  }

  Future<void> stopRinging() async {
    final ringing = _currentlyRingingAlarm;
    if (ringing == null) return;

    _currentlyRingingAlarm = null;
    notifyListeners();

    await _schedulerService.dismissRingingAlarm(
      alarm: ringing,
      onAlarmUpdated: (updated) async {
        final idx = _alarms.indexWhere((a) => a.id == updated.id);
        if (idx != -1) {
          _alarms[idx] = updated;
          await _saveAlarmsToStorage();
          notifyListeners();
        }
      },
    );
  }

  Future<void> snoozeRinging({int? overrideMinutes}) async {
    final ringing = _currentlyRingingAlarm;
    if (ringing == null) return;

    final minutes = overrideMinutes ?? ringing.snoozeDurationMinutes;
    _currentlyRingingAlarm = null;
    notifyListeners();

    await _schedulerService.snoozeAlarm(ringing, minutes);
  }

  /// Manually trigger an immediate test ringing for testing
  void simulateRing(AlarmModel alarm) {
    _currentlyRingingAlarm = alarm;
    notifyListeners();
  }

  @override
  void dispose() {
    _ringSubscription?.cancel();
    super.dispose();
  }
}
