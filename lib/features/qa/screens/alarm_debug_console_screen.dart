import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:alarm/alarm.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/permissions/permission_service.dart';
import '../services/qa_engine.dart';
import '../../alarm/controllers/alarm_controller.dart';

class AlarmDebugConsoleScreen extends StatefulWidget {
  final QAEngine engine;
  final AlarmController? alarmController;

  const AlarmDebugConsoleScreen({
    super.key,
    required this.engine,
    this.alarmController,
  });

  @override
  State<AlarmDebugConsoleScreen> createState() => _AlarmDebugConsoleScreenState();
}

class _AlarmDebugConsoleScreenState extends State<AlarmDebugConsoleScreen> {
  List<AlarmSettings> _osAlarms = [];
  bool _notifGranted = false;
  bool _exactGranted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshDiagnostics();
  }

  Future<void> _refreshDiagnostics() async {
    setState(() => _isLoading = true);
    _osAlarms = await Alarm.getAlarms();
    _notifGranted = await PermissionService.instance.hasNotificationPermission();
    _exactGranted = await PermissionService.instance.hasExactAlarmPermission();
    setState(() => _isLoading = false);
  }

  void _exportReport() async {
    final report = await widget.engine.exportDiagnosticReport(widget.alarmController);
    await Clipboard.setData(ClipboardData(text: report));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.orange,
          content: Text('Diagnostic report copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedAlarms = widget.alarmController?.alarms ?? [];
    final ringing = widget.alarmController?.currentlyRingingAlarm;

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
          'Alarm Debug Console',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.orange),
            onPressed: _refreshDiagnostics,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.orange),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Real-Time System Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: ringing != null ? AppColors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: ringing != null
                              ? AppColors.orange.withOpacity(0.3)
                              : Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Alarm Engine State',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ringing != null
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.textMuted,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ringing != null
                                    ? Colors.white.withOpacity(0.25)
                                    : AppColors.screenBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                ringing != null ? 'RINGING' : 'IDLE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: ringing != null ? Colors.white : AppColors.successGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (ringing != null) ...[
                          Text(
                            'Active: ${ringing.label} (${ringing.formattedTime}${ringing.period})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Audio: ${ringing.audioTitle} • Vibrate: ${ringing.vibrate}',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                          ),
                        ] else ...[
                          Text(
                            _osAlarms.isNotEmpty
                                ? 'Next in OS: ${_osAlarms.first.notificationSettings.title}'
                                : 'No alarms currently armed in OS',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (_osAlarms.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                DateFormat('EEE, d MMM • h:mm a').format(_osAlarms.first.dateTime),
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Diagnostics Matrix Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          'OS Registered',
                          '${_osAlarms.length}',
                          'Native alarms',
                          Icons.schedule,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          'App Saved',
                          '${savedAlarms.length}',
                          'Stored in prefs',
                          Icons.folder_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Permission Matrix Card
                  Container(
                    padding: const EdgeInsets.all(18),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Permission States',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPermRow('Post Notifications', _notifGranted),
                        const Divider(height: 16),
                        _buildPermRow('Schedule Exact Alarms (Android)', _exactGranted),
                        const Divider(height: 16),
                        _buildPermRow('Haptic Vibration Engine', true),
                        const Divider(height: 16),
                        _buildPermRow('Full-Screen Alarm Intent', true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Registered Native Alarms List
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Native AlarmManager / APNs Registry',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () async {
                                await widget.engine.clearTestData(widget.alarmController);
                                _refreshDiagnostics();
                              },
                              child: const Text(
                                'Clear QA Alarms',
                                style: TextStyle(fontSize: 12, color: AppColors.orange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_osAlarms.isEmpty)
                          const Text(
                            'No active alarms scheduled in device OS.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          )
                        else
                          ..._osAlarms.map((a) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.screenBackground,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '#${a.id}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        a.notificationSettings.title.isEmpty ? 'Alarm' : a.notificationSettings.title,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat('h:mm a • EEE').format(a.dateTime),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Diagnostic Event Logs
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Background & Event Logs',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedBuilder(
                          animation: widget.engine,
                          builder: (context, _) {
                            final logs = widget.engine.logs;
                            if (logs.isEmpty) {
                              return const Text(
                                'No logs recorded yet.',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              );
                            }
                            return Column(
                              children: logs.take(15).map((l) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm:ss').format(l.timestamp),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '[${l.tag}] ${l.message}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricTile(String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              Icon(icon, size: 16, color: AppColors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPermRow(String label, bool isGranted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        ),
        Row(
          children: [
            Text(
              isGranted ? 'GRANTED' : 'DENIED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isGranted ? AppColors.successGreen : AppColors.errorRed,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isGranted ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: isGranted ? AppColors.successGreen : AppColors.errorRed,
            ),
          ],
        ),
      ],
    );
  }
}

