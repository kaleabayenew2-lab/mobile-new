import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import '../../services/theme_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _notificationsEnabled = false;
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Settings',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'These toggles are for demonstration only.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Turn app notifications on or off'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeThumbColor: Colors.blue,
                    activeTrackColor: const Color.fromRGBO(33, 150, 243, 0.4),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Row(
                      children: [
                        Icon(
                          _themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: _themeService.isDarkMode ? Colors.blue.shade700 : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            color: _themeService.isDarkMode ? Colors.blue.shade700 : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _themeService.isDarkMode ? Colors.blue.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _themeService.isDarkMode ? 'ON' : 'OFF',
                            style: TextStyle(
                              color: _themeService.isDarkMode ? Colors.blue.shade900 : Colors.orange.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      _themeService.isDarkMode 
                        ? 'Dark mode is currently enabled'
                        : 'Light mode is currently enabled',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    value: _themeService.isDarkMode,
                    onChanged: (value) {
                      _themeService.toggleDarkMode();
                    },
                    activeThumbColor: _themeService.isDarkMode ? Colors.blue.shade700 : Colors.orange.shade700,
                    activeTrackColor: (_themeService.isDarkMode ? Colors.blue.shade200 : Colors.orange.shade200).withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _themeService.isDarkMode ? Colors.grey.shade600 : Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        key: const Key('settings-icon'),
                        _themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: _themeService.isDarkMode ? Colors.orange.shade700 : Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Theme & Notification Status',
                          style: TextStyle(
                            color: _themeService.isDarkMode ? Colors.white : Colors.grey.shade800,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _themeService.isDarkMode 
                      ? 'Dark mode is currently active - Dark theme enabled'
                      : 'Light mode is currently active - Light theme enabled',
                    style: TextStyle(
                      color: _themeService.isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Notifications Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _notificationsEnabled 
                            ? (_themeService.isDarkMode ? Colors.green.shade600 : Colors.green.shade400)
                            : (_themeService.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _notificationsEnabled ? 'On' : 'Off',
                          style: TextStyle(
                            color: _notificationsEnabled 
                              ? (_themeService.isDarkMode ? Colors.white : Colors.grey.shade800)
                              : (_themeService.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade600),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dark Mode Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _themeService.isDarkMode ? Colors.blue.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              size: 16,
                              color: _themeService.isDarkMode ? Colors.blue.shade700 : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _themeService.isDarkMode ? 'ENABLED' : 'DISABLED',
                              style: TextStyle(
                                color: _themeService.isDarkMode ? Colors.blue.shade900 : Colors.orange.shade900,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}