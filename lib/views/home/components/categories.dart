import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/components/category_tile.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class Categories extends StatelessWidget {
  final ScreenController controller = Get.find();

  Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(75),
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding / 2),
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
          Row(
            children: [
              CategoryTile(
                icon: const Icon(
                  FontAwesomeIcons.car,
                ),
                label: 'Cars',
                onTap: () {},
              ),
              SizedBox(
                width: AppDefaults.categoryTileWidth /
                    AppDefaults.categoryTilesCount,
              ),
              CategoryTile(
                icon: const Icon(
                  FontAwesomeIcons.building,
                ),
                label: 'Properties',
                onTap: () {},
              ),
              SizedBox(
                width: AppDefaults.categoryTileWidth /
                    AppDefaults.categoryTilesCount,
              ),
              CategoryTile(
                icon: const Icon(
                  FontAwesomeIcons.champagneGlasses,
                ),
                label: 'Events',
                onTap: () {},
              ),
              SizedBox(
                width: AppDefaults.categoryTileWidth /
                    AppDefaults.categoryTilesCount,
              ),
              CategoryTile(
                icon: const Icon(
                  FontAwesomeIcons.briefcase,
                ),
                label: 'Jobs',
                onTap: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}
