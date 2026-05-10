import 'package:flutter/material.dart';
import 'pages/home/home.dart';
import 'components/splash_screen.dart';
import 'pages/map/route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Med',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: MapRoute.getRoutes(),
      home: SplashScreen(
        child: const HomePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
