// lib/pages/agent/account-detail.dart
import 'package:flutter/material.dart';
import '../../../utils/validate-agent.dart';

class AccountDetailSection extends StatefulWidget {
  final Function(Map<String, String>) onAccountDetailsChanged;
  final VoidCallback onValidate;

  const AccountDetailSection({
    super.key,
    required this.onAccountDetailsChanged,
    required this.onValidate,
  });

  @override
  State<AccountDetailSection> createState() => _AccountDetailSectionState();
}

class _AccountDetailSectionState extends State<AccountDetailSection> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_notifyParent);
    _passwordController.addListener(_notifyParent);
    _confirmPasswordController.addListener(_notifyParent);
    _emailController.addListener(_notifyParent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyParent();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onAccountDetailsChanged({
      'username': _usernameController.text,
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
      'email': _emailController.text,
    });
  }

  // Validation methods
  String? _validateUsername(String? value) => AgentValidator.validateUsername(value);

  String? _validatePassword(String? value) => AgentValidator.validatePassword(value);

  String? _validateConfirmPassword(String? value) =>
      AgentValidator.validateConfirmPassword(_passwordController.text, value);

  String? _validateEmail(String? value) => AgentValidator.validateEmail(value);

  // Form validation
  bool validateForm() {
    return _validateUsername(_usernameController.text) == null &&
           _validatePassword(_passwordController.text) == null &&
           _validateConfirmPassword(_confirmPasswordController.text) == null &&
           _validateEmail(_emailController.text) == null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Account Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Username Field
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Choose a unique username',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: _validateUsername,
            onChanged: (_) => _notifyParent(),
          ),
          const SizedBox(height: 16),
          
          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter password (min 6 characters)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: _validatePassword,
            onChanged: (_) => _notifyParent(),
          ),
          const SizedBox(height: 16),
          
          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: _validateConfirmPassword,
            onChanged: (_) => _notifyParent(),
          ),
          const SizedBox(height: 16),
          
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email address',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: _validateEmail,
            onChanged: (_) => _notifyParent(),
          ),
          
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Password must be at least 6 characters and contain both letters and numbers',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}