import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ora/features/qa/screens/qa_dashboard_screen.dart';
import 'package:ora/features/qa/services/qa_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Alarm.init();
  });

  group('QADashboardScreen Widget Tests', () {
    testWidgets('Renders dashboard header, metrics, and automated runner button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final engine = QAEngine.instance;

      await tester.pumpWidget(
        MaterialApp(
          home: QADashboardScreen(engine: engine),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('QA Test Dashboard'), findsOneWidget);
      expect(find.text('Run Automated Suite'), findsOneWidget);
      expect(find.text('Debug Console'), findsOneWidget);
      expect(find.textContaining('Passed:'), findsOneWidget);
      expect(find.textContaining('Failed:'), findsOneWidget);
      expect(find.textContaining('Blocked:'), findsOneWidget);
      expect(find.textContaining('Pending:'), findsOneWidget);

      // Verify at least one test case row is visible in list
      expect(find.textContaining('ALM-001'), findsOneWidget);
    });

    testWidgets('Tapping a status filter chip updates test case filtering',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final engine = QAEngine.instance;

      await tester.pumpWidget(
        MaterialApp(
          home: QADashboardScreen(engine: engine),
        ),
      );
      await tester.pumpAndSettle();

      // Find the "Passed" chip
      final passedChip = find.textContaining('Passed (');
      expect(passedChip, findsOneWidget);

      await tester.tap(passedChip);
      await tester.pumpAndSettle();

      // Filter is applied without errors
      expect(find.text('QA Test Dashboard'), findsOneWidget);
    });
  });
}
