import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/phone_frame.dart';
import '../features/world_clock/screens/world_clock_screen.dart';
import '../features/world_clock/controllers/world_clock_controller.dart';
import '../features/stopwatch/screens/stopwatch_screen.dart';
import '../features/stopwatch/controllers/stopwatch_controller.dart';
import '../features/sleep_timer/screens/sleep_timer_screen.dart';
import '../features/sleep_timer/controllers/sleep_timer_controller.dart';

class ShowcaseScreen extends StatelessWidget {
  final WorldClockController worldClockController;
  final StopwatchController stopwatchController;
  final SleepTimerController sleepTimerController;
  final ValueChanged<int>? onSelectScreen;

  const ShowcaseScreen({
    super.key,
    required this.worldClockController,
    required this.stopwatchController,
    required this.sleepTimerController,
    this.onSelectScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.showcaseBackground,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Screen 1: World Clock
              GestureDetector(
                onTap: () => onSelectScreen?.call(1),
                child: PhoneFrame(
                  width: 350,
                  height: 720,
                  child: WorldClockScreen(controller: worldClockController),
                ),
              ),

              // Screen 2: StopWatch
              GestureDetector(
                onTap: () => onSelectScreen?.call(2),
                child: PhoneFrame(
                  width: 350,
                  height: 720,
                  child: StopwatchScreen(controller: stopwatchController),
                ),
              ),

              // Screen 3: Sleep Timer
              GestureDetector(
                onTap: () => onSelectScreen?.call(3),
                child: PhoneFrame(
                  width: 350,
                  height: 720,
                  child: SleepTimerScreen(controller: sleepTimerController),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
