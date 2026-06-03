import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanguard/core/models/deposit.dart';
import 'package:vanguard/core/utils/string_extensions.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_empty_state.dart';
import 'package:vanguard/widgets/wf_status_chip.dart';

class DepositHistoryScreen extends ConsumerStatefulWidget {
  const DepositHistoryScreen({super.key});

  @override
  ConsumerState<DepositHistoryScreen> createState() =>
      _DepositHistoryScreenState();
}

class _DepositHistoryScreenState extends ConsumerState<DepositHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(currentUserDepositProvider.notifier).loadDeposits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final depositState = ref.watch(currentUserDepositProvider);
    final deposits = depositState.deposits;
    final filteredDeposits = _getFilteredDeposits(deposits);
    final totalAmount = _getTotalAmount(deposits);
    final approvedAmount = _getApprovedAmount(deposits);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(currentUserDepositProvider.notifier).loadDeposits(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: depositState.isLoading && deposits.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Submitted',
                          'XAF ${_formatCurrency(totalAmount)}',
                          Colors.blue,
                          theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Approved',
                          'XAF ${_formatCurrency(approvedAmount)}',
                          Colors.green,
                          theme,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final count = filter == 'All'
                            ? deposits.length
                            : deposits
                                .where(
                                    (d) => d.status.name.capitalize() == filter)
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
                const SizedBox(height: 16),
                Expanded(
                  child: filteredDeposits.isEmpty
                      ? WFEmptyState(
                          icon: Icons.receipt_long,
                          title: 'No deposits found',
                          message: _selectedFilter == 'All'
                              ? 'You haven\'t submitted any deposit requests yet.'
                              : 'No deposits found with status $_selectedFilter',
                          buttonText: _selectedFilter == 'All'
                              ? 'Submit Deposit'
                              : null,
                          onButtonPressed: _selectedFilter == 'All'
                              ? () => Navigator.pop(context)
                              : null,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredDeposits.length,
                          itemBuilder: (context, index) {
                            final deposit = filteredDeposits[index];
                            return _buildDepositCard(deposit, theme);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildDepositCard(Deposit deposit, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(deposit.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(deposit.type),
                    color: _getTypeColor(deposit.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeDisplayName(deposit.type),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'XAF ${_formatCurrency(deposit.amount)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                WFStatusBadge(
                  label: deposit.status.name.toUpperCase(),
                  color: _getStatusColor(deposit.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deposit.reason,
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
                  'Submitted on ${_formatDate(deposit.requestDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (deposit.attachments.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.attachment,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${deposit.attachments.length} attachments',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            if (deposit.status != DepositStatus.pending &&
                deposit.approvalDate != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(deposit.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      deposit.status == DepositStatus.approved
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 16,
                      color: _getStatusColor(deposit.status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${deposit.status == DepositStatus.approved ? 'Approved' : 'Rejected'} on ${_formatDate(deposit.approvalDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(deposit.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (deposit.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Text(
                    'Attachments:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: deposit.attachments.map((attachment) {
                        return ActionChip(
                          label: Text(
                            attachment,
                            style: const TextStyle(fontSize: 10),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Viewing $attachment'),
                              ),
                            );
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
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
            style: theme.textTheme.headlineSmall?.copyWith(
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

  List<Deposit> _getFilteredDeposits(List<Deposit> deposits) {
    if (_selectedFilter == 'All') return deposits;
    return deposits
        .where((d) => d.status.name.capitalize() == _selectedFilter)
        .toList();
  }

  double _getTotalAmount(List<Deposit> deposits) {
    return deposits.fold(0.0, (sum, d) => sum + d.amount);
  }

  double _getApprovedAmount(List<Deposit> deposits) {
    return deposits
        .where((d) => d.status == DepositStatus.approved)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  String _getTypeDisplayName(DepositType type) {
    switch (type) {
      case DepositType.travel:
        return 'Travel Expenses';
      case DepositType.meal:
        return 'Meal Allowance';
      case DepositType.equipment:
        return 'Equipment Purchase';
      case DepositType.office:
        return 'Office Supplies';
      case DepositType.other:
        return 'Other Expenses';
    }
  }

  IconData _getTypeIcon(DepositType type) {
    switch (type) {
      case DepositType.travel:
        return Icons.flight;
      case DepositType.meal:
        return Icons.restaurant;
      case DepositType.equipment:
        return Icons.devices;
      case DepositType.office:
        return Icons.business;
      case DepositType.other:
        return Icons.more_horiz;
    }
  }

  Color _getTypeColor(DepositType type) {
    switch (type) {
      case DepositType.travel:
        return Colors.blue;
      case DepositType.meal:
        return Colors.orange;
      case DepositType.equipment:
        return Colors.purple;
      case DepositType.office:
        return Colors.green;
      case DepositType.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(DepositStatus status) {
    switch (status) {
      case DepositStatus.pending:
        return Colors.orange;
      case DepositStatus.approved:
        return Colors.green;
      case DepositStatus.rejected:
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Deposits'),
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
