import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/core/utils/bottom_sheet_helper.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: 'Support & Help', showBackButton: true,),
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
              context: context,
              title: 'Frequently Asked Questions',
              children: [
                _buildFAQItem(
                  context: context,
                  question: 'How do I go online to start receiving rides?',
                  answer: 'Tap the "Go Online" button on your home screen. Make sure your location is enabled and you have a stable internet connection.',
                ),
                _buildFAQItem(
                  context: context,
                  question: 'What documents do I need to drive?',
                  answer: 'You need a valid driver\'s license, vehicle registration, insurance documents, and a clear profile photo.',
                ),
                _buildFAQItem(
                  context: context,
                  question: 'How are my earnings calculated?',
                  answer: 'Your earnings are based on distance, time, and current demand. You can view detailed breakdowns in the Earnings section.',
                ),
                _buildFAQItem(
                  context: context,
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
    required BuildContext context,
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
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return ListTile(
      title: Text(
        question,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.help_outline,
        color: AppColors.primaryBlue,
      ),
      onTap: () => _showFAQDetails(context, question, answer),
    );
  }

  void _showFAQDetails(BuildContext context, String question, String answer) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'FAQ Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Answer',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        BottomSheetAction(
          text: 'Still Need Help?',
          isOutlined: true,
          onPressed: () => _showMoreHelpOptions(context),
        ),
        BottomSheetAction(
          text: 'Got it!',
          onPressed: () {
            SnackbarHelper.showSuccessSnackBar(
              context,
              'Glad we could help!',
            );
          },
        ),
      ],
    );
  }

  void _showMoreHelpOptions(BuildContext context) {
    final helpOptions = [
      const ActionSheetOption(
        title: 'Call Support',
        subtitle: 'Speak directly with our team',
        icon: Icons.phone,
        value: 'call',
      ),
      const ActionSheetOption(
        title: 'Send Email',
        subtitle: 'Email us your question',
        icon: Icons.email,
        value: 'email',
      ),
      const ActionSheetOption(
        title: 'Browse More FAQs',
        subtitle: 'Check other common questions',
        icon: Icons.quiz,
        value: 'faq',
      ),
    ];

    BottomSheetHelper.showActionSheet<String>(
      context: context,
      title: 'Additional Help Options',
      subtitle: 'Choose how you\'d like to get more help',
      options: helpOptions,
    ).then((selectedOption) {
      if (selectedOption != null) {
        switch (selectedOption) {
          case 'call':
            _callSupport(context);
            break;
          case 'email':
            _emailSupport(context);
            break;
          case 'faq':
            SnackbarHelper.showInfoSnackBar(
              context,
              'Scroll down to see more frequently asked questions!',
            );
            break;
        }
      }
    });
  }

  // Bottom sheet methods for help topics
  void _showGettingStartedDialog(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'Getting Started',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Thirikkale Driver! Here\'s how to get started:',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildStep('1', 'Complete your profile and upload required documents'),
          _buildStep('2', 'Wait for verification (usually 24-48 hours)'),
          _buildStep('3', 'Go online by tapping the "Go Online" button'),
          _buildStep('4', 'Accept ride requests and start earning!'),
        ],
      ),
      actions: [
        BottomSheetAction(
          text: 'Got it!',
          onPressed: () {
            SnackbarHelper.showSuccessSnackBar(
              context,
              'Great! You\'re ready to start your journey with Thirikkale!',
            );
          },
        ),
      ],
    );
  }

  void _showAcceptRidesDialog(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'How to Accept Rides',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow these steps to accept and complete rides:',
            style: AppTextStyles.bodyMedium,
          ),
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
      actions: [
        BottomSheetAction(
          text: 'Got it!',
          onPressed: () {
            SnackbarHelper.showSuccessSnackBar(
              context,
              'Now you know how to accept rides like a pro!',
            );
          },
        ),
      ],
      maxHeight: MediaQuery.of(context).size.height * 0.8,
    );
  }

  void _showEarningsDialog(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'Earnings & Payments',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Understanding your earnings:',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildStep('💰', 'Base fare + time + distance = total fare'),
          _buildStep('⏰', 'Surge pricing during high demand periods'),
          _buildStep('💳', 'Weekly payments directly to your bank account'),
          _buildStep('📊', 'View detailed earnings breakdown in the app'),
          _buildStep('🎯', 'Bonus opportunities for completing certain targets'),
        ],
      ),
      actions: [
        BottomSheetAction(
          text: 'Got it!',
          onPressed: () {
            SnackbarHelper.showInfoSnackBar(
              context,
              'Check your earnings screen to track your progress!',
            );
          },
        ),
      ],
    );
  }

  void _showGPSIssuesDialog(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'GPS & Location Issues',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To fix GPS and location problems:',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildStep('📍', 'Enable location permissions for the app'),
          _buildStep('🛰️', 'Ensure GPS is turned on in your phone settings'),
          _buildStep('🌐', 'Check your internet connection'),
          _buildStep('🔄', 'Restart the app if location seems inaccurate'),
          _buildStep('📱', 'Keep your phone in an area with clear sky view'),
        ],
      ),
      actions: [
        BottomSheetAction(
          text: 'Got it!',
          onPressed: () {
            SnackbarHelper.showInfoSnackBar(
              context,
              'Try these steps to improve your GPS accuracy!',
            );
          },
        ),
      ],
    );
  }

  void _showConnectionIssuesDialog(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'Connection Problems',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To fix network and connectivity issues:',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildStep('📶', 'Check your mobile data or WiFi connection'),
          _buildStep('🔄', 'Try switching between WiFi and mobile data'),
          _buildStep('✈️', 'Turn airplane mode on/off to reset connection'),
          _buildStep('📱', 'Restart your phone if issues persist'),
          _buildStep('📍', 'Move to an area with better signal strength'),
        ],
      ),
      actions: [
        BottomSheetAction(
          text: 'Got it!',
          onPressed: () {
            SnackbarHelper.showInfoSnackBar(
              context,
              'These tips should help resolve connection issues!',
            );
          },
        ),
      ],
    );
  }

  void _showVerificationDialog(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'Account Verification',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For successful account verification:',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildStep('📄', 'Upload clear photos of all required documents'),
          _buildStep('🆔', 'Ensure documents are valid and not expired'),
          _buildStep('📸', 'Take photos in good lighting without shadows'),
          _buildStep('✅', 'Double-check all information matches exactly'),
          _buildStep('⏳', 'Verification usually takes 24-48 hours'),
        ],
      ),
      actions: [
        BottomSheetAction(
          text: 'Got it!',
          onPressed: () {
            SnackbarHelper.showSuccessSnackBar(
              context,
              'Follow these tips for faster verification!',
            );
          },
        ),
      ],
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
    BottomSheetHelper.showConfirmationBottomSheet(
      context: context,
      title: 'Call Support',
      content: 'This will open your phone app to call our support team at +1234567890. Our team is available 24/7 to assist you.',
      icon: Icons.phone,
      confirmText: 'Call Now',
      cancelText: 'Cancel',
      confirmButtonColor: AppColors.success,
      onConfirm: () async {
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
      },
    );
  }

  void _emailSupport(BuildContext context) async {
    BottomSheetHelper.showConfirmationBottomSheet(
      context: context,
      title: 'Email Support',
      content: 'This will open your email app to send a message to our support team at support@thirikkale.com. Please include details about your issue.',
      icon: Icons.email,
      confirmText: 'Send Email',
      cancelText: 'Cancel',
      confirmButtonColor: AppColors.primaryBlue,
      onConfirm: () async {
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
      },
    );
  }

  void _startLiveChat(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'Live Chat Support',
      content: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Live Chat Coming Soon!',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re working hard to bring you real-time chat support. In the meantime, you can:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildStep('📞', 'Call us for immediate assistance'),
          _buildStep('📧', 'Send us an email with your questions'),
          _buildStep('❓', 'Check our FAQ section for quick answers'),
        ],
      ),
      actions: [
        BottomSheetAction(
          text: 'Call Support',
          isOutlined: true,
          onPressed: () => _callSupport(context),
        ),
        BottomSheetAction(
          text: 'Got it!',
          onPressed: () {
            SnackbarHelper.showInfoSnackBar(
              context, 
              'We\'ll notify you when live chat is available!',
            );
          },
        ),
      ],
    );
  }
}
