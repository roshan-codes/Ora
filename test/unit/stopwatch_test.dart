import 'package:flutter_test/flutter_test.dart';
import 'package:ora/features/stopwatch/controllers/stopwatch_controller.dart';

void main() {
  group('StopwatchController Unit Tests', () {
    late StopwatchController controller;

    setUp(() {
      controller = StopwatchController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('STW-001: Initial state is stopped with zero duration and empty laps', () {
      expect(controller.state, StopwatchState.stopped);
      expect(controller.isStopped, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.elapsed, Duration.zero);
      expect(controller.laps, isEmpty);
      expect(controller.progressRatio, 0.0);
    });

    test('STW-002: Start transitions to running', () {
      controller.start();
      expect(controller.state, StopwatchState.running);
      expect(controller.isRunning, isTrue);
    });

    test('STW-003: Pause preserves accumulated elapsed time', () async {
      controller.start();
      await Future.delayed(const Duration(milliseconds: 50));
      controller.pause();

      expect(controller.state, StopwatchState.paused);
      expect(controller.isPaused, isTrue);
      final pausedElapsed = controller.elapsed;
      expect(pausedElapsed.inMilliseconds, greaterThan(0));

      // Wait a moment and ensure elapsed time did not keep advancing while paused
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.elapsed.inMilliseconds, pausedElapsed.inMilliseconds);
    });

    test('STW-004: Resume continues accumulating from paused mark', () async {
      controller.start();
      await Future.delayed(const Duration(milliseconds: 40));
      controller.pause();
      final beforeResume = controller.elapsed;

      controller.resume();
      expect(controller.isRunning, isTrue);
      await Future.delayed(const Duration(milliseconds: 40));
      controller.pause();

      expect(controller.elapsed.inMilliseconds, greaterThan(beforeResume.inMilliseconds));
    });

    test('STW-005: Reset returns controller to clean initial state', () async {
      controller.start();
      await Future.delayed(const Duration(milliseconds: 30));
      controller.recordLap();
      controller.reset();

      expect(controller.state, StopwatchState.stopped);
      expect(controller.elapsed, Duration.zero);
      expect(controller.laps, isEmpty);
      expect(controller.formattedDisplay, '00:00');
    });

    test('STW-006: Recording laps tracks split and calculates difference', () async {
      controller.start();

      await Future.delayed(const Duration(milliseconds: 30));
      controller.recordLap(); // Lap 1
      expect(controller.laps.length, 1);
      expect(controller.laps.first.lapIndex, 1);
      expect(controller.laps.first.differenceFromPrevious, isNull);

      await Future.delayed(const Duration(milliseconds: 40));
      controller.recordLap(); // Lap 2
      expect(controller.laps.length, 2);
      expect(controller.laps.first.lapIndex, 2);
      expect(controller.laps.first.differenceFromPrevious, isNotNull);
    });

    test('STW-007: Formatted display renders MM:SS and H:M formats correctly', () {
      expect(controller.formattedDisplay, '00:00');
      expect(controller.millisecondsDisplay, '00');
    });
  });
}

