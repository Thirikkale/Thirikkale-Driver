import 'package:flutter/material.dart';
import 'package:thirikkale_driver/config/routes.dart';
import 'package:thirikkale_driver/core/utils/app_theme.dart';

void main() {
  runApp(const ThirikkaleDriverApp());
}

class ThirikkaleDriverApp extends StatelessWidget {
  const ThirikkaleDriverApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thirikkale',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.getRoutes(),
    );
  }
}
