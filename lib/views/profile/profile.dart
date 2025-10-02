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
import 'package:url_launcher/url_launcher.dart';

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
        // Settings Menu Button
        Padding(
          padding: const EdgeInsets.only(right: AppDefaults.padding / 2),
          child: IconButton(
            onPressed: () =>
                _showSettingsBottomSheet(context, profileController),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: Colors.grey[700],
                size: 20,
              ),
            ),
            tooltip: 'Settings',
          ),
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

  void _showSettingsBottomSheet(
    BuildContext context,
    ProfileController profileController,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.settings, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDefaults.margin),
            const Divider(height: 1),
            // Settings options
            _buildNotificationToggle(profileController),
            _buildSettingsOption(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy',
              subtitle: 'View our privacy policy',
              color: Colors.purple,
              onTap: () {
                Get.back();
                _launchPrivacyPolicy();
              },
            ),
            const Divider(height: 1),
            // Danger zone
            _buildSettingsOption(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              color: Colors.orange[700]!,
              onTap: () {
                Get.back();
                _showLogoutDialog();
              },
            ),
            _buildSettingsOption(
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              color: Colors.red,
              onTap: () {
                Get.back();
                _showDeleteAccountDialog(profileController);
              },
              isDangerous: true,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDangerous = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDangerous ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(ProfileController profileController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Receive push notifications',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: profileController.notificationsEnabled.value,
              onChanged: (value) async {
                await profileController.toggleNotifications(value);
                Get.snackbar(
                  'Notifications',
                  value ? 'Notifications enabled' : 'Notifications disabled',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              activeThumbColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://zruri.dzrv.digital/privacy.html');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open privacy policy',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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

  void _showEditProfileDialog(ProfileController profileController) {
    final displayNameController = TextEditingController(
      text: profileController.displayName.value,
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.edit, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Edit Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final RxBool isLoggingOut = false.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isLoggingOut.value
                  ? null
                  : () async {
                      isLoggingOut.value = true;
                      await Get.find<AuthController>().signOut();
                      Get.back();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: isLoggingOut.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(ProfileController profileController) {
    final RxBool isConfirmed = false.obs;
    final RxBool isDeleting = false.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Account', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildDeleteWarningItem('All your listings will be removed'),
            _buildDeleteWarningItem('Your profile will be deleted'),
            _buildDeleteWarningItem('All your messages will be lost'),
            const SizedBox(height: AppDefaults.margin),
            const Text(
              "Your listings may take some time to be removed from the app because of indexing.",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Obx(
              () => CheckboxListTile(
                value: isConfirmed.value,
                onChanged: isDeleting.value
                    ? null
                    : (value) => isConfirmed.value = value ?? false,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'I understand this action is permanent',
                  style: TextStyle(fontSize: 14),
                ),
                activeColor: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: isDeleting.value ? null : () => Get.back(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isConfirmed.value && !isDeleting.value
                  ? () async {
                      isDeleting.value = true;
                      try {
                        await profileController.deleteAccount('');
                        Get.back(); // Close dialog
                      } catch (e) {
                        isDeleting.value = false;
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: isDeleting.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Delete Account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.close, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete Listing'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this listing? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
