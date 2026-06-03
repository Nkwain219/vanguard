import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/widgets/app_drawer.dart';
import 'package:vanguard/core/theme/app_theme.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_clock_button.dart';
import 'package:vanguard/widgets/wf_metric_card.dart';
import 'package:vanguard/l10n/app_localizations.dart';

class EmployeeDashboardScreen extends ConsumerStatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  ConsumerState<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState
    extends ConsumerState<EmployeeDashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(currentUserAttendanceProvider.notifier).loadAttendance();
      ref.read(currentUserSalaryProvider.notifier).loadSalaryRequests();
      ref.read(taskViewModelProvider.notifier).loadTasks();
      ref.read(currentUserLeaveProvider.notifier).loadLeaveRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final currentUser = ref.watch(currentUserProvider);

    final isClockedIn = ref.watch(isClockedInProvider);
    final clockInTime = ref.watch(clockInTimeProvider);
    final hoursWorkedToday = ref.watch(hoursWorkedTodayProvider);
    final weeklyHours = ref.watch(currentUserAttendanceProvider
        .select((s) => s.summary?.totalHoursWorked ?? 0.0));
    final attendanceLoading =
        ref.watch(currentUserAttendanceProvider.select((s) => s.isLoading));

    final leaveBalance =
        ref.watch(currentUserLeaveProvider.select((s) => s.remainingLeaveDays));

    final pendingSalaryCount = ref.watch(
        currentUserSalaryProvider.select((s) => s.pendingRequests.length));
    final totalSalaryCount =
        ref.watch(currentUserSalaryProvider.select((s) => s.requests.length));

    final allTasks = ref.watch(taskListProvider);
    final tasksLoading = ref.watch(tasksLoadingProvider);
    final myTasks =
        allTasks.where((t) => t.assigneeIds.contains(currentUser?.id)).toList();
    final tasksDueToday = myTasks
        .where((t) =>
            t.dueDate != null &&
            t.dueDate!.day == DateTime.now().day &&
            t.dueDate!.month == DateTime.now().month)
        .length;

    final greeting = _getGreeting(l10n);
    final userName = currentUser?.firstName ?? l10n.employee;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications),
            ),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $userName!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isClockedIn ? l10n.doingGreat : l10n.readyToStart,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      WFClockButton(
                        isClockedIn: isClockedIn,
                        clockInTime: clockInTime,
                        onClockIn: () => _handleClockAction(isClockIn: true),
                        onClockOut: () => _handleClockAction(isClockIn: false),
                        isLoading: attendanceLoading,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isClockedIn
                            ? l10n.clockedInAt(clockInTime ?? '')
                            : l10n.notClockedIn,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.quickGlance,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    WFMetricCard(
                      title: l10n.myTasks,
                      value: myTasks.length.toString(),
                      icon: Icons.assignment,
                      color: AppTheme.secondary,
                      subtitle: l10n.tasksDue(tasksDueToday),
                      onTap: () => context.push('/tasks'),
                    ),
                    WFMetricCard(
                      title: l10n.hoursThisWeek,
                      value: weeklyHours.toStringAsFixed(1),
                      icon: Icons.schedule,
                      color: AppTheme.success,
                      subtitle:
                          '${hoursWorkedToday.toStringAsFixed(1)} ${l10n.today}',
                      onTap: () => context.push('/attendance/employee'),
                    ),
                    WFMetricCard(
                      title: l10n.leaveBalance,
                      value: leaveBalance.toString(),
                      icon: Icons.event_available,
                      color: AppTheme.warning,
                      subtitle: l10n.daysRemaining,
                      onTap: () => context.push('/leave-request'),
                    ),
                    WFMetricCard(
                      title: l10n.salaryRequests,
                      value: totalSalaryCount.toString(),
                      icon: Icons.payments,
                      color: AppTheme.primary,
                      subtitle: '$pendingSalaryCount ${l10n.pending}',
                      onTap: () => context.push('/salary-request'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.quickActions,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.9,
                  children: [
                    _buildQuickActionCard(
                      context,
                      l10n.requestLeave,
                      Icons.event_available,
                      () => context.push('/leave-request'),
                    ),
                    _buildQuickActionCard(
                      context,
                      l10n.requestDeposit,
                      Icons.receipt,
                      () => context.push('/deposit'),
                    ),
                    _buildQuickActionCard(
                      context,
                      l10n.salaryRequest,
                      Icons.payments,
                      () => context.push('/salary-request'),
                    ),
                    _buildQuickActionCard(
                      context,
                      l10n.companyDeposits,
                      Icons.account_balance_wallet,
                      () => context.push('/my-deposits'),
                    ),
                    _buildQuickActionCard(
                      context,
                      l10n.payslips,
                      Icons.description,
                      () => context.push('/payslip/current'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.recentTasks,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (tasksLoading)
                  const Center(child: CircularProgressIndicator())
                else if (myTasks.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.task_alt,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              l10n.noTasks,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myTasks.take(3).length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final task = myTasks[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getTaskStatusColor(task.status)
                                .withValues(alpha: 0.1),
                            child: Icon(
                              _getTaskStatusIcon(task.status),
                              color: _getTaskStatusColor(task.status),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            task.dueDate != null
                                ? l10n.dueLabel(_formatDate(task.dueDate!))
                                : l10n.noDueDate,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/tasks/${task.id}'),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 6),
              Flexible(
                fit: FlexFit.loose,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(currentUserAttendanceProvider.notifier).loadAttendance(),
      ref.read(currentUserSalaryProvider.notifier).loadSalaryRequests(),
      ref.read(taskViewModelProvider.notifier).loadTasks(),
      ref.read(currentUserLeaveProvider.notifier).loadLeaveRequests(),
    ]);
  }

  Future<void> _handleClockAction({required bool isClockIn}) async {
    final attendanceNotifier = ref.read(currentUserAttendanceProvider.notifier);

    bool success;
    if (isClockIn) {
      success = await attendanceNotifier.clockIn();
    } else {
      success = await attendanceNotifier.clockOut();
    }

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isClockIn ? l10n.clockInSuccess : l10n.clockOutSuccess),
          backgroundColor: AppTheme.success,
        ),
      );
    } else if (!success && mounted) {
      final error = ref.read(currentUserAttendanceProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? AppLocalizations.of(context)!.operationFailed),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Color _getTaskStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'TaskStatus.pending':
        return Colors.grey;
      case 'TaskStatus.inProgress':
        return Colors.blue;
      case 'TaskStatus.completed':
        return Colors.green;
      case 'TaskStatus.cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskStatusIcon(dynamic status) {
    switch (status.toString()) {
      case 'TaskStatus.pending':
        return Icons.pending;
      case 'TaskStatus.inProgress':
        return Icons.hourglass_empty;
      case 'TaskStatus.completed':
        return Icons.check_circle;
      case 'TaskStatus.cancelled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
