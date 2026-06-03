import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanguard/core/models/salary_request.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/primary_button.dart';
import 'package:vanguard/widgets/wf_status_chip.dart';

class SalaryRequestScreen extends ConsumerStatefulWidget {
  const SalaryRequestScreen({super.key});

  @override
  ConsumerState<SalaryRequestScreen> createState() =>
      _SalaryRequestScreenState();
}

class _SalaryRequestScreenState extends ConsumerState<SalaryRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  SalaryRequestType _selectedType = SalaryRequestType.overtime;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Request'),
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
                    Icon(
                      Icons.payments,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Request Additional Payment',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submit your request for overtime, bonus, or other payments',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
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
                        'Request Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<SalaryRequestType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Request Type',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: SalaryRequestType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getTypeDisplayName(type)),
                          );
                        }).toList(),
                        onChanged: (type) {
                          setState(() {
                            _selectedType = type!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (XAF)',
                          prefixIcon: Icon(Icons.money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (double.tryParse(value!) == null)
                            return 'Invalid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason/Description',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Submit Request',
                        onPressed: _submitRequest,
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
                          ref.watch(currentUserSalaryProvider).requests.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final salaryRequests =
                            ref.watch(currentUserSalaryProvider).requests;
                        if (salaryRequests.isEmpty) {
                          return const ListTile(
                            title: Text('No salary requests found'),
                          );
                        }
                        final request = salaryRequests[index];
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
                            '${_getTypeDisplayName(request.type)} - XAF ${_formatCurrency(request.amount)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request.reason),
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(currentUserSalaryProvider.notifier).loadSalaryRequests();
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider);

      final request = SalaryRequest(
        id: '',
        employeeId: user.id,
        employeeFullName: user.fullName,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        reason: _reasonController.text,
        requestDate: DateTime.now(),
        status: SalaryRequestStatus.pending,
      );

      final success = await ref
          .read(currentUserSalaryProvider.notifier)
          .createSalaryRequest(request);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Salary request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          _amountController.clear();
          _reasonController.clear();
          setState(() {
            _selectedType = SalaryRequestType.overtime;
          });
        } else {
          final error = ref.read(currentUserSalaryProvider).error;
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Salary Requests',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount:
                        ref.watch(currentUserSalaryProvider).requests.length,
                    itemBuilder: (context, index) {
                      final salaryRequests =
                          ref.watch(currentUserSalaryProvider).requests;
                      if (salaryRequests.isEmpty) {
                        return const Center(
                          child: Text('No requests found'),
                        );
                      }
                      final request = salaryRequests[index];
                      return Card(
                        child: ListTile(
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
                            '${_getTypeDisplayName(request.type)} - XAF ${_formatCurrency(request.amount)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(request.reason),
                          trailing: WFStatusBadge(
                            label: request.status.name.toUpperCase(),
                            color: _getStatusColor(request.status),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
