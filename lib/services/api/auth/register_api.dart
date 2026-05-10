import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterApi {
  static const String baseUrl = 'http://127.0.0.1:5000'; // Replace with your actual API URL

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String age,
    required String email,
    required String phone,
    required String password,
    String? provider,
    String? idToken,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': '+251$phone', // Add Ethiopia country code
        'age': int.parse(age),
      };

      // Add provider and idToken if present (for Google auth)
      if (provider != null) {
        requestBody['provider'] = provider;
        if (idToken != null) {
          requestBody['idToken'] = idToken;
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseData,
            'message': 'Registration successful',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Email already exists',
        };
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Invalid input data',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode} ${response.reasonPhrase}',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Registration failed',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode} ${response.reasonPhrase}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/check?email=$email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'exists': responseData['exists'] ?? false,
            'telegramLinked': responseData['telegramLinked'] ?? false,
            'telegramUsername': responseData['telegramUsername'],
            'adminResetPassword': responseData['adminResetPassword'],
            'adminResetPasswordExpires': responseData['adminResetPasswordExpires'],
            'success': true,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to check email: ${response.statusCode} ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> checkUserExists({
    String? email,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/check-user-exists'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          if (email != null) 'email': email,
          if (phone != null) 'phone': '+251$phone', // Add Ethiopia country code
        }),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': responseData['success'] ?? false,
            'exists': responseData['exists'] ?? false,
            'conflicts': responseData['conflicts'] ?? {},
            'message': responseData['message'] ?? '',
            'processingTime': responseData['processingTime'] ?? '',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to check user existence: ${response.statusCode} ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> validateRegistrationData({
    required String fullName,
    required String age,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Check email exists using GET endpoint
    final emailCheck = await checkEmailExists(email);
    if (emailCheck['success'] == true && emailCheck['exists'] == true) {
      return {
        'success': false,
        'message': 'Email is already registered',
      };
    }

    // Check user exists using POST endpoint (for phone and comprehensive check)
    final userCheck = await checkUserExists(email: email, phone: phone);
    if (userCheck['success'] == true && userCheck['exists'] == true) {
      final conflicts = userCheck['conflicts'] as Map<String, dynamic>? ?? {};
      if (conflicts.containsKey('phone')) {
        return {
          'success': false,
          'message': conflicts['phone'] ?? 'Phone number already registered',
        };
      }
      if (conflicts.containsKey('email')) {
        return {
          'success': false,
          'message': conflicts['email'] ?? 'Email already registered',
        };
      }
    }

    return {
      'success': true,
      'message': 'Validation passed',
    };
  }
}
