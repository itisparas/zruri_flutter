import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/core/components/carousel.dart';
import 'package:zruri/views/home/controllers/ad_space_controller.dart';

class AdSpace extends StatelessWidget {
  const AdSpace({super.key});

  @override
  Widget build(BuildContext context) {
    final AdSpaceController controller = Get.put(
      AdSpaceController(),
      permanent: true,
    );

    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Carousel(data: controller.adSpaces.toList()),
      ),
    );
  }
}
