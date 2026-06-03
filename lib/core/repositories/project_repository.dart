import '../models/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getAllProjects();

  Future<Project?> getProjectById(String id);

  Future<List<Project>> getProjectsByStatus(ProjectStatus status);

  Future<List<Project>> getProjectsByManager(String managerId);

  Future<List<Project>> getProjectsByMember(String memberId);

  Future<void> createProject(Project project);

  Future<void> updateProject(Project project);

  Future<void> deleteProject(String id);

  Future<void> addMember(String projectId, String memberId);

  Future<void> removeMember(String projectId, String memberId);

  Stream<List<Project>> watchProjects();
}
