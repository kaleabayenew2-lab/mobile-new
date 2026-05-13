import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  bool _isOnline = true;
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionController.stream;

  bool get isOnline => _isOnline;

  void setOnlineStatus(bool status) {
    _isOnline = status;
    _connectionController.add(status);
  }

  Future<bool> checkConnection() async {
    try {
      // Simulate connection check
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo, always return true
      // In production, you would check actual internet connectivity
      return true;
    } catch (e) {
      // Use debugPrint for development logging instead of print
      if (kDebugMode) {
        debugPrint('Connection check error: $e');
      }
      return false;
    }
  }

  void dispose() {
    _connectionController.close();
  }
}
