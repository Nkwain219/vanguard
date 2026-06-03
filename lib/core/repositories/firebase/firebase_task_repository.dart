import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task.dart';
import '../../services/firestore_service.dart';
import '../task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.tasksCollection;

  @override
  String generateId() => _collection.doc().id;

  @override
  Future<List<Task>> getAllTasks() async {
    final snapshot =
        await _collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Task.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<Task>> getTasksByProject(String projectId) async {
    final snapshot = await _collection
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Task>> getTasksByAssignee(String userId) async {
    final snapshot =
        await _collection.where('assigneeIds', arrayContains: userId).get();
    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Task>> getTasksByCreator(String userId) async {
    final snapshot = await _collection
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final snapshot =
        await _collection.where('status', isEqualTo: status.name).get();
    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }

  @override
  Future<void> createTask(Task task) async {
    await _collection.doc(task.id).set(task.toJson());
  }

  @override
  Future<void> updateTask(Task task) async {
    await _collection.doc(task.id).update(task.toJson());
  }

  @override
  Future<void> deleteTask(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    await _collection.doc(id).update({'status': status.name});
  }

  @override
  Future<void> updateTaskProgress(String id, double progress) async {
    await _collection.doc(id).update({'progress': progress});
  }

  @override
  Future<void> addComment(String taskId, TaskComment comment) async {
    await _collection.doc(taskId).update({
      'comments': FieldValue.arrayUnion([comment.toJson()]),
    });
  }

  @override
  Stream<List<Task>> watchTasks() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList());
  }

  @override
  Stream<List<Task>> watchTasksByProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList());
  }
}
