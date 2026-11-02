import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/qa_test_case.dart';
import '../services/qa_engine.dart';
import '../../alarm/controllers/alarm_controller.dart';
import '../../world_clock/controllers/world_clock_controller.dart';
import '../../stopwatch/controllers/stopwatch_controller.dart';
import '../../sleep_timer/controllers/sleep_timer_controller.dart';
import '../../bedtime/controllers/bedtime_controller.dart';

class QATestDetailSheet extends StatefulWidget {
  final QATestCase testCase;
  final QAEngine engine;
  final AlarmController? alarmController;
  final WorldClockController? worldClockController;
  final StopwatchController? stopwatchController;
  final SleepTimerController? sleepTimerController;
  final BedtimeController? bedtimeController;

  const QATestDetailSheet({
    super.key,
    required this.testCase,
    required this.engine,
    this.alarmController,
    this.worldClockController,
    this.stopwatchController,
    this.sleepTimerController,
    this.bedtimeController,
  });

  @override
  State<QATestDetailSheet> createState() => _QATestDetailSheetState();
}

class _QATestDetailSheetState extends State<QATestDetailSheet> {
  late TextEditingController _notesController;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.testCase.actualResult);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _executeTest() async {
    setState(() => _isRunning = true);
    await widget.engine.runTest(
      widget.testCase.id,
      alarmController: widget.alarmController,
      worldClockController: widget.worldClockController,
      stopwatchController: widget.stopwatchController,
      sleepTimerController: widget.sleepTimerController,
      bedtimeController: widget.bedtimeController,
    );
    _notesController.text = widget.testCase.actualResult;
    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.testCase;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.categoryName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textDark),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test Name
                  Text(
                    t.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Screen: ${t.relatedScreen}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),

                  const SizedBox(height: 18),

                  // Preconditions
                  _buildSectionCard(
                    title: 'Preconditions',
                    content: t.preconditions,
                    icon: Icons.check_circle_outline,
                  ),

                  const SizedBox(height: 12),

                  // Steps
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                        const Row(
                          children: [
                            Icon(Icons.format_list_numbered, size: 18, color: AppColors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Test Steps',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...t.steps.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                  height: 1.3,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Expected Result
                  _buildSectionCard(
                    title: 'Expected Result',
                    content: t.expectedResult,
                    icon: Icons.flag_outlined,
                  ),

                  const SizedBox(height: 12),

                  // Actual Result & Notes
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.description_outlined,
                                    size: 18, color: AppColors.orange),
                                SizedBox(width: 8),
                                Text(
                                  'Actual Result / Observations',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            if (t.executedAt != null)
                              Text(
                                DateFormat('MMM d, h:mm a').format(t.executedAt!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter observed behavior or error message...',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          onChanged: (val) {
                            t.actualResult = val;
                          },
                        ),
                        if (t.errorMessage != null) ...[
                          const Divider(height: 16),
                          Text(
                            'Error: ${t.errorMessage}',
                            style: const TextStyle(fontSize: 12, color: AppColors.errorRed),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Interactive Status Setter
                  const Text(
                    'Set Test Verdict',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStatusBtn(QAStatus.passed, 'Pass', AppColors.successGreen),
                      const SizedBox(width: 8),
                      _buildStatusBtn(QAStatus.failed, 'Fail', AppColors.errorRed),
                      const SizedBox(width: 8),
                      _buildStatusBtn(QAStatus.blocked, 'Blocked', Colors.orange),
                      const SizedBox(width: 8),
                      _buildStatusBtn(QAStatus.notTested, 'Reset', AppColors.textMuted),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Automated Run Button
                  if (t.isAutomated)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: _isRunning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow, size: 20),
                        label: Text(
                          _isRunning ? 'Executing Test...' : 'Run Automated Test',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        onPressed: _isRunning ? null : _executeTest,
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.orange),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBtn(QAStatus status, String label, Color color) {
    final isSelected = widget.testCase.status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.engine.updateTestStatus(
            widget.testCase.id,
            status,
            actualResult: _notesController.text.trim().isEmpty
                ? 'Marked as $label manually.'
                : _notesController.text.trim(),
          );
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

