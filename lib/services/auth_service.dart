import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'notification_service.dart';

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

  // Agent/Facility data
  Map<String, dynamic>? _currentAgent;
  String? _agentToken;
  bool _isAgentLoggedIn = false;

  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _currentUser?['fullName'];
  String? get userEmail => _currentUser?['email'];
  String? get userPhone => _currentUser?['phone'];
  String? get userId => _currentUser?['id']?.toString();

  Map<String, dynamic>? get currentAgent => _currentAgent;
  String? get agentToken => _agentToken;
  bool get isAgentLoggedIn => _isAgentLoggedIn;

  /// Set user as logged in
  void login(Map<String, dynamic> userData, String token) {
    _currentUser = userData;
    _token = token;
    _isLoggedIn = true;
    
    // Store in local storage for persistence
    _storeUserData();
    
    debugPrint('✅ User logged in: ${userData['fullName'] ?? userData['email']}');
    
    // Reset notification service first run for new session
    NotificationService.instance.resetFirstRun();

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
    
    // Reset notifications
    NotificationService.instance.resetFirstRun();

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
      final response = await ApiService.post('/agents/login', {
        'username': username,
        'password': password,
      });

      if (response['success'] == true) {
        // Store all returned agent/facility fields in _currentAgent
        _currentAgent = {
          'id': response['id'],
          'agentId': response['agentId'],
          'username': response['username'] ?? username,
          'name': response['name'] ?? response['fullName'] ?? '',
          'fullName': response['name'] ?? response['fullName'] ?? '',
          'email': response['email'] ?? '',
          'phone': response['phone'] ?? '',
          'type': response['type'] ?? 'hospital',
          'hospitalType': response['hospitalType'],
          'pharmacyType': response['pharmacyType'],
          'address': response['address'] ?? '',
          'openingHours': response['openingHours'] ?? '',
          'ownership': response['ownership'] ?? '',
          'isEmergency': response['isEmergency'] ?? false,
          'isActive': response['isActive'] ?? true,
          'services': response['services'] ?? [],
          'latitude': response['latitude'],
          'longitude': response['longitude'],
          'profileImage': response['profileImage'],
          'averageRating': response['averageRating'] ?? 0.0,
          'ratingCount': response['ratingCount'] ?? 0,
          'viewsTotal': response['viewsTotal'] ?? 0,
          'favoriteCount': response['favoriteCount'] ?? 0,
          'createdAt': response['createdAt'],
        };
        _isAgentLoggedIn = true;
        _agentToken = response['token'];
        
        _storeUserData();
        
        // Reset notifications for agent
        NotificationService.instance.resetFirstRun();

        notifyListeners();
        
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
      final response = await ApiService.post('/agents/register', agentData);

      if (response['success'] == true) {
        // Store full agent data in _currentAgent
        _currentAgent = {
          'id': response['id'],
          'agentId': response['agentId'] ?? response['id']?.toString(),
          'username': agentData['username'],
          'name': agentData['name'],
          'fullName': agentData['name'],
          'email': agentData['email'],
          'phone': agentData['phone'],
          'type': agentData['facility_type']?.toString().toLowerCase(),
          'hospitalType': agentData['facility_type']?.toString().toLowerCase() == 'hospital' ? agentData['facility_sub_type'] : null,
          'pharmacyType': agentData['facility_type']?.toString().toLowerCase() == 'pharmacy' ? agentData['facility_sub_type'] : null,
          'address': agentData['address'] ?? '',
          'openingHours': agentData['opening_hours'] ?? '',
          'ownership': agentData['ownership'] ?? '',
          'isEmergency': agentData['emergency_enabled'] ?? false,
          'isActive': true,
          'services': agentData['services'] ?? [],
          'latitude': agentData['latitude'],
          'longitude': agentData['longitude'],
          'profileImage': agentData['profile_image'],
          'galleryImages': agentData['gallery_images'] ?? [],
          'notes': agentData['note'] ?? '',
          'averageRating': 0.0,
          'ratingCount': 0,
          'viewsTotal': 0,
          'favoriteCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        };
        _isAgentLoggedIn = true;
        _agentToken = response['token'];
        
        _storeUserData();
        
        // Reset notifications for agent
        NotificationService.instance.resetFirstRun();

        notifyListeners(); // Ensure UI updates
        
        return {'success': true, 'message': 'Registration successful', 'data': response};
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

  /// Set agent as logged out
  void logoutAgent() {
    final previousState = _isAgentLoggedIn;
    
    _currentAgent = null;
    _agentToken = null;
    _isAgentLoggedIn = false;
    
    _clearUserData();
    
    debugPrint('✅ Agent logged out');
    
    // Reset notifications
    NotificationService.instance.resetFirstRun();

    if (previousState != _isAgentLoggedIn) {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
    try {
      final response = await ApiService.post('/agents/forgot-password', {
        'email': email,
      });
      return response;
    } catch (e) {
      return {'success': false, 'message': 'Failed to send OTP: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await ApiService.post('/agents/verify-otp', {
        'email': email,
        'otp': otp,
      });
      return response;
    } catch (e) {
      return {'success': false, 'message': 'OTP verification failed: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await ApiService.post('/agents/reset-password', {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
      return response;
    } catch (e) {
      return {'success': false, 'message': 'Password reset failed: $e'};
    }
  }

  Future<Map<String, dynamic>> updateAgentProfile(Map<String, dynamic> updatedData) async {
    try {
      final response = await ApiService.put('/agents/profile', {
        'id': _currentAgent?['id'],
        ...updatedData,
      });

      if (response != null && response['success'] == true) {
        final facility = response['facility'];
        _currentAgent = {
          'id': facility['id'],
          'agentId': facility['agentId'],
          'username': facility['username'],
          'name': facility['name'] ?? facility['fullName'] ?? '',
          'fullName': facility['name'] ?? facility['fullName'] ?? '',
          'email': facility['email'] ?? '',
          'phone': facility['phone'] ?? '',
          'type': facility['type'] ?? 'hospital',
          'hospitalType': facility['hospitalType'],
          'pharmacyType': facility['pharmacyType'],
          'address': facility['address'] ?? '',
          'openingHours': facility['openingHours'] ?? '',
          'ownership': facility['ownership'] ?? '',
          'isEmergency': facility['isEmergency'] ?? false,
          'isActive': facility['isActive'] ?? true,
          'services': facility['services'] ?? [],
          'latitude': facility['latitude'],
          'longitude': facility['longitude'],
          'profileImage': facility['profileImage'],
          'averageRating': (facility['averageRating'] ?? 0.0).toDouble(),
          'ratingCount': facility['ratingCount'] ?? 0,
          'viewsTotal': facility['viewsTotal'] ?? 0,
          'favoriteCount': facility['favoriteCount'] ?? 0,
          'createdAt': facility['createdAt'],
        };
        _storeUserData();
        notifyListeners();
        return {'success': true, 'message': 'Profile updated successfully'};
      } else {
        return {'success': false, 'message': response?['message'] ?? 'Failed to update profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateAgentCredentials({
    required String username,
    required String currentPassword,
    String? newPassword,
  }) async {
    try {
      final response = await ApiService.put('/agents/change-credentials', {
        'id': _currentAgent?['id'],
        'username': username,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response != null && response['success'] == true) {
        if (_currentAgent != null) {
          _currentAgent!['username'] = response['username'] ?? username;
          _storeUserData();
          notifyListeners();
        }
        return {'success': true, 'message': response['message'] ?? 'Credentials updated successfully'};
      } else {
        return {'success': false, 'message': response?['message'] ?? 'Failed to update credentials'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}