import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zruri/controllers/ad_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/core/services/firebase_storage_service.dart';
import 'package:zruri/core/utils/constants.dart';
import 'package:zruri/main.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class AdPage extends StatelessWidget {
  AdPage({super.key});

  final String previousRoute = Get.previousRoute;

  @override
  Widget build(BuildContext context) {
    FirebaseStorageService storageService = FirebaseStorageService();
    AdController adController = Get.put(
      AdController(adId: Get.parameters['adId']!),
    );
    final CarouselSliderController carouselController =
        CarouselSliderController();

    return Scaffold(
      body: Obx(
        () => adController.loading.value
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, adController),
                  _buildImageCarousel(
                    context,
                    adController,
                    carouselController,
                    storageService,
                  ),
                  _buildContentSection(context, adController),
                ],
              ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AdController adController) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          onPressed: () => _shareAd(context, adController),
          icon: const Icon(Icons.share_outlined),
        ),
        // PopupMenuButton<String>(
        //   onSelected: (value) => _handleMenuAction(value, adController),
        //   itemBuilder: (context) => [
        //     const PopupMenuItem(
        //       value: 'report',
        //       child: Row(
        //         children: [
        //           Icon(Icons.flag_outlined),
        //           SizedBox(width: 8),
        //           Text('Report Ad'),
        //         ],
        //       ),
        //     ),
        //     const PopupMenuItem(
        //       value: 'save',
        //       child: Row(
        //         children: [
        //           Icon(Icons.bookmark_border),
        //           SizedBox(width: 8),
        //           Text('Save Ad'),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildImageCarousel(
    BuildContext context,
    AdController adController,
    CarouselSliderController carouselController,
    FirebaseStorageService storageService,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        height: Get.width,
        child: Stack(
          children: [
            CarouselSlider(
              carouselController: carouselController,
              items: adController.adDetails.value?['filepaths'].map<Widget>((
                image,
              ) {
                return FutureBuilder(
                  future: storageService.getDownloadUrl(path: image),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return GestureDetector(
                        onTap: () =>
                            _showImageFullScreen(context, snapshot.data!),
                        child: Container(
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
              options: CarouselOptions(
                aspectRatio: 1,
                height: Get.width,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: AppDefaults.adSpaceCarouselInterval,
                autoPlayCurve: Curves.easeInOut,
                autoPlayAnimationDuration: AppDefaults.adSpaceCarouselAnimation,
                onPageChanged: (index, reason) {
                  adController.currentImageIndex.value = index;
                },
              ),
            ),

            // Image counter
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${adController.currentImageIndex.value + 1}/${adController.adDetails.value?['filepaths'].length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Image navigation dots
            if (adController.adDetails.value?['filepaths'].length > 1)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    adController.adDetails.value?['filepaths'].length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: adController.currentImageIndex.value == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, AdController adController) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildTitleAndPrice(context, adController),
            _buildLocationAndStats(context, adController),
            _buildDescription(context, adController),
            _buildSellerInfo(context, adController),
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndPrice(BuildContext context, AdController adController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            adController.adDetails.value?['title'].toString() ?? 'Ad title',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '$currency${adController.adDetails.value?['price']}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndStats(
    BuildContext context,
    AdController adController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    adController
                            .adDetails
                            .value?['location']?['formattedAddress'] ??
                        'Location not available',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.visibility_outlined,
                  '${adController.adDetails.value?['views'] ?? 1} views',
                ),
                Container(width: 1, height: 20, color: Colors.grey[300]),
                _buildStatItem(
                  context,
                  Icons.calendar_today_outlined,
                  'Posted ${DateFormat.MMMd().format(adController.adDetails.value?['createdAt'].toDate())}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, AdController adController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              Uri.decodeComponent(adController.adDetails.value!['description']),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(BuildContext context, AdController adController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
        ),
        child: Obx(
          () => adController.loadingUser.value
              ? const Center(
                  child: SpinKitThreeBounce(color: AppColors.primary, size: 20),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seller Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adController
                                        .advertiserDetails
                                        .value?['displayname'] ??
                                    'Zruri User',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Member since ${DateFormat.yMMM().format(adController.advertiserDetails.value!['createdAt'].toDate())}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _initiateChat(context, adController),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Start Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _shareAd(BuildContext context, AdController adController) {
    try {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final adData = adController.adDetails.value;
      final String shareText =
          '''
🏷️ Check out this amazing deal!

📱 ${adData?['title'] ?? 'Great Deal'}
💰 $currency${adData?['price']}
📍 ${adData?['location']?['formattedAddress'] ?? 'Location not specified'}

View details: https://zruri.dzrv.digital/listing/${Get.parameters['adId']}

#Zruri #Marketplace #Deal
      '''
              .trim();

      SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: adData?['title'] ?? 'Check out this deal!',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to share at the moment',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _initiateChat(BuildContext context, AdController adController) {
    final sellerId = adController.adDetails.value!['user'];
    final sellerName =
        adController.advertiserDetails.value?['displayname'] ?? 'Seller';
    final adId = Get.parameters['adId'];
    final adTitle = adController.adDetails.value?['title'];

    if (sellerId == auth.currentUser?.uid) {
      Get.snackbar(
        'Error',
        'You cannot chat with yourself',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (sellerId != null) {
      Get.toNamed(
        AppRouteNames.chatPage,
        arguments: {
          'sellerId': sellerId,
          'sellerName': sellerName,
          'adId': adId,
          'adTitle': adTitle,
        },
      );
    } else {
      Get.snackbar(
        'Error',
        'Unable to start chat at the moment',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleMenuAction(String action, AdController adController) {
    switch (action) {
      case 'report':
        _showReportDialog();
        break;
      case 'save':
        _saveAd(adController);
        break;
    }
  }

  void _showReportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Report Ad'),
        content: const Text('Are you sure you want to report this ad?'),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(previousRoute),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.toNamed(previousRoute);
              Get.snackbar(
                'Reported',
                'Thank you for your report. We will review it.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _saveAd(AdController adController) {
    // Implement save functionality
    Get.snackbar(
      'Saved',
      'Ad has been saved to your favorites',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
