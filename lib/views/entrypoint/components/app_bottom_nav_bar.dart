import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/views/entrypoint/components/bottom_app_bar_item.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class AppBottomNavBar extends StatelessWidget {
  ScreenController c = Get.put(ScreenController());

  AppBottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: AppDefaults.margin,
      color: AppColors.scaffoldBackground,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BottomAppBarItem(
              iconName: Icons.home_work_outlined,
              name: 'Home',
              isActive: c.currentIndex.value == 0,
              onTap: () => c.onChange(0),
            ),
            BottomAppBarItem(
              iconName: Icons.category_outlined,
              name: 'Categories',
              isActive: c.currentIndex.value == 1,
              onTap: () => c.onChange(1),
            ),
            const Padding(
              padding: EdgeInsets.all(AppDefaults.padding * 2),
              child: SizedBox(
                width: AppDefaults.margin,
              ),
            ),
            BottomAppBarItem(
              iconName: Icons.bookmark_added_outlined,
              name: 'My ads',
              isActive: c.currentIndex.value == 3,
              onTap: () => c.onChange(3),
            ),
            BottomAppBarItem(
              iconName: Icons.person_outline,
              name: 'Profile',
              isActive: c.currentIndex.value == 4,
              onTap: () => c.onChange(4),
            ),
          ],
        ),
      ),
    );
  }
}
