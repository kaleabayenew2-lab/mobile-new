import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  // Sample favorites data
  List<Map<String, dynamic>> get sampleFavorites => [
    {
      'id': '1',
      'name': 'Black Lion Hospital',
      'type': 'Hospital',
      'address': 'Bole, Addis Ababa, Ethiopia',
      'phone': '+251911234567',
      'rating': 4.5,
      'distance': '2.3 km',
      'savedDate': '2024-01-15',
      'isAvailable': true,
    },
    {
      'id': '2',
      'name': 'St. Paulos Hospital',
      'type': 'Hospital',
      'address': 'Mekelle, Addis Ababa, Ethiopia',
      'phone': '+251912345678',
      'rating': 4.2,
      'distance': '5.1 km',
      'savedDate': '2024-02-20',
      'isAvailable': true,
    },
    {
      'id': '3',
      'name': 'Addis Ababa Medical Center',
      'type': 'Medical Center',
      'address': 'Bole, Addis Ababa, Ethiopia',
      'phone': '+251913456789',
      'rating': 4.8,
      'distance': '1.8 km',
      'savedDate': '2024-03-10',
      'isAvailable': false,
    },
    {
      'id': '4',
      'name': 'Luna Pharmacy',
      'type': 'Pharmacy',
      'address': 'Kazanchis, Addis Ababa, Ethiopia',
      'phone': '+251914567890',
      'rating': 4.0,
      'distance': '3.2 km',
      'savedDate': '2024-03-15',
      'isAvailable': true,
    },
    {
      'id': '5',
      'name': 'Hayat Hospital',
      'type': 'Hospital',
      'address': 'CMC, Addis Ababa, Ethiopia',
      'phone': '+251915678901',
      'rating': 4.6,
      'distance': '4.5 km',
      'savedDate': '2024-04-01',
      'isAvailable': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'Favorites page encountered an error',
      child: MainLayout(
        title: 'My Favorites',
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
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Favorite Places',
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
                          count: sampleFavorites.length,
                          label: 'Total',
                          icon: Icons.favorite,
                        ),
                        _StatItem(
                          count: sampleFavorites.where((f) => f['type'] == 'Hospital').length,
                          label: 'Hospitals',
                          icon: Icons.local_hospital,
                        ),
                        _StatItem(
                          count: sampleFavorites.where((f) => f['type'] == 'Pharmacy').length,
                          label: 'Pharmacies',
                          icon: Icons.medical_services,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Favorites List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Facilities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Favorite Items
                    ...sampleFavorites.map((favorite) => _FavoriteCard(
                      favorite: favorite,
                      onTap: () => _showFacilityDetails(context, favorite),
                      onRemove: () => _removeFavorite(context, favorite),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFacilityDetails(BuildContext context, Map<String, dynamic> facility) {
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
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    facility['type'] == 'Hospital' ? Icons.local_hospital : Icons.medical_services,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        facility['type'],
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
                    color: facility['isAvailable'] == true ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    facility['isAvailable'] == true ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: facility['isAvailable'] == true ? Colors.green[700] : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _DetailRow(icon: Icons.location_on, text: facility['address']),
            _DetailRow(icon: Icons.phone, text: facility['phone']),
            _DetailRow(icon: Icons.star, text: '${facility['rating']} ⭐'),
            _DetailRow(icon: Icons.directions, text: facility['distance']),
            _DetailRow(icon: Icons.bookmark, text: 'Saved on ${facility['savedDate']}'),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Get Directions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[400]!),
                    ),
                    child: Text(
                      'Remove',
                      style: TextStyle(color: Colors.red[600]),
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

  void _removeFavorite(BuildContext context, Map<String, dynamic> facility) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${facility['name']} removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action undone')),
            );
          },
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

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> favorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.favorite,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            favorite['type'] == 'Hospital' ? Icons.local_hospital : Icons.medical_services,
            color: Colors.blue[600],
            size: 24,
          ),
        ),
        title: Text(
          favorite['name'],
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
              favorite['address'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  '${favorite['rating']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.directions, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  favorite['distance'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: favorite['isAvailable'] == true ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    favorite['isAvailable'] == true ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: favorite['isAvailable'] == true ? Colors.green[700] : Colors.red[700],
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
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: onRemove,
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
