// lib/pages/agent/agent_register.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../../utils/validate-agent.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
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

  void _showValidationErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Validation Alert', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // Validate all sections using AgentValidator
  bool _validateAllSections() {
    print('📝 [Register] Validating forms...');
    print('💼 [Register] Facility Details: $_facilityDetails');
    print('👤 [Register] Account Details: $_accountDetails');
    print('📍 [Register] Coordinates: $_latitude, $_longitude');

    final nameErr = AgentValidator.validateName(_facilityDetails['name']?.toString());
    if (nameErr != null) {
      print('❌ [Register] Name Validation Failed: $nameErr');
      _showValidationErrorDialog(nameErr);
      return false;
    }

    final addrErr = AgentValidator.validateAddress(_facilityDetails['address']?.toString());
    if (addrErr != null) {
      print('❌ [Register] Address Validation Failed: $addrErr');
      _showValidationErrorDialog(addrErr);
      return false;
    }

    final phoneErr = AgentValidator.validatePhone(_facilityDetails['phone']?.toString());
    if (phoneErr != null) {
      print('❌ [Register] Phone Validation Failed: $phoneErr');
      _showValidationErrorDialog(phoneErr);
      return false;
    }

    final userErr = AgentValidator.validateUsername(_accountDetails['username']);
    if (userErr != null) {
      print('❌ [Register] Username Validation Failed: $userErr');
      _showValidationErrorDialog(userErr);
      return false;
    }

    final passErr = AgentValidator.validatePassword(_accountDetails['password']);
    if (passErr != null) {
      print('❌ [Register] Password Validation Failed: $passErr');
      _showValidationErrorDialog(passErr);
      return false;
    }

    final emailErr = AgentValidator.validateEmail(_accountDetails['email']);
    if (emailErr != null) {
      print('❌ [Register] Email Validation Failed: $emailErr');
      _showValidationErrorDialog(emailErr);
      return false;
    }

    final locErr = AgentValidator.validateCoordinates(_latitude, _longitude);
    if (locErr != null) {
      print('❌ [Register] Coordinates Validation Failed: $locErr');
      _showValidationErrorDialog(locErr);
      return false;
    }

    print('✅ [Register] Forms validation passed successfully!');
    return true;
  }

  Future<void> _sendRegistrationOTP() async {
    print('🚀 [Register] Send Registration OTP clicked!');
    if (!_validateAllSections()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _accountDetails['email']?.trim();
      final name = _facilityDetails['name']?.trim() ?? 'Facility';

      print('📧 [Register] Triggering OTP via API for email: $email, facility: $name');

      // 1. Send OTP via backend email service
      final sendResponse = await ApiService.post('/otp/send', {
        'identifier': email,
        'method': 'email',
        'facilityName': name,
      });

      print('📬 [Register] API Send Response: $sendResponse');

      if (sendResponse == null || sendResponse['success'] != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(sendResponse?['message'] ?? 'Failed to send verification OTP code'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 2. Open high-fidelity custom OTP Dialog popup
      if (mounted) {
        final verified = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => OtpVerificationDialog(
            email: email!,
            facilityName: name,
            onResend: () async {
              await ApiService.post('/otp/send', {
                'identifier': email,
                'method': 'email',
                'facilityName': name,
              });
            },
            onVerify: (code) async {
              final verifyResponse = await ApiService.post('/otp/verify', {
                'identifier': email,
                'code': code,
                'method': 'email',
              });
              return verifyResponse['success'] == true;
            },
          ),
        );

        if (verified == true) {
          // Successfully verified! Finalize registration
          await _registerAgentAfterOtpVerification();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration verification error: $e'),
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

  Future<void> _registerAgentAfterOtpVerification() async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Correctly registered the agent!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onLoginSuccess(
            result['data']['name'] ?? '',
            result['data']['facility_type'] ?? result['data']['type'] ?? 'Hospital',
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
                              onPressed: _isLoading ? null : _sendRegistrationOTP,
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
                                  : const Text('Send Registration OTP', 
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

class OtpVerificationDialog extends StatefulWidget {
  final String email;
  final String facilityName;
  final VoidCallback onResend;
  final Future<bool> Function(String code) onVerify;

  const OtpVerificationDialog({
    super.key,
    required this.email,
    required this.facilityName,
    required this.onResend,
    required this.onVerify,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _codeController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;
  int _attemptsCount = 0;
  final int _maxAttempts = 5;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _errorMessage = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    try {
      widget.onResend();
      _startTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP: $e';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      _attemptsCount++;
      if (_attemptsCount > _maxAttempts) {
        setState(() {
          _errorMessage = 'Maximum verification attempts exceeded. Please try resending the OTP.';
          _isVerifying = false;
        });
        return;
      }

      final success = await widget.onVerify(code);
      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid verification code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during verification: $e';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerText = _secondsRemaining > 0
        ? '0:${_secondsRemaining.toString().padLeft(2, '0')}'
        : 'Expired';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.mark_email_read_rounded, color: Colors.blue, size: 28),
          SizedBox(width: 10),
          Text(
            'Verify Your Email',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A verification code has been sent to:',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                labelText: '6-Digit OTP Code',
                labelStyle: const TextStyle(letterSpacing: 0, fontSize: 14),
                prefixIcon: const Icon(Icons.security_rounded, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: '',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timer: $timerText',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _secondsRemaining > 0 ? Colors.blue[800] : Colors.red,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Attempts: $_attemptsCount / $_maxAttempts',
                      style: TextStyle(
                        color: _attemptsCount >= _maxAttempts - 1 ? Colors.orange[800] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _secondsRemaining > 0 || _isResending ? null : _handleResend,
                  child: _isResending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Resend OTP'),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _handleVerify,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isVerifying
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Verify & Register', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}