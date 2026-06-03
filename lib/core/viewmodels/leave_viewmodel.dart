import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_request.dart';
import '../repositories/leave_repository.dart';

class LeaveState {
  final List<LeaveRequest> requests;
  final List<LeaveRequest> pendingRequests;
  final LeaveBalance? balance;
  final bool isLoading;
  final String? error;
  final LeaveStatus? statusFilter;

  const LeaveState({
    this.requests = const [],
    this.pendingRequests = const [],
    this.balance,
    this.isLoading = false,
    this.error,
    this.statusFilter,
  });

  LeaveState copyWith({
    List<LeaveRequest>? requests,
    List<LeaveRequest>? pendingRequests,
    LeaveBalance? balance,
    bool? isLoading,
    String? error,
    LeaveStatus? statusFilter,
  }) {
    return LeaveState(
      requests: requests ?? this.requests,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statusFilter: statusFilter,
    );
  }

  List<LeaveRequest> get filteredRequests {
    if (statusFilter == null) return requests;
    return requests.where((r) => r.status == statusFilter).toList();
  }

  List<LeaveRequest> get approvedRequests =>
      requests.where((r) => r.status == LeaveStatus.approved).toList();

  List<LeaveRequest> get rejectedRequests =>
      requests.where((r) => r.status == LeaveStatus.rejected).toList();

  List<LeaveRequest> get pendingRequestsOnly =>
      requests.where((r) => r.status == LeaveStatus.pending).toList();

  int get remainingLeaveDays => balance?.annualRemaining ?? 18;
}

class LeaveViewModel extends StateNotifier<LeaveState> {
  final LeaveRepository _repository;
  final String? employeeId;

  LeaveViewModel(this._repository, {this.employeeId})
      : super(const LeaveState());

  Future<void> loadLeaveRequests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<LeaveRequest> requests;
      LeaveBalance? balance;

      if (employeeId != null) {
        requests = await _repository.getLeaveRequestsByEmployee(employeeId!);
        balance = await _repository.getLeaveBalance(employeeId!);
      } else {
        requests = await _repository.getAllLeaveRequests();
      }

      final pendingRequests = await _repository.getPendingLeaveRequests();

      state = state.copyWith(
        requests: requests,
        pendingRequests: pendingRequests,
        balance: balance,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadPendingRequests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pendingRequests = await _repository.getPendingLeaveRequests();

      state = state.copyWith(
        pendingRequests: pendingRequests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createLeaveRequest(LeaveRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.createLeaveRequest(request);
      await loadLeaveRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> approveRequest(String id, String approvedBy,
      {String? notes}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.approveLeaveRequest(id, approvedBy, notes: notes);
      await loadLeaveRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> rejectRequest(String id, String approvedBy,
      {String? notes}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.rejectLeaveRequest(id, approvedBy, notes: notes);
      await loadLeaveRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> cancelRequest(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.cancelLeaveRequest(id);
      await loadLeaveRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void setStatusFilter(LeaveStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  void clearFilters() {
    state = state.copyWith(statusFilter: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
