import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/controllers/categories_controller.dart';
import 'package:zruri_flutter/core/constants/app_icons.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/constants/constants.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class PostAdPage extends StatelessWidget {
  final ScreenController screenController = Get.find();
  final CategoriesController categoriesController =
      Get.put(CategoriesController());
  final AppIcons appIcons = AppIcons();

  PostAdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                AppMessages.enUs['postingpage.title'],
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding,
                  vertical: AppDefaults.padding / 2,
                ),
                child: Text(
                  AppMessages.enUs['postingpage.choosecategory'],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            Obx(
              () => categoriesController.loading.value
                  ? const SliverToBoxAdapter(
                      child: CircularProgressIndicator(),
                    )
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.all(AppDefaults.padding),
                          child: IconButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                AppColors.scaffoldWithBoxBackground,
                              ),
                              shape: MaterialStateProperty.all(
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
                                  categoriesController.categories[index].name
                                      .toString()
                                      .replaceAll(RegExp(r'[^\w\s]+'), ' ')
                                      .capitalizeFirst!,
                                  style: Theme.of(context).textTheme.titleSmall,
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
      ),
    );
  }
}
