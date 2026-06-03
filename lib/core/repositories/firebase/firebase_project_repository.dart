import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project.dart';
import '../../services/firestore_service.dart';
import '../project_repository.dart';

class FirebaseProjectRepository implements ProjectRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.projectsCollection;

  @override
  Future<List<Project>> getAllProjects() async {
    final snapshot =
        await _collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Project.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    final snapshot =
        await _collection.where('status', isEqualTo: status.name).get();
    return snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Project>> getProjectsByManager(String managerId) async {
    final snapshot =
        await _collection.where('managerId', isEqualTo: managerId).get();
    return snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Project>> getProjectsByMember(String memberId) async {
    final snapshot =
        await _collection.where('memberIds', arrayContains: memberId).get();
    return snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList();
  }

  @override
  Future<void> createProject(Project project) async {
    await _collection.doc(project.id).set(project.toJson());
  }

  @override
  Future<void> updateProject(Project project) async {
    await _collection.doc(project.id).update(project.toJson());
  }

  @override
  Future<void> deleteProject(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> addMember(String projectId, String memberId) async {
    await _collection.doc(projectId).update({
      'memberIds': FieldValue.arrayUnion([memberId]),
    });
  }

  @override
  Future<void> removeMember(String projectId, String memberId) async {
    await _collection.doc(projectId).update({
      'memberIds': FieldValue.arrayRemove([memberId]),
    });
  }

  @override
  Stream<List<Project>> watchProjects() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList());
  }
}
