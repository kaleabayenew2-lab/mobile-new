import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MedicalProfilePage extends StatefulWidget {
  const MedicalProfilePage({super.key});

  @override
  State<MedicalProfilePage> createState() => _MedicalProfilePageState();
}

class _MedicalProfilePageState extends State<MedicalProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateForm();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _emergencyContactController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  void _populateForm() {
    // Mock data - in real app, this would come from API/database
    final mockData = {
      'fullName': 'John Doe',
      'email': 'john.doe@example.com',
      'phone': '+251912345678',
      'age': 35,
      'bloodType': 'O+',
      'allergies': 'Penicillin, Peanuts',
      'medications': 'Lisinopril',
      'emergencyContact': '+251911223344',
      'medicalHistory': 'Diabetes Type 2, Hypertension',
    };
    
    setState(() {
      _fullNameController.text = mockData['fullName']?.toString() ?? '';
      _emailController.text = mockData['email']?.toString() ?? '';
      _phoneController.text = mockData['phone']?.toString().replaceAll('+251', '') ?? '';
      _ageController.text = mockData['age']?.toString() ?? '';
      _bloodTypeController.text = mockData['bloodType']?.toString() ?? '';
      _allergiesController.text = mockData['allergies']?.toString() ?? '';
      _medicationsController.text = mockData['medications']?.toString() ?? '';
      _emergencyContactController.text = mockData['emergencyContact']?.toString().replaceAll('+251', '') ?? '';
      _medicalHistoryController.text = mockData['medicalHistory']?.toString() ?? '';
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _populateForm();
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical profile saved successfully!')),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text('Are you sure you want to delete your medical profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medical profile deleted successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting profile: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Profile'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isLoading ? null : (_isEditing ? _saveProfile : _toggleEditMode),
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    const Text(
                      'Personal Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                              prefixText: '+251 ',
                            ),
                            keyboardType: TextInputType.phone,
                            enabled: _isEditing,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length != 9) {
                                return 'Phone number must be 9 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.cake),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: _isEditing,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your age';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 0 || age > 150) {
                                return 'Please enter a valid age';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _bloodTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Blood Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.opacity),
                        hintText: 'e.g., O+, A-, B+, AB-',
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your blood type';
                        }
                        final validTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
                        if (!validTypes.contains(value.toUpperCase())) {
                          return 'Please enter a valid blood type (A+, A-, B+, B-, AB+, AB-, O+, O-)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Medical Information Section
                    const Text(
                      'Medical Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Allergies',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning),
                        hintText: 'List any known allergies',
                      ),
                      maxLines: 2,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _medicationsController,
                      decoration: const InputDecoration(
                        labelText: 'Current Medications',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                        hintText: 'List current medications',
                      ),
                      maxLines: 2,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Contact',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emergency),
                        prefixText: '+251 ',
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: _isEditing,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter emergency contact number';
                        }
                        if (value.length != 9) {
                          return 'Phone number must be 9 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _medicalHistoryController,
                      decoration: const InputDecoration(
                        labelText: 'Medical History',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.history),
                        hintText: 'List any medical conditions or surgeries',
                      ),
                      maxLines: 3,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 32),
                    
                    // Save Button (only visible when editing)
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Save Medical Profile'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
