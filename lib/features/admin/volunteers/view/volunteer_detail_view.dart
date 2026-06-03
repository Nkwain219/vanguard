import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/volunteer.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';

class VolunteerDetailScreen extends ConsumerStatefulWidget {
  final String volunteerId;

  const VolunteerDetailScreen({super.key, required this.volunteerId});

  @override
  ConsumerState<VolunteerDetailScreen> createState() =>
      _VolunteerDetailScreenState();
}

class _VolunteerDetailScreenState extends ConsumerState<VolunteerDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(volunteerViewModelProvider.notifier)
          .selectVolunteer(widget.volunteerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final volunteerState = ref.watch(volunteerViewModelProvider);
    final volunteer = volunteerState.selectedVolunteer;

    if (volunteerState.isLoading && volunteer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Volunteer Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (volunteer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Volunteer Details')),
        body: const Center(child: Text('Volunteer not found')),
      );
    }

    final initials =
        '${volunteer.firstName.isNotEmpty ? volunteer.firstName[0] : ''}${volunteer.lastName.isNotEmpty ? volunteer.lastName[0] : ''}'
            .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(volunteer.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit-volunteer/${volunteer.id}'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_status') {
                _showToggleStatusDialog(volunteer);
              } else if (value == 'delete') {
                _showDeleteDialog(volunteer);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                        volunteer.isActive
                            ? Icons.block
                            : Icons.check_circle_outline,
                        size: 18),
                    const SizedBox(width: 8),
                    Text(volunteer.isActive ? 'Deactivate' : 'Activate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: volunteer.isActive
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      backgroundImage: volunteer.profileImageUrl != null
                          ? NetworkImage(volunteer.profileImageUrl!)
                          : null,
                      child: volunteer.profileImageUrl == null
                          ? Text(
                              initials,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volunteer.fullName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${volunteer.department} · ${volunteer.position}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: volunteer.isActive
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              volunteer.isActive ? 'Active' : 'Inactive',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: volunteer.isActive
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Contact Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _buildInfoRow(Icons.email, 'Email', volunteer.email),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.phone, 'Phone', volunteer.phone),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.badge, 'ID Card', volunteer.idCard),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Work Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _buildInfoRow(
                      Icons.business, 'Department', volunteer.department),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.work, 'Position', volunteer.position),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.calendar_today, 'Join Date',
                      _formatDate(volunteer.joinDate)),
                  if (volunteer.stipend != null) ...[
                    const Divider(height: 1),
                    _buildInfoRow(Icons.attach_money, 'Stipend',
                        '${volunteer.stipend} XAF/month'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showToggleStatusDialog(Volunteer volunteer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            volunteer.isActive ? 'Deactivate Volunteer' : 'Activate Volunteer'),
        content: Text(
          volunteer.isActive
              ? 'Are you sure you want to deactivate ${volunteer.fullName}?'
              : 'Are you sure you want to activate ${volunteer.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(volunteerViewModelProvider.notifier)
                  .toggleStatus(volunteer.id, !volunteer.isActive);

              ref
                  .read(volunteerViewModelProvider.notifier)
                  .selectVolunteer(volunteer.id);
            },
            child: Text(volunteer.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Volunteer volunteer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Volunteer'),
        content: Text(
            'Are you sure you want to permanently delete ${volunteer.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(volunteerViewModelProvider.notifier)
                  .deleteVolunteer(volunteer.id);
              if (success && mounted) {
                context.pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
