import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth_service.dart';

class ProfileAddApi {
  static const String baseUrl = 'http://127.0.0.1:5000'; // Replace with your actual API URL

  /// Save medical facility
  static Future<Map<String, dynamic>> saveFacility({
    required Map<String, dynamic> facilityData,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/facilities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService().token}',
        },
        body: jsonEncode({
          'userId': userId,
          ...facilityData,
        }),
      );

      if (response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseData,
            'message': 'Facility saved successfully',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Invalid facility data',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode} ${response.reasonPhrase}',
          };
        }
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
            'message': errorData['message'] ?? 'Failed to save facility',
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

  /// Get saved facilities for a user
  static Future<Map<String, dynamic>> getSavedFacilities(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/facilities'),
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
            'message': 'Facilities retrieved successfully',
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
          'message': 'No facilities found',
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
            'message': errorData['message'] ?? 'Failed to retrieve facilities',
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

  /// Save medical profile data
  static Future<Map<String, dynamic>> saveMedicalProfile({
    required Map<String, dynamic> medicalData,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/medical-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService().token}',
        },
        body: jsonEncode({
          'userId': userId,
          ...medicalData,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Medical profile saved successfully',
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Invalid medical data',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Please login again',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to save medical profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Get medical profile data for a user
  static Future<Map<String, dynamic>> getMedicalProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/medical-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService().token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Medical profile retrieved successfully',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'No medical profile found',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Please login again',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to retrieve medical profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Validate facility data
  static bool isValidFacilityData(Map<String, dynamic> facilityData) {
    final requiredFields = ['name', 'address', 'phone', 'type'];
    
    for (String field in requiredFields) {
      if (!facilityData.containsKey(field) || 
          facilityData[field] == null || 
          facilityData[field].toString().trim().isEmpty) {
        return false;
      }
    }
    
    // Validate phone format
    if (facilityData.containsKey('phone')) {
      final phone = facilityData['phone'].toString();
      if (!phone.startsWith('+251') || phone.length < 12) {
        return false;
      }
    }
    
    return true;
  }

  /// Validate medical profile data
  static bool isValidMedicalData(Map<String, dynamic> medicalData) {
    final requiredFields = ['fullName', 'email', 'phone', 'age'];
    
    for (String field in requiredFields) {
      if (!medicalData.containsKey(field) || 
          medicalData[field] == null || 
          medicalData[field].toString().trim().isEmpty) {
        return false;
      }
    }
    
    // Validate email
    if (medicalData.containsKey('email')) {
      final email = medicalData['email'].toString().trim();
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,})$').hasMatch(email)) {
        return false;
      }
    }
    
    // Validate phone
    if (medicalData.containsKey('phone')) {
      final phone = medicalData['phone'].toString();
      if (!phone.startsWith('+251') || phone.length < 12) {
        return false;
      }
    }
    
    // Validate age
    if (medicalData.containsKey('age')) {
      final age = int.tryParse(medicalData['age'].toString());
      if (age == null || age! < 0 || age! > 120) {
        return false;
      }
    }
    
    return true;
  }

  /// Validate blood type
  static bool isValidBloodType(String? bloodType) {
    if (bloodType == null || bloodType!.isEmpty) {
      return false;
    }
    
    final validTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return validTypes.contains(bloodType!);
  }
}
