import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/widgets/app_drawer.dart';
import 'package:vanguard/core/models/task.dart';
import 'package:vanguard/core/theme/app_theme.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_metric_card.dart';
import 'package:vanguard/l10n/app_localizations.dart';

class SecretaryDashboardScreen extends ConsumerStatefulWidget {
  const SecretaryDashboardScreen({super.key});

  @override
  ConsumerState<SecretaryDashboardScreen> createState() =>
      _SecretaryDashboardScreenState();
}

class _SecretaryDashboardScreenState
    extends ConsumerState<SecretaryDashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(employeeViewModelProvider.notifier).loadEmployees();
      ref.read(taskViewModelProvider.notifier).loadTasks();
      ref.read(leaveViewModelProvider.notifier).loadLeaveRequests();
      ref.read(reminderViewModelProvider.notifier).loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final currentUser = ref.watch(currentUserProvider);
    final employees = ref.watch(employeeListProvider);
    final tasks = ref.watch(taskListProvider);
    final pendingLeaveCount = ref.watch(pendingLeaveCountProvider);

    final activeTasksCount =
        tasks.where((t) => t.status != TaskStatus.completed).length;

    final userName = currentUser?.firstName ?? l10n.secretary;
    final userInitials = currentUser != null
        ? '${currentUser.firstName.isNotEmpty ? currentUser.firstName[0] : ''}${currentUser.lastName.isNotEmpty ? currentUser.lastName[0] : ''}'
        : 'SE';

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.secretaryDashboard),
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
        child: RefreshIndicator(
          onRefresh: _refreshData,
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
                            userInitials,
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
                                'Welcome, $userName!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Manage workforce efficiently',
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
                Card(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  child: InkWell(
                    onTap: () => context.push('/reminders'),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.sendReminders,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                                Text(
                                  'Send notifications to employees',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.secondary,
                          ),
                        ],
                      ),
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
                    WFMetricCard(
                      title: l10n.totalEmployees,
                      value: '${employees.length}',
                      icon: Icons.people,
                      color: AppTheme.primary,
                      onTap: () => context.push('/employees'),
                    ),
                    WFMetricCard(
                      title: l10n.activeTasks,
                      value: '$activeTasksCount',
                      icon: Icons.task,
                      color: AppTheme.secondary,
                      onTap: () => context.push('/tasks'),
                    ),
                    WFMetricCard(
                      title: l10n.leaveRequests,
                      value: '$pendingLeaveCount',
                      icon: Icons.calendar_today,
                      color: AppTheme.warning,
                      subtitle: 'pending',
                      onTap: () => context.push('/leave-approval'),
                    ),
                    WFMetricCard(
                      title: l10n.activeEmployees,
                      value: '${employees.where((e) => e.isActive).length}',
                      icon: Icons.check_circle,
                      color: AppTheme.success,
                      subtitle: 'of ${employees.length}',
                      onTap: () => context.push('/attendance/overview'),
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
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    _buildQuickActionCard(
                      context,
                      l10n.viewTasks,
                      Icons.task,
                      () => context.push('/tasks'),
                    ),
                    _buildQuickActionCard(
                      context,
                      l10n.attendance,
                      Icons.schedule,
                      () => context.push('/attendance/overview'),
                    ),
                    _buildQuickActionCard(
                      context,
                      'Leave\nRequests',
                      Icons.event_available,
                      () => context.push('/leave-approval'),
                    ),
                    _buildQuickActionCard(
                      context,
                      'Company\nDeposits',
                      Icons.account_balance_wallet,
                      () => context.push('/my-deposits'),
                    ),
                    _buildQuickActionCard(
                      context,
                      'Send\nNotification',
                      Icons.campaign,
                      () => context.push('/compose-notification'),
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
                if (tasks.isEmpty)
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
                              'No tasks available',
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
                      itemCount: tasks.take(4).length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            child: Icon(
                              Icons.task,
                              color: theme.colorScheme.secondary,
                              size: 20,
                            ),
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            task.dueDate != null
                                ? 'Due: ${_formatDate(task.dueDate!)}'
                                : task.status.name.toUpperCase(),
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

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(employeeViewModelProvider.notifier).loadEmployees(),
      ref.read(taskViewModelProvider.notifier).loadTasks(),
      ref.read(leaveViewModelProvider.notifier).loadLeaveRequests(),
      ref.read(reminderViewModelProvider.notifier).loadTemplates(),
    ]);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
