import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Theme-aware slide bar component
class ThemeAwareSlideBar extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final List<BoxShadow>? boxShadow;

  const ThemeAwareSlideBar({
    super.key,
    required this.title,
    required this.children,
    this.height = 60.0,
    this.margin,
    this.padding,
    this.decoration,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final isDarkMode = themeService.isDarkMode;

    return AnimatedBuilder(
      animation: themeService,
      builder: (context, child) {
        return Container(
          height: height,
          margin: margin,
          padding: padding,
          decoration: decoration ?? BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: boxShadow ?? [
              BoxShadow(
                color: isDarkMode 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Handle or drag indicator
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: isDarkMode 
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF2196F3),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF333333),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
