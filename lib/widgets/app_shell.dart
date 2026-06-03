import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/viewmodel_providers.dart';
import '../core/models/user_role.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexFromLocation(String location, UserRole role) {
    if (location.startsWith('/admin-dashboard') ||
        location.startsWith('/employee-dashboard') ||
        location.startsWith('/secretary-dashboard') ||
        location.startsWith('/volunteer-dashboard')) {
      return 0;
    }
    if (location.startsWith('/tasks') ||
        location.startsWith('/volunteer/tasks')) return 1;
    if (location.startsWith('/attendance') ||
        location.startsWith('/volunteer/attendance')) return 2;

    if (role == UserRole.admin) {
      if (location.startsWith('/employees') ||
          location.startsWith('/employee/')) return 3;
      if (location.startsWith('/profile')) return 4;
    } else {
      if (location.startsWith('/profile') ||
          location.startsWith('/volunteer/profile')) return 3;
    }

    return 0;
  }

  String _homePathForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '/admin-dashboard';
      case UserRole.employee:
        return '/employee-dashboard';
      case UserRole.secretary:
        return '/secretary-dashboard';
      case UserRole.volunteer:
        return '/volunteer-dashboard';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location, role);

    final isAdmin = role == UserRole.admin;
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.check_circle), label: 'Tasks'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.access_time), label: 'Attendance'),
      if (isAdmin)
        const BottomNavigationBarItem(
            icon: Icon(Icons.group), label: 'Employees'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: items,
        onTap: (index) {
          if (index == 0) {
            context.go(_homePathForRole(role));
            return;
          }
          if (index == 1) {
            if (role == UserRole.volunteer) {
              context.go('/volunteer/tasks');
            } else {
              context.go('/tasks');
            }
            return;
          }
          if (index == 2) {
            if (role == UserRole.employee) {
              context.go('/attendance/employee');
            } else if (role == UserRole.volunteer) {
              context.go('/volunteer/attendance');
            } else {
              context.go('/attendance/overview');
            }
            return;
          }
          if (isAdmin) {
            if (index == 3) {
              context.go('/employees');
              return;
            }
            if (index == 4) {
              context.go('/profile');
              return;
            }
          } else {
            if (index == 3) {
              if (role == UserRole.volunteer) {
                context.go('/volunteer/profile');
              } else {
                context.go('/profile');
              }
              return;
            }
          }
        },
      ),
    );
  }
}
