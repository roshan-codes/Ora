import 'package:flutter/material.dart';
import '../models/bedtime_model.dart';
import '../../alarm/controllers/alarm_controller.dart';
import '../../alarm/models/alarm_model.dart';
import '../../../data/local_storage/preferences_service.dart';

class BedtimeController extends ChangeNotifier {
  final PreferencesService _prefsService;
  final AlarmController? _alarmController;

  BedtimeModel _model = const BedtimeModel();
  bool _isLoading = true;

  BedtimeController({
    PreferencesService? prefsService,
    AlarmController? alarmController,
  })  : _prefsService = prefsService ?? PreferencesService.instance,
        _alarmController = alarmController {
    _load();
  }

  BedtimeModel get model => _model;
  bool get isLoading => _isLoading;

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final raw = await _prefsService.getBedtimeRaw();
      if (raw != null) {
        _model = BedtimeModel.fromJson(raw);
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await _prefsService.saveBedtimeRaw(_model.toJson());
    await _syncWithAlarmController();
  }

  Future<void> toggleEnabled(bool enabled) async {
    _model = _model.copyWith(isEnabled: enabled);
    notifyListeners();
    await _save();
  }

  Future<void> updateBedtime(int hour, int minute) async {
    _model = _model.copyWith(bedtimeHour: hour, bedtimeMinute: minute);
    notifyListeners();
    await _save();
  }

  Future<void> updateWakeTime(int hour, int minute) async {
    _model = _model.copyWith(wakeHour: hour, wakeMinute: minute);
    notifyListeners();
    await _save();
  }

  Future<void> toggleDay(int isoDay) async {
    final list = List<int>.from(_model.repeatDays);
    if (list.contains(isoDay)) {
      list.remove(isoDay);
    } else {
      list.add(isoDay);
    }
    _model = _model.copyWith(repeatDays: list);
    notifyListeners();
    await _save();
  }

  Future<void> _syncWithAlarmController() async {
    if (_alarmController == null) return;

    const bedtimeAlarmId = 888;
    if (_model.isEnabled) {
      final alarm = AlarmModel(
        id: bedtimeAlarmId,
        hour: _model.wakeHour,
        minute: _model.wakeMinute,
        label: 'Bedtime Wake Up',
        isEnabled: true,
        repeatDays: _model.repeatDays,
        vibrate: true,
      );

      final exists = _alarmController.alarms.any((a) => a.id == bedtimeAlarmId);
      if (exists) {
        await _alarmController.updateAlarm(alarm);
      } else {
        await _alarmController.addAlarm(alarm);
      }
    } else {
      await _alarmController.toggleAlarm(bedtimeAlarmId, false);
    }
  }
}

