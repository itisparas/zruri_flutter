import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri_flutter/controllers/recommendations_controller.dart';
import 'package:zruri_flutter/core/components/listing_item.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class Recommendations extends StatelessWidget {

  Recommendations({super.key}) {
    Get.lazyPut(() => RecommendationsController());
  }

  @override
  Widget build(BuildContext context) {
    RecommendationsController recommendationsController =
        Get.find<RecommendationsController>();

    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For you',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: AppDefaults.padding / 4,
          ),
          Obx(
            () => recommendationsController.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : recommendationsController.recommendations.isEmpty
                    ? const Center(
                        child: Text('No recommendations available'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            recommendationsController.recommendations.length,
                        itemBuilder: (context, index) {
                          final ad =
                              recommendationsController.recommendations[index];
                          return ListingItem(
                            image: ad.imageUrl,
                            price: ad.price,
                            title: ad.title,
                            timeline: DateFormat.yMMMd()
                                .format(ad.createdAt.toDate())
                                .toString(),
                            location: ad.location,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
