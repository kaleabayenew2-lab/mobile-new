import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// User authentication state management service
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Static getter for the instance
  static AuthService get instance => _instance;

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
    
    debugPrint('✅ User logged in: ${userData['fullName'] ?? userData['email']}');
    
    // Notify listeners to update UI
    notifyListeners();
  }

  /// Set user as logged out
  void logout() {
    final previousState = _isLoggedIn;
    
    _currentUser = null;
    _token = null;
    _isLoggedIn = false;
    
    // Clear local storage
    _clearUserData();
    
    debugPrint('✅ User logged out');
    
    // Only notify if state actually changed
    if (previousState != _isLoggedIn) {
      notifyListeners();
    }
  }

  /// Update user data
  void updateUserData(Map<String, dynamic> userData) {
    if (_currentUser != null) {
      _currentUser!.addAll(userData);
      _storeUserData();
      notifyListeners(); // Notify listeners when user data updates
      debugPrint('✅ User data updated');
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _isLoggedIn && _token != null && _token!.isNotEmpty;
  }

  /// Refresh user data from API (call after profile updates)
  Future<void> refreshUserData() async {
    if (!_isLoggedIn || _token == null) return;
    
    try {
      // Example API call to get updated user data
      // final response = await ApiService.get('/users/profile', token: _token);
      // if (response['success'] == true) {
      //   _currentUser = response['data'];
      //   notifyListeners();
      // }
      debugPrint('🔄 User data refresh requested');
    } catch (e) {
      debugPrint('❌ Failed to refresh user data: $e');
    }
  }

  /// Store user data in local storage (simplified version)
  void _storeUserData() {
    // In a real app, you'd use shared_preferences or secure_storage
    // For now, we'll just keep it in memory
    if (kDebugMode) {
      debugPrint('📦 User data stored: ${jsonEncode(_currentUser)}');
      debugPrint('🔑 Token stored (length: ${_token?.length ?? 0})');
    }
  }

  /// Clear user data from local storage
  void _clearUserData() {
    // In a real app, you'd clear shared_preferences or secure_storage
    debugPrint('🗑️ User data cleared');
  }

  /// Initialize auth state from storage (simplified version)
  Future<void> initialize() async {
    // In a real app, you'd load from shared_preferences or secure_storage
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // _token = prefs.getString('auth_token');
    // if (_token != null) {
    //   final userJson = prefs.getString('user_data');
    //   if (userJson != null) {
    //     _currentUser = jsonDecode(userJson);
    //     _isLoggedIn = true;
    //   }
    // }
    debugPrint('🚀 AuthService initialized (isLoggedIn: $_isLoggedIn)');
    notifyListeners(); // Ensure UI reflects initial state
  }

  /// Get user display name
  String get userDisplayName {
    if (_currentUser == null) return 'Guest';
    
    // Try fullName first
    final fullName = _currentUser!['fullName'] as String?;
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    // Try name
    final name = _currentUser!['name'] as String?;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    
    // Fallback to email username part
    final email = _currentUser!['email'] as String?;
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    
    return 'User';
  }

  /// Get user avatar initial (first letter of name or email)
  String get userAvatarInitial {
    final displayName = userDisplayName;
    if (displayName == 'Guest') return 'G';
    
    if (displayName.isNotEmpty && displayName != 'User') {
      return displayName[0].toUpperCase();
    }
    
    final email = userEmail;
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    
    return 'U';
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
          'fullName': response['fullName'], // Add fullName for consistency
        };
        _isLoggedIn = true;
        _token = response['token'];
        
        _storeUserData();
        notifyListeners(); // Ensure UI updates
        
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
          'fullName': agentData['name'], // Add fullName for consistency
          'email': agentData['email'],
          'phone': agentData['phone'],
          'type': agentData['facilityType'],
        };
        _isLoggedIn = true;
        _token = response['token'];
        
        _storeUserData();
        notifyListeners(); // Ensure UI updates
        
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
      if (email.isNotEmpty && email.contains('@')) {
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
      
      // Mock OTP verification (accept any 6-digit code for demo)
      if (email.isNotEmpty && otp.isNotEmpty && otp.length >= 4) {
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
      if (email.isNotEmpty && otp.isNotEmpty && newPassword.isNotEmpty && newPassword.length >= 6) {
        return {'success': true, 'message': 'Password reset successful'};
      } else {
        return {'success': false, 'message': 'Password reset failed: Missing information or weak password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Password reset failed: $e'};
    }
  }
}