import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/services/firebase_storage_service.dart';
import 'package:share_plus/share_plus.dart';

class ListingItem extends StatelessWidget {
  final FirebaseStorageService storageService = FirebaseStorageService();
  final String id;
  final String image;
  final String price;
  final String title;
  final String timeline;
  final String location;
  final bool? isFeatured;
  final VoidCallback? onTap;

  ListingItem({
    super.key,
    required this.id,
    required this.image,
    required this.price,
    required this.title,
    required this.timeline,
    required this.location,
    this.isFeatured = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDefaults.margin),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context),
              _buildContentSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          // Main Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: FutureBuilder(
              future: storageService.getDownloadUrl(path: image),
              builder: (context, AsyncSnapshot<String?> urlSnapshot) {
                if (urlSnapshot.connectionState == ConnectionState.done &&
                    urlSnapshot.hasData) {
                  return CachedNetworkImage(
                    imageUrl: urlSnapshot.data!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImageError(),
                  );
                } else {
                  return _buildImagePlaceholder();
                }
              },
            ),
          ),

          // Gradient overlay for better text visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),

          // Featured Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, size: 12, color: Colors.white),
                  SizedBox(width: 2),
                  Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Share Button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => {_shareListingItem(context)},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.whiteLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.share_outlined,
                  size: 18,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),

          // Price Tag
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '\$$price',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Share functionality
  void _shareListingItem(BuildContext context) async {
    try {
      // Create a deep link to your listing
      String shareUrl = 'https://app-zruri.web.app/listing/$id';

      // If you have custom deep links or use Firebase Dynamic Links
      // shareUrl = await _createDynamicLink();

      String shareText =
          '''
🏷️ Check out this amazing deal!

📱 $title
💰 \$$price
📍 $location
⏰ Posted $timeline

View more details: $shareUrl

#Zruri #Marketplace #Deal'''
              .trim();

      // Get the widget's render box for positioning the share sheet on tablets
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final Rect sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.zero;

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: title,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );

      // Optional: Track sharing analytics
      FirebaseAnalytics.instance.logShare(
        contentType: 'listing',
        itemId: id,
        method: 'share_button',
      );
    } catch (e) {
      // Handle error gracefully
      Get.snackbar(
        'Error',
        'Unable to share at the moment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Create Firebase Dynamic Link for sharing
  // Future<String> _createDynamicLink(String id) async {
  //   try {
  //     final dynamicLinkParams = DynamicLinkParameters(
  //       link: Uri.parse('https://app-zruri.web.app/'),
  //       uriPrefix: 'https://yourapp.page.link',
  //       androidParameters: const AndroidParameters(
  //         packageName: 'com.yourapp.zruri',
  //         minimumVersion: 0,
  //       ),
  //       iosParameters: const IOSParameters(
  //         bundleId: 'com.yourapp.zruri',
  //         minimumVersion: '0',
  //       ),
  //       socialMetaTagParameters: SocialMetaTagParameters(
  //         title: title.isNotEmpty ? title : 'Check out this listing',
  //         description: 'Check out this amazing deal for only \$$price in $location',
  //         imageUrl: Uri.parse(image),
  //       ),
  //     );

  //     final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance
  //         .buildShortLink(dynamicLinkParams);

  //     return shortLink.shortUrl.toString();
  //   } catch (e) {
  //     debugPrint('Error creating dynamic link: $e');
  //     // Fallback to a simple URL if dynamic link fails
  //     return 'https://yourapp.com/listing/$id';
  //   }
  // }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Timeline Row
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildTimelineChip(),
            ],
          ),

          const SizedBox(height: 12),

          // Location Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        timeline,
        style: TextStyle(
          color: AppColors.grayLightText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: SpinKitSpinningCircle(color: AppColors.primary, size: 40),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
