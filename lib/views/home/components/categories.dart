import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/controllers/categories_controller.dart';
import 'package:zruri_flutter/core/components/category_tile.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class Categories extends StatelessWidget {
  final ScreenController controller = Get.find();

  final CategoriesController categoriesController =
      Get.put(CategoriesController());

  Categories({super.key});

  @override
  Widget build(BuildContext context) {
    const icons = {"services": FontAwesomeIcons.bellConcierge};

    return SizedBox(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Browse categories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  controller.onChange(1);
                },
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text(
                  'view all',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
                ),
              )
            ],
          ),
          Obx(() => categoriesController.loading.value
              ? SizedBox(
                  height: AppDefaults.categoryTileWidth,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ))
              : categoriesController.categories.isEmpty
                  ? SizedBox(
                      height: AppDefaults.categoryTileWidth,
                      child: const Center(
                        child: Text('No categories found'),
                      ),
                    )
                  : SizedBox(
                      height: AppDefaults.categoryTileWidth + 16,
                      child: Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categoriesController.categories.length,
                              itemBuilder: (context, index) {
                                return CategoryTile(
                                  icon: Icon(icons['services'] ??
                                      FontAwesomeIcons.question),
                                  label: categoriesController
                                      .categories[index].name.capitalize!,
                                  onTap: () {
                                    Get.toNamed(AppRouteNames().categoryListing(
                                      categoriesController.categories[index].id,
                                    ));
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ))),
          // Row(
          //   children: [
          //     CategoryTile(
          //       icon: const Icon(
          //         FontAwesomeIcons.car,
          //       ),
          //       label: 'Cars',
          //       onTap: () {},
          //     ),
          //     SizedBox(
          //       width: AppDefaults.categoryTileGutterWidth,
          //     ),
          //     CategoryTile(
          //       icon: const Icon(
          //         FontAwesomeIcons.building,
          //       ),
          //       label: 'Properties',
          //       onTap: () {},
          //     ),
          //     SizedBox(
          //       width: AppDefaults.categoryTileGutterWidth,
          //     ),
          //     CategoryTile(
          //       icon: const Icon(
          //         FontAwesomeIcons.champagneGlasses,
          //       ),
          //       label: 'Events',
          //       onTap: () {},
          //     ),
          //     SizedBox(
          //       width: AppDefaults.categoryTileGutterWidth,
          //     ),
          //     CategoryTile(
          //       icon: const Icon(
          //         FontAwesomeIcons.briefcase,
          //       ),
          //       label: 'Jobs',
          //       onTap: () {},
          //     ),
          //   ],
          // ),
          const SizedBox(
            height: AppDefaults.margin / 2,
          ),
        ],
      ),
    ));
  }
}
