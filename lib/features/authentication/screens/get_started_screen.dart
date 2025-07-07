import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/authentication/screens/mobile_registration_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              "assets/images/thirikkale_driver_dark_logo.png",
              width: double.infinity,
              height: 300.0,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 5),
            Expanded(
              flex: 5,
              child: Lottie.asset(
                'assets/lotties/driver_get_started_animation.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),

            const SizedBox(height: 80),
            Text(
              'Drive When You Want, \nEarn How You Choose',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2,
            ),

            SizedBox(height: 60.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MobileRegistrationScreen()),
                    ),
                style: AppButtonStyles.primaryButton,
                child: Text("Get Started"),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
