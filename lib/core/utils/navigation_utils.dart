import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Duration get transitionDuration => Duration.zero;
  
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class NavigationUtils {
  // Launch Google Maps for navigation
  static Future<void> launchGoogleMapsNavigation({
    required double destinationLat,
    required double destinationLng,
    String? destinationName,
  }) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Google Maps');
      }
    } catch (e) {
      print('Error launching navigation: $e');
      // You might want to show a snackbar or dialog here
    }
  }

  // Launch phone dialer
  static Future<void> launchPhoneDialer(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw Exception('Could not launch phone dialer');
      }
    } catch (e) {
      print('Error launching phone dialer: $e');
    }
  }

  // Launch SMS
  static Future<void> launchSMS(String phoneNumber, {String? message}) async {
    final url = Uri.parse('sms:$phoneNumber${message != null ? '?body=$message' : ''}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw Exception('Could not launch SMS');
      }
    } catch (e) {
      print('Error launching SMS: $e');
    }
  }
}