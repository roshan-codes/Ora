import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ora/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Alarm.init();
  });

  group('Full Alarm Lifecycle Integration Tests', () {
    testWidgets('Create, verify, trigger and stop alarm workflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const OraApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // 1. Navigate to Alarms tab
      await tester.tap(find.text('Alarms'));
      await tester.pumpAndSettle();

      // Verify pre-seeded alarm is present
      expect(find.text('Wake Up'), findsOneWidget);

      // 2. Tap '+' FAB button to open Add Alarm screen
      final fabFinder = find.byIcon(Icons.add);
      expect(fabFinder, findsWidgets);
      await tester.tap(fabFinder.first);
      await tester.pumpAndSettle();

      // Verify Add Alarm screen opened
      expect(find.text('New Alarm'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // 3. Save new alarm
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // 4. Verify the alarm is now visible in the list
      expect(find.text('No alarms set'), findsNothing);
      expect(find.text('Test Ring'), findsOneWidget);

      // 5. Trigger ring simulation
      await tester.tap(find.text('Test Ring'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      // 6. Verify Alarm Ringing Screen overlay appears
      expect(find.text('Stop Alarm'), findsOneWidget);
      expect(find.textContaining('Snooze'), findsWidgets);

      // 7. Dismiss alarm via 'Stop Alarm'
      await tester.tap(find.text('Stop Alarm'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // 8. Verify returned to list screen
      expect(find.text('Stop Alarm'), findsNothing);
      expect(find.text('Alarms'), findsWidgets);
    });
  });
}
