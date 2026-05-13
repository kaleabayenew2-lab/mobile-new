import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  
  // Contact information
  static const String _email = 'kaleabayenew519@gmail.com';
  static const String _phone1 = '+251909095880';
  static const String _phone2 = '+251709095880';
  static const String _address = 'Gondar Maraki';
  static const String _workingHours = '24/7';

  // Social media URLs
  static const String _facebookUrl = 'https://www.facebook.com/findmedethiopia';
  static const String _twitterUrl = 'https://www.twitter.com/findmedethiopia';
  static const String _instagramUrl = 'https://www.instagram.com/findmedethiopia';
  static const String _youtubeUrl = 'https://www.youtube.com/@findmedethiopia';

  // Launch email
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _email,
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }

  // Launch phone
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    }
  }

  // Launch URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'About page encountered an error',
      child: MainLayout(
        title: 'About Us',
        child: ScrollAwareFooter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[600]!, Colors.teal[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'FindMed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your Healthcare Companion',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Mission Section
                const _AboutSection(
                  title: 'Our Mission',
                  icon: Icons.lightbulb,
                  content: [
                    '• Revolutionize healthcare access in Ethiopia through mobile technology',
                    '• Bridge the gap between patients and healthcare providers nationwide',
                    '• Provide accurate, real-time information about medical facilities and services',
                    '• Eliminate barriers to quality healthcare through digital innovation',
                    '• Empower Ethiopians to take control of their health journey',
                    '• Reduce wait times and improve efficiency in healthcare delivery',
                    '• Ensure every Ethiopian can find medical care when and where they need it',
                  ],
                ),

                const SizedBox(height: 16),

                // Features Section
                const _AboutSection(
                  title: 'Key Features',
                  icon: Icons.star,
                  content: [
                    '• Search and filter hospitals, pharmacies, and medical centers by location',
                    '• Book appointments with doctors and healthcare providers online',
                    '• Track medical history, appointments, and treatment records',
                    '• Get real-time directions and navigation to healthcare facilities',
                    '• Access emergency services and urgent care information 24/7',
                    '• Save favorite healthcare facilities for quick access',
                    '• View facility details including services, hours, and contact info',
                    '• Receive appointment reminders and health notifications',
                    '• Rate and review healthcare providers and facilities',
                    '• Multi-language support for local Ethiopian languages',
                    '• Offline access to saved medical information',
                    '• Secure messaging with healthcare providers',
                  ],
                ),

                const SizedBox(height: 16),

                // Team Section
                const _AboutSection(
                  title: 'Our Team',
                  icon: Icons.groups,
                  content: [
                    '• Healthcare professionals specializing in Ethiopian medical system',
                    '• Mobile app developers with healthcare technology expertise',
                    '• UI/UX designers focused on user-friendly medical interfaces',
                    '• Local medical facility partners and consultants',
                    '• Customer support team fluent in local languages',
                    '• Data analysts ensuring accurate healthcare information',
                    '• Quality assurance team testing medical app features',
                  ],
                ),

                const SizedBox(height: 16),

                // Stats Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'By the Numbers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatCard(
                            number: '500+',
                            label: 'Healthcare Facilities',
                            icon: Icons.local_hospital,
                          ),
                          _StatCard(
                            number: '50K+',
                            label: 'Active Users',
                            icon: Icons.people,
                          ),
                          _StatCard(
                            number: '100K+',
                            label: 'Appointments Booked',
                            icon: Icons.calendar_month,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.contact_support,
                              color: Colors.teal[600],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Contact Us',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      GestureDetector(
                        onTap: _launchEmail,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.email, color: Colors.teal[600], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.teal[700],
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Icon(Icons.open_in_new, color: Colors.teal[600], size: 16),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Phone Numbers
                      Column(
                        children: [
                          // First Phone Number
                          GestureDetector(
                            onTap: () => _launchPhone(_phone1),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.green[600], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _phone1,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.open_in_new, color: Colors.green[600], size: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Second Phone Number
                          GestureDetector(
                            onTap: () => _launchPhone(_phone2),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.green[600], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _phone2,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.open_in_new, color: Colors.green[600], size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Address
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _address,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Working Hours
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.orange[600], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _workingHours,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Social Media Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Follow Us',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SocialButton(
                            icon: Icons.alternate_email,
                            label: 'Facebook',
                            onTap: () => _launchUrl(_facebookUrl),
                          ),
                          _SocialButton(
                            icon: Icons.chat,
                            label: 'Twitter',
                            onTap: () => _launchUrl(_twitterUrl),
                          ),
                          _SocialButton(
                            icon: Icons.photo_camera,
                            label: 'Instagram',
                            onTap: () => _launchUrl(_instagramUrl),
                          ),
                          _SocialButton(
                            icon: Icons.play_circle,
                            label: 'YouTube',
                            onTap: () => _launchUrl(_youtubeUrl),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Version Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '© 2024 FindMed. All rights reserved.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> content;

  const _AboutSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.teal[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...content.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.teal[600],
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.teal[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}