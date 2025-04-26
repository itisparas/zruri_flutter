import 'dart:developer';

import 'package:get/get.dart';
import 'package:zruri_flutter/core/services/my_ads_service.dart';
import 'package:zruri_flutter/models/my_ads_model.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class MyAdsController extends GetxController {
  final MyAdsService _myAdsService = Get.put(MyAdsService());

  var myAds = <MyAdsModel>[].obs;
  var loading = true.obs;

  @override
  void onInit() {
    AuthController authController = Get.find<AuthController>();
    loadMyAds(authController.firebaseUser.value?.user.uid);
    super.onInit();
  }

  Future<void> loadMyAds(userId) async {
    try {
      loading.value = true;
      List<MyAdsModel> myAdsList = await _myAdsService.getMyAds(userId);
      log(myAdsList.toString());
      myAds.value = myAdsList;
    } catch (e) {
      throw Exception(e);
    } finally {
      loading.value = false;
    }
  }
}
