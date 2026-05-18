import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api/booking_api.dart';

class AgentBookingPage extends StatefulWidget {
  const AgentBookingPage({super.key});

  @override
  State<AgentBookingPage> createState() => _AgentBookingPageState();
}

class _AgentBookingPageState extends State<AgentBookingPage> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Confirmed', 'Pending', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final agent = AuthService.instance.currentAgent;
      final agentId = agent?['id'] as int?;
      if (agentId != null) {
        final response = await BookingApi.getBookings(
          facilityId: agentId,
          token: AuthService.instance.agentToken,
        );
        if (response['success'] == true && response['bookings'] != null) {
          final List<dynamic> bookingsList = response['bookings'];
          setState(() {
            _bookings = bookingsList.map((b) => Map<String, dynamic>.from(b)).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading agent bookings: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  String _capitalize(String text) {
    if (text.isEmpty) return 'Pending';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'All') {
      return _bookings;
    }
    return _bookings.where((booking) {
      final status = _capitalize(booking['status'] ?? 'pending');
      return status == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
                          selectedColor: Colors.blue.shade100,
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue.shade900 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                // Bookings List
                Expanded(
                  child: _filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No ${_selectedFilter.toLowerCase()} bookings',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (BuildContext context, int index) {
                            final booking = _filteredBookings[index];
                            return _buildBookingCard(booking);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final rawStatus = booking['status'] as String? ?? 'pending';
    final status = _capitalize(rawStatus);
    final statusColor = _getStatusColor(status);
    
    final patientName = booking['patientName'] ?? booking['patient'] ?? 'Unknown Patient';
    final service = booking['purpose'] ?? booking['service'] ?? 'General Consult';
    final dateTime = '${booking['appointmentDate'] ?? ''} @ ${booking['appointmentTime'] ?? ''}';
    final phone = booking['patientPhone'] ?? booking['phone'] ?? 'No Phone';
    final email = booking['userEmail'] ?? booking['email'] ?? 'No Email';
    final paymentStatus = booking['paymentStatus'] as String? ?? 'unpaid';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            _getStatusIcon(status),
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          patientName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          service,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateTime,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        phone,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          const Text('Payment: ', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: paymentStatus == 'paid' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              paymentStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (status == 'Pending') ...[
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(booking, 'Confirmed'),
                          icon: const Icon(Icons.check, size: 16, color: Colors.white),
                          label: const Text('Confirm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _updateStatus(booking, 'Cancelled'),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ] else if (status == 'Confirmed') ...[
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(booking, 'Completed'),
                          icon: const Icon(Icons.done_all, size: 16, color: Colors.white),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _contactPatient(booking),
                          icon: const Icon(Icons.message, size: 16),
                          label: const Text('Contact'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ] else ...[
                        OutlinedButton.icon(
                          onPressed: () => _viewDetails(booking),
                          icon: const Icon(Icons.info, size: 16),
                          label: const Text('Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Confirmed':
        return Icons.check_circle;
      case 'Pending':
        return Icons.schedule;
      case 'Completed':
        return Icons.done_all;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Future<void> _updateStatus(Map<String, dynamic> booking, String newStatus) async {
    final bookingId = booking['id'] as int?;
    if (bookingId == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await BookingApi.updateBookingStatus(
        bookingId,
        newStatus,
        token: AuthService.instance.agentToken,
      );
      if (response['success'] == true) {
        await _loadBookings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Booking status updated to $newStatus successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update status: ${response['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating booking status: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _contactPatient(Map<String, dynamic> booking) {
    final patientName = booking['patientName'] ?? booking['patient'] ?? 'Unknown Patient';
    final phone = booking['patientPhone'] ?? booking['phone'] ?? '';
    final email = booking['userEmail'] ?? booking['email'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact $patientName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose contact method:'),
              const SizedBox(height: 8),
              if (phone.isNotEmpty) ...[
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling $patientName ($phone)...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.green, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Call', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Messaging $patientName...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.message, color: Colors.blue, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Send Message', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (email.isNotEmpty) ...[
                const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Emailing $patientName...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.email, color: Colors.red, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Send Email', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewDetails(Map<String, dynamic> booking) {
    final patientName = booking['patientName'] ?? booking['patient'] ?? 'Unknown Patient';
    final service = booking['purpose'] ?? booking['service'] ?? 'General Consult';
    final dateTime = '${booking['appointmentDate'] ?? ''} @ ${booking['appointmentTime'] ?? ''}';
    final phone = booking['patientPhone'] ?? booking['phone'] ?? '';
    final email = booking['userEmail'] ?? booking['email'] ?? '';
    final rawStatus = booking['status'] as String? ?? 'pending';
    final status = _capitalize(rawStatus);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details - $patientName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Service:', service),
              const SizedBox(height: 12),
              _buildDetailRow('Date & Time:', dateTime),
              const SizedBox(height: 12),
              _buildDetailRow('Phone:', phone),
              const SizedBox(height: 12),
              _buildDetailRow('Email:', email),
              const SizedBox(height: 12),
              _buildDetailRow('Status:', status, color: _getStatusColor(status)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.black54,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
          softWrap: true,
        ),
      ],
    );
  }
}