import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AgentResetPage extends StatefulWidget {
  const AgentResetPage({
    super.key,
    required this.onSwitchToLogin,
  });

  final VoidCallback onSwitchToLogin;

  @override
  State<AgentResetPage> createState() => _AgentResetPageState();
}

class _AgentResetPageState extends State<AgentResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService.instance;

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await _authService.sendPasswordResetOTP(_emailController.text.trim());

      if (result['success']) {
        setState(() => _otpSent = true);
        _startCooldown();
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Verification OTP code sent to your email'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to send OTP'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOTP() async {
    final otpText = _otpController.text.trim();
    if (otpText.isEmpty || otpText.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP code'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await _authService.verifyOTP(_emailController.text.trim(), otpText);

      if (result['success']) {
        setState(() => _otpVerified = true);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('OTP code verified successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Invalid or expired OTP'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await _authService.resetPassword(
        _emailController.text.trim(),
        _otpController.text.trim(),
        _newPasswordController.text,
      );

      if (result['success']) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Password updated successfully! Please login.'), backgroundColor: Colors.green),
          );
        }
        widget.onSwitchToLogin();
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Password reset failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepNode(1, 'Request', true),
        _buildStepDivider(_otpSent),
        _buildStepNode(2, 'Verify', _otpSent),
        _buildStepDivider(_otpVerified),
        _buildStepNode(3, 'Reset', _otpVerified),
      ],
    );
  }

  Widget _buildStepNode(int index, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.blue : Colors.grey.shade300,
            boxShadow: active
                ? [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
                : null,
          ),
          child: Center(
            child: active && index == 1 && _otpSent
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : active && index == 2 && _otpVerified
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$index',
                        style: TextStyle(
                          color: active ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? Colors.blue.shade700 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 2,
      color: active ? Colors.blue : Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Follow the simple steps to securely recover and reset your agent account credentials.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildStepIndicator(),
                  const SizedBox(height: 32),

                  // Email Input Field (Disabled once OTP is successfully sent)
                  TextFormField(
                    controller: _emailController,
                    enabled: !_otpSent,
                    style: TextStyle(color: _otpSent ? Colors.grey : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Registered Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: _otpSent,
                      fillColor: _otpSent ? Colors.grey.shade100 : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  // Send OTP Button (Only visible if OTP not sent yet)
                  if (!_otpSent) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Send Verification OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],

                  // OTP Verification Section (Only shown after OTP is sent but not verified)
                  if (_otpSent && !_otpVerified) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Enter the OTP verification code:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: 'Enter 6-Digit OTP',
                        prefixIcon: const Icon(Icons.security_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Verify Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: (_isLoading || _resendCooldown > 0) ? null : _sendOTP,
                          child: Text(
                            _resendCooldown > 0 ? 'Resend Code in ${_resendCooldown}s' : 'Resend OTP Code',
                            style: TextStyle(
                              color: _resendCooldown > 0 ? Colors.grey : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _otpSent = false;
                                    _otpController.clear();
                                  });
                                },
                          child: const Text(
                            'Change Email',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Reset New Password Section (Only shown after OTP is successfully verified!)
                  if (_otpVerified) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Set your new secure password:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _isObscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                          onPressed: () => setState(() => _isObscureNew = !_isObscureNew),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _isObscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                          onPressed: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm your password';
                        if (value != _newPasswordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Update & Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: widget.onSwitchToLogin,
                      child: const Text(
                        'Return to Login Screen',
                        style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),
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
  }
}