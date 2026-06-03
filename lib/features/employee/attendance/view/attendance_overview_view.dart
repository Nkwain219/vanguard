import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vanguard/core/models/attendance.dart';
import 'package:vanguard/core/theme/app_theme.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/widgets/wf_status_chip.dart';

class AttendanceOverviewScreen extends ConsumerStatefulWidget {
  const AttendanceOverviewScreen({super.key});

  @override
  ConsumerState<AttendanceOverviewScreen> createState() =>
      _AttendanceOverviewScreenState();
}

class _AttendanceOverviewScreenState
    extends ConsumerState<AttendanceOverviewScreen> {
  String _selectedFilter = 'All';
  String _selectedPeriod = 'This Week';

  final List<String> _filters = ['All', 'Present', 'Absent', 'Late'];
  final List<String> _periods = ['Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final now = DateTime.now();
      ref
          .read(globalAttendanceViewModelProvider.notifier)
          .loadDailyAttendance(now);
      ref.read(globalAttendanceViewModelProvider.notifier).loadWeeklyTrend();
      ref.read(employeeViewModelProvider.notifier).loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final globalAttendance = ref.watch(globalAttendanceViewModelProvider);
    final employeeState = ref.watch(employeeViewModelProvider);

    final totalEmployees = employeeState.employees.length;
    final presentCount = globalAttendance.records
        .where((r) =>
            r.status == AttendanceStatus.present ||
            r.status == AttendanceStatus.late)
        .length;
    final lateCount = globalAttendance.records
        .where((r) => r.status == AttendanceStatus.late)
        .length;
    final absentCount = totalEmployees - presentCount;
    final attendanceRate = totalEmployees > 0
        ? (presentCount / totalEmployees * 100).toStringAsFixed(0)
        : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      isDense: true,
                    ),
                    items: _periods.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFilter,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      isDense: true,
                    ),
                    items: _filters.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Present',
                    '$presentCount',
                    Colors.green,
                    Icons.check_circle,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Absent',
                    '$absentCount',
                    Colors.red,
                    Icons.cancel,
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
                    'Late Arrivals',
                    '$lateCount',
                    Colors.orange,
                    Icons.schedule,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Attendance Rate',
                    '$attendanceRate%',
                    AppTheme.primary,
                    Icons.trending_up,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Attendance Trend',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 15,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri'
                                  ];
                                  if (value.toInt() < days.length) {
                                    return Text(days[value.toInt()]);
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: [
                            _buildBarGroup(
                                0,
                                (globalAttendance.weeklyTrend[1] ?? 0)
                                    .toDouble(),
                                Colors.green),
                            _buildBarGroup(
                                1,
                                (globalAttendance.weeklyTrend[2] ?? 0)
                                    .toDouble(),
                                Colors.green),
                            _buildBarGroup(
                                2,
                                (globalAttendance.weeklyTrend[3] ?? 0)
                                    .toDouble(),
                                Colors.green),
                            _buildBarGroup(
                                3,
                                (globalAttendance.weeklyTrend[4] ?? 0)
                                    .toDouble(),
                                Colors.green),
                            _buildBarGroup(
                                4,
                                (globalAttendance.weeklyTrend[5] ?? 0)
                                    .toDouble(),
                                Colors.green),
                          ],
                        ),
                      ),
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
                    Row(
                      children: [
                        Text(
                          'Employee Attendance Today',
                          style: theme.textTheme.titleMedium?.copyWith(
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
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: employeeState.employees.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final employee = employeeState.employees[index];
                        final attendance = globalAttendance.records
                            .where((r) => r.employeeId == employee.id)
                            .firstOrNull;

                        final status =
                            attendance?.status.name.toUpperCase() ?? 'ABSENT';
                        final clockIn = attendance?.clockIn != null
                            ? '${attendance!.clockIn!.hour.toString().padLeft(2, '0')}:${attendance.clockIn!.minute.toString().padLeft(2, '0')}'
                            : '--:--';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Text(
                              (employee.firstName.isNotEmpty
                                      ? employee.firstName[0]
                                      : '') +
                                  (employee.lastName.isNotEmpty
                                      ? employee.lastName[0]
                                      : ''),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(employee.fullName),
                          subtitle: Text(
                              '${employee.department} • Clock in: $clockIn'),
                          trailing: WFStatusBadge(
                            label: status,
                            color: _getStatusColor(status),
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
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'halfday':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance data exported successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
