import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                Obx(() => myAdsController.myAds.isNotEmpty
                    ? Column(
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
                      )
                    : Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: Get.height * 0.4,
                              child: SvgPicture.asset('assets/svg/no-data.svg'),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'No ads published',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
