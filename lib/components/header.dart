import 'package:flutter/material.dart';
import 'auth_popups.dart';
import '../services/auth_service.dart';

class Header extends StatelessWidget {
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

  void _showLoginPopup(BuildContext context) {
    AuthPopups.showLoginPopupWithNavigation(
      context,
      onLoginSuccess: () {
        // Navigate to home page after successful login
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
      onPopupClosed: () {
        // Navigate to home page when popup is closed
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
    );
  }

  void _showRegisterPopup(BuildContext context) {
    AuthPopups.showRegisterPopupWithNavigation(
      context,
      onRegisterSuccess: () {
        // Navigate to home page after successful registration
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
      onPopupClosed: () {
        // Navigate to home page when popup is closed
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onMenuTap != null)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuTap,
            ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!isLoggedIn) ...[
            // Login button
            TextButton(
              onPressed: onLoginTap ?? () => _showLoginPopup(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.white, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Register button
            ElevatedButton(
              onPressed: onRegisterTap ?? () => _showRegisterPopup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else
            // User info when logged in
            Row(
              children: [
                // User avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // User name and phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authService.userDisplayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authService.formattedPhone,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}