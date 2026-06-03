import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Traitz Tech';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get selectRole => 'Select Role';

  @override
  String get loginAsDemo => 'Login as Demo User';

  @override
  String continueAsRole(String role) {
    return 'Continue as $role';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get employees => 'Employees';

  @override
  String get volunteers => 'Volunteers';

  @override
  String get tasks => 'Tasks';

  @override
  String get attendance => 'Attendance';

  @override
  String get reports => 'Reports';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminders => 'Reminders';

  @override
  String get welcome => 'Welcome';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get clockIn => 'Clock In';

  @override
  String get clockOut => 'Clock Out';

  @override
  String get clockedIn => 'Clocked In';

  @override
  String get clockedOut => 'Clocked Out';

  @override
  String get clockInSuccess => 'Successfully clocked in!';

  @override
  String get clockOutSuccess => 'Successfully clocked out!';

  @override
  String get todayAttendance => 'Today\'s Attendance';

  @override
  String get weeklyHours => 'Weekly Hours';

  @override
  String get monthlyHours => 'Monthly Hours';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'Late';

  @override
  String get onLeave => 'On Leave';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get update => 'Update';

  @override
  String get submit => 'Submit';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Sort by';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get name => 'Name';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get fullName => 'Full Name';

  @override
  String get department => 'Department';

  @override
  String get position => 'Position';

  @override
  String get salary => 'Salary';

  @override
  String get phone => 'Phone';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get status => 'Status';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get amount => 'Amount';

  @override
  String get reason => 'Reason';

  @override
  String get description => 'Description';

  @override
  String get type => 'Type';

  @override
  String get priority => 'Priority';

  @override
  String get dueDate => 'Due Date';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get admin => 'Administrator';

  @override
  String get secretary => 'Secretary';

  @override
  String get employee => 'Employee';

  @override
  String get volunteer => 'Volunteer';

  @override
  String get totalEmployees => 'Total Employees';

  @override
  String get totalVolunteers => 'Total Volunteers';

  @override
  String get totalTasks => 'Total Tasks';

  @override
  String get pendingTasks => 'Pending Tasks';

  @override
  String get completedTasks => 'Completed Tasks';

  @override
  String get presentToday => 'Present Today';

  @override
  String get absentToday => 'Absent Today';

  @override
  String get onLeaveToday => 'On Leave Today';

  @override
  String get manageEmployees => 'Manage Employees';

  @override
  String get manageVolunteers => 'Manage Volunteers';

  @override
  String get addEmployee => 'Add Employee';

  @override
  String get addVolunteer => 'Add Volunteer';

  @override
  String get editEmployee => 'Edit Employee';

  @override
  String get editVolunteer => 'Edit Volunteer';

  @override
  String get employeeDetails => 'Employee Details';

  @override
  String get volunteerDetails => 'Volunteer Details';

  @override
  String get deleteEmployee => 'Delete Employee';

  @override
  String get deleteVolunteer => 'Delete Volunteer';

  @override
  String deleteConfirmation(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get myTasks => 'My Tasks';

  @override
  String get assignedTasks => 'Assigned Tasks';

  @override
  String get createTask => 'Create Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get assignTo => 'Assign To';

  @override
  String get assignees => 'Assignees';

  @override
  String get comments => 'Comments';

  @override
  String get addComment => 'Add Comment';

  @override
  String get progress => 'Progress';

  @override
  String get urgent => 'Urgent';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get salaryRequest => 'Salary Request';

  @override
  String get salaryRequests => 'Salary Requests';

  @override
  String get requestSalary => 'Request Salary';

  @override
  String get salaryApproval => 'Salary Approval';

  @override
  String get approveSalary => 'Approve Salary';

  @override
  String get rejectSalary => 'Reject Salary';

  @override
  String get overtime => 'Overtime';

  @override
  String get bonus => 'Bonus';

  @override
  String get advance => 'Advance';

  @override
  String get deduction => 'Deduction';

  @override
  String get payslip => 'Payslip';

  @override
  String get payslips => 'Payslips';

  @override
  String get viewPayslip => 'View Payslip';

  @override
  String get downloadPayslip => 'Download Payslip';

  @override
  String get basicSalary => 'Basic Salary';

  @override
  String get netSalary => 'Net Salary';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get totalDeductions => 'Total Deductions';

  @override
  String get deposit => 'Deposit';

  @override
  String get deposits => 'Deposits';

  @override
  String get depositHistory => 'Deposit History';

  @override
  String get requestDeposit => 'Request Deposit';

  @override
  String get depositApproval => 'Deposit Approval';

  @override
  String get approveDeposit => 'Approve Deposit';

  @override
  String get rejectDeposit => 'Reject Deposit';

  @override
  String get travelExpense => 'Travel Expense';

  @override
  String get officeSupplies => 'Office Supplies';

  @override
  String get equipment => 'Equipment';

  @override
  String get other => 'Other';

  @override
  String get leave => 'Leave';

  @override
  String get leaveRequest => 'Leave Request';

  @override
  String get leaveRequests => 'Leave Requests';

  @override
  String get requestLeave => 'Request Leave';

  @override
  String get leaveApproval => 'Leave Approval';

  @override
  String get approveLeave => 'Approve Leave';

  @override
  String get rejectLeave => 'Reject Leave';

  @override
  String get annualLeave => 'Annual Leave';

  @override
  String get sickLeave => 'Sick Leave';

  @override
  String get maternityLeave => 'Maternity Leave';

  @override
  String get paternityLeave => 'Paternity Leave';

  @override
  String get unpaidLeave => 'Unpaid Leave';

  @override
  String get daysRequested => 'Days Requested';

  @override
  String get daysRemaining => 'Days Remaining';

  @override
  String get leaveBalance => 'Leave Balance';

  @override
  String get attendanceHistory => 'Attendance History';

  @override
  String get attendanceOverview => 'Attendance Overview';

  @override
  String get attendanceReport => 'Attendance Report';

  @override
  String get hoursWorked => 'Hours Worked';

  @override
  String get averageHours => 'Average Hours';

  @override
  String get totalDays => 'Total Days';

  @override
  String get workingDays => 'Working Days';

  @override
  String get sendReminder => 'Send Reminder';

  @override
  String get reminderSent => 'Reminder sent successfully';

  @override
  String get selectRecipients => 'Select Recipients';

  @override
  String get selectTemplate => 'Select Template';

  @override
  String get customMessage => 'Custom Message';

  @override
  String get reminderTemplates => 'Reminder Templates';

  @override
  String get reportSummary => 'Report Summary';

  @override
  String get attendanceStats => 'Attendance Statistics';

  @override
  String get taskStats => 'Task Statistics';

  @override
  String get salaryStats => 'Salary Statistics';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get weeklyReport => 'Weekly Report';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get exportReport => 'Export Report';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get noData => 'No data available';

  @override
  String get noEmployees => 'No employees found';

  @override
  String get noVolunteers => 'No volunteers found';

  @override
  String get noTasks => 'No tasks found';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noRequests => 'No requests found';

  @override
  String get noResults => 'No results found';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get onboardingTitle1 => 'Workforce Management';

  @override
  String get onboardingDesc1 =>
      'Manage your employees and volunteers efficiently with Traitz Tech.';

  @override
  String get onboardingTitle2 => 'Track Attendance';

  @override
  String get onboardingDesc2 =>
      'Easy clock-in and clock-out with real-time attendance tracking.';

  @override
  String get onboardingTitle3 => 'Stay Organized';

  @override
  String get onboardingDesc3 =>
      'Assign tasks, manage leaves, and generate reports seamlessly.';

  @override
  String get bankAccount => 'Bank Account';

  @override
  String get idCard => 'ID Card';

  @override
  String get joinDate => 'Join Date';

  @override
  String get stipend => 'Stipend';

  @override
  String get quickGlance => 'Quick Glance';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentTasks => 'Recent Tasks';

  @override
  String get dueToday => 'Due Today';

  @override
  String tasksDue(int count) {
    return '$count due today';
  }

  @override
  String get hoursThisWeek => 'Hours This Week';

  @override
  String get workforceManagement => 'Workforce Management';

  @override
  String get workforceManagementSystem => 'Workforce Management System';

  @override
  String get welcomeBackSimple => 'Welcome Back';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get doingGreat => 'You\'re doing great today!';

  @override
  String get readyToStart => 'Ready to start your day?';

  @override
  String get notClockedIn => 'Not clocked in yet';

  @override
  String get companyDeposits => 'Company Deposits';

  @override
  String get noDueDate => 'No due date';

  @override
  String dueLabel(String date) {
    return 'Due: $date';
  }

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get secretaryDashboard => 'Secretary Dashboard';

  @override
  String get volunteerDashboard => 'Volunteer Dashboard';

  @override
  String get employeeDashboard => 'Employee Dashboard';

  @override
  String get activeTasks => 'Active Tasks';

  @override
  String get activeEmployees => 'Active Employees';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get viewTasks => 'View Tasks';

  @override
  String get sendReminders => 'Send Reminders';

  @override
  String get sendNotification => 'Send Notification';

  @override
  String get newProject => 'New Project';

  @override
  String get editProject => 'Edit Project';

  @override
  String get projectDetails => 'Project Details';

  @override
  String get projectName => 'Project Name';

  @override
  String get createProject => 'Create Project';

  @override
  String get updateProject => 'Update Project';

  @override
  String get daysLeft => 'Days Left';

  @override
  String get addTask => 'Add Task';

  @override
  String get reminderCenter => 'Reminder Center';

  @override
  String get selectEmployees => 'Select Employees';

  @override
  String get selectAll => 'Select All';

  @override
  String get clearAll => 'Clear All';

  @override
  String get messagePreview => 'Message Preview:';

  @override
  String selectedTemplates(int count) {
    return 'Selected Templates ($count)';
  }

  @override
  String get quickSend => 'Quick Send';

  @override
  String get totalReport => 'Total';

  @override
  String get lateArrivals => 'Late Arrivals';

  @override
  String get weeklyAttendanceTrend => 'Weekly Attendance Trend';

  @override
  String get attendanceDetails => 'Attendance Details';

  @override
  String get presentDays => 'Present Days';

  @override
  String get absentDays => 'Absent Days';

  @override
  String get lateDays => 'Late Days';

  @override
  String get trackAttendance => 'Track Attendance';

  @override
  String get manageTasks => 'Manage Tasks';

  @override
  String get handlePayroll => 'Handle Payroll';

  @override
  String get seeAll => 'See All';

  @override
  String get atWorkLocation => 'At Work Location';

  @override
  String get outsideWorkArea => 'Outside Work Area';

  @override
  String get needsAttention => 'Needs Attention';

  @override
  String get slideToClockIn => 'Slide to Clock In';

  @override
  String get slideToClockOut => 'Slide to Clock Out';

  @override
  String get locationRequired =>
      'You must be at your work location to clock in';

  @override
  String failedWithError(String error) {
    return 'Failed: $error';
  }

  @override
  String get leaveApprovalMenu => 'Leave Approval';

  @override
  String get salaryApprovalMenu => 'Salary Approval';

  @override
  String get workLocations => 'Work Locations';

  @override
  String get myWork => 'My Work';

  @override
  String get myAttendance => 'My Attendance';

  @override
  String get myDeposits => 'My Deposits';

  @override
  String get attendanceCalendar => 'Attendance Calendar';

  @override
  String get todayTimeline => 'Today\'s Timeline';

  @override
  String clockedInAt(String time) {
    return 'Clocked in at $time';
  }

  @override
  String workingTime(String time) {
    return 'Working time: $time';
  }

  @override
  String get noAttendanceRecords => 'No attendance records found';

  @override
  String get pendingSync => 'Pending sync';

  @override
  String get verified => 'Verified ✓';

  @override
  String get autoLeftPerimeter => 'Auto (left perimeter)';

  @override
  String get locationPermissionRequired =>
      'Location permission is required for attendance';

  @override
  String get clockedInSuccess => 'Clocked in successfully!';

  @override
  String get clockedOutSuccess => 'Clocked out successfully!';

  @override
  String get recordingClockIn => 'Recording clock in...';

  @override
  String get recordingClockOut => 'Recording clock out...';

  @override
  String get daysSummary => 'Days';

  @override
  String get legend => 'Legend';
}
