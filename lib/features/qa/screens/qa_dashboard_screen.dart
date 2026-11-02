import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/qa_test_case.dart';
import '../services/qa_engine.dart';
import '../widgets/qa_test_detail_sheet.dart';
import 'alarm_debug_console_screen.dart';
import '../../alarm/controllers/alarm_controller.dart';
import '../../world_clock/controllers/world_clock_controller.dart';
import '../../stopwatch/controllers/stopwatch_controller.dart';
import '../../sleep_timer/controllers/sleep_timer_controller.dart';
import '../../bedtime/controllers/bedtime_controller.dart';

class QADashboardScreen extends StatefulWidget {
  final QAEngine engine;
  final AlarmController? alarmController;
  final WorldClockController? worldClockController;
  final StopwatchController? stopwatchController;
  final SleepTimerController? sleepTimerController;
  final BedtimeController? bedtimeController;

  const QADashboardScreen({
    super.key,
    required this.engine,
    this.alarmController,
    this.worldClockController,
    this.stopwatchController,
    this.sleepTimerController,
    this.bedtimeController,
  });

  @override
  State<QADashboardScreen> createState() => _QADashboardScreenState();
}

class _QADashboardScreenState extends State<QADashboardScreen> {
  QAStatus? _statusFilter;
  QACategory? _categoryFilter;
  bool _isBatchRunning = false;

  void _openTestDetails(QATestCase testCase) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QATestDetailSheet(
        testCase: testCase,
        engine: widget.engine,
        alarmController: widget.alarmController,
        worldClockController: widget.worldClockController,
        stopwatchController: widget.stopwatchController,
        sleepTimerController: widget.sleepTimerController,
        bedtimeController: widget.bedtimeController,
      ),
    );
  }

  void _openDebugConsole() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlarmDebugConsoleScreen(
          engine: widget.engine,
          alarmController: widget.alarmController,
        ),
      ),
    );
  }

  Future<void> _runAllAutomated() async {
    setState(() => _isBatchRunning = true);
    await widget.engine.runAllAutomatedTests(
      alarmController: widget.alarmController,
      worldClockController: widget.worldClockController,
      stopwatchController: widget.stopwatchController,
      sleepTimerController: widget.sleepTimerController,
      bedtimeController: widget.bedtimeController,
    );
    setState(() => _isBatchRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.engine,
      builder: (context, _) {
        final engine = widget.engine;
        final filteredTests = engine.testCases.where((t) {
          if (_statusFilter != null && t.status != _statusFilter) return false;
          if (_categoryFilter != null && t.category != _categoryFilter) return false;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.screenBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'QA Test Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.terminal, color: AppColors.orange),
                tooltip: 'Alarm Debug Console',
                onPressed: _openDebugConsole,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Top Progress & Metric Banner
                _buildSummaryCard(engine),

                const SizedBox(height: 14),

                // Actions Row: Batch Run & Diagnostic Console
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isBatchRunning
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_circle_fill, size: 18),
                          label: Text(
                            _isBatchRunning ? 'Running Tests...' : 'Run Automated Suite',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          onPressed: _isBatchRunning ? null : _runAllAutomated,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textDark,
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.bug_report_outlined, size: 18, color: AppColors.orange),
                        label: const Text(
                          'Debug Console',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _openDebugConsole,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Filter Tabs (Status Filter)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterChip(null, 'All (${engine.totalTests})'),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip(
                        QAStatus.passed,
                        'Passed (${engine.passedTests})',
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip(
                        QAStatus.failed,
                        'Failed (${engine.failedTests})',
                        color: AppColors.errorRed,
                      ),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip(
                        QAStatus.notTested,
                        'Not Tested (${engine.notTestedTests})',
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip(
                        QAStatus.blocked,
                        'Blocked (${engine.blockedTests})',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Category Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(null, 'All Categories'),
                      const SizedBox(width: 6),
                      ...QACategory.values.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _buildCategoryChip(cat, _categoryLabel(cat)),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Tests List
                Expanded(
                  child: filteredTests.isEmpty
                      ? const Center(
                          child: Text(
                            'No test cases match active filter.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredTests.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final testCase = filteredTests[index];
                            return _buildTestCaseCard(testCase);
                          },
                        ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(QAEngine engine) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Test Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${engine.passedTests} of ${engine.totalTests} tests verified',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              Text(
                '${engine.completionPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: engine.totalTests == 0 ? 0.0 : engine.passedTests / engine.totalTests,
              backgroundColor: AppColors.screenBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCountBadge('Passed', engine.passedTests, AppColors.successGreen),
              _buildCountBadge('Failed', engine.failedTests, AppColors.errorRed),
              _buildCountBadge('Blocked', engine.blockedTests, Colors.orange),
              _buildCountBadge('Pending', engine.notTestedTests, AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusFilterChip(QAStatus? status, String label, {Color? color}) {
    final isSelected = _statusFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.textDark) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(QACategory? category, String label) {
    final isSelected = _categoryFilter == category;
    return GestureDetector(
      onTap: () => setState(() => _categoryFilter = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildTestCaseCard(QATestCase test) {
    Color badgeColor;
    String badgeText;

    switch (test.status) {
      case QAStatus.passed:
        badgeColor = AppColors.successGreen;
        badgeText = 'PASSED';
        break;
      case QAStatus.failed:
        badgeColor = AppColors.errorRed;
        badgeText = 'FAILED';
        break;
      case QAStatus.blocked:
        badgeColor = Colors.orange;
        badgeText = 'BLOCKED';
        break;
      case QAStatus.notTested:
        badgeColor = AppColors.textMuted;
        badgeText = 'NOT TESTED';
        break;
    }

    return GestureDetector(
      onTap: () => _openTestDetails(test),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon Indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                test.status == QAStatus.passed
                    ? Icons.check
                    : (test.status == QAStatus.failed
                        ? Icons.close
                        : (test.status == QAStatus.blocked
                            ? Icons.pause
                            : Icons.help_outline)),
                size: 16,
                color: badgeColor,
              ),
            ),
            const SizedBox(width: 12),

            // Title & ID
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        test.id,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        test.categoryName,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                      if (test.isAutomated) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.screenBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AUTO',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    test.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Status Badge & Run Button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
                if (test.isAutomated) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.play_arrow, size: 20, color: AppColors.orange),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      widget.engine.runTest(
                        test.id,
                        alarmController: widget.alarmController,
                        worldClockController: widget.worldClockController,
                        stopwatchController: widget.stopwatchController,
                        sleepTimerController: widget.sleepTimerController,
                        bedtimeController: widget.bedtimeController,
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(QACategory cat) {
    switch (cat) {
      case QACategory.alarm:
        return 'Alarm';
      case QACategory.ringing:
        return 'Ringing';
      case QACategory.permission:
        return 'Permissions';
      case QACategory.worldClock:
        return 'World Clock';
      case QACategory.stopwatch:
        return 'Stopwatch';
      case QACategory.sleepTimer:
        return 'Sleep Timer';
      case QACategory.bedtime:
        return 'Bedtime';
      case QACategory.storage:
        return 'Storage';
      case QACategory.background:
        return 'Background';
    }
  }
}

