import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/deposit.dart';
import '../repositories/deposit_repository.dart';

class DepositState {
  final List<Deposit> deposits;
  final List<Deposit> pendingDeposits;
  final bool isLoading;
  final String? error;
  final DepositStatus? statusFilter;
  final DepositType? typeFilter;

  const DepositState({
    this.deposits = const [],
    this.pendingDeposits = const [],
    this.isLoading = false,
    this.error,
    this.statusFilter,
    this.typeFilter,
  });

  DepositState copyWith({
    List<Deposit>? deposits,
    List<Deposit>? pendingDeposits,
    bool? isLoading,
    String? error,
    DepositStatus? statusFilter,
    DepositType? typeFilter,
  }) {
    return DepositState(
      deposits: deposits ?? this.deposits,
      pendingDeposits: pendingDeposits ?? this.pendingDeposits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statusFilter: statusFilter,
      typeFilter: typeFilter,
    );
  }

  List<Deposit> get filteredDeposits {
    var result = deposits;

    if (statusFilter != null) {
      result = result.where((d) => d.status == statusFilter).toList();
    }

    if (typeFilter != null) {
      result = result.where((d) => d.type == typeFilter).toList();
    }

    return result;
  }

  double get totalPendingAmount =>
      pendingDeposits.fold(0.0, (sum, d) => sum + d.amount);

  double get totalApprovedAmount => deposits
      .where((d) => d.status == DepositStatus.approved)
      .fold(0.0, (sum, d) => sum + d.amount);

  Map<DepositType, double> get amountsByType {
    final amounts = <DepositType, double>{};
    for (final type in DepositType.values) {
      amounts[type] = deposits
          .where((d) => d.type == type && d.status == DepositStatus.approved)
          .fold(0.0, (sum, d) => sum + d.amount);
    }
    return amounts;
  }
}

class DepositViewModel extends StateNotifier<DepositState> {
  final DepositRepository _repository;
  final String? employeeId;

  DepositViewModel(this._repository, {this.employeeId})
      : super(const DepositState());

  Future<void> loadDeposits() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<Deposit> deposits;

      if (employeeId != null) {
        deposits = await _repository.getDepositsByEmployee(employeeId!);
      } else {
        deposits = await _repository.getAllDeposits();
      }

      final pendingDeposits = await _repository.getPendingDeposits();

      state = state.copyWith(
        deposits: deposits,
        pendingDeposits: pendingDeposits,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadPendingDeposits() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pendingDeposits = await _repository.getPendingDeposits();

      state = state.copyWith(
        pendingDeposits: pendingDeposits,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createDeposit(Deposit deposit) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.createDeposit(deposit);
      await loadDeposits();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> approveDeposit(String id, String approvedBy,
      {String? notes}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.approveDeposit(id, approvedBy, notes: notes);
      await loadDeposits();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> rejectDeposit(String id, String approvedBy,
      {String? notes}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.rejectDeposit(id, approvedBy, notes: notes);
      await loadDeposits();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> cancelDeposit(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.cancelDeposit(id);
      await loadDeposits();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void setStatusFilter(DepositStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  void setTypeFilter(DepositType? type) {
    state = state.copyWith(typeFilter: type);
  }

  void clearFilters() {
    state = state.copyWith(statusFilter: null, typeFilter: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
