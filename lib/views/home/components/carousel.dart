import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/models/ad_space_model.dart';
import 'package:zruri_flutter/core/services/firebase_storage_service.dart';

class Carousel extends StatefulWidget {
  final List<AdSpaceModel> data;

  const Carousel({super.key, required this.data});

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final FirebaseStorageService storageService = FirebaseStorageService();

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: widget.data.map((adSpace) {
        return FutureBuilder<String?>(
          future: storageService.getDownloadUrl(path: adSpace.url!),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return GestureDetector(
                onTap: () {
                  if (adSpace.url != null) {
                    Get.toNamed(adSpace.url!);
                  }
                },
                child: CachedNetworkImage(
                  imageUrl: snapshot.data!,
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return const CircularProgressIndicator();
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
        autoPlayCurve: Curves.ease,
        autoPlayAnimationDuration: AppDefaults.adSpaceCarouselAnimation,
        enlargeCenterPage: true,
      ),
    );
  }
}
