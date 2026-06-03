import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/volunteer.dart';
import '../../services/firestore_service.dart';
import '../volunteer_repository.dart';

class FirebaseVolunteerRepository implements VolunteerRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.volunteersCollection;

  @override
  Future<List<Volunteer>> getAllVolunteers() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Volunteer.fromJson(doc.data())).toList();
  }

  @override
  Future<Volunteer?> getVolunteerById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Volunteer.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<Volunteer>> getVolunteersByDepartment(String department) async {
    final snapshot =
        await _collection.where('department', isEqualTo: department).get();
    return snapshot.docs.map((doc) => Volunteer.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Volunteer>> getActiveVolunteers() async {
    final snapshot = await _collection.where('isActive', isEqualTo: true).get();
    return snapshot.docs.map((doc) => Volunteer.fromJson(doc.data())).toList();
  }

  @override
  Future<void> createVolunteer(Volunteer volunteer) async {
    await _collection.doc(volunteer.id).set(volunteer.toJson());
  }

  @override
  Future<void> updateVolunteer(Volunteer volunteer) async {
    await _collection.doc(volunteer.id).update(volunteer.toJson());
  }

  @override
  Future<void> deleteVolunteer(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> toggleVolunteerStatus(String id, bool isActive) async {
    await _collection.doc(id).update({'isActive': isActive});
  }

  @override
  Stream<List<Volunteer>> watchVolunteers() {
    return _collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Volunteer.fromJson(doc.data())).toList());
  }
}
