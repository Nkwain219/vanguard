import '../models/task.dart';

abstract class TaskRepository {
  String generateId();

  Future<List<Task>> getAllTasks();

  Future<Task?> getTaskById(String id);

  Future<List<Task>> getTasksByProject(String projectId);

  Future<List<Task>> getTasksByAssignee(String userId);

  Future<List<Task>> getTasksByCreator(String userId);

  Future<List<Task>> getTasksByStatus(TaskStatus status);

  Future<void> createTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String id);

  Future<void> updateTaskStatus(String id, TaskStatus status);

  Future<void> updateTaskProgress(String id, double progress);

  Future<void> addComment(String taskId, TaskComment comment);

  Stream<List<Task>> watchTasks();

  Stream<List<Task>> watchTasksByProject(String projectId);
}
