import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../models/salary_request.dart';
import '../../services/firestore_service.dart';
import '../salary_repository.dart';

class FirebaseSalaryRepository implements SalaryRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.salaryRequestsCollection;

  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  @override
  Future<List<SalaryRequest>> getAllSalaryRequests() async {
    final snapshot =
        await _collection.orderBy('requestDate', descending: true).get();
    return snapshot.docs
        .map((doc) => SalaryRequest.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<SalaryRequest?> getSalaryRequestById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return SalaryRequest.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<SalaryRequest>> getSalaryRequestsByEmployee(
      String employeeId) async {
    final snapshot = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('requestDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => SalaryRequest.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<SalaryRequest>> getSalaryRequestsByStatus(
      SalaryRequestStatus status) async {
    final snapshot =
        await _collection.where('status', isEqualTo: status.name).get();
    return snapshot.docs
        .map((doc) => SalaryRequest.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<SalaryRequest>> getSalaryRequestsByType(
      SalaryRequestType type) async {
    final snapshot =
        await _collection.where('type', isEqualTo: type.name).get();
    return snapshot.docs
        .map((doc) => SalaryRequest.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<SalaryRequest>> getPendingSalaryRequests() async {
    return getSalaryRequestsByStatus(SalaryRequestStatus.pending);
  }

  @override
  Future<void> createSalaryRequest(SalaryRequest request) async {
    await _collection.doc(request.id).set(request.toJson());
  }

  @override
  Future<void> approveSalaryRequest(String id, String approvedBy,
      {String? notes}) async {
    await _collection.doc(id).update({
      'status': SalaryRequestStatus.approved.name,
      'approvedBy': approvedBy,
      'approvalDate': DateTime.now().toIso8601String(),
      'notes': notes,
    });
  }

  @override
  Future<void> rejectSalaryRequest(String id, String approvedBy,
      {String? notes}) async {
    await _collection.doc(id).update({
      'status': SalaryRequestStatus.rejected.name,
      'approvedBy': approvedBy,
      'approvalDate': DateTime.now().toIso8601String(),
      'notes': notes,
    });
  }

  @override
  Future<void> cancelSalaryRequest(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<SalaryRequest>> watchSalaryRequests(String employeeId) {
    return _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SalaryRequest.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<List<SalaryRequest>> watchPendingSalaryRequests() {
    return _collection
        .where('status', isEqualTo: SalaryRequestStatus.pending.name)
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SalaryRequest.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<DisbursementResult> disburseSalary(String requestId,
      {String? notes}) async {
    try {
      final callable = _functions.httpsCallable('disburseSalary');
      final result = await callable.call<Map<String, dynamic>>({
        'requestId': requestId,
        'notes': notes,
      });

      return DisbursementResult(
        success: result.data['success'] as bool? ?? false,
        transactionId: result.data['transactionId'] as String?,
        message: result.data['message'] as String? ?? 'Payment processed',
      );
    } on FirebaseFunctionsException catch (e) {
      return DisbursementResult(
        success: false,
        message: e.message ?? 'Payment failed',
        error: e.code,
      );
    } catch (e) {
      return DisbursementResult(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }
}
