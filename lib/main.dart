import 'package:flutter/material.dart';
import 'pages/home/home.dart';
import 'components/splash_screen.dart';
import 'components/error_boundary.dart';
import 'routes/app_routes.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      enableLogging: true,
      fallbackMessage: 'Application encountered an error',
      child: AnimatedBuilder(
        animation: ThemeService(),
        builder: (context, child) {
          return MaterialApp(
            title: 'Find Med',
            theme: ThemeService().currentTheme,
            routes: AppRoutes.getRoutes(),
            home: const ErrorBoundary(
              enableLogging: true,
              fallbackMessage: 'Home screen failed to load',
              child: SplashScreen(
                child: HomePage(),
              ),
            ),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return ErrorBoundary(
                enableLogging: true,
                fallbackMessage: 'Navigation error occurred',
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
