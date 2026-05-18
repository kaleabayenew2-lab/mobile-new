import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {Map<String, String>? extraHeaders}) async {
    try {
      final headers = {
        ..._headers,
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Request failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data, {Map<String, String>? extraHeaders}) async {
    try {
      final headers = {
        ..._headers,
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Request failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? extraHeaders}) async {
    try {
      final headers = {
        ..._headers,
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Request failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint, {Map<String, String>? extraHeaders}) async {
    try {
      final headers = {
        ..._headers,
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Request failed: $e'};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is Map<String, dynamic> 
          ? {'success': true, ...body}
          : {'success': true, 'data': body};
    } else {
      return {
        'success': false,
        'message': body['message'] ?? 'Request failed',
        'statusCode': response.statusCode,
        'error': body,
      };
    }
  }

  static Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      final response = await get('/users/check?email=$email');
      return response;
    } catch (e) {
      return {'success': false, 'message': 'Check failed: $e'};
    }
  }
}
