// lib/controllers/my_ads_controller.dart
import 'dart:developer';
import 'package:get/get.dart';
import 'package:zruri/core/services/my_ads_service.dart';
import 'package:zruri/models/my_ads_model.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class MyAdsController extends GetxController {
  final MyAdsService _myAdsService = Get.put(MyAdsService(), permanent: true);

  final RxList<MyAdsModel> myAds = <MyAdsModel>[].obs;
  final RxBool loading = true.obs;
  final RxString sortBy = 'newest'.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyAds();
  }

  Future<void> loadMyAds() async {
    try {
      final AuthController authController = Get.find<AuthController>();
      final userId = authController.firebaseUser.value?.user.uid;

      if (userId == null) return;

      loading.value = true;
      List<MyAdsModel> myAdsList = await _myAdsService.getMyAds(userId);
      myAds.assignAll(myAdsList);
      _sortAds();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load your ads');
      log('Error loading ads: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshAds() async {
    await loadMyAds();
  }

  Future<void> activateAd(String id) async {
    await _myAdsService.activateAd(id);
  }

  Future<void> deactivateAd(String id) async {
    await _myAdsService.deactivateAd(id);
  }

  Future<void> deleteAd(String id) async {
    await _myAdsService.deleteAd(id);
  }

  void setSortBy(String sortType) {
    sortBy.value = sortType;
    _sortAds();
  }

  void _sortAds() {
    switch (sortBy.value) {
      case 'newest':
        myAds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        myAds.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'price_high':
        myAds.sort(
          (a, b) => double.parse(b.price).compareTo(double.parse(a.price)),
        );
        break;
      case 'price_low':
        myAds.sort(
          (a, b) => double.parse(a.price).compareTo(double.parse(b.price)),
        );
        break;
      case 'title':
        myAds.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }
  }

  // Getters
  int get totalAds => myAds.length;
  int get activeAds => myAds.where((ad) => ad.active).length;
  int get inactiveAds => totalAds - activeAds;
}
