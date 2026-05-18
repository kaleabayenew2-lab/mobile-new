import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'api/booking_api.dart';

class AppNotification {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      subtitle: subtitle,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _startTimer();
  }

  static NotificationService get instance => _instance;

  final List<AppNotification> _notifications = [];
  bool _shouldBlink = false;
  Timer? _timer;
  bool _isFirstRun = true;
  
  // Track seen IDs to avoid blinking for old notifications
  final Set<String> _knownNotificationIds = {};

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get shouldBlink => _shouldBlink;

  void setShouldBlink(bool value) {
    _shouldBlink = value;
    notifyListeners();
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _shouldBlink = false;
    notifyListeners();
  }

  void _startTimer() {
    // Check immediately on startup/instantiation
    checkNotifications();
    
    // Check periodically
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      checkNotifications();
    });
  }

  void resetFirstRun() {
    _isFirstRun = true;
    _notifications.clear();
    _knownNotificationIds.clear();
    _shouldBlink = false;
    checkNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> checkNotifications() async {
    final auth = AuthService.instance;
    bool hasChanges = false;
    
    // 1. Agent Notification Check
    if (auth.isAgentLoggedIn) {
      final agent = auth.currentAgent;
      final agentId = agent?['id'] as int?;
      if (agentId != null) {
        try {
          final response = await BookingApi.getBookings(
            facilityId: agentId,
            token: auth.agentToken,
          );
          if (response['success'] == true && response['bookings'] != null) {
            final List<dynamic> bookings = response['bookings'];
            bool hasNew = false;
            for (final booking in bookings) {
              final id = booking['id']?.toString() ?? '';
              final notifId = 'agent_booking_$id';
              
              if (!_knownNotificationIds.contains(notifId)) {
                _knownNotificationIds.add(notifId);
                
                final patientName = booking['patientName'] ?? booking['patient'] ?? 'Patient';
                final service = booking['purpose'] ?? booking['service'] ?? 'Consultation';
                
                _notifications.insert(0, AppNotification(
                  id: notifId,
                  title: 'New Booking Request',
                  subtitle: '$patientName requested a $service.',
                  timestamp: DateTime.now(),
                  isRead: _isFirstRun,
                ));
                
                hasChanges = true;
                if (!_isFirstRun) {
                  hasNew = true;
                }
              }
            }
            if (hasNew) {
              _shouldBlink = true;
            }
          }
        } catch (e) {
          debugPrint('Error in notification agent check: $e');
        }
      }
    }

    // 2. User Notification Check
    if (auth.isLoggedIn) {
      final email = auth.userEmail;
      if (email != null && email.isNotEmpty) {
        try {
          final response = await BookingApi.getBookings(
            email: email,
            token: auth.token,
          );
          if (response['success'] == true && response['bookings'] != null) {
            final List<dynamic> bookings = response['bookings'];
            bool hasNew = false;
            
            for (final booking in bookings) {
              final status = booking['status']?.toString().toLowerCase() ?? '';
              if (status == 'confirmed') {
                final id = booking['id']?.toString() ?? '';
                final notifId = 'user_reminder_$id';
                
                // Parse date & time
                final dateStr = booking['appointmentDate']?.toString() ?? '';
                final timeStr = booking['appointmentTime']?.toString() ?? '';
                final appointmentTime = _parseDateTime(dateStr, timeStr);
                
                if (appointmentTime != null) {
                  final difference = appointmentTime.difference(DateTime.now());
                  // If appointment is within 1 hour (60 minutes) remaining and in the future or very recent
                  if (difference.inMinutes > -10 && difference.inMinutes <= 60) {
                    if (!_knownNotificationIds.contains(notifId)) {
                      _knownNotificationIds.add(notifId);
                      
                      final facilityName = booking['facilityName'] ?? 'Facility';
                      
                      _notifications.insert(0, AppNotification(
                        id: notifId,
                        title: 'Appointment Reminder',
                        subtitle: 'Your booking at $facilityName starts in ${difference.inMinutes} minutes!',
                        timestamp: DateTime.now(),
                        isRead: _isFirstRun,
                      ));
                      
                      hasChanges = true;
                      if (!_isFirstRun) {
                        hasNew = true;
                      }
                    }
                  }
                }
              }
            }
            if (hasNew) {
              _shouldBlink = true;
            }
          }
        } catch (e) {
          debugPrint('Error in notification user check: $e');
        }
      }
    }

    if (hasChanges) {
      _isFirstRun = false;
      notifyListeners();
    }
  }

  DateTime? _parseDateTime(String dateStr, String timeStr) {
    try {
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return null;
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final isPm = timeStr.toUpperCase().contains('PM');
      final cleanTime = timeStr.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
      final timeParts = cleanTime.split(':');
      if (timeParts.length != 2) return null;
      
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      if (isPm && hour != 12) {
        hour += 12;
      } else if (!isPm && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }
}
