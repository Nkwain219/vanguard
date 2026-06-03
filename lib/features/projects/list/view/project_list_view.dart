import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/project.dart';
import 'package:vanguard/core/constants/constants.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_status_chip.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    Future.microtask(
        () => ref.read(projectViewModelProvider.notifier).loadProjects());
  }

  List<Project> _getFilteredProjects() {
    final projects = ref.watch(projectViewModelProvider).projects;
    if (_searchQuery.isEmpty) return projects;
    return projects.where((project) {
      return project.name.toLowerCase().contains(_searchQuery) ||
          project.description.toLowerCase().contains(_searchQuery);
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          if (user?.role.canManageEmployees ?? false)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/projects/create'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _getFilteredProjects().isEmpty
                ? const WFEmptyState(
                    icon: Icons.folder_off,
                    title: 'No projects found',
                    message: 'Try adjusting your search terms',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _getFilteredProjects().length,
                    itemBuilder: (context, index) {
                      final project = _getFilteredProjects()[index];
                      return _buildProjectCard(theme, project);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ThemeData theme, Project project) {
    final statusColor = _getStatusColor(project.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/projects/${project.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  WFStatusBadge(
                    label: project.statusLabel,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${_formatDate(project.endDate)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  const Icon(Icons.people_outline,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${project.memberIds.length} members',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${(project.progress * 100).toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: project.progress,
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No deadline';
    return '${date.day}/${date.month}/${date.year}';
  }
}
