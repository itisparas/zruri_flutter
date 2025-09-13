// lib/views/entrypoint/entry_point.dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/routes/bottom_bar_routes.dart';

import 'package:zruri/views/entrypoint/components/modern_bottom_nav_bar.dart';
import 'package:zruri/views/entrypoint/controllers/navigation_controller.dart';
import 'package:zruri/views/entrypoint/controllers/screen_controller.dart';

class EntrypointUI extends StatelessWidget {
  final ScreenController screenController = Get.put(
    ScreenController(),
    permanent: true,
  );

  EntrypointUI({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with proper lifecycle management
    final NavigationController controller = Get.put(
      NavigationController(),
      permanent: true,
    );

    return WillPopScope(
      onWillPop: () async => _handleBackPress(controller),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: GetBuilder<NavigationController>(
          init: controller, // Ensure controller is initialized
          builder: (_) => Obx(() => _buildBody(controller)),
        ),
        bottomNavigationBar: GetBuilder<NavigationController>(
          init: controller,
          builder: (_) => Obx(() => _buildBottomNavBar(controller)),
        ),
      ),
    );
  }

  Widget _buildBody(NavigationController controller) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return _buildPageTransition(
          child: child,
          primaryAnimation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          controller: controller,
        );
      },
      duration: AppDefaults.duration,
      reverse: controller.isNavigatingBack.value,
      child: Container(
        key: ValueKey('page_${controller.currentIndex.value}'),
        child: IndexedStack(
          index: controller.currentIndex.value,
          children: BottomBarRoutes.pages,
        ),
      ),
    );
  }

  Widget _buildPageTransition({
    required Widget child,
    required Animation<double> primaryAnimation,
    required Animation<double> secondaryAnimation,
    required NavigationController controller,
  }) {
    final transitionType = _getTransitionType(controller);

    switch (transitionType) {
      case PageTransitionType.fade:
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: AppColors.scaffoldBackground,
          child: child,
        );

      case PageTransitionType.sharedAxis:
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: AppColors.scaffoldBackground,
          child: child,
        );

      case PageTransitionType.scale:
        return FadeThroughTransition(
          // Use fade for scale to avoid issues
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: AppColors.scaffoldBackground,
          child: child,
        );
    }
  }

  PageTransitionType _getTransitionType(NavigationController controller) {
    // Simplified transition logic to avoid potential null issues
    if (controller.currentIndex.value == 2) {
      return PageTransitionType.scale;
    }

    return PageTransitionType.sharedAxis;
  }

  Widget _buildBottomNavBar(NavigationController controller) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: (controller.isKeyboardVisible.value)
          ? const Offset(0, 1)
          : Offset.zero,
      child: const ModernBottomNavBar(),
    );
  }

  Future<bool> _handleBackPress(NavigationController controller) async {
    HapticFeedback.lightImpact();

    // Safe null checking
    if (controller.canPop.value == true) {
      return !controller.goBack();
    }

    if (controller.currentIndex.value != 0) {
      controller.navigateToPage(0);
      return false;
    }

    return await _showExitDialog();
  }

  Future<bool> _showExitDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit Zruri?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

enum PageTransitionType { fade, sharedAxis, scale }
