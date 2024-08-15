import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri_flutter/controllers/listing_controller.dart';
import 'package:zruri_flutter/core/components/my_ad_item.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class ListingPage extends StatelessWidget {
  final String genre = Get.parameters['genre'] ?? '';
  final String genreInfo = Get.parameters['genre_info'] ?? '';

  ListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    ListingController listingController =
        Get.put<ListingController>(ListingController());

    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(
              AppDefaults.padding / 2,
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: Text(
                        'Ads',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      floating: true,
                      pinned: true,
                    ),
                    Obx(
                      () {
                        if (listingController.ads.isEmpty &&
                            listingController.isLoading.value) {
                          return SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        } else if (listingController.ads.isEmpty) {
                          return const SliverFillRemaining(
                            child: Center(
                              child: Text('No ads found'),
                            ),
                          );
                        } else {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                print(index.toString());
                                if (index < listingController.ads.length) {
                                  final ad = listingController.ads[index];
                                  return MyAdItem(
                                      image: ad.imageUrl,
                                      price: ad.price,
                                      title: ad.title +
                                          listingController.hasMoreData.value
                                              .toString(),
                                      timeline: DateFormat.yMMMd()
                                          .format(
                                            ad.createdAt.toDate(),
                                          )
                                          .toString(),
                                      id: ad.id,
                                      active: ad.active,
                                      searchResult: true);
                                } else if (listingController
                                    .hasMoreData.value) {
                                  print('triggering load more ads');
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    // Trigger state changes here, after the build is complete
                                    listingController.loadMoreAds();
                                  });
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: Text('No more ads'),
                                  );
                                }
                              },
                              childCount: listingController.ads.length +
                                  (listingController.hasMoreData.value ? 1 : 0),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
