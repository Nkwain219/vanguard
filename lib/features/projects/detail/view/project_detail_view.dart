import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/project.dart';
import 'package:vanguard/core/constants/constants.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_status_chip.dart';
import 'package:vanguard/widgets/wf_task_card.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    final projectState = ref.watch(projectViewModelProvider);
    final employeeState = ref.watch(employeeViewModelProvider);
    final taskState = ref.watch(taskViewModelProvider);

    final project = projectState.projects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => projectState.projects.isNotEmpty
          ? projectState.projects.first
          : Project(
              id: 'placeholder',
              name: 'Loading...',
              description: '',
              status: ProjectStatus.planning,
              startDate: DateTime.now(),
              createdAt: DateTime.now(),
              memberIds: [],
              taskIds: [],
              managerId: '',
            ),
    );

    final projectTasks = taskState.tasks
        .where(
            (t) => t.projectId == projectId || project.taskIds.contains(t.id))
        .toList();

    final members = employeeState.employees
        .where((e) => project.memberIds.contains(e.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          if (user?.role.canManageEmployees ?? false)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/projects/edit/$projectId'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manager: ${_getManagerName(employeeState.employees, project.managerId)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                WFStatusBadge(
                  label: project.statusLabel,
                  color: _getStatusColor(project.status),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Tasks',
                    '${projectTasks.length}',
                    Icons.task,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Members',
                    '${members.length}',
                    Icons.people,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Days Left',
                    '${project.daysRemaining ?? "-"}',
                    Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.role.canManageEmployees ?? false)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Task'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (projectTasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No tasks linked to this project'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projectTasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = projectTasks[index];

                  return WFTaskCard(
                    task: task,
                    onTap: () => context.push('/tasks/${task.id}'),
                    assigneeNames: const [],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return AppColors.info;
      case ProjectStatus.active:
        return AppColors.success;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.completed:
        return AppColors.secondary;
      case ProjectStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getManagerName(List<dynamic> employees, String managerId) {
    if (employees.isEmpty) return 'Unassigned';
    try {
      final manager = employees.firstWhere((e) => e.id == managerId);
      return manager.fullName;
    } catch (_) {
      return 'Unassigned';
    }
  }

  Widget _buildStatCard(
      ThemeData theme, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
