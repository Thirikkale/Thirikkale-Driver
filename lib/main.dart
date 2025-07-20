import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/config/routes.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ThirikkaleDriverApp());
}

class ThirikkaleDriverApp extends StatelessWidget {
  const ThirikkaleDriverApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Thirikkale Driver',
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        // themeMode: ThemeMode.system,
        initialRoute: AppRoutes.initial,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
