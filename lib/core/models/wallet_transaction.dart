import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { deposit, expense }

enum DepositCategory {
  clientPayment,
  sale,
  refund,
  donation,
  other,
}

enum ExpenseCategory {
  salary,
  equipment,
  travel,
  utility,
  rent,
  supplies,
  other,
}

class WalletTransaction {
  final String id;
  final TransactionType type;
  final String category;
  final double amount;
  final String description;
  final String submittedBy;
  final String submittedByName;
  final DateTime date;
  final String? receiptUrl;
  final bool isVerified;
  final String? verifiedBy;
  final DateTime? verifiedAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.submittedBy,
    required this.submittedByName,
    required this.date,
    this.receiptUrl,
    this.isVerified = false,
    this.verifiedBy,
    this.verifiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'category': category,
      'amount': amount,
      'description': description,
      'submittedBy': submittedBy,
      'submittedByName': submittedByName,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'isVerified': isVerified,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      return DateTime.now();
    }
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String? ?? '',
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.deposit,
      ),
      category: json['category'] as String? ?? 'other',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      submittedBy: json['submittedBy'] as String? ?? '',
      submittedByName: json['submittedByName'] as String? ?? 'Unknown',
      date: _parseDate(json['date']),
      receiptUrl: json['receiptUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      verifiedBy: json['verifiedBy'] as String?,
      verifiedAt:
          json['verifiedAt'] != null ? _parseDate(json['verifiedAt']) : null,
    );
  }

  WalletTransaction copyWith({
    String? id,
    TransactionType? type,
    String? category,
    double? amount,
    String? description,
    String? submittedBy,
    String? submittedByName,
    DateTime? date,
    String? receiptUrl,
    bool? isVerified,
    String? verifiedBy,
    DateTime? verifiedAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedByName: submittedByName ?? this.submittedByName,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isVerified: isVerified ?? this.isVerified,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}

class WalletSummary {
  final double totalBalance;
  final double totalRevenue;
  final double totalExpenses;
  final double monthlyRevenue;
  final double monthlyExpenses;
  final DateTime lastUpdated;

  const WalletSummary({
    required this.totalBalance,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.monthlyRevenue,
    required this.monthlyExpenses,
    required this.lastUpdated,
  });

  factory WalletSummary.empty() => WalletSummary(
        totalBalance: 0,
        totalRevenue: 0,
        totalExpenses: 0,
        monthlyRevenue: 0,
        monthlyExpenses: 0,
        lastUpdated: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'totalBalance': totalBalance,
        'totalRevenue': totalRevenue,
        'totalExpenses': totalExpenses,
        'monthlyRevenue': monthlyRevenue,
        'monthlyExpenses': monthlyExpenses,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble() ?? 0,
      monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble() ?? 0,
      lastUpdated: _parseDate(json['lastUpdated']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      return DateTime.now();
    }
  }
}
