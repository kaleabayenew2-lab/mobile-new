import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';
import '../../components/auth_popups.dart';
import '../../services/auth_service.dart';
import '../../services/api/booking_api.dart';
import '../../services/notification_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _activeTab = 'Bookings'; // 'Bookings' or 'Recent Activity'
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Add listener to rebuild when notification states or auth states change
    AuthService.instance.addListener(_onAuthChanged);
    NotificationService.instance.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    NotificationService.instance.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      _loadData();
    }
  }

  void _onNotificationsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    final isLoggedIn = AuthService.instance.isLoggedIn;
    if (!isLoggedIn) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = AuthService.instance.userEmail;
      if (email != null) {
        final response = await BookingApi.getBookings(
          email: email,
          token: AuthService.instance.token,
        );
        if (response['success'] == true && response['bookings'] != null) {
          final List<dynamic> bookingsList = response['bookings'];
          setState(() {
            _bookings = bookingsList.map((b) => Map<String, dynamic>.from(b)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading history bookings: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showLoginPopup() {
    AuthPopups.showLoginPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.instance.isLoggedIn;

    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'History page encountered an error',
      child: MainLayout(
        title: 'My History',
        child: ScrollAwareFooter(
          child: !isLoggedIn
              ? _buildLockedScreen()
              : _isLoading
                  ? const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildHistoryContent(),
        ),
      ),
    );
  }

  Widget _buildLockedScreen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Locked Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Headline
          const Text(
            'Authentication Required',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // Sub-headline
          Text(
            'To view your appointment bookings and dynamic activity logs, please log in to your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          // CTA Login Button
          ElevatedButton.icon(
            onPressed: _showLoginPopup,
            icon: const Icon(Icons.login_rounded, color: Colors.white),
            label: const Text(
              'Log In Now',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    final totalCount = _bookings.length;
    final paidCount = _bookings.where((b) => b['paymentStatus'] == 'paid').length;
    final notificationsCount = NotificationService.instance.notifications.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📊 Premium Stats Cards Panel
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade700, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Your Activity Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _HistoryStatItem(
                    count: totalCount,
                    label: 'Bookings',
                    icon: Icons.book_rounded,
                  ),
                  _HistoryStatItem(
                    count: paidCount,
                    label: 'Paid',
                    icon: Icons.check_circle_rounded,
                  ),
                  _HistoryStatItem(
                    count: notificationsCount,
                    label: 'Activities',
                    icon: Icons.notifications_active_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),

        // 🏷️ Dynamic Filter Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: ['Bookings', 'Recent Activity'].map((tab) {
              final isActive = _activeTab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = tab;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.purple.shade600 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade600,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Content body based on selected tab
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _activeTab == 'Bookings' ? _buildBookingsList() : _buildActivitiesList(),
        ),
      ],
    );
  }

  Widget _buildBookingsList() {
    if (_bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.book_online_outlined,
        title: 'No Bookings Found',
        subtitle: 'You have not booked any appointments yet.',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final b = _bookings[index];
        final facilityName = b['facilityName'] ?? 'Medical Facility';
        final facilityType = b['facilityType'] ?? 'Hospital';
        final purpose = b['purpose'] ?? 'General Consult';
        final date = b['appointmentDate'] ?? '';
        final time = b['appointmentTime'] ?? '';
        final status = b['status']?.toString().toUpperCase() ?? 'PENDING';
        final paymentStatus = b['paymentStatus']?.toString().toUpperCase() ?? 'UNPAID';
        final amount = b['amount'] ?? 250.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.1),
              child: const Icon(Icons.local_hospital_rounded, color: Colors.purple),
            ),
            title: Text(
              facilityName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '$facilityType • $purpose',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '$date @ $time',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == 'CONFIRMED' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: status == 'CONFIRMED' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: paymentStatus == 'PAID' ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        paymentStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: paymentStatus == 'PAID' ? Colors.blue : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              '${amount} ETB',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitiesList() {
    final list = NotificationService.instance.notifications;

    if (list.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'No Recent Activity',
        subtitle: 'Your clinical activity log is currently empty.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 12),
      itemBuilder: (context, index) {
        final n = list[index];
        final isReminder = n.id.startsWith('user_reminder_');
        final isAgent = n.id.startsWith('agent_');
        final timeDiff = DateTime.now().difference(n.timestamp).inMinutes;
        final timeText = timeDiff <= 0 ? 'Just now' : '${timeDiff}m ago';

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: isReminder
                ? Colors.orange.withOpacity(0.1)
                : (isAgent ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
            child: Icon(
              isReminder
                  ? Icons.access_time_rounded
                  : (isAgent ? Icons.calendar_today_rounded : Icons.notifications_rounded),
              color: isReminder ? Colors.orange : (isAgent ? Colors.blue : Colors.green),
            ),
          ),
          title: Text(
            n.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                n.subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                timeText,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HistoryStatItem extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;

  const _HistoryStatItem({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}