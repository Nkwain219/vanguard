import '../models/leave_request.dart';

abstract class LeaveRepository {
  Future<List<LeaveRequest>> getAllLeaveRequests();

  Future<LeaveRequest?> getLeaveRequestById(String id);

  Future<List<LeaveRequest>> getLeaveRequestsByEmployee(String employeeId);

  Future<List<LeaveRequest>> getLeaveRequestsByStatus(LeaveStatus status);

  Future<List<LeaveRequest>> getPendingLeaveRequests();

  Future<void> createLeaveRequest(LeaveRequest request);

  Future<void> approveLeaveRequest(String id, String approvedBy,
      {String? notes});

  Future<void> rejectLeaveRequest(String id, String approvedBy,
      {String? notes});

  Future<void> cancelLeaveRequest(String id);

  Future<LeaveBalance> getLeaveBalance(String employeeId);

  Stream<List<LeaveRequest>> watchLeaveRequests(String employeeId);

  Stream<List<LeaveRequest>> watchPendingLeaveRequests();
}

class LeaveBalance {
  final int annualTotal;
  final int annualUsed;
  final int sickTotal;
  final int sickUsed;
  final int maternityTotal;
  final int maternityUsed;
  final int paternityTotal;
  final int paternityUsed;

  const LeaveBalance({
    this.annualTotal = 21,
    this.annualUsed = 0,
    this.sickTotal = 10,
    this.sickUsed = 0,
    this.maternityTotal = 90,
    this.maternityUsed = 0,
    this.paternityTotal = 10,
    this.paternityUsed = 0,
  });

  int get annualRemaining => annualTotal - annualUsed;
  int get sickRemaining => sickTotal - sickUsed;
  int get maternityRemaining => maternityTotal - maternityUsed;
  int get paternityRemaining => paternityTotal - paternityUsed;
}
