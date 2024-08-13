import 'package:get/get.dart';
import 'package:zruri_flutter/core/services/get_my_ads.dart';
import 'package:zruri_flutter/models/my_ads_model.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class MyAdsController extends GetxController {
  final GetMyAdsService _myAdsService = Get.put(GetMyAdsService());

  var myAds = <MyAdsModel>[].obs;
  var loading = true.obs;

  @override
  void onInit() {
    AuthController authController = Get.find<AuthController>();
    _loadMyAds(authController.firebaseUser.value?.user.uid);
    super.onInit();
  }

  Future<void> _loadMyAds(userId) async {
    try {
      loading.value = true;
      List<MyAdsModel> myAdsList = await _myAdsService.getMyAds(userId);
      myAds.value = myAdsList;
    } catch (e) {
      throw Exception(e);
    } finally {
      loading.value = false;
    }
  }
}
