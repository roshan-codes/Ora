import 'package:flutter_test/flutter_test.dart';
import 'package:ora/features/bedtime/models/bedtime_model.dart';

void main() {
  group('BedtimeModel Unit Tests', () {
    test('BDT-001: Overnight sleep duration calculation spanning midnight', () {
      // 11:00 PM (23:00) to 7:00 AM
      const bedtime = BedtimeModel(
        bedtimeHour: 23,
        bedtimeMinute: 0,
        wakeHour: 7,
        wakeMinute: 0,
      );

      final duration = bedtime.sleepDuration;
      expect(duration.inHours, 8);
      expect(duration.inMinutes, 480);
      expect(bedtime.formattedSleepDuration, '8 hrs');
    });

    test('BDT-002: Same-day sleep duration calculation', () {
      // 1:00 AM (01:00) to 9:30 AM
      const bedtime = BedtimeModel(
        bedtimeHour: 1,
        bedtimeMinute: 0,
        wakeHour: 9,
        wakeMinute: 30,
      );

      final duration = bedtime.sleepDuration;
      expect(duration.inHours, 8);
      expect(duration.inMinutes, 510);
      expect(bedtime.formattedSleepDuration, '8 hrs 30 mins');
    });

    test('BDT-003: Formatted 12-hour bedtime and wake displays', () {
      const bedtime = BedtimeModel(
        bedtimeHour: 22,
        bedtimeMinute: 45,
        wakeHour: 6,
        wakeMinute: 15,
      );

      expect(bedtime.formattedBedtime, '10:45pm');
      expect(bedtime.formattedWakeTime, '6:15am');
    });

    test('BDT-004: JSON serialization and deserialization', () {
      const original = BedtimeModel(
        bedtimeHour: 23,
        bedtimeMinute: 30,
        wakeHour: 7,
        wakeMinute: 15,
        isEnabled: false,
        repeatDays: [1, 2, 3, 4, 5, 6],
      );

      final json = original.toJson();
      final restored = BedtimeModel.fromJson(json);

      expect(restored.bedtimeHour, 23);
      expect(restored.bedtimeMinute, 30);
      expect(restored.wakeHour, 7);
      expect(restored.wakeMinute, 15);
      expect(restored.isEnabled, isFalse);
      expect(restored.repeatDays, [1, 2, 3, 4, 5, 6]);
    });
  });
}
