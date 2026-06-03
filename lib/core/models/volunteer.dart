class Volunteer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String department;
  final String position;
  final int? stipend;
  final DateTime joinDate;
  final String? profileImageUrl;
  final bool isActive;
  final String idCard;

  const Volunteer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    this.stipend,
    required this.joinDate,
    this.profileImageUrl,
    this.isActive = true,
    required this.idCard,
  });

  String get fullName => '$firstName $lastName';

  Volunteer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? department,
    String? position,
    int? stipend,
    DateTime? joinDate,
    String? profileImageUrl,
    bool? isActive,
    String? idCard,
  }) {
    return Volunteer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      position: position ?? this.position,
      stipend: stipend ?? this.stipend,
      joinDate: joinDate ?? this.joinDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
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
      'stipend': stipend,
      'joinDate': joinDate.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'idCard': idCard,
    };
  }

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      department: json['department'] as String,
      position: json['position'] as String,
      stipend: json['stipend'] as int?,
      joinDate: DateTime.parse(json['joinDate'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      idCard: json['idCard'] as String,
    );
  }
}
