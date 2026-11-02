import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ora/features/alarm/controllers/alarm_controller.dart';
import 'package:ora/features/alarm/models/alarm_model.dart';
import 'package:ora/features/alarm/screens/alarms_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Alarm.init();
  });

  group('AlarmsListScreen Widget Tests', () {
    testWidgets('Renders empty state when no alarms are scheduled',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AlarmController(initialAlarms: const []);

      await tester.pumpWidget(
        MaterialApp(
          home: AlarmsListScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alarms'), findsOneWidget);
      expect(find.text('No Alarms Set'), findsOneWidget);
      expect(find.text('Tap the + button below to create your first alarm'), findsOneWidget);
    });

    testWidgets('Displays alarm card with time, period, and label',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AlarmController(
        initialAlarms: const [
          AlarmModel(
            id: 501,
            hour: 6,
            minute: 45,
            label: 'Gym Workout',
            isEnabled: true,
            repeatDays: [1, 2, 3, 4, 5],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AlarmsListScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gym Workout'), findsOneWidget);
      expect(find.text('6:45'), findsOneWidget);
      expect(find.text('am'), findsOneWidget);
      expect(find.textContaining('Weekdays'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('Toggling switch updates alarm enabled state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AlarmController(
        initialAlarms: const [
          AlarmModel(
            id: 502,
            hour: 8,
            minute: 0,
            label: 'Daily Sync',
            isEnabled: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AlarmsListScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      expect(controller.alarms.first.isEnabled, isTrue);

      // Tap toggle to disable
      await tester.tap(switchFinder);
      await tester.pump();

      expect(controller.alarms.first.isEnabled, isFalse);
    });
  });
}
