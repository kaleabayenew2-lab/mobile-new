import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'header.dart';
import 'footer.dart';
import 'sidebar.dart';
import '../pages/map/map.dart';
import '../pages/profile/profile.dart';
import '../pages/favorites/favorites.dart';
import '../pages/emergency/emergency.dart';
import '../pages/setting/setting.dart';
import '../pages/agent/agent.dart';
// Login and register pages removed from sidebar
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

    // 🔥 FIX: Use current auth state to conditionally add Profile
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
        onTap: () => _navigateToPage(const FavoritesPage()),
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
    if (mounted) {
      setState(() {
        _isSidebarOpen = false;
      });
    }
  }

  void _navigateToPage(Widget page) {
    _closeSidebar();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authService,
      builder: (context, child) {
        // 🔥 FIX: Force rebuild of sidebar items when auth state changes
        final sidebarItems = _buildSidebarItems();
        final isLoggedIn = _authService.isLoggedIn;
        
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
                        onClose: () {
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        items: sidebarItems,
                      ),
                    ),
              body: Row(
                children: [
                  if (isLargeScreen)
                    Sidebar(
                      isOpen: _isSidebarOpen,
                      onClose: _closeSidebar,
                      items: sidebarItems,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        // 🔥 CRITICAL FIX: Add ValueKey to force Header rebuild on auth change
                        Header(
                          key: ValueKey('header_${isLoggedIn ? 'loggedin' : 'loggedout'}'),
                          title: widget.title,
                          onMenuTap: () => _toggleSidebar(isLargeScreen),
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
      },
    );
  }
}