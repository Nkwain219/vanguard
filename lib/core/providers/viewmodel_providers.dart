import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/leave_request.dart';
import '../models/salary_request.dart';
import '../models/deposit.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../models/notification.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/employee_viewmodel.dart';
import '../viewmodels/project_viewmodel.dart';
import '../viewmodels/task_viewmodel.dart';
import '../viewmodels/attendance_viewmodel.dart';
import '../viewmodels/leave_viewmodel.dart';
import '../viewmodels/salary_viewmodel.dart';
import '../viewmodels/deposit_viewmodel.dart';
import '../viewmodels/global_attendance_viewmodel.dart';
import '../viewmodels/volunteer_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../viewmodels/document_viewmodel.dart';
import '../viewmodels/reminder_viewmodel.dart';

import 'repository_providers.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
});

final employeeViewModelProvider =
    StateNotifierProvider<EmployeeViewModel, EmployeeState>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return EmployeeViewModel(repository);
});

final projectViewModelProvider =
    StateNotifierProvider<ProjectViewModel, ProjectState>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectViewModel(repository);
});

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, TaskState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskViewModel(repository);
});

final attendanceViewModelProvider =
    StateNotifierProvider.family<AttendanceViewModel, AttendanceState, String>(
        (ref, employeeId) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceViewModel(repository, employeeId);
});

final documentViewModelProvider =
    StateNotifierProvider.family<DocumentViewModel, DocumentState, String>(
        (ref, employeeId) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentViewModel(repository, employeeId);
});

final reminderViewModelProvider =
    StateNotifierProvider<ReminderViewModel, ReminderState>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return ReminderViewModel(repository);
});

final currentUserAttendanceProvider =
    StateNotifierProvider<AttendanceViewModel, AttendanceState>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  final employeeId = ref.watch(currentUserIdProvider);
  return AttendanceViewModel(repository, employeeId);
});

final globalAttendanceViewModelProvider =
    StateNotifierProvider<GlobalAttendanceViewModel, GlobalAttendanceState>(
        (ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return GlobalAttendanceViewModel(repository);
});

final leaveViewModelProvider =
    StateNotifierProvider<LeaveViewModel, LeaveState>((ref) {
  final repository = ref.watch(leaveRepositoryProvider);
  return LeaveViewModel(repository);
});

final employeeLeaveViewModelProvider =
    StateNotifierProvider.family<LeaveViewModel, LeaveState, String>(
        (ref, employeeId) {
  final repository = ref.watch(leaveRepositoryProvider);
  return LeaveViewModel(repository, employeeId: employeeId);
});

final currentUserLeaveProvider =
    StateNotifierProvider<LeaveViewModel, LeaveState>((ref) {
  final repository = ref.watch(leaveRepositoryProvider);
  final employeeId = ref.watch(currentUserIdProvider);
  return LeaveViewModel(repository, employeeId: employeeId);
});

final salaryViewModelProvider =
    StateNotifierProvider<SalaryViewModel, SalaryState>((ref) {
  final repository = ref.watch(salaryRepositoryProvider);
  return SalaryViewModel(repository);
});

final employeeSalaryViewModelProvider =
    StateNotifierProvider.family<SalaryViewModel, SalaryState, String>(
        (ref, employeeId) {
  final repository = ref.watch(salaryRepositoryProvider);
  return SalaryViewModel(repository, employeeId: employeeId);
});

final currentUserSalaryProvider =
    StateNotifierProvider<SalaryViewModel, SalaryState>((ref) {
  final repository = ref.watch(salaryRepositoryProvider);
  final employeeId = ref.watch(currentUserIdProvider);
  return SalaryViewModel(repository, employeeId: employeeId);
});

final depositViewModelProvider =
    StateNotifierProvider<DepositViewModel, DepositState>((ref) {
  final repository = ref.watch(depositRepositoryProvider);
  return DepositViewModel(repository);
});

final employeeDepositViewModelProvider =
    StateNotifierProvider.family<DepositViewModel, DepositState, String>(
        (ref, employeeId) {
  final repository = ref.watch(depositRepositoryProvider);
  return DepositViewModel(repository, employeeId: employeeId);
});

final currentUserDepositProvider =
    StateNotifierProvider<DepositViewModel, DepositState>((ref) {
  final repository = ref.watch(depositRepositoryProvider);
  final employeeId = ref.watch(currentUserIdProvider);
  return DepositViewModel(repository, employeeId: employeeId);
});

final volunteerViewModelProvider =
    StateNotifierProvider<VolunteerViewModel, VolunteerState>((ref) {
  final repository = ref.watch(volunteerRepositoryProvider);
  return VolunteerViewModel(repository);
});

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final role = ref.watch(currentRoleProvider);
  return NotificationViewModel(repository, userId: userId, userRole: role.name);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationViewModelProvider.select((s) => s.unreadCount));
});

final notificationListProvider = Provider<List<AppNotification>>((ref) {
  return ref
      .watch(notificationViewModelProvider.select((s) => s.notifications));
});

final currentUserIdProvider = Provider<String>((ref) {
  return ref.watch(authViewModelProvider.select((s) => s.user?.id ?? ''));
});

final currentRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(authViewModelProvider.select((s) => s.selectedRole));
});

final currentUserProvider = Provider<User>((ref) {
  final user = ref.watch(authViewModelProvider.select((s) => s.user));
  if (user == null) {
    return User(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      role: UserRole.employee,
      department: '',
      position: '',
      joinDate: DateTime.now(),
      isActive: false,
    );
  }
  return user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authViewModelProvider.select((s) => s.isAuthenticated));
});

final authIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authViewModelProvider.select((s) => s.isLoading));
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authViewModelProvider.select((s) => s.error));
});

final currentEmployeeProfileProvider = StreamProvider<Employee?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId.isEmpty) return Stream.value(null);

  final repository = ref.watch(employeeRepositoryProvider);
  return repository.watchEmployee(userId);
});

final employeeListProvider = Provider<List<Employee>>((ref) {
  return ref
      .watch(employeeViewModelProvider.select((s) => s.filteredEmployees));
});

final employeeCountProvider = Provider<int>((ref) {
  return ref.watch(employeeViewModelProvider.select((s) => s.totalCount));
});

final selectedEmployeeProvider = Provider<Employee?>((ref) {
  return ref.watch(employeeViewModelProvider.select((s) => s.selectedEmployee));
});

final employeesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(employeeViewModelProvider.select((s) => s.isLoading));
});

final departmentsProvider = Provider<List<String>>((ref) {
  return ref.watch(employeeViewModelProvider.select((s) => s.departments));
});

final employeeErrorProvider = Provider<String?>((ref) {
  return ref.watch(employeeViewModelProvider.select((s) => s.error));
});

final projectListProvider = Provider<List<Project>>((ref) {
  return ref.watch(projectViewModelProvider.select((s) => s.filteredProjects));
});

final activeProjectsCountProvider = Provider<int>((ref) {
  return ref
      .watch(projectViewModelProvider.select((s) => s.activeProjects.length));
});

final projectsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(projectViewModelProvider.select((s) => s.isLoading));
});

final selectedProjectProvider = Provider<Project?>((ref) {
  return ref.watch(projectViewModelProvider.select((s) => s.selectedProject));
});

final taskListProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskViewModelProvider.select((s) => s.filteredTasks));
});

final pendingTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskViewModelProvider.select((s) => s.pendingTasks.length));
});

final urgentTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskViewModelProvider.select((s) => s.urgentTasks.length));
});

final overdueTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskViewModelProvider.select((s) => s.overdueTasks.length));
});

final tasksLoadingProvider = Provider<bool>((ref) {
  return ref.watch(taskViewModelProvider.select((s) => s.isLoading));
});

final selectedTaskProvider = Provider<Task?>((ref) {
  return ref.watch(taskViewModelProvider.select((s) => s.selectedTask));
});

final pendingApprovalsCountProvider = Provider<int>((ref) {
  final leaveCount =
      ref.watch(leaveViewModelProvider.select((s) => s.pendingRequests.length));
  final salaryCount = ref
      .watch(salaryViewModelProvider.select((s) => s.pendingRequests.length));
  final depositCount = ref
      .watch(depositViewModelProvider.select((s) => s.pendingDeposits.length));

  return leaveCount + salaryCount + depositCount;
});

final pendingLeaveCountProvider = Provider<int>((ref) {
  return ref
      .watch(leaveViewModelProvider.select((s) => s.pendingRequests.length));
});

final pendingSalaryCountProvider = Provider<int>((ref) {
  return ref
      .watch(salaryViewModelProvider.select((s) => s.pendingRequests.length));
});

final pendingDepositCountProvider = Provider<int>((ref) {
  return ref
      .watch(depositViewModelProvider.select((s) => s.pendingDeposits.length));
});

final isClockedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserAttendanceProvider.select((s) => s.isClockedIn));
});

final clockInTimeProvider = Provider<String?>((ref) {
  return ref.watch(currentUserAttendanceProvider.select((s) => s.clockInTime));
});

final hoursWorkedTodayProvider = Provider<double>((ref) {
  return ref
      .watch(currentUserAttendanceProvider.select((s) => s.hoursWorkedToday));
});

final leaveRequestListProvider = Provider<List<LeaveRequest>>((ref) {
  return ref.watch(leaveViewModelProvider.select((s) => s.requests));
});

final pendingLeaveListProvider = Provider<List<LeaveRequest>>((ref) {
  return ref.watch(leaveViewModelProvider.select((s) => s.pendingRequests));
});

final leaveLoadingProvider = Provider<bool>((ref) {
  return ref.watch(leaveViewModelProvider.select((s) => s.isLoading));
});

final salaryRequestListProvider = Provider<List<SalaryRequest>>((ref) {
  return ref.watch(salaryViewModelProvider.select((s) => s.requests));
});

final pendingSalaryListProvider = Provider<List<SalaryRequest>>((ref) {
  return ref.watch(salaryViewModelProvider.select((s) => s.pendingRequests));
});

final salaryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(salaryViewModelProvider.select((s) => s.isLoading));
});

final depositListProvider = Provider<List<Deposit>>((ref) {
  return ref.watch(depositViewModelProvider.select((s) => s.deposits));
});

final pendingDepositListProvider = Provider<List<Deposit>>((ref) {
  return ref.watch(depositViewModelProvider.select((s) => s.pendingDeposits));
});

final depositLoadingProvider = Provider<bool>((ref) {
  return ref.watch(depositViewModelProvider.select((s) => s.isLoading));
});

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  return DashboardStats(
    employeeCount: ref.watch(employeeCountProvider),
    activeProjectsCount: ref.watch(activeProjectsCountProvider),
    pendingTasksCount: ref.watch(pendingTasksCountProvider),
    pendingApprovalsCount: ref.watch(pendingApprovalsCountProvider),
  );
});

class DashboardStats {
  final int employeeCount;
  final int activeProjectsCount;
  final int pendingTasksCount;
  final int pendingApprovalsCount;

  const DashboardStats({
    required this.employeeCount,
    required this.activeProjectsCount,
    required this.pendingTasksCount,
    required this.pendingApprovalsCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStats &&
        other.employeeCount == employeeCount &&
        other.activeProjectsCount == activeProjectsCount &&
        other.pendingTasksCount == pendingTasksCount &&
        other.pendingApprovalsCount == pendingApprovalsCount;
  }

  @override
  int get hashCode => Object.hash(
        employeeCount,
        activeProjectsCount,
        pendingTasksCount,
        pendingApprovalsCount,
      );
}
