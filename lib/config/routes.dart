import 'package:flutter/material.dart';
import 'package:thirikkale_driver/features/authentication/screens/document_upload_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/get_started_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/name_registration_screen.dart';
import 'package:thirikkale_driver/features/home/screens/home_screen.dart';
import 'package:thirikkale_driver/features/home/screens/driver_home_screen.dart';
import 'package:thirikkale_driver/features/drivepass/screens/drive_pass_screen.dart';
import 'package:thirikkale_driver/features/drivepass/screens/drive_pass_history_screen.dart';
import 'package:thirikkale_driver/features/reviewrate/screens/reviews_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/earnings_overview_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/earnings_history_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/payout_settings_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/earnings_analytics_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/trips_payment_screen.dart';
import 'package:thirikkale_driver/features/earnings/screens/bonuses_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';
  static const String driverHome = '/driver-home';
  static const String nameReg = '/name-registration';
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
  static const String bonuses = '/bonuses';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const GetStartedScreen(),
      home: (context) => const HomeScreen(),
      driverHome: (context) => const DriverHomeScreen(),
      nameReg: (context) => const NameRegistrationScreen(),
      documentUpload:
          (context) => const DocumentUploadScreen(firstName: "Nikila"),
      drivePass: (context) => const DrivePassScreen(),
      drivePassHistory: (context) => const DrivePassHistoryScreen(),
      reviews: (context) => const ReviewsScreen(),
      earningsOverview: (context) => const EarningsOverviewScreen(),
      earningsHistory: (context) => const EarningsHistoryScreen(),
      payoutSettings: (context) => const PayoutSettingsScreen(),
      earningsAnalytics: (context) => const EarningsAnalyticsScreen(),
      trips: (context) => const TripsPaymentScreen(),
      tripPayment: (context) => const TripsPaymentScreen(),
      bonuses: (context) => const BonusesScreen(),
    };
  }
}
