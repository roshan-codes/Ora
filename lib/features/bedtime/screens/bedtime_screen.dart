import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/bedtime_controller.dart';

class BedtimeScreen extends StatelessWidget {
  final BedtimeController controller;

  const BedtimeScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const days = [
      {'id': 1, 'name': 'M'},
      {'id': 2, 'name': 'T'},
      {'id': 3, 'name': 'W'},
      {'id': 4, 'name': 'T'},
      {'id': 5, 'name': 'F'},
      {'id': 6, 'name': 'S'},
      {'id': 7, 'name': 'S'},
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final m = controller.model;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Bedtime',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Switch.adaptive(
                                value: m.isEnabled,
                                activeColor: AppColors.orange,
                                onChanged: (val) => controller.toggleEnabled(val),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Sleep Goal Hero Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: m.isEnabled ? AppColors.orange : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: m.isEnabled
                                  ? [
                                      BoxShadow(
                                        color: AppColors.orange.withOpacity(0.32),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
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
                                      'Sleep Duration',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: m.isEnabled
                                            ? Colors.white.withOpacity(0.9)
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                    Icon(
                                      Icons.bed,
                                      color: m.isEnabled ? Colors.white : AppColors.orange,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  m.formattedSleepDuration,
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: m.isEnabled ? Colors.white : AppColors.textDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m.isEnabled
                                      ? 'Next bedtime ${m.remainingUntilBedtime}'
                                      : 'Schedule is paused',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: m.isEnabled
                                        ? Colors.white.withOpacity(0.85)
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Schedule',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Bedtime Card
                          _buildScheduleRow(
                            icon: Icons.nightlight_round,
                            title: 'Bedtime',
                            subtitle: 'Wind down reminder',
                            timeStr: m.formattedBedtime,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: m.bedtimeHour,
                                  minute: m.bedtimeMinute,
                                ),
                              );
                              if (picked != null) {
                                controller.updateBedtime(picked.hour, picked.minute);
                              }
                            },
                          ),

                          const SizedBox(height: 12),

                          // Wake Up Card
                          _buildScheduleRow(
                            icon: Icons.wb_sunny_rounded,
                            title: 'Wake Up',
                            subtitle: 'Alarm with sound & vibration',
                            timeStr: m.formattedWakeTime,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: m.wakeHour,
                                  minute: m.wakeMinute,
                                ),
                              );
                              if (picked != null) {
                                controller.updateWakeTime(picked.hour, picked.minute);
                              }
                            },
                          ),

                          const SizedBox(height: 22),

                          // Days of Week Row
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Days',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: days.map((day) {
                                    final id = day['id'] as int;
                                    final name = day['name'] as String;
                                    final isSelected = m.repeatDays.contains(id);

                                    return GestureDetector(
                                      onTap: () => controller.toggleDay(id),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.orange
                                              : AppColors.screenBackground,
                                          shape: BoxShape.circle,
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.orange.withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildScheduleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String timeStr,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.screenBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.orange, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

