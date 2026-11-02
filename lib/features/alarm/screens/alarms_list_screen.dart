import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/alarm_model.dart';
import '../controllers/alarm_controller.dart';
import 'add_edit_alarm_screen.dart';

class AlarmsListScreen extends StatelessWidget {
  final AlarmController controller;

  const AlarmsListScreen({
    super.key,
    required this.controller,
  });

  void _openAddAlarm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditAlarmScreen(
          onSave: (newAlarm) => controller.addAlarm(newAlarm),
        ),
      ),
    );
  }

  void _openEditAlarm(BuildContext context, AlarmModel alarm) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditAlarmScreen(
          existingAlarm: alarm,
          onSave: (updated) => controller.updateAlarm(updated),
          onDelete: (id) => controller.deleteAlarm(id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final alarms = controller.alarms;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
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
                      'Alarms',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    // Quick test ringing trigger button
                    if (alarms.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.ring_volume, size: 16, color: AppColors.orange),
                        label: const Text(
                          'Test Ring',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.orange,
                          ),
                        ),
                        onPressed: () {
                          controller.simulateRing(alarms.first);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Alarms List or Empty State
                Expanded(
                  child: alarms.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: alarms.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final alarm = alarms[index];
                            return _buildAlarmCard(context, alarm);
                          },
                        ),
                ),

                const SizedBox(height: 12),

                // Floating Action Button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _openAddAlarm(context),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.alarm_off_outlined,
              size: 32,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Alarms Set',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the + button below to create your first alarm',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, AlarmModel alarm) {
    final isSelected = alarm.isEnabled;

    return Dismissible(
      key: Key('alarm_${alarm.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteAlarm(alarm.id),
      child: GestureDetector(
        onTap: () => _openEditAlarm(context, alarm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.orange : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Label, Repeat Days, Sound
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      alarm.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alarm.repeatDaysSummary} • ${alarm.audioTitle}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? Colors.white.withOpacity(0.85)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Time & Toggle Switch
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        alarm.formattedTime,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        alarm.period,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Toggle Switch
                  Switch.adaptive(
                    value: alarm.isEnabled,
                    activeColor: Colors.white,
                    activeTrackColor: isSelected
                        ? Colors.white.withOpacity(0.35)
                        : AppColors.orange,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.switchTrackInactive,
                    onChanged: (val) {
                      controller.toggleAlarm(alarm.id, val);
                    },
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

