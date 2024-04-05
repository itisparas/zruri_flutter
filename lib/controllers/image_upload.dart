import 'dart:io';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/services/firebase_storage_service.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class ImageUploadController extends GetxController {
  static ImageUploadController instance = Get.find();

  static AuthController authController = Get.find();

  RxList<String> images = <String>[].obs;

  RxBool uploading = false.obs;

  FirebaseStorageService storageService = FirebaseStorageService();

  void addImage(String filePath) => images.add(filePath);

  Future<void> uploadImages({
    required List<File> files,
    String dirName = '',
    bool userSpecific = false,
  }) async {
    uploading.value = true;
    try {
      for (File image in files) {
        String fileName = const Uuid().v6();
        String userUid =
            userSpecific ? '${authController.firebaseUser.value?.uid}/' : '';
        String filePath =
            '$dirName/$userUid$fileName.${image.path.split('.').last}';
        addImage(
          await storageService.uploadImage(
            file: image,
            filePath: filePath,
          ),
        );
      }
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
