import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api/profile/profile_api.dart';
import '../../services/auth_service.dart';
import '../../components/auth_popups.dart';
import '../../components/main_layout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ProfileApi.getCurrentUserProfile();
      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _profileData = result['data'];
            _isLoading = false;
          });
          _populateForm();
        } else {
          setState(() {
            _isLoading = false;
          });
          _showError(result['message'] ?? 'Failed to load profile');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Network error: $e');
      }
    }
  }

  void _populateForm() {
    if (_profileData == null) return;

    _fullNameController.text = _profileData!['fullName'] ?? '';
    String phone = _profileData!['phone']?.toString() ?? '';
    // Remove +251 if present
    if (phone.startsWith('+251')) {
      phone = phone.substring(4);
    }
    _phoneController.text = phone;
    _ageController.text = _profileData!['age']?.toString() ?? '';
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _clearForm();
      } else {
        _populateForm();
        _passwordController.clear();
      }
    });
  }

  void _clearForm() {
    _fullNameController.clear();
    _phoneController.clear();
    _ageController.clear();
    _passwordController.clear();
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current Password
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New Password
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (currentPasswordController.text.isEmpty ||
                                      newPasswordController.text.isEmpty ||
                                      confirmPasswordController.text.isEmpty) {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (newPasswordController.text != confirmPasswordController.text) {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      const SnackBar(
                                        content: Text('New passwords do not match'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (newPasswordController.text.length < 6) {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password must be at least 6 characters'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    // Call API to change password
                                    final result = await ProfileApi.changePassword(
                                      currentPassword: currentPasswordController.text,
                                      newPassword: newPasswordController.text,
                                    );

                                    if (result['success'] == true) {
                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                                          const SnackBar(
                                            content: Text('Password updated successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                                          SnackBar(
                                            content: Text(result['message'] ?? 'Failed to update password'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (dialogContext.mounted) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Update Password'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await ProfileApi.updateProfile(
          id: _profileData!['id'].toString(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
          password: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : null,
        );

        if (mounted) {
          if (result['success'] == true) {
            // Update local auth service data
            final updatedData = result['data'];
            final authService = AuthService();
            authService.updateUserData(updatedData);

            setState(() {
              _profileData = updatedData;
              _isEditing = false;
              _isLoading = false;
            });

            _showSuccess('Profile updated successfully!');
          } else {
            setState(() {
              _isLoading = false;
            });
            _showError(result['message'] ?? 'Failed to update profile');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showError('Network error: $e');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;
    
    return MainLayout(
      title: _isEditing ? 'Edit Profile' : 'My Profile',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action buttons row (replacing appBar actions)
                      if (isLoggedIn && !_isEditing) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _toggleEditMode,
                              tooltip: 'Edit Profile',
                            ),
                            IconButton(
                              icon: const Icon(Icons.lock),
                              onPressed: _showChangePasswordDialog,
                              tooltip: 'Change Password',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_isEditing) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: _toggleEditMode,
                              tooltip: 'Cancel Edit',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Profile Display (when not editing)
                      if (!_isEditing && _profileData != null) ...[
                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Profile Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildProfileInfo('Full Name', _profileData!['fullName'] ?? 'N/A'),
                                _buildProfileInfo('Email', _profileData!['email'] ?? 'N/A'),
                                _buildProfileInfo('Phone', _profileData!['phone'] ?? 'N/A'),
                                _buildProfileInfo('Age', _profileData!['age']?.toString() ?? 'N/A'),
                                if (_profileData!['telegramUsername'] != null)
                                  _buildProfileInfo('Telegram Username', _profileData!['telegramUsername'].toString()),
                                if (_profileData!['telegramPhone'] != null)
                                  _buildProfileInfo('Telegram Phone', _profileData!['telegramPhone'].toString()),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Navigate to Profile Add Page for facility management
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/profile-add');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Saved Facilities',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),

                      // Login/Register buttons (when not logged in)
                      if (!isLoggedIn) ...[
                        const SizedBox(height: 40),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Text(
                                  'Please Login or Register',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'You need to be logged in to view your profile',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          AuthPopups.showLoginPopupWithNavigation(
                                            context,
                                            onLoginSuccess: () {
                                              if (mounted) {
                                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                              }
                                            },
                                            onPopupClosed: () {
                                              if (mounted) {
                                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                              }
                                            },
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          side: const BorderSide(color: Colors.blue),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          AuthPopups.showRegisterPopupWithNavigation(
                                            context,
                                            onRegisterSuccess: () {
                                              if (mounted) {
                                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                              }
                                            },
                                            onPopupClosed: () {
                                              if (mounted) {
                                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                              }
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Register',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Edit Form (when editing)
                      if (_isEditing) ...[
                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Full Name
                                TextFormField(
                                  controller: _fullNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    if (value.length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }
                                    if (value.length > 50) {
                                      return 'Name must not exceed 50 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 80,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: const Text(
                                        '+251',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number',
                                          prefixIcon: Icon(Icons.phone),
                                          border: OutlineInputBorder(),
                                          helperText: 'Enter 9 digits (starts with 9 or 7)',
                                        ),
                                        validator: (value) {
                                          if (value != null && value.isNotEmpty) {
                                            if (value.length != 9) {
                                              return 'Phone number must be exactly 9 digits';
                                            }
                                            if (!value.startsWith('9') && !value.startsWith('7')) {
                                              return 'Phone number must start with 9 or 7';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Age
                                TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Age',
                                    prefixIcon: Icon(Icons.cake),
                                    border: OutlineInputBorder(),
                                    helperText: 'Between 10-100 years',
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final age = int.tryParse(value);
                                      if (age == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (age < 10 || age > 100) {
                                        return 'Please enter a valid age (10-100)';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password (optional)
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password (leave empty to keep current)',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: const OutlineInputBorder(),
                                    helperText: 'Enter new password to change',
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _toggleEditMode,
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.grey),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _updateProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: const Text('Update Profile'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}