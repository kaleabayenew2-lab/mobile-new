import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AgentDashboardPage extends StatefulWidget {
  const AgentDashboardPage({
    super.key,
    this.agentName = '',
    this.agentType = '',
    this.onLogout,
  });

  final String agentName;
  final String agentType;
  final VoidCallback? onLogout;

  @override
  State<AgentDashboardPage> createState() => _AgentDashboardPageState();
}

class _AgentDashboardPageState extends State<AgentDashboardPage> {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService.instance;
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Map<String, dynamic> get _agent => _authService.currentAgent ?? {};

  String get _name => _agent['name'] ?? _agent['fullName'] ?? widget.agentName;
  String get _type => _agent['type'] ?? widget.agentType;
  String get _email => _agent['email'] ?? '';
  String get _phone => _agent['phone'] ?? '';
  String get _address => _agent['address'] ?? '';
  String get _openingHours => _agent['openingHours'] ?? '';
  String get _ownership => _agent['ownership'] ?? '';
  String get _agentId => _agent['agentId']?.toString() ?? '';
  String get _username => _agent['username'] ?? '';
  bool get _isEmergency => _agent['isEmergency'] == true;
  double get _rating => (_agent['averageRating'] ?? 0.0).toDouble();
  int get _ratingCount => (_agent['ratingCount'] ?? 0) as int;
  int get _viewsTotal => (_agent['viewsTotal'] ?? 0) as int;
  List<String> get _services {
    final raw = _agent['services'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  Color get _typeColor {
    switch (_type.toLowerCase()) {
      case 'hospital': return const Color(0xFF3b82f6);
      case 'pharmacy': return const Color(0xFF10b981);
      case 'clinic': return const Color(0xFF8b5cf6);
      default: return const Color(0xFF6b7280);
    }
  }

  void _navigateToProfile() => Navigator.of(context).pushNamed('/agent-profile');
  void _navigateToManagement() => Navigator.of(context).pushNamed('/agent-management');
  void _navigateToBookings() => Navigator.of(context).pushNamed('/agent-bookings');

  void _logout() {
    _authService.logoutAgent();
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      Navigator.of(context).pushReplacementNamed('/agent-login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _typeColor,
        foregroundColor: Colors.white,
        title: const Text('Agent Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: _navigateToProfile, tooltip: 'Profile'),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Logout'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Agent Identity Card ─────────────────────────────────
            _buildAgentCard(),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats ─────────────────────────────────────────
                  _buildSectionTitle('Statistics'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _buildStatCard('Rating', _rating > 0 ? _rating.toStringAsFixed(1) : '—', Icons.star_rounded, const Color(0xFFF59E0B))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Reviews', _ratingCount.toString(), Icons.reviews_rounded, const Color(0xFF8B5CF6))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Views', _viewsTotal.toString(), Icons.visibility_rounded, const Color(0xFF3B82F6))),
                  ]),
                  const SizedBox(height: 24),

                  // ── Services ──────────────────────────────────────
                  if (_services.isNotEmpty) ...[
                    _buildSectionTitle('Services Offered'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _services.map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12, color: Colors.white)),
                        backgroundColor: _typeColor,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Quick Actions ─────────────────────────────────
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _buildActionTile('Profile', Icons.person_rounded, const Color(0xFF3B82F6), _navigateToProfile),
                      _buildActionTile('Management', Icons.business_rounded, const Color(0xFF10B981), _navigateToManagement),
                      _buildActionTile('Bookings', Icons.calendar_month_rounded, const Color(0xFFF59E0B), _navigateToBookings),
                      _buildActionTile('Settings', Icons.settings_rounded, const Color(0xFF6B7280), () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings coming soon')),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Agent Profile Card ──────────────────────────────────────────────────────
  Widget _buildAgentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_typeColor, _typeColor.withOpacity(0.85)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name row
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(
                  _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name.isNotEmpty ? _name : 'Facility Name',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_type.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                      ),
                      if (_isEmergency) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('EMERGENCY',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Detail rows
          if (_username.isNotEmpty) _infoRow(Icons.person, 'Username', '@$_username'),
          if (_agentId.isNotEmpty) _infoRow(Icons.badge_rounded, 'Agent ID', _agentId),
          if (_email.isNotEmpty) _infoRow(Icons.email_rounded, 'Email', _email),
          if (_phone.isNotEmpty) _infoRow(Icons.phone_rounded, 'Phone', _phone),
          if (_address.isNotEmpty) _infoRow(Icons.location_on_rounded, 'Address', _address),
          if (_openingHours.isNotEmpty) _infoRow(Icons.access_time_rounded, 'Hours', _openingHours),
          if (_ownership.isNotEmpty) _infoRow(Icons.business_rounded, 'Ownership', _ownership.toUpperCase()),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.85)),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
          Expanded(
            child: Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)));
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }
}