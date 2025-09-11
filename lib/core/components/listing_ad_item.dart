import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:zruri/core/components/skeleton.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/services/firebase_storage_service.dart';

class ListingAdItem extends StatelessWidget {
  final FirebaseStorageService storageService = FirebaseStorageService();

  final String image;
  final String price;
  final String title;
  final String timeline;
  final String id;
  final String location;
  final String description;

  ListingAdItem({
    super.key,
    required this.image,
    required this.price,
    required this.title,
    required this.timeline,
    required this.id,
    required this.location,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: GestureDetector(
        onTap: () => Get.toNamed('/ad/$id'),
        child: Card(
          clipBehavior: Clip.hardEdge,
          elevation: 1,
          color: Colors.white,
          surfaceTintColor: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: AppDefaults.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: storageService.getDownloadUrl(path: image),
                      builder: (context, AsyncSnapshot<String?> urlSnapshot) {
                        if (urlSnapshot.connectionState ==
                                ConnectionState.done &&
                            urlSnapshot.hasData) {
                          return ClipRRect(
                            borderRadius: AppDefaults.borderRadius,
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: CachedNetworkImage(
                                imageUrl: urlSnapshot.data!,
                                placeholder: (context, url) =>
                                    const SpinKitSpinningCircle(
                                      color: AppColors.primary,
                                    ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        } else {
                          return const Skeleton(width: 100, height: 100);
                        }
                      },
                    ),
                    const SizedBox(width: AppDefaults.margin / 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text('\$$price'),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppDefaults.margin / 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                size: 16,
                                color: AppColors.placeholder,
                              ),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
