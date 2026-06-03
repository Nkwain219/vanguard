import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanguard/core/models/leave_request.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/primary_button.dart';
import 'package:vanguard/widgets/wf_status_chip.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  LeaveType _selectedType = LeaveType.annual;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(leaveViewModelProvider.notifier).loadLeaveRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysDifference = _startDate != null && _endDate != null
        ? _endDate!.difference(_startDate!).inDays + 1
        : 0;

    final leaveState = ref.watch(leaveViewModelProvider);
    final balance = leaveState.balance;
    final remainingAnnual = balance?.annualRemaining ?? 0;
    final totalUsed = (balance?.annualUsed ?? 0) + (balance?.sickUsed ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Leave Balance',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$remainingAnnual days remaining this year',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceItem(
                              'Annual',
                              '${balance?.annualRemaining ?? 0}',
                              Colors.green,
                              theme),
                        ),
                        Expanded(
                          child: _buildBalanceItem(
                              'Sick',
                              '${balance?.sickRemaining ?? 0}',
                              Colors.blue,
                              theme),
                        ),
                        Expanded(
                          child: _buildBalanceItem(
                              'Used', '$totalUsed', Colors.orange, theme),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Leave Request',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<LeaveType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Leave Type',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: LeaveType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_getTypeIcon(type), size: 20),
                                const SizedBox(width: 8),
                                Text(_getTypeDisplayName(type)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (type) {
                          setState(() {
                            _selectedType = type!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.calendar_today),
                              title: Text(
                                _startDate == null
                                    ? 'Start Date'
                                    : _formatDate(_startDate!),
                              ),
                              subtitle: _startDate == null
                                  ? const Text('Select start date')
                                  : null,
                              onTap: () => _selectDate(true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.event),
                              title: Text(
                                _endDate == null
                                    ? 'End Date'
                                    : _formatDate(_endDate!),
                              ),
                              subtitle: _endDate == null
                                  ? const Text('Select end date')
                                  : null,
                              onTap: () => _selectDate(false),
                            ),
                          ),
                        ],
                      ),
                      if (daysDifference > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: theme.colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total days: $daysDifference',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Describe the reason for your leave...',
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Submit Request',
                        onPressed: _canSubmit() ? _submitRequest : null,
                        isLoading: _isLoading,
                        isFullWidth: true,
                        icon: Icons.send,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Recent Requests',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _viewAllRequests,
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          ref.watch(leaveViewModelProvider).requests.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final leaveRequests =
                            ref.watch(leaveViewModelProvider).requests;
                        if (leaveRequests.isEmpty) {
                          return const ListTile(
                            title: Text('No leave requests found'),
                          );
                        }
                        final request = leaveRequests[index];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(request.status)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getTypeIcon(request.type),
                              color: _getStatusColor(request.status),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '${_getTypeDisplayName(request.type)} - ${request.days} days',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}'),
                              const SizedBox(height: 4),
                              Text(
                                'Requested on ${_formatDate(request.requestDate)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: WFStatusBadge(
                            label: request.status.name.toUpperCase(),
                            color: _getStatusColor(request.status),
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
      String label, String value, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _startDate != null &&
        _endDate != null &&
        _reasonController.text.isNotEmpty &&
        !_isLoading;
  }

  String _getTypeDisplayName(LeaveType type) {
    switch (type) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.maternity:
        return 'Maternity Leave';
      case LeaveType.paternity:
        return 'Paternity Leave';
      case LeaveType.emergency:
        return 'Emergency Leave';
      case LeaveType.unpaid:
        return 'Unpaid Leave';
    }
  }

  IconData _getTypeIcon(LeaveType type) {
    switch (type) {
      case LeaveType.annual:
        return Icons.beach_access;
      case LeaveType.sick:
        return Icons.local_hospital;
      case LeaveType.maternity:
        return Icons.child_care;
      case LeaveType.paternity:
        return Icons.family_restroom;
      case LeaveType.emergency:
        return Icons.emergency;
      case LeaveType.unpaid:
        return Icons.money_off;
    }
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ??
            _startDate?.add(const Duration(days: 1)) ??
            DateTime.now());

    final firstDate =
        isStartDate ? DateTime.now() : (_startDate ?? DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(date)) {
            _endDate = null;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || !_canSubmit()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider);

      final days = _endDate!.difference(_startDate!).inDays + 1;

      final docId = '${user.id}_${DateTime.now().millisecondsSinceEpoch}';

      final request = LeaveRequest(
        id: docId,
        employeeId: user.id,
        employeeFullName: user.fullName,
        type: _selectedType,
        startDate: _startDate!,
        endDate: _endDate!,
        days: days,
        reason: _reasonController.text,
        status: LeaveStatus.pending,
        requestDate: DateTime.now(),
      );

      final success = await ref
          .read(leaveViewModelProvider.notifier)
          .createLeaveRequest(request);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leave request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          _reasonController.clear();
          setState(() {
            _selectedType = LeaveType.annual;
            _startDate = null;
            _endDate = null;
          });
        } else {
          final error = ref.read(leaveViewModelProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to submit request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewAllRequests() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final requests = ref.watch(leaveViewModelProvider).requests;

          return Column(
            children: [
              AppBar(
                title: const Text('Leave History'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: requests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No leave history found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: requests.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request.status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getTypeIcon(request.type),
                                color: _getStatusColor(request.status),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              '${_getTypeDisplayName(request.type)} - ${request.days} days',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}'),
                                const SizedBox(height: 4),
                                Text(
                                  'Requested on ${_formatDate(request.requestDate)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (request.reason.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Reason: ${request.reason}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontStyle: FontStyle.italic),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: WFStatusBadge(
                              label: request.status.name.toUpperCase(),
                              color: _getStatusColor(request.status),
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
