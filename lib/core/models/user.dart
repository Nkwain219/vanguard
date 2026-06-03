import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final UserRole role;
  final String department;
  final String position;
  final DateTime joinDate;
  final String? profileImageUrl;
  final bool isActive;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.position,
    required this.joinDate,
    this.profileImageUrl,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    UserRole? role,
    String? department,
    String? position,
    DateTime? joinDate,
    String? profileImageUrl,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'department': department,
      'position': position,
      'joinDate': joinDate.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      final roleString = (json['role'] as String).trim();
      return User(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == roleString,
          orElse: () => UserRole.employee,
        ),
        department: json['department'] as String? ?? '',
        position: json['position'] as String? ?? '',
        joinDate: _parseDateTime(json['joinDate']),
        profileImageUrl: json['profileImageUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );
    } catch (e) {
      print('ERROR parsing User: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}
