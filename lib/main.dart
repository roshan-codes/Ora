import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'features/alarm/controllers/alarm_controller.dart';
import 'features/alarm/screens/alarms_list_screen.dart';
import 'features/alarm/screens/alarm_ringing_screen.dart';
import 'features/alarm/services/alarm_scheduler_service.dart';
import 'features/world_clock/controllers/world_clock_controller.dart';
import 'features/world_clock/screens/world_clock_screen.dart';
import 'features/stopwatch/controllers/stopwatch_controller.dart';
import 'features/stopwatch/screens/stopwatch_screen.dart';
import 'features/sleep_timer/controllers/sleep_timer_controller.dart';
import 'features/sleep_timer/screens/sleep_timer_screen.dart';
import 'features/bedtime/controllers/bedtime_controller.dart';
import 'features/qa/services/qa_engine.dart';
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize native Alarm service
  await AlarmSchedulerService.instance.initialize();

  runApp(const OraApp());
}

class OraApp extends StatefulWidget {
  const OraApp({super.key});

  @override
  State<OraApp> createState() => _OraAppState();
}

class _OraAppState extends State<OraApp> {
  late final AlarmController _alarmController;
  late final WorldClockController _worldClockController;
  late final StopwatchController _stopwatchController;
  late final SleepTimerController _sleepTimerController;
  late final BedtimeController _bedtimeController;
  late final QAEngine _qaEngine;

  @override
  void initState() {
    super.initState();
    _alarmController = AlarmController();
    _worldClockController = WorldClockController();
    _stopwatchController = StopwatchController();
    _sleepTimerController = SleepTimerController(alarmController: _alarmController);
    _bedtimeController = BedtimeController(alarmController: _alarmController);
    _qaEngine = QAEngine.instance;
  }

  @override
  void dispose() {
    _alarmController.dispose();
    _worldClockController.dispose();
    _stopwatchController.dispose();
    _sleepTimerController.dispose();
    _bedtimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ora Clock & Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.screenBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orange,
          primary: AppColors.orange,
        ),
        fontFamilyFallback: const [
          'SF Pro Display',
          'Inter',
          'Helvetica Neue',
          'Roboto',
          'sans-serif',
        ],
        useMaterial3: true,
      ),
      home: AnimatedBuilder(
        animation: _alarmController,
        builder: (context, _) {
          // If an alarm is currently ringing, display the full-screen ringing UI!
          final ringingAlarm = _alarmController.currentlyRingingAlarm;
          if (ringingAlarm != null) {
            return AlarmRingingScreen(
              alarm: ringingAlarm,
              onStop: () => _alarmController.stopRinging(),
              onSnooze: (mins) => _alarmController.snoozeRinging(overrideMinutes: mins),
            );
          }

          return MainNavigationShell(
            alarmController: _alarmController,
            worldClockController: _worldClockController,
            stopwatchController: _stopwatchController,
            sleepTimerController: _sleepTimerController,
            bedtimeController: _bedtimeController,
            qaEngine: _qaEngine,
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AlarmController alarmController;
  final WorldClockController worldClockController;
  final StopwatchController stopwatchController;
  final SleepTimerController sleepTimerController;
  final BedtimeController bedtimeController;
  final QAEngine qaEngine;

  final int initialIndex;

  const MainNavigationShell({
    super.key,
    required this.alarmController,
    required this.worldClockController,
    required this.stopwatchController,
    required this.sleepTimerController,
    required this.bedtimeController,
    required this.qaEngine,
    this.initialIndex = 1,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  // 0: Alarms, 1: Clock (World Clock), 2: Timer (StopWatch), 3: Bedtimes (Sleep Timer)
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          alarmController: widget.alarmController,
          worldClockController: widget.worldClockController,
          stopwatchController: widget.stopwatchController,
          sleepTimerController: widget.sleepTimerController,
          bedtimeController: widget.bedtimeController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      // Pixel-perfect: No top bar. Content starts cleanly below status bar.
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: _buildCurrentView(),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildFloatingBottomNav(),
      ),
    );
  }

  Widget _buildFloatingBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.alarm_outlined,
            label: 'Alarms',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.public,
            label: 'Clock',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.timer_outlined,
            label: 'Timer',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.bed_outlined,
            label: 'Bedtimes',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      onLongPress: _openSettings, // Subtle developer shortcut to Settings & QA
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.white,
              ),
            )
          else
            Icon(
              icon,
              size: 20,
              color: AppColors.unselectedIcon,
            ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.orange : AppColors.unselectedIcon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentIndex) {
      case 0:
        return AlarmsListScreen(
          controller: widget.alarmController,
        );
      case 1:
        return WorldClockScreen(
          controller: widget.worldClockController,
          onOpenSettings: _openSettings,
        );
      case 2:
        return StopwatchScreen(
          controller: widget.stopwatchController,
          onOpenSettings: _openSettings,
        );
      case 3:
      default:
        return SleepTimerScreen(
          controller: widget.sleepTimerController,
          onOpenSettings: _openSettings,
        );
    }
  }
}
