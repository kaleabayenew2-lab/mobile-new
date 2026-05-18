import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/auth_popups.dart';
import '../../services/auth_service.dart';
import '../../services/api/facility_api.dart';
import '../../services/api/favorites_api.dart';
import '../../services/api/booking_api.dart';
import '../../utils/network_url.dart';
import 'facility.dart';
import '../map/map.dart';

class DetailFacility extends StatefulWidget {
  final FacilityItem facility;

  const DetailFacility({
    super.key,
    required this.facility,
  });

  @override
  State<DetailFacility> createState() => _DetailFacilityState();
}

class _DetailFacilityState extends State<DetailFacility> {
  final PageController _galleryController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _galleryPageIndex = 0;
  bool _isFavorite = false;
  bool _isSavingFavorite = false;
  int _viewsCount = 0;

  bool _isNetworkImage(String imageUrl) {
    return imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://') ||
        imageUrl.startsWith('//') ||
        imageUrl.startsWith('/uploads/') ||
        imageUrl.startsWith('uploads/');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.facility.isFavorite;
    _viewsCount = widget.facility.viewsTotal ?? 0;
    _recordFacilityView();
  }

  Future<void> _recordFacilityView() async {
    if (widget.facility.id == null) return;
    try {
      final auth = AuthService.instance;
      String? viewerEmail;
      if (auth.isLoggedIn) {
        viewerEmail = auth.userEmail;
      }
      final response = await FacilityApi.recordView(
        widget.facility.id!,
        viewerIdentifier: viewerEmail,
        viewerType: viewerEmail != null ? 'email' : 'device',
      );
      if (response['ok'] == true && response['viewsTotal'] != null) {
        if (mounted) {
          setState(() {
            _viewsCount = int.tryParse(response['viewsTotal'].toString()) ?? _viewsCount;
          });
        }
      }
    } catch (_) {
      // Ignore view recording failures.
    }
  }

  String _normalizeImageUrl(String imageUrl) {
    return resolveHostUrl(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final galleryImages = (widget.facility.galleryImages ?? []).take(10).toList();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Facility Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: _isSavingFavorite
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.blue,
                              ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Column(
                children: [
                  // Profile icon at the top with gallery thumbnails below
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: widget.facility.profileImage != null && widget.facility.profileImage!.isNotEmpty
                                ? _isNetworkImage(_normalizeImageUrl(widget.facility.profileImage!))
                                    ? Image.network(
                                        _normalizeImageUrl(widget.facility.profileImage!),
                                        width: 92,
                                        height: 92,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        _normalizeImageUrl(widget.facility.profileImage!),
                                        width: 92,
                                        height: 92,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          );
                                        },
                                      )
                                : const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (galleryImages.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gallery',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 180,
                                  child: PageView.builder(
                                    controller: _galleryController,
                                    itemCount: galleryImages.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _galleryPageIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final normalizedUrl = _normalizeImageUrl(galleryImages[index]);
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          color: Colors.grey.shade100,
                                          child: _isNetworkImage(normalizedUrl)
                                              ? Image.network(
                                                  normalizedUrl,
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  height: 180,
                                                  alignment: Alignment.center,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.image,
                                                          size: 48,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Image.asset(
                                                  normalizedUrl,
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  height: 180,
                                                  alignment: Alignment.center,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.image,
                                                          size: 48,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(galleryImages.length, (indicatorIndex) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _galleryPageIndex == indicatorIndex
                                            ? Colors.blue
                                            : Colors.grey.shade300,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Facility Details
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Facility Name and Type with View Counter
                          Text(
                            widget.facility.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.facility.facilityType,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.visibility_outlined,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$_viewsCount views',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Location and Distance Side by Side
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoSection(
                                  'Location',
                                  Icons.location_on,
                                  widget.facility.location,
                                  Colors.red,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoSection(
                                  'Distance',
                                  Icons.directions_walk,
                                  widget.facility.distance,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Phone Number and Email Side by Side
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoSection(
                                  'Phone Number',
                                  Icons.phone,
                                  widget.facility.phoneNumber,
                                  Colors.blue,
                                  canCopy: true,
                                ),
                              ),
                              if (widget.facility.email != null && widget.facility.email!.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoSection(
                                    'Email',
                                    Icons.email,
                                    widget.facility.email!,
                                    Colors.purple,
                                    canCopy: true,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Opening Hours and Type Side by Side
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoSection(
                                  'Opening Hours',
                                  Icons.access_time,
                                  widget.facility.openingHours ?? 'Not specified',
                                  Colors.orange,
                                ),
                              ),
                              if (widget.facility.hospitalType != null) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoSection(
                                    'Type',
                                    widget.facility.facilityType == 'hospital' ? Icons.local_hospital : Icons.medical_services,
                                    widget.facility.hospitalType ?? 'Not specified',
                                    Colors.teal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Services Section
                          if (widget.facility.services != null && widget.facility.services!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Services',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: widget.facility.services!.map((service) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withAlpha(25),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          service,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Additional Information
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'About this facility',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This ${widget.facility.facilityType} facility provides comprehensive medical services '
                                  'with experienced healthcare professionals. We are committed to providing quality care '
                                  'to all patients in a comfortable and safe environment.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          offset: const Offset(0, -1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _makePhoneCall,
                            icon: const Icon(Icons.call, size: 18),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _getDirections,
                            icon: const Icon(Icons.directions, size: 18),
                            label: const Text('Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _bookAppointment,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Book'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, String value, Color color, {bool canCopy = false}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: canCopy ? () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$title copied to clipboard'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (canCopy)
                      Icon(
                        Icons.copy,
                        size: 16,
                        color: color,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall() async {
    if (widget.facility.phoneNumber.isEmpty) return;
    
    // Normalize phone number format (remove spaces, etc.)
    String phone = widget.facility.phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone dialer for $phone'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getDirections() async {
    Navigator.of(context).pop(); // Close the facility detail dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPage(initialFacility: widget.facility),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final auth = AuthService.instance;
    if (!auth.isAuthenticated()) {
      final choice = await AuthPopups.showAuthChoicePopup(context);
      if (choice == 'login') {
        await AuthPopups.showLoginPopupWithNavigation(
          context,
          onLoginSuccess: () async {
            if (mounted) {
              await _toggleFavorite();
            }
          },
        );
      } else if (choice == 'register') {
        await AuthPopups.showRegisterPopupWithNavigation(
          context,
          onRegisterSuccess: () async {
            if (mounted) {
              await _toggleFavorite();
            }
          },
        );
      }
      return;
    }

    if (widget.facility.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save this facility.')),      
      );
      return;
    }

    setState(() {
      _isSavingFavorite = true;
    });

    try {
      final response = _isFavorite
          ? await FavoritesApi.removeFavorite(
              auth.userEmail!,
              widget.facility.id!,
              token: auth.token,
            )
          : await FavoritesApi.addFavorite(
              auth.userEmail!,
              widget.facility.id!,
              token: auth.token,
            );

      if (response['success'] == true) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite
                ? 'Saved to favorites'
                : 'Removed from favorites'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Favorite request failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favorite request failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingFavorite = false;
        });
      }
    }
  }

  void _bookAppointment() {
    showDialog(
      context: context,
      builder: (context) => BookingFormDialog(facility: widget.facility),
    );
  }
}

class BookingFormDialog extends StatefulWidget {
  final FacilityItem facility;

  const BookingFormDialog({
    super.key,
    required this.facility,
  });

  @override
  State<BookingFormDialog> createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends State<BookingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  
  String _selectedPurpose = 'General Consultation';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  
  bool _isLoading = false;
  String? _paymentMethod; // 'telebirr', 'chapa', 'cbe_birr'
  
  @override
  void initState() {
    super.initState();
    final auth = AuthService.instance;
    _nameController = TextEditingController(text: auth.isLoggedIn ? auth.userName : '');
    
    String initialPhone = '';
    if (auth.isLoggedIn && auth.userPhone != null) {
      String rawPhone = auth.userPhone!;
      rawPhone = rawPhone.replaceAll(RegExp(r'\D'), '');
      if (rawPhone.startsWith('251')) {
        rawPhone = rawPhone.substring(3);
      }
      if (rawPhone.startsWith('0')) {
        rawPhone = rawPhone.substring(1);
      }
      if (rawPhone.length == 9 && (rawPhone.startsWith('7') || rawPhone.startsWith('9'))) {
        initialPhone = rawPhone;
      } else if (rawPhone.length >= 9) {
        String tail = rawPhone.substring(rawPhone.length - 9);
        if (tail.startsWith('7') || tail.startsWith('9')) {
          initialPhone = tail;
        }
      }
    }
    
    _phoneController = TextEditingController(text: initialPhone);
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitBooking({required bool withPayment}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final auth = AuthService.instance;
    final finalPaymentMethod = withPayment ? 'Chapa' : null;
    final bookingData = {
      'facilityId': widget.facility.id,
      'facilityName': widget.facility.name,
      'facilityType': widget.facility.facilityType,
      'patientName': _nameController.text.trim(),
      'patientAge': int.tryParse(_ageController.text.trim()) ?? 0,
      'patientPhone': '+251${_phoneController.text.trim()}',
      'userEmail': auth.isLoggedIn ? auth.userEmail : null,
      'purpose': _selectedPurpose,
      'appointmentDate': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      'appointmentTime': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      'status': 'confirmed',
      'paymentStatus': withPayment ? 'paid' : 'unpaid',
      'paymentMethod': finalPaymentMethod,
      'amount': 250.0,
    };

    try {
      final response = await BookingApi.createBooking(bookingData, token: auth.token);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response['success'] == true) {
          Navigator.pop(context); // Close booking form dialog
          final String? checkoutUrl = response['checkoutUrl'];
          _showSuccessDialog(withPayment, checkoutUrl: checkoutUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to submit booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(bool wasPaid, {String? checkoutUrl}) {
    final randomRef = 'BK-${(1000 + (DateTime.now().millisecond * 9) % 8999)}';
    
    if (checkoutUrl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final Uri uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
      });
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                wasPaid ? (checkoutUrl != null ? 'Secure Payment Redirecting...' : 'Booking & Payment Successful!') : 'Appointment Confirmed!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                checkoutUrl != null
                    ? 'Your booking is pending payment. We are redirecting you to Chapa payment portal to complete checkout securely.'
                    : 'Your appointment has been successfully scheduled at ${widget.facility.name}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.red[800], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This booking is valid for 24 hours only.',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Column(
                  children: [
                    _ReceiptRow(label: 'Reference Code', value: randomRef),
                    const Divider(height: 16),
                    _ReceiptRow(label: 'Patient Name', value: _nameController.text),
                    const Divider(height: 16),
                    _ReceiptRow(
                      label: 'Date & Time',
                      value: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} at ${_selectedTime.format(context)}',
                    ),
                    if (wasPaid) ...[
                      const Divider(height: 16),
                      _ReceiptRow(
                        label: 'Paid Via',
                        value: (checkoutUrl != null ? 'CHAPA' : (_paymentMethod ?? 'CHAPA')).toUpperCase(),
                      ),
                      const Divider(height: 16),
                      const _ReceiptRow(label: 'Amount Paid', value: '250.00 ETB', isBold: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (checkoutUrl != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri uri = Uri.parse(checkoutUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.inAppWebView);
                      }
                    },
                    icon: const Icon(Icons.payment_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Proceed to Secure Payment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Scheduling appointment...',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.facility.name,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // Full Name Input
                const Text(
                  'Full Name',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter patient full name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    // Age Input
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Age',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              hintText: 'e.g. 24',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Age is required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Phone Number Input
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phone Number',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                            decoration: InputDecoration(
                              prefixText: '+251 ',
                              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              hintText: '912345678',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (value.length != 9) {
                                return 'Must be exactly 9 digits';
                              }
                              if (!value.startsWith('7') && !value.startsWith('9')) {
                                return 'Must start with 7 or 9';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Purpose of Visit Dropdown
                const Text(
                  'Purpose of Visit',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedPurpose,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    'General Consultation',
                    'Cardiology Clinic',
                    'Dental Checkup',
                    'Prescription Refill',
                    'Dermatology',
                    'Pediatrics Clinic',
                    'Emergency Service'
                  ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) {
                    if (val != null) _selectedPurpose = val;
                  },
                ),
                const SizedBox(height: 16),
                
                // Date & Time pickers
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Time',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const Icon(Icons.access_time, size: 16, color: Colors.blue),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                const SizedBox(height: 24),
                
                // Booking Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _submitBooking(withPayment: false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue[600]!),
                          foregroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _submitBooking(withPayment: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Book and Pay',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const _PaymentMethodCard({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : Colors.grey[300]!,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : Colors.grey[600], size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? color : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
            color: isBold ? Colors.black : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

// Helper function to show facility detail popup
Future<void> showFacilityDetail(BuildContext context, FacilityItem facility) async {
  await showDialog(
    context: context,
    builder: (context) => DetailFacility(facility: facility),
  );
}