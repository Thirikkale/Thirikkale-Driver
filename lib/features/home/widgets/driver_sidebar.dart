import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class DriverSidebar extends StatelessWidget {
  const DriverSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: AppDimensions.pageHorizontalPadding,
              right: AppDimensions.pageHorizontalPadding,
            ),
            decoration: const BoxDecoration(color: AppColors.primaryBlue),
            child: Stack(
              children: [
                Row(
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.white,
                              backgroundImage:
                                  authProvider.profilePictureUrl != null &&
                                          authProvider
                                              .profilePictureUrl!
                                              .isNotEmpty
                                      ? NetworkImage(
                                        authProvider.profilePictureUrl!,
                                      )
                                      : null,
                              child:
                                  (authProvider.profilePictureUrl == null ||
                                          authProvider
                                              .profilePictureUrl!
                                              .isEmpty)
                                      ? const Icon(
                                        Icons.person,
                                        size: 36,
                                        color: AppColors.primaryBlue,
                                      )
                                      : null,
                            ),

                            const SizedBox(height: 16),
                            Text(
                              authProvider.fullName,
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(Icons.star, color: AppColors.white),
                                SizedBox(width: 2.5),
                                Text(
                                  '5.00',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                // Verified Badge in top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: AppColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.verified_sharp,
                  title: 'Drive Pass',
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Trip History',
                  onTap: () => _navigateToTripHistory(context),
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Earnings',
                  onTap: () => _navigateToEarnings(context),
                ),
                _buildMenuItem(
                  icon: Icons.directions_car,
                  title: 'Vehicle Details',
                  onTap: () => _navigateToVehicleDetails(context),
                ),
                _buildMenuItem(
                  icon: Icons.list_alt_outlined,
                  title: 'Documents',
                  onTap: () => _navigateToVehicleDetails(context),
                ),
                _buildMenuItem(
                  icon: Icons.star,
                  title: 'Ratings & Reviews',
                  onTap: () => _navigateToRatings(context),
                ),
                _buildMenuItem(
                  icon: Icons.support_agent,
                  title: 'Support',
                  onTap: () => _navigateToSupport(context),
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () => _navigateToSettings(context),
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => _showLogoutDialog(context),
                  textColor: AppColors.error,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            child: Column(
              children: [
                const Divider(),
                Text(
                  'Thirikkale Driver',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary, size: 30),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateToTripHistory(BuildContext context) {
    Navigator.pop(context);
    // Navigate to trip history screen
    print('Navigate to Trip History');
  }

  void _navigateToEarnings(BuildContext context) {
    Navigator.pop(context);
    // Navigate to earnings screen
    print('Navigate to Earnings');
  }

  void _navigateToVehicleDetails(BuildContext context) {
    Navigator.pop(context);
    // Navigate to vehicle details screen
    print('Navigate to Vehicle Details');
  }

  void _navigateToRatings(BuildContext context) {
    Navigator.pop(context);
    // Navigate to ratings screen
    print('Navigate to Ratings');
  }

  void _navigateToSupport(BuildContext context) {
    Navigator.pop(context);
    // Navigate to support screen
    print('Navigate to Support');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context);
    // Navigate to settings screen
    print('Navigate to Settings');
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Thirikkale Driver'),
            content: const Text(
              'Thirikkale Driver app helps you connect with passengers and earn money by providing safe and reliable transportation services.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Perform logout
                  print('Logout');
                },
                child: Text('Logout', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }
}
