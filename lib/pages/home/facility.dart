import 'package:flutter/material.dart';
// Remove or comment out this import if detailfacility.dart doesn't exist yet
// import 'detailfacility.dart';

class FacilityItem {
  final String name;
  final String location;
  final String distance;
  final String phoneNumber;
  final String facilityType;
  final String? profileImage;
  final String? email;
  final List<String>? services;
  final String? openingHours;
  final String? hospitalType;
  final String? pharmacyType;
  final double latitude;
  final double longitude;
  final VoidCallback? onTap;

  FacilityItem({
    required this.name,
    required this.location,
    required this.distance,
    required this.phoneNumber,
    required this.facilityType,
    required this.latitude,
    required this.longitude,
    this.profileImage,
    this.email,
    this.services,
    this.openingHours,
    this.hospitalType,
    this.pharmacyType,
    this.onTap,
  });

  FacilityItem copyWith({
    String? name,
    String? location,
    String? distance,
    String? phoneNumber,
    String? facilityType,
    String? profileImage,
    String? email,
    List<String>? services,
    String? openingHours,
    String? hospitalType,
    String? pharmacyType,
    double? latitude,
    double? longitude,
    VoidCallback? onTap,
  }) {
    return FacilityItem(
      name: name ?? this.name,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      facilityType: facilityType ?? this.facilityType,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      services: services ?? this.services,
      openingHours: openingHours ?? this.openingHours,
      hospitalType: hospitalType ?? this.hospitalType,
      pharmacyType: pharmacyType ?? this.pharmacyType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      onTap: onTap ?? this.onTap,
    );
  }
}

class Facility extends StatefulWidget {
  final List<FacilityItem> facilities;
  final String? moreButtonText;
  final String? lessButtonText;
  final int maxItems;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;

  const Facility({
    super.key,
    required this.facilities,
    this.moreButtonText = 'More',
    this.lessButtonText = 'Less',
    this.maxItems = 5,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
  });

  @override
  State<Facility> createState() => _FacilityState();
}

class _FacilityState extends State<Facility> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final displayFacilities = _showAll 
        ? widget.facilities 
        : widget.facilities.take(widget.maxItems).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Our Facilities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Loading state
          if (widget.isLoading)
            Container(
              height: 200,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading facilities...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Error state with retry
          else if (widget.hasError && widget.facilities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load facilities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please check your connection and try again',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to retry',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Empty state
          else if (widget.facilities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No facilities available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please try again later',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Facility list
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayFacilities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final facility = displayFacilities[index];
                return _FacilityCard(
                  facility: facility,
                );
              },
            ),
            const SizedBox(height: 16),
            // More/Less button
            if (widget.facilities.length > widget.maxItems)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showAll = !_showAll;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.blue.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _showAll ? widget.lessButtonText ?? 'Less' : widget.moreButtonText!,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final FacilityItem facility;

  const _FacilityCard({
    super.key,
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: '${facility.name}\n${facility.location}\nDistance: ${facility.distance}\nType: ${facility.facilityType}',
        child: GestureDetector(
          onTap: facility.onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profile Image Circle
                ClipOval(
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: facility.profileImage != null
                        ? Image.asset(
                            facility.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Facility Name
                      Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Location with icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              facility.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Distance and Phone
                      Row(
                        children: [
                          // Distance
                          Row(
                            children: [
                              Icon(
                                Icons.directions_walk,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                facility.distance,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Phone
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                facility.phoneNumber,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Facility Type
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          facility.facilityType,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.local_hospital,
      size: 24,
      color: Colors.grey[600],
    );
  }
}