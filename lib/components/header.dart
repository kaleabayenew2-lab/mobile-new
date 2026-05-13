import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import 'auth_popups.dart';

class Header extends StatefulWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onLogoutTap;
  
  const Header({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onLoginTap,
    this.onRegisterTap,
    this.onLogoutTap,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final AuthService _authService = AuthService();
  final ThemeService _themeService = ThemeService();

  void _showLoginPopup(BuildContext context) {
    AuthPopups.showLoginPopup(context);
  }

  void _showRegisterPopup(BuildContext context) {
    AuthPopups.showRegisterPopup(context);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _authService.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
                // Trigger additional callback if provided
                if (widget.onLogoutTap != null) {
                  widget.onLogoutTap!();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authService,
      builder: (context, child) {
        final isLoggedIn = _authService.isLoggedIn;
        final userDisplayName = _authService.userDisplayName;
        final userEmail = _authService.userEmail;
        final avatarInitial = _authService.userAvatarInitial;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _themeService.isDarkMode 
                ? [Color(0xFF1E1E1E), Color(0xFF121212)]
                : [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Menu button (hamburger)
              if (widget.onMenuTap != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(Icons.menu, color: _themeService.isDarkMode ? Colors.white : Colors.white, size: 24),
                    onPressed: widget.onMenuTap,
                    tooltip: 'Menu',
                  ),
                ),
              
              // Title
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: _themeService.isDarkMode ? Colors.white : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Auth buttons or user info
              if (!isLoggedIn) ...[
                // Login button
                TextButton(
                  onPressed: widget.onLoginTap ?? () => _showLoginPopup(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Register button
                ElevatedButton(
                  onPressed: widget.onRegisterTap ?? () => _showRegisterPopup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2196F3),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else
                // User info section when logged in
                GestureDetector(
                  onTap: () {
                    // Optional: Navigate to profile when tapping user area
                    // You can add navigation to profile page here
                    debugPrint('User area tapped - can navigate to profile');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User avatar with initial
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _themeService.isDarkMode ? Colors.white : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              avatarInitial,
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // User name and email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userDisplayName,
                              style: TextStyle(
                                color: _themeService.isDarkMode ? Colors.white : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userEmail ?? 'No email',
                              style: TextStyle(
                                color: (_themeService.isDarkMode ? Colors.white : Colors.white).withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Logout button
                        IconButton(
                          onPressed: () => _showLogoutConfirmation(context),
                          icon: Icon(
                            Icons.logout,
                            color: _themeService.isDarkMode ? Colors.white : Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Logout',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(36, 36),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}