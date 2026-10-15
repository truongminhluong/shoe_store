import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  ApiClient._();

  // =========================
  // GET
  // =========================

  static Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);

    return _handleResponse(response);
  }

  // =========================
  // POST
  // =========================

  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? idempotencyKey,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

    final requestHeaders = await _getHeaders();
    if (idempotencyKey != null) {
      requestHeaders['Idempotency-Key'] = idempotencyKey;
    }

    final response = await http.post(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  // =========================
  // PUT
  // =========================

  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

    final headers = await _getHeaders();

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  // =========================
  // PATCH
  // =========================

  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

    final headers = await _getHeaders();

    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  // =========================
  // DELETE
  // =========================

  static Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

    final headers = await _getHeaders();

    final response = await http.delete(uri, headers: headers);

    return _handleResponse(response);
  }

  // =========================
  // HEADERS
  // =========================

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',

      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // =========================
  // RESPONSE
  // =========================

  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic data;

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Có lỗi xảy ra ($statusCode)');
    }

    throw Exception('Có lỗi xảy ra ($statusCode)');
  }
}
