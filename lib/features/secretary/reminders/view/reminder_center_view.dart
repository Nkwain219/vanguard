import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';
import 'package:vanguard/core/models/reminder.dart';

class SecretaryReminderCenterScreen extends ConsumerStatefulWidget {
  const SecretaryReminderCenterScreen({super.key});

  @override
  ConsumerState<SecretaryReminderCenterScreen> createState() =>
      _SecretaryReminderCenterScreenState();
}

class _SecretaryReminderCenterScreenState
    extends ConsumerState<SecretaryReminderCenterScreen> {
  final List<String> _selectedEmployees = [];
  final List<String> _selectedTemplates = [];
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Attendance',
    'Tasks',
    'Leave',
    'Documents',
    'Meetings',
    'Payroll',
    'Training',
    'Equipment',
    'HR',
    'Safety'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reminderViewModelProvider.notifier).loadTemplates();
      ref.read(employeeViewModelProvider.notifier).loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminderState = ref.watch(reminderViewModelProvider);
    final filteredTemplates = _getFilteredTemplates(reminderState.templates);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Center'),
        actions: [
          if (reminderState.isLoading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 24, height: 24, child: CircularProgressIndicator()),
            )),
          IconButton(
            icon: Badge(
              label: Text('${_selectedTemplates.length}'),
              isLabelVisible: _selectedTemplates.isNotEmpty,
              child: const Icon(Icons.checklist),
            ),
            onPressed: _selectedTemplates.isNotEmpty
                ? () => _showSelectedTemplates(reminderState.templates)
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (_selectedTemplates.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.send,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Send Reminders',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_selectedTemplates.length} selected',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectEmployees,
                          icon: const Icon(Icons.people),
                          label: Text(_selectedEmployees.isEmpty
                              ? 'Select Employees'
                              : '${_selectedEmployees.length} employees'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectedEmployees.isNotEmpty
                              ? () => _sendReminders(reminderState.templates)
                              : null,
                          icon: const Icon(Icons.send),
                          label: const Text('Send'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredTemplates.isEmpty
                ? const WFEmptyState(
                    icon: Icons.notifications,
                    title: 'No templates found',
                    message: 'No reminder templates match your filter.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = filteredTemplates[index];
                      final isSelected =
                          _selectedTemplates.contains(template.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedTemplates.add(template.id);
                              } else {
                                _selectedTemplates.remove(template.id);
                              }
                            });
                          },
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(template.category)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getCategoryIcon(template.category),
                                  size: 16,
                                  color: _getCategoryColor(template.category),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      template.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      template.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getCategoryColor(
                                            template.category),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 34),
                            child: Text(
                              template.message,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          secondary: IconButton(
                            icon: const Icon(Icons.preview),
                            onPressed: () => _previewTemplate(template),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedTemplates.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _sendQuickReminder(reminderState.templates),
              icon: const Icon(Icons.flash_on),
              label: const Text('Quick Send'),
            )
          : null,
    );
  }

  List<ReminderTemplate> _getFilteredTemplates(
      List<ReminderTemplate> templates) {
    if (_selectedCategory == 'All') {
      return templates;
    }
    return templates.where((template) {
      return template.category == _selectedCategory;
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Attendance':
        return Colors.blue;
      case 'Tasks':
        return Colors.green;
      case 'Leave':
        return Colors.orange;
      case 'Documents':
        return Colors.purple;
      case 'Meetings':
        return Colors.red;
      case 'Payroll':
        return Colors.teal;
      case 'Training':
        return Colors.indigo;
      case 'Equipment':
        return Colors.brown;
      case 'HR':
        return Colors.pink;
      case 'Safety':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Attendance':
        return Icons.schedule;
      case 'Tasks':
        return Icons.task;
      case 'Leave':
        return Icons.event_available;
      case 'Documents':
        return Icons.description;
      case 'Meetings':
        return Icons.meeting_room;
      case 'Payroll':
        return Icons.payments;
      case 'Training':
        return Icons.school;
      case 'Equipment':
        return Icons.devices;
      case 'HR':
        return Icons.people;
      case 'Safety':
        return Icons.security;
      default:
        return Icons.notification_important;
    }
  }

  void _selectEmployees() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Employees'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final employees =
                              ref.read(employeeViewModelProvider).employees;
                          setDialogState(() {
                            _selectedEmployees.clear();
                            _selectedEmployees
                                .addAll(employees.map((e) => e.id));
                          });
                          setState(() {});
                        },
                        child: const Text('Select All'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setDialogState(() {
                            _selectedEmployees.clear();
                          });
                          setState(() {});
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        ref.watch(employeeViewModelProvider).employees.length,
                    itemBuilder: (context, index) {
                      final employees =
                          ref.watch(employeeViewModelProvider).employees;
                      if (employees.isEmpty) return const SizedBox.shrink();
                      final employee = employees[index];
                      final isSelected =
                          _selectedEmployees.contains(employee.id);

                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(employee.fullName),
                        subtitle: Text(
                            '${employee.position} • ${employee.department}'),
                        onChanged: (selected) {
                          setDialogState(() {
                            if (selected == true) {
                              _selectedEmployees.add(employee.id);
                            } else {
                              _selectedEmployees.remove(employee.id);
                            }
                          });
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _previewTemplate(ReminderTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getCategoryIcon(template.category)),
            const SizedBox(width: 8),
            Expanded(child: Text(template.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    _getCategoryColor(template.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                template.category,
                style: TextStyle(
                  fontSize: 12,
                  color: _getCategoryColor(template.category),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Message Preview:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(template.message),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (!_selectedTemplates.contains(template.id)) {
                  _selectedTemplates.add(template.id);
                }
              });
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _showSelectedTemplates(List<ReminderTemplate> allTemplates) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Templates (${_selectedTemplates.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedTemplates.length,
                  itemBuilder: (context, index) {
                    final templateId = _selectedTemplates[index];
                    final template = allTemplates.firstWhere(
                      (t) => t.id == templateId,
                      orElse: () => const ReminderTemplate(
                          id: '',
                          title: 'Unknown',
                          category: 'Other',
                          message: ''),
                    );

                    return ListTile(
                      leading: Icon(_getCategoryIcon(template.category)),
                      title: Text(template.title),
                      subtitle: Text(template.category),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            _selectedTemplates.remove(templateId);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendReminders(List<ReminderTemplate> allTemplates) async {
    if (_selectedEmployees.isEmpty || _selectedTemplates.isEmpty) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Reminders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Send ${_selectedTemplates.length} reminders to ${_selectedEmployees.length} employees?'),
            const SizedBox(height: 16),
            const Row(
              children: [
                Checkbox(value: true, onChanged: null),
                Text('In-app Notification'),
              ],
            ),
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                Text('Email (coming soon)',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return;

      int sentCount = 0;
      final currentUser = ref.read(currentUserProvider);

      for (final templateId in _selectedTemplates) {
        final template = allTemplates.firstWhere((t) => t.id == templateId,
            orElse: () => const ReminderTemplate(
                id: '', title: 'Unknown', category: 'Other', message: ''));
        if (template.id.isEmpty) continue;

        await ref.read(reminderViewModelProvider.notifier).sendReminder(
              title: template.title,
              message: template.message,
              category: template.category,
              recipientIds: _selectedEmployees,
              senderId: currentUser.id,
            );
        sentCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$sentCount reminder types sent to ${_selectedEmployees.length} employees!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedTemplates.clear();
          _selectedEmployees.clear();
        });
      }
    }
  }

  void _sendQuickReminder(List<ReminderTemplate> allTemplates) {
    if (_selectedTemplates.isEmpty) return;

    setState(() {
      final employees = ref.read(employeeViewModelProvider).employees;
      _selectedEmployees.clear();
      _selectedEmployees.addAll(employees.map((e) => e.id));
    });

    _sendReminders(allTemplates);
  }
}
