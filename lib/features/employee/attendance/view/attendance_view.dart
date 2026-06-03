import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanguard/core/models/attendance.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vanguard/widgets/wf_clock_button.dart';
import 'package:vanguard/core/services/location_service.dart';
import 'package:vanguard/core/theme/app_theme.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/l10n/app_localizations.dart';

class AttendanceEmployeeScreen extends ConsumerStatefulWidget {
  const AttendanceEmployeeScreen({super.key});

  @override
  ConsumerState<AttendanceEmployeeScreen> createState() =>
      _AttendanceEmployeeScreenState();
}

class _AttendanceEmployeeScreenState
    extends ConsumerState<AttendanceEmployeeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _checkLocationPermission();

    Future.microtask(() {
      ref.read(currentUserAttendanceProvider.notifier).loadAttendance();
    });
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await LocationService.instance.ensurePermissions();
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required for attendance'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isClockedIn = ref.watch(isClockedInProvider);
    final clockInTime = ref.watch(clockInTimeProvider);
    final attendanceLoading =
        ref.watch(currentUserAttendanceProvider.select((s) => s.isLoading));
    final todayRecord =
        ref.watch(currentUserAttendanceProvider.select((s) => s.todayRecord));
    final summary =
        ref.watch(currentUserAttendanceProvider.select((s) => s.summary));
    final records =
        ref.watch(currentUserAttendanceProvider.select((s) => s.records));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.attendance),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showAttendanceHistory(records),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(currentUserAttendanceProvider.notifier).loadAttendance(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '${l10n.today} - ${_formatDate(DateTime.now())}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      WFClockButton(
                        isClockedIn: isClockedIn,
                        clockInTime: clockInTime,
                        onClockIn: () => _handleClockAction(isClockIn: true),
                        onClockOut: () => _handleClockAction(isClockIn: false),
                        isLoading: attendanceLoading,
                      ),
                      const SizedBox(height: 16),
                      if (isClockedIn && clockInTime != null) ...[
                        Text(
                          '${l10n.clockedIn} ${clockInTime}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${l10n.hoursWorked}: ${todayRecord?.hoursWorked.toStringAsFixed(1) ?? "0.0"}h',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else if (!isClockedIn)
                        Text(
                          l10n.clockedOut,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (todayRecord != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.todayAttendance,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (todayRecord.clockIn != null)
                          _buildTimelineItem(
                            icon: Icons.login,
                            label: l10n.clockIn,
                            time: todayRecord.clockIn!,
                            color: Colors.green,
                            theme: theme,
                          ),
                        if (todayRecord.clockOut != null)
                          _buildTimelineItem(
                            icon: Icons.logout,
                            label: l10n.clockOut,
                            time: todayRecord.clockOut!,
                            color: Colors.red,
                            theme: theme,
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
                        l10n.monthlyHours,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              l10n.hoursWorked,
                              summary?.totalHoursWorked.toStringAsFixed(1) ??
                                  '0.0',
                              l10n.thisMonth,
                              Colors.blue,
                              theme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              l10n.presentToday,
                              '${summary?.presentDays ?? 0}',
                              l10n.totalDays,
                              Colors.green,
                              theme,
                            ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.attendanceOverview,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TableCalendar<dynamic>(
                        firstDay: DateTime.utc(2023, 1, 1),
                        lastDay: DateTime.utc(2027, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          selectedDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 1,
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                        ),
                        eventLoader: (day) {
                          if (day.weekday <= 5 &&
                              day.isBefore(DateTime.now())) {
                            return ['present'];
                          }
                          return [];
                        },
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
                        l10n.status,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildLegendItem(Colors.green, l10n.present, theme),
                          const SizedBox(width: 16),
                          _buildLegendItem(Colors.red, l10n.absent, theme),
                          const SizedBox(width: 16),
                          _buildLegendItem(Colors.orange, l10n.late, theme),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required DateTime time,
    required Color color,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            '$label - ${_formatTime(time)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    Color color,
    ThemeData theme,
  ) {
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
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _handleClockAction({required bool isClockIn}) async {
    final attendanceNotifier = ref.read(currentUserAttendanceProvider.notifier);

    bool success;
    if (isClockIn) {
      success = await attendanceNotifier.clockIn();
    } else {
      success = await attendanceNotifier.clockOut();
    }

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isClockIn ? l10n.clockInSuccess : l10n.clockOutSuccess),
          backgroundColor: AppTheme.success,
        ),
      );
    } else if (!success && mounted) {
      final error = ref.read(currentUserAttendanceProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Operation failed'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showAttendanceHistory(List<Attendance> records) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.attendanceHistory,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        ref
                            .read(currentUserAttendanceProvider.notifier)
                            .loadAttendance();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (records.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(l10n.noData),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final date = record.date;
                      final isPresent =
                          record.status == AttendanceStatus.present;
                      final isLate = record.status == AttendanceStatus.late;

                      Color statusColor = Colors.grey;
                      String statusText = l10n.absent;
                      IconData statusIcon = Icons.close;

                      if (isPresent) {
                        statusColor = Colors.green;
                        statusText = l10n.present;
                        statusIcon = Icons.check;
                      } else if (isLate) {
                        statusColor = Colors.orange;
                        statusText = l10n.late;
                        statusIcon = Icons.schedule;
                      }

                      final clockIn = record.clockIn != null
                          ? _formatTime(record.clockIn!)
                          : '--:--';
                      final clockOut = record.clockOut != null
                          ? _formatTime(record.clockOut!)
                          : '--:--';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          title: Text(_formatDate(date)),
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
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
