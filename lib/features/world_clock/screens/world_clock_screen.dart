import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/world_clock_controller.dart';
import '../widgets/city_search_sheet.dart';

class WorldClockScreen extends StatelessWidget {
  final WorldClockController controller;
  final VoidCallback? onOpenSettings;

  const WorldClockScreen({
    super.key,
    required this.controller,
    this.onOpenSettings,
  });

  void _openAddCitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CitySearchSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final heroCity = controller.activeHeroCity;
        final cities = controller.selectedCities;

        final heroTimeDigits = heroCity?.formattedTime ?? '5:15';
        final heroPeriod = heroCity?.period ?? 'pm';
        final heroDate = heroCity?.formattedDate ?? 'Tue, 29 Apr';

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
                              'World Clock',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Big Clock Display (Live Time)
                          Center(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      heroTimeDigits,
                                      style: const TextStyle(
                                        fontSize: 54,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textDark,
                                        letterSpacing: -1.2,
                                      ),
                                    ),
                                    Text(
                                      heroPeriod,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  heroDate,
                                  style: const TextStyle(
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

                          // Location Cards List
                          ...cities.map((city) {
                            final isSelected =
                                city.id == controller.selectedCityId;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: Key('city_${city.id}'),
                                direction: cities.length > 1
                                    ? DismissDirection.endToStart
                                    : DismissDirection.none,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorRed,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) {
                                  controller.removeCity(city.id);
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectCity(city.id);
                                  },
                                  child: _buildLocationCard(
                                    city: city.cityName,
                                    offset: city.relativeOffsetString,
                                    timeDigits: city.formattedTime,
                                    timePeriod: city.period,
                                    isSelected: isSelected,
                                  ),
                                ),
                              ),
                            );
                          }),

                          const Spacer(),
                          const SizedBox(height: 12),

                          // Floating Plus Button to add city
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => _openAddCitySheet(context),
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.orange.withOpacity(0.35),
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
                          const SizedBox(height: 18),
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

}
