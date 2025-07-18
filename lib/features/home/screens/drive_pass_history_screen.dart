import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class DrivePassHistoryScreen extends StatelessWidget {
  const DrivePassHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'Uber',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.question_mark,
                color: AppColors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Drive Pass history',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // July 2025 Section
                  _buildMonthSection('July 2025', [
                    DrivePassHistoryItem(
                      dateRange: 'Jul 6 - Jul 6',
                      duration: '4 hours',
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // June 2025 Section
                  _buildMonthSection('June 2025', [
                    DrivePassHistoryItem(
                      dateRange: 'Jun 29 - Jun 29',
                      duration: '4 hours',
                    ),
                    DrivePassHistoryItem(
                      dateRange: 'Jun 21 - Jun 21',
                      duration: '4 hours',
                    ),
                    DrivePassHistoryItem(
                      dateRange: 'Jun 14 - Jun 14',
                      duration: '4 hours',
                    ),
                    DrivePassHistoryItem(
                      dateRange: 'Jun 10 - Jun 13',
                      duration: '3 days',
                    ),
                  ]),

                  const SizedBox(height: 40),

                  // Footer text
                  Text(
                    'Drive Pass history covers the last 6 months. Go to Earnings to see your trip history.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<DrivePassHistoryItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Text(
          month,
          style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // History items
        ...items.map((item) => _buildHistoryItem(item)),
      ],
    );
  }

  Widget _buildHistoryItem(DrivePassHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Handle item tap - could navigate to details
          print('Tapped on ${item.dateRange}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.dateRange,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.duration,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
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
}

class DrivePassHistoryItem {
  final String dateRange;
  final String duration;

  DrivePassHistoryItem({required this.dateRange, required this.duration});
}
