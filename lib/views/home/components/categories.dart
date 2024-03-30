import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/views/home/components/category_tile.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                onPressed: () {},
                child: const Text(
                  'view all',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dashed),
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
