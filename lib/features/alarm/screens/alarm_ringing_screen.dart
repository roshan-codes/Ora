import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/alarm_model.dart';

class AlarmRingingScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onStop;
  final ValueChanged<int> onSnooze;

  const AlarmRingingScreen({
    super.key,
    required this.alarm,
    required this.onStop,
    required this.onSnooze,
  });

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _currentTime;
  late Timer _timer;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm').format(_currentTime);
    final period = DateFormat('a').format(_currentTime).toLowerCase();
    final dateStr = DateFormat('EEEE, d MMMM').format(_currentTime);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar / Label
              Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alarm,
                          size: 16,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.alarm.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Center Visual & Live Clock
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated pulsing alarm bell ring
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final scale = 1.0 + (_animController.value * 0.12);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.orange.withOpacity(
                                  0.25 + (_animController.value * 0.25),
                                ),
                                blurRadius: 28 + (_animController.value * 12),
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.alarm_on,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 38),

                  // Big Hero Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -1.5,
                        ),
                      ),
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Full Date
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scheduled for detail
                  Text(
                    'Scheduled: ${widget.alarm.formattedTime}${widget.alarm.period} (${widget.alarm.repeatDaysSummary})',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              // Bottom Action Buttons (Snooze & Stop)
              Column(
                children: [
                  // Snooze button with quick option or default duration
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        shadowColor: Colors.black.withOpacity(0.04),
                      ),
                      onPressed: () =>
                          widget.onSnooze(widget.alarm.snoozeDurationMinutes),
                      child: Text(
                        'Snooze (${widget.alarm.snoozeDurationMinutes}m)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Stop Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        shadowColor: AppColors.orange.withOpacity(0.35),
                      ),
                      onPressed: widget.onStop,
                      child: const Text(
                        'Stop Alarm',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Snooze options row (5m, 10m, 15m, 20m)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [5, 10, 15, 20].map((mins) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => widget.onSnooze(mins),
                          child: Text(
                            '+${mins}m',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

