import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/salary_request.dart';
import '../repositories/salary_repository.dart';

class SalaryState {
  final List<SalaryRequest> requests;
  final List<SalaryRequest> pendingRequests;
  final bool isLoading;
  final String? error;
  final SalaryRequestStatus? statusFilter;
  final SalaryRequestType? typeFilter;

  const SalaryState({
    this.requests = const [],
    this.pendingRequests = const [],
    this.isLoading = false,
    this.error,
    this.statusFilter,
    this.typeFilter,
  });

  SalaryState copyWith({
    List<SalaryRequest>? requests,
    List<SalaryRequest>? pendingRequests,
    bool? isLoading,
    String? error,
    SalaryRequestStatus? statusFilter,
    SalaryRequestType? typeFilter,
  }) {
    return SalaryState(
      requests: requests ?? this.requests,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statusFilter: statusFilter,
      typeFilter: typeFilter,
    );
  }

  List<SalaryRequest> get filteredRequests {
    var result = requests;

    if (statusFilter != null) {
      result = result.where((r) => r.status == statusFilter).toList();
    }

    if (typeFilter != null) {
      result = result.where((r) => r.type == typeFilter).toList();
    }

    return result;
  }

  double get totalPendingAmount =>
      pendingRequests.fold(0.0, (sum, r) => sum + r.amount);

  double get totalApprovedAmount => requests
      .where((r) => r.status == SalaryRequestStatus.approved)
      .fold(0.0, (sum, r) => sum + r.amount);

  Map<SalaryRequestType, int> get typeCounts {
    final counts = <SalaryRequestType, int>{};
    for (final type in SalaryRequestType.values) {
      counts[type] = requests.where((r) => r.type == type).length;
    }
    return counts;
  }
}

class SalaryViewModel extends StateNotifier<SalaryState> {
  final SalaryRepository _repository;
  final String? employeeId;

  SalaryViewModel(this._repository, {this.employeeId})
      : super(const SalaryState());

  Future<void> loadSalaryRequests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<SalaryRequest> requests;

      if (employeeId != null) {
        requests = await _repository.getSalaryRequestsByEmployee(employeeId!);
      } else {
        requests = await _repository.getAllSalaryRequests();
      }

      final pendingRequests = await _repository.getPendingSalaryRequests();

      state = state.copyWith(
        requests: requests,
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

  Future<void> loadPendingRequests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pendingRequests = await _repository.getPendingSalaryRequests();

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

  Future<bool> createSalaryRequest(SalaryRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.createSalaryRequest(request);
      await loadSalaryRequests();
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
      await _repository.approveSalaryRequest(id, approvedBy, notes: notes);
      await loadSalaryRequests();
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
      await _repository.rejectSalaryRequest(id, approvedBy, notes: notes);
      await loadSalaryRequests();
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
      await _repository.cancelSalaryRequest(id);
      await loadSalaryRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void setStatusFilter(SalaryRequestStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  void setTypeFilter(SalaryRequestType? type) {
    state = state.copyWith(typeFilter: type);
  }

  void clearFilters() {
    state = state.copyWith(statusFilter: null, typeFilter: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
