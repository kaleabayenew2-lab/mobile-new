import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';
import '../../services/api/home/homeapi.dart';
import '../home/facility.dart';
import '../map/map.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _openNowOnly = false;
  List<Map<String, dynamic>> _allFacilities = [];
  List<Map<String, dynamic>> _filteredFacilities = [];
  bool _isLoading = true;
  String? _error;
  String _typeFilter = 'all'; // 'all', 'hospital', 'pharmacy'

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final facilities = await HomeApi.getFacilities();

      // Helper: check if isEmergency is truthy (handles true, 1, "1" from SQLite)
      bool isEmergency(Map<String, dynamic> f) {
        final val = f['isEmergency'];
        return val == true || val == 1 || val == '1';
      }

      setState(() {
        // Emergency-flagged facilities first, then all others
        final emergencyFacilities = facilities.where(isEmergency).toList();
        final otherFacilities = facilities.where((f) => !isEmergency(f)).toList();
        _allFacilities = [...emergencyFacilities, ...otherFacilities];
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredFacilities = _allFacilities.where((facility) {
        final name = (facility['name'] ?? '').toString().toLowerCase();
        final location = (facility['address'] ?? '').toString().toLowerCase();
        final type = (facility['type'] ?? '').toString().toLowerCase();
        final openingHours = (facility['openingHours'] ?? '').toString().toLowerCase();

        final matchesQuery = query.isEmpty ||
            name.contains(query) ||
            location.contains(query) ||
            type.contains(query);

        final matchesOpenNow = !_openNowOnly || openingHours.contains('24/7') || openingHours.contains('24 hours');
        final matchesType = _typeFilter == 'all' || type == _typeFilter;

        return matchesQuery && matchesOpenNow && matchesType;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFacilityDetails(BuildContext context, Map<String, dynamic> facility) {
    final openingHours = (facility['openingHours'] ?? '').toString();
    final isOpen247 = openingHours.toLowerCase().contains('24/7') || openingHours.toLowerCase().contains('24 hours');
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                    image: facility['profileImage'] != null && facility['profileImage'].toString().isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(facility['profileImage']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: facility['profileImage'] == null || facility['profileImage'].toString().isEmpty
                      ? Icon(
                          (facility['type'] ?? '').toString().toLowerCase() == 'hospital' ? Icons.local_hospital : Icons.medical_services,
                          color: Colors.red[600],
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility['name'] ?? 'Unknown Facility',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        facility['type'] ?? 'Facility',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen247 ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOpen247 ? 'Open 24/7' : 'Limited Hours',
                    style: TextStyle(
                      color: isOpen247 ? Colors.green[700] : Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _DetailRow(icon: Icons.location_on, text: facility['address']?.toString().isNotEmpty == true ? facility['address'] : 'No address provided'),
            _DetailRow(icon: Icons.phone, text: facility['phone']?.toString().isNotEmpty == true ? facility['phone'] : 'No phone provided'),
            _DetailRow(icon: Icons.access_time, text: openingHours.isNotEmpty ? openingHours : 'Hours not specified'),
            _DetailRow(icon: Icons.directions, text: '${facility['viewsTotal'] ?? 0} views'),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _callFacility(facility['phone']?.toString() ?? '');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Call Now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      
                      // Convert Map<String, dynamic> to FacilityItem
                      double lat = 0.0;
                      double lng = 0.0;
                      try {
                        if (facility['latitude'] != null) lat = double.parse(facility['latitude'].toString());
                        if (facility['longitude'] != null) lng = double.parse(facility['longitude'].toString());
                        
                        // Fallback to parsing location JSON if direct lat/lng missing
                        if (lat == 0.0 && lng == 0.0 && facility['location'] != null) {
                          final locData = json.decode(facility['location'].toString());
                          if (locData['coordinates'] != null) {
                            lng = double.parse(locData['coordinates'][0].toString());
                            lat = double.parse(locData['coordinates'][1].toString());
                          }
                        }
                      } catch (_) {}

                      final facilityItem = FacilityItem(
                        id: facility['id'] != null ? int.tryParse(facility['id'].toString()) : null,
                        name: facility['name'] ?? 'Unknown Facility',
                        location: facility['address'] ?? 'Unknown Address',
                        distance: '', // Calculate if needed, map page doesn't strictly require it
                        phoneNumber: facility['phone'] ?? '',
                        facilityType: facility['type'] ?? 'facility',
                        latitude: lat,
                        longitude: lng,
                        profileImage: facility['profileImage'],
                      );
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(initialFacility: facilityItem),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[400]!),
                    ),
                    child: Text(
                      'Get Directions',
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callFacility(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number not available')),
        );
      }
      return;
    }

    // Clean the phone number: remove spaces, dashes, +
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-+]'), '');

    // Remove leading 0 if present (Ethiopian numbers)
    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }

    // Ensure it starts with +251
    String dialNumber = cleanNumber.startsWith('251')
        ? '+$cleanNumber'
        : '+251$cleanNumber';

    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: dialNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot call $dialNumber')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error dialing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'Emergency page encountered an error',
      child: MainLayout(
        title: 'Emergency Services',
        child: RefreshIndicator(
          onRefresh: _loadFacilities,
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Stats Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[600]!, Colors.red[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Emergency Services Nearby',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              count: _allFacilities.length,
                              label: 'Total',
                              icon: Icons.medical_services,
                              selected: _typeFilter == 'all',
                              onTap: () {
                                setState(() => _typeFilter = 'all');
                                _applyFilters();
                              },
                            ),
                            _StatItem(
                              count: _allFacilities.where((f) => (f['type'] ?? '').toString().toLowerCase() == 'hospital').length,
                              label: 'Hospitals',
                              icon: Icons.local_hospital,
                              selected: _typeFilter == 'hospital',
                              onTap: () {
                                setState(() => _typeFilter = 'hospital');
                                _applyFilters();
                              },
                            ),
                            _StatItem(
                              count: _allFacilities.where((f) => (f['type'] ?? '').toString().toLowerCase() == 'pharmacy').length,
                              label: 'Pharmacies',
                              icon: Icons.medical_information,
                              selected: _typeFilter == 'pharmacy',
                              onTap: () {
                                setState(() => _typeFilter = 'pharmacy');
                                _applyFilters();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search and Filter Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search by name, location, or type',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    prefixIcon: const Icon(Icons.search, color: Colors.red),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onChanged: (_) => _applyFilters(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Filter Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.filter_alt, color: Colors.red[600], size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Show only facilities open 24/7',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Switch(
                                  value: _openNowOnly,
                                  onChanged: (value) {
                                    setState(() {
                                      _openNowOnly = value;
                                    });
                                    _applyFilters();
                                  },
                                  activeColor: Colors.red[600],
                                  activeTrackColor: Colors.red[100],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Results count
                        if (!_isLoading)
                          Text(
                            '${_filteredFacilities.length} facilities found',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        // Emergency Facilities List
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator(color: Colors.red)),
                          )
                        else if (_error != null)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  Text('Failed to load: $_error', style: const TextStyle(color: Colors.red)),
                                  TextButton(onPressed: _loadFacilities, child: const Text('Retry'))
                                ],
                              ),
                            ),
                          )
                        else if (_filteredFacilities.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No emergency facilities found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or filter',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ..._filteredFacilities.map((facility) => _EmergencyFacilityCard(
                            facility: facility,
                            onTap: () => _showFacilityDetails(context, facility),
                            onCall: () => _callFacility((facility['phone'] ?? '').toString()),
                          )),
                      ],
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

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _StatItem({
    required this.count,
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: Colors.white, width: 1.5) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyFacilityCard extends StatelessWidget {
  final Map<String, dynamic> facility;
  final VoidCallback onTap;
  final VoidCallback onCall;

  const _EmergencyFacilityCard({
    required this.facility,
    required this.onTap,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final openingHours = (facility['openingHours'] ?? '').toString();
    final bool isOpen247 = openingHours.toLowerCase().contains('24/7') || openingHours.toLowerCase().contains('24 hours');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            image: facility['profileImage'] != null && facility['profileImage'].toString().isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(facility['profileImage']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: facility['profileImage'] == null || facility['profileImage'].toString().isEmpty
              ? Icon(
                  (facility['type'] ?? '').toString().toLowerCase() == 'hospital' ? Icons.local_hospital : Icons.medical_services,
                  color: Colors.red[600],
                  size: 24,
                )
              : null,
        ),
        title: Text(
          facility['name'] ?? 'Unknown Facility',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              facility['address']?.toString().isNotEmpty == true ? facility['address'] : 'No address provided',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[400], size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    openingHours.isNotEmpty ? openingHours : 'Hours not specified',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOpen247 ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOpen247 ? '24/7' : 'Limited',
                    style: TextStyle(
                      color: isOpen247 ? Colors.green[700] : Colors.orange[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blue),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: onCall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}