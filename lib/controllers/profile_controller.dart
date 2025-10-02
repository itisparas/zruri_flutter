// lib/views/profile/controllers/profile_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Observables
  final RxString displayName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxString email = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final Rx<DateTime?> joinDate = Rx<DateTime?>(null);
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _updateUserData(user);
      }
    });
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _updateUserData(user);
    }
  }

  void _updateUserData(User user) {
    displayName.value = user.displayName ?? 'Zruri User';
    phoneNumber.value = user.phoneNumber ?? '';
    email.value = user.email ?? '';
    profileImageUrl.value = user.photoURL ?? '';
    joinDate.value = user.metadata.creationTime;
  }

  // Update display name
  Future<void> updateDisplayName(String newName) async {
    if (newName.trim().isEmpty) return;

    try {
      isLoading.value = true;
      await _authController.updateUserDisplayName(newName.trim());
      displayName.value = newName.trim();
      Get.snackbar(
        'Success',
        'Display name updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update display name',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile picture
  Future<void> updateProfilePicture() async {
    try {
      // Show image source selection
      final ImageSource source = ImageSource.gallery;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        isUploadingImage.value = true;
        final String downloadUrl = await _uploadProfileImage(File(image.path));
        await _updateUserProfileImage(downloadUrl);
        profileImageUrl.value = downloadUrl;
        Get.snackbar(
          'Success',
          'Profile picture updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile picture',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadProfileImage(File imageFile) async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String fileName = 'profile_$userId.jpg';

    final Reference storageRef = _storage
        .ref()
        .child('profile_images')
        .child(fileName);

    final UploadTask uploadTask = storageRef.putFile(imageFile);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateUserProfileImage(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePhotoURL(imageUrl);
    }
  }

  // Remove profile picture
  Future<void> removeProfilePicture() async {
    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Profile Picture'),
        content: const Text(
          'Are you sure you want to remove your profile picture?',
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        isUploadingImage.value = true;
        await _updateUserProfileImage('');
        profileImageUrl.value = '';
        Get.snackbar('Success', 'Profile picture removed successfully');
      } catch (e) {
        Get.snackbar('Error', 'Failed to remove profile picture');
      } finally {
        isUploadingImage.value = false;
      }
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    _loadUserData();
  }

  // Get formatted join date
  String get formattedJoinDate {
    if (joinDate.value == null) return 'Unknown';
    return DateFormat('MMMM yyyy').format(joinDate.value!);
  }

  // Get user initials for avatar fallback
  String get userInitials {
    final name = displayName.value.trim();
    if (name.isEmpty) return 'U';

    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    try {
      notificationsEnabled.value = value;

      // Update Firestore user document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'notificationsEnabled': value});

        // Update the token document
        await FirebaseFirestore.instance
            .collection('user_tokens')
            .doc(user.uid)
            .update({'notificationsEnabled': value});
      }
    } catch (e) {
      // Revert on error
      notificationsEnabled.value = !value;
      Get.snackbar(
        'Error',
        'Failed to update notification settings',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user with phone number
      // Note: For phone auth, we need to re-verify the phone number
      // This is a simplified version - you may need to adjust based on your auth flow

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      await FirebaseFirestore.instance
          .collection('user_tokens')
          .doc(user.uid)
          .delete();

      // Delete all user's ads
      final adsQuery = await FirebaseFirestore.instance
          .collection('ads')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var doc in adsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete Firebase Auth account
      await user.delete();

      // Delete all controllers including permanent ones
      Get.deleteAll(force: true);

      Get.offAllNamed('/authlanding');
      Get.snackbar(
        'Account Deleted',
        'Your account has been permanently deleted',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar(
          'Error',
          'Please log out and log in again before deleting your account',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete account: ${e.message}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
