import 'package:flutter/material.dart';
import '../pages/favorites/favorites.dart';
import '../pages/history/history.dart';
import '../pages/map/route.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String map = MapRoute.mapRoute;
  static const String favorites = '/favorites';
  static const String history = '/history';
  
  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      // Include existing map routes
      ...MapRoute.getRoutes(),
      
      // Add new routes
      favorites: (context) => const FavoritesPage(),
      history: (context) => const HistoryPage(),
    };
  }
}
