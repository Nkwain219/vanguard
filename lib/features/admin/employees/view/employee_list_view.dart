import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/employee.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_employee_card.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = 'All';

  final List<String> _departments = [
    'All',
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeViewModelProvider.notifier).loadEmployees();
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    ref
        .read(employeeViewModelProvider.notifier)
        .setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRole = ref.watch(currentRoleProvider);
    final employeeState = ref.watch(employeeViewModelProvider);

    List<Employee> filteredEmployees = employeeState.filteredEmployees;
    if (_selectedDepartment != 'All') {
      filteredEmployees = filteredEmployees
          .where((e) => e.department == _selectedDepartment)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          if (currentRole.canManageEmployees)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => context.push('/create-employee'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search employees...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _departments.map((dept) {
                      final isSelected = _selectedDepartment == dept;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(dept),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDepartment = dept;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (employeeState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (employeeState.isLoading) const SizedBox(width: 8),
                Text(
                  '${filteredEmployees.length} employees found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref
                        .read(employeeViewModelProvider.notifier)
                        .loadEmployees(forceRefresh: true);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () => _showSortOptions(filteredEmployees),
                ),
              ],
            ),
          ),
          Expanded(
            child: employeeState.isLoading && employeeState.employees.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredEmployees.isEmpty
                    ? const WFEmptyState(
                        icon: Icons.people,
                        title: 'No employees found',
                        message:
                            'Try adjusting your search criteria or add new employees',
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(employeeViewModelProvider.notifier)
                            .loadEmployees(forceRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = filteredEmployees[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: WFEmployeeCard(
                                employee: employee,
                                onTap: () =>
                                    context.push('/employee/${employee.id}'),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(List<Employee> employees) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name (A-Z)'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name (Z-A)'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Department'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Join Date'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
