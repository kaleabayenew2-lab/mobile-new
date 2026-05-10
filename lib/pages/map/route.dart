import 'package:flutter/material.dart';
import 'displaymap.dart';
import '../home/facility.dart';

class MapRoute {
  static const String mapRoute = '/map';
  
  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      mapRoute: (context) {
        final facilities = ModalRoute.of(context)?.settings.arguments as List<FacilityItem>?;
        return facilities != null ? DisplayMap(facilities: facilities) : const SizedBox();
      },
    };
  }
}
