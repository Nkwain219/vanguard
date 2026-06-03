import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../repositories/employee_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/leave_repository.dart';
import '../repositories/salary_repository.dart';
import '../repositories/deposit_repository.dart';
import '../repositories/volunteer_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/document_repository.dart';

import '../repositories/firebase/firebase_auth_repository.dart';
import '../repositories/firebase/firebase_employee_repository.dart';
import '../repositories/firebase/firebase_project_repository.dart';
import '../repositories/firebase/firebase_task_repository.dart';
import '../repositories/firebase/firebase_attendance_repository.dart';
import '../repositories/firebase/firebase_leave_repository.dart';
import '../repositories/firebase/firebase_salary_repository.dart';
import '../repositories/firebase/firebase_deposit_repository.dart';
import '../repositories/firebase/firebase_volunteer_repository.dart';
import '../repositories/firebase/firebase_notification_repository.dart';
import '../repositories/firebase/firebase_document_repository.dart';
import '../repositories/firebase/firebase_reminder_repository.dart';
import '../repositories/reminder_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return FirebaseEmployeeRepository();
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return FirebaseProjectRepository();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirebaseTaskRepository();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return FirebaseAttendanceRepository();
});

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return FirebaseLeaveRepository();
});

final salaryRepositoryProvider = Provider<SalaryRepository>((ref) {
  return FirebaseSalaryRepository();
});

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  return FirebaseDepositRepository();
});

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  return FirebaseVolunteerRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirebaseNotificationRepository();
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return FirebaseDocumentRepository();
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return FirebaseReminderRepository(FirebaseFirestore.instance);
});
