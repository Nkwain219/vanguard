import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/primary_button.dart';
import 'package:vanguard/core/models/user_role.dart';

class CreateEditEmployeeScreen extends ConsumerStatefulWidget {
  final String? employeeId;

  const CreateEditEmployeeScreen({
    super.key,
    this.employeeId,
  });

  @override
  ConsumerState<CreateEditEmployeeScreen> createState() =>
      _CreateEditEmployeeScreenState();
}

class _CreateEditEmployeeScreenState
    extends ConsumerState<CreateEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _idCardController = TextEditingController();

  String _selectedDepartment = 'IT';
  UserRole _selectedRole = UserRole.employee;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _departments = [
    'Administration',
    'Human Resources',
    'IT',
    'Finance',
    'Operations',
    'Marketing',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employeeId != null) {
      _loadEmployeeData();
    }
  }

  void _loadEmployeeData() {
    final employeeState = ref.read(employeeViewModelProvider);
    final employee = employeeState.employees
        .where((e) => e.id == widget.employeeId)
        .firstOrNull;

    if (employee != null) {
      _firstNameController.text = employee.firstName;
      _lastNameController.text = employee.lastName;
      _emailController.text = employee.email;
      _phoneController.text = employee.phone;
      _positionController.text = employee.position;
      _salaryController.text = employee.salary.toString();
      _bankAccountController.text = employee.bankAccount;
      _idCardController.text = employee.idCard;
      _selectedDepartment = employee.department;
      _isActive = employee.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.employeeId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Employee' : 'Add Employee'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEditing)
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'A secure password will be auto-generated and sent to the employee\'s email address.',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!isEditing) const SizedBox(height: 16),
              _buildSectionCard(
                'Personal Information',
                [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      helperText: isEditing
                          ? null
                          : 'Login credentials will be sent here',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isEditing,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (!value!.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
                theme,
              ),
              const SizedBox(height: 24),
              if (!isEditing)
                _buildSectionCard(
                  'User Role',
                  [
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(_roleLabel(role)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                  ],
                  theme,
                ),
              if (!isEditing) const SizedBox(height: 24),
              _buildSectionCard(
                'Employment Information',
                [
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.business),
                    ),
                    items: _departments.map((dept) {
                      return DropdownMenuItem(value: dept, child: Text(dept));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      prefixIcon: Icon(Icons.work),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _salaryController,
                    decoration: InputDecoration(
                      labelText: _selectedRole == UserRole.volunteer
                          ? 'Stipend (XAF)'
                          : 'Salary (XAF)',
                      prefixIcon: const Icon(Icons.payments),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
                theme,
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                'Banking Information',
                [
                  TextFormField(
                    controller: _bankAccountController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Account Number',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _idCardController,
                    decoration: const InputDecoration(
                      labelText: 'ID Card Number',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
                theme,
              ),
              const SizedBox(height: 24),
              if (isEditing)
                _buildSectionCard(
                  'Status',
                  [
                    SwitchListTile(
                      title: const Text('Active Employee'),
                      subtitle: Text(_isActive
                          ? 'Employee can access system'
                          : 'Employee cannot access system'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ],
                  theme,
                ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      text: 'Cancel',
                      onPressed: () => context.pop(),
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: isEditing
                          ? 'Update Employee'
                          : 'Create & Send Invite',
                      onPressed: _saveEmployee,
                      isLoading: _isLoading,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.secretary:
        return 'Secretary';
      case UserRole.employee:
        return 'Employee';
      case UserRole.volunteer:
        return 'Volunteer';
    }
  }

  Widget _buildSectionCard(
      String title, List<Widget> children, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final isEditing = widget.employeeId != null;

      if (isEditing) {
        final employeeState = ref.read(employeeViewModelProvider);
        final existingEmployee = employeeState.employees.firstWhere(
          (e) => e.id == widget.employeeId,
          orElse: () => throw Exception('Employee not found'),
        );

        final updatedEmployee = existingEmployee.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
          department: _selectedDepartment,
          position: _positionController.text.trim(),
          salary: double.tryParse(_salaryController.text) ?? 0,
          bankAccount: _bankAccountController.text.trim(),
          idCard: _idCardController.text.trim(),
          isActive: _isActive,
        );

        await ref
            .read(employeeViewModelProvider.notifier)
            .updateEmployee(updatedEmployee);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Employee updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final authViewModel = ref.read(authViewModelProvider.notifier);
        await authViewModel.refreshToken();

        final authUser = ref.read(authViewModelProvider).user;
        debugPrint('CREATE_USER_DEBUG: Current Auth User ID: ${authUser?.id}');
        debugPrint(
            'CREATE_USER_DEBUG: Device Time: ${DateTime.now().toIso8601String()}');
        debugPrint(
            'CREATE_USER_DEBUG: Calling createUser for: ${_emailController.text.trim()}');

        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser == null) {
          throw Exception('No Firebase Auth user found. Please log in again.');
        }

        final idToken = await fbUser.getIdToken(true);
        debugPrint('CREATE_USER_DEBUG: Firebase UID: ${fbUser.uid}');
        debugPrint(
            'CREATE_USER_DEBUG: ID Token obtained: ${idToken != null && idToken.isNotEmpty ? "YES (${idToken.length} chars)" : "NO"}');

        final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
        final callable = functions.httpsCallable('createUser');

        final result = await callable.call({
          'email': _emailController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole.name,
          'department': _selectedDepartment,
          'position': _positionController.text.trim(),
          'salary': double.tryParse(_salaryController.text) ?? 0,
          'bankAccount': _bankAccountController.text.trim(),
          'idCard': _idCardController.text.trim(),
        });

        final data = result.data as Map<String, dynamic>;

        if (data['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'User created successfully!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
          }

          ref.read(employeeViewModelProvider.notifier).loadEmployees();
        }
      }

      if (mounted) {
        context.pop();
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          'CREATE_USER_DEBUG: FirebaseFunctionsException: [${e.code}] ${e.message}');
      debugPrint('CREATE_USER_DEBUG: Details: ${e.details}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Failed to create user. [${e.code}]'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('CREATE_USER_DEBUG: Unexpected Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _bankAccountController.dispose();
    _idCardController.dispose();
    super.dispose();
  }
}
