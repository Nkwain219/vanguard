import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanguard/core/models/notification.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Unread',
    'Info',
    'Warning',
    'Success',
    'Error',
    'Reminder'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationViewModelProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationState = ref.watch(notificationViewModelProvider);
    final notifications = notificationState.notifications;
    final filteredNotifications = _getFilteredNotifications(notifications);
    final unreadCount = notificationState.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => _markAllAsRead(),
              child: const Text('Mark all as read'),
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_read',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear read notifications'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Notification settings'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'clear_read':
                  _clearReadNotifications(notifications);
                  break;
                case 'settings':
                  _showNotificationSettings();
                  break;
              }
            },
          ),
        ],
      ),
      body: notificationState.isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You have $unreadCount unread notifications',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                'Stay updated with the latest information',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      final count = _getFilterCount(filter, notifications);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(count > 0 ? '$filter ($count)' : filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (notificationState.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                notificationState.error!,
                                style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: filteredNotifications.isEmpty
                      ? WFEmptyState(
                          icon: Icons.notifications_none,
                          title: 'No notifications',
                          message: _selectedFilter == 'All'
                              ? 'You\'re all caught up!'
                              : 'No ${_selectedFilter.toLowerCase()} notifications found.',
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(notificationViewModelProvider.notifier)
                              .loadNotifications(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = filteredNotifications[index];
                              return _buildNotificationCard(
                                  notification, theme);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, ThemeData theme) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(notification),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: notification.isRead
            ? null
            : theme.colorScheme.primary.withValues(alpha: 0.03),
        child: InkWell(
          onTap: () => _openNotification(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (notification.priority ==
                              NotificationPriority.high)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'HIGH',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (notification.priority ==
                              NotificationPriority.urgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (!notification.isRead)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            _formatNotificationTime(notification.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (notification.senderName != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• from ${notification.senderName}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<AppNotification> _getFilteredNotifications(
      List<AppNotification> notifications) {
    switch (_selectedFilter) {
      case 'All':
        return notifications;
      case 'Unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'Info':
        return notifications
            .where((n) => n.type == NotificationType.info)
            .toList();
      case 'Warning':
        return notifications
            .where((n) => n.type == NotificationType.warning)
            .toList();
      case 'Success':
        return notifications
            .where((n) => n.type == NotificationType.success)
            .toList();
      case 'Error':
        return notifications
            .where((n) => n.type == NotificationType.error)
            .toList();
      case 'Reminder':
        return notifications
            .where((n) => n.type == NotificationType.reminder)
            .toList();
      default:
        return notifications;
    }
  }

  int _getFilterCount(String filter, List<AppNotification> notifications) {
    switch (filter) {
      case 'All':
        return notifications.length;
      case 'Unread':
        return notifications.where((n) => !n.isRead).length;
      case 'Info':
        return notifications
            .where((n) => n.type == NotificationType.info)
            .length;
      case 'Warning':
        return notifications
            .where((n) => n.type == NotificationType.warning)
            .length;
      case 'Success':
        return notifications
            .where((n) => n.type == NotificationType.success)
            .length;
      case 'Error':
        return notifications
            .where((n) => n.type == NotificationType.error)
            .length;
      case 'Reminder':
        return notifications
            .where((n) => n.type == NotificationType.reminder)
            .length;
      default:
        return 0;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.reminder:
        return Colors.purple;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.reminder:
        return Icons.notifications;
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _openNotification(AppNotification notification) {
    if (!notification.isRead) {
      ref
          .read(notificationViewModelProvider.notifier)
          .markAsRead(notification.id);
    }
    if (notification.actionUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening ${notification.actionUrl}')),
      );
    }
  }

  Future<bool> _confirmDelete(AppNotification notification) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content:
            const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (result == true) {
      ref
          .read(notificationViewModelProvider.notifier)
          .deleteNotification(notification.id);
    }
    return result ?? false;
  }

  void _markAllAsRead() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text('Mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notificationViewModelProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                    content: Text('All notifications marked as read')),
              );
            },
            child: const Text('Mark All'),
          ),
        ],
      ),
    );
  }

  void _clearReadNotifications(List<AppNotification> notifications) {
    final readNotifications = notifications.where((n) => n.isRead).toList();
    if (readNotifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No read notifications to clear')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Read Notifications'),
        content: Text('Delete ${readNotifications.length} read notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              for (final n in readNotifications) {
                ref
                    .read(notificationViewModelProvider.notifier)
                    .deleteNotification(n.id);
              }
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Read notifications cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications on this device'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Task Reminders'),
              subtitle: const Text('Get reminded about pending tasks'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Leave Approvals'),
              subtitle: const Text('Notifications for leave requests'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Salary Updates'),
              subtitle: const Text('Updates about salary and payments'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}
