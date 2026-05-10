import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import 'agent_login.dart';
import 'agent_register.dart';
import 'agent_reset.dart';
import 'agent_dashboard.dart';
import 'agent_profile.dart';
import 'agent_managemnt.dart';
import 'agent_booking.dart';

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> with TickerProviderStateMixin {
  bool _isLoggedIn = false;
  String _authMode = 'login'; // 'login', 'register', 'reset'
  String _agentName = '';
  String _agentType = '';
  
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleLoginSuccess(String name, String type) {
    setState(() {
      _isLoggedIn = true;
      _agentName = name;
      _agentType = type;
      _authMode = 'login';
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _tabController.index = 0;
      _authMode = 'login';
      _agentName = '';
      _agentType = '';
    });
  }

  void _switchToRegister() {
    setState(() {
      _authMode = 'register';
    });
  }

  void _switchToReset() {
    setState(() {
      _authMode = 'reset';
    });
  }

  void _switchToLogin() {
    setState(() {
      _authMode = 'login';
    });
  }

  Widget _buildAuthCard() {
    switch (_authMode) {
      case 'register':
        return AgentRegisterPage(
          onLoginSuccess: _handleLoginSuccess,
          onSwitchToLogin: _switchToLogin,
        );
      case 'reset':
        return AgentResetPage(
          onSwitchToLogin: _switchToLogin,
        );
      default:
        return AgentLoginPage(
          onLoginSuccess: _handleLoginSuccess,
          onSwitchToRegister: _switchToRegister,
          onSwitchToReset: _switchToReset,
        );
    }
  }

  Widget _buildAgentTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'Dashboard'),
                    Tab(text: 'Profile'),
                    Tab(text: 'Management'),
                    Tab(text: 'Booking'),
                  ],
                ),
                const Divider(height: 1),
                SizedBox(
                  height: 520,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      AgentDashboardPage(
                        agentName: _agentName,
                        agentType: _agentType,
                      ),
                      const AgentProfilePage(),
                      const AgentManagementPage(),
                      const AgentBookingPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleLogout,
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Agent',
      child: _isLoggedIn 
          ? _buildAgentTabs() 
          : _buildAuthCard(),
    );
  }
}
