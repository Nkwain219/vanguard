import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vanguard/core/models/task.dart';
import 'package:vanguard/core/models/project.dart';
import 'package:vanguard/core/models/leave_request.dart';
import 'package:vanguard/core/theme/app_theme.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/core/providers/repository_providers.dart';
import 'package:vanguard/core/providers/wallet_balance_provider.dart';
import 'package:vanguard/widgets/wf_metric_card.dart';
import 'package:vanguard/widgets/app_drawer.dart';
import 'package:vanguard/l10n/app_localizations.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  List<double> _weeklyAttendanceCounts = [0, 0, 0, 0, 0];
  bool _isLoadingChart = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(employeeViewModelProvider.notifier).loadEmployees();
      ref.read(volunteerViewModelProvider.notifier).loadVolunteers();
      ref.read(taskViewModelProvider.notifier).loadTasks();
      ref.read(projectViewModelProvider.notifier).loadProjects();
      ref.read(leaveViewModelProvider.notifier).loadLeaveRequests();
      ref.read(salaryViewModelProvider.notifier).loadSalaryRequests();
      ref.read(depositViewModelProvider.notifier).loadDeposits();
      ref
          .read(globalAttendanceViewModelProvider.notifier)
          .loadDailyAttendance(DateTime.now());
      ref.read(walletBalanceProvider.notifier).fetchBalance();
      _loadWeeklyAttendance();
    });
  }

  Future<void> _loadWeeklyAttendance() async {
    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final now = DateTime.now();

      final monday = now.subtract(Duration(days: now.weekday - 1));
      final counts = <double>[];

      for (int i = 0; i < 5; i++) {
        final day = DateTime(monday.year, monday.month, monday.day + i);

        if (day.isAfter(now)) {
          counts.add(0);
        } else {
          final records = await repo.getAttendanceByDate(day);
          counts.add(records.length.toDouble());
        }
      }

      if (mounted) {
        setState(() {
          _weeklyAttendanceCounts = counts;
          _isLoadingChart = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingChart = false);
      }
    }
  }

  List<Map<String, dynamic>> _buildRecentActivities() {
    final activities = <Map<String, dynamic>>[];

    final leaveRequests = ref.read(leaveViewModelProvider).requests;
    for (final lr in leaveRequests) {
      activities.add({
        'icon': lr.status == LeaveStatus.pending
            ? Icons.schedule_send
            : lr.status == LeaveStatus.approved
                ? Icons.check_circle
                : Icons.cancel,
        'title':
            '${lr.employeeFullName} — ${lr.type.name} leave ${lr.status.name}',
        'date': lr.requestDate,
      });
    }

    final salaryRequests = ref.read(salaryViewModelProvider).requests;
    for (final sr in salaryRequests) {
      activities.add({
        'icon': Icons.attach_money,
        'title':
            '${sr.employeeFullName} — ${sr.type.name} request ${sr.status.name}',
        'date': sr.requestDate,
      });
    }

    final deposits = ref.read(depositViewModelProvider).deposits;
    for (final d in deposits) {
      activities.add({
        'icon': Icons.receipt_long,
        'title':
            '${d.employeeFullName} — ${d.type.name} deposit ${d.status.name}',
        'date': d.requestDate,
      });
    }

    final tasks = ref.read(taskViewModelProvider).tasks;
    for (final t in tasks) {
      activities.add({
        'icon': t.status == TaskStatus.completed
            ? Icons.task_alt
            : Icons.assignment,
        'title': 'Task "${t.title}" ${t.status.name}',
        'date': t.createdAt,
      });
    }

    activities.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return activities.take(8).toList();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _formatDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context)!;

    final initials =
        (currentUser.firstName.isNotEmpty && currentUser.lastName.isNotEmpty)
            ? '${currentUser.firstName[0]}${currentUser.lastName[0]}'
            : 'AD';

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${currentUser.firstName.isNotEmpty ? currentUser.firstName : l10n.admin}!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Today is ${_formatDate(DateTime.now())}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Overview',
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
                  Consumer(
                    builder: (context, ref, _) {
                      final employeeState =
                          ref.watch(employeeViewModelProvider);
                      return WFMetricCard(
                        title: l10n.totalEmployees,
                        value: '${employeeState.employees.length}',
                        icon: Icons.people,
                        color: AppTheme.primary,
                        onTap: () => context.push('/employees'),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final volunteerState =
                          ref.watch(volunteerViewModelProvider);
                      return WFMetricCard(
                        title: l10n.totalVolunteers,
                        value: '${volunteerState.volunteers.length}',
                        icon: Icons.volunteer_activism,
                        color: AppTheme.accent,
                        onTap: () => context.push('/volunteers'),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final taskState = ref.watch(taskViewModelProvider);
                      return WFMetricCard(
                        title: l10n.activeTasks,
                        value:
                            '${taskState.tasks.where((t) => t.status != TaskStatus.completed).length}',
                        icon: Icons.task,
                        color: AppTheme.secondary,
                        onTap: () => context.push('/tasks'),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final projectState = ref.watch(projectViewModelProvider);
                      return WFMetricCard(
                        title: 'Active Projects',
                        value:
                            '${projectState.projects.where((p) => p.status == ProjectStatus.active).length}',
                        icon: Icons.folder,
                        color: AppTheme.warning,
                        onTap: () => context.push('/projects'),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final pendingCount =
                          ref.watch(pendingApprovalsCountProvider);
                      return WFMetricCard(
                        title: l10n.pending,
                        value: '$pendingCount',
                        icon: Icons.pending,
                        color: AppTheme.error,
                        onTap: () => context.push('/salary-approval'),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final attendanceState =
                          ref.watch(globalAttendanceViewModelProvider);
                      return WFMetricCard(
                        title: l10n.presentToday,
                        value: '${attendanceState.presentCount}',
                        icon: Icons.check_circle,
                        color: AppTheme.success,
                        onTap: () => context.push('/attendance/overview'),
                      );
                    },
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
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.push('/create-employee'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_add,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.addEmployee,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.push('/tasks/create'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_task,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.createTask,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.push('/leave-approval'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.leaveApprovalMenu,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.push('/reports'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.reports,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.push('/wallet'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Company Wallet',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.push('/wallet-deposit'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_circle,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Record Deposit',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.push('/salary-approval'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.request_page,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Salary Approval',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.push('/deposit-history'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Deposit Approval',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final activities = _buildRecentActivities();
                  if (activities.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                'No recent activity',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activities.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Icon(
                              activity['icon'] as IconData,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            activity['title'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle:
                              Text(_timeAgo(activity['date'] as DateTime)),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Analytics',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyAttendanceTrend,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri'
                                    ];
                                    if (value.toInt() < days.length) {
                                      return Text(days[value.toInt()]);
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _isLoadingChart
                                    ? const [
                                        FlSpot(0, 0),
                                        FlSpot(1, 0),
                                        FlSpot(2, 0),
                                        FlSpot(3, 0),
                                        FlSpot(4, 0),
                                      ]
                                    : [
                                        for (int i = 0; i < 5; i++)
                                          FlSpot(i.toDouble(),
                                              _weeklyAttendanceCounts[i]),
                                      ],
                                isCurved: true,
                                color: theme.colorScheme.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
