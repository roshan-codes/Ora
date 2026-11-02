import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/wavy_dial.dart';
import '../controllers/stopwatch_controller.dart';

class StopwatchScreen extends StatelessWidget {
  final StopwatchController controller;
  final VoidCallback? onOpenSettings;

  const StopwatchScreen({
    super.key,
    required this.controller,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isRunning = controller.isRunning;
        final isPaused = controller.isPaused;
        final isStopped = controller.isStopped;

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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          // Header
                          GestureDetector(
                            onLongPress: onOpenSettings,
                            child: const Text(
                              'StopWatch',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Dynamic Dial Graphic with real time readout
                          Center(
                            child: SizedBox(
                              width: 225,
                              height: 225,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const WavyDial(size: 225),
                                  // Overlay live stopwatch readings
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            isStopped
                                                ? '1h 15m'
                                                : controller.formattedDisplay,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          if (!isStopped)
                                            Text(
                                              '.${controller.millisecondsDisplay}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        isRunning
                                            ? 'Timing'
                                            : (isPaused ? 'Paused' : 'Remaining'),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        isStopped ? '1 hrs' : 'Active',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isStopped
                                            ? 'To complete drying'
                                            : (isRunning
                                                ? 'Tap Lap to record'
                                                : 'Ready'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Task information
                          Text(
                            isStopped
                                ? 'Wash and dry'
                                : (isRunning
                                    ? 'Precision Stopwatch'
                                    : 'Timing Paused'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isStopped
                                ? 'Currently drying'
                                : '${controller.laps.length} recorded splits',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '65% work done already',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Laps List (if any recorded)
                          if (controller.laps.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 140),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: controller.laps.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 12),
                                itemBuilder: (context, index) {
                                  final lap = controller.laps[index];
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Lap ${lap.lapIndex}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        lap.formattedDifference,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: lap.differenceFromPrevious
                                                      ?.isNegative ??
                                                  false
                                              ? AppColors.successGreen
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                      Text(
                                        lap.formattedLapTime,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          else
                            const Text(
                              '65% work done already',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textMuted,
                              ),
                            ),

                          const Spacer(),
                          const SizedBox(height: 16),

                          // Bottom Controls Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Button 1 (Pause or Lap)
                              GestureDetector(
                                onTap: () {
                                  if (isRunning) {
                                    controller.recordLap();
                                  } else if (isPaused) {
                                    controller.reset();
                                  } else {
                                    // isStopped: start
                                    controller.start();
                                  }
                                },
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isRunning
                                        ? const Text(
                                            'Lap',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          )
                                        : (isPaused
                                            ? const Icon(
                                                Icons.refresh,
                                                color: AppColors.textMuted,
                                                size: 20,
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 4,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.textMuted,
                                                      borderRadius:
                                                          BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Container(
                                                    width: 4,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.textMuted,
                                                      borderRadius:
                                                          BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Button 2 (Play / Pause / Stop)
                              GestureDetector(
                                onTap: () {
                                  if (isRunning) {
                                    controller.pause();
                                  } else {
                                    controller.start();
                                  }
                                },
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
                                        blurRadius: 12,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),
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
}

