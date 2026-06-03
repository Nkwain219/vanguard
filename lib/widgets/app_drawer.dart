import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/user_role.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/l10n/app_localizations.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(currentRoleProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            accountName: Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            accountEmail: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.name[0].toUpperCase() + role.name.substring(1),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(user.email,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard,
                  title: l10n.dashboard,
                  onTap: () => _navigate(
                      context,
                      role == UserRole.admin
                          ? '/admin-dashboard'
                          : role == UserRole.secretary
                              ? '/secretary-dashboard'
                              : role == UserRole.volunteer
                                  ? '/volunteer-dashboard'
                                  : '/employee-dashboard'),
                ),
                const Divider(),
                if (role == UserRole.admin) ...[
                  _DrawerSectionHeader(title: l10n.employees),
                  _DrawerItem(
                      icon: Icons.people,
                      title: l10n.employees,
                      onTap: () => _navigate(context, '/employees')),
                  _DrawerItem(
                      icon: Icons.volunteer_activism,
                      title: l10n.volunteers,
                      onTap: () => _navigate(context, '/volunteers')),
                  _DrawerItem(
                      icon: Icons.folder_copy,
                      title: 'Projects',
                      onTap: () => _navigate(context, '/projects')),
                  _DrawerItem(
                      icon: Icons.task_alt,
                      title: l10n.tasks,
                      onTap: () => _navigate(context, '/tasks')),
                  const Divider(),
                  _DrawerItem(
                      icon: Icons.event_busy,
                      title: l10n.leaveApprovalMenu,
                      onTap: () => _navigate(context, '/leave-approval')),
                  _DrawerItem(
                      icon: Icons.payments,
                      title: l10n.salaryApprovalMenu,
                      onTap: () => _navigate(context, '/salary-approval')),
                  _DrawerItem(
                      icon: Icons.account_balance,
                      title: l10n.deposits,
                      onTap: () => _navigate(context, '/deposit-history')),
                  _DrawerItem(
                      icon: Icons.location_on,
                      title: l10n.workLocations,
                      onTap: () => _navigate(context, '/work-locations')),
                  const Divider(),
                  _DrawerSectionHeader(title: 'Finance'),
                  _DrawerItem(
                      icon: Icons.account_balance_wallet,
                      title: 'Wallet',
                      onTap: () => _navigate(context, '/wallet')),
                  _DrawerItem(
                      icon: Icons.assessment,
                      title: l10n.reports,
                      onTap: () => _navigate(context, '/reports')),
                  const Divider(),
                  _DrawerSectionHeader(title: 'Communication'),
                  _DrawerItem(
                    icon: Icons.send,
                    title: l10n.sendNotification,
                    onTap: () => _navigate(context, '/compose-notification'),
                  ),
                  _DrawerItem(
                      icon: Icons.campaign,
                      title: l10n.sendReminders,
                      onTap: () => _navigate(context, '/reminders')),
                ],
                if (role == UserRole.secretary) ...[
                  _DrawerSectionHeader(title: l10n.myWork),
                  _DrawerItem(
                      icon: Icons.people_outline,
                      title: l10n.employees,
                      onTap: () => _navigate(context, '/employees')),
                  _DrawerItem(
                      icon: Icons.task_alt,
                      title: l10n.tasks,
                      onTap: () => _navigate(context, '/tasks')),
                  _DrawerItem(
                      icon: Icons.access_time,
                      title: l10n.attendance,
                      onTap: () => _navigate(context, '/attendance/overview')),
                  _DrawerItem(
                      icon: Icons.event_busy,
                      title: l10n.leaveRequests,
                      onTap: () => _navigate(context, '/leave-approval')),
                  const Divider(),
                  _DrawerSectionHeader(title: 'Communication'),
                  _DrawerItem(
                    icon: Icons.send,
                    title: l10n.sendNotification,
                    onTap: () => _navigate(context, '/compose-notification'),
                  ),
                  _DrawerItem(
                      icon: Icons.campaign,
                      title: l10n.sendReminders,
                      onTap: () => _navigate(context, '/reminders')),
                ],
                if (role == UserRole.employee) ...[
                  _DrawerSectionHeader(title: l10n.myWork),
                  _DrawerItem(
                      icon: Icons.task_alt,
                      title: l10n.myTasks,
                      onTap: () => _navigate(context, '/tasks')),
                  _DrawerItem(
                      icon: Icons.access_time,
                      title: l10n.myAttendance,
                      onTap: () => _navigate(context, '/attendance/employee')),
                  const Divider(),
                  _DrawerSectionHeader(title: l10n.pending),
                  _DrawerItem(
                      icon: Icons.event_busy,
                      title: l10n.leaveRequest,
                      onTap: () => _navigate(context, '/leave-request')),
                  _DrawerItem(
                      icon: Icons.payments,
                      title: l10n.salaryRequest,
                      onTap: () => _navigate(context, '/salary-request')),
                  _DrawerItem(
                      icon: Icons.account_balance,
                      title: l10n.myDeposits,
                      onTap: () => _navigate(context, '/my-deposits')),
                ],
                if (role == UserRole.volunteer) ...[
                  _DrawerSectionHeader(title: l10n.myWork),
                  _DrawerItem(
                      icon: Icons.task_alt,
                      title: l10n.myTasks,
                      onTap: () => _navigate(context, '/tasks')),
                  _DrawerItem(
                      icon: Icons.access_time,
                      title: l10n.myAttendance,
                      onTap: () => _navigate(context, '/volunteer/attendance')),
                ],
                const Divider(),
                _DrawerItem(
                  icon: Icons.notifications,
                  title: l10n.notifications,
                  trailing: unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                  onTap: () => _navigate(context, '/notifications'),
                ),
                _DrawerItem(
                  icon: Icons.person,
                  title: l10n.profileSettings,
                  onTap: () => _navigate(context, '/profile'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(l10n.signOut,
                style: TextStyle(color: theme.colorScheme.error)),
            onTap: () {
              Navigator.pop(context);
              ref.read(authViewModelProvider.notifier).signOut();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String path) {
    Navigator.pop(context);
    context.go(path);
  }
}

class _DrawerSectionHeader extends StatelessWidget {
  final String title;
  const _DrawerSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title),
      trailing: trailing,
      dense: true,
      onTap: onTap,
    );
  }
}
