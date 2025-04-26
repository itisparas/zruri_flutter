import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/routes/bottom_bar_routes.dart';
import 'package:zruri_flutter/views/entrypoint/components/app_bottom_nav_bar.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class EntrypointUI extends StatelessWidget {
  final ScreenController c = Get.put(ScreenController());

  EntrypointUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PageTransitionSwitcher(
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: AppColors.scaffoldBackground,
              child: child,
            );
          },
          duration: AppDefaults.duration,
          child: BottomBarRoutes.pages[c.currentIndex.value],
        ),
      ),
      floatingActionButton: Obx(
        () => c.isKeyboardVisible.value
            ? const SizedBox()
            : FloatingActionButton(
                onPressed: () {
                  c.onChange(2);
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(),
    );
  }
}
