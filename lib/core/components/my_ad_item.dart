import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/controllers/my_ads_controller.dart';
import 'package:zruri_flutter/core/components/skeleton.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/services/firebase_storage_service.dart';
import 'package:zruri_flutter/core/services/my_ads_service.dart';

class MyAdItem extends StatelessWidget {
  final FirebaseStorageService storageService = FirebaseStorageService();
  final String image;
  final String price;
  final String title;
  final String timeline;
  final String id;

  MyAdItem({
    super.key,
    required this.image,
    required this.price,
    required this.title,
    required this.timeline,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    MyAdsService myAdsService = MyAdsService();
    MyAdsController myAdsController = Get.find<MyAdsController>();

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
                          return const Skeleton(
                            width: 100,
                            height: 100,
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      width: AppDefaults.margin / 2,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Posted on: '),
                              Text(timeline),
                            ],
                          ),
                          const SizedBox(
                            height: AppDefaults.margin / 2,
                          ),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(
                            height: AppDefaults.margin / 2,
                          ),
                          Text('Rs. $price'),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                          onPressed: () {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext buildContext) =>
                                  AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppDefaults.borderRadius,
                                ),
                                title: Text(AppMessages.enUs['modal']
                                    ['confirm.deactivate']['title']),
                                content: Text(AppMessages.enUs['modal']
                                    ['confirm.deactivate']['description']),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await myAdsService.deactivateAd(id);
                                      myAdsController.onInit();
                                      Navigator.pop(context, 'OK');
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility_off),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext buildContext) =>
                                  AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppDefaults.borderRadius,
                                ),
                                title: Text(AppMessages.enUs['modal']
                                    ['confirm.delete']['title']),
                                content: Text(AppMessages.enUs['modal']
                                    ['confirm.delete']['description']),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await myAdsService.deleteAd(id);
                                      myAdsController.onInit();
                                      Navigator.pop(context, 'OK');
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(CupertinoIcons.delete),
                          style: ButtonStyle(
                            foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.error,
                            ),
                            backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
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
