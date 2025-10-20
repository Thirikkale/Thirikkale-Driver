import 'package:flutter/material.dart';
import 'package:thirikkale_driver/features/authentication/screens/auth_wrapper.dart';
import 'package:thirikkale_driver/features/authentication/screens/document_upload_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/get_started_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/mobile_registration_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/name_registration_screen.dart';
import 'package:thirikkale_driver/features/home/screens/driver_home_screen.dart';
import 'package:thirikkale_driver/features/drivepass/screens/drive_pass_screen.dart';
import 'package:thirikkale_driver/features/drivepass/screens/drive_pass_history_screen.dart';
import 'package:thirikkale_driver/features/reviewrate/screens/reviews_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/earnings_overview_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/earnings_history_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/payout_settings_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/trips_payment_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String getStarted = '/get-started';
  static const String driverHome = '/driver-home';
  static const String nameReg = '/name-registration';
  static const String mobileRegistration = '/mobile-registration';
  static const String documentUpload = '/document-upload';
  static const String drivePass = '/drive-pass';
  static const String drivePassHistory = '/drive-pass-history';
  static const String reviews = '/reviews';
  static const String writeReview = '/write-review';
  static const String earningsOverview = '/earnings-overview';
  static const String earningsHistory = '/earnings-history';
  static const String payoutSettings = '/payout-settings';
  static const String earningsAnalytics = '/earnings-analytics';
  static const String trips = '/trips';
  static const String tripPayment = '/trip-payment';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const AuthWrapper(),
      getStarted: (context) => const GetStartedScreen(),
      driverHome: (context) => const DriverHomeScreen(),
      nameReg: (context) => const NameRegistrationScreen(),
      mobileRegistration: (context) => const MobileRegistrationScreen(),
      documentUpload: (context) => const DocumentUploadScreen(firstName: "Driver"),
      drivePass: (context) => const DrivePassScreen(),
      drivePassHistory: (context) => const DrivePassHistoryScreen(),
      reviews: (context) => const ReviewsScreen(),
      earningsOverview: (context) => const EarningsOverviewScreen(),
      earningsHistory: (context) => const EarningsHistoryScreen(),
      payoutSettings: (context) => const PayoutSettingsScreen(),
      trips: (context) => const TripsPaymentScreen(),
      tripPayment: (context) => const TripsPaymentScreen(),
    };
  }
}
