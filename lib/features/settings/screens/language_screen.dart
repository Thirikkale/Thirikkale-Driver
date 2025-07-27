import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/settings/widgets/settings_page_layout.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en'; // Default language code

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'si', 'name': 'Sinhala', 'nativeName': 'සිංහල'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
  ];

  @override
  Widget build(BuildContext context) {
    return SettingsPageLayout(
      title: 'Language',
      children: [
        Text(
          'Select your preferred language',
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
            children: _languages.map((language) {
              final isSelected = _selectedLanguage == language['code'];
              return RadioListTile(
                title: Text(
                  language['name']!,
                  style: AppTextStyles.bodyLarge,
                ),
                subtitle: Text(
                  language['nativeName']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: language['code']!,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  // TODO: Implement language change
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${language['name']}'),
                    ),
                  );
                },
                activeColor: AppColors.primaryBlue,
                selected: isSelected,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Note: The app will restart to apply language changes',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
