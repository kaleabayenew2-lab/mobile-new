import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordApi {
  static const String baseUrl = 'http://127.0.0.1:5000'; // Replace with your actual API URL

  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/request-reset'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': responseData['ok'] ?? false,
            'data': responseData,
            'message': 'Reset code sent to your email',
            'via': responseData['via'] ?? 'email',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Email not found',
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to send reset code',
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

  static Future<Map<String, dynamic>> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/confirm-reset'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': responseData['ok'] ?? false,
            'data': responseData,
            'message': 'Password reset successful',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Invalid or expired OTP',
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Password reset failed',
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

  // Legacy methods for backward compatibility
  static Future<Map<String, dynamic>> sendResetCode(String email) async {
    return await requestPasswordReset(email);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return await confirmPasswordReset(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }

  static Future<Map<String, dynamic>> resendResetCode(String email) async {
    return await requestPasswordReset(email);
  }

  static Map<String, dynamic> validateOtpFormat(String otp) {
    if (otp.isEmpty) {
      return {
        'success': false,
        'message': 'OTP cannot be empty',
      };
    }

    if (otp.length != 6) {
      return {
        'success': false,
        'message': 'OTP must be exactly 6 digits',
      };
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return {
        'success': false,
        'message': 'OTP must contain only numbers',
      };
    }

    return {
      'success': true,
      'message': 'OTP format is valid',
    };
  }

  static Future<Map<String, dynamic>> checkUserExistsForReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/check-user-exists'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'exists': responseData['exists'] ?? false,
          'message': responseData['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to check user existence',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
