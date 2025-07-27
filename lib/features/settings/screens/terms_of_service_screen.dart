import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/settings/widgets/settings_page_layout.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageLayout(
      title: 'Terms of Service',
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
                title: '1. Acceptance of Terms',
                content: 'By accessing or using the Thirikkale Driver app, you agree to be bound by these Terms of Service and all applicable laws and regulations.',
              ),
              _buildSection(
                title: '2. Driver Eligibility',
                content: 'You must be at least 18 years old and possess a valid driver\'s license to use our services. You must also maintain proper insurance coverage as required by local laws.',
              ),
              _buildSection(
                title: '3. Service Rules',
                content: 'You agree to provide professional and courteous service to all passengers, maintain your vehicle in good condition, and follow all local transportation laws and regulations.',
              ),
              _buildSection(
                title: '4. Payment Terms',
                content: 'You will receive payment for your services as described in our Payment Terms. We reserve the right to modify our fee structure with appropriate notice.',
              ),
              _buildSection(
                title: '5. Account Termination',
                content: 'We reserve the right to suspend or terminate your account for violations of these terms, low ratings, or other reasons as determined by our policies.',
              ),
              _buildSection(
                title: '6. Liability',
                content: 'You are responsible for maintaining appropriate insurance coverage and complying with all applicable laws. We are not liable for any damages arising from your use of our services.',
              ),
              const SizedBox(height: 16),
              Text(
                'For the complete terms of service, please visit our website or contact our support team.',
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
