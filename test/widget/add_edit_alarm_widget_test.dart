import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ora/features/alarm/models/alarm_model.dart';
import 'package:ora/features/alarm/screens/add_edit_alarm_screen.dart';

void main() {
  group('AddEditAlarmScreen Widget Tests', () {
    testWidgets('Renders New Alarm screen with default values and Save button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AlarmModel? savedAlarm;

      await tester.pumpWidget(
        MaterialApp(
          home: AddEditAlarmScreen(
            onSave: (alarm) {
              savedAlarm = alarm;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Alarm'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Alarm Sound'), findsOneWidget);
      expect(find.text('Classic Alarm'), findsOneWidget);

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedAlarm, isNotNull);
      expect(savedAlarm!.label, 'Alarm');
    });

    testWidgets('Populates existing alarm values when editing',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const existing = AlarmModel(
        id: 777,
        hour: 9,
        minute: 30,
        label: 'Client Call',
        isEnabled: true,
        repeatDays: [1, 2, 3],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AddEditAlarmScreen(
            existingAlarm: existing,
            onSave: (_) {},
            onDelete: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Alarm'), findsOneWidget);
      expect(find.text('Client Call'), findsOneWidget);
      expect(find.text('Delete Alarm'), findsOneWidget);
    });
  });
}
