import 'package:flutter/material.dart';
import 'package:thirikkale_driver/features/authentication/screens/document_upload_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/get_started_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/mobile_registration_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/name_registration_screen.dart';
import 'package:thirikkale_driver/features/home/screens/home_screen.dart';
import 'package:thirikkale_driver/features/home/screens/driver_home_screen.dart';
import 'package:thirikkale_driver/features/drivepass/screens/drive_pass_screen.dart';
import 'package:thirikkale_driver/features/drivepass/screens/drive_pass_history_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';
  static const String driverHome = '/driver-home';
  static const String nameReg = '/name-registration';
  static const String mobileRegistration = '/mobile-registration';
  static const String documentUpload = '/document-upload';
  static const String drivePass = '/drive-pass';
  static const String drivePassHistory = '/drive-pass-history';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const GetStartedScreen(),
      home: (context) => const HomeScreen(),
      driverHome: (context) => const DriverHomeScreen(),
      nameReg: (context) => const NameRegistrationScreen(),
      mobileRegistration: (context) => const MobileRegistrationScreen(),
      documentUpload: (context) => const DocumentUploadScreen(firstName: "Nikila"),
      drivePass: (context) => const DrivePassScreen(),
      drivePassHistory: (context) => const DrivePassHistoryScreen(),
    };
  }
}
