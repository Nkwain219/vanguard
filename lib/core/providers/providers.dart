import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_shell.dart';

import '../../features/auth/login/view/login_view.dart';
import '../../features/auth/onboarding/view/onboarding_view.dart';
import '../../features/auth/splash/view/splash_view.dart';

import '../../features/admin/home/view/admin_home_view.dart';
import '../../features/admin/employees/view/employee_list_view.dart';
import '../../features/admin/employees/view/employee_detail_view.dart';
import '../../features/admin/employees/view/create_edit_employee_view.dart';
import '../../features/admin/employees/view/payslip_view.dart';
import '../../features/admin/reports/view/reports_view.dart';
import '../../features/admin/leave/view/leave_approval_view.dart';
import '../../features/admin/locations/view/work_locations_view.dart';

import '../../features/admin/volunteers/view/volunteer_list_view.dart';
import '../../features/admin/volunteers/view/volunteer_detail_view.dart';
import '../../features/admin/volunteers/view/create_edit_volunteer_view.dart';

import '../../features/secretary/home/view/secretary_home_view.dart';
import '../../features/secretary/reminders/view/reminder_center_view.dart';

import '../../features/employee/home/view/employee_home_view.dart';
import '../../features/employee/attendance/view/attendance_view.dart';
import '../../features/employee/attendance/view/attendance_overview_view.dart';
import '../../features/employee/salary/view/salary_request_view.dart';
import '../../features/employee/salary/view/salary_approval_view.dart';
import '../../features/employee/deposit/view/deposit_view.dart';
import '../../features/employee/deposit/view/deposit_history_view.dart';
import '../../features/employee/leave/view/leave_request_view.dart';
import '../../features/employee/notifications/view/notification_center_view.dart';

import '../../features/shared/notifications/view/compose_notification_view.dart';

import '../../features/volunteer/home/view/volunteer_home_view.dart';

import '../../features/tasks/list/view/task_list_view.dart';
import '../../features/tasks/detail/view/task_detail_view.dart';
import '../../features/tasks/create/view/create_task_view.dart';

import '../../features/profile/settings/view/profile_settings_view.dart';

import '../models/user.dart';
import '../models/user_role.dart';
import 'repository_providers.dart';

import '../../features/projects/list/view/project_list_view.dart';
import '../../features/projects/detail/view/project_detail_view.dart';
import '../../features/projects/create/view/create_project_view.dart';

import '../../features/wallet/view/wallet_deposit_view.dart';
import '../../features/wallet/view/wallet_dashboard_view.dart';
import '../../features/wallet/view/my_deposits_view.dart';

final themeProvider = StateProvider<bool>((ref) => false);
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/secretary-dashboard',
            builder: (context, state) => const SecretaryDashboardScreen(),
          ),
          GoRoute(
            path: '/employee-dashboard',
            builder: (context, state) => const EmployeeDashboardScreen(),
          ),
          GoRoute(
            path: '/volunteer-dashboard',
            builder: (context, state) => const VolunteerDashboardScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateTaskScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => TaskDetailScreen(
                  taskId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/volunteer/tasks',
            builder: (context, state) => const TaskListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateTaskScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => TaskDetailScreen(
                  taskId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/attendance/overview',
            builder: (context, state) => const AttendanceOverviewScreen(),
          ),
          GoRoute(
            path: '/attendance/employee',
            builder: (context, state) => const AttendanceEmployeeScreen(),
          ),
          GoRoute(
            path: '/volunteer/attendance',
            builder: (context, state) => const AttendanceEmployeeScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileSettingsScreen(),
          ),
          GoRoute(
            path: '/volunteer/profile',
            builder: (context, state) => const ProfileSettingsScreen(),
          ),
          GoRoute(
            path: '/employees',
            builder: (context, state) => const EmployeeListScreen(),
          ),
          GoRoute(
            path: '/volunteers',
            builder: (context, state) => const VolunteerListScreen(),
          ),
          GoRoute(
            path: '/volunteer/:id',
            builder: (context, state) => VolunteerDetailScreen(
              volunteerId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/create-volunteer',
            builder: (context, state) => const CreateEditVolunteerScreen(),
          ),
          GoRoute(
            path: '/edit-volunteer/:id',
            builder: (context, state) => CreateEditVolunteerScreen(
              volunteerId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/employee/:id',
            builder: (context, state) => EmployeeDetailScreen(
              employeeId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/edit-employee/:id',
            builder: (context, state) => CreateEditEmployeeScreen(
              employeeId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/create-employee',
            builder: (context, state) => const CreateEditEmployeeScreen(),
          ),
          GoRoute(
            path: '/salary-request',
            builder: (context, state) => const SalaryRequestScreen(),
          ),
          GoRoute(
            path: '/salary-approval',
            builder: (context, state) => const SalaryApprovalListScreen(),
          ),
          GoRoute(
            path: '/payslip/:id',
            builder: (context, state) => SalaryPayslipPreviewScreen(
              salaryId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/deposit',
            builder: (context, state) => const DepositScreen(),
          ),
          GoRoute(
            path: '/deposit-history',
            builder: (context, state) => const DepositHistoryScreen(),
          ),
          GoRoute(
            path: '/work-locations',
            builder: (context, state) => const WorkLocationsScreen(),
          ),
          GoRoute(
            path: '/leave-request',
            builder: (context, state) => const LeaveRequestScreen(),
          ),
          GoRoute(
            path: '/leave-approval',
            builder: (context, state) => const LeaveApprovalScreen(),
          ),
          GoRoute(
            path: '/reminders',
            builder: (context, state) => const SecretaryReminderCenterScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationCenterScreen(),
          ),
          GoRoute(
            path: '/compose-notification',
            builder: (context, state) => const ComposeNotificationScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateProjectScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => CreateProjectScreen(
                  projectId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ProjectDetailScreen(
                  projectId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletDashboardView(),
          ),
          GoRoute(
            path: '/wallet-deposit',
            builder: (context, state) => const WalletDepositView(),
          ),
          GoRoute(
            path: '/my-deposits',
            builder: (context, state) => const MyDepositsView(),
          ),
        ],
      ),
    ],
  );
});
