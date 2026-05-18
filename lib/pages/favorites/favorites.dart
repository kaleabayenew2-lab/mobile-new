import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';
import '../../components/auth_popups.dart';
import 'dart:convert';

import '../../services/auth_service.dart';
import '../../services/api/favorites_api.dart';
import '../../services/api/home/homeapi.dart';
import '../../services/api/facility_api.dart';
import '../home/detailfacility.dart';
import '../home/facility.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _allFacilities = [];
  Set<int> _userFavorites = {}; // Track user's favorite facility IDs
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _typeFilter = 'all'; // 'all', 'hospital', 'pharmacy'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all facilities regardless of login status
      final facilitiesData = await HomeApi.getFacilities();
      
      final facilities = facilitiesData.map((f) => Map<String, dynamic>.from(f as Map)).toList();

      // If user is logged in, load their favorite facilities
      Set<int> userFavIds = {};
      final auth = AuthService.instance;
      if (auth.isAuthenticated() && auth.userEmail != null && auth.userEmail!.isNotEmpty) {
        try {
          final response = await FavoritesApi.getFavoritesByEmail(
            auth.userEmail!,
            token: auth.token,
          );
          if (response['success'] == true && response['favorites'] is List) {
            userFavIds = (response['favorites'] as List)
                .map((f) => f['id'] as int? ?? 0)
                .where((id) => id > 0)
                .toSet();
          }
        } catch (e) {
          print('Error loading user favorites: $e');
        }
      }

      setState(() {
        _allFacilities = facilities;
        _userFavorites = userFavIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allFacilities = [];
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Refresh favorites
  Future<void> _refreshFavorites() async {
    await _loadFavorites();
  }

  List<Widget> _buildFavoriteItems(BuildContext context) {
    final filtered = _allFacilities.where((f) {
      final query = _searchQuery.toLowerCase();
      final name = (f['name'] ?? '').toString().toLowerCase();
      final type = (f['type'] ?? '').toString().toLowerCase();
      final address = (f['address'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(query) || type.contains(query) || address.contains(query);
      final matchesType = _typeFilter == 'all' || type == _typeFilter;
      return matchesSearch && matchesType;
    }).toList();

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(child: Text('No results match "$_searchQuery"')),
        )
      ];
    }

    return filtered.map<Widget>((facility) => _FavoriteCard(
      facility: facility,
      isFavorited: _userFavorites.contains(facility['id']),
      onTap: () => _showFacilityDetails(context, facility),
      onFavoriteToggle: () => _toggleFavorite(context, facility),
    )).toList();
  }

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
                          count: _allFacilities.length,
                          label: 'Total',
                          icon: Icons.favorite,
                          selected: _typeFilter == 'all',
                          onTap: () => setState(() => _typeFilter = 'all'),
                        ),
                        _StatItem(
                          count: _allFacilities.where((f) => (f['type'] ?? '').toString().toLowerCase() == 'hospital').length,
                          label: 'Hospitals',
                          icon: Icons.local_hospital,
                          selected: _typeFilter == 'hospital',
                          onTap: () => setState(() => _typeFilter = 'hospital'),
                        ),
                        _StatItem(
                          count: _allFacilities.where((f) => (f['type'] ?? '').toString().toLowerCase() == 'pharmacy').length,
                          label: 'Pharmacies',
                          icon: Icons.medical_services,
                          selected: _typeFilter == 'pharmacy',
                          onTap: () => setState(() => _typeFilter = 'pharmacy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search favorites...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue[400]!),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Favorites List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saved Facilities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadFavorites,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text('Failed to load: $_error', textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: _loadFavorites, child: const Text('Retry')),
                            ],
                          ),
                        ),
                      )
                    else if (_allFacilities.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(child: Text('No facilities found.')),
                      )
                    else
                      // Favorite Items
                      ..._buildFavoriteItems(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FacilityItem _mapToFacilityItem(Map<String, dynamic> data) {
    // Safely parse coordinates
    double lat = 0.0;
    double lng = 0.0;
    try {
      final raw = data['location'];
      final locationData = raw is String ? json.decode(raw) : raw;
      if (locationData != null && locationData['coordinates'] is List) {
        final coords = locationData['coordinates'] as List<dynamic>;
        if (coords.length >= 2) {
          lng = (coords[0] as num).toDouble();
          lat = (coords[1] as num).toDouble();
        }
      }
    } catch (_) {}

    // Safely parse services
    List<String> services = [];
    try {
      if (data['services'] is String && (data['services'] as String).isNotEmpty) {
        final decoded = json.decode(data['services']);
        if (decoded is List) services = decoded.cast<String>();
      } else if (data['services'] is List) {
        services = (data['services'] as List<dynamic>).cast<String>();
      }
    } catch (_) {}

    // Safely parse gallery images
    List<String> galleryImages = [];
    try {
      if (data['galleryImages'] is String && (data['galleryImages'] as String).isNotEmpty) {
        final decoded = json.decode(data['galleryImages']);
        if (decoded is List) {
          galleryImages = decoded.cast<String>();
        }
      } else if (data['galleryImages'] is List) {
        galleryImages = (data['galleryImages'] as List<dynamic>).cast<String>();
      }
    } catch (_) {}

    return FacilityItem(
      id: data['id'] != null ? int.tryParse(data['id'].toString()) : null,
      isFavorite: _userFavorites.contains(data['id']),
      name: (data['name'] ?? 'Unknown').toString(),
      location: (data['address'] ?? 'Unknown Address').toString(),
      distance: 'Calculating...',
      phoneNumber: data['phone']?.toString() ?? '',
      facilityType: (data['type'] ?? 'facility').toString(),
      profileImage: data['profileImage']?.toString(),
      email: data['email']?.toString(),
      services: services,
      openingHours: data['openingHours']?.toString(),
      hospitalType: data['hospitalType']?.toString(),
      pharmacyType: data['pharmacyType']?.toString(),
      galleryImages: galleryImages.isNotEmpty ? galleryImages : null,
      viewsTotal: data['viewsTotal'] != null ? int.tryParse(data['viewsTotal'].toString()) : 0,
      latitude: lat,
      longitude: lng,
    );
  }

  void _showFacilityDetails(BuildContext context, Map<String, dynamic> facility) async {
    // Record view in the background first so the count increments immediately
    try {
      if (facility['id'] != null) {
        final auth = AuthService.instance;
        final email = auth.isLoggedIn ? auth.userEmail : null;
        await FacilityApi.recordView(
          facility['id'] as int,
          viewerIdentifier: email,
          viewerType: email != null ? 'email' : 'device',
        );
      }
    } catch (_) {}

    // Show details using the standard details popup
    final item = _mapToFacilityItem(facility);
    await showFacilityDetail(context, item);
    
    // Refresh the list when closing the sheet to show the updated views count!
    _loadFavorites();
  }

  Future<void> _toggleFavorite(BuildContext context, Map<String, dynamic> facility) async {
    final auth = AuthService.instance;
    if (!auth.isAuthenticated()) {
      final choice = await AuthPopups.showAuthChoicePopup(context);
      if (choice == 'login') {
        await AuthPopups.showLoginPopupWithNavigation(
          context,
          onLoginSuccess: () async {
            if (mounted) {
              await _toggleFavorite(context, facility);
            }
          },
        );
      } else if (choice == 'register') {
        await AuthPopups.showRegisterPopupWithNavigation(
          context,
          onRegisterSuccess: () async {
            if (mounted) {
              await _toggleFavorite(context, facility);
            }
          },
        );
      }
      return;
    }

    if (facility['id'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot save this facility.')),
        );
      }
      return;
    }

    try {
      final isFavorited = _userFavorites.contains(facility['id']);
      final response = isFavorited
          ? await FavoritesApi.removeFavorite(
              auth.userEmail!,
              facility['id'] as int,
              token: auth.token,
            )
          : await FavoritesApi.addFavorite(
              auth.userEmail!,
              facility['id'] as int,
              token: auth.token,
            );

      if (response['success'] == true) {
        setState(() {
          if (isFavorited) {
            _userFavorites.remove(facility['id']);
          } else {
            _userFavorites.add(facility['id'] as int);
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFavorited
                  ? 'Removed from favorites'
                  : 'Saved to favorites'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Favorite request failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorite request failed: $e')),
        );
      }
    }
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

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> facility;
  final bool isFavorited;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _FavoriteCard({
    required this.facility,
    required this.isFavorited,
    required this.onTap,
    required this.onFavoriteToggle,
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
                  color: Colors.blue[600],
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
              facility['address']?.toString().isNotEmpty == true ? facility['address'] : (facility['type'] ?? '').toString().toUpperCase(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.remove_red_eye, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  '${facility['viewsTotal'] ?? 0}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.favorite, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${facility['favoriteCount'] ?? 0}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: facility['isActive'] == true ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    facility['isActive'] == true ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: facility['isActive'] == true ? Colors.green[700] : Colors.red[700],
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
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
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
