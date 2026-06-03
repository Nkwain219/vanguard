import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MesombService {
  static MesombService? _instance;
  static MesombService get instance => _instance ??= MesombService._();
  MesombService._();

  static const String _baseUrl = 'https://mesomb.hachther.com/api/v1.1';

  String get _appKey => dotenv.env['MESOMB_APP_KEY'] ?? '';
  String get _accessKey => dotenv.env['MESOMB_ACCESS_KEY'] ?? '';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-MeSomb-Application': _appKey,
        'Authorization': 'Token $_accessKey',
      };

  bool get isConfigured => _appKey.isNotEmpty && _accessKey.isNotEmpty;

  Future<MesombResult> collectPayment({
    required double amount,
    required String phoneNumber,
    required String service,
    String? message,
    String? reference,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/collect/'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount.toInt(),
          'payer': phoneNumber,
          'service': service.toUpperCase(),
          'message': message ?? 'Payment',
          'reference':
              reference ?? 'txn_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return MesombResult.failure('Network error: ${e.toString()}');
    }
  }

  Future<MesombResult> makeDeposit({
    required double amount,
    required String phoneNumber,
    required String service,
    String? message,
    String? reference,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/deposit/'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount.toInt(),
          'receiver': phoneNumber,
          'service': service.toUpperCase(),
          'message': message ?? 'Deposit',
          'reference':
              reference ?? 'dep_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      return _parseResponse(response);
    } catch (e) {
      return MesombResult.failure('Network error: ${e.toString()}');
    }
  }

  Future<MesombResult> checkTransactionStatus(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment/status/$transactionId/'),
        headers: _headers,
      );

      return _parseResponse(response);
    } catch (e) {
      return MesombResult.failure('Network error: ${e.toString()}');
    }
  }

  Future<MesombResult> getBalance() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/application/status/'),
        headers: _headers,
      );

      return _parseResponse(response);
    } catch (e) {
      return MesombResult.failure('Network error: ${e.toString()}');
    }
  }

  MesombResult _parseResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return MesombResult.success(data);
      } else {
        final message = data['message'] ?? data['detail'] ?? 'Unknown error';
        return MesombResult.failure(message);
      }
    } catch (e) {
      return MesombResult.failure('Failed to parse response');
    }
  }
}

class MesombResult {
  final bool isSuccess;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  MesombResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  factory MesombResult.success(Map<String, dynamic> data) {
    return MesombResult._(isSuccess: true, data: data);
  }

  factory MesombResult.failure(String message) {
    return MesombResult._(isSuccess: false, errorMessage: message);
  }

  String? get transactionId => data?['pk']?.toString();

  String? get status => data?['status']?.toString();

  double? get balance => (data?['balance'] as num?)?.toDouble();
}
