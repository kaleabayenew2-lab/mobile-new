import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({super.key});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  // Profile data
  String _agentId = '';
  String _agentName = '';
  String _agentEmail = '';
  String _agentUsername = '';
  String _agentPhone = '';
  String _agentType = '';
  String _agentAddress = '';
  String _agentOpeningHours = '';
  String _agentOwnership = '';
  bool _agentIsEmergency = false;
  String _agentLatitude = '';
  String _agentLongitude = '';
  String _agentNotes = '';
  List<String> _agentServices = [];
  String _profileImageUrl = '';
  List<String> _galleryImages = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      // Load actual profile data from API
      final authService = AuthService();
      final profile = await authService.getAgentProfile();
      if (profile != null) {
        setState(() {
          _agentId = profile['id'] ?? '';
          _agentName = profile['name'] ?? '';
          _agentEmail = profile['email'] ?? '';
          _agentUsername = profile['username'] ?? '';
          _agentPhone = profile['phone'] ?? '';
          _agentType = profile['type'] ?? '';
          _agentAddress = profile['address'] ?? '';
          _agentOpeningHours = profile['openingHours'] ?? '';
          _agentOwnership = profile['ownership'] ?? '';
          _agentIsEmergency = profile['isEmergency'] ?? false;
          _agentLatitude = profile['latitude']?.toString() ?? '';
          _agentLongitude = profile['longitude']?.toString() ?? '';
          _agentNotes = profile['notes'] ?? '';
          _agentServices = List<String>.from(profile['services'] ?? []);
          _profileImageUrl = profile['profileImage'] ?? '';
          _galleryImages = List<String>.from(profile['galleryImages'] ?? []);
        });
      } else {
        // Load sample data if no profile exists
        _loadSampleData();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _loadSampleData();
    }
  }

  void _loadSampleData() {
    setState(() {
      _agentId = 'AGT001';
      _agentName = 'City General Hospital';
      _agentEmail = 'contact@citygeneral.com';
      _agentUsername = 'citygeneral';
      _agentPhone = '+1-555-0123';
      _agentType = 'Hospital';
      _agentAddress = '123 Medical Center Dr, City, State 12345';
      _agentOpeningHours = 'Mon-Fri: 8AM-8PM, Sat-Sun: 9AM-5PM';
      _agentOwnership = 'Private';
      _agentIsEmergency = true;
      _agentLatitude = '40.7128';
      _agentLongitude = '-74.0060';
      _agentNotes = 'Full-service hospital with 24/7 emergency care';
      _agentServices = ['Emergency Care', 'Surgery', 'ICU', 'Pharmacy'];
      _profileImageUrl = '';
      _galleryImages = [
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/150',
      ];
    });
  }

  void _editProfile() {
    // TODO: Navigate to edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile functionality not implemented yet')),
    );
  }

  void _changePassword() {
    // Navigate to change password page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password functionality not implemented yet')),
    );
  }

  void _changeUsername() {
    // Navigate to change username page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change username functionality not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : null,
                        child: _profileImageUrl.isEmpty
                          ? const Icon(Icons.business, size: 40, color: Colors.blue)
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            onPressed: () {
                              // Implement profile image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile image picker not implemented yet')),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _agentName.isNotEmpty ? _agentName : 'Agent Name',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _agentEmail.isNotEmpty ? _agentEmail : 'agent@example.com',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Agent ID: $_agentId',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Gallery Section
            const Text(
              'Gallery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _galleryImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _galleryImages.length) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_photo_alternate, color: Colors.grey),
                        onPressed: () {
                          // Implement gallery image picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gallery image picker not implemented yet')),
                          );
                        },
                      ),
                    );
                  }

                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(_galleryImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Agent Details
            const Text(
              'Facility Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildProfileDetailRow('Facility Type', _agentType.isNotEmpty ? _agentType : 'Not set'),
            _buildProfileDetailRow('Username', _agentUsername.isNotEmpty ? _agentUsername : 'Not set'),
            _buildProfileDetailRow('Phone', _agentPhone.isNotEmpty ? _agentPhone : 'Not set'),
            _buildProfileDetailRow('Address', _agentAddress.isNotEmpty ? _agentAddress : 'Not set'),
            _buildProfileDetailRow('Opening Hours', _agentOpeningHours.isNotEmpty ? _agentOpeningHours : 'Not set'),
            _buildProfileDetailRow('Ownership', _agentOwnership.isNotEmpty ? _agentOwnership : 'Not set'),
            _buildProfileDetailRow('Emergency Agent', _agentIsEmergency ? 'Yes' : 'No'),

            if (_agentLatitude.isNotEmpty && _agentLongitude.isNotEmpty)
              _buildProfileDetailRow('Coordinates', '$_agentLatitude, $_agentLongitude'),

            if (_agentNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Notes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_agentNotes),
              ),
            ],

            if (_agentServices.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Services',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _agentServices.map((service) {
                  return Chip(
                    label: Text(service),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            const Text(
              'Account Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _changePassword,
                    icon: const Icon(Icons.lock),
                    label: const Text('Change Password'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _changeUsername,
                    icon: const Icon(Icons.account_circle),
                    label: const Text('Change Username'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
