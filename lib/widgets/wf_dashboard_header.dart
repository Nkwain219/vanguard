import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/constants/constants.dart';
import 'package:vanguard/core/models/notification.dart';
import 'package:vanguard/core/models/task.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';

class WFDashboardHeader extends ConsumerWidget {
  final String userName;
  final String? subtitle;
  final String? avatarUrl;

  const WFDashboardHeader({
    super.key,
    required this.userName,
    this.subtitle,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications =
        ref.watch(notificationViewModelProvider).notifications;
    final tasks = ref.watch(taskViewModelProvider).tasks;
    final userId = ref.watch(currentUserIdProvider);

    final urgentNotifications = notifications
        .where((n) =>
            !n.isRead &&
            (n.priority == NotificationPriority.high ||
                n.priority == NotificationPriority.urgent))
        .toList();

    final now = DateTime.now();
    final urgentTasks = tasks.where((t) {
      final isAssignedToMe = t.assigneeIds.contains(userId);
      if (!isAssignedToMe) return false;
      final isOverdue = t.dueDate != null &&
          t.dueDate!.isBefore(now) &&
          t.status != TaskStatus.completed &&
          t.status != TaskStatus.cancelled;
      final isHighPriority =
          t.priority == TaskPriority.high || t.priority == TaskPriority.urgent;
      return isOverdue || (isHighPriority && t.status != TaskStatus.completed);
    }).toList();

    final hasAlerts = urgentNotifications.isNotEmpty || urgentTasks.isNotEmpty;

    if (hasAlerts) {
      return _AlertsBanner(
        notifications: urgentNotifications.take(3).toList(),
        tasks: urgentTasks.take(3).toList(),
      );
    }

    return _GreetingCard(
      userName: userName,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
    );
  }
}

class _AlertsBanner extends StatelessWidget {
  final List<AppNotification> notifications;
  final List<Task> tasks;

  const _AlertsBanner({
    required this.notifications,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = <_AlertItem>[];

    for (final n in notifications) {
      items.add(_AlertItem(
        icon: n.priority == NotificationPriority.urgent
            ? Icons.warning_amber_rounded
            : Icons.notification_important,
        title: n.title,
        subtitle: n.message,
        color: n.priority == NotificationPriority.urgent
            ? AppColors.error
            : AppColors.warning,
        onTap: () => context.push('/notifications'),
      ));
    }

    for (final t in tasks) {
      final isOverdue =
          t.dueDate != null && t.dueDate!.isBefore(DateTime.now());
      items.add(_AlertItem(
        icon: isOverdue ? Icons.schedule : Icons.flag,
        title: t.title,
        subtitle: isOverdue
            ? 'Overdue — was due ${_formatDaysAgo(t.dueDate!)}'
            : 'High priority task',
        color: isOverdue ? AppColors.error : AppColors.warning,
        onTap: () => context.push('/tasks/${t.id}'),
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.error.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    color: AppColors.error,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Needs Attention',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length} item${items.length > 1 ? 's' : ''}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) => _AlertItemTile(item: item)),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  String _formatDaysAgo(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '$diff days ago';
  }
}

class _AlertItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _AlertItemTile extends StatelessWidget {
  final _AlertItem item;
  const _AlertItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(item.icon, color: item.color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String userName;
  final String? subtitle;
  final String? avatarUrl;

  const _GreetingCard({
    required this.userName,
    this.subtitle,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [AppColors.primary, const Color(0xFF1E3A5F)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.colored(AppColors.primary, opacity: 0.2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting 👋',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              children: [
                Text(
                  '${DateTime.now().day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _monthAbbr(DateTime.now().month),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}
