import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late ScrollController _scrollController;
  bool _isVisible = true;
  int _selectedFilter = 0; // 0 for "All", 1-5 for star ratings

  // All reviews data
  final List<Map<String, dynamic>> _allReviews = [
    {
      'name': 'Christain Allister',
      'rating': 5.0,
      'timeAgo': '1d',
      'review':
          'Excellent service! The driver was very professional and arrived on time. The vehicle was clean and comfortable. Highly recommend this service to everyone.',
    },
    {
      'name': 'James Carters',
      'rating': 4.0,
      'timeAgo': '2d',
      'review':
          'Good experience overall. Driver was friendly and the ride was smooth. Only minor issue was that pickup took a bit longer than expected.',
    },
    {
      'name': 'Sophie Harris',
      'rating': 3.0,
      'timeAgo': '3d',
      'review':
          'Average service. The ride was okay but the driver seemed to be in a hurry. Vehicle was decent but could have been cleaner.',
    },
    {
      'name': 'Lucky Carter',
      'rating': 5.0,
      'timeAgo': '4d',
      'review':
          'Amazing experience! Very punctual, safe driving, and excellent customer service. Will definitely use this service again.',
    },
    {
      'name': 'Maria Rodriguez',
      'rating': 4.0,
      'timeAgo': '5d',
      'review':
          'Great service with professional drivers. The app is easy to use and booking was seamless. Vehicle was comfortable and clean.',
    },
    {
      'name': 'David Chen',
      'rating': 2.0,
      'timeAgo': '6d',
      'review':
          'Had some issues with the service. Driver was late and the vehicle had some cleanliness issues. Customer support was helpful though.',
    },
    {
      'name': 'Emma Thompson',
      'rating': 5.0,
      'timeAgo': '1w',
      'review':
          'Outstanding service! Professional driver, clean vehicle, and excellent communication throughout the journey. Highly recommended.',
    },
    {
      'name': 'Michael Brown',
      'rating': 4.0,
      'timeAgo': '1w',
      'review':
          'Very good experience. Driver was courteous and knowledgeable about the area. Smooth ride and fair pricing.',
    },
    {
      'name': 'Lisa Anderson',
      'rating': 3.0,
      'timeAgo': '2w',
      'review':
          'Decent service but there is room for improvement. The ride was comfortable but communication could have been better.',
    },
    {
      'name': 'Robert Wilson',
      'rating': 5.0,
      'timeAgo': '2w',
      'review':
          'Exceptional service from start to finish. Professional, punctual, and reliable. The vehicle was spotless and the ride was very comfortable.',
    },
    {
      'name': 'Jennifer Lee',
      'rating': 1.0,
      'timeAgo': '3w',
      'review':
          'Very disappointing experience. Driver was rude and the vehicle was not clean. Would not recommend this service.',
    },
    {
      'name': 'Alex Johnson',
      'rating': 2.0,
      'timeAgo': '3w',
      'review':
          'Service was below expectations. Had to wait longer than expected and communication was poor.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold =
        50.0; // Reduced scroll threshold for better responsiveness

    if (_scrollController.offset > threshold && _isVisible) {
      setState(() {
        _isVisible = false;
      });
    } else if (_scrollController.offset <= threshold && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  // Filter reviews based on selected rating
  List<Map<String, dynamic>> _getFilteredReviews() {
    if (_selectedFilter == 0) {
      // Show all reviews
      return _allReviews;
    } else {
      // Filter by selected star rating
      return _allReviews
          .where((review) => review['rating'].floor() == _selectedFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with custom title and back button
      appBar: CustomAppbarName(
        title: 'Reviews & Ratings',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Animated Rating Summary Section - completely hidden when scrolling
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isVisible ? null : 0,
            child: AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Two Column Layout
                    Row(
                      children: [
                        // Left Column - Rating Info
                        Expanded(
                          child: Column(
                            children: [
                              // Overall Rating
                              Text(
                                '4.0',
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ), // Using theme primary blue
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Star Rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...List.generate(
                                    4,
                                    (index) => const Icon(
                                      Icons.star,
                                      color:
                                          AppColors
                                              .warning, // Using theme warning color for stars
                                      size: 24,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star_border,
                                    color: AppColors.grey,
                                    size: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '3,123 reviews',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Right Column - Rating Distribution
                        Expanded(child: _buildRatingDistribution()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Filter Buttons
                    _buildFilterButtons(),
                  ],
                ),
              ),
            ),
          ),

          // Reviews List - takes full screen when rating section is hidden
          Expanded(
            child: Column(
              children: [
                // Comments header - hidden when scrolling
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isVisible ? 64 : 0,
                  child: AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.tune,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_getFilteredReviews().length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Reviews list - takes full available space
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      ..._getFilteredReviews()
                          .map(
                            (review) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildReviewItem(
                                name: review['name']!,
                                rating: review['rating']!,
                                timeAgo: review['timeAgo']!,
                                review: review['review']!,
                                avatarUrl: null,
                              ),
                            ),
                          )
                          .toList(),
                      const SizedBox(height: 100), // Space at bottom
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All button
          _buildFilterButton(
            label: 'All',
            isSelected: _selectedFilter == 0,
            onTap: () {
              setState(() {
                _selectedFilter = 0;
              });
            },
          ),
          const SizedBox(width: 8),
          // Star filter buttons
          ...List.generate(5, (index) {
            int starCount = 5 - index; // 5, 4, 3, 2, 1
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterButton(
                label: '$starCount',
                icon: Icons.star,
                isSelected: _selectedFilter == starCount,
                onTap: () {
                  setState(() {
                    _selectedFilter = starCount;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && isSelected) ...[
              Icon(icon, size: 14, color: AppColors.white),
              const SizedBox(width: 3),
            ] else if (icon != null && !isSelected) ...[
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution() {
    final ratings = [
      {'stars': 5, 'percentage': '40%', 'value': 0.4},
      {'stars': 4, 'percentage': '44%', 'value': 0.44},
      {'stars': 3, 'percentage': '23%', 'value': 0.23},
      {'stars': 2, 'percentage': '20%', 'value': 0.2},
      {'stars': 1, 'percentage': '5%', 'value': 0.05},
    ];

    return Column(
      children:
          ratings.map((rating) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  // Star icon
                  Icon(Icons.star, color: AppColors.warning, size: 16),
                  const SizedBox(width: 4),
                  // Star number
                  Text(
                    '${rating['stars']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Progress bar
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: rating['value'] as double,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                AppColors
                                    .primaryBlue, // Using theme primary blue
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Percentage
                  Text(
                    rating['percentage'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required double rating,
    required String timeAgo,
    required String review,
    String? avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.grey,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child:
                    avatarUrl == null
                        ? Text(
                          name[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              // Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Star Rating
                    Row(
                      children: List.generate(5, (index) {
                        if (index < rating.floor()) {
                          return Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 16,
                          );
                        } else if (index < rating && rating % 1 != 0) {
                          return Icon(
                            Icons.star_half,
                            color: AppColors.warning,
                            size: 16,
                          );
                        } else {
                          return Icon(
                            Icons.star_border,
                            color: AppColors.grey,
                            size: 16,
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
              // Time ago
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review Text
          Text(
            review,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
