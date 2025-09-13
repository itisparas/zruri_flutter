// lib/views/profile/components/profile_stats.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/controllers/my_ads_controller.dart';
import 'package:zruri/controllers/profile_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';

class ProfileStats extends StatelessWidget {
  final ProfileController profileController;
  final MyAdsController myAdsController;

  const ProfileStats({
    super.key,
    required this.profileController,
    required this.myAdsController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(() {
        final totalAds = myAdsController.myAds.length;
        final activeAds = myAdsController.myAds.where((ad) => ad.active).length;
        final inactiveAds = totalAds - activeAds;

        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Ads',
                totalAds.toString(),
                Icons.inventory_2_outlined,
                AppColors.primary,
              ),
            ),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            Expanded(
              child: _buildStatItem(
                'Active',
                activeAds.toString(),
                Icons.visibility_outlined,
                Colors.green,
              ),
            ),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            Expanded(
              child: _buildStatItem(
                'Inactive',
                inactiveAds.toString(),
                Icons.visibility_off_outlined,
                Colors.orange,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
