import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/config/env_config.dart';
import 'package:thirikkale_driver/config/routes.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/provider/driver_provider.dart';
import 'package:thirikkale_driver/core/provider/location_provider.dart';
import 'package:thirikkale_driver/core/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling to prevent crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  try {
    await EnvConfig.loadEnv();
    await Firebase.initializeApp();
  } catch (e) {
    print('Initialization error: $e');
    // Continue anyway to prevent complete app failure
  }

  runApp(const ThirikkaleDriverApp());
}

class ThirikkaleDriverApp extends StatelessWidget {
  const ThirikkaleDriverApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Thirikkale Driver',
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        // themeMode: ThemeMode.system,
        initialRoute: AppRoutes.driverHome,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
