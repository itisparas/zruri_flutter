import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/services/firebase_storage_service.dart';

class ListingItem extends StatelessWidget {
  final FirebaseStorageService storageService = FirebaseStorageService();
  final String image;
  final String price;
  final String title;
  final String timeline;
  final String location;

  ListingItem({
    super.key,
    required this.image,
    required this.price,
    required this.title,
    required this.timeline,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDefaults.margin / 2),
      child: SizedBox(
        width: Get.width,
        child: Card(
          color: Colors.white,
          surfaceTintColor: Theme.of(context).colorScheme.primaryContainer,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: storageService.getDownloadUrl(
                  path: image,
                ),
                builder: (context, AsyncSnapshot<String?> urlSnapshot) {
                  if (urlSnapshot.connectionState == ConnectionState.done &&
                      urlSnapshot.hasData) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(
                  AppDefaults.padding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Rs. $price',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Text(timeline)
                      ],
                    ),
                    const SizedBox(
                      height: AppDefaults.padding / 2,
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(
                      height: AppDefaults.padding / 2,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined),
                        const SizedBox(
                          width: AppDefaults.padding / 4,
                        ),
                        Text(location),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
