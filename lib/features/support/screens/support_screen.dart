import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Support & Help',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.widgetSpacing),
            
            // Welcome message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We\'re here to help!',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to common questions or get in touch with our support team.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.sectionSpacing),

            // Quick Help Section
            Text(
              'Quick Help',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppDimensions.subSectionSpacing),

            // Quick help cards
            _buildHelpCard(
              icon: Icons.info_outline,
              title: 'Getting Started',
              description: 'Learn how to use the Thirikkale Driver app',
              color: AppColors.primaryBlue,
              onTap: () => _showGettingStartedDialog(context),
            ),
            
            const SizedBox(height: AppDimensions.widgetSpacing),
            
            _buildHelpCard(
              icon: Icons.directions_car,
              title: 'How to Accept Rides',
              description: 'Step-by-step guide to accepting and completing rides',
              color: AppColors.success,
              onTap: () => _showAcceptRidesDialog(context),
            ),

            const SizedBox(height: AppDimensions.widgetSpacing),
            
            _buildHelpCard(
              icon: Icons.account_balance_wallet,
              title: 'Earnings & Payments',
              description: 'Understand how your earnings work and payment schedules',
              color: AppColors.warning,
              onTap: () => _showEarningsDialog(context),
            ),

            const SizedBox(height: AppDimensions.sectionSpacing),

            // Common Issues Section
            Text(
              'Common Issues',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppDimensions.subSectionSpacing),

            _buildHelpCard(
              icon: Icons.gps_not_fixed,
              title: 'GPS & Location Issues',
              description: 'Troubleshoot location and navigation problems',
              color: AppColors.error,
              onTap: () => _showGPSIssuesDialog(context),
            ),

            const SizedBox(height: AppDimensions.widgetSpacing),
            
            _buildHelpCard(
              icon: Icons.network_check,
              title: 'Connection Problems',
              description: 'Fix network and connectivity issues',
              color: AppColors.secondaryBlue,
              onTap: () => _showConnectionIssuesDialog(context),
            ),

            const SizedBox(height: AppDimensions.widgetSpacing),
            
            _buildHelpCard(
              icon: Icons.verified_user,
              title: 'Account Verification',
              description: 'Help with document upload and verification process',
              color: AppColors.primaryGreen,
              onTap: () => _showVerificationDialog(context),
            ),

            const SizedBox(height: AppDimensions.sectionSpacing),

            // Contact Support Section
            Text(
              'Contact Support',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppDimensions.subSectionSpacing),

            _buildContactCard(
              icon: Icons.phone,
              title: 'Call Support',
              description: 'Speak directly with our support team',
              actionText: 'Call Now',
              onTap: () => _callSupport(context),
            ),

            const SizedBox(height: AppDimensions.widgetSpacing),
            
            _buildContactCard(
              icon: Icons.email,
              title: 'Email Support',
              description: 'Send us a detailed message about your issue',
              actionText: 'Send Email',
              onTap: () => _emailSupport(context),
            ),

            const SizedBox(height: AppDimensions.widgetSpacing),
            
            _buildContactCard(
              icon: Icons.chat,
              title: 'Live Chat',
              description: 'Chat with our support team in real-time',
              actionText: 'Start Chat',
              onTap: () => _startLiveChat(context),
            ),

            const SizedBox(height: AppDimensions.sectionSpacing),

            // FAQ Section
            _buildExpandableSection(
              title: 'Frequently Asked Questions',
              children: [
                _buildFAQItem(
                  question: 'How do I go online to start receiving rides?',
                  answer: 'Tap the "Go Online" button on your home screen. Make sure your location is enabled and you have a stable internet connection.',
                ),
                _buildFAQItem(
                  question: 'What documents do I need to drive?',
                  answer: 'You need a valid driver\'s license, vehicle registration, insurance documents, and a clear profile photo.',
                ),
                _buildFAQItem(
                  question: 'How are my earnings calculated?',
                  answer: 'Your earnings are based on distance, time, and current demand. You can view detailed breakdowns in the Earnings section.',
                ),
                _buildFAQItem(
                  question: 'What should I do if a passenger doesn\'t show up?',
                  answer: 'Wait for 5 minutes, then you can cancel the ride and receive a cancellation fee. Use the "Passenger No-Show" option.',
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.sectionSpacing * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onTap,
              style: AppButtonStyles.primaryButton.copyWith(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: children,
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // Dialog methods for help topics
  void _showGettingStartedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Getting Started', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome to Thirikkale Driver! Here\'s how to get started:', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              _buildStep('1', 'Complete your profile and upload required documents'),
              _buildStep('2', 'Wait for verification (usually 24-48 hours)'),
              _buildStep('3', 'Go online by tapping the "Go Online" button'),
              _buildStep('4', 'Accept ride requests and start earning!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarHelper.showSuccessSnackBar(
                context,
                'Great! You\'re ready to start your journey with Thirikkale!',
              );
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showAcceptRidesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How to Accept Rides', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Follow these steps to accept and complete rides:', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              _buildStep('1', 'When you receive a ride request, review pickup location and destination'),
              _buildStep('2', 'Tap "Accept" to confirm the ride'),
              _buildStep('3', 'Navigate to the pickup location using the built-in GPS'),
              _buildStep('4', 'Call or text the passenger when you arrive'),
              _buildStep('5', 'Confirm passenger pickup and start the trip'),
              _buildStep('6', 'Follow GPS directions to the destination'),
              _buildStep('7', 'End the trip when you reach the destination'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarHelper.showSuccessSnackBar(
                context,
                'Now you know how to accept rides like a pro!',
              );
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showEarningsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Earnings & Payments', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Understanding your earnings:', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              _buildStep('💰', 'Base fare + time + distance = total fare'),
              _buildStep('⏰', 'Surge pricing during high demand periods'),
              _buildStep('💳', 'Weekly payments directly to your bank account'),
              _buildStep('📊', 'View detailed earnings breakdown in the app'),
              _buildStep('🎯', 'Bonus opportunities for completing certain targets'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarHelper.showInfoSnackBar(
                context,
                'Check your earnings screen to track your progress!',
              );
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showGPSIssuesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('GPS & Location Issues', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('To fix GPS and location problems:', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              _buildStep('📍', 'Enable location permissions for the app'),
              _buildStep('🛰️', 'Ensure GPS is turned on in your phone settings'),
              _buildStep('🌐', 'Check your internet connection'),
              _buildStep('🔄', 'Restart the app if location seems inaccurate'),
              _buildStep('📱', 'Keep your phone in an area with clear sky view'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarHelper.showInfoSnackBar(
                context,
                'Try these steps to improve your GPS accuracy!',
              );
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showConnectionIssuesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection Problems', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('To fix network and connectivity issues:', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              _buildStep('📶', 'Check your mobile data or WiFi connection'),
              _buildStep('🔄', 'Try switching between WiFi and mobile data'),
              _buildStep('✈️', 'Turn airplane mode on/off to reset connection'),
              _buildStep('📱', 'Restart your phone if issues persist'),
              _buildStep('📍', 'Move to an area with better signal strength'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarHelper.showInfoSnackBar(
                context,
                'These tips should help resolve connection issues!',
              );
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Verification', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('For successful account verification:', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              _buildStep('📄', 'Upload clear photos of all required documents'),
              _buildStep('🆔', 'Ensure documents are valid and not expired'),
              _buildStep('📸', 'Take photos in good lighting without shadows'),
              _buildStep('✅', 'Double-check all information matches exactly'),
              _buildStep('⏳', 'Verification usually takes 24-48 hours'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarHelper.showSuccessSnackBar(
                context,
                'Follow these tips for faster verification!',
              );
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Contact methods
  void _callSupport(BuildContext context) async {
    const phoneUrl = 'tel:+1234567890';
    try {
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
        if (context.mounted) {
          SnackbarHelper.showSuccessSnackBar(
            context, 
            'Opening phone app to call support...',
          );
        }
      } else {
        throw 'Could not launch phone app';
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showErrorSnackBar(
          context,
          'Unable to open phone app. Please call +1234567890 manually.',
        );
      }
    }
  }

  void _emailSupport(BuildContext context) async {
    const emailUrl = 'mailto:support@thirikkale.com?subject=Driver Support Request';
    try {
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
        if (context.mounted) {
          SnackbarHelper.showSuccessSnackBar(
            context, 
            'Opening email app to contact support...',
          );
        }
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showErrorSnackBar(
          context,
          'Unable to open email app. Please email support@thirikkale.com manually.',
        );
      }
    }
  }

  void _startLiveChat(BuildContext context) {
    // This would typically open a chat interface
    SnackbarHelper.showInfoSnackBar(
      context, 
      'Live chat feature coming soon! We\'re working hard to bring you real-time support.',
    );
  }
}
