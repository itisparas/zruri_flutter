import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

// Report reasons enum
enum ReportReason {
  spam('Spam or Misleading', Icons.warning_amber),
  inappropriate('Inappropriate Content', Icons.block),
  scam('Suspected Scam', Icons.error_outline),
  duplicate('Duplicate Listing', Icons.copy),
  wrongCategory('Wrong Category', Icons.category_outlined),
  soldItem('Item Already Sold', Icons.check_circle_outline),
  other('Other', Icons.more_horiz);

  final String label;
  final IconData icon;
  const ReportReason(this.label, this.icon);
}

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
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, adController),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Report Ad'),
                ],
              ),
            ),
          ],
        ),
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
        _showReportDialog(adController);
        break;
    }
  }

  void _showReportDialog(AdController adController) {
    final Rx<String?> selectedReason = Rx<String?>(null);
    final TextEditingController additionalDetailsController =
        TextEditingController();
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flag, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Report Ad'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Why are you reporting this ad?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ...ReportReason.values.map((reason) {
                return Obx(
                  () => RadioListTile<String>(
                    value: reason.name,
                    groupValue: selectedReason.value,
                    onChanged: isSubmitting.value
                        ? null
                        : (value) => selectedReason.value = value,
                    title: Row(
                      children: [
                        Icon(reason.icon, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Expanded(child: Text(reason.label)),
                      ],
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: Colors.red,
                  ),
                );
              }),
              const SizedBox(height: 16),
              TextField(
                controller: additionalDetailsController,
                enabled: !isSubmitting.value,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional details (optional)',
                  hintText: 'Please provide more information...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSubmitting.value ? null : () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: selectedReason.value != null && !isSubmitting.value
                  ? () async {
                      isSubmitting.value = true;
                      try {
                        final success = await _submitReport(
                          adController,
                          selectedReason.value!,
                          additionalDetailsController.text.trim(),
                        );
                        isSubmitting.value = false;

                        if (success) {
                          log('Attempting to close dialog...');
                          // Close the dialog
                          Navigator.of(Get.overlayContext!).pop();
                          log('Dialog close attempted');
                        }
                      } catch (e) {
                        log('Error in submit handler: $e');
                        isSubmitting.value = false;
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: isSubmitting.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Submit Report'),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _submitReport(
    AdController adController,
    String reason,
    String additionalDetails,
  ) async {
    try {
      log('Starting report submission...');
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        log('User not logged in');
        Get.snackbar(
          'Error',
          'You must be logged in to report an ad',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final adId = Get.parameters['adId']!;
      final adData = adController.adDetails.value;
      final adOwnerId = adData?['user'];

      log('Ad ID: $adId, Owner: $adOwnerId');

      // Check if user already reported this ad
      log('Checking for existing reports...');
      final existingReport = await FirebaseFirestore.instance
          .collection('ad_reports')
          .where('adId', isEqualTo: adId)
          .where('reportedBy', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (existingReport.docs.isNotEmpty) {
        log('User already reported this ad');
        Get.snackbar(
          'Already Reported',
          'You have already reported this ad',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true; // Return true to close dialog
      }

      // Create report document
      log('Creating report document...');
      final reportRef = FirebaseFirestore.instance
          .collection('ad_reports')
          .doc();
      await reportRef.set({
        'adId': adId,
        'adTitle': adData?['title'],
        'adOwnerId': adOwnerId,
        'reportedBy': currentUser.uid,
        'reporterName': currentUser.displayName ?? 'Anonymous',
        'reason': reason,
        'reasonLabel': ReportReason.values
            .firstWhere((r) => r.name == reason)
            .label,
        'additionalDetails': additionalDetails,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, reviewed, resolved
      });

      // Update ad spam count
      log('Updating ad spam count...');
      final adRef = FirebaseFirestore.instance.collection('ads').doc(adId);
      await adRef.set({
        'spamReportCount': FieldValue.increment(1),
        'lastReportedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update user spam count
      log('Updating user spam count...');
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(adOwnerId);
      await userRef.set({
        'adsReportedAsSpam': FieldValue.increment(1),
      }, SetOptions(merge: true));

      log('Report submitted successfully!');
      Get.snackbar(
        'Report Submitted',
        'Thank you for your report. We will review it shortly.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      log('Error submitting report: $e');
      Get.snackbar(
        'Error',
        'Failed to submit report. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
