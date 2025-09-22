import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/core/services/spotlight_service.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class PostAdSuccess extends StatelessWidget {
  const PostAdSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSuccessIcon(),
                  const SizedBox(height: 16),
                  _buildSuccessMessage(context),
                  const SizedBox(height: 12),
                  _buildSpotlightCard(context),
                ],
              ),
            ),
            // Expanded(
            //   child: SingleChildScrollView(
            //     physics: const BouncingScrollPhysics(),
            //     child: Padding(
            //       padding: const EdgeInsets.all(20),
            //       child: Column(
            //         children: [
            //           const SizedBox(height: 16),
            //           _buildSuccessIcon(),
            //           const SizedBox(height: 16),
            //           _buildSuccessMessage(context),
            //           const SizedBox(height: 12),
            //           _buildSpotlightCard(context),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: const Text(
        'Success!',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () => Get.toNamed(AppRouteNames.entrypoint),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    final iconSize = 80.0;
    final ringSize = iconSize / 2;
    return Container(
          width: iconSize * 2,
          height: iconSize * 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background pattern
              Container(
                width: (iconSize * 2) - ringSize,
                height: (iconSize * 2) - ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: (iconSize * 2) - (ringSize * 2),
                height: (iconSize * 2) - (ringSize * 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
              // Success icon
              Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: iconSize - (ringSize / 2),
              ),
            ],
          ),
        )
        .animate()
        .scale(delay: 200.ms, duration: 600.ms)
        .then()
        .shake(duration: 1000.ms);
  }

  Widget _buildSuccessMessage(BuildContext context) {
    return Column(
      children: [
        Text(
          'Congratulations!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
        const SizedBox(height: 12),
        Text(
          'Yay! Your ad will be live shortly.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Colors.green.shade600,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Usually live within 2-5 minutes',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildSpotlightCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Put your ad in Spotlight!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // const SizedBox(height: 4),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 8,
                        //     vertical: 2,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: Colors.orange.shade600,
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: const Text(
                        //     'HOT',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 10,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Give your ad a boost by putting your ad into spotlight.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.visibility_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '5x views',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Faster sell',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: -0.3, delay: 1000.ms, duration: 600.ms).fadeIn();
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendSpotlightEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded),
                    const SizedBox(width: 8),
                    const Text(
                      'Turn spotlight on',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.offNamed(
                    '${AppRouteNames.adPageMainRoute}${Get.parameters['adId']}',
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility_rounded),
                    const SizedBox(width: 8),
                    const Text(
                      'Preview your ad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSpotlightEmail() async {
    FirebaseAnalytics.instance.logSelectPromotion(
      promotionId: Get.parameters['adId']!,
    );
    final AuthController authController = Get.find<AuthController>();
    final String adId = Get.parameters['adId']!;
    final String adTitle = Get.parameters['adTitle'] ?? 'Untitled ad';
    if (authController.firebaseUser.value == null) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please write to us at zruri@dzrv.digital',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await SpotlightService.createSpotlightRequest(
      userId: authController.firebaseUser.value!.user.uid,
      userName:
          authController.firebaseUser.value!.user.displayName ?? 'Unknown',
      userEmail:
          authController.firebaseUser.value!.user.phoneNumber ?? 'Unknown',
      adId: adId,
      adTitle: adTitle,
    );
  }
}
