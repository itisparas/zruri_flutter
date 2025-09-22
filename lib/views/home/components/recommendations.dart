import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri/controllers/recommendations_controller.dart';
import 'package:zruri/core/components/listing_item.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/routes/app_route_names.dart';

class Recommendations extends StatelessWidget {
  Recommendations({super.key}) {
    Get.lazyPut(() => RecommendationsController());
  }

  @override
  Widget build(BuildContext context) {
    RecommendationsController recommendationsController =
        Get.find<RecommendationsController>();

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDefaults.padding,
        right: AppDefaults.padding,
        bottom: AppDefaults.padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: AppDefaults.padding),
          Obx(
            () => recommendationsController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : recommendationsController.recommendations.isEmpty
                ? const Center(child: Text('No recommendations available'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendationsController.recommendations.length,
                    itemBuilder: (context, index) {
                      final ad =
                          recommendationsController.recommendations[index];
                      return ListingItem(
                        id: ad.id,
                        image: ad.imageUrl,
                        price: ad.price,
                        title: ad.title,
                        timeline: DateFormat.yMMMd()
                            .format(ad.createdAt.toDate())
                            .toString(),
                        location: ad.location,
                        onTap: () => Get.toNamed(
                          '${AppRouteNames.adPageMainRoute}${ad.id}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.recommend, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'For you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
