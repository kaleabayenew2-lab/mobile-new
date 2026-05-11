import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AgentDashboardPage extends StatefulWidget {
  const AgentDashboardPage({
    super.key,
    this.agentName = '',
    this.agentType = '',
  });

  final String agentName;
  final String agentType;

  @override
  State<AgentDashboardPage> createState() => _AgentDashboardPageState();
}

class _AgentDashboardPageState extends State<AgentDashboardPage> {
  final _authService = AuthService();

  // Dashboard data
  int _totalBookings = 0;
  int _activeBookings = 0;
  int _completedBookings = 0;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    // Load dashboard statistics using mock data
    // Future implementation should fetch from agent dashboard API
    setState(() {
      _totalBookings = 45;
      _activeBookings = 8;
      _completedBookings = 37;
      _rating = 4.7;
    });
  }

  void _navigateToProfile() {
    Navigator.of(context).pushNamed('/agent-profile');
  }

  void _navigateToManagement() {
    Navigator.of(context).pushNamed('/agent-management');
  }

  void _navigateToBookings() {
    Navigator.of(context).pushNamed('/agent-bookings');
  }

  void _logout() {
    _authService.logout();
    Navigator.of(context).pushReplacementNamed('/agent-login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Add this to prevent infinite height
          children: [
            // Welcome Section
            Text(
              'Welcome back, ${widget.agentName}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s your facility overview',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Bookings',
                    _totalBookings.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    _activeBookings.toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    _completedBookings.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Rating',
                    _rating.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // COMPLETELY REWORKED: Use Wrap instead of GridView to avoid constraints issues
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionCard(
                  'Manage Profile',
                  Icons.person,
                  Colors.blue,
                  _navigateToProfile,
                ),
                _buildActionCard(
                  'Facility Management',
                  Icons.business,
                  Colors.green,
                  _navigateToManagement,
                ),
                _buildActionCard(
                  'View Bookings',
                  Icons.calendar_view_day,
                  Colors.orange,
                  _navigateToBookings,
                ),
                _buildActionCard(
                  'Settings',
                  Icons.settings,
                  Colors.grey,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings not implemented yet')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildActivityItem(
              'New booking received',
              'Patient John Doe booked an appointment',
              '2 hours ago',
              Icons.add_circle,
              Colors.blue,
            ),
            _buildActivityItem(
              'Appointment completed',
              'Consultation with Jane Smith finished',
              '4 hours ago',
              Icons.check_circle,
              Colors.green,
            ),
            _buildActivityItem(
              'Review received',
              'New 5-star review from patient',
              '1 day ago',
              Icons.star,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2, // Calculate width for 2 columns
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}