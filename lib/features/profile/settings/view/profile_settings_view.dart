import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/providers/providers.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/core/providers/repository_providers.dart';
import 'package:vanguard/core/models/user_role.dart';
import 'package:vanguard/l10n/app_localizations.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentUser = ref.watch(currentUserProvider);
    final employeeAsync = ref.watch(currentEmployeeProfileProvider);

    debugPrint('PROFILE_DEBUG: User ID: ${currentUser.id}');
    debugPrint('PROFILE_DEBUG: Full Name: ${currentUser.fullName}');
    debugPrint('PROFILE_DEBUG: Email: ${currentUser.email}');
    debugPrint('PROFILE_DEBUG: Role: ${currentUser.role}');

    employeeAsync.when(
      data: (emp) {
        debugPrint('EMPLOYEE_DEBUG: Employee loaded: ${emp != null}');
        if (emp != null) {
          debugPrint('EMPLOYEE_DEBUG: Bank Account: "${emp.bankAccount}"');
          debugPrint('EMPLOYEE_DEBUG: ID Card: "${emp.idCard}"');
          debugPrint('EMPLOYEE_DEBUG: Employee ID: ${emp.id}');
        }
      },
      loading: () => debugPrint('EMPLOYEE_DEBUG: Loading employee...'),
      error: (e, st) =>
          debugPrint('EMPLOYEE_DEBUG: Error loading employee: $e'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileSettings),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            (currentUser.firstName.isNotEmpty &&
                                    currentUser.lastName.isNotEmpty)
                                ? '${currentUser.firstName[0]}${currentUser.lastName[0]}'
                                : '??',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              onPressed: _changeProfilePhoto,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser?.fullName ?? 'User',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.position ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.department ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                l10n.personalInfo,
                [
                  _buildInfoTile(
                    Icons.email,
                    l10n.email,
                    currentUser?.email ?? '',
                  ),
                  _buildInfoTile(
                    Icons.phone,
                    l10n.phone,
                    currentUser?.phone ?? '',
                  ),
                  _buildInfoTile(
                    Icons.business,
                    l10n.department,
                    currentUser?.department ?? '',
                  ),
                  _buildInfoTile(
                    Icons.work,
                    l10n.position,
                    currentUser?.position ?? '',
                  ),
                  _buildInfoTile(
                    Icons.calendar_today,
                    l10n.joinDate,
                    _formatDate(currentUser.joinDate),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (currentUser.role != UserRole.admin)
                _buildSection(
                  l10n.bankAccount,
                  [
                    employeeAsync.when(
                      data: (employee) => _buildInfoTile(
                        Icons.account_balance,
                        l10n.bankAccount,
                        (employee?.bankAccount != null &&
                                employee!.bankAccount.isNotEmpty)
                            ? employee.bankAccount
                            : l10n.noData,
                        onTap: _editBankDetails,
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: LinearProgressIndicator()),
                      ),
                      error: (_, __) => _buildInfoTile(
                          Icons.account_balance, l10n.bankAccount, l10n.error),
                    ),
                    employeeAsync.when(
                      data: (employee) => _buildInfoTile(
                        Icons.credit_card,
                        l10n.idCard,
                        (employee?.idCard != null &&
                                employee!.idCard.isNotEmpty)
                            ? employee.idCard
                            : l10n.noData,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              _buildSection(
                l10n.settings,
                [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.language),
                    subtitle: Text(currentLocale.languageCode == 'en'
                        ? l10n.english
                        : l10n.french),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showLanguageSelector,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode),
                    title: Text(l10n.darkMode),
                    subtitle: Text(l10n.theme),
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).state = value;
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(l10n.notifications),
                    subtitle: Text(l10n.notifications),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showNotificationSettings,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Security',
                [
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _changePassword,
                  ),
                  ListTile(
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('Biometric Login'),
                    subtitle: const Text('Use fingerprint or face ID'),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Biometric login coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Two-Factor Authentication'),
                    subtitle: const Text('Add an extra layer of security'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _setup2FA,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Support & Information',
                [
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get help with using the app'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showHelp,
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    subtitle: const Text('App version and information'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showAbout,
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('Read our privacy policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showPrivacyPolicy,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms of Service'),
                    subtitle: const Text('Terms and conditions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showTerms,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text(l10n.logout,
                        style: const TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: onTap != null ? const Icon(Icons.edit) : null,
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon!')),
    );
  }

  void _changeProfilePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery feature coming soon!')),
                );
              },
            ),
            if (true)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo removed!')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _editBankDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bank Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bank Account Number',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: 'Bank Account'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: 'Ecobank Cameroon'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bank details updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: Text(l10n.english),
              value: const Locale('en'),
              groupValue: ref.read(localeProvider),
              onChanged: (locale) {
                ref.read(localeProvider.notifier).state = locale!;
                Navigator.pop(dialogContext);
              },
            ),
            RadioListTile<Locale>(
              title: Text(l10n.french),
              value: const Locale('fr'),
              groupValue: ref.read(localeProvider),
              onChanged: (locale) {
                ref.read(localeProvider.notifier).state = locale!;
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _changePassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  helperText: 'At least 6 characters',
                ),
                obscureText: true,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: !isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (currentPasswordController.text.isEmpty) {
                        setDialogState(() => errorMessage =
                            'Please enter your current password');
                        return;
                      }
                      if (newPasswordController.text.length < 6) {
                        setDialogState(() => errorMessage =
                            'New password must be at least 6 characters');
                        return;
                      }
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        setDialogState(
                            () => errorMessage = 'New passwords do not match');
                        return;
                      }
                      if (currentPasswordController.text ==
                          newPasswordController.text) {
                        setDialogState(() => errorMessage =
                            'New password must be different from current');
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        final authRepo = ref.read(authRepositoryProvider);
                        await authRepo.changePassword(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                        );

                        if (!mounted) return;
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password changed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        String message =
                            'Failed to change password. Please try again.';
                        final errorString = e.toString().toLowerCase();
                        if (errorString.contains('wrong-password') ||
                            errorString.contains('invalid-credential')) {
                          message = 'Current password is incorrect.';
                        } else if (errorString.contains('weak-password')) {
                          message = 'New password is too weak.';
                        } else if (errorString
                            .contains('requires-recent-login')) {
                          message =
                              'Please log out and log in again before changing password.';
                        }
                        setDialogState(() {
                          isLoading = false;
                          errorMessage = message;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _setup2FA() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('2FA setup coming soon!')),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & support coming soon!')),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Vanguard',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.work),
      children: [
        const Text('Workforce Management System for Cameroon businesses.'),
        const SizedBox(height: 16),
        const Text('Built with Flutter & Material 3 Design.'),
      ],
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon!')),
    );
  }

  void _showTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service coming soon!')),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authViewModelProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
