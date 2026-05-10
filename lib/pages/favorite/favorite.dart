import 'package:flutter/material.dart';
import '../../components/main_layout.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late final List<FavoriteFacility> _favoriteFacilities;

  @override
  void initState() {
    super.initState();
    _favoriteFacilities = [
      FavoriteFacility(
        name: 'St. Mary Emergency Center',
        location: 'Bole, Addis Ababa',
        distance: '2.4 km',
        phoneNumber: '+251 911 123 456',
        facilityType: 'Hospital',
        latitude: 9.02497,
        longitude: 38.7615,
        openingHours: 'Open 24/7',
        rating: 4.8,
        reviews: 342,
      ),
      FavoriteFacility(
        name: 'Addis Health Clinic',
        location: 'Kazanchis, Addis Ababa',
        distance: '4.1 km',
        phoneNumber: '+251 911 234 567',
        facilityType: 'Clinic',
        latitude: 9.0136,
        longitude: 38.7612,
        openingHours: 'Open 24/7',
        rating: 4.6,
        reviews: 218,
      ),
      FavoriteFacility(
        name: 'City Pharmacy & Urgent Care',
        location: 'Piassa, Addis Ababa',
        distance: '5.9 km',
        phoneNumber: '+251 911 345 678',
        facilityType: 'Pharmacy',
        latitude: 9.0155,
        longitude: 38.7539,
        openingHours: '08:00 - 22:00',
        rating: 4.5,
        reviews: 156,
      ),
      FavoriteFacility(
        name: 'Sunrise Emergency Ward',
        location: 'Bole Road, Addis Ababa',
        distance: '3.2 km',
        phoneNumber: '+251 911 456 789',
        facilityType: 'Hospital',
        latitude: 9.0353,
        longitude: 38.7598,
        openingHours: 'Open 24/7',
        rating: 4.9,
        reviews: 421,
      ),
      FavoriteFacility(
        name: 'Riverside Clinic',
        location: 'Meskel Square, Addis Ababa',
        distance: '6.3 km',
        phoneNumber: '+251 911 567 890',
        facilityType: 'Clinic',
        latitude: 9.0111,
        longitude: 38.7617,
        openingHours: '09:00 - 20:00',
        rating: 4.4,
        reviews: 189,
      ),
      FavoriteFacility(
        name: 'Prime Medical Center',
        location: 'Mexico Square, Addis Ababa',
        distance: '7.1 km',
        phoneNumber: '+251 911 678 901',
        facilityType: 'Hospital',
        latitude: 9.0089,
        longitude: 38.7556,
        openingHours: 'Open 24/7',
        rating: 4.7,
        reviews: 305,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Favorites',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Your Favorite Facilities',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_favoriteFacilities.length} saved favorites',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _favoriteFacilities.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No favorite facilities yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Add your favorite healthcare facilities here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _favoriteFacilities.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final facility = _favoriteFacilities[index];
                          return _FavoriteFacilityCard(facility: facility);
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

class FavoriteFacility {
  final String name;
  final String location;
  final String distance;
  final String phoneNumber;
  final String facilityType;
  final double latitude;
  final double longitude;
  final String openingHours;
  final double rating;
  final int reviews;

  FavoriteFacility({
    required this.name,
    required this.location,
    required this.distance,
    required this.phoneNumber,
    required this.facilityType,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
    required this.rating,
    required this.reviews,
  });
}

class _FavoriteFacilityCard extends StatelessWidget {
  final FavoriteFacility facility;

  const _FavoriteFacilityCard({
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            facility.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(Icons.favorite, color: Colors.red, size: 20),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      facility.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          facility.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${facility.reviews} reviews)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: facility.openingHours.toLowerCase().contains('24/7')
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  facility.openingHours,
                  style: TextStyle(
                    fontSize: 12,
                    color: facility.openingHours.toLowerCase().contains('24/7')
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
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  facility.facilityType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${facility.reviews} reviews',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from favorites')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${facility.phoneNumber}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Call'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
