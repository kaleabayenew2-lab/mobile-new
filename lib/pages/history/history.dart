import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Sample history data
  List<Map<String, dynamic>> get sampleHistory => [
    {
      'id': '1',
      'facilityName': 'Black Lion Hospital',
      'type': 'Hospital',
      'action': 'Visited',
      'date': '2024-05-10',
      'time': '14:30',
      'address': 'Bole, Addis Ababa, Ethiopia',
      'duration': '2 hours 15 minutes',
      'rating': 5,
    },
    {
      'id': '2',
      'facilityName': 'Luna Pharmacy',
      'type': 'Pharmacy',
      'action': 'Called',
      'date': '2024-05-09',
      'time': '10:15',
      'address': 'Kazanchis, Addis Ababa, Ethiopia',
      'duration': '5 minutes',
      'rating': null,
    },
    {
      'id': '3',
      'facilityName': 'St. Paulos Hospital',
      'type': 'Hospital',
      'action': 'Visited',
      'date': '2024-05-08',
      'time': '09:00',
      'address': 'Mekelle, Addis Ababa, Ethiopia',
      'duration': '1 hour 45 minutes',
      'rating': 4,
    },
    {
      'id': '4',
      'facilityName': 'Addis Ababa Medical Center',
      'type': 'Medical Center',
      'action': 'Bookmarked',
      'date': '2024-05-07',
      'time': '16:45',
      'address': 'Bole, Addis Ababa, Ethiopia',
      'duration': '2 minutes',
      'rating': null,
    },
    {
      'id': '5',
      'facilityName': 'Hayat Hospital',
      'type': 'Hospital',
      'action': 'Visited',
      'date': '2024-05-06',
      'time': '11:30',
      'address': 'CMC, Addis Ababa, Ethiopia',
      'duration': '3 hours 10 minutes',
      'rating': 4,
    },
    {
      'id': '6',
      'facilityName': 'Zemen Pharmacy',
      'type': 'Pharmacy',
      'action': 'Called',
      'date': '2024-05-05',
      'time': '13:20',
      'address': 'Piassa, Addis Ababa, Ethiopia',
      'duration': '8 minutes',
      'rating': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'History page encountered an error',
      child: MainLayout(
        title: 'My History',
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
                    colors: [Colors.purple[600]!, Colors.purple[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Activity History',
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
                        _HistoryStatItem(
                          count: sampleHistory.length,
                          label: 'Total Activities',
                          icon: Icons.history,
                        ),
                        _HistoryStatItem(
                          count: sampleHistory.where((h) => h['action'] == 'Visited').length,
                          label: 'Visits',
                          icon: Icons.local_hospital,
                        ),
                        _HistoryStatItem(
                          count: sampleHistory.where((h) => h['action'] == 'Called').length,
                          label: 'Calls',
                          icon: Icons.phone,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filter Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterTab(
                        title: 'All',
                        isActive: true,
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: _FilterTab(
                        title: 'Visited',
                        isActive: false,
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: _FilterTab(
                        title: 'Called',
                        isActive: false,
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: _FilterTab(
                        title: 'Bookmarked',
                        isActive: false,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // History List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // History Items grouped by date
                    ..._groupHistoryByDate(sampleHistory).map((entry) => _HistoryDateGroup(
                      date: entry['date'] as String,
                      activities: entry['activities'] as List<Map<String, dynamic>>,
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

  List<Map<String, dynamic>> _groupHistoryByDate(List<Map<String, dynamic>> history) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (final item in history) {
      final date = item['date'] as String;
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(item);
    }
    
    return grouped.entries.map((entry) => {
      'date': entry.key,
      'activities': entry.value,
    }).toList();
  }
}

class _HistoryStatItem extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;

  const _HistoryStatItem({
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

class _FilterTab extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _HistoryDateGroup extends StatelessWidget {
  final String date;
  final List<Map<String, dynamic>> activities;

  const _HistoryDateGroup({
    required this.date,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        
        // Activities for this date
        ...activities.map((activity) => _HistoryCard(
          activity: activity,
          onTap: () => _showActivityDetails(context, activity),
        )),
        
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return dateStr;
    }
  }

  void _showActivityDetails(BuildContext context, Map<String, dynamic> activity) {
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
                    color: _getActionColor(activity['action']).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getActionIcon(activity['action']),
                    color: _getActionColor(activity['action']),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['facilityName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        activity['type'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _HistoryDetailRow(icon: Icons.access_time, text: activity['time']),
            _HistoryDetailRow(icon: Icons.calendar_today, text: activity['date']),
            _HistoryDetailRow(icon: Icons.location_on, text: activity['address']),
            _HistoryDetailRow(icon: Icons.timer, text: activity['duration']),
            
            if (activity['rating'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Your Rating: ${activity['rating']}/5',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('View Facility'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'Visited':
        return Colors.blue;
      case 'Called':
        return Colors.green;
      case 'Bookmarked':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'Visited':
        return Icons.local_hospital;
      case 'Called':
        return Icons.phone;
      case 'Bookmarked':
        return Icons.bookmark;
      default:
        return Icons.info;
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.activity,
    required this.onTap,
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
            color: Colors.grey.withValues(alpha: 0.3),
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
            color: _getActionColor(activity['action']).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getActionIcon(activity['action']),
            color: _getActionColor(activity['action']),
            size: 24,
          ),
        ),
        title: Text(
          activity['facilityName'],
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
              activity['address'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  '${activity['time']} • ${activity['duration']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                if (activity['rating'] != null) ...[
                  Icon(Icons.star, color: Colors.orange[400], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${activity['rating']}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.purple),
          onPressed: onTap,
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'Visited':
        return Colors.blue;
      case 'Called':
        return Colors.green;
      case 'Bookmarked':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'Visited':
        return Icons.local_hospital;
      case 'Called':
        return Icons.phone;
      case 'Bookmarked':
        return Icons.bookmark;
      default:
        return Icons.info;
    }
  }
}

class _HistoryDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HistoryDetailRow({
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