import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../components/auth_popups.dart';

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({super.key});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  late final AuthService _authService;
  List<dynamic> _favoritedUsers = [];
  bool _isLoadingFavorites = false;
  bool _isDetectingLocation = false;

  Future<void> _detectLocation(
      TextEditingController latController,
      TextEditingController lngController,
      Function(void Function()) setDialogState) async {
    setDialogState(() {
      _isDetectingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled. Please enable them in settings.'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied'), backgroundColor: Colors.red),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in settings.'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      latController.text = position.latitude.toStringAsFixed(6);
      lngController.text = position.longitude.toStringAsFixed(6);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current GPS location detected successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to detect location: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setDialogState(() {
        _isDetectingLocation = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _authService = AuthService.instance;
    _authService.addListener(_onAuthChanged);
    _fetchFavoritedUsers();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {
        _fetchFavoritedUsers();
      });
    }
  }

  Future<void> _fetchFavoritedUsers() async {
    final id = _profile['id']?.toString() ?? _profile['agentId']?.toString();
    if (id == null || id.isEmpty) return;

    setState(() {
      _isLoadingFavorites = true;
    });

    try {
      final response = await ApiService.get('/facility-status/facility/$id');
      if (response != null && response['success'] == true) {
        setState(() {
          _favoritedUsers = response['statuses'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching favorited users: $e');
    } finally {
      setState(() {
        _isLoadingFavorites = false;
      });
    }
  }

  /// Reads the already-logged-in facility data from the singleton AuthService.
  /// No extra API call is needed — the data was decrypted and stored at login.
  Map<String, dynamic> get _profile => _authService.currentUser ?? {};

  String get _agentId        => _profile['agentId']?.toString() ?? _profile['id']?.toString() ?? '';
  String get _agentName      => _profile['name'] ?? _profile['fullName'] ?? '';
  String get _agentEmail     => _profile['email'] ?? '';
  String get _agentUsername  => _profile['username'] ?? '';
  String get _agentPhone     => _profile['phone'] ?? '';
  String get _agentType      => _profile['type'] ?? '';
  String get _agentAddress   => _profile['address'] ?? '';
  String get _agentOpeningHours => _profile['openingHours'] ?? '';
  String get _agentOwnership => _profile['ownership'] ?? '';
  bool   get _agentIsEmergency => _profile['isEmergency'] == true;
  String get _agentLatitude  => _profile['latitude']?.toString() ?? '';
  String get _agentLongitude => _profile['longitude']?.toString() ?? '';
  String get _agentNotes     => _profile['notes'] ?? '';
  String get _profileImageUrl => _profile['profileImage'] ?? '';
  double get _averageRating  => (_profile['averageRating'] ?? 0.0).toDouble();
  int    get _ratingCount    => (_profile['ratingCount'] ?? 0) as int;
  int    get _viewsTotal     => (_profile['viewsTotal'] ?? 0) as int;
  int    get _favoriteCount  => (_profile['favoriteCount'] ?? 0) as int;

  List<String> get _agentServices {
    final raw = _profile['services'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  List<String> get _galleryImages {
    final raw = _profile['galleryImages'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  Color get _typeColor {
    switch (_agentType.toLowerCase()) {
      case 'hospital': return const Color(0xFF3B82F6);
      case 'pharmacy': return const Color(0xFF10B981);
      default:         return const Color(0xFF6B7280);
    }
  }

  void _changeCredentials() {
    final usernameController = TextEditingController(text: _agentUsername);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isObscureCurrent = true;
    bool isObscureNew = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.security_rounded, color: Colors.blue),
              SizedBox(width: 8),
              Text('Change Credentials', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Modify your agent username and update your account password security details.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.account_circle_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: isObscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(isObscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                        onPressed: () {
                          setDialogState(() {
                            isObscureCurrent = !isObscureCurrent;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: isObscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password (Optional)',
                      helperText: 'Leave blank to only change username',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(isObscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                        onPressed: () {
                          setDialogState(() {
                            isObscureNew = !isObscureNew;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close Change Credentials Dialog
                        AuthPopups.showResetPasswordPopup(context); // Open Reset Password Popup
                      },
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = usernameController.text.trim();
                final current = currentPasswordController.text;
                final newPass = newPasswordController.text;

                if (user.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username cannot be empty'), backgroundColor: Colors.red),
                  );
                  return;
                }

                if (current.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter current password to verify identity'), backgroundColor: Colors.red),
                  );
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                final result = await _authService.updateAgentCredentials(
                  username: user,
                  currentPassword: current,
                  newPassword: newPass.isNotEmpty ? newPass : null,
                );

                // Pop loading indicator
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }

                if (ctx.mounted) {
                  Navigator.of(ctx).pop(); // Pop change credentials dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Credentials updated'),
                      backgroundColor: result['success'] == true ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _agentName);
    final emailController = TextEditingController(text: _agentEmail);
    final phoneController = TextEditingController(text: _agentPhone);
    final addressController = TextEditingController(text: _agentAddress);
    final hoursController = TextEditingController(text: _agentOpeningHours);
    final notesController = TextEditingController(text: _agentNotes);
    final latController = TextEditingController(text: _agentLatitude);
    final lngController = TextEditingController(text: _agentLongitude);

    // Dynamic lists of sub-types
    final List<String> hospitalTypes = [
      'General Hospital',
      'Specialized Hospital',
      'Teaching Hospital',
      'District Hospital',
      'Primary Hospital',
      'Clinic',
      'Medical Center',
    ];

    final List<String> pharmacyTypes = [
      'Retail Pharmacy',
      'Hospital Pharmacy',
      'Clinical Pharmacy',
      'Compounding Pharmacy',
      'Online Pharmacy',
      'Wholesale Pharmacy',
      'Chain Pharmacy',
    ];

    // Services preset mapping
    final Map<String, List<String>> servicesPresetMap = {
      'General Hospital': [
        'Emergency Services',
        'Inpatient Care',
        'Outpatient Care',
        'Surgery',
        'Maternity Services',
        'Pediatrics',
        'Cardiology',
        'Radiology',
        'Laboratory Services',
        'Pharmacy',
        'Intensive Care Unit',
        'Ambulance Services',
      ],
      'Specialized Hospital': [
        'Specialized Consultations',
        'Advanced Surgery',
        'Specialized Diagnostics',
        'Rehabilitation',
        'Research Services',
        'Specialized ICU',
        'Organ Transplant',
        'Oncology Services',
      ],
      'Teaching Hospital': [
        'Medical Education',
        'Research Programs',
        'Specialized Clinics',
        'Emergency Care',
        'Residency Programs',
        'Clinical Trials',
        'Referral Services',
      ],
      'District Hospital': [
        'Primary Care',
        'Emergency Services',
        'Maternity Care',
        'Inpatient Services',
        'Diagnostic Services',
        'Preventive Care',
        'Community Health',
      ],
      'Primary Hospital': [
        'Basic Emergency Care',
        'General Medicine',
        'General Surgery',
        'Maternity Services',
        'Pediatric Care',
        'Laboratory Services',
      ],
      'Clinic': [
        'General Checkups',
        'Vaccinations',
        'Minor Procedures',
        'Health Screening',
        'Family Medicine',
        'Consultations',
      ],
      'Medical Center': [
        'Specialized Clinics',
        'Diagnostic Services',
        'Preventive Care',
        'Wellness Programs',
        'Physical Therapy',
        'Specialist Referrals',
      ],
      'Retail Pharmacy': [
        'Prescription Filling',
        'Over Counter Medicines',
        'Health Consultations',
        'Vaccination Services',
        'Health Screening',
        'Medicine Delivery',
        'Medical Devices',
      ],
      'Hospital Pharmacy': [
        'Inpatient Medications',
        'Outpatient Medications',
        'Clinical Pharmacy',
        'IV Admixture Services',
        'Medication Management',
        'Drug Information Services',
      ],
      'Clinical Pharmacy': [
        'Patient Counseling',
        'Medication Therapy Management',
        'Disease Management',
        'Drug Interaction Checks',
        'Clinical Consultations',
      ],
      'Compounding Pharmacy': [
        'Custom Medications',
        'Dosage Adjustments',
        'Allergen-Free Medications',
        'Flavor Additions',
        'Special Formulations',
      ],
      'Online Pharmacy': [
        'Online Prescriptions',
        'Home Delivery',
        'Virtual Consultations',
        'Medicine Reminders',
        'Health Records',
      ],
      'Wholesale Pharmacy': [
        'Bulk Medications',
        'Distribution Services',
        'Supply Chain Management',
        'Inventory Management',
        'Logistics Services',
      ],
      'Chain Pharmacy': [
        'Standard Prescriptions',
        'Health Screenings',
        'Immunizations',
        'Wellness Products',
        'Multiple Locations',
        'Loyalty Programs',
      ],
    };

    // State variables within StatefulBuilder context
    String ownershipValue = _agentOwnership.toLowerCase() == 'public' ? 'public' : 'private';
    String typeValue = _agentType.toLowerCase() == 'pharmacy' ? 'pharmacy' : (_agentType.toLowerCase() == 'clinic' ? 'clinic' : 'hospital');
    bool isEmergencyValue = _agentIsEmergency;

    // Determine initial sub-type selection
    String subTypeValue = 'General Hospital';
    if (typeValue == 'pharmacy') {
      subTypeValue = _profile['pharmacyType'] ?? 'Retail Pharmacy';
    } else {
      subTypeValue = _profile['hospitalType'] ?? 'General Hospital';
    }

    List<String> selectedServices = List<String>.from(_agentServices);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Adjust sub-type selections dynamically based on chosen type
          final List<String> currentSubTypeOptions = (typeValue == 'pharmacy') ? pharmacyTypes : hospitalTypes;
          if (!currentSubTypeOptions.contains(subTypeValue)) {
            subTypeValue = currentSubTypeOptions.first;
          }

          final List<String> presetServices = List<String>.from(servicesPresetMap[subTypeValue] ?? []);
          // Ensure any currently active service that might not be in the presets is still listed so the user can see and toggle it!
          for (final s in selectedServices) {
            if (!presetServices.contains(s)) {
              presetServices.add(s);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.edit_rounded, color: _typeColor),
                const SizedBox(width: 8),
                const Text('Edit Facility Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update your health facility information, location mapping, and operational services.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      // Prominent Current Facility Type and Emergency Indicator Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: typeValue == 'pharmacy' 
                              ? Colors.green.shade50 
                              : (typeValue == 'clinic' ? Colors.orange.shade50 : Colors.blue.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: typeValue == 'pharmacy' 
                                ? Colors.green.shade200 
                                : (typeValue == 'clinic' ? Colors.orange.shade200 : Colors.blue.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              typeValue == 'pharmacy' 
                                  ? Icons.local_pharmacy_rounded 
                                  : (typeValue == 'clinic' ? Icons.medical_services_rounded : Icons.local_hospital_rounded),
                              color: typeValue == 'pharmacy' 
                                  ? Colors.green.shade700 
                                  : (typeValue == 'clinic' ? Colors.orange.shade700 : Colors.blue.shade700),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CURRENT FACILITY CLASSIFICATION',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                      color: typeValue == 'pharmacy' 
                                          ? Colors.green.shade800 
                                          : (typeValue == 'clinic' ? Colors.orange.shade800 : Colors.blue.shade800),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    typeValue.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: typeValue == 'pharmacy' 
                                          ? Colors.green.shade900 
                                          : (typeValue == 'clinic' ? Colors.orange.shade900 : Colors.blue.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Emergency Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isEmergencyValue ? Colors.red.shade100 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isEmergencyValue ? 'EMERGENCY: ON' : 'EMERGENCY: OFF',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isEmergencyValue ? Colors.red.shade900 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Read-only ID Row
                      TextField(
                        controller: TextEditingController(text: _agentId),
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Agent ID (Read Only)',
                          prefixIcon: Icon(Icons.badge_rounded, color: Colors.grey),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Name & Email Row ──
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Facility Name',
                                prefixIcon: Icon(Icons.business_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Phone & Address Row ──
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                prefixIcon: Icon(Icons.location_on_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Latitude & Longitude Row ──
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: latController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                prefixIcon: Icon(Icons.pin_drop_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: lngController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                prefixIcon: Icon(Icons.pin_drop_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Detect Location Button
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: _isDetectingLocation
                              ? null
                              : () => _detectLocation(latController, lngController, setDialogState),
                          icon: _isDetectingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                                )
                              : const Icon(Icons.my_location_rounded, size: 16),
                          label: Text(
                            _isDetectingLocation ? 'Detecting GPS Coordinates...' : 'Detect Current Location',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _typeColor),
                            foregroundColor: _typeColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Facility Type & Ownership Row ──
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: typeValue,
                              decoration: const InputDecoration(
                                labelText: 'Facility Type',
                                prefixIcon: Icon(Icons.local_hospital_rounded),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'hospital', child: Text('Hospital')),
                                DropdownMenuItem(value: 'pharmacy', child: Text('Pharmacy')),
                                DropdownMenuItem(value: 'clinic', child: Text('Clinic')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    typeValue = val;
                                    subTypeValue = (val == 'pharmacy') ? 'Retail Pharmacy' : 'General Hospital';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: ownershipValue,
                              decoration: const InputDecoration(
                                labelText: 'Ownership',
                                prefixIcon: Icon(Icons.business_center_rounded),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'private', child: Text('Private')),
                                DropdownMenuItem(value: 'public', child: Text('Public')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    ownershipValue = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Sub-Type & Opening Hours Row ──
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: subTypeValue,
                              decoration: InputDecoration(
                                labelText: typeValue == 'pharmacy' ? 'Pharmacy Sub-Type' : 'Hospital Sub-Type',
                                prefixIcon: const Icon(Icons.category_rounded),
                              ),
                              items: currentSubTypeOptions.map((st) {
                                return DropdownMenuItem(value: st, child: Text(st));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    subTypeValue = val;
                                    // Pre-populate with typical services for this new subtype
                                    // if the list was completely empty or reset.
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: hoursController,
                              decoration: const InputDecoration(
                                labelText: 'Opening Hours',
                                prefixIcon: Icon(Icons.access_time_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Emergency Switch ──
                      SwitchListTile(
                        title: const Text('Emergency Services Available', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          isEmergencyValue ? 'EMERGENCY STATUS: ACTIVE (ON)' : 'EMERGENCY STATUS: INACTIVE (OFF)',
                          style: TextStyle(
                            color: isEmergencyValue ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: isEmergencyValue,
                        activeColor: Colors.red,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setDialogState(() {
                            isEmergencyValue = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Services Offered Checklist ──
                      Text(
                        'Services Offered under $subTypeValue',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      if (presetServices.isEmpty)
                        Text(
                          'No standard preset services available for this sub-type. You can write custom ones.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: presetServices.map((service) {
                            final isSelected = selectedServices.contains(service);
                            return FilterChip(
                              label: Text(
                                service,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: _typeColor,
                              checkmarkColor: Colors.white,
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                              ),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    selectedServices.add(service);
                                  } else {
                                    selectedServices.remove(service);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),

                      // Notes Section
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Facility Notes / Description',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  final result = await _authService.updateAgentProfile({
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'address': addressController.text.trim(),
                    'openingHours': hoursController.text.trim(),
                    'ownership': ownershipValue,
                    'type': typeValue,
                    'hospitalType': typeValue == 'pharmacy' ? null : subTypeValue,
                    'pharmacyType': typeValue == 'pharmacy' ? subTypeValue : null,
                    'isEmergency': isEmergencyValue,
                    'notes': notesController.text.trim(),
                    'latitude': double.tryParse(latController.text.trim()) ?? 0.0,
                    'longitude': double.tryParse(lngController.text.trim()) ?? 0.0,
                    'services': selectedServices,
                  });

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop(); // Pop loading dialog
                  }

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop(); // Pop edit profile dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Profile updated'),
                        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _typeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Save Profile'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFavoritesTable() {
    if (_isLoadingFavorites) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_favoritedUsers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: const Column(
          children: [
            Icon(Icons.favorite_border_rounded, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No Favorites Yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
            SizedBox(height: 4),
            Text(
              'When users add your facility to their favorites list, they will appear here.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Interactions & Favorites Board',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.blue),
                onPressed: _fetchFavoritedUsers,
                tooltip: 'Refresh Board',
              ),
            ],
          ),
          const Divider(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: 0,
              columns: const [
                DataColumn(label: Text('User Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Added On', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
              ],
              rows: _favoritedUsers.map<DataRow>((status) {
                final rawDate = status['createdAt'] != null ? DateTime.tryParse(status['createdAt'].toString()) : null;
                final formattedDate = rawDate != null
                    ? '${rawDate.year}-${rawDate.month.toString().padLeft(2, '0')}-${rawDate.day.toString().padLeft(2, '0')}'
                    : '—';

                return DataRow(
                  cells: [
                    DataCell(Text(status['fullName']?.toString() ?? '—', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                    DataCell(Text(status['email']?.toString() ?? '—', style: const TextStyle(color: Color(0xFF475569)))),
                    DataCell(Text(status['phone']?.toString() ?? '—', style: const TextStyle(color: Color(0xFF475569)))),
                    DataCell(Text(formattedDate, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _typeColor,
        foregroundColor: Colors.white,
        title: const Text('Facility Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: _showEditProfileDialog,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header banner ───────────────────────────────────────
            _buildHeader(),

            // ── Details ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(children: [
                    Expanded(child: _statCard('Rating',  _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '—', Icons.star_rounded, const Color(0xFFF59E0B))),
                    const SizedBox(width: 8),
                    Expanded(child: _statCard('Views',   _viewsTotal.toString(), Icons.visibility_rounded, const Color(0xFF3B82F6))),
                    const SizedBox(width: 8),
                    Expanded(child: _statCard('Favorites', _favoriteCount.toString(), Icons.favorite_rounded, const Color(0xFFEF4444))),
                  ]),
                  const SizedBox(height: 24),

                  // Contact details card
                  _sectionCard('Contact Information', [
                    _detailRow(Icons.email_rounded,  'Email',    _agentEmail.isNotEmpty    ? _agentEmail    : 'Not set'),
                    _detailRow(Icons.phone_rounded,  'Phone',    _agentPhone.isNotEmpty    ? _agentPhone    : 'Not set'),
                    _detailRow(Icons.location_on_rounded, 'Address', _agentAddress.isNotEmpty ? _agentAddress : 'Not set'),
                  ]),
                  const SizedBox(height: 16),

                  // Facility details card
                  _sectionCard('Facility Details', [
                    _detailRow(Icons.person_rounded,        'Username',     _agentUsername.isNotEmpty    ? '@$_agentUsername'  : 'Not set'),
                    _detailRow(Icons.badge_rounded,         'Agent ID',     _agentId.isNotEmpty          ? _agentId            : 'Not set'),
                    _detailRow(Icons.business_rounded,      'Type',         _agentType.isNotEmpty        ? _agentType.toUpperCase() : 'Not set'),
                    _detailRow(Icons.business_center_rounded, 'Ownership',  _agentOwnership.isNotEmpty   ? _agentOwnership.toUpperCase() : 'Not set'),
                    _detailRow(Icons.access_time_rounded,   'Opening Hours',_agentOpeningHours.isNotEmpty? _agentOpeningHours   : 'Not set'),
                    _detailRow(Icons.local_hospital_rounded,'Emergency',    _agentIsEmergency            ? 'Yes ✅'             : 'No'),
                    if (_agentLatitude.isNotEmpty && _agentLongitude.isNotEmpty)
                      _detailRow(Icons.map_rounded, 'Coordinates', '$_agentLatitude, $_agentLongitude'),
                    if (_agentNotes.isNotEmpty)
                      _detailRow(Icons.notes_rounded, 'Notes', _agentNotes),
                  ]),
                  const SizedBox(height: 16),

                  // Services
                  if (_agentServices.isNotEmpty) ...[
                    _buildSectionTitle('Services Offered'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _agentServices.map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12, color: Colors.white)),
                        backgroundColor: _typeColor,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Gallery
                  if (_galleryImages.isNotEmpty) ...[
                    _buildSectionTitle('Gallery'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _galleryImages.length,
                        itemBuilder: (ctx, i) => Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_galleryImages[i]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Favorites Board
                  _buildFavoritesTable(),
                  const SizedBox(height: 16),

                  // Account actions
                  _buildSectionTitle('Account Actions'),
                  const SizedBox(height: 12),
                   Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showEditProfileDialog,
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _typeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _changeCredentials,
                        icon: const Icon(Icons.security_rounded),
                        label: const Text('Change Credentials'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[800],
                          side: BorderSide(color: Colors.blue[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_typeColor, _typeColor.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withOpacity(0.25),
            backgroundImage: _profileImageUrl.isNotEmpty ? NetworkImage(_profileImageUrl) : null,
            child: _profileImageUrl.isEmpty
                ? Text(
                    _agentName.isNotEmpty ? _agentName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            _agentName.isNotEmpty ? _agentName : 'Facility',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Email (decrypted)
          if (_agentEmail.isNotEmpty)
            Text(
              _agentEmail,
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
            ),
          const SizedBox(height: 10),
          // Type badge + Emergency badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _badge(_agentType.toUpperCase(), Colors.white.withOpacity(0.25)),
              if (_agentIsEmergency) ...[
                const SizedBox(width: 8),
                _badge('EMERGENCY', Colors.red.withOpacity(0.8)),
              ],
            ],
          ),
          if (_agentId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Text(
                'Agent ID: $_agentId',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
  );

  // ── Section helpers ────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
  );

  Widget _sectionCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const Divider(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), textAlign: TextAlign.center),
      ]),
    );
  }
}