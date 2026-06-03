import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/deposit.dart';
import '../../services/firestore_service.dart';
import '../deposit_repository.dart';

class FirebaseDepositRepository implements DepositRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.depositsCollection;

  @override
  Future<List<Deposit>> getAllDeposits() async {
    final snapshot =
        await _collection.orderBy('requestDate', descending: true).get();
    return snapshot.docs.map((doc) => Deposit.fromJson(doc.data())).toList();
  }

  @override
  Future<Deposit?> getDepositById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Deposit.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<Deposit>> getDepositsByEmployee(String employeeId) async {
    final snapshot = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('requestDate', descending: true)
        .get();
    return snapshot.docs.map((doc) => Deposit.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Deposit>> getDepositsByStatus(DepositStatus status) async {
    final snapshot =
        await _collection.where('status', isEqualTo: status.name).get();
    return snapshot.docs.map((doc) => Deposit.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Deposit>> getDepositsByType(DepositType type) async {
    final snapshot =
        await _collection.where('type', isEqualTo: type.name).get();
    return snapshot.docs.map((doc) => Deposit.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Deposit>> getPendingDeposits() async {
    return getDepositsByStatus(DepositStatus.pending);
  }

  @override
  Future<void> createDeposit(Deposit deposit) async {
    await _collection.doc(deposit.id).set(deposit.toJson());
  }

  @override
  Future<void> approveDeposit(String id, String approvedBy,
      {String? notes}) async {
    await _collection.doc(id).update({
      'status': DepositStatus.approved.name,
      'approvedBy': approvedBy,
      'approvalDate': DateTime.now().toIso8601String(),
      'notes': notes,
    });
  }

  @override
  Future<void> rejectDeposit(String id, String approvedBy,
      {String? notes}) async {
    await _collection.doc(id).update({
      'status': DepositStatus.rejected.name,
      'approvedBy': approvedBy,
      'approvalDate': DateTime.now().toIso8601String(),
      'notes': notes,
    });
  }

  @override
  Future<void> cancelDeposit(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<Deposit>> watchDeposits(String employeeId) {
    return _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Deposit.fromJson(doc.data())).toList());
  }

  @override
  Stream<List<Deposit>> watchPendingDeposits() {
    return _collection
        .where('status', isEqualTo: DepositStatus.pending.name)
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Deposit.fromJson(doc.data())).toList());
  }
}
