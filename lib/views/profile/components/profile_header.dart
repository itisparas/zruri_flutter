// lib/views/profile/components/profile_header.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/controllers/profile_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileController controller;

  const ProfileHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Picture Section
        Stack(
          children: [
            Obx(
              () => GestureDetector(
                onTap: () => _showProfileImageOptions(),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: controller.profileImageUrl.value.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: controller.profileImageUrl.value,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                _buildAvatarFallback(),
                          )
                        : _buildAvatarFallback(),
                  ),
                ),
              ),
            ),

            // Upload indicator
            Obx(
              () => controller.isUploadingImage.value
                  ? Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Edit button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.updateProfilePicture,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // User Info Section
        Obx(
          () => Column(
            children: [
              // Display Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      controller.displayName.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showEditNameDialog(),
                    child: Icon(Icons.edit, size: 18, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Phone Number
              if (controller.phoneNumber.value.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        controller.phoneNumber.value,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Join Date
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Member since ${controller.formattedJoinDate}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Obx(
          () => Text(
            controller.userInitials,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileImageOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Update Picture'),
              onTap: () {
                Get.back();
                controller.updateProfilePicture();
              },
            ),
            if (controller.profileImageUrl.value.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Picture',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  controller.removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(
      text: controller.displayName.value,
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.updateDisplayName(nameController.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
