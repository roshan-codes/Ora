import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/sleep_timer_controller.dart';

class SleepTimerScreen extends StatelessWidget {
  final SleepTimerController controller;
  final VoidCallback? onOpenSettings;

  const SleepTimerScreen({
    super.key,
    required this.controller,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    // Weekday mapping: indices 0..6 map to days of week [7, 1, 2, 3, 4, 5, 6] or standard
    const dayLabels = ['S', 'S', 'M', 'T', 'W', 'T', 'F'];
    // In design: Sunday, Saturday, Monday, Tuesday, Wednesday, Thursday, Friday
    // Map index to ISO weekday: 0->7(Sun), 1->6(Sat), 2->1(Mon), 3->2(Tue), 4->3(Wed), 5->4(Thu), 6->5(Fri)
    const dayIsoMapping = [7, 6, 1, 2, 3, 4, 5];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
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
                          GestureDetector(
                            onLongPress: onOpenSettings,
                            child: const Text(
                              'Sleep Timer',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Subtitle
                          const Center(
                            child: Text(
                              'Set a regular wake-up alarm',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Time Selector (- 7:00am +)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Minus button
                              GestureDetector(
                                onTap: controller.decrementAlarmTime,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 22),

                              // Time digits
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    controller.formattedAlarmTime,
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    controller.alarmPeriod,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 22),

                              // Plus button
                              GestureDetector(
                                onTap: controller.incrementAlarmTime,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.orange,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.orange.withOpacity(0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Days of the week row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(dayLabels.length, (index) {
                              final isoDay = dayIsoMapping[index];
                              final isSelected = controller.selectedDays.contains(isoDay);

                              return GestureDetector(
                                onTap: () => controller.toggleDay(isoDay),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.orange : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? AppColors.orange.withOpacity(0.35)
                                            : Colors.black.withOpacity(0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      dayLabels[index],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 24),

                          // Option Cards
                          // 1. Sunrise Alarm
                          GestureDetector(
                            onTap: controller.toggleSunriseAlarm,
                            child: _buildOptionCard(
                              iconWidget: const Icon(
                                Icons.wb_sunny_outlined,
                                size: 20,
                                color: AppColors.textDark,
                              ),
                              title: 'Sunrise alarm',
                              subtitle: 'Slowly brighten screen before alarm',
                              isSelected: controller.sunriseAlarm,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 2. Vibrate (Active)
                          GestureDetector(
                            onTap: controller.toggleVibrate,
                            child: _buildOptionCard(
                              iconWidget: Icon(
                                Icons.vibration,
                                size: 20,
                                color: controller.vibrate
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                              title: 'Vibrate',
                              isSelected: controller.vibrate,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 3. Sound
                          _buildOptionCard(
                            iconWidget: const Icon(
                              Icons.music_note_outlined,
                              size: 20,
                              color: AppColors.textDark,
                            ),
                            title: 'Sound',
                            subtitle: controller.soundTitle,
                            isSelected: false,
                          ),

                          const Spacer(),
                          const SizedBox(height: 16),

                          // Bottom Buttons (Skip & Next)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Skipped configuration'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Skip',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await controller.saveAndScheduleWakeUpAlarm();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.orange,
                                          content: Text(
                                            'Wake-up alarm set for ${controller.formattedAlarmTime}${controller.alarmPeriod}!',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.orange,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.orange.withOpacity(0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

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

  Widget _buildOptionCard({
    required Widget iconWidget,
    required String title,
    String? subtitle,
    required bool isSelected,
  }) {
    final bgColor = isSelected ? AppColors.orange : Colors.white;
    final primaryTextColor = isSelected ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
        isSelected ? Colors.white.withOpacity(0.85) : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Icon
          iconWidget,
          const SizedBox(width: 14),

          // Title & optional subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Radio or Checkmark
          if (isSelected)
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  size: 13,
                  color: AppColors.orange,
                ),
              ),
            )
          else
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.radioBorder,
                  width: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

