import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';
import '../home/facility.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _openNowOnly = false;
  late List<FacilityItem> _allFacilities;
  List<FacilityItem> _filteredFacilities = [];

  @override
  void initState() {
    super.initState();
    _initializeFacilities();
  }

  void _initializeFacilities() {
    _allFacilities = [
      FacilityItem(
        name: 'St. Mary Emergency Center',
        location: 'Bole, Addis Ababa',
        distance: '2.4 km',
        phoneNumber: '+251 911 123 456',
        facilityType: 'Hospital',
        latitude: 9.02497,
        longitude: 38.7615,
        openingHours: 'Open 24/7',
      ),
      FacilityItem(
        name: 'Addis Health Clinic',
        location: 'Kazanchis, Addis Ababa',
        distance: '4.1 km',
        phoneNumber: '+251 911 234 567',
        facilityType: 'Clinic',
        latitude: 9.0136,
        longitude: 38.7612,
        openingHours: 'Open 24/7',
      ),
      FacilityItem(
        name: 'City Pharmacy & Urgent Care',
        location: 'Piassa, Addis Ababa',
        distance: '5.9 km',
        phoneNumber: '+251 911 345 678',
        facilityType: 'Pharmacy',
        latitude: 9.0155,
        longitude: 38.7539,
        openingHours: '08:00 - 22:00',
      ),
      FacilityItem(
        name: 'Sunrise Emergency Ward',
        location: 'Bole Road, Addis Ababa',
        distance: '3.2 km',
        phoneNumber: '+251 911 456 789',
        facilityType: 'Hospital',
        latitude: 9.0353,
        longitude: 38.7598,
        openingHours: 'Open 24/7',
      ),
      FacilityItem(
        name: 'Riverside Clinic',
        location: 'Meskel Square, Addis Ababa',
        distance: '6.3 km',
        phoneNumber: '+251 911 567 890',
        facilityType: 'Clinic',
        latitude: 9.0111,
        longitude: 38.7617,
        openingHours: '09:00 - 20:00',
      ),
    ];
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredFacilities = _allFacilities.where((facility) {
        final matchesQuery = query.isEmpty ||
            facility.name.toLowerCase().contains(query) ||
            facility.location.toLowerCase().contains(query) ||
            facility.facilityType.toLowerCase().contains(query);

        final matchesOpenNow = !_openNowOnly ||
            (facility.openingHours != null && 
             facility.openingHours!.toLowerCase().contains('24/7'));

        return matchesQuery && matchesOpenNow;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFacilityDetails(BuildContext context, FacilityItem facility) {
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
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        facility.facilityType,
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
                    color: facility.openingHours != null && facility.openingHours!.toLowerCase().contains('24/7') 
                        ? Colors.green[100] 
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    facility.openingHours != null && facility.openingHours!.toLowerCase().contains('24/7') 
                        ? 'Open 24/7' 
                        : 'Limited Hours',
                    style: TextStyle(
                      color: facility.openingHours != null && facility.openingHours!.toLowerCase().contains('24/7') 
                          ? Colors.green[700] 
                          : Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _DetailRow(icon: Icons.location_on, text: facility.location),
            _DetailRow(icon: Icons.phone, text: facility.phoneNumber),
            _DetailRow(icon: Icons.access_time, text: facility.openingHours ?? 'Hours not specified'),
            _DetailRow(icon: Icons.directions, text: facility.distance),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: () => Navigator.pop(context),
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

  void _callFacility(String phoneNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phoneNumber...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'Emergency page encountered an error',
      child: MainLayout(
        title: 'Emergency Services',
        child: ScrollAwareFooter(
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
                      color: Colors.red.withValues(alpha: 0.3),
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
                        ),
                        _StatItem(
                          count: _allFacilities.where((f) => f.facilityType == 'Hospital').length,
                          label: 'Hospitals',
                          icon: Icons.local_hospital,
                        ),
                        _StatItem(
                          count: _allFacilities.where((f) => f.facilityType == 'Pharmacy').length,
                          label: 'Pharmacies',
                          icon: Icons.medical_information,
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
                                  color: Colors.grey.withValues(alpha: 0.1),
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
                              onSubmitted: (_) => _applyFilters(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w600)),
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
                              activeThumbColor: Colors.red[600],
                              activeTrackColor: Colors.red[100],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Results count
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
                    ..._filteredFacilities.map((facility) => _EmergencyFacilityCard(
                      facility: facility,
                      onTap: () => _showFacilityDetails(context, facility),
                      onCall: () => _callFacility(facility.phoneNumber),
                    )),
                    
                    if (_filteredFacilities.isEmpty)
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
                      ),
                  ],
                ),
              ),
            ],
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

  const _StatItem({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
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
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EmergencyFacilityCard extends StatelessWidget {
  final FacilityItem facility;
  final VoidCallback onTap;
  final VoidCallback onCall;

  const _EmergencyFacilityCard({
    required this.facility,
    required this.onTap,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOpen247 = facility.openingHours != null && 
                           facility.openingHours!.toLowerCase().contains('24/7');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.local_hospital,
            color: Colors.red[600],
            size: 24,
          ),
        ),
        title: Text(
          facility.name,
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
              facility.location,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[400], size: 14),
                const SizedBox(width: 4),
                Text(
                  facility.openingHours ?? 'Hours not specified',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.directions, color: Colors.grey[400], size: 14),
                const SizedBox(width: 4),
                Text(
                  facility.distance,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
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