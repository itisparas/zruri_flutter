// lib/views/entrypoint/components/app_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/views/entrypoint/components/bottom_app_bar_item.dart';
import 'package:zruri/views/entrypoint/controllers/screen_controller.dart';

class AppBottomNavBar extends StatelessWidget {
  final ScreenController c = Get.put(ScreenController(), permanent: true);

  AppBottomNavBar({super.key});

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
              iconName: Icons.home_outlined,
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
              child: SizedBox(width: AppDefaults.margin),
            ),
            // New Chat Tab
            BottomAppBarItem(
              iconName: Icons.chat_bubble_outline,
              name: 'Chats',
              isActive: c.currentIndex.value == 2,
              onTap: () => c.onChange(2),
              // Show unread count badge
              badgeCount: c.unreadMessagesCount.value,
            ),
            BottomAppBarItem(
              iconName: Icons.bookmark_outlined,
              name: 'My Ads',
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
