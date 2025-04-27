import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/controllers/image_upload.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_field_types.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_model.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class SaveDynamicForm extends GetxController {
  final ImageUploadController imageUploadController =
      Get.put(ImageUploadController());
  final AuthController authController = Get.find<AuthController>();

  RxList<DynamicModel> formFields = <DynamicModel>[].obs;
  RxList<File> images = <File>[].obs;

  RxBool isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> postAdForm(String? categoryName, String? categoryId) async {
    isLoading.value = true;
    log('postAdForm() triggered.');
    Map<String, dynamic> formData = {};

    String adId = _firestore.collection('ads').doc().id;

    formData['filepaths'] =
        await imageUploadController.uploadAdImages(files: images, adId: adId);
    formData['user'] = authController.firebaseUser.value?.user.uid;
    formData['createdAt'] = FieldValue.serverTimestamp();
    formData['active'] = true;
    formData['soft_delete'] = false;
    formData['category_name'] = categoryName;
    formData['category_id'] = categoryId;
    formData['views'] = 0;
    formData['ad_promoted'] = false;
    formData['ad_slider'] = false;

    formData['location'] = authController.firebaseUser.value?.location.toMap();
    formData['location_latitude'] =
        authController.firebaseUser.value?.location.latitude;
    formData['location_longitude'] =
        authController.firebaseUser.value?.location.longitude;
    formData['location_locality'] =
        authController.firebaseUser.value?.location.locality;

    for (var element in formFields) {
      if (element.formType == FormTypeValues.multiline) {
        element.value = Uri.encodeComponent(element.value);
      }
      formData[element.controlName] = element.value;
    }
    _firestore.collection('ads').doc(adId).set(formData).then(
          (value) => Get.offAndToNamed(
              '${AppRouteNames.postAdSuccessPageMainRoute}$adId'),
          onError: (e) => throw Exception(e),
        );
    isLoading.value = false;
  }
}
