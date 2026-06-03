import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/salary_request.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';
import 'package:vanguard/widgets/wf_status_chip.dart';

class SalaryApprovalListScreen extends ConsumerStatefulWidget {
  const SalaryApprovalListScreen({super.key});

  @override
  ConsumerState<SalaryApprovalListScreen> createState() =>
      _SalaryApprovalListScreenState();
}

class _SalaryApprovalListScreenState
    extends ConsumerState<SalaryApprovalListScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredRequests = _getFilteredRequests();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final salaryState = ref.watch(salaryViewModelProvider);
                  final salaryRequests = salaryState.requests;
                  final count = filter == 'All'
                      ? salaryRequests.length
                      : salaryRequests
                          .where((r) =>
                              r.status.name.toLowerCase() ==
                              filter.toLowerCase())
                          .length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('$filter ($count)'),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: filteredRequests.isEmpty
                ? const WFEmptyState(
                    icon: Icons.pending_actions,
                    title: 'No requests found',
                    message:
                        'There are no salary requests matching your filter.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    child: Icon(
                                      _getTypeIcon(request.type),
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          request.employeeFullName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _getTypeDisplayName(request.type),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'XAF ${_formatCurrency(request.amount)}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                request.reason,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Requested on ${_formatDate(request.requestDate)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  WFStatusBadge(
                                    label: request.status.name.toUpperCase(),
                                    color: _getStatusColor(request.status),
                                  ),
                                ],
                              ),
                              if (request.status ==
                                  SalaryRequestStatus.pending) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _handleRequest(request, false),
                                        icon: const Icon(Icons.close, size: 18),
                                        label: const Text('Reject'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _handleRequest(request, true),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (request.status !=
                                      SalaryRequestStatus.pending &&
                                  request.approvedBy != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '${request.status == SalaryRequestStatus.approved ? 'Approved' : 'Rejected'} on ${_formatDate(request.approvalDate!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<SalaryRequest> _getFilteredRequests() {
    final salaryState = ref.watch(salaryViewModelProvider);
    final salaryRequests = salaryState.requests;
    if (_selectedFilter == 'All') {
      return salaryRequests;
    }
    return salaryRequests.where((request) {
      return request.status.name.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  String _getTypeDisplayName(SalaryRequestType type) {
    switch (type) {
      case SalaryRequestType.salary:
        return 'Salary Advance';
      case SalaryRequestType.bonus:
        return 'Performance Bonus';
      case SalaryRequestType.overtime:
        return 'Overtime Payment';
      case SalaryRequestType.deduction:
        return 'Deduction Adjustment';
      case SalaryRequestType.advance:
        return 'Salary Advance Request';
    }
  }

  IconData _getTypeIcon(SalaryRequestType type) {
    switch (type) {
      case SalaryRequestType.salary:
        return Icons.payments;
      case SalaryRequestType.bonus:
        return Icons.star;
      case SalaryRequestType.overtime:
        return Icons.schedule;
      case SalaryRequestType.deduction:
        return Icons.remove_circle;
      case SalaryRequestType.advance:
        return Icons.account_balance_wallet;
    }
  }

  Color _getStatusColor(SalaryRequestStatus status) {
    switch (status) {
      case SalaryRequestStatus.pending:
        return Colors.orange;
      case SalaryRequestStatus.approved:
        return Colors.green;
      case SalaryRequestStatus.rejected:
        return Colors.red;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleRequest(SalaryRequest request, bool approve) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve Request' : 'Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${approve ? 'Approve' : 'Reject'} ${request.employeeFullName}\'s ${_getTypeDisplayName(request.type).toLowerCase()} request?'),
            const SizedBox(height: 8),
            Text(
              'Amount: XAF ${_formatCurrency(request.amount)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText:
                    approve ? 'Approval Notes (Optional)' : 'Rejection Reason',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
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
                SnackBar(
                  content: Text(
                    'Request ${approve ? 'approved' : 'rejected'} successfully!',
                  ),
                  backgroundColor: approve ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.green : Colors.red,
            ),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Requests'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
