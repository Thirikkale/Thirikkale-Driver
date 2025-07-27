import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/settings/widgets/settings_page_layout.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageLayout(
      title: 'Privacy Policy',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: July 2025',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: '1. Information We Collect',
                content: 'We collect information that you provide directly to us, including your name, email address, phone number, and location data necessary for providing our services.',
              ),
              _buildSection(
                title: '2. How We Use Your Information',
                content: 'We use the information we collect to provide, maintain, and improve our services, communicate with you, and ensure the safety and security of our platform.',
              ),
              _buildSection(
                title: '3. Location Data',
                content: 'We collect and process your location data to facilitate trip matching, navigation, and safety features. This data is essential for the core functionality of our service.',
              ),
              _buildSection(
                title: '4. Data Security',
                content: 'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
              ),
              _buildSection(
                title: '5. Information Sharing',
                content: 'We may share your information with passengers, other drivers, or law enforcement when necessary for providing our services or complying with legal obligations.',
              ),
              const SizedBox(height: 16),
              Text(
                'For the complete privacy policy, please visit our website or contact our support team.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
