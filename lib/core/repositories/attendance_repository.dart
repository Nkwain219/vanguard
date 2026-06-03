import '../models/attendance.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> getAllAttendance();

  Future<List<Attendance>> getAttendanceByEmployee(String employeeId);

  Future<List<Attendance>> getAttendanceByDateRange(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  );

  Future<List<Attendance>> getGlobalAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  Future<List<Attendance>> getAttendanceByDate(DateTime date);

  Future<Attendance?> getTodayAttendance(String employeeId);

  Future<Attendance> clockIn({
    required String employeeId,
    String? checkInPhotoUrl,
    String? checkInLocation,
    String? deviceId,
  });

  Future<Attendance> clockOut(String attendanceId);

  Future<void> updateAttendance(Attendance attendance);

  Future<AttendanceSummary> getAttendanceSummary(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  );

  Stream<List<Attendance>> watchAttendance(String employeeId);
}

class AttendanceSummary {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int halfDays;
  final double totalHoursWorked;

  const AttendanceSummary({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.halfDays,
    required this.totalHoursWorked,
  });
}
