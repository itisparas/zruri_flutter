import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/constants/app_messages.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/views/location_page/controllers/location_controller.dart';

class PromptLocation extends StatelessWidget {
  const PromptLocation({super.key});

  @override
  Widget build(BuildContext context) {
    LocationController promptLocationController = Get.put(LocationController());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: Get.height * 0.4,
              child: SvgPicture.asset('assets/svg/prompt-location.svg'),
            ),
            const SizedBox(height: 20),
            Text(
              AppMessages.enUs['prompt.location.title'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: Get.width * .8,
              child: Text(
                AppMessages.enUs['prompt.location.description'],
                textAlign: TextAlign.center,
                // style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppDefaults.padding / 2,
                left: AppDefaults.padding,
                right: AppDefaults.padding,
              ),
              child: Obx(
                () => promptLocationController.loading.value
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await promptLocationController.updateLocation(
                                  determinePosition: true,
                                );
                              },
                              icon: const Icon(Icons.location_on_sharp),
                              label: const Text('Nearby deals'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                Get.offAndToNamed(
                                  AppRouteNames.inputManualLocation,
                                );
                              },
                              child: const Text(
                                'Set location manually',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
