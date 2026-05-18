import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
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

class _HeaderState extends State<Header> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ThemeService _themeService = ThemeService();

  AnimationController? _blinkController;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.addListener(_onNotificationsChanged);
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (NotificationService.instance.shouldBlink) {
      _blinkController?.repeat(reverse: true);
    }
  }

  void _onNotificationsChanged() {
    if (mounted) {
      if (NotificationService.instance.shouldBlink) {
        if (!(_blinkController?.isAnimating ?? false)) {
          _blinkController?.repeat(reverse: true);
        }
      } else {
        _blinkController?.stop();
        _blinkController?.value = 0.0;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_onNotificationsChanged);
    _blinkController?.dispose();
    super.dispose();
  }

  void _showLoginPopup(BuildContext context) {
    AuthPopups.showLoginPopup(context);
  }

  void _showRegisterPopup(BuildContext context) {
    AuthPopups.showRegisterPopup(context);
  }

  void _showLogoutConfirmation(BuildContext context, {required bool isAgent}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isAgent ? 'Logout Agent' : 'Logout User'),
          content: Text(isAgent 
              ? 'Are you sure you want to log out of the Agent/Facility session?' 
              : 'Are you sure you want to log out of the User session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isAgent) {
                  _authService.logoutAgent();
                } else {
                  _authService.logout();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAgent ? 'Agent logged out successfully' : 'User logged out successfully'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
                // Trigger additional callback if provided
                if (!isAgent && widget.onLogoutTap != null) {
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

  void _showNotificationsDialog(BuildContext context) {
    final notifService = NotificationService.instance;
    final list = notifService.notifications;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 380, maxHeight: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_rounded, color: Colors.blue, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'Notifications',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            if (notifService.unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${notifService.unreadCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: list.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No notifications found',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: list.length,
                              separatorBuilder: (context, index) => const Divider(height: 16),
                              itemBuilder: (context, index) {
                                final n = list[index];
                                final isAgentNotif = n.id.startsWith('agent_');
                                final isReminder = n.id.startsWith('user_reminder_');
                                final timeDiff = DateTime.now().difference(n.timestamp).inMinutes;
                                final timeText = timeDiff <= 0 ? 'Just now' : '${timeDiff}m ago';
                                
                                return _buildNotificationTile(
                                  icon: isReminder 
                                      ? Icons.access_time_rounded 
                                      : (isAgentNotif ? Icons.calendar_today_rounded : Icons.notifications_rounded),
                                  iconColor: isReminder 
                                      ? Colors.orange 
                                      : (isAgentNotif ? Colors.blue : Colors.green),
                                  title: n.title,
                                  subtitle: n.subtitle,
                                  time: timeText,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          notifService.markAllAsRead();
                          setDialogState(() {});
                          setState(() {});
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Mark all as read'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _openNotifications() {
    NotificationService.instance.markAllAsRead();
    _showNotificationsDialog(context);
    setState(() {});
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfileGreen() {
    final userDisplayName = _authService.userDisplayName;
    final avatarInitial = _authService.userAvatarInitial;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User avatar with initial - green theme
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatarInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // User name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  userDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                'User Active',
                style: TextStyle(
                  color: Colors.green.shade100,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // User logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showLogoutConfirmation(context, isAgent: false),
            tooltip: 'User Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildAgentProfileRed() {
    final agentName = _authService.currentAgent?['name'] ?? _authService.currentAgent?['fullName'] ?? 'Agent';
    final agentType = _authService.currentAgent?['type'] ?? 'Hospital';
    final agentInitial = agentName.isNotEmpty ? agentName[0].toUpperCase() : 'A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Agent avatar - red theme
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                agentInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Agent name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  agentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                '${agentType.toUpperCase()} Agent',
                style: TextStyle(
                  color: Colors.red.shade100,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // Agent logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showLogoutConfirmation(context, isAgent: true),
            tooltip: 'Agent Logout',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authService,
      builder: (context, child) {
        final isUserLoggedIn = _authService.isLoggedIn;
        final isAgentLoggedIn = _authService.isAgentLoggedIn;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _themeService.isDarkMode 
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [const Color(0xFF2196F3), const Color(0xFF1976D2)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
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
              
              // Notification Icon
              AnimatedBuilder(
                animation: Listenable.merge([NotificationService.instance, _blinkController!]),
                builder: (context, child) {
                  final notifService = NotificationService.instance;
                  final unreadCount = notifService.unreadCount;
                  final shouldBlink = notifService.shouldBlink;

                  final scale = 1.0 + (_blinkController!.value * 0.18);
                  final color = Color.lerp(
                    Colors.white,
                    Colors.amber.shade400,
                    _blinkController!.value,
                  );

                  return IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.scale(
                          scale: shouldBlink ? scale : 1.0,
                          child: Icon(
                            Icons.notifications_rounded,
                            color: shouldBlink ? color : Colors.white,
                            size: 24,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Center(
                                child: Text(
                                  '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _openNotifications,
                    tooltip: 'Notifications',
                  );
                },
              ),
              const SizedBox(width: 8),

              // Auth profiles or buttons
              if (!isUserLoggedIn && !isAgentLoggedIn) ...[
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
              ] else ...[
                if (isUserLoggedIn) ...[
                  _buildUserProfileGreen(),
                ],
                if (isUserLoggedIn && isAgentLoggedIn) const SizedBox(width: 8),
                if (isAgentLoggedIn) ...[
                  _buildAgentProfileRed(),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}