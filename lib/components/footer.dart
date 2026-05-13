import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ScrollAwareFooter extends StatefulWidget {
  final String? copyright;
  final List<Widget>? actions;
  final Widget child;
  
  const ScrollAwareFooter({
    super.key,
    this.copyright,
    this.actions,
    required this.child,
  });

  @override
  State<ScrollAwareFooter> createState() => _ScrollAwareFooterState();
}

class _ScrollAwareFooterState extends State<ScrollAwareFooter> {
  bool _showFooter = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      final shouldShowFooter = maxScroll - currentScroll < 100;
      
      if (shouldShowFooter != _showFooter) {
        setState(() {
          _showFooter = shouldShowFooter;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              widget.child,
              const SizedBox(height: 200),
            ],
          ),
        ),
        
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFooter ? null : 0,
            child: _showFooter
                ? Footer(
                    copyright: widget.copyright,
                    actions: widget.actions,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class Footer extends StatelessWidget {
  final String? copyright;
  final List<Widget>? actions;
  
  const Footer({
    super.key,
    this.copyright,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Contact Us Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.contact_mail, color: Colors.blue[700], size: 22),
              const SizedBox(width: 8),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Row 1: Email and Phone side by side
          Row(
            children: [
              // Email
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'kaleabayenew519@gmail.com',
                    );
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Colors.teal[600], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'kaleabayenew519@gmail.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.teal[600],
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Phone 1
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: '+251909095880',
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.green[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '+251909095880',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Row 2: Second Phone and Location side by side
          Row(
            children: [
              // Phone 2
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: '+251709095880',
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.green[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '+251709095880',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Location
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.orange[600], size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gondar Maraki, Ethiopia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Row 3: Availability (full width)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.purple[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  '24/7 Available - Always Ready to Help',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.purple[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Divider(height: 1, color: Colors.grey),
          
          const SizedBox(height: 12),
          
          // Copyright section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                copyright ?? '© 2024 FindMed. All rights reserved.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          
          const SizedBox(height: 8),
          
          Center(
            child: Text(
              'Made with ❤️ in Ethiopia',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}