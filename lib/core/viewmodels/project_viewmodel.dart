import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../repositories/project_repository.dart';

class ProjectState {
  final List<Project> projects;
  final Project? selectedProject;
  final bool isLoading;
  final String? error;
  final ProjectStatus? statusFilter;

  const ProjectState({
    this.projects = const [],
    this.selectedProject,
    this.isLoading = false,
    this.error,
    this.statusFilter,
  });

  ProjectState copyWith({
    List<Project>? projects,
    Project? selectedProject,
    bool? isLoading,
    String? error,
    ProjectStatus? statusFilter,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statusFilter: statusFilter,
    );
  }

  List<Project> get filteredProjects {
    if (statusFilter == null) return projects;
    return projects.where((p) => p.status == statusFilter).toList();
  }

  List<Project> get activeProjects =>
      projects.where((p) => p.status == ProjectStatus.active).toList();

  List<Project> get completedProjects =>
      projects.where((p) => p.status == ProjectStatus.completed).toList();

  List<Project> get planningProjects =>
      projects.where((p) => p.status == ProjectStatus.planning).toList();

  List<Project> get overdueProjects =>
      projects.where((p) => p.isOverdue).toList();

  Map<ProjectStatus, int> get statusCounts {
    final counts = <ProjectStatus, int>{};
    for (final status in ProjectStatus.values) {
      counts[status] = projects.where((p) => p.status == status).length;
    }
    return counts;
  }

  double get averageProgress {
    if (projects.isEmpty) return 0.0;
    return projects.map((p) => p.progress).reduce((a, b) => a + b) /
        projects.length;
  }
}

class ProjectViewModel extends StateNotifier<ProjectState> {
  final ProjectRepository _repository;
  StreamSubscription<List<Project>>? _projectsSubscription;

  ProjectViewModel(this._repository) : super(const ProjectState());

  @override
  void dispose() {
    _projectsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadProjects() async {
    if (_projectsSubscription != null && state.projects.isNotEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    _projectsSubscription?.cancel();
    _projectsSubscription = _repository.watchProjects().listen(
      (projects) {
        state = state.copyWith(
          projects: projects,
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

  Future<void> selectProject(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      final project = await _repository.getProjectById(id);
      state = state.copyWith(
        selectedProject: project,
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
    state = ProjectState(
      projects: state.projects,
      statusFilter: state.statusFilter,
    );
  }

  Future<bool> createProject(Project project) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.createProject(project);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProject(Project project) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.updateProject(project);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteProject(id);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateStatus(String id, ProjectStatus status) async {
    final project = state.projects.firstWhere((p) => p.id == id);
    return updateProject(project.copyWith(status: status));
  }

  Future<bool> updateProgress(String id, double progress) async {
    final project = state.projects.firstWhere((p) => p.id == id);
    return updateProject(project.copyWith(progress: progress));
  }

  Future<bool> addMember(String projectId, String memberId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.addMember(projectId, memberId);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> removeMember(String projectId, String memberId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.removeMember(projectId, memberId);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void setStatusFilter(ProjectStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  void clearFilters() {
    state = state.copyWith(statusFilter: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
