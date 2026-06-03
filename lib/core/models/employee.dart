import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String department;
  final String position;
  final double salary;
  final DateTime joinDate;
  final String? profileImageUrl;
  final bool isActive;
  final String bankAccount;
  final String idCard;

  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    required this.salary,
    required this.joinDate,
    this.profileImageUrl,
    this.isActive = true,
    this.bankAccount = '',
    this.idCard = '',
  });

  String get fullName => '$firstName $lastName';

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? department,
    String? position,
    double? salary,
    DateTime? joinDate,
    String? profileImageUrl,
    bool? isActive,
    String? bankAccount,
    String? idCard,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      joinDate: joinDate ?? this.joinDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      bankAccount: bankAccount ?? this.bankAccount,
      idCard: idCard ?? this.idCard,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'salary': salary,
      'joinDate': joinDate.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'bankAccount': bankAccount,
      'idCard': idCard,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      department: json['department'] as String? ?? '',
      position: json['position'] as String? ?? '',
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      joinDate: _parseDateTime(json['joinDate']),
      profileImageUrl: json['profileImageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      bankAccount: json['bankAccount'] as String? ?? '',
      idCard: json['idCard'] as String? ?? '',
    );
  }
}
