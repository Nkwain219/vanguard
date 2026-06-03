import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  String get appTitle;

  String get login;

  String get email;

  String get password;

  String get selectRole;

  String get loginAsDemo;

  String continueAsRole(String role);

  String get dashboard;

  String get employees;

  String get volunteers;

  String get tasks;

  String get attendance;

  String get reports;

  String get profile;

  String get settings;

  String get logout;

  String get notifications;

  String get reminders;

  String get welcome;

  String welcomeBack(String name);

  String get goodMorning;

  String get goodAfternoon;

  String get goodEvening;

  String get clockIn;

  String get clockOut;

  String get clockedIn;

  String get clockedOut;

  String get clockInSuccess;

  String get clockOutSuccess;

  String get todayAttendance;

  String get weeklyHours;

  String get monthlyHours;

  String get present;

  String get absent;

  String get late;

  String get onLeave;

  String get pending;

  String get approved;

  String get rejected;

  String get inProgress;

  String get completed;

  String get cancelled;

  String get save;

  String get cancel;

  String get delete;

  String get edit;

  String get add;

  String get create;

  String get update;

  String get submit;

  String get confirm;

  String get close;

  String get done;

  String get back;

  String get next;

  String get skip;

  String get getStarted;

  String get search;

  String get filter;

  String get sortBy;

  String get all;

  String get today;

  String get thisWeek;

  String get thisMonth;

  String get name;

  String get firstName;

  String get lastName;

  String get fullName;

  String get department;

  String get position;

  String get salary;

  String get phone;

  String get active;

  String get inactive;

  String get status;

  String get date;

  String get time;

  String get amount;

  String get reason;

  String get description;

  String get type;

  String get priority;

  String get dueDate;

  String get startDate;

  String get endDate;

  String get admin;

  String get secretary;

  String get employee;

  String get volunteer;

  String get totalEmployees;

  String get totalVolunteers;

  String get totalTasks;

  String get pendingTasks;

  String get completedTasks;

  String get presentToday;

  String get absentToday;

  String get onLeaveToday;

  String get manageEmployees;

  String get manageVolunteers;

  String get addEmployee;

  String get addVolunteer;

  String get editEmployee;

  String get editVolunteer;

  String get employeeDetails;

  String get volunteerDetails;

  String get deleteEmployee;

  String get deleteVolunteer;

  String deleteConfirmation(String name);

  String get myTasks;

  String get assignedTasks;

  String get createTask;

  String get editTask;

  String get taskDetails;

  String get assignTo;

  String get assignees;

  String get comments;

  String get addComment;

  String get progress;

  String get urgent;

  String get high;

  String get medium;

  String get low;

  String get salaryRequest;

  String get salaryRequests;

  String get requestSalary;

  String get salaryApproval;

  String get approveSalary;

  String get rejectSalary;

  String get overtime;

  String get bonus;

  String get advance;

  String get deduction;

  String get payslip;

  String get payslips;

  String get viewPayslip;

  String get downloadPayslip;

  String get basicSalary;

  String get netSalary;

  String get totalEarnings;

  String get totalDeductions;

  String get deposit;

  String get deposits;

  String get depositHistory;

  String get requestDeposit;

  String get depositApproval;

  String get approveDeposit;

  String get rejectDeposit;

  String get travelExpense;

  String get officeSupplies;

  String get equipment;

  String get other;

  String get leave;

  String get leaveRequest;

  String get leaveRequests;

  String get requestLeave;

  String get leaveApproval;

  String get approveLeave;

  String get rejectLeave;

  String get annualLeave;

  String get sickLeave;

  String get maternityLeave;

  String get paternityLeave;

  String get unpaidLeave;

  String get daysRequested;

  String get daysRemaining;

  String get leaveBalance;

  String get attendanceHistory;

  String get attendanceOverview;

  String get attendanceReport;

  String get hoursWorked;

  String get averageHours;

  String get totalDays;

  String get workingDays;

  String get sendReminder;

  String get reminderSent;

  String get selectRecipients;

  String get selectTemplate;

  String get customMessage;

  String get reminderTemplates;

  String get reportSummary;

  String get attendanceStats;

  String get taskStats;

  String get salaryStats;

  String get monthlyReport;

  String get weeklyReport;

  String get generateReport;

  String get exportReport;

  String get profileSettings;

  String get accountSettings;

  String get personalInfo;

  String get changePassword;

  String get currentPassword;

  String get newPassword;

  String get confirmPassword;

  String get language;

  String get english;

  String get french;

  String get theme;

  String get lightMode;

  String get darkMode;

  String get systemDefault;

  String get noData;

  String get noEmployees;

  String get noVolunteers;

  String get noTasks;

  String get noNotifications;

  String get noRequests;

  String get noResults;

  String get tryAgain;

  String get loading;

  String get error;

  String get success;

  String get warning;

  String get info;

  String get onboardingTitle1;

  String get onboardingDesc1;

  String get onboardingTitle2;

  String get onboardingDesc2;

  String get onboardingTitle3;

  String get onboardingDesc3;

  String get bankAccount;

  String get idCard;

  String get joinDate;

  String get stipend;

  String get quickGlance;

  String get quickActions;

  String get recentTasks;

  String get dueToday;

  String tasksDue(int count);

  String get hoursThisWeek;

  String get workforceManagement;

  String get workforceManagementSystem;

  String get welcomeBackSimple;

  String get forgotPassword;

  String get signIn;

  String get signOut;

  String get doingGreat;

  String get readyToStart;

  String get notClockedIn;

  String get companyDeposits;

  String get noDueDate;

  String dueLabel(String date);

  String get operationFailed;

  String get adminDashboard;

  String get secretaryDashboard;

  String get volunteerDashboard;

  String get employeeDashboard;

  String get activeTasks;

  String get activeEmployees;

  String get completionRate;

  String get viewTasks;

  String get sendReminders;

  String get sendNotification;

  String get newProject;

  String get editProject;

  String get projectDetails;

  String get projectName;

  String get createProject;

  String get updateProject;

  String get daysLeft;

  String get addTask;

  String get reminderCenter;

  String get selectEmployees;

  String get selectAll;

  String get clearAll;

  String get messagePreview;

  String selectedTemplates(int count);

  String get quickSend;

  String get totalReport;

  String get lateArrivals;

  String get weeklyAttendanceTrend;

  String get attendanceDetails;

  String get presentDays;

  String get absentDays;

  String get lateDays;

  String get trackAttendance;

  String get manageTasks;

  String get handlePayroll;

  String get seeAll;

  String get atWorkLocation;

  String get outsideWorkArea;

  String get needsAttention;

  String get slideToClockIn;

  String get slideToClockOut;

  String get locationRequired;

  String failedWithError(String error);

  String get leaveApprovalMenu;

  String get salaryApprovalMenu;

  String get workLocations;

  String get myWork;

  String get myAttendance;

  String get myDeposits;

  String get attendanceCalendar;

  String get todayTimeline;

  String clockedInAt(String time);

  String workingTime(String time);

  String get noAttendanceRecords;

  String get pendingSync;

  String get verified;

  String get autoLeftPerimeter;

  String get locationPermissionRequired;

  String get clockedInSuccess;

  String get clockedOutSuccess;

  String get recordingClockIn;

  String get recordingClockOut;

  String get daysSummary;

  String get legend;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
