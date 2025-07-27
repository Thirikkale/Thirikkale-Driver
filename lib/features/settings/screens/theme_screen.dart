import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/settings/widgets/settings_page_layout.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  String _selectedTheme = 'system'; // 'light', 'dark', or 'system'

  @override
  Widget build(BuildContext context) {
    return SettingsPageLayout(
      title: 'Theme',
      children: [
        Text(
          'Choose your preferred theme',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
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
            children: [
              _buildThemeOption(
                title: 'System Default',
                subtitle: 'Follow system theme',
                value: 'system',
                icon: Icons.brightness_auto,
              ),
              _buildThemeOption(
                title: 'Light Theme',
                subtitle: 'Light colors',
                value: 'light',
                icon: Icons.light_mode,
              ),
              _buildThemeOption(
                title: 'Dark Theme',
                subtitle: 'Dark colors',
                value: 'dark',
                icon: Icons.dark_mode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedTheme == value;
    return RadioListTile(
      title: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary),
          const SizedBox(width: 16),
          Text(title, style: AppTextStyles.bodyLarge),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      groupValue: _selectedTheme,
      onChanged: (value) {
        setState(() => _selectedTheme = value!);
        // TODO: Implement theme change
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to $title'),
          ),
        );
      },
      activeColor: AppColors.primaryBlue,
      selected: isSelected,
    );
  }
}
