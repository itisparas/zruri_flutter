import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/components/footer.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/constants.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';
import 'package:zruri_flutter/views/home/components/ad_space.dart';
import 'package:zruri_flutter/views/home/components/categories.dart';
import 'package:zruri_flutter/views/home/components/recommendations.dart';

class HomePage extends GetView<AuthController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find<AuthController>();
    ScreenController screenController = Get.find<ScreenController>();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: Padding(
                padding: const EdgeInsets.all(AppDefaults.padding / 2),
                child: IconButton.filledTonal(
                  onPressed: () {
                    screenController.onChange(4);
                  },
                  icon: const Icon(Icons.menu),
                ),
              ),
              floating: false,
              title: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRouteNames.promptLocation);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppDefaults.padding / 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(kToolbarHeight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.all(AppDefaults.padding / 2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on_outlined),
                          ),
                          const SizedBox(
                            width: AppDefaults.padding / 2,
                          ),
                          Expanded(
                            child: Text(
                              authController.firebaseUser.value!.address,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dashed,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(
                            width: AppDefaults.padding / 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // title: Center(
              //   child: GestureDetector(
              //     onTap: () {
              //       Get.toNamed(AppRouteNames.promptLocation);
              //     },
              //     child: Container(
              //         padding: const EdgeInsets.all(AppDefaults.padding / 4),
              //         decoration: BoxDecoration(
              //           color: Theme.of(context).colorScheme.primaryContainer,
              //           borderRadius: BorderRadius.circular(kToolbarHeight),
              //         ),
              //         child: Flex(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           mainAxisSize: MainAxisSize.min,
              //           direction: Axis.horizontal,
              //           children: [
              //             Container(
              //               padding:
              //                   const EdgeInsets.all(AppDefaults.padding / 2),
              //               decoration: const BoxDecoration(
              //                 color: Colors.white,
              //                 shape: BoxShape.circle,
              //               ),
              //               child: const Icon(Icons.location_on_outlined),
              //             ),
              //             Container(
              //               padding: const EdgeInsets.only(
              //                 left: AppDefaults.padding / 2,
              //               ),
              //               child: Text(
              //                 authController.firebaseUser.value!.address,
              //                 overflow: TextOverflow.fade,
              //                 style: const TextStyle(
              //                   decoration: TextDecoration.underline,
              //                   decorationStyle: TextDecorationStyle.dashed,
              //                 ),
              //               ),
              //             ),
              //             Icon(
              //               Icons.arrow_drop_down_rounded,
              //               color: Theme.of(context).colorScheme.secondary,
              //             ),
              //             const SizedBox(
              //               width: AppDefaults.padding / 2,
              //             ),
              //           ],
              //         )),
              //   ),
              // ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding / 2),
                  child: IconButton.filledTonal(
                    onPressed: () => Get.toNamed(AppRouteNames.searchPage),
                    icon: const Icon(CupertinoIcons.search),
                  ),
                )
              ],
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: Get.width,
                width: Get.width,
                child: const AdSpace(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                width: Get.width,
                child: Categories(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                width: Get.width,
                child: const Recommendations(),
              ),
            ),
            const SliverToBoxAdapter(
              child: Footer(),
            )
          ],
        ),
      ),
    );
  }
}
