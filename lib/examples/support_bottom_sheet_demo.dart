import 'package:flutter/material.dart';
import 'package:thirikkale_driver/features/support/screens/support_screen.dart';
import 'package:thirikkale_driver/features/demo/screens/bottom_sheet_demo_screen.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

/// Demo app showing how to navigate to support screen with bottom sheets
class SupportWithBottomSheetDemo extends StatelessWidget {
  const SupportWithBottomSheetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Support with Bottom Sheets Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DemoHomeScreen(),
    );
  }
}

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thirikkale Driver Demo'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Support & Bottom Sheet Demo',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'This demo shows how the Support & Help screen now uses modern bottom sheets instead of traditional dialogs.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Open Support & Help'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BottomSheetDemoScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.view_list),
                  label: const Text('View All Bottom Sheet Types'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features Implemented:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Interactive help guides with bottom sheets'),
                      const Text('• Confirmation dialogs for contact actions'),
                      const Text('• Enhanced FAQ with detailed answers'),
                      const Text('• Action sheets for additional help options'),
                      const Text('• Consistent design throughout the app'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const SupportWithBottomSheetDemo());
}
