import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth_service.dart';

class ProfileApi {
  static const String baseUrl = 'http://127.0.0.1:5000'; // Replace with your actual API URL

  /// Get user profile by ID
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService().token}',
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseData,
            'message': 'Profile retrieved successfully',
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
          'message': 'Profile not found',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Please login again',
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to retrieve profile',
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

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String id,
    String? fullName,
    String? phone,
    int? age,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'id': id,
      };

      // Add only provided fields
      if (fullName != null) requestBody['fullName'] = fullName;
      if (phone != null) requestBody['phone'] = '+251$phone'; // Add Ethiopia country code
      if (age != null) requestBody['age'] = age;
      if (password != null) requestBody['password'] = password;

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService().token}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseData,
            'message': 'Profile updated successfully',
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
          'message': 'Profile not found',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Please login again',
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
            'message': errorData['message'] ?? 'Failed to update profile',
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

  /// Get current user's profile (using stored user ID)
  static Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final authService = AuthService();
    if (authService.currentUser == null || authService.currentUser!['id'] == null) {
      return {
        'success': false,
        'message': 'No user ID available',
      };
    }

    final userId = authService.currentUser!['id'].toString();
    return await getProfile(userId);
  }

  /// Validate phone number format
  static bool isValidPhone(String phone) {
    // Remove any non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Ethiopian phone number (starts with 251 and has 9 digits total)
    if (digitsOnly.startsWith('251')) {
      return digitsOnly.length == 12; // 251 + 9 digits = 12
    }
    
    // For other phones, expect 9-15 digits
    return digitsOnly.length >= 9 && digitsOnly.length <= 15;
  }

  /// Validate age
  static bool isValidAge(int? age) {
    if (age == null) return true; // Optional field
    return age! >= 10 && age! <= 100;
  }

  /// Validate full name
  static bool isValidFullName(String? fullName) {
    if (fullName == null || fullName!.isEmpty) return false;
    return fullName!.length >= 2 && fullName!.length <= 50;
  }
}
