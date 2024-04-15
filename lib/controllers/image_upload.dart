import 'dart:io';

import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/services/firebase_storage_service.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class ImageUploadController extends GetxController {
  static ImageUploadController instance = Get.find();

  static AuthController authController = Get.find();

  RxBool uploading = false.obs;

  RxInt currentUploadingIndex = 0.obs;

  FirebaseStorageService storageService = FirebaseStorageService();

  Future<List<String>> uploadAdImages({
    required List<File> files,
    required String adId,
  }) async {
    currentUploadingIndex.value = 0;
    uploading.value = true;

    List<String> filepaths = [];

    try {
      for (int i = 0; i < files.length; i++) {
        String userUid = '${authController.firebaseUser.value?.uid}/';
        // Construct the file path for the Firebase storage bucket
        String filePath =
            'ads/$userUid$adId-${i + 1}.${files[i].path.split('.').last}';
        await storageService
            .uploadImage(
              file: files[i],
              filePath: filePath,
            )
            .then(
              (value) => currentUploadingIndex.value++,
              onError: (e) => throw Exception(e),
            );
        filepaths.add(filePath);
      }
      return filepaths;
    } catch (e) {
      Get.snackbar(
        AppMessages.enUs['snackbar']['error.title'],
        AppMessages.enUs['snackbar']['error.imageupload'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
      throw Exception(e);
    } finally {
      uploading.value = false;
    }
  }
}
