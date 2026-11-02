import 'package:flutter_test/flutter_test.dart';
import 'package:ora/features/alarm/models/alarm_model.dart';

void main() {
  group('AlarmModel Unit Tests', () {
    test('ALM-001 / ALM-002: Same-day single alarm calculation', () {
      final now = DateTime(2026, 5, 10, 8, 30); // 8:30 AM
      const alarm = AlarmModel(
        id: 101,
        hour: 9,
        minute: 15,
        label: 'Work Standup',
      );

      final next = alarm.getNextTriggerDateTime(now: now);
      expect(next.year, 2026);
      expect(next.month, 5);
      expect(next.day, 10);
      expect(next.hour, 9);
      expect(next.minute, 15);
    });

    test('ALM-003: Passed time single alarm rolls over to next day', () {
      final now = DateTime(2026, 5, 10, 10, 30); // 10:30 AM
      const alarm = AlarmModel(
        id: 102,
        hour: 7,
        minute: 0,
        label: 'Early Morning',
      );

      final next = alarm.getNextTriggerDateTime(now: now);
      expect(next.year, 2026);
      expect(next.month, 5);
      expect(next.day, 11); // Rolls over to May 11
      expect(next.hour, 7);
      expect(next.minute, 0);
    });

    test('ALM-004: Recurring alarm picks nearest valid weekday', () {
      // 2026-05-10 is Sunday (DateTime.sunday = 7)
      final sunday = DateTime(2026, 5, 10, 12, 0);
      const weekdayAlarm = AlarmModel(
        id: 103,
        hour: 8,
        minute: 0,
        repeatDays: [1, 2, 3, 4, 5], // Mon to Fri
      );

      final next = weekdayAlarm.getNextTriggerDateTime(now: sunday);
      expect(next.weekday, DateTime.monday);
      expect(next.day, 11); // Next day Monday
      expect(next.hour, 8);
    });

    test('ALM-005: Snooze trigger calculates precise future offset', () {
      final now = DateTime(2026, 5, 10, 7, 0);
      const alarm = AlarmModel(
        id: 104,
        hour: 7,
        minute: 0,
        snoozeDurationMinutes: 10,
      );

      final snoozedTime = alarm.calculateSnoozeDateTime(from: now);
      expect(snoozedTime.minute, 10);
      expect(snoozedTime.difference(now).inMinutes, 10);
    });

    test('ALM-006: JSON serialization and deserialization round-trip', () {
      const original = AlarmModel(
        id: 202,
        hour: 14,
        minute: 45,
        label: 'Afternoon Tea',
        isEnabled: true,
        repeatDays: [1, 3, 5],
        audioPath: 'assets/audio/gentle_chime.wav',
        audioTitle: 'Gentle Chime',
        volume: 0.85,
        vibrate: true,
        gradualVolume: true,
        snoozeDurationMinutes: 15,
      );

      final json = original.toJson();
      final restored = AlarmModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.hour, original.hour);
      expect(restored.minute, original.minute);
      expect(restored.label, original.label);
      expect(restored.isEnabled, original.isEnabled);
      expect(restored.repeatDays, original.repeatDays);
      expect(restored.audioPath, original.audioPath);
      expect(restored.audioTitle, original.audioTitle);
      expect(restored.volume, original.volume);
      expect(restored.vibrate, original.vibrate);
      expect(restored.gradualVolume, original.gradualVolume);
      expect(restored.snoozeDurationMinutes, original.snoozeDurationMinutes);
    });

    test('ALM-007: Recurrence summary text formatting', () {
      const onceAlarm = AlarmModel(id: 1, hour: 6, minute: 0);
      expect(onceAlarm.repeatDaysSummary, 'Once');

      const dailyAlarm = AlarmModel(
        id: 2,
        hour: 6,
        minute: 0,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
      );
      expect(dailyAlarm.repeatDaysSummary, 'Every day');

      const weekdaysAlarm = AlarmModel(
        id: 3,
        hour: 6,
        minute: 0,
        repeatDays: [1, 2, 3, 4, 5],
      );
      expect(weekdaysAlarm.repeatDaysSummary, 'Weekdays');

      const weekendsAlarm = AlarmModel(
        id: 4,
        hour: 6,
        minute: 0,
        repeatDays: [6, 7],
      );
      expect(weekendsAlarm.repeatDaysSummary, 'Weekends');

      const customAlarm = AlarmModel(
        id: 5,
        hour: 6,
        minute: 0,
        repeatDays: [1, 4],
      );
      expect(customAlarm.repeatDaysSummary, 'Mon, Thu');
    });

    test('ALM-008: 12-hour AM/PM formatting', () {
      const morningAlarm = AlarmModel(id: 1, hour: 7, minute: 5);
      expect(morningAlarm.formattedTime, '7:05');
      expect(morningAlarm.period, 'am');

      const midnightAlarm = AlarmModel(id: 2, hour: 0, minute: 0);
      expect(midnightAlarm.formattedTime, '12:00');
      expect(midnightAlarm.period, 'am');

      const noonAlarm = AlarmModel(id: 3, hour: 12, minute: 30);
      expect(noonAlarm.formattedTime, '12:30');
      expect(noonAlarm.period, 'pm');

      const nightAlarm = AlarmModel(id: 4, hour: 23, minute: 45);
      expect(nightAlarm.formattedTime, '11:45');
      expect(nightAlarm.period, 'pm');
    });
  });
}
