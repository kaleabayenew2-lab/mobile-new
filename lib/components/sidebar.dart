import 'package:flutter/material.dart';

class SidebarItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  SidebarItem({
    required this.icon,
    required this.title,
    this.onTap,
  });
}

class Sidebar extends StatelessWidget {
  final bool isOpen;
  final bool isDrawer;
  final VoidCallback? onClose;
  final List<SidebarItem> items;

  const Sidebar({
    super.key,
    required this.isOpen,
    this.isDrawer = false,
    this.onClose,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isOpen ? 250 : 0,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: (isOpen || isDrawer)
          ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (onClose != null)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                        ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        minLeadingWidth: 40,
                        leading: SizedBox(
                          width: 24,
                          child: Icon(item.icon),
                        ),
                        title: Text(item.title),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        onTap: item.onTap,
                      );
                    },
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
