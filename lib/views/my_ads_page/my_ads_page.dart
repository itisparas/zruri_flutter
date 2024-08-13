import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri_flutter/controllers/my_ads_controller.dart';
import 'package:zruri_flutter/core/components/my_ad_item.dart';
import 'package:zruri_flutter/core/constants/constants.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class MyAdsPage extends StatelessWidget {
  const MyAdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenController screenController = Get.find();
    MyAdsController myAdsController = Get.put(MyAdsController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My ads',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            screenController.gotoPrevPage();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: myAdsController.myAds
                        .map(
                          (element) => MyAdItem(
                            image: element.imageUrl,
                            price: element.price.toString(),
                            title: element.title,
                            timeline: DateFormat.yMMMd()
                                .format(
                                  element.createdAt.toDate(),
                                )
                                .toString(),
                            id: element.id,
                          ),
                        )
                        .toList(),
                    // children: [
                    //   ListingItem(
                    //     image: 'pexels-binyamin-mellish-186077.jpg',
                    //     price: '10,000',
                    //     title:
                    //         'Maruti Suzuki Wagon-R 2014 model first-owner perfect condition',
                    //     timeline: 'Today',
                    //     location: 'Gurugram, HR',
                    //   ),
                    //   Text(myAdsController.myAds.toString()),
                    // ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
