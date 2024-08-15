import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri_flutter/controllers/listing_controller.dart';
import 'package:zruri_flutter/core/components/listing_ad_item.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class ListingPage extends StatelessWidget {
  ListingController listingController = Get.put<ListingController>(
      ListingController(
          Get.parameters['genre'] ?? '', Get.parameters['genre_info'] ?? ''));

  ListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Browse ads',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.filter_alt_outlined),
          //   onPressed: () {
          //     // Handle filter action
          //     _showFilterBottomSheet(context);
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // Handle sort action
              _showSortBottomSheet(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding / 2),
          child: Column(
            children: [
              Expanded(
                child: Obx(
                  () {
                    if (listingController.ads.isEmpty &&
                        listingController.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    } else if (listingController.ads.isEmpty) {
                      return Center(
                        child: Text(
                          'No ads found',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 18,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: listingController.ads.length +
                            (listingController.hasMoreData.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < listingController.ads.length) {
                            final ad = listingController.ads[index];
                            return ListingAdItem(
                                image: ad.imageUrl,
                                price: ad.price,
                                title: ad.title,
                                timeline: DateFormat.yMMMd()
                                    .format(ad.createdAt.toDate())
                                    .toString(),
                                id: ad.id,
                                location: ad.location,
                                description: ad.description);
                          } else if (listingController.hasMoreData.value) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              listingController.loadMoreAds();
                            });
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No more ads',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Ads',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Add your filter options here, for example:
              CheckboxListTile(
                title: const Text('Show Active Ads Only'),
                value: true, // Replace with your controller value
                onChanged: (value) {
                  // Handle filter logic here
                },
              ),
              CheckboxListTile(
                title: const Text('Show Ads with Images Only'),
                value: false, // Replace with your controller value
                onChanged: (value) {
                  // Handle filter logic here
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Apply filters
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDefaults.radius),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort ads',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Price: Low to High'),
                onTap: () {
                  // Handle sort logic here
                  listingController.selectedSortOption.value = 'price_asc';
                  listingController.resetAds();
                  listingController.fetchAds();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Price: High to Low'),
                onTap: () {
                  // Handle sort logic here
                  listingController.selectedSortOption.value = 'price_desc';
                  listingController.resetAds();
                  listingController.fetchAds();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Newest First'),
                onTap: () {
                  // Handle sort logic here
                  listingController.selectedSortOption.value = 'date_desc';
                  listingController.resetAds();
                  listingController.fetchAds();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Oldest First'),
                onTap: () {
                  // Handle sort logic here
                  listingController.selectedSortOption.value = 'date_asc';
                  listingController.resetAds();
                  listingController.fetchAds();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
