import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WorldClockScreen extends StatelessWidget {
  final ValueChanged<int>? onTabSelected;

  const WorldClockScreen({
    super.key,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        'World Clock',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Big Clock Display
                      const Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '5:15',
                                  style: TextStyle(
                                    fontSize: 54,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                    letterSpacing: -1.2,
                                  ),
                                ),
                                Text(
                                  'pm',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tue, 29 Apr',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Locations label
                      const Text(
                        'Locations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Location Cards
                      _buildLocationCard(
                        city: 'Tokyo',
                        offset: '-10h',
                        timeDigits: '5:05',
                        timePeriod: 'am',
                        isSelected: false,
                      ),
                      const SizedBox(height: 12),
                      _buildLocationCard(
                        city: 'Mumbai',
                        offset: '-3h',
                        timeDigits: '2:15',
                        timePeriod: 'pm',
                        isSelected: true,
                      ),
                      const SizedBox(height: 12),
                      _buildLocationCard(
                        city: 'Los Angels',
                        offset: '-5h',
                        timeDigits: '12:15',
                        timePeriod: 'am',
                        isSelected: false,
                      ),

                      const Spacer(),
                      const SizedBox(height: 12),

                      // Floating Plus Button aligned to right
                      Align(
                        alignment: Alignment.centerRight,
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

                      const SizedBox(height: 14),

                      // Bottom Navigation Bar Pill
                      _buildBottomNav(),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationCard({
    required String city,
    required String offset,
    required String timeDigits,
    required String timePeriod,
    required bool isSelected,
  }) {
    final bgColor = isSelected ? AppColors.orange : AppColors.cardWhite;
    final primaryTextColor = isSelected ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
        isSelected ? Colors.white.withOpacity(0.85) : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.3),
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
          // City & Offset
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                city,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                offset,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          // Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                timeDigits,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                timePeriod,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
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
            isSelected: false,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.public,
            label: 'Clock',
            isSelected: true,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.timer_outlined,
            label: 'Timer',
            isSelected: false,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.bed_outlined,
            label: 'Bedtimes',
            isSelected: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTabSelected?.call(index),
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
              child: const Icon(
                Icons.public,
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
}
