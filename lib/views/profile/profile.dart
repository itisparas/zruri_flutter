// lib/views/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/controllers/my_ads_controller.dart';
import 'package:zruri/controllers/profile_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/constants.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';
import 'package:zruri/views/entrypoint/controllers/navigation_controller.dart';
import 'package:zruri/views/post_ad_page/category_selection_page.dart';
import 'package:zruri/views/profile/components/my_ad_card.dart';
import 'package:zruri/views/profile/components/profile_header.dart';
import 'package:zruri/views/profile/components/profile_stats.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
    final MyAdsController myAdsController = Get.put(
      MyAdsController(),
      permanent: true,
    );
    final NavigationController navigationController =
        Get.find<NavigationController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(
              context,
              navigationController,
              profileController,
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () => _handleRefresh(profileController, myAdsController),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildProfileHeader(profileController),
              _buildProfileStats(profileController, myAdsController),
              _buildMyAdsSection(myAdsController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    NavigationController navigationController,
    ProfileController profileController,
  ) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      pinned: true,
      leading: IconButton(
        onPressed: () {
          if (navigationController.canPop.value) {
            navigationController.goBack();
          } else {
            navigationController.navigateToPage(0);
          }
        },
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, profileController),
          icon: Icon(Icons.more_vert, color: Colors.grey[700]),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Edit Profile'),
                ],
              ),
            ),
            // const PopupMenuItem(
            //   value: 'settings',
            //   child: Row(
            //     children: [
            //       Icon(Icons.settings_outlined),
            //       SizedBox(width: 8),
            //       Text('Settings'),
            //     ],
            //   ),
            // ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ProfileController profileController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.primary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ProfileHeader(controller: profileController),
      ),
    );
  }

  Widget _buildProfileStats(
    ProfileController profileController,
    MyAdsController myAdsController,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ProfileStats(
          profileController: profileController,
          myAdsController: myAdsController,
        ),
      ),
    );
  }

  Widget _buildMyAdsSection(MyAdsController myAdsController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(
          left: AppDefaults.margin,
          right: AppDefaults.margin,
          top: AppDefaults.margin * 2,
          bottom: AppDefaults.margin * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'My Listings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    '${myAdsController.myAds.length} ads',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDefaults.padding),
            Obx(() => _buildMyAdsContent(myAdsController)),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAdsContent(MyAdsController myAdsController) {
    if (myAdsController.loading.value) {
      return _buildLoadingAds();
    }

    if (myAdsController.myAds.isEmpty) {
      return _buildEmptyAdsState();
    }

    return Column(
      children: myAdsController.myAds.map((ad) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: MyAdCard(
            ad: ad,
            onToggleActive: () =>
                _toggleAdStatus(ad.id, ad.active, myAdsController),
            onDelete: () => _deleteAd(ad.id, myAdsController),
            onTap: () => Get.toNamed('/ad/${ad.id}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingAds() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAdsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start selling by creating your first listing',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to post ad page
              Get.to(() => CategorySelectionPage());
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Listing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh(
    ProfileController profileController,
    MyAdsController myAdsController,
  ) async {
    await Future.wait([
      profileController.refreshProfile(),
      myAdsController.refreshAds(),
    ]);
  }

  void _handleMenuAction(String action, ProfileController profileController) {
    switch (action) {
      case 'edit':
        _showEditProfileDialog(profileController);
        break;
      case 'settings':
        // Navigate to settings
        Get.toNamed('/settings');
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showEditProfileDialog(ProfileController profileController) {
    final displayNameController = TextEditingController(
      text: profileController.displayName.value,
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await profileController.updateDisplayName(
                displayNameController.text,
              );
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

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAdStatus(
    String id,
    bool currentStatus,
    MyAdsController controller,
  ) async {
    try {
      if (currentStatus) {
        await controller.deactivateAd(id);
      } else {
        await controller.activateAd(id);
      }
      await controller.refreshAds();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update ad status');
    }
  }

  Future<void> _deleteAd(String id, MyAdsController controller) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing'),
        content: const Text(
          'Are you sure you want to delete this listing? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await controller.deleteAd(id);
        await controller.refreshAds();
        Get.snackbar('Success', 'Listing deleted successfully');
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete listing');
      }
    }
  }
}
