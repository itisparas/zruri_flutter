import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller. Using permanent: true is fine for a root controller.
    final authController = Get.put(AuthController(), permanent: true);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // While loading, show a branded splash screen
          if (authController.isLoading.value) {
            return const _LoadingScreen();
          }

          // After loading, check login state
          if (authController.isLoggedIn.value) {
            // User is logged in. Redirect them to the main app.
            // Using a post-frame callback ensures navigation happens safely after the build cycle.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Get.offAll() clears the navigation stack, so the user can't go back to the landing page.
              Get.offAllNamed(AppRouteNames.entrypoint);
            });

            // While redirecting, show the loading screen to prevent a flicker
            return const _LoadingScreen();
          } else {
            // User is logged out. Show them clear login/signup options.
            return const _WelcomeScreen();
          }
        }),
      ),
    );
  }
}

/// A dedicated widget for the welcome/actions screen.
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          // --- App Logo and Tagline ---
          const Icon(
                Icons.storefront_rounded, // Replace with your app's logo widget
                size: 80,
                color: AppColors.primary,
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 24),

          Text(
                'Welcome to Zruri', // Your App Name
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 12),

          Text(
            'Your one-stop marketplace for everything you need.', // Your app's tagline
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

          const Spacer(),
          const Spacer(),

          // --- Action Buttons ---
          ElevatedButton(
                onPressed: () {
                  // Navigate to your LoginPage
                  Get.toNamed(AppRouteNames.onboarding);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Primary color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )
              .animate()
              .fadeIn(delay: 600.ms, duration: 500.ms)
              .slideY(begin: 0.5),
        ],
      ),
    );
  }
}

/// A dedicated widget for the loading/splash screen.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.rocket_launch_outlined, // Replace with your app's logo
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Securing your session...',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
