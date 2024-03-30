import 'package:flutter/material.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class CategoryTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final void Function() onTap;

  const CategoryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.scaffoldBackground,
      child: InkWell(
        borderRadius: AppDefaults.borderRadius,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldWithBoxBackground,
                borderRadius: AppDefaults.borderRadius,
              ),
              width: AppDefaults.categoryTileWidth,
              child: AspectRatio(
                aspectRatio: 1.25,
                child: icon,
              ),
            ),
            const SizedBox(
              height: AppDefaults.padding / 4,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
