import 'package:flutter/material.dart';
import '../../services/api/profile/profileadd_api.dart';
import '../../services/auth_service.dart';

class ProfileAddPage extends StatefulWidget {
  const ProfileAddPage({super.key});

  @override
  State<ProfileAddPage> createState() => _ProfileAddPageState();
}

class _ProfileAddPageState extends State<ProfileAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _facilityNameController = TextEditingController();
  final _facilityAddressController = TextEditingController();
  final _facilityPhoneController = TextEditingController();
  final _facilityTypeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  Map<String, dynamic>? _savedFacilities;

  @override
  void initState() {
    super.initState();
    _loadSavedFacilities();
  }

  // Mock data for saved facilities (moved from profile.dart)
  List<Map<String, dynamic>> get mockSavedFacilities => [
    {
      'id': '1',
      'name': 'Black Lion Hospital',
      'address': 'Bole, Addis Ababa, Ethiopia',
      'phone': '+251911234567',
      'type': 'Hospital',
      'rating': 4.5,
      'savedDate': '2024-01-15',
    },
    {
      'id': '2',
      'name': 'St. Paulos Hospital',
      'address': 'Mekelle, Addis Ababa, Ethiopia',
      'phone': '+251912345678',
      'type': 'Hospital',
      'rating': 4.2,
      'savedDate': '2024-02-20',
    },
    {
      'id': '3',
      'name': 'Addis Ababa Medical Center',
      'address': 'Bole, Addis Ababa, Ethiopia',
      'phone': '+251911234567',
      'type': 'Medical Center',
      'rating': 4.8,
      'savedDate': '2024-03-10',
    },
  ];

  @override
  void dispose() {
    _facilityNameController.dispose();
    _facilityAddressController.dispose();
    _facilityPhoneController.dispose();
    _facilityTypeController.dispose();
    super.dispose();
  }

  void _loadSavedFacilities() async {
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      setState(() {
        _savedFacilities = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ProfileAddApi.getSavedFacilities(authService.currentUser!['id'].toString());
      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _savedFacilities = List<Map<String, dynamic>>.from(result['data'] ?? []);
            _isLoading = false;
          });
        } else {
          setState(() {
            _savedFacilities = [];
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to load facilities'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _savedFacilities = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading facilities: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _clearForm();
      }
    });
  }

  void _clearForm() {
    _facilityNameController.clear();
    _facilityAddressController.clear();
    _facilityPhoneController.clear();
    _facilityTypeController.dispose();
  }

  void _saveFacility() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = AuthService();
        final facilityData = {
          'name': _facilityNameController.text.trim(),
          'address': _facilityAddressController.text.trim(),
          'phone': '+251${_facilityPhoneController.text.trim()}',
          'type': _facilityTypeController.text.trim(),
        };

        final result = await ProfileAddApi.saveFacility(
          facilityData: facilityData,
          userId: authService.currentUser!['id'].toString(),
        );

        if (mounted) {
          if (result['success'] == true) {
            setState(() {
              _isLoading = false;
              _isEditing = false;
              _savedFacilities!.add(result['data']);
              _clearForm();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Facility saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to save facility'),
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
              content: Text('Error saving facility: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showFacilityDetails(Map<String, dynamic> facility) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(facility['name'] ?? 'Facility Details'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${facility['address'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Phone: ${facility['phone'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Type: ${facility['type'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Saved: ${facility['savedDate'] ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Facilities'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _toggleEditMode,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isLoggedIn
              ? Column(
                  children: [
                    // Saved Facilities List
                    Expanded(
                      child: _savedFacilities!.isEmpty
                          ? const Center(
                              child: Text(
                                'No saved facilities yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _savedFacilities!.length,
                              itemBuilder: (context, index) {
                                final facility = _savedFacilities![index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      facility['name'] ?? 'Unknown Facility',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${facility['address'] ?? 'No address'} • ${facility['type'] ?? 'No type'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '⭐ ${facility['rating'] ?? '0.0'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.info),
                                          onPressed: () => _showFacilityDetails(facility),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      // Navigate to facility details or edit
                                    },
                                  ),
                                );
                              },
                            ),
                    ),

                    // Add Facility Form (when editing)
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
                                'Add New Facility',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Facility Name
                              TextFormField(
                                controller: _facilityNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Facility Name',
                                  prefixIcon: Icon(Icons.local_hospital),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Facility Address
                              TextFormField(
                                controller: _facilityAddressController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  prefixIcon: Icon(Icons.location_on),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Facility Phone
                              TextFormField(
                                controller: _facilityPhoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixText: '+251 ',
                                  prefixIcon: Icon(Icons.phone),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Facility Type
                              TextFormField(
                                controller: _facilityTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'Facility Type',
                                  prefixIcon: Icon(Icons.category),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _toggleEditMode,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: const BorderSide(color: Colors.grey),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _saveFacility,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Save Facility'),
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
                )
              : const Center(
                  child: Text(
                    'Please login to view saved facilities',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
    );
  }
}
