import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/phone_frame.dart';
import 'world_clock_screen.dart';
import 'stopwatch_screen.dart';
import 'sleep_timer_screen.dart';

class ShowcaseScreen extends StatelessWidget {
  final ValueChanged<int>? onSelectScreen;

  const ShowcaseScreen({
    super.key,
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
                onTap: () => onSelectScreen?.call(0),
                child: const PhoneFrame(
                  width: 350,
                  height: 720,
                  child: WorldClockScreen(),
                ),
              ),

              // Screen 2: StopWatch
              GestureDetector(
                onTap: () => onSelectScreen?.call(1),
                child: const PhoneFrame(
                  width: 350,
                  height: 720,
                  child: StopwatchScreen(),
                ),
              ),

              // Screen 3: Sleep Timer
              GestureDetector(
                onTap: () => onSelectScreen?.call(2),
                child: const PhoneFrame(
                  width: 350,
                  height: 720,
                  child: SleepTimerScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

