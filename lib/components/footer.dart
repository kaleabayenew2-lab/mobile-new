import 'package:flutter/material.dart';

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
      
      // Show footer when user is within 100 pixels of the bottom
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
        // Main content
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              widget.child,
              // Add some padding at the bottom to ensure footer can appear
              const SizedBox(height: 200),
            ],
          ),
        ),
        
        // Footer that appears when scrolled to bottom
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
    // Quick navigation actions
    final quickActions = [
      _QuickActionButton(
        icon: Icons.home,
        text: 'Home',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigating to Home...')),
          );
        },
      ),
      _QuickActionButton(
        icon: Icons.map,
        text: 'Map',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening Map...')),
          );
        },
      ),
      _QuickActionButton(
        icon: Icons.favorite,
        text: 'Favorites',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening Favorites...')),
          );
        },
      ),
      _QuickActionButton(
        icon: Icons.settings,
        text: 'Settings',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening Settings...')),
          );
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
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
          // Main footer content with two sections
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Contact Information
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ContactItem(
                        icon: Icons.phone,
                        text: '+251 123 456 789',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling +251 123 456 789')),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      _ContactItem(
                        icon: Icons.email,
                        text: 'info@findmed.com',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening email client...')),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      _ContactItem(
                        icon: Icons.location_on,
                        text: 'Addis Ababa, Ethiopia',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Showing location on map...')),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      _ContactItem(
                        icon: Icons.facebook,
                        text: 'FindMed Ethiopia',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening Facebook page...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Right side - Quick Actions & Navigation
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Navigation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: quickActions,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // App info section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'FindMed - Your Healthcare Companion',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find hospitals, pharmacies, and medical services near you',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Copyright section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                copyright ?? '© 2024 FindMed. All rights reserved.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Made with ❤️ in Ethiopia',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue[300]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
