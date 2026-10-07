
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ============================================================
  // BASE URL
  // ============================================================

  static const String baseUrl = 'http://103.168.210.85:4000';

  // ============================================================
  // COMMON HEADERS
  // ============================================================

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ============================================================
  // LOGIN API
  // POST /api/login
  // ============================================================

  Future<Map<String, dynamic>> login(
    String empCode,
    String password,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/login');

      final response = await http
          .post(
            url,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'empCode': empCode,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('LOGIN URL: $url');
      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN RESPONSE: ${response.body}');

      if (response.body.trim().isEmpty) {
        return {
          'success': false,
          'message': 'API se empty response mila.',
        };
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        return {
          'success': false,
          'message': 'Invalid API response.',
        };
      }

      final data = Map<String, dynamic>.from(decoded);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return {
          ...data,
          'success': false,
          'message': data['message']?.toString() ??
              data['error']?.toString() ??
              'Login failed (${response.statusCode}).',
        };
      }

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'token',
          data['token']?.toString() ?? '',
        );

        final userData = data['user'];

        if (userData is Map) {
          final user = Map<String, dynamic>.from(userData);

          await prefs.setString(
            'empCode',
            user['empCode']?.toString() ?? '',
          );

          await prefs.setString(
            'userName',
            user['userName']?.toString() ?? '',
          );

          await prefs.setString(
            'userType',
            user['userType']?.toString() ?? '',
          );

          await prefs.setString(
            'locCode',
            user['locCode']?.toString() ?? '',
          );

          await prefs.setString(
            'locName',
            user['locName']?.toString() ?? '',
          );

          await prefs.setBool(
            'isAdmin',
            user['isAdmin'] == true,
          );
        }

        await prefs.setBool('isLogin', true);
      }

      return data;
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Login request timed out.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Login API returned invalid JSON.',
      };
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      return {
        'success': false,
        'message': 'API connection failed: $e',
      };
    }
  }

  // ============================================================
  // GET ASSET DETAILS
  // GET /api/asset/{assetCode}
  // ============================================================

  Future<Map<String, dynamic>> getAssetByCode({
    required String assetCode,
  }) async {
    final code = assetCode.trim();

    if (code.isEmpty) {
      throw Exception('Please enter Asset Code.');
    }

    final url = Uri.parse(
      '$baseUrl/api/asset/${Uri.encodeComponent(code)}',
    );

    try {
      final response = await http
          .get(
            url,
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('GET ASSET URL: $url');
      debugPrint('GET ASSET STATUS: ${response.statusCode}');
      debugPrint('GET ASSET RESPONSE: ${response.body}');

      if (response.body.trim().isEmpty) {
        throw Exception('Asset API returned an empty response.');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Invalid asset API response.');
      }

      final data = Map<String, dynamic>.from(decoded);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message']?.toString() ??
              data['error']?.toString() ??
              'Asset API failed (${response.statusCode}).',
        );
      }

      if (data['success'] != true) {
        throw Exception(
          data['message']?.toString() ??
              data['error']?.toString() ??
              'Asset not found.',
        );
      }

      return data;
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Server returned invalid JSON.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to server: $e');
    }
  }

  // ============================================================
  // VERIFY ASSET
  // POST /api/verify
  // ============================================================

  Future<Map<String, dynamic>> verifyAsset({
    required String assetCode,
    String status = 'OK',
    String remark = '',
    bool raiseTicket = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final empCode = prefs.getString('empCode') ?? '';
      final userName = prefs.getString('userName') ?? '';
      final locCode = prefs.getString('locCode') ?? '';

      if (assetCode.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Asset Code is required.',
        };
      }

      final finalStatus = status.trim().toUpperCase();

      if (finalStatus != 'OK' && finalStatus != 'ISSUE') {
        return {
          'success': false,
          'message': 'Status must be OK or ISSUE.',
        };
      }

      if (finalStatus == 'ISSUE' && remark.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Remark is required when status is ISSUE.',
        };
      }

      final url = Uri.parse('$baseUrl/api/verify');

      final body = <String, dynamic>{
        'assetCode': assetCode.trim(),
        'status': finalStatus,
        'raiseTicket': raiseTicket,
        'user': {
          'empCode': empCode,
          'userName': userName,
          'locCode': locCode,
        },
      };

      if (finalStatus == 'ISSUE') {
        body['remark'] = remark.trim();
      }

      debugPrint('VERIFY URL: $url');
      debugPrint('VERIFY REQUEST: ${jsonEncode(body)}');

      final response = await http
          .post(
            url,
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('VERIFY STATUS: ${response.statusCode}');
      debugPrint('VERIFY RESPONSE: ${response.body}');

      if (response.body.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Verify API returned an empty response.',
        };
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        return {
          'success': false,
          'message': 'Invalid verify API response.',
        };
      }

      final data = Map<String, dynamic>.from(decoded);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return {
          ...data,
          'success': false,
          'message': data['message']?.toString() ??
              data['error']?.toString() ??
              'Verification failed (${response.statusCode}).',
        };
      }

      return data;
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Verification request timed out.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Verify API returned invalid JSON.',
      };
    } catch (e) {
      debugPrint('VERIFY ERROR: $e');

      return {
        'success': false,
        'message': 'Verify API connection failed: $e',
      };
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ============================================================
  // LOGIN STATUS
  // ============================================================

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogin') ?? false;
  }

  // ============================================================
  // SAVED USER DETAILS
  // ============================================================

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<String> getEmpCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('empCode') ?? '';
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? '';
  }

  Future<String> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType') ?? '';
  }

  Future<String> getLocCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('locCode') ?? '';
  }

  Future<String> getLocName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('locName') ?? '';
  }

  Future<bool> getIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdmin') ?? false;
  }
}
