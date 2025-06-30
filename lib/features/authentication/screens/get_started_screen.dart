import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/home/screens/home_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/thirikkale_driver_dark_logo.png",
                  width: double.infinity,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
                Text(
                  "Thirikkale Driver GetStarted Screen",
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 35.0,),
                ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      ),
                  style: AppButtonStyles.primaryButton,
                  child: Text("Get Started"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
