import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/core/components/skeleton.dart';

class IntroPageBackgroundWrapper extends StatelessWidget {
  final String imageUrl;

  const IntroPageBackgroundWrapper({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return _IntroLoginBody(image: imageProvider);
      },
      placeholder: (context, url) => const Skeleton(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}

class _IntroLoginBody extends StatelessWidget {
  final ImageProvider image;

  const _IntroLoginBody({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black12.withOpacity(0.1),
                  Colors.black12,
                  Colors.black54,
                  Colors.black54,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        )
      ],
    );
  }
}
