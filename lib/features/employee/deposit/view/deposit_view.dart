import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/deposit.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/primary_button.dart';

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  DepositType _selectedType = DepositType.office;
  final List<String> _attachments = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Deposit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/deposit-history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: theme.colorScheme.secondary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 60,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Submit Expense Report',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Request reimbursement for business expenses',
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
                        'Expense Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<DepositType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Expense Category',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: DepositType.values.map((type) {
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
                          labelText: 'Description/Reason',
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Describe the expense details...',
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ],
                  ),
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
                          'Receipts & Documents',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addAttachment,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Add Photo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload receipts or photos of your expenses for faster approval',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_attachments.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No attachments yet',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: _addAttachment,
                              child: const Text('Add Receipt'),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _attachments.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _attachments.length) {
                            return GestureDetector(
                              onTap: _addAttachment,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.5),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image, size: 32),
                                      SizedBox(height: 4),
                                      Text('Receipt',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeAttachment(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
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
                    Text(
                      'Quick Expenses',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickExpenseChip('Taxi - 2,000 XAF', 2000),
                        _buildQuickExpenseChip('Lunch - 1,500 XAF', 1500),
                        _buildQuickExpenseChip('Parking - 500 XAF', 500),
                        _buildQuickExpenseChip(
                            'Office Supplies - 5,000 XAF', 5000),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Submit Deposit Request',
              onPressed: _submitDeposit,
              isLoading: _isLoading,
              isFullWidth: true,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickExpenseChip(String label, double amount) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _amountController.text = amount.toString();
          _reasonController.text = label.split(' - ')[0];
        });
      },
    );
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

  void _addAttachment() {
    setState(() {
      _attachments.add('receipt_${_attachments.length + 1}.jpg');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _submitDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider);

      final docId = '${user.id}_${DateTime.now().millisecondsSinceEpoch}';

      final deposit = Deposit(
        id: docId,
        employeeId: user.id,
        employeeFullName: user.fullName,
        amount: double.parse(_amountController.text),
        type: _selectedType,
        reason: _reasonController.text,
        status: DepositStatus.pending,
        requestDate: DateTime.now(),
        attachments: List.from(_attachments),
      );

      final success = await ref
          .read(currentUserDepositProvider.notifier)
          .createDeposit(deposit);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deposit request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          _amountController.clear();
          _reasonController.clear();
          setState(() {
            _selectedType = DepositType.office;
            _attachments.clear();
          });

          if (mounted) Navigator.of(context).pop();
        } else {
          final error = ref.read(currentUserDepositProvider).error;
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

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
