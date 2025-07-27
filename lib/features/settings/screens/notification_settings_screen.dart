import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/settings/widgets/settings_page_layout.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool newTrips = true;
  bool tripUpdates = true;
  bool earnings = true;
  bool promotions = false;
  bool appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return SettingsPageLayout(
      title: 'Notification Settings',
      children: [
        _buildSection(
          title: 'Trip Notifications',
          children: [
            _buildSwitchTile(
              title: 'New Trip Requests',
              subtitle: 'Get notified when new trips are available',
              value: newTrips,
              onChanged: (value) => setState(() => newTrips = value),
            ),
            _buildSwitchTile(
              title: 'Trip Updates',
              subtitle: 'Receive updates about your ongoing trips',
              value: tripUpdates,
              onChanged: (value) => setState(() => tripUpdates = value),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: 'Other Notifications',
          children: [
            _buildSwitchTile(
              title: 'Earnings Updates',
              subtitle: 'Get notified about your earnings and payments',
              value: earnings,
              onChanged: (value) => setState(() => earnings = value),
            ),
            _buildSwitchTile(
              title: 'Promotions & Offers',
              subtitle: 'Receive updates about special offers and promotions',
              value: promotions,
              onChanged: (value) => setState(() => promotions = value),
            ),
            _buildSwitchTile(
              title: 'App Updates',
              subtitle: 'Get notified about new app features and updates',
              value: appUpdates,
              onChanged: (value) => setState(() => appUpdates = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryBlue,
    );
  }
}
