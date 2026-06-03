import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/task.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';
import 'package:vanguard/widgets/wf_task_card.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    Future.microtask(
        () => ref.read(taskViewModelProvider.notifier).loadTasks());
  }

  List<Task> get _filteredTasks {
    final tasks = ref.watch(taskListProvider);
    if (_searchQuery.isEmpty) return tasks;
    return tasks.where((task) {
      return task.title.toLowerCase().contains(_searchQuery) ||
          task.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<Task> _getTasksByStatus(TaskStatus status) {
    return _filteredTasks.where((task) => task.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = ref.watch(currentRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          if (currentRole.canManageEmployees)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/tasks/create'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All',
              icon: Badge(
                label: Text('${_filteredTasks.length}'),
                child: const Icon(Icons.list),
              ),
            ),
            Tab(
              text: 'Pending',
              icon: Badge(
                label: Text('${_getTasksByStatus(TaskStatus.pending).length}'),
                child: const Icon(Icons.pending),
              ),
            ),
            Tab(
              text: 'In Progress',
              icon: Badge(
                label:
                    Text('${_getTasksByStatus(TaskStatus.inProgress).length}'),
                child: const Icon(Icons.hourglass_empty),
              ),
            ),
            Tab(
              text: 'Completed',
              icon: Badge(
                label:
                    Text('${_getTasksByStatus(TaskStatus.completed).length}'),
                child: const Icon(Icons.check_circle),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(_filteredTasks),
          _buildTaskList(_getTasksByStatus(TaskStatus.pending)),
          _buildTaskList(_getTasksByStatus(TaskStatus.inProgress)),
          _buildTaskList(_getTasksByStatus(TaskStatus.completed)),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const WFEmptyState(
        icon: Icons.task,
        title: 'No tasks found',
        message: 'There are no tasks matching your criteria.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final employees = ref.watch(employeeListProvider);
        final assigneeNames = task.assigneeIds.map((id) {
          if (employees.isEmpty) return 'Unknown';
          try {
            return employees.firstWhere((e) => e.id == id).fullName;
          } catch (_) {
            return 'Unknown';
          }
        }).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WFTaskCard(
            task: task,
            assigneeNames: assigneeNames,
            onTap: () => context.push('/tasks/${task.id}'),
          ),
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter task title or description...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
