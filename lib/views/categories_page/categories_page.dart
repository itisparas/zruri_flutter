import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/controllers/categories_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/constants/app_icons.dart';
import 'package:zruri/core/constants/app_messages.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/views/entrypoint/controllers/screen_controller.dart';

class CategoriesPage extends StatelessWidget {
  final AppIcons appIcons = AppIcons();

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenController screenController = Get.find<ScreenController>();
    final CategoriesController categoriesController =
        Get.find<CategoriesController>();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    onPressed: () {
                      screenController.gotoPrevPage();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                    ),
                  ),
                  title: Text(
                    AppMessages.enUs['categoriespage.title'],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Obx(
                  () => categoriesController.loading.value
                      ? const SliverToBoxAdapter(
                          child: SizedBox(),
                        )
                      : SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding:
                                  const EdgeInsets.all(AppDefaults.padding / 2),
                              child: IconButton(
                                onPressed: () => Get.toNamed(
                                  AppRouteNames().categoryListing(
                                    categoriesController.categories[index].id,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    AppColors.scaffoldWithBoxBackground,
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: AppDefaults.borderRadius,
                                    ),
                                  ),
                                ),
                                icon: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    appIcons.categoriesIcon.containsKey(
                                            categoriesController
                                                .categories[index].name)
                                        ? appIcons.categoriesIcon[
                                            categoriesController
                                                .categories[index].name]
                                        : Text(categoriesController
                                            .categories[index].name),
                                    const SizedBox(
                                      height: AppDefaults.padding / 2,
                                    ),
                                    Text(
                                      categoriesController
                                          .categories[index].name
                                          .toString()
                                          .replaceAll(RegExp(r'[^\w\s]+'), ' ')
                                          .capitalizeFirst!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            childCount: categoriesController.categories.length,
                          ),
                        ),
                ),
              ],
            ),
            Obx(
              () => categoriesController.loading.value
                  ? const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
