import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../qa/services/qa_engine.dart';
import '../../qa/screens/qa_dashboard_screen.dart';
import '../../qa/screens/alarm_debug_console_screen.dart';
import '../../alarm/controllers/alarm_controller.dart';
import '../../world_clock/controllers/world_clock_controller.dart';
import '../../stopwatch/controllers/stopwatch_controller.dart';
import '../../sleep_timer/controllers/sleep_timer_controller.dart';
import '../../bedtime/controllers/bedtime_controller.dart';

class SettingsScreen extends StatelessWidget {
  final AlarmController? alarmController;
  final WorldClockController? worldClockController;
  final StopwatchController? stopwatchController;
  final SleepTimerController? sleepTimerController;
  final BedtimeController? bedtimeController;

  const SettingsScreen({
    super.key,
    this.alarmController,
    this.worldClockController,
    this.stopwatchController,
    this.sleepTimerController,
    this.bedtimeController,
  });

  @override
  Widget build(BuildContext context) {
    final engine = QAEngine.instance;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Preferences
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),

            _buildSettingCard([
              _buildSettingTile(
                icon: Icons.notifications_active_outlined,
                title: 'Lock-Screen Presentation',
                subtitle: 'Wake up display for alarms',
                trailing: const Icon(Icons.check, color: AppColors.orange, size: 20),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.volume_up_outlined,
                title: 'Gradual Volume Increase',
                subtitle: '15-second gentle audio ramp',
                trailing: const Icon(Icons.check, color: AppColors.orange, size: 20),
              ),
            ]),

            const SizedBox(height: 24),

            // DEVELOPER TOOLS SECTION (Accessible in dev & testing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Developer Tools',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'QA MODE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // QA Testing Dashboard Entry
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fact_check_outlined, color: AppColors.orange),
                    ),
                    title: const Text(
                      'QA Testing',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: AnimatedBuilder(
                      animation: engine,
                      builder: (context, _) {
                        return Text(
                          '${engine.totalTests} tests • ${engine.passedTests} passed (${engine.completionPercentage.toStringAsFixed(0)}%)',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        );
                      },
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QADashboardScreen(
                            engine: engine,
                            alarmController: alarmController,
                            worldClockController: worldClockController,
                            stopwatchController: stopwatchController,
                            sleepTimerController: sleepTimerController,
                            bedtimeController: bedtimeController,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.screenBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.terminal, color: AppColors.textDark),
                    ),
                    title: const Text(
                      'Alarm Debug Console',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: const Text(
                      'OS registry, active audio, permissions & event logs',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlarmDebugConsoleScreen(
                            engine: engine,
                            alarmController: alarmController,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About section
            const Text(
              'About Ora',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingCard([
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'Application Version',
                subtitle: 'Ora 1.0.0 (Production Architecture)',
                trailing: const Text('1.0.0+1', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
            ]),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Icon(icon, color: AppColors.textDark, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
      trailing: trailing,
    );
  }
}
