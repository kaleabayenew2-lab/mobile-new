import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// User authentication state management service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // User data
  Map<String, dynamic>? _currentUser;
  String? _token;
  bool _isLoggedIn = false;

  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _currentUser?['fullName'];
  String? get userEmail => _currentUser?['email'];
  String? get userPhone => _currentUser?['phone'];

  /// Set user as logged in
  void login(Map<String, dynamic> userData, String token) {
    _currentUser = userData;
    _token = token;
    _isLoggedIn = true;
    
    // Store in local storage for persistence
    _storeUserData();
  }

  /// Set user as logged out
  void logout() {
    _currentUser = null;
    _token = null;
    _isLoggedIn = false;
    
    // Clear local storage
    _clearUserData();
  }

  /// Update user data
  void updateUserData(Map<String, dynamic> userData) {
    if (_currentUser != null) {
      _currentUser!.addAll(userData);
      _storeUserData();
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _isLoggedIn && _token != null;
  }

  /// Store user data in local storage (simplified version)
  void _storeUserData() {
    // In a real app, you'd use shared_preferences or secure_storage
    // For now, we'll just keep it in memory
    debugPrint('User data stored: ${jsonEncode(_currentUser)}');
  }

  /// Clear user data from local storage
  void _clearUserData() {
    // In a real app, you'd clear shared_preferences or secure_storage
    debugPrint('User data cleared');
  }

  /// Initialize auth state from storage (simplified version)
  Future<void> initialize() async {
    // In a real app, you'd load from shared_preferences or secure_storage
    debugPrint('AuthService initialized');
  }

  /// Get user display name
  String get userDisplayName {
    if (_currentUser == null) return 'Guest';
    final fullName = _currentUser!['fullName'] as String?;
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    return 'User';
  }

  /// Get formatted phone number
  String get formattedPhone {
    final phone = _currentUser?['phone'] as String?;
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }
    return 'Not provided';
  }

  /// Agent authentication methods
  Future<Map<String, dynamic>> loginAgent(String username, String password) async {
    try {
      final response = await ApiService.post('/users/login', {
        'email': username, // Using email as username for now
        'password': password,
      });

      if (response['success'] == true) {
        // Store agent data
        _currentUser = {
          'id': response['id'],
          'username': username,
          'name': response['fullName'],
          'email': response['email'],
          'phone': response['phone'],
          'type': 'Agent',
        };
        _isLoggedIn = true;
        _token = response['token'];
        
        _storeUserData();
        
        return {'success': true, 'message': 'Login successful'};
      } else {
        return {
          'success': false, 
          'message': response['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  Future<Map<String, dynamic>> registerAgent(Map<String, dynamic> agentData) async {
    try {
      final response = await ApiService.post('/users/register', {
        'fullName': agentData['name'],
        'email': agentData['email'],
        'password': agentData['password'],
        'phone': agentData['phone'],
        'username': agentData['username'],
      });

      if (response['success'] == true) {
        // Store agent data
        _currentUser = {
          'id': response['id'],
          'username': agentData['username'],
          'name': agentData['name'],
          'email': agentData['email'],
          'phone': agentData['phone'],
          'type': agentData['facilityType'],
        };
        _isLoggedIn = true;
        _token = response['token'];
        
        _storeUserData();
        
        return {'success': true, 'message': 'Registration successful'};
      } else {
        return {
          'success': false, 
          'message': response['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock OTP sending
      if (email.isNotEmpty) {
        return {'success': true, 'message': 'OTP sent successfully'};
      } else {
        return {'success': false, 'message': 'Invalid email address'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to send OTP: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock OTP verification
      if (email.isNotEmpty && otp.isNotEmpty) {
        return {'success': true, 'message': 'OTP verified successfully'};
      } else {
        return {'success': false, 'message': 'Invalid OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'OTP verification failed: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock password reset
      if (email.isNotEmpty && otp.isNotEmpty && newPassword.isNotEmpty) {
        return {'success': true, 'message': 'Password reset successful'};
      } else {
        return {'success': false, 'message': 'Password reset failed: Missing information'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Password reset failed: $e'};
    }
  }
}
