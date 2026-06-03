import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/leave_request.dart';
import '../../services/firestore_service.dart';
import '../leave_repository.dart';

class FirebaseLeaveRepository implements LeaveRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.leaveRequestsCollection;

  @override
  Future<List<LeaveRequest>> getAllLeaveRequests() async {
    final snapshot =
        await _collection.orderBy('requestDate', descending: true).get();
    return snapshot.docs
        .map((doc) => LeaveRequest.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<LeaveRequest?> getLeaveRequestById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return LeaveRequest.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<LeaveRequest>> getLeaveRequestsByEmployee(
      String employeeId) async {
    final snapshot = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('requestDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LeaveRequest.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<LeaveRequest>> getLeaveRequestsByStatus(
      LeaveStatus status) async {
    final snapshot =
        await _collection.where('status', isEqualTo: status.name).get();
    return snapshot.docs
        .map((doc) => LeaveRequest.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<LeaveRequest>> getPendingLeaveRequests() async {
    return getLeaveRequestsByStatus(LeaveStatus.pending);
  }

  @override
  Future<void> createLeaveRequest(LeaveRequest request) async {
    await _collection.doc(request.id).set(request.toJson());
  }

  @override
  Future<void> approveLeaveRequest(String id, String approvedBy,
      {String? notes}) async {
    await _collection.doc(id).update({
      'status': LeaveStatus.approved.name,
      'approvedBy': approvedBy,
      'approvalDate': DateTime.now().toIso8601String(),
      'notes': notes,
    });
  }

  @override
  Future<void> rejectLeaveRequest(String id, String approvedBy,
      {String? notes}) async {
    await _collection.doc(id).update({
      'status': LeaveStatus.rejected.name,
      'approvedBy': approvedBy,
      'approvalDate': DateTime.now().toIso8601String(),
      'notes': notes,
    });
  }

  @override
  Future<void> cancelLeaveRequest(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<LeaveBalance> getLeaveBalance(String employeeId) async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    final snapshot = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: LeaveStatus.approved.name)
        .where('startDate',
            isGreaterThanOrEqualTo: startOfYear.toIso8601String())
        .get();

    int annualUsed = 0;
    int sickUsed = 0;
    int maternityUsed = 0;
    int paternityUsed = 0;

    for (final doc in snapshot.docs) {
      final request = LeaveRequest.fromJson(doc.data());
      switch (request.type) {
        case LeaveType.annual:
          annualUsed += request.days;
          break;
        case LeaveType.sick:
          sickUsed += request.days;
          break;
        case LeaveType.maternity:
          maternityUsed += request.days;
          break;
        case LeaveType.paternity:
          paternityUsed += request.days;
          break;
        default:
          break;
      }
    }

    return LeaveBalance(
      annualUsed: annualUsed,
      sickUsed: sickUsed,
      maternityUsed: maternityUsed,
      paternityUsed: paternityUsed,
    );
  }

  @override
  Stream<List<LeaveRequest>> watchLeaveRequests(String employeeId) {
    return _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaveRequest.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<List<LeaveRequest>> watchPendingLeaveRequests() {
    return _collection
        .where('status', isEqualTo: LeaveStatus.pending.name)
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaveRequest.fromJson(doc.data()))
            .toList());
  }
}
