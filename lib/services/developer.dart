import 'package:flutter/foundation.dart';

class DeveloperSettings {
  static bool _isDeveloperMode = false;
  
  static bool get isDeveloperMode => _isDeveloperMode;
  
  static void setDeveloperMode(bool enabled) {
    _isDeveloperMode = enabled;
    if (kDebugMode) {
      print('Developer mode ${enabled ? "enabled" : "disabled"}');
    }
  }
  
  static void toggleDeveloperMode() {
    _isDeveloperMode = !_isDeveloperMode;
    if (kDebugMode) {
      print('Developer mode toggled to ${_isDeveloperMode ? "enabled" : "disabled"}');
    }
  }
}
