// lib/pages/agent/agent_register.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../components/error_boundary.dart';
import 'register/image.dart';
import 'register/facility-detail-register.dart';
import 'register/account-detail.dart';
import 'register/location.dart';

class AgentRegisterPage extends StatefulWidget {
  const AgentRegisterPage({
    super.key,
    required this.onLoginSuccess,
    required this.onSwitchToLogin,
    this.useScaffold = true,
  });

  final VoidCallback onSwitchToLogin;
  final Function(String name, String type) onLoginSuccess;
  final bool useScaffold;

  @override
  State<AgentRegisterPage> createState() => _AgentRegisterPageState();
}

class _AgentRegisterPageState extends State<AgentRegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  late TabController _tabController;

  // Form data
  String _selectedFacilityType = 'Hospital';
  bool _isLoading = false;
  
  // Image data
  File? _profileImage;
  List<File> _galleryImages = [];
  int? _selectedImageIndex;
  
  // Facility detail data
  Map<String, dynamic> _facilityDetails = {};
  
  // Account detail data
  Map<String, String> _accountDetails = {};
  
  // Location data
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedFacilityType = _tabController.index == 0 ? 'Hospital' : 'Pharmacy';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Callback methods for child components
  void _onProfileImageChanged(File? image) {
    setState(() {
      _profileImage = image;
    });
  }

  void _onGalleryImagesChanged(List<File> images) {
    setState(() {
      _galleryImages = images;
    });
  }

  void _onSelectedImageIndexChanged(int? index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  void _onFacilityDetailsChanged(Map<String, dynamic> details) {
    setState(() {
      _facilityDetails = details;
    });
  }

  void _onAccountDetailsChanged(Map<String, String> details) {
    setState(() {
      _accountDetails = details;
    });
  }

  void _onLocationChanged(double? latitude, double? longitude) {
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });
  }

  // Validate all sections
  bool _validateAllSections() {
    // Facility detail section validation
    if (_facilityDetails['name'] == null || _facilityDetails['name'].toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in facility name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    if (_facilityDetails['address'] == null || _facilityDetails['address'].toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in address'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    if (_facilityDetails['phone'] == null || _facilityDetails['phone'].toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    // Account detail section validation
    if (_accountDetails['username'] == null || _accountDetails['username']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in username'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    if (_accountDetails['password'] == null || _accountDetails['password']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in password'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    if (_accountDetails['email'] == null || _accountDetails['email']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in email'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    // Location validation
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in location coordinates'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    return true;
  }

  Future<void> _registerAgent() async {
    if (!_validateAllSections()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final agentData = {
        'name': _facilityDetails['name'],
        'facility_type': _selectedFacilityType,
        'facility_sub_type': _facilityDetails['facility_sub_type'],
        'ownership': _facilityDetails['ownership'],
        'address': _facilityDetails['address'],
        'phone': _facilityDetails['phone'],
        'note': _facilityDetails['note'] ?? '',
        'emergency_enabled': _facilityDetails['emergency_enabled'] ?? false,
        'is_24_hours': _facilityDetails['is_24_hours'] ?? false,
        'opening_time': _facilityDetails['opening_time'],
        'closing_time': _facilityDetails['closing_time'],
        'opening_hours': _facilityDetails['opening_hours'],
        'services': _facilityDetails['services'] ?? [],
        'username': _accountDetails['username'],
        'password': _accountDetails['password'],
        'email': _accountDetails['email'],
        'latitude': _latitude,
        'longitude': _longitude,
        'profile_image': _profileImage?.path,
        'gallery_images': _galleryImages.map((file) => file.path).toList(),
      };

      final result = await _authService.registerAgent(agentData);
      
      if (mounted) {
        if (result['success'] == true) {
          widget.onLoginSuccess(
            result['data']['name'],
            result['data']['facility_type'],
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Text(
                      'Agent Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Tab bar
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue[600],
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue[600],
                      tabs: const [
                        Tab(text: 'Hospital'),
                        Tab(text: 'Pharmacy'),
                      ],
                    ),
                  ),
                  
                  // Form content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registration Form',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          
                          // Image Section
                          ImageSection(
                            onProfileImageChanged: _onProfileImageChanged,
                            onGalleryImagesChanged: _onGalleryImagesChanged,
                            onSelectedImageIndexChanged: _onSelectedImageIndexChanged,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Facility Detail Section
                          FacilityDetailRegisterSection(
                            facilityType: _selectedFacilityType,
                            onFacilityDetailsChanged: _onFacilityDetailsChanged,
                            onValidate: () {},
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Location Section
                          LocationSection(
                            onLocationChanged: _onLocationChanged,
                            onValidate: () {},
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Account Detail Section
                          AccountDetailSection(
                            onAccountDetailsChanged: _onAccountDetailsChanged,
                            onValidate: () {},
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _registerAgent,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Register Agent', 
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?', style: TextStyle(fontSize: 14)),
                              TextButton(
                                onPressed: widget.onSwitchToLogin,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.useScaffold) {
      return ErrorBoundary(
        enableLogging: true,
        fallbackMessage: 'Agent registration form encountered an error',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Agent Register'),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          body: content,
        ),
      );
    } else {
      return ErrorBoundary(
        enableLogging: true,
        fallbackMessage: 'Agent registration form encountered an error',
        child: content,
      );
    }
  }
}