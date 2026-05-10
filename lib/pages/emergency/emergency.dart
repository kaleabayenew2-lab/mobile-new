import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../home/facility.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _openNowOnly = false;
  late final List<FacilityItem> _allFacilities;
  List<FacilityItem> _filteredFacilities = [];

  @override
  void initState() {
    super.initState();
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
            (facility.openingHours != null && facility.openingHours!.toLowerCase().contains('24/7'));

        return matchesQuery && matchesOpenNow;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Emergency',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Emergency Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search for nearby emergency facilities and filter by open now.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search facilities',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Show only open facilities',
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
                      activeThumbColor: Colors.blue,
                      activeTrackColor: const Color.fromRGBO(33, 150, 243, 0.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: _filteredFacilities.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No emergency facilities found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Try a different search or disable the open-now filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredFacilities.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final facility = _filteredFacilities[index];
                          return _EmergencyFacilityCard(facility: facility);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyFacilityCard extends StatelessWidget {
  final FacilityItem facility;

  const _EmergencyFacilityCard({
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(128, 128, 128, 0.08),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      facility.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: facility.openingHours != null && facility.openingHours!.toLowerCase().contains('24/7')
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  facility.openingHours ?? 'Hours unknown',
                  style: TextStyle(
                    fontSize: 12,
                    color: facility.openingHours != null && facility.openingHours!.toLowerCase().contains('24/7')
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.directions_walk, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  facility.distance,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    facility.phoneNumber,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _EmergencyTag(label: facility.facilityType),
              _EmergencyTag(label: facility.openingHours ?? 'Hours TBD'),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmergencyTag extends StatelessWidget {
  final String label;

  const _EmergencyTag({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
