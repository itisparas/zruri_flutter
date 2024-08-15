import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zruri_flutter/controllers/ad_controller.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/services/firebase_storage_service.dart';
import 'package:zruri_flutter/core/utils/constants.dart';

class AdPage extends StatelessWidget {
  const AdPage({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseStorageService storageService = FirebaseStorageService();
    AdController adController =
        Get.put(AdController(adId: Get.parameters['adId']!));
    final CarouselController carouselController = CarouselController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Obx(
        () => adController.loading.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : SafeArea(
                child: CustomScrollView(
                  slivers: [
                    const SliverAppBar(),
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Stack(
                          children: [
                            CarouselSlider(
                              carouselController: carouselController,
                              items: adController.adDetails.value?['filepaths']
                                  .map<Widget>((image) {
                                return FutureBuilder(
                                  future: storageService.getDownloadUrl(
                                      path: image),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      return GestureDetector(
                                        onTap: () {},
                                        child: CachedNetworkImage(
                                          imageUrl: snapshot.data!,
                                          placeholder: (context, url) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                              ),
                                            );
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
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
                                autoPlayInterval:
                                    AppDefaults.adSpaceCarouselInterval,
                                autoPlayCurve: Curves.ease,
                                autoPlayAnimationDuration:
                                    AppDefaults.adSpaceCarouselAnimation,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  adController.currentImageIndex.value = index;
                                },
                              ),
                            ),
                            Positioned(
                              bottom: AppDefaults.margin,
                              right: AppDefaults.margin,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDefaults.padding / 2,
                                  vertical: AppDefaults.padding / 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '${adController.currentImageIndex.value + 1}/${adController.adDetails.value?['filepaths'].length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppDefaults.padding,
                          top: AppDefaults.padding,
                          right: AppDefaults.padding,
                          bottom: AppDefaults.padding / 4,
                        ),
                        child: Text(
                          adController.adDetails.value?['title'].toString() ??
                              'Ad title',
                          softWrap: true,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDefaults.padding,
                        ),
                        child: Text(
                          currency + adController.adDetails.value?['price'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDefaults.padding,
                          vertical: AppDefaults.padding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_outlined),
                                  Text(adController.adDetails.value?['location']
                                          ?['formattedAddress'] ??
                                      'Not available'),
                                ],
                              ),
                            ),
                            Text(DateFormat.yMMMd()
                                .format(
                                  adController.adDetails.value!['createdAt']
                                      .toDate(),
                                )
                                .toString()),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDefaults.padding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(
                              height: AppDefaults.margin / 2,
                            ),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(
                              height: AppDefaults.padding / 2,
                            ),
                            Text(
                              Uri.decodeComponent(
                                adController.adDetails.value!['description'],
                              ),
                            ),
                            const SizedBox(
                              height: AppDefaults.margin / 2,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: AppDefaults.margin / 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDefaults.margin,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppDefaults.padding),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppDefaults.radius),
                          ),
                          child: Obx(
                            () => adController.loadingUser.value
                                ? const SpinKitThreeBounce(
                                    color: AppColors.primary,
                                    size: 20,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            Theme.of(context).disabledColor,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            adController.advertiserDetails
                                                    .value?['displayname'] ??
                                                'Zruri user',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                              'member since ${DateFormat.yMMM().format(
                                                    adController
                                                        .advertiserDetails
                                                        .value!['createdAt']
                                                        .toDate(),
                                                  ).toString()}'),
                                        ],
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        color: AppColors.primary,
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                            Colors.white,
                                          ),
                                        ),
                                        onPressed: () async {
                                          await _launchCaller(
                                              'tel:${adController.advertiserDetails.value?['phonenumber']}');
                                        },
                                        icon: const Icon(Icons.call),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  _launchCaller(url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      log('cannot launch url');
    }
  }
}
