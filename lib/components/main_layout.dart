import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'header.dart';
import 'footer.dart';
import 'sidebar.dart';
import '../pages/map/map.dart';
import '../pages/profile/profile.dart';
import '../pages/favorite/favorite.dart';
import '../pages/emergency/emergency.dart';
import '../pages/setting/setting.dart';
import '../pages/agent/agent.dart';
import '../pages/auth/login.dart';
import '../pages/auth/register.dart';
import '../pages/booking/booking.dart';
import '../pages/privacy/privacy.dart';
import '../pages/about/about.dart';
import '../pages/history/history.dart';
import '../pages/home/home.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  
  const MainLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final AuthService _authService = AuthService();

  List<SidebarItem> _buildSidebarItems() {
    final items = <SidebarItem>[
      SidebarItem(
        icon: Icons.home,
        title: 'Home',
        onTap: () => _navigateToPage(const HomePage()),
      ),
      SidebarItem(
        icon: Icons.map,
        title: 'Map',
        onTap: () => _navigateToPage(const MapPage()),
      ),
    ];

    if (_authService.isLoggedIn) {
      items.add(
        SidebarItem(
          icon: Icons.person,
          title: 'Profile',
          onTap: () => _navigateToPage(const ProfilePage()),
        ),
      );
    }

    items.addAll([
      SidebarItem(
        icon: Icons.favorite,
        title: 'Favorites',
        onTap: () => _navigateToPage(const FavoritePage()),
      ),
      SidebarItem(
        icon: Icons.emergency,
        title: 'Emergency',
        onTap: () => _navigateToPage(const EmergencyPage()),
      ),
      SidebarItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () => _navigateToPage(const SettingPage()),
      ),
      SidebarItem(
        icon: Icons.support_agent,
        title: 'Agent',
        onTap: () => _navigateToPage(const AgentPage()),
      ),
      SidebarItem(
        icon: Icons.history,
        title: 'History',
        onTap: () => _navigateToPage(const HistoryPage()),
      ),
      SidebarItem(
        icon: Icons.book,
        title: 'Booking',
        onTap: () => _navigateToPage(const BookingPage()),
      ),
      SidebarItem(
        icon: Icons.privacy_tip,
        title: 'Privacy',
        onTap: () => _navigateToPage(const PrivacyPage()),
      ),
      SidebarItem(
        icon: Icons.info,
        title: 'About',
        onTap: () => _navigateToPage(const AboutPage()),
      ),
    ]);

    if (!_authService.isLoggedIn) {
      items.addAll([
        SidebarItem(
          icon: Icons.login,
          title: 'Login',
          onTap: () => _navigateToPage(const LoginPage()),
        ),
        SidebarItem(
          icon: Icons.app_registration,
          title: 'Register',
          onTap: () => _navigateToPage(const RegisterPage()),
        ),
      ]);
    }

    return items;
  }

  void _toggleSidebar(bool isLargeScreen) {
    if (isLargeScreen) {
      setState(() {
        _isSidebarOpen = !_isSidebarOpen;
      });
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
    });
  }

  void _navigateToPage(Widget page) {
    _closeSidebar();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 700;

        return Scaffold(
          key: _scaffoldKey,
          drawer: isLargeScreen
              ? null
              : Drawer(
                  child: Sidebar(
                    isOpen: true,
                    isDrawer: true,
                    onClose: () => Navigator.of(context).pop(),
                    items: _buildSidebarItems(),
                  ),
                ),
          body: Row(
            children: [
              if (isLargeScreen)
                Sidebar(
                  isOpen: _isSidebarOpen,
                  onClose: _closeSidebar,
                  items: _buildSidebarItems(),
                ),
              Expanded(
                child: Column(
                  children: [
                    Header(
                      title: widget.title,
                      onMenuTap: () => _toggleSidebar(isLargeScreen),
                      onLoginTap: () => _navigateToPage(const LoginPage()),
                      onRegisterTap: () => _navigateToPage(const RegisterPage()),
                    ),
                    Expanded(
                      child: ScrollAwareFooter(
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
