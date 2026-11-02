import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ora/main.dart';
import 'package:ora/features/alarm/models/alarm_model.dart';
import 'package:ora/features/world_clock/models/world_clock_city.dart';
import 'package:ora/features/stopwatch/controllers/stopwatch_controller.dart';
import 'package:ora/features/bedtime/models/bedtime_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Alarm.init();
  });

  group('Ora Production App & Architecture Tests', () {
    testWidgets('App renders clean navigation shell with all feature tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const OraApp());
      // Pump initial initialization timers
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Bottom navigation bar items and initial screen
      expect(find.text('Alarms'), findsWidgets);
      expect(find.text('Clock'), findsWidgets);
      expect(find.text('Timer'), findsWidgets);
      expect(find.text('Bedtimes'), findsWidgets);

      // Verify World Clock displays Locations and hero clock
      expect(find.text('Locations'), findsOneWidget);
      expect(find.text('World Clock'), findsOneWidget);

      // Navigate to Alarms tab using bottom nav bar
      await tester.tap(find.text('Alarms'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Alarms'), findsWidgets);

      // Navigate to Timer tab (StopWatch) using bottom nav bar
      await tester.tap(find.text('Timer'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('StopWatch'), findsWidgets);

      // Navigate to Bedtimes tab (Sleep Timer) using bottom nav bar
      await tester.tap(find.text('Bedtimes'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Sleep Timer'), findsOneWidget);
      expect(find.text('Set a regular wake-up alarm'), findsOneWidget);

      // Settle any remaining async timers from plugin initialization
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    test('AlarmModel calculations for single and recurring triggers', () {
      final now = DateTime(2026, 4, 29, 6, 0); // Wednesday 6:00 AM

      // Same-day future alarm
      const sameDayAlarm = AlarmModel(
        id: 1,
        hour: 7,
        minute: 0,
        label: 'Morning',
      );
      final trigger1 = sameDayAlarm.getNextTriggerDateTime(now: now);
      expect(trigger1.year, 2026);
      expect(trigger1.month, 4);
      expect(trigger1.day, 29);
      expect(trigger1.hour, 7);
      expect(trigger1.minute, 0);

      // Past time one-time alarm (must schedule for tomorrow)
      const pastAlarm = AlarmModel(
        id: 2,
        hour: 5,
        minute: 0,
        label: 'Early',
      );
      final trigger2 = pastAlarm.getNextTriggerDateTime(now: now);
      expect(trigger2.day, 30); // Next day

      // Recurring alarm for Friday (weekday 5)
      const recurringFriday = AlarmModel(
        id: 3,
        hour: 8,
        minute: 0,
        repeatDays: [5], // Friday
      );
      final trigger3 = recurringFriday.getNextTriggerDateTime(now: now);
      expect(trigger3.weekday, 5); // Friday
      expect(trigger3.isAfter(now), isTrue);
    });

    test('StopwatchController maintains timestamp accuracy across operations',
        () async {
      final controller = StopwatchController();
      expect(controller.isStopped, isTrue);
      expect(controller.elapsed, Duration.zero);

      controller.start();
      expect(controller.isRunning, isTrue);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.elapsed.inMilliseconds, greaterThan(0));

      controller.recordLap();
      expect(controller.laps.length, 1);

      controller.pause();
      expect(controller.isPaused, isTrue);

      final elapsedAtPause = controller.elapsed;
      await Future.delayed(const Duration(milliseconds: 30));
      // Elapsed must remain frozen while paused
      expect(controller.elapsed, elapsedAtPause);

      controller.resume();
      expect(controller.isRunning, isTrue);

      controller.reset();
      expect(controller.isStopped, isTrue);
      expect(controller.elapsed, Duration.zero);
      expect(controller.laps, isEmpty);

      controller.dispose();
    });

    test('WorldClockCity relative offset calculation', () {
      const city = WorldClockCity(
        id: 'tokyo',
        cityName: 'Tokyo',
        countryName: 'Japan',
        timezoneId: 'Asia/Tokyo',
      );

      expect(city.cityName, 'Tokyo');
      expect(city.period, anyOf('am', 'pm'));
      expect(city.relativeOffsetString, isNotEmpty);
    });

    test('BedtimeModel sleep duration computation', () {
      const bedtime = BedtimeModel(
        bedtimeHour: 23, // 11 PM
        bedtimeMinute: 0,
        wakeHour: 7, // 7 AM
        wakeMinute: 0,
      );

      expect(bedtime.sleepDuration.inHours, 8);
      expect(bedtime.formattedSleepDuration, '8 hrs');
      expect(bedtime.remainingUntilBedtime, startsWith('in '));
    });
  });
}
