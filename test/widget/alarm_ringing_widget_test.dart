import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ora/features/alarm/models/alarm_model.dart';
import 'package:ora/features/alarm/screens/alarm_ringing_screen.dart';

void main() {
  group('AlarmRingingScreen Widget Tests', () {
    testWidgets('Renders ringing screen with time, label, Stop and Snooze',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool stopCalled = false;
      int? snoozedMinutes;

      const testAlarm = AlarmModel(
        id: 999,
        hour: 7,
        minute: 15,
        label: 'Sunrise Wakeup',
        snoozeDurationMinutes: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AlarmRingingScreen(
            alarm: testAlarm,
            onStop: () {
              stopCalled = true;
            },
            onSnooze: (mins) {
              snoozedMinutes = mins;
            },
          ),
        ),
      );
      await tester.pump();

      // Check label and buttons
      expect(find.text('Sunrise Wakeup'), findsOneWidget);
      expect(find.text('Stop Alarm'), findsOneWidget);
      expect(find.text('Snooze (10m)'), findsOneWidget);
      expect(find.text('+5m'), findsOneWidget);
      expect(find.text('+10m'), findsOneWidget);
      expect(find.text('+15m'), findsOneWidget);
      expect(find.text('+20m'), findsOneWidget);

      // Tap Snooze
      await tester.tap(find.text('Snooze (10m)'));
      expect(snoozedMinutes, 10);

      // Tap Stop
      await tester.tap(find.text('Stop Alarm'));
      expect(stopCalled, isTrue);

      // Tap quick snooze pill (+15m)
      await tester.tap(find.text('+15m'));
      expect(snoozedMinutes, 15);
    });
  });
}

