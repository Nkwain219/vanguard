import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance.dart';
import '../repositories/attendance_repository.dart';

class GlobalAttendanceState {
  final List<Attendance> records;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final Map<int, int> weeklyTrend;

  GlobalAttendanceState({
    this.records = const [],
    this.isLoading = false,
    this.error,
    DateTime? selectedDate,
    this.weeklyTrend = const {},
  }) : selectedDate = selectedDate ?? DateTime.now();

  GlobalAttendanceState copyWith({
    List<Attendance>? records,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    Map<int, int>? weeklyTrend,
  }) {
    return GlobalAttendanceState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
    );
  }

  int get presentCount => records
      .where((r) =>
          r.status == AttendanceStatus.present ||
          r.status == AttendanceStatus.late)
      .length;
  int get lateCount =>
      records.where((r) => r.status == AttendanceStatus.late).length;
}

class GlobalAttendanceViewModel extends StateNotifier<GlobalAttendanceState> {
  final AttendanceRepository _repository;

  GlobalAttendanceViewModel(this._repository) : super(GlobalAttendanceState());

  Future<void> loadDailyAttendance(DateTime date) async {
    state = state.copyWith(isLoading: true, error: null, selectedDate: date);
    try {
      final records = await _repository.getAttendanceByDate(date);
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setDate(DateTime date) {
    if (date.year == state.selectedDate.year &&
        date.month == state.selectedDate.month &&
        date.day == state.selectedDate.day) {
      return;
    }
    loadDailyAttendance(date);
  }

  Future<void> loadWeeklyTrend() async {
    final now = DateTime.now();

    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    try {
      final records = await _repository.getGlobalAttendanceByDateRange(
          startOfWeek, endOfWeek);

      final Map<int, int> trend = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

      for (final record in records) {
        if (record.status != AttendanceStatus.absent) {
          final weekday = record.date.weekday;
          trend[weekday] = (trend[weekday] ?? 0) + 1;
        }
      }

      state = state.copyWith(weeklyTrend: trend);
    } catch (e) {
      print('Error loading weekly trend: $e');
    }
  }
}
