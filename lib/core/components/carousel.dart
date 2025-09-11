import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/core/services/firebase_storage_service.dart';
import 'package:zruri/models/listing_ad_model.dart';

class Carousel extends StatefulWidget {
  final List<ListingAdModel> data;

  const Carousel({super.key, required this.data});

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final FirebaseStorageService storageService = FirebaseStorageService();

    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          items: widget.data.asMap().entries.map((entry) {
            int index = entry.key;
            ListingAdModel adSpace = entry.value;

            return FutureBuilder<String?>(
              future: storageService.getDownloadUrl(path: adSpace.imageUrl!),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return _buildAdBanner(adSpace, snapshot.data!, index);
                } else {
                  return _buildLoadingBanner();
                }
              },
            );
          }).toList(),
          options: CarouselOptions(
            aspectRatio: 16 / 9,
            height: Get.width - 24,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: AppDefaults.adSpaceCarouselInterval,
            autoPlayCurve: Curves.easeInOut,
            autoPlayAnimationDuration: AppDefaults.adSpaceCarouselAnimation,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildIndicators(),
      ],
    );
  }

  Widget _buildAdBanner(ListingAdModel adSpace, String imageUrl, int index) {
    return GestureDetector(
      onTap: () {
        if (adSpace.id != null) {
          Get.toNamed('${AppRouteNames.adPageMainRoute}${adSpace.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildLoadingBanner(),
                errorWidget: (context, url, error) => _buildErrorBanner(),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Content Overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      adSpace.title ?? 'Featured Ad',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description or Additional Info
                    if (adSpace.description != null &&
                        adSpace.description!.isNotEmpty)
                      Text(
                        adSpace.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 2),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // Action Button or Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price or Category
                        if (adSpace.price != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '\$${adSpace.price}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        // View More Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.whiteLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.whiteBorder,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PROMOTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  Widget _buildLoadingBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SpinKitSpinningLines(color: AppColors.primary, size: 40),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.error_outline, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.data.asMap().entries.map((entry) {
        int index = entry.key;
        return GestureDetector(
          onTap: () {
            _carouselController.animateToPage(index);
          },
          child: Container(
            width: currentIndex == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: currentIndex == index
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
            ),
          ),
        );
      }).toList(),
    );
  }
}
