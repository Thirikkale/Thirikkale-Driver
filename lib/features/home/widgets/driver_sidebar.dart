import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/trip_history/screens/trip_history_screen.dart';
import 'package:thirikkale_driver/features/ratings_reviews/screens/ratings_screen.dart';
import 'package:thirikkale_driver/features/settings/screens/settings_screen.dart';

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
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Olivia Bennet',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Driver ID: DR001234',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Verified',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
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
      leading: Icon(
        icon,
        color: textColor ?? AppColors.textPrimary,
        size: 30,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateToTripHistory(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const TripHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
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
    // Navigate to Ratings and Reviews screen
    print('Navigate to Ratings & Reviews');
  }
   

  void _navigateToSupport(BuildContext context) {
    Navigator.pop(context);
    // Navigate to support screen
    print('Navigate to Support');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      builder: (context) => AlertDialog(
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
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
