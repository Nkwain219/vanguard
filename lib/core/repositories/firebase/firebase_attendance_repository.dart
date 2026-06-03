import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/attendance.dart';
import '../../services/firestore_service.dart';
import '../attendance_repository.dart';

class FirebaseAttendanceRepository implements AttendanceRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.attendanceCollection;

  @override
  Future<List<Attendance>> getAllAttendance() async {
    final snapshot = await _collection.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => Attendance.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Attendance>> getAttendanceByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .get();

    return snapshot.docs.map((doc) => Attendance.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Attendance>> getGlobalAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Attendance.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Attendance>> getAttendanceByEmployee(String employeeId) async {
    final snapshot = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Attendance.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Attendance>> getAttendanceByDateRange(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Attendance.fromJson(doc.data())).toList();
  }

  @override
  Future<Attendance?> getTodayAttendance(String employeeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Attendance.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  @override
  Future<Attendance> clockIn({
    required String employeeId,
    String? checkInPhotoUrl,
    String? checkInLocation,
    String? deviceId,
  }) async {
    final now = DateTime.now();
    final id = _collection.doc().id;

    final isLate = now.hour >= 9;

    final attendance = Attendance(
      id: id,
      employeeId: employeeId,
      date: DateTime(now.year, now.month, now.day),
      clockIn: now,
      status: isLate ? AttendanceStatus.late : AttendanceStatus.present,
      hoursWorked: 0.0,
      checkInPhotoUrl: checkInPhotoUrl,
      checkInLocation: checkInLocation,
      deviceId: deviceId,
      isVerified: checkInPhotoUrl != null,
    );

    await _collection.doc(id).set(attendance.toJson());
    return attendance;
  }

  @override
  Future<Attendance> clockOut(String attendanceId) async {
    final now = DateTime.now();
    final doc = await _collection.doc(attendanceId).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('Attendance record not found');
    }

    final attendance = Attendance.fromJson(doc.data()!);
    final hoursWorked = attendance.clockIn != null
        ? now.difference(attendance.clockIn!).inMinutes / 60.0
        : 0.0;

    final updated = attendance.copyWith(
      clockOut: now,
      hoursWorked: hoursWorked,
    );

    await _collection.doc(attendanceId).update({
      'clockOut': now.toIso8601String(),
      'hoursWorked': hoursWorked,
    });

    return updated;
  }

  @override
  Future<void> updateAttendance(Attendance attendance) async {
    await _collection.doc(attendance.id).update(attendance.toJson());
  }

  @override
  Future<AttendanceSummary> getAttendanceSummary(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final records =
        await getAttendanceByDateRange(employeeId, startDate, endDate);

    int presentDays = 0;
    int lateDays = 0;
    int halfDays = 0;
    double totalHours = 0.0;

    for (final record in records) {
      totalHours += record.hoursWorked;
      switch (record.status) {
        case AttendanceStatus.present:
          presentDays++;
          break;
        case AttendanceStatus.late:
          lateDays++;
          break;
        case AttendanceStatus.halfDay:
          halfDays++;
          break;
        case AttendanceStatus.absent:
          break;
      }
    }

    int totalDays = 0;
    for (var date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        totalDays++;
      }
    }

    return AttendanceSummary(
      totalDays: totalDays,
      presentDays: presentDays + lateDays + halfDays,
      absentDays: totalDays - (presentDays + lateDays + halfDays),
      lateDays: lateDays,
      halfDays: halfDays,
      totalHoursWorked: totalHours,
    );
  }

  @override
  Stream<List<Attendance>> watchAttendance(String employeeId) {
    return _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Attendance.fromJson(doc.data()))
            .toList());
  }
}
