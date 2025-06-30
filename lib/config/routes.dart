import 'package:flutter/material.dart';
import 'package:thirikkale_driver/features/authentication/screens/get_started_screen.dart';
import 'package:thirikkale_driver/features/home/screens/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const GetStartedScreen(),
      home: (context) => const HomeScreen(),
    };
  }
}
