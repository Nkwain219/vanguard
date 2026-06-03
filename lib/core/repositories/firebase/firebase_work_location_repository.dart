import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/work_location.dart';
import '../../services/firestore_service.dart';
import '../work_location_repository.dart';

class FirebaseWorkLocationRepository implements WorkLocationRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.workLocationsCollection;

  @override
  Future<List<WorkLocation>> getAllLocations() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => WorkLocation.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<WorkLocation>> getActiveLocations() async {
    final snapshot = await _collection.where('isActive', isEqualTo: true).get();
    return snapshot.docs
        .map((doc) => WorkLocation.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<WorkLocation?> getLocationById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return WorkLocation.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> createLocation(WorkLocation location) async {
    await _collection.doc(location.id).set(location.toJson());
  }

  @override
  Future<void> updateLocation(WorkLocation location) async {
    await _collection.doc(location.id).update(location.toJson());
  }

  @override
  Future<void> deleteLocation(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<WorkLocation>> watchLocations() {
    return _collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => WorkLocation.fromJson(doc.data())).toList());
  }
}
