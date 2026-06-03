import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/volunteer.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';

class VolunteerListScreen extends ConsumerStatefulWidget {
  const VolunteerListScreen({super.key});

  @override
  ConsumerState<VolunteerListScreen> createState() =>
      _VolunteerListScreenState();
}

class _VolunteerListScreenState extends ConsumerState<VolunteerListScreen> {
  final _searchController = TextEditingController();
  String _sortBy = 'name';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(volunteerViewModelProvider.notifier)
          .loadVolunteers(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Volunteer> _getSortedVolunteers(List<Volunteer> volunteers) {
    var filtered = _showActiveOnly
        ? volunteers.where((v) => v.isActive).toList()
        : volunteers;

    switch (_sortBy) {
      case 'department':
        filtered.sort((a, b) => a.department.compareTo(b.department));
        break;
      case 'joinDate':
        filtered.sort((a, b) => b.joinDate.compareTo(a.joinDate));
        break;
      default:
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final volunteerState = ref.watch(volunteerViewModelProvider);

    if (_searchController.text.isNotEmpty) {
      ref
          .read(volunteerViewModelProvider.notifier)
          .setSearchQuery(_searchController.text);
    }

    final displayVolunteers =
        _getSortedVolunteers(volunteerState.filteredVolunteers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteers'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                        _sortBy == 'name'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18),
                    const SizedBox(width: 8),
                    const Text('Name'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'department',
                child: Row(
                  children: [
                    Icon(
                        _sortBy == 'department'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18),
                    const SizedBox(width: 8),
                    const Text('Department'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'joinDate',
                child: Row(
                  children: [
                    Icon(
                        _sortBy == 'joinDate'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18),
                    const SizedBox(width: 8),
                    const Text('Join Date'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
                _showActiveOnly ? Icons.filter_alt : Icons.filter_alt_outlined),
            tooltip: _showActiveOnly ? 'Show all' : 'Active only',
            onPressed: () => setState(() => _showActiveOnly = !_showActiveOnly),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                ref
                    .read(volunteerViewModelProvider.notifier)
                    .setSearchQuery(query);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search volunteers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(volunteerViewModelProvider.notifier)
                              .clearFilters();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${displayVolunteers.length} volunteer${displayVolunteers.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '${volunteerState.activeCount} active',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: volunteerState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayVolunteers.isEmpty
                    ? const WFEmptyState(
                        icon: Icons.volunteer_activism,
                        title: 'No volunteers found',
                        message: 'Add your first volunteer to get started.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(volunteerViewModelProvider.notifier)
                            .loadVolunteers(forceRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: displayVolunteers.length,
                          itemBuilder: (context, index) {
                            final volunteer = displayVolunteers[index];
                            return _VolunteerCard(
                              volunteer: volunteer,
                              onTap: () =>
                                  context.push('/volunteer/${volunteer.id}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-volunteer'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Volunteer'),
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  final Volunteer volunteer;
  final VoidCallback onTap;

  const _VolunteerCard({required this.volunteer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials =
        '${volunteer.firstName.isNotEmpty ? volunteer.firstName[0] : ''}${volunteer.lastName.isNotEmpty ? volunteer.lastName[0] : ''}'
            .toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: volunteer.isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          child: Text(
            initials,
            style: TextStyle(
              color: volunteer.isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          volunteer.fullName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${volunteer.department} · ${volunteer.position}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: volunteer.isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                volunteer.isActive ? 'Active' : 'Inactive',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: volunteer.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
