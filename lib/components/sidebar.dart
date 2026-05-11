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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with close button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      if (onClose != null)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 24,
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Menu items list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          child: Icon(
                            item.icon,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        dense: true,
                        horizontalTitleGap: 12,
                        onTap: () {
                          if (item.onTap != null) {
                            item.onTap!();
                          }
                          if (!isDrawer && onClose != null && isOpen) {
                            onClose!();
                          }
                        },
                      );
                    },
                  ),
                ),
                // Optional footer
                if (isDrawer)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}