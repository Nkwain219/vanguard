import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:vanguard/core/models/wallet_transaction.dart';
import 'package:vanguard/core/repositories/firebase/firebase_wallet_repository.dart';
import 'package:vanguard/core/providers/wallet_balance_provider.dart';

class WalletDashboardView extends ConsumerStatefulWidget {
  const WalletDashboardView({super.key});

  @override
  ConsumerState<WalletDashboardView> createState() =>
      _WalletDashboardViewState();
}

class _WalletDashboardViewState extends ConsumerState<WalletDashboardView> {
  final _walletRepo = FirebaseWalletRepository();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(walletBalanceProvider.notifier).fetchBalance();
    });
  }

  Future<void> _recalculateWalletSummary(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Recalculating totals...'),
          ],
        ),
      ),
    );

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('recalculateWalletSummary');
      final result = await callable.call();

      if (!context.mounted) return;
      Navigator.of(context).pop();

      final data = result.data as Map<String, dynamic>;
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Updated: Revenue ${data['totalRevenue']} XAF, Expenses ${data['totalExpenses']} XAF',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final balanceState = ref.watch(walletBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/wallet-deposit'),
            tooltip: 'Record Deposit',
          ),
          IconButton(
            icon: balanceState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            onPressed: balanceState.isLoading
                ? null
                : () => ref.read(walletBalanceProvider.notifier).fetchBalance(),
            tooltip: 'Refresh Balance',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'recalculate') {
                await _recalculateWalletSummary(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'recalculate',
                child: Row(
                  children: [
                    Icon(Icons.calculate_outlined),
                    SizedBox(width: 8),
                    Text('Recalculate Totals'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<WalletSummary>(
        stream: _walletRepo.watchWalletSummary(),
        builder: (context, summarySnapshot) {
          if (summarySnapshot.hasError) {
            debugPrint('❌ Wallet Summary Error: ${summarySnapshot.error}');
          }
          if (summarySnapshot.connectionState == ConnectionState.waiting) {
            debugPrint('⏳ Wallet Summary: Waiting for data...');
          }
          if (summarySnapshot.hasData) {
            debugPrint('✅ Wallet Summary: ${summarySnapshot.data}');
          }
          final summary = summarySnapshot.data ?? WalletSummary.empty();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(balanceState, summary, theme),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Monthly Revenue',
                        summary.monthlyRevenue,
                        Icons.trending_up,
                        Colors.green,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Monthly Expenses',
                        summary.monthlyExpenses,
                        Icons.trending_down,
                        Colors.red,
                        theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Revenue vs Expenses',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildPieChart(summary, theme),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<WalletTransaction>>(
                  stream: _walletRepo.watchTransactions(),
                  builder: (context, txnSnapshot) {
                    if (txnSnapshot.hasError) {
                      debugPrint('❌ Transactions Error: ${txnSnapshot.error}');
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Failed to fetch transactions',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${txnSnapshot.error}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (txnSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      debugPrint('⏳ Transactions: Waiting for data...');
                      return const Center(child: CircularProgressIndicator());
                    }

                    debugPrint(
                        '✅ Transactions received: ${txnSnapshot.data?.length ?? 0} items');
                    final transactions = txnSnapshot.data ?? [];
                    if (transactions.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions yet',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: transactions
                          .take(10)
                          .map((txn) => _buildTransactionItem(txn, theme))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/wallet-deposit'),
        icon: const Icon(Icons.add),
        label: const Text('Deposit'),
      ),
    );
  }

  Widget _buildBalanceCard(
      WalletBalanceState balanceState, WalletSummary summary, ThemeData theme) {
    final calculatedBalance = summary.totalRevenue - summary.totalExpenses;

    final String balanceDisplay = '${_formatAmount(calculatedBalance)} XAF';
    final String balanceNote = 'Revenue - Expenses';

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Balance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    balanceNote,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              balanceDisplay,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMiniStat(
                  'Total Revenue',
                  summary.totalRevenue,
                  Icons.arrow_upward,
                  Colors.greenAccent,
                ),
                const SizedBox(width: 16),
                _buildMiniStat(
                  'Total Expenses',
                  summary.totalExpenses,
                  Icons.arrow_downward,
                  Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
      String label, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            Text(
              '${_formatAmount(amount)} XAF',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    double amount,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatAmount(amount)} XAF',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(WalletSummary summary, ThemeData theme) {
    if (summary.totalRevenue == 0 && summary.totalExpenses == 0) {
      return Center(
        child: Text(
          'No data yet',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: summary.totalRevenue,
            title: 'Revenue',
            color: Colors.green,
            radius: 60,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          PieChartSectionData(
            value: summary.totalExpenses,
            title: 'Expenses',
            color: Colors.red,
            radius: 60,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransaction txn, ThemeData theme) {
    final isDeposit = txn.type == TransactionType.deposit;
    final color = isDeposit ? Colors.green : Colors.red;
    final sign = isDeposit ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _showTransactionDetails(txn, theme),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(
          txn.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${txn.submittedByName} • ${_formatDate(txn.date)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign${_formatAmount(txn.amount)} XAF',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!txn.isVerified)
              Text(
                'Pending',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(WalletTransaction txn, ThemeData theme) {
    final isDeposit = txn.type == TransactionType.deposit;
    final color = isDeposit ? Colors.green : Colors.red;
    final sign = isDeposit ? '+' : '-';
    final typeLabel = isDeposit ? 'Deposit' : 'Expense';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: Icon(
                        isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$sign${txn.amount.toStringAsFixed(0)} XAF',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Transaction Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Transaction ID', txn.id, theme),
              _buildDetailRow('Description', txn.description, theme),
              _buildDetailRow('Category', _formatCategory(txn.category), theme),
              _buildDetailRow('Date', _formatFullDate(txn.date), theme),
              _buildDetailRow('Submitted By', txn.submittedByName, theme),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusRow(
                txn.isVerified ? 'Verified' : 'Pending Verification',
                txn.isVerified ? Colors.green : Colors.orange,
                txn.isVerified ? Icons.check_circle : Icons.pending,
                theme,
              ),
              if (txn.isVerified && txn.verifiedBy != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Verified By', txn.verifiedBy!, theme),
              ],
              if (txn.isVerified && txn.verifiedAt != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Verified At', _formatFullDate(txn.verifiedAt!), theme),
              ],
              if (txn.receiptUrl != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening receipt...')),
                      );
                    },
                    icon: const Icon(Icons.receipt),
                    label: const Text('View Receipt'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
      String status, Color color, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCategory(String category) {
    return category
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  String _formatFullDate(DateTime date) {
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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
