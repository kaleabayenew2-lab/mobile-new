import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/main_layout.dart';
import '../../components/footer.dart';
import '../../components/error_boundary.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  
  // Contact information
  static const String _email = 'kaleabayenew519@gmail.com';
  static const String _phone1 = '+251909095880';
  static const String _phone2 = '+251709095880';
  static const String _address = 'Gondar Maraki';
  static const String _workingHours = '24/7';

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

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'Privacy page encountered an error',
      child: MainLayout(
        title: 'Privacy Policy',
        child: ScrollAwareFooter(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _PrivacyHeader(),
                const SizedBox(height: 16),
                
                // Privacy Content Sections
                _PrivacySection(
                  title: 'Information We Collect',
                  icon: Icons.data_usage,
                  content: [
                    '• Personal information (name, email, phone number, date of birth)',
                    '• Location data for finding nearby medical facilities and pharmacies in Ethiopia',
                    '• Health information and medical history from Ethiopian healthcare providers',
                    '• Prescription and medication information for pharmacy services',
                    '• Emergency contact information for medical emergencies',
                    '• Insurance information for healthcare billing and coverage',
                    '• Appointment and booking history with medical facilities',
                    '• Usage data and app interactions for healthcare service improvement',
                    '• Device information for healthcare app compatibility and security',
                  ],
                ),
                const SizedBox(height: 16),
                
                _PrivacySection(
                  title: 'How We Use Your Information',
                  icon: Icons.settings,
                  content: [
                    '• To provide and maintain FindMed Ethiopia healthcare services',
                    '• To manage your medical appointments and bookings with healthcare facilities',
                    '• To connect you with nearby pharmacies and medical facilities in Ethiopia',
                    '• To handle your prescription orders and medication reminders',
                    '• To provide emergency medical assistance when needed',
                    '• To send healthcare notifications and appointment reminders',
                    '• To analyze healthcare usage patterns for service improvement',
                    '• To verify your identity for medical services and prescriptions',
                    '• To coordinate with Ethiopian healthcare providers for your care',
                  ],
                ),
                const SizedBox(height: 16),
                
                _PrivacySection(
                  title: 'Information Sharing',
                  icon: Icons.share,
                  content: [
                    '• We do not sell your medical or personal information',
                    '• Medical data shared only with authorized healthcare providers in Ethiopia',
                    '• Location data used only for finding nearby medical facilities and pharmacies',
                    '• Emergency medical data shared with emergency services when required',
                    '• Booking information shared only with selected healthcare facilities',
                    '• Prescription data shared only with verified pharmacies',
                    '• Anonymous healthcare analytics shared with medical research partners',
                    '• We share health information only with your explicit written consent',
                  ],
                ),
                const SizedBox(height: 16),
                
                _PrivacySection(
                  title: 'Data Security',
                  icon: Icons.security,
                  content: [
                    '• All medical data encrypted with AES-256 encryption in transit and at rest',
                    '• Secure healthcare servers with regular HIPAA-compliant security updates',
                    '• Strict access control for sensitive medical information and patient records',
                    '• Regular security audits and healthcare-specific penetration testing',
                    '• Compliance with Ethiopian healthcare data regulations and international standards',
                    '• Secure medical record storage with backup and disaster recovery',
                    '• Protected pharmacy and facility data with role-based access',
                    '• Secure emergency medical data transmission for urgent care situations',
                  ],
                ),
                const SizedBox(height: 16),
                
                _PrivacySection(
                  title: 'Your Rights',
                  icon: Icons.gavel,
                  content: [
                    '• Right to access your medical and personal data through FindMed Ethiopia',
                    '• Right to correct inaccurate health information in your profile',
                    '• Right to delete your account and all healthcare records',
                    '• Right to opt-out of healthcare notifications and promotions',
                    '• Right to request export of your medical history and bookings',
                    '• Right to control who can access your health information',
                    '• Right to transparent pricing and service information',
                    '• Right to emergency medical assistance when needed',
                  ],
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
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.contact_support,
                              color: Colors.indigo[600],
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
                            color: Colors.indigo[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.email, color: Colors.indigo[600], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.indigo[700],
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Icon(Icons.open_in_new, color: Colors.indigo[600], size: 16),
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
                const SizedBox(height: 32),
                
                // Last Updated Section
                _LastUpdatedSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyHeader extends StatelessWidget {
  const _PrivacyHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[600]!, Colors.indigo[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.privacy_tip,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your privacy is our priority',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> content;

  const _PrivacySection({
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
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.indigo[600],
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

class _LastUpdatedSection extends StatelessWidget {
  const _LastUpdatedSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            'Last Updated: May 12, 2024',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This privacy policy is effective immediately upon posting. We may update this policy periodically to reflect changes in our practices, services, or legal requirements.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}