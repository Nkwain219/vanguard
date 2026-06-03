import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance.dart';
import '../repositories/attendance_repository.dart';

class AttendanceState {
  final List<Attendance> records;
  final Attendance? todayRecord;
  final AttendanceSummary? summary;
  final bool isClockedIn;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;

  AttendanceState({
    this.records = const [],
    this.todayRecord,
    this.summary,
    this.isClockedIn = false,
    this.isLoading = false,
    this.error,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AttendanceState copyWith({
    List<Attendance>? records,
    Attendance? todayRecord,
    AttendanceSummary? summary,
    bool? isClockedIn,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
  }) {
    return AttendanceState(
      records: records ?? this.records,
      todayRecord: todayRecord ?? this.todayRecord,
      summary: summary ?? this.summary,
      isClockedIn: isClockedIn ?? this.isClockedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  bool get hasClockedOut => todayRecord?.clockOut != null;

  double get hoursWorkedToday => todayRecord?.hoursWorked ?? 0.0;

  String? get clockInTime {
    if (todayRecord?.clockIn == null) return null;
    final time = todayRecord!.clockIn!;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String? get clockOutTime {
    if (todayRecord?.clockOut == null) return null;
    final time = todayRecord!.clockOut!;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class AttendanceViewModel extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;
  final String employeeId;

  AttendanceViewModel(this._repository, this.employeeId)
      : super(AttendanceState());

  Future<void> loadAttendance() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final records = await _repository.getAttendanceByEmployee(employeeId);
      final todayRecord = await _repository.getTodayAttendance(employeeId);

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final summary = await _repository.getAttendanceSummary(
        employeeId,
        startOfMonth,
        now,
      );

      state = state.copyWith(
        records: records,
        todayRecord: todayRecord,
        summary: summary,
        isClockedIn:
            todayRecord?.clockIn != null && todayRecord?.clockOut == null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAttendanceForRange(
      DateTime startDate, DateTime endDate) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final records = await _repository.getAttendanceByDateRange(
        employeeId,
        startDate,
        endDate,
      );

      final summary = await _repository.getAttendanceSummary(
        employeeId,
        startDate,
        endDate,
      );

      state = state.copyWith(
        records: records,
        summary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> clockIn({
    String? checkInPhotoUrl,
    String? checkInLocation,
    String? deviceId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final attendance = await _repository.clockIn(
        employeeId: employeeId,
        checkInPhotoUrl: checkInPhotoUrl,
        checkInLocation: checkInLocation,
        deviceId: deviceId,
      );

      state = state.copyWith(
        todayRecord: attendance,
        isClockedIn: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> clockOut() async {
    if (state.todayRecord == null) {
      state = state.copyWith(error: 'No clock in record found');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final attendance = await _repository.clockOut(state.todayRecord!.id);

      state = state.copyWith(
        todayRecord: attendance,
        isClockedIn: false,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
