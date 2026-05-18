import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';
import '../../services/auth_service.dart';
import '../../components/auth_popups.dart';
import '../../services/api/booking_api.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String _activeTab = 'All';
  final _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load patient bookings filtered by user email
  Future<void> _loadBookings() async {
    final auth = AuthService.instance;
    if (!auth.isLoggedIn) {
      setState(() {
        _isLoading = false;
        _bookings = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await BookingApi.getBookings(
        email: auth.userEmail,
        token: auth.token,
      );

      if (response['success'] == true) {
        final List<dynamic> rawList = response['bookings'] ?? [];
        setState(() {
          _bookings = rawList.map((item) => Map<String, dynamic>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to retrieve bookings';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Filtering by tab & search query
  List<Map<String, dynamic>> get _filteredBookings {
    List<Map<String, dynamic>> result = _bookings;

    switch (_activeTab) {
      case 'Upcoming':
        result = result.where((b) => b['status'] == 'confirmed' || b['status'] == 'pending').toList();
        break;
      case 'Completed':
        result = result.where((b) => b['status'] == 'completed').toList();
        break;
      case 'Cancelled':
        result = result.where((b) => b['status'] == 'cancelled').toList();
        break;
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((b) {
        final facName = (b['facilityName'] as String? ?? '').toLowerCase();
        final purpose = (b['purpose'] as String? ?? '').toLowerCase();
        final type = (b['facilityType'] as String? ?? '').toLowerCase();
        return facName.contains(query) || purpose.contains(query) || type.contains(query);
      }).toList();
    }

    return result;
  }

  void _onTabChanged(String tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  // Date and Time picker interactive reschedule
  Future<void> _rescheduleBooking(BuildContext context, Map<String, dynamic> booking) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(booking['appointmentDate']) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: int.tryParse(booking['appointmentTime'].toString().split(':')[0]) ?? 9,
          minute: int.tryParse(booking['appointmentTime'].toString().split(':')[1]) ?? 0,
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.green.shade700,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        final formattedTime = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";

        setState(() {
          booking['appointmentDate'] = formattedDate;
          booking['appointmentTime'] = formattedTime;
          booking['status'] = 'confirmed'; // Auto confirm on reschedule
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📅 Appointment rescheduled for $formattedDate at $formattedTime successfully!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Confirmation dialog and cancellation simulation
  void _cancelBooking(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Cancel Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Are you sure you want to cancel your appointment with "${booking['facilityName']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                booking['status'] = 'cancelled';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Appointment with ${booking['facilityName']} cancelled successfully.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    final status = booking['status'] as String? ?? 'confirmed';
    final statusColor = _getStatusColor(status);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['facilityName'] ?? 'Medical Facility',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        booking['facilityType'] ?? 'Hospital',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _BookingDetailRow(icon: Icons.local_hospital, text: 'Type: ${booking['facilityType'] ?? 'General'}'),
            _BookingDetailRow(icon: Icons.person, text: 'Patient: ${booking['patientName'] ?? 'Self'} (${booking['patientAge'] ?? 0} yrs)'),
            _BookingDetailRow(icon: Icons.calendar_today, text: 'Date: ${booking['appointmentDate']}'),
            _BookingDetailRow(icon: Icons.access_time, text: 'Time: ${booking['appointmentTime']}'),
            _BookingDetailRow(icon: Icons.phone, text: 'Phone: ${booking['patientPhone'] ?? 'N/A'}'),
            _BookingDetailRow(icon: Icons.description, text: 'Purpose: ${booking['purpose'] ?? 'Regular Consultation'}'),
            _BookingDetailRow(
              icon: Icons.payment_rounded,
              text: 'Payment: ${(booking['paymentStatus'] ?? 'unpaid').toUpperCase()} (${booking['paymentMethod'] ?? 'N/A'})',
            ),
            _BookingDetailRow(icon: Icons.attach_money, text: 'Price: ${booking['amount'] ?? 250.0} ETB'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🗺️ Launching GPS Directions to facility...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;

    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'Booking page encountered an error',
      child: MainLayout(
        title: 'My Bookings',
        child: ScrollAwareFooter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!auth.isLoggedIn)
                // 🔒 Beautiful Locked View for Unauthenticated Users
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_person_rounded,
                          size: 48,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Access Your Bookings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please log in to manage your medical appointments, view electronic receipts, and secure healthcare summaries.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await AuthPopups.showLoginPopup(context);
                            setState(() {});
                            if (AuthService.instance.isLoggedIn) {
                              _loadBookings();
                            }
                          },
                          icon: const Icon(Icons.login_rounded, color: Colors.white),
                          label: const Text(
                            'Log In or Register Now',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_isLoading)
                // ⏳ Gorgeous loading indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 120),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Fetching your bookings securely...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              else if (_errorMessage != null)
                // ⚠️ Error View
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red[700], size: 40),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _loadBookings,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
                      ),
                    ],
                  ),
                )
              else ...[
                // 📊 Premium Analytical Header Panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[700]!, Colors.green[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _BookingStatItem(
                            count: _bookings.length,
                            label: 'Total Bookings',
                            icon: Icons.calendar_month_rounded,
                          ),
                          _BookingStatItem(
                            count: _bookings.where((b) => b['status'] == 'confirmed').length,
                            label: 'Confirmed',
                            icon: Icons.check_circle_rounded,
                          ),
                          _BookingStatItem(
                            count: _bookings.where((b) => b['status'] == 'pending').length,
                            label: 'Pending',
                            icon: Icons.hourglass_top_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 🔍 Live Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by hospital, specialty...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                child: const Icon(Icons.clear),
                              )
                            : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🏷️ Dynamic Filter Chips
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: ['All', 'Upcoming', 'Completed', 'Cancelled'].map((tab) {
                      final isActive = _activeTab == tab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onTabChanged(tab),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green[600] : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tab,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey[600],
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

                // 📝 Booking Cards List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_activeTab Bookings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '${_filteredBookings.length} found',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_filteredBookings.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No $_activeTab bookings found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try selecting a different filter tab',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._filteredBookings.map((booking) {
                          final status = booking['status'] as String? ?? 'confirmed';
                          final statusColor = _getStatusColor(status);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: statusColor.withOpacity(0.15),
                                child: Icon(_getStatusIcon(status), color: statusColor, size: 20),
                              ),
                              title: Text(
                                booking['facilityName'] ?? 'Facility',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${booking['purpose'] ?? 'General Consultation'} • For ${booking['patientName'] ?? 'Self'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, color: Colors.grey[400], size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${booking['appointmentDate']} at ${booking['appointmentTime']}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'pending') ...[
                                    IconButton(
                                      icon: const Icon(Icons.schedule_rounded, color: Colors.blueAccent, size: 22),
                                      onPressed: () => _rescheduleBooking(context, booking),
                                      tooltip: 'Reschedule Appointment',
                                      style: IconButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(36, 36),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 22),
                                      onPressed: () => _cancelBooking(context, booking),
                                      tooltip: 'Cancel Appointment',
                                      style: IconButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(36, 36),
                                      ),
                                    ),
                                  ],
                                  IconButton(
                                    icon: const Icon(Icons.info_outline_rounded, color: Colors.green, size: 22),
                                    onPressed: () => _showBookingDetails(context, booking),
                                    tooltip: 'Details',
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(36, 36),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingStatItem extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;

  const _BookingStatItem({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
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

class _BookingDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BookingDetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
