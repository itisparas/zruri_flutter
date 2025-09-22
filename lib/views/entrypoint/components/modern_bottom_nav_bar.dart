// lib/views/entrypoint/components/modern_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/views/entrypoint/controllers/navigation_controller.dart';
import 'package:zruri/views/post_ad_page/category_selection_page.dart';

class ModernBottomNavBar extends StatelessWidget {
  const ModernBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find<NavigationController>();

    return Obx(
      () => Container(
        height: 85, // Reduced height to prevent overflow
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -10),
              spreadRadius: 0,
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ), // Reduced padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center align items
              children: [
                Expanded(
                  // Use Expanded to prevent overflow
                  child: _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isActive: controller.currentIndex.value == 0,
                    onTap: () => controller.navigateToPage(0),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view,
                    label: 'Categories',
                    index: 1,
                    isActive: controller.currentIndex.value == 1,
                    onTap: () => controller.navigateToPage(1),
                  ),
                ),
                // FAB with fixed width
                SizedBox(
                  width: 60,
                  child: _buildFloatingActionButton(controller),
                ),
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: 'Chats',
                    index: 2,
                    isActive: controller.currentIndex.value == 2,
                    badgeCount: controller.unreadMessagesCount.value,
                    onTap: () => controller.navigateToPage(2),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    index: 3,
                    isActive: controller.currentIndex.value == 3,
                    onTap: () => controller.navigateToPage(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ), // Reduced padding
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14), // Reduced radius
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey('${index}_${isActive}'),
                    color: isActive ? AppColors.primary : Colors.grey[600],
                    size: 22, // Slightly smaller icon
                  ),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9, // Smaller text
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3), // Reduced spacing
            Flexible(
              // Use Flexible to prevent text overflow
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10, // Smaller font
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.primary : Colors.grey[600],
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(NavigationController controller) {
    return GestureDetector(
      onTap: () => Get.to(() => CategorySelectionPage()),
      child: Container(
        width: 52, // Slightly smaller
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 26, // Smaller icon
        ),
      ),
    );
  }
}
