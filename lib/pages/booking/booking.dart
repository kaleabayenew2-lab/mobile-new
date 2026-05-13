import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String _activeTab = 'All';

  // Tab filtering logic
  List<Map<String, dynamic>> get _filteredBookings {
    switch (_activeTab) {
      case 'Upcoming':
        return sampleBookings.where((b) => b['status'] == 'confirmed' || b['status'] == 'pending').toList();
      case 'Completed':
        return sampleBookings.where((b) => b['status'] == 'completed').toList();
      case 'Cancelled':
        return sampleBookings.where((b) => b['status'] == 'cancelled').toList();
      default:
        return sampleBookings;
    }
  }

  void _onTabChanged(String tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  // Sample booking data
  List<Map<String, dynamic>> get sampleBookings => [
    {
      'id': '1',
      'facilityName': 'Black Lion Hospital',
      'facilityType': 'Hospital',
      'department': 'Cardiology',
      'doctorName': 'Dr. Alemu Bekele',
      'appointmentDate': '2024-05-15',
      'appointmentTime': '14:30',
      'status': 'confirmed',
      'address': 'Bole, Addis Ababa, Ethiopia',
      'phone': '+251911234567',
      'purpose': 'Regular Checkup',
      'notes': 'Annual health examination',
    },
    {
      'id': '2',
      'facilityName': 'Luna Pharmacy',
      'facilityType': 'Pharmacy',
      'department': 'Prescription',
      'doctorName': 'Dr. Hanna Tesfaye',
      'appointmentDate': '2024-05-18',
      'appointmentTime': '10:00',
      'status': 'pending',
      'address': 'Kazanchis, Addis Ababa, Ethiopia',
      'phone': '+251914567890',
      'purpose': 'Medication Pickup',
      'notes': 'Monthly prescription refill',
    },
    {
      'id': '3',
      'facilityName': 'St. Paulos Hospital',
      'facilityType': 'Hospital',
      'department': 'Orthopedics',
      'doctorName': 'Dr. Kassahun Mengistu',
      'appointmentDate': '2024-05-20',
      'appointmentTime': '09:00',
      'status': 'completed',
      'address': 'Mekelle, Addis Ababa, Ethiopia',
      'phone': '+251912345678',
      'purpose': 'Follow-up Consultation',
      'notes': 'Post-surgery follow up',
    },
    {
      'id': '4',
      'facilityName': 'Addis Ababa Medical Center',
      'facilityType': 'Medical Center',
      'department': 'General Practice',
      'doctorName': 'Dr. Sara Mohammed',
      'appointmentDate': '2024-05-22',
      'appointmentTime': '16:45',
      'status': 'cancelled',
      'address': 'Bole, Addis Ababa, Ethiopia',
      'phone': '+251913456789',
      'purpose': 'Consultation',
      'notes': 'Initial consultation',
    },
    {
      'id': '5',
      'facilityName': 'Hayat Hospital',
      'facilityType': 'Hospital',
      'department': 'Pediatrics',
      'doctorName': 'Dr. Solomon Abebe',
      'appointmentDate': '2024-05-25',
      'appointmentTime': '11:30',
      'status': 'confirmed',
      'address': 'CMC, Addis Ababa, Ethiopia',
      'phone': '+251915678901',
      'purpose': 'Child Checkup',
      'notes': 'Routine pediatric examination',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'Booking page encountered an error',
      child: MainLayout(
        title: 'My Bookings',
        child: ScrollAwareFooter(
          child: Column(
            children: [
              // Stats Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BookingStatItem(
                          count: sampleBookings.length,
                          label: 'Total',
                          icon: Icons.calendar_month,
                        ),
                        _BookingStatItem(
                          count: sampleBookings.where((b) => b['status'] == 'confirmed').length,
                          label: 'Confirmed',
                          icon: Icons.check_circle,
                        ),
                        _BookingStatItem(
                          count: sampleBookings.where((b) => b['status'] == 'pending').length,
                          label: 'Pending',
                          icon: Icons.pending,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filter Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _BookingFilterTab(
                        title: 'All',
                        isActive: _activeTab == 'All',
                        onTap: () => _onTabChanged('All'),
                      ),
                    ),
                    Expanded(
                      child: _BookingFilterTab(
                        title: 'Upcoming',
                        isActive: _activeTab == 'Upcoming',
                        onTap: () => _onTabChanged('Upcoming'),
                      ),
                    ),
                    Expanded(
                      child: _BookingFilterTab(
                        title: 'Completed',
                        isActive: _activeTab == 'Completed',
                        onTap: () => _onTabChanged('Completed'),
                      ),
                    ),
                    Expanded(
                      child: _BookingFilterTab(
                        title: 'Cancelled',
                        isActive: _activeTab == 'Cancelled',
                        onTap: () => _onTabChanged('Cancelled'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_filteredBookings.length} bookings found',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Bookings List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_activeTab} Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Booking Items
                    if (_filteredBookings.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${_activeTab.toLowerCase()} bookings found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different tab',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._filteredBookings.map((booking) => _BookingCard(
                        booking: booking,
                        onTap: () => _showBookingDetails(context, booking),
                        onCancel: () => _cancelBooking(context, booking),
                        onReschedule: () => _rescheduleBooking(context, booking),
                      )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
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
                    color: _getStatusColor(booking['status']).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(booking['status']),
                    color: _getStatusColor(booking['status']),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['facilityName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        booking['facilityType'],
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
                    color: _getStatusColor(booking['status']).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(booking['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _BookingDetailRow(icon: Icons.local_hospital, text: booking['department']),
            _BookingDetailRow(icon: Icons.person, text: booking['doctorName']),
            _BookingDetailRow(icon: Icons.calendar_today, text: booking['appointmentDate']),
            _BookingDetailRow(icon: Icons.access_time, text: booking['appointmentTime']),
            _BookingDetailRow(icon: Icons.location_on, text: booking['address']),
            _BookingDetailRow(icon: Icons.phone, text: booking['phone']),
            _BookingDetailRow(icon: Icons.description, text: booking['purpose']),
            _BookingDetailRow(icon: Icons.note, text: booking['notes']),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Get Directions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
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

  void _cancelBooking(BuildContext context, Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking with ${booking['facilityName']} cancelled'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action undone')),
            );
          },
        ),
      ),
    );
  }

  void _rescheduleBooking(BuildContext context, Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reschedule ${booking['facilityName']} booking'),
        action: SnackBarAction(
          label: 'Select Date',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Date selection dialog would open here')),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
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
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _BookingFilterTab extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _BookingFilterTab({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.green[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(booking['status']).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(booking['status']),
            color: _getStatusColor(booking['status']),
            size: 24,
          ),
        ),
        title: Text(
          booking['facilityName'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${booking['department']} • ${booking['doctorName']}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  '${booking['appointmentDate']} at ${booking['appointmentTime']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking['status']).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(booking['status']),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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
            if (booking['status'] == 'confirmed' || booking['status'] == 'pending') ...[
              IconButton(
                icon: const Icon(Icons.schedule, color: Colors.blue),
                onPressed: onReschedule,
                tooltip: 'Reschedule',
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: onCancel,
                tooltip: 'Cancel',
              ),
            ],
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.green),
              onPressed: onTap,
              tooltip: 'Details',
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
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
