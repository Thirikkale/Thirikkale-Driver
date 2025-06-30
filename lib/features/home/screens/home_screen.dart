import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
                Text(
                  "Thirikkale Driver Home Screen",
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
