import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';

class EmployeeState {
  final List<Employee> employees;
  final Employee? selectedEmployee;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? departmentFilter;

  final List<Employee>? _cachedFiltered;
  final int _filterHash;

  EmployeeState({
    this.employees = const [],
    this.selectedEmployee,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.departmentFilter,
    List<Employee>? cachedFiltered,
    int? filterHash,
  })  : _cachedFiltered = cachedFiltered,
        _filterHash = filterHash ?? 0;

  EmployeeState copyWith({
    List<Employee>? employees,
    Employee? selectedEmployee,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? departmentFilter,
    bool clearError = false,
    bool clearSelection = false,
    bool clearDepartmentFilter = false,
  }) {
    final newEmployees = employees ?? this.employees;
    final newSearchQuery = searchQuery ?? this.searchQuery;
    final newDepartmentFilter = clearDepartmentFilter
        ? null
        : (departmentFilter ?? this.departmentFilter);

    final newFilterHash = Object.hash(
      newEmployees.length,
      newSearchQuery,
      newDepartmentFilter,
    );

    return EmployeeState(
      employees: newEmployees,
      selectedEmployee:
          clearSelection ? null : (selectedEmployee ?? this.selectedEmployee),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
      searchQuery: newSearchQuery,
      departmentFilter: newDepartmentFilter,
      cachedFiltered: newFilterHash == _filterHash ? _cachedFiltered : null,
      filterHash: newFilterHash,
    );
  }

  List<Employee> get filteredEmployees {
    if (_cachedFiltered != null) return _cachedFiltered!;

    var result = employees;

    if (departmentFilter != null && departmentFilter!.isNotEmpty) {
      result = result.where((e) => e.department == departmentFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((e) {
        return e.fullName.toLowerCase().contains(query) ||
            e.email.toLowerCase().contains(query) ||
            e.department.toLowerCase().contains(query) ||
            e.position.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  List<String> get departments {
    return employees.map((e) => e.department).toSet().toList()..sort();
  }

  Map<String, int> get departmentCounts {
    final counts = <String, int>{};
    for (final employee in employees) {
      counts[employee.department] = (counts[employee.department] ?? 0) + 1;
    }
    return counts;
  }

  int get activeCount => employees.where((e) => e.isActive).length;
  int get inactiveCount => employees.where((e) => !e.isActive).length;
  int get totalCount => employees.length;

  bool get hasFilters => searchQuery.isNotEmpty || departmentFilter != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmployeeState &&
        other.employees.length == employees.length &&
        other.selectedEmployee?.id == selectedEmployee?.id &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.searchQuery == searchQuery &&
        other.departmentFilter == departmentFilter;
  }

  @override
  int get hashCode => Object.hash(
        employees.length,
        selectedEmployee?.id,
        isLoading,
        error,
        searchQuery,
        departmentFilter,
      );
}

class EmployeeViewModel extends StateNotifier<EmployeeState> {
  final EmployeeRepository _repository;
  bool _disposed = false;
  StreamSubscription<List<Employee>>? _employeesSubscription;

  EmployeeViewModel(this._repository) : super(EmployeeState());

  @override
  void dispose() {
    _disposed = true;
    _employeesSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadEmployees({bool forceRefresh = false}) async {
    if (_disposed) return;

    if (!forceRefresh &&
        _employeesSubscription != null &&
        state.employees.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    _employeesSubscription?.cancel();

    _employeesSubscription = _repository.watchEmployees().listen(
      (employees) {
        if (_disposed) return;
        state = state.copyWith(
          employees: employees,
          isLoading: false,
        );
      },
      onError: (e) {
        if (_disposed) return;
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      },
    );
  }

  Future<void> selectEmployee(String id) async {
    if (_disposed) return;

    if (state.selectedEmployee?.id == id) return;

    state = state.copyWith(isLoading: true);

    try {
      final employee = await _repository.getEmployeeById(id);
      if (_disposed) return;

      state = state.copyWith(
        selectedEmployee: employee,
        isLoading: false,
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSelection() {
    if (state.selectedEmployee == null) return;
    state = state.copyWith(clearSelection: true);
  }

  Future<bool> createEmployee(Employee employee) async {
    if (_disposed || state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.createEmployee(employee);
      if (_disposed) return false;

      state = state.copyWith(
        employees: [...state.employees, employee],
        isLoading: false,
      );
      return true;
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateEmployee(Employee employee) async {
    if (_disposed || state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.updateEmployee(employee);
      if (_disposed) return false;

      final updatedList = state.employees.map((e) {
        return e.id == employee.id ? employee : e;
      }).toList();

      state = state.copyWith(
        employees: updatedList,
        selectedEmployee:
            state.selectedEmployee?.id == employee.id ? employee : null,
        isLoading: false,
      );
      return true;
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    if (_disposed || state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.deleteEmployee(id);
      if (_disposed) return false;

      final updatedList = state.employees.where((e) => e.id != id).toList();

      state = state.copyWith(
        employees: updatedList,
        clearSelection: state.selectedEmployee?.id == id,
        isLoading: false,
      );
      return true;
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> toggleStatus(String id, bool isActive) async {
    if (_disposed || state.isLoading) return false;

    try {
      await _repository.toggleEmployeeStatus(id, isActive);
      if (_disposed) return false;

      final updatedList = state.employees.map((e) {
        return e.id == id ? e.copyWith(isActive: isActive) : e;
      }).toList();

      state = state.copyWith(employees: updatedList);
      return true;
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    state = state.copyWith(searchQuery: query);
  }

  void setDepartmentFilter(String? department) {
    if (department == state.departmentFilter) return;
    state = state.copyWith(
      departmentFilter: department,
      clearDepartmentFilter: department == null,
    );
  }

  void clearFilters() {
    if (!state.hasFilters) return;
    state = state.copyWith(
      searchQuery: '',
      clearDepartmentFilter: true,
    );
  }

  void clearError() {
    if (state.error == null) return;
    state = state.copyWith(clearError: true);
  }
}
