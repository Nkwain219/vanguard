enum UserRole {
  admin,
  secretary,
  employee,
  volunteer;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.secretary:
        return 'Secretary';
      case UserRole.employee:
        return 'Employee';
      case UserRole.volunteer:
        return 'Volunteer';
    }
  }

  bool get canManageEmployees => this == UserRole.admin;
  bool get canApproveRequests => this == UserRole.admin;
  bool get canViewAllData =>
      this == UserRole.admin || this == UserRole.secretary;
  bool get canSendReminders =>
      this == UserRole.admin || this == UserRole.secretary;
}
