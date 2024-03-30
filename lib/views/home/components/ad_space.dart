import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/views/home/components/carousel.dart';
import 'package:zruri_flutter/views/home/controllers/ad_space_controller.dart';

class AdSpace extends StatelessWidget {
  const AdSpace({super.key});

  @override
  Widget build(BuildContext context) {
    final AdSpaceController controller = Get.put(AdSpaceController());

    return Scaffold(
      body: Obx(
        () => Carousel(data: controller.adSpaces.toList()),
      ),
    );
  }
}
