import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskFilter {
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? projectId;
  final String? assigneeId;
  final String? searchQuery;

  const TaskFilter({
    this.status,
    this.priority,
    this.projectId,
    this.assigneeId,
    this.searchQuery,
  });

  TaskFilter copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? assigneeId,
    String? searchQuery,
  }) {
    return TaskFilter(
      status: status,
      priority: priority,
      projectId: projectId,
      assigneeId: assigneeId,
      searchQuery: searchQuery,
    );
  }

  bool get hasFilters =>
      status != null ||
      priority != null ||
      projectId != null ||
      assigneeId != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

class TaskState {
  final List<Task> tasks;
  final Task? selectedTask;
  final bool isLoading;
  final String? error;
  final TaskFilter filter;

  const TaskState({
    this.tasks = const [],
    this.selectedTask,
    this.isLoading = false,
    this.error,
    this.filter = const TaskFilter(),
  });

  TaskState copyWith({
    List<Task>? tasks,
    Task? selectedTask,
    bool? isLoading,
    String? error,
    TaskFilter? filter,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }

  List<Task> get filteredTasks {
    var result = tasks;

    if (filter.status != null) {
      result = result.where((t) => t.status == filter.status).toList();
    }

    if (filter.priority != null) {
      result = result.where((t) => t.priority == filter.priority).toList();
    }

    if (filter.projectId != null) {
      result = result.where((t) => t.projectId == filter.projectId).toList();
    }

    if (filter.assigneeId != null) {
      result = result
          .where((t) => t.assigneeIds.contains(filter.assigneeId))
          .toList();
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  List<Task> get pendingTasks =>
      tasks.where((t) => t.status == TaskStatus.pending).toList();
  List<Task> get inProgressTasks =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<Task> get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.completed).toList();

  List<Task> get urgentTasks =>
      tasks.where((t) => t.priority == TaskPriority.urgent).toList();

  List<Task> get overdueTasks => tasks.where((t) {
        if (t.dueDate == null) return false;
        return DateTime.now().isAfter(t.dueDate!) &&
            t.status != TaskStatus.completed;
      }).toList();

  Map<TaskStatus, int> get statusCounts {
    final counts = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      counts[status] = tasks.where((t) => t.status == status).length;
    }
    return counts;
  }
}

class TaskViewModel extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  StreamSubscription<List<Task>>? _tasksSubscription;

  TaskViewModel(this._repository) : super(const TaskState());

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }

  String generateTaskId() {
    return _repository.generateId();
  }

  Future<void> loadTasks() async {
    if (_tasksSubscription != null && state.tasks.isNotEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    _tasksSubscription?.cancel();
    _tasksSubscription = _repository.watchTasks().listen(
      (tasks) {
        state = state.copyWith(
          tasks: tasks,
          isLoading: false,
        );
      },
      onError: (e) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      },
    );
  }

  Future<void> loadTasksByProject(String projectId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tasks = await _repository.getTasksByProject(projectId);
      state = state.copyWith(
        tasks: tasks,
        isLoading: false,
        filter: state.filter.copyWith(projectId: projectId),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTasksByAssignee(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tasks = await _repository.getTasksByAssignee(userId);
      state = state.copyWith(
        tasks: tasks,
        isLoading: false,
        filter: state.filter.copyWith(assigneeId: userId),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectTask(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      final task = await _repository.getTaskById(id);
      state = state.copyWith(
        selectedTask: task,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSelection() {
    state = TaskState(
      tasks: state.tasks,
      filter: state.filter,
    );
  }

  Future<bool> createTask(Task task) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.createTask(task);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.updateTask(task);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteTask(id);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateStatus(String id, TaskStatus status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.updateTaskStatus(id, status);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProgress(String id, double progress) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.updateTaskProgress(id, progress);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> addComment(String taskId, TaskComment comment) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.addComment(taskId, comment);
      await selectTask(taskId);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setStatusFilter(TaskStatus? status) {
    state = state.copyWith(filter: state.filter.copyWith(status: status));
  }

  void setPriorityFilter(TaskPriority? priority) {
    state = state.copyWith(filter: state.filter.copyWith(priority: priority));
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(filter: state.filter.copyWith(searchQuery: query));
  }

  void clearFilters() {
    state = state.copyWith(filter: const TaskFilter());
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
