import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/notification.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';

class ComposeNotificationScreen extends ConsumerStatefulWidget {
  const ComposeNotificationScreen({super.key});

  @override
  ConsumerState<ComposeNotificationScreen> createState() =>
      _ComposeNotificationScreenState();
}

class _ComposeNotificationScreenState
    extends ConsumerState<ComposeNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  NotificationType _type = NotificationType.info;
  NotificationPriority _priority = NotificationPriority.normal;
  TargetAudience _audience = TargetAudience.all;
  final List<String> _selectedUserIds = [];
  final List<String> _selectedUserNames = [];
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: _isSending ? null : _send,
              icon: _isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, size: 18),
              label: const Text('Send'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_priority == NotificationPriority.urgent)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Urgent notifications will trigger high-priority push alerts on all recipient devices.',
                          style: TextStyle(fontSize: 13, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Staff Meeting Tomorrow',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message',
                  hintText: 'Write your notification message...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.message),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Message is required'
                    : null,
              ),
              const SizedBox(height: 24),
              Text('Type',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: NotificationType.values.map((t) {
                  final isSelected = _type == t;
                  return ChoiceChip(
                    label: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _type = t),
                    avatar: Icon(_getTypeIcon(t), size: 18),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Priority',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<NotificationPriority>(
                segments: const [
                  ButtonSegment(
                      value: NotificationPriority.normal,
                      label: Text('Normal'),
                      icon: Icon(Icons.flag_outlined)),
                  ButtonSegment(
                      value: NotificationPriority.high,
                      label: Text('High'),
                      icon: Icon(Icons.flag, color: Colors.orange)),
                  ButtonSegment(
                      value: NotificationPriority.urgent,
                      label: Text('Urgent'),
                      icon: Icon(Icons.priority_high, color: Colors.red)),
                ],
                selected: {_priority},
                onSelectionChanged: (v) => setState(() => _priority = v.first),
              ),
              const SizedBox(height: 24),
              Text('Send To',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    _audienceTile(TargetAudience.all, 'All Users', Icons.groups,
                        'Send to everyone in the organization'),
                    const Divider(height: 1),
                    _audienceTile(TargetAudience.employees, 'All Employees',
                        Icons.badge, 'Send to all employees'),
                    const Divider(height: 1),
                    _audienceTile(TargetAudience.volunteers, 'All Volunteers',
                        Icons.volunteer_activism, 'Send to all volunteers'),
                    const Divider(height: 1),
                    _audienceTile(TargetAudience.custom, 'Specific People',
                        Icons.person_search, 'Choose individual recipients'),
                  ],
                ),
              ),
              if (_audience == TargetAudience.custom) ...[
                const SizedBox(height: 12),
                if (_selectedUserNames.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_selectedUserNames.length, (i) {
                      return Chip(
                        label: Text(_selectedUserNames[i]),
                        onDeleted: () {
                          setState(() {
                            _selectedUserIds.removeAt(i);
                            _selectedUserNames.removeAt(i);
                          });
                        },
                      );
                    }),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _showUserPicker,
                  icon: const Icon(Icons.person_add),
                  label: Text(_selectedUserIds.isEmpty
                      ? 'Select People'
                      : 'Add More People'),
                ),
              ],
              const SizedBox(height: 32),
              Text('Preview',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _getTypeColor(_type).withValues(alpha: 0.1),
                    child:
                        Icon(_getTypeIcon(_type), color: _getTypeColor(_type)),
                  ),
                  title: Text(
                    _titleController.text.isEmpty
                        ? 'Notification title'
                        : _titleController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _messageController.text.isEmpty
                        ? 'Notification message preview...'
                        : _messageController.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: _priority == NotificationPriority.urgent
                      ? const Icon(Icons.priority_high, color: Colors.red)
                      : _priority == NotificationPriority.high
                          ? const Icon(Icons.flag, color: Colors.orange)
                          : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _audienceTile(
      TargetAudience audience, String title, IconData icon, String subtitle) {
    final isSelected = _audience == audience;
    return RadioListTile<TargetAudience>(
      value: audience,
      groupValue: _audience,
      onChanged: (v) => setState(() {
        _audience = v!;
        if (v != TargetAudience.custom) {
          _selectedUserIds.clear();
          _selectedUserNames.clear();
        }
      }),
      title: Row(
        children: [
          Icon(icon,
              size: 20,
              color: isSelected ? Theme.of(context).colorScheme.primary : null),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }

  void _showUserPicker() {
    final employees = ref.read(employeeViewModelProvider).employees;
    final volunteers = ref.read(volunteerViewModelProvider).volunteers;

    final allUsers = <_UserOption>[];
    for (final e in employees) {
      allUsers.add(_UserOption(
          id: e.id, name: '${e.firstName} ${e.lastName}', role: 'Employee'));
    }
    for (final v in volunteers) {
      allUsers.add(_UserOption(
          id: v.id, name: '${v.firstName} ${v.lastName}', role: 'Volunteer'));
    }

    final tempSelected = Set<String>.from(_selectedUserIds);
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = allUsers
              .where((u) =>
                  u.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  u.role.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder: (ctx, scrollController) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Select Recipients (${tempSelected.length})',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedUserIds.clear();
                            _selectedUserIds.addAll(tempSelected);
                            _selectedUserNames.clear();
                            for (final id in tempSelected) {
                              final user = allUsers.firstWhere(
                                  (u) => u.id == id,
                                  orElse: () =>
                                      _UserOption(id: id, name: id, role: ''));
                              _selectedUserNames.add(user.name);
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search people...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                    onChanged: (v) => setModalState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final user = filtered[i];
                      final isChecked = tempSelected.contains(user.id);
                      return CheckboxListTile(
                        value: isChecked,
                        onChanged: (v) {
                          setModalState(() {
                            if (v == true) {
                              tempSelected.add(user.id);
                            } else {
                              tempSelected.remove(user.id);
                            }
                          });
                        },
                        title: Text(user.name),
                        subtitle: Text(user.role),
                        secondary: CircleAvatar(
                          child: Text(user.name[0].toUpperCase()),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (_audience == TargetAudience.custom && _selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one recipient')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      await ref.read(notificationViewModelProvider.notifier).sendNotification(
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            type: _type,
            priority: _priority,
            targetAudience: _audience,
            recipientIds: _selectedUserIds,
            senderId: currentUser.id,
            senderName: '${currentUser.firstName} ${currentUser.lastName}',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification sent to ${_getAudienceLabel()}'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getAudienceLabel() {
    switch (_audience) {
      case TargetAudience.all:
        return 'all users';
      case TargetAudience.employees:
        return 'all employees';
      case TargetAudience.volunteers:
        return 'all volunteers';
      case TargetAudience.admins:
        return 'all admins';
      case TargetAudience.secretaries:
        return 'all secretaries';
      case TargetAudience.custom:
        return '${_selectedUserIds.length} people';
    }
  }

  IconData _getTypeIcon(NotificationType type) {
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

  Color _getTypeColor(NotificationType type) {
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
}

class _UserOption {
  final String id;
  final String name;
  final String role;
  _UserOption({required this.id, required this.name, required this.role});
}
