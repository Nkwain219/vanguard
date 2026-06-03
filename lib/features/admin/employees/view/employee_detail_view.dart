import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vanguard/core/models/employee.dart';
import 'package:vanguard/core/models/task.dart';
import 'package:vanguard/core/models/salary_request.dart';
import 'package:vanguard/core/models/employee_document.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final String employeeId;

  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  @override
  ConsumerState<EmployeeDetailScreen> createState() =>
      _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(attendanceViewModelProvider(widget.employeeId).notifier)
          .loadAttendance();
      ref
          .read(documentViewModelProvider(widget.employeeId).notifier)
          .loadDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRole = ref.watch(currentRoleProvider);

    final employeeState = ref.watch(employeeViewModelProvider);
    final employee = employeeState.employees.firstWhere(
      (e) => e.id == widget.employeeId,
      orElse: () => employeeState.employees.isNotEmpty
          ? employeeState.employees.first
          : Employee(
              id: '',
              firstName: 'Unknown',
              lastName: '',
              email: '',
              phone: '',
              department: '',
              position: '',
              salary: 0,
              bankAccount: '',
              idCard: '',
              joinDate: DateTime.now(),
              isActive: false,
            ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(employee.fullName),
        actions: [
          if (currentRole.canManageEmployees)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: const Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit Employee'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'deactivate',
                  child: Row(
                    children: [
                      Icon(
                        employee.isActive ? Icons.block : Icons.check_circle,
                        color: employee.isActive ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(employee.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    context.push('/edit-employee/${employee.id}');
                    break;
                  case 'deactivate':
                    _showDeactivateConfirmation(employee);
                    break;
                }
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Profile', icon: Icon(Icons.person)),
            Tab(text: 'Attendance', icon: Icon(Icons.schedule)),
            Tab(text: 'Tasks', icon: Icon(Icons.task)),
            Tab(text: 'Payroll', icon: Icon(Icons.payments)),
            Tab(text: 'Documents', icon: Icon(Icons.folder)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(employee, theme),
          _buildAttendanceTab(employee, theme),
          _buildTasksTab(employee, theme),
          _buildPayrollTab(employee, theme),
          _buildDocumentsTab(employee, theme),
        ],
      ),
    );
  }

  Widget _buildProfileTab(Employee employee, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      employee.firstName.isNotEmpty
                          ? employee.firstName[0] +
                              (employee.lastName.isNotEmpty
                                  ? employee.lastName[0]
                                  : '')
                          : '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.position,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: employee.isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            employee.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color:
                                  employee.isActive ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.email, 'Email', employee.email),
                  _buildInfoRow(Icons.phone, 'Phone', employee.phone),
                  _buildInfoRow(
                      Icons.business, 'Department', employee.department),
                  _buildInfoRow(Icons.work, 'Position', employee.position),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employment Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.date_range, 'Join Date',
                      _formatDate(employee.joinDate)),
                  _buildInfoRow(Icons.payments, 'Salary',
                      'XAF ${_formatCurrency(employee.salary)}'),
                  _buildInfoRow(Icons.account_balance, 'Bank Account',
                      employee.bankAccount),
                  _buildInfoRow(Icons.credit_card, 'ID Card', employee.idCard),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(Employee employee, ThemeData theme) {
    final attendanceState = ref.watch(attendanceViewModelProvider(employee.id));

    if (attendanceState.isLoading && attendanceState.records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = attendanceState.summary;
    final records = attendanceState.records;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Days Present',
                            '${summary.presentDays}',
                            Colors.green,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Days Absent',
                            '${summary.absentDays}',
                            Colors.red,
                            theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Late Days',
                            '${summary.lateDays}',
                            Colors.orange,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Total Hours',
                            summary.totalHoursWorked.toStringAsFixed(1),
                            Colors.blue,
                            theme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const WFEmptyState(
              icon: Icons.access_time,
              title: 'No Attendance Records',
              message: 'No attendance records found for this employee.',
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Recent Attendance',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/attendance/overview'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: records.take(5).length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final status = record.status;

                        final clockIn = record.clockIn != null
                            ? '${record.clockIn!.hour.toString().padLeft(2, '0')}:${record.clockIn!.minute.toString().padLeft(2, '0')}'
                            : '--:--';

                        final clockOut = record.clockOut != null
                            ? '${record.clockOut!.hour.toString().padLeft(2, '0')}:${record.clockOut!.minute.toString().padLeft(2, '0')}'
                            : '--:--';

                        Color statusColor;
                        switch (status.name) {
                          case 'present':
                            statusColor = Colors.green;
                            break;
                          case 'absent':
                            statusColor = Colors.red;
                            break;
                          case 'late':
                            statusColor = Colors.orange;
                            break;
                          case 'halfDay':
                            statusColor = Colors.blue;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            child: Icon(
                              status.name == 'late'
                                  ? Icons.schedule
                                  : Icons.check,
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          title: Text(_formatDate(record.date)),
                          subtitle: Text('$clockIn - $clockOut'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.name.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(Employee employee, ThemeData theme) {
    final taskState = ref.watch(taskViewModelProvider);
    final employeeTasks = taskState.tasks
        .where((task) => task.assigneeIds.contains(employee.id))
        .toList();

    if (employeeTasks.isEmpty) {
      return const WFEmptyState(
        icon: Icons.task,
        title: 'No tasks assigned',
        message: 'This employee has no tasks assigned yet',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employeeTasks.length,
      itemBuilder: (context, index) {
        final task = employeeTasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(task.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.status.name.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(task.status),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Due: ${_formatDate(task.dueDate!)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: task.progress > 0
                ? CircularProgressIndicator(
                    value: task.progress,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  )
                : null,
            onTap: () => context.push('/task/${task.id}'),
          ),
        );
      },
    );
  }

  Widget _buildPayrollTab(Employee employee, ThemeData theme) {
    final salaryRequests = ref.watch(salaryRequestListProvider);
    final employeeRequests =
        salaryRequests.where((r) => r.employeeId == employee.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salary Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.payments,
                    'Base Salary',
                    'XAF ${_formatCurrency(employee.salary)}',
                  ),
                  _buildInfoRow(
                    Icons.account_balance,
                    'Bank Account',
                    employee.bankAccount,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Payment History',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (employeeRequests.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('No payment history found')),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: employeeRequests.take(5).length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final request = employeeRequests[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                request.status == SalaryRequestStatus.approved
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                            child: Icon(Icons.payments,
                                color: request.status ==
                                        SalaryRequestStatus.approved
                                    ? Colors.green
                                    : Colors.orange,
                                size: 20),
                          ),
                          title: Text(
                              '${request.type.name.toUpperCase()} Payment'),
                          subtitle: Text(_formatDate(request.requestDate)),
                          trailing: Text(
                            'XAF ${_formatCurrency(request.amount)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(Employee employee, ThemeData theme) {
    final documentState = ref.watch(documentViewModelProvider(employee.id));
    final documents = documentState.documents;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${documents.length} Documents',
                style: theme.textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: () => _showUploadDialog(employee),
                icon: const Icon(Icons.upload),
                label: const Text('Upload Document'),
              ),
            ],
          ),
        ),
        if (documentState.isLoading && documents.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator())),
        if (!documentState.isLoading && documents.isEmpty)
          Expanded(
            child: WFEmptyState(
              icon: Icons.folder_open,
              title: 'No Documents',
              message: 'Upload documents for ${employee.firstName}.',
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        _getDocumentIcon(doc.type),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(doc.name),
                    subtitle: Text(
                        '${doc.type.name.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ').toUpperCase()} • ${doc.formattedSize}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('View'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'view') {
                          _launchUrl(doc.fileUrl);
                        } else if (value == 'delete') {
                          _confirmDeleteDocument(doc.id, doc.name);
                        }
                      },
                    ),
                    onTap: () => _launchUrl(doc.fileUrl),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showDeactivateConfirmation(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            employee.isActive ? 'Deactivate Employee' : 'Activate Employee'),
        content: Text(
          employee.isActive
              ? 'Are you sure you want to deactivate ${employee.fullName}? They will not be able to access the system.'
              : 'Are you sure you want to activate ${employee.fullName}? They will regain access to the system.',
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
                SnackBar(
                  content: Text(
                    employee.isActive
                        ? '${employee.fullName} has been deactivated'
                        : '${employee.fullName} has been activated',
                  ),
                ),
              );
            },
            child: Text(employee.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.contract:
        return Icons.description;
      case DocumentType.idCard:
        return Icons.badge;
      case DocumentType.resume:
        return Icons.work;
      case DocumentType.certificate:
        return Icons.workspace_premium;
      case DocumentType.bankDetails:
        return Icons.account_balance;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }

  Future<void> _showUploadDialog(Employee employee) async {
    final nameController = TextEditingController();
    DocumentType selectedType = DocumentType.other;
    File? selectedFile;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Upload Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Document Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DocumentType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Document Type'),
                items: DocumentType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name
                              .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ')
                              .toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedType = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedFile != null
                          ? selectedFile!.path.split('/').last
                          : 'No file selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        setState(() =>
                            selectedFile = File(result.files.single.path!));

                        if (nameController.text.isEmpty) {
                          nameController.text = result.files.single.name;
                        }
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Pick File'),
                  )
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedFile == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _uploadDocument(
                          file: selectedFile!,
                          name: nameController.text,
                          type: selectedType,
                          employeeId: employee.id);
                    },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadDocument({
    required File file,
    required String name,
    required DocumentType type,
    required String employeeId,
  }) async {
    final notifier = ref.read(documentViewModelProvider(employeeId).notifier);
    final currentUser = ref.read(currentUserProvider);

    final success = await notifier.uploadDocument(
        file: file, name: name, type: type, uploadedBy: currentUser.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Document uploaded successfully' : 'Upload failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _confirmDeleteDocument(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(documentViewModelProvider(widget.employeeId).notifier)
                  .deleteDocument(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
