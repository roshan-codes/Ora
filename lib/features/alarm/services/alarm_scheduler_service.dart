import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import '../models/alarm_model.dart';
import '../../../core/permissions/permission_service.dart';

class AlarmSchedulerService {
  static final AlarmSchedulerService instance = AlarmSchedulerService._();
  AlarmSchedulerService._();

  bool _isInitialized = false;

  /// Stream of alarms that are currently ringing
  Stream<AlarmSettings> get ringingStream => Alarm.ringStream.stream;

  /// Initialize the native alarm system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Alarm.init();
      _isInitialized = true;
      debugPrint('[AlarmScheduler] Native Alarm plugin initialized');
    } catch (e) {
      debugPrint('[AlarmScheduler] Error initializing Alarm plugin: $e');
    }

    // Request necessary permissions asynchronously
    await PermissionService.instance.requestAllPermissions();
  }

  /// Schedule an alarm in the operating system
  Future<bool> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) {
      await cancelAlarm(alarm.id);
      return false;
    }

    final triggerTime = alarm.getNextTriggerDateTime();
    debugPrint(
      '[AlarmScheduler] Scheduling alarm #${alarm.id} (${alarm.label}) for $triggerTime',
    );

    final alarmSettings = AlarmSettings(
      id: alarm.id,
      dateTime: triggerTime,
      assetAudioPath: alarm.audioPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      volume: alarm.volume,
      fadeDuration: alarm.gradualVolume ? 15.0 : 0.0,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      notificationSettings: NotificationSettings(
        title: alarm.label.isEmpty ? 'Alarm' : alarm.label,
        body: 'Ringing for ${alarm.formattedTime}${alarm.period}',
        stopButton: 'Stop',
        icon: 'notification_icon',
      ),
    );

    try {
      final success = await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('[AlarmScheduler] Alarm #${alarm.id} scheduled: $success');
      return success;
    } catch (e) {
      debugPrint('[AlarmScheduler] Failed to schedule alarm #${alarm.id}: $e');
      return false;
    }
  }

  /// Cancel an alarm from the operating system
  Future<bool> cancelAlarm(int id) async {
    try {
      final stopped = await Alarm.stop(id);
      debugPrint('[AlarmScheduler] Alarm #$id stopped/cancelled: $stopped');
      return stopped;
    } catch (e) {
      debugPrint('[AlarmScheduler] Error stopping alarm #$id: $e');
      return false;
    }
  }

  /// Snooze an alarm by scheduled duration
  Future<bool> snoozeAlarm(AlarmModel alarm, int snoozeMinutes) async {
    // 1. Stop current ringing sound and vibration
    await cancelAlarm(alarm.id);

    // 2. Schedule snooze for now + snoozeMinutes
    final snoozeTrigger = DateTime.now().add(Duration(minutes: snoozeMinutes));
    debugPrint(
      '[AlarmScheduler] Snoozing alarm #${alarm.id} for $snoozeMinutes min until $snoozeTrigger',
    );

    final snoozeSettings = AlarmSettings(
      id: alarm.id,
      dateTime: snoozeTrigger,
      assetAudioPath: alarm.audioPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      volume: alarm.volume,
      fadeDuration: alarm.gradualVolume ? 10.0 : 0.0,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      notificationSettings: NotificationSettings(
        title: '${alarm.label} (Snoozed)',
        body: 'Snoozed alarm ringing now',
        stopButton: 'Stop',
        icon: 'notification_icon',
      ),
    );

    try {
      return await Alarm.set(alarmSettings: snoozeSettings);
    } catch (e) {
      debugPrint('[AlarmScheduler] Error setting snooze: $e');
      return false;
    }
  }

  /// Stop ringing and reschedule if repeating
  Future<void> dismissRingingAlarm({
    required AlarmModel alarm,
    required Future<void> Function(AlarmModel updated) onAlarmUpdated,
  }) async {
    await cancelAlarm(alarm.id);

    if (alarm.repeatDays.isNotEmpty) {
      // Recurring alarm: schedule next occurrence
      final updated = alarm.copyWith(isEnabled: true);
      await onAlarmUpdated(updated);
      await scheduleAlarm(updated);
    } else {
      // One-time alarm: mark disabled in storage
      final updated = alarm.copyWith(isEnabled: false);
      await onAlarmUpdated(updated);
    }
  }

  /// Verify and reschedule all enabled alarms (e.g. after reboot or app start)
  Future<void> syncAllAlarms(List<AlarmModel> alarms) async {
    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        await scheduleAlarm(alarm);
      } else {
        await cancelAlarm(alarm.id);
      }
    }
  }
}
