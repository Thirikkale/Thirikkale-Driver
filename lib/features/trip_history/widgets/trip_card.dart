import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class TripCard extends StatelessWidget {
  const TripCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LKR 759.74', style: AppTextStyles.heading3),
                Text('12:51 PM', 
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 8),
                Text('Cash Collected',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, size: 12),
                    Container(
                      width: 2,
                      height: 30,
                      color: AppColors.textSecondary,
                    ),
                    const Icon(Icons.location_on, color: AppColors.error),
                  ],
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kandy - Colombo Rd Peliyagoda LK',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 16),
                      Text('Katrishmetra Colombo 01000, LK',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Trip • 39 min 41 sec • 8.10 km',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary
                )),
          ],
        ),
      ),
    );
  }
}