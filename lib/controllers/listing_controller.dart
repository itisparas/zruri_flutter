import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/models/my_ads_model.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class ListingController extends GetxController {
  RxList<MyAdsModel> ads = <MyAdsModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMoreData = true.obs;

  final int limit = 10; // Number of items to load per page

  DocumentSnapshot? lastDocument;

  AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  void fetchAds() async {
    double userLat =
        authController.firebaseUser.value?.location.latitude ?? 28.00;
    double userLng =
        authController.firebaseUser.value?.location.longitude ?? 86.00;
    double minLat = userLat - (50 / 6371) * (180 / pi);
    double maxLat = userLat + (50 / 6371) * (180 / pi);
    double minLng =
        userLng - (50 / 6371) * (180 / pi) / cos(userLat * pi / 180);
    double maxLng =
        userLng + (50 / 6371) * (180 / pi) / cos(userLat * pi / 180);
    print('$userLat - $userLng');
    print('$minLat - $maxLat');
    print('$minLng - $maxLng');

    if (isLoading.value || !hasMoreData.value) return;

    isLoading.value = true;

    Query query = FirebaseFirestore.instance
        .collection('ads')
        .orderBy('createdAt', descending: true)
        .where(
          Filter.and(
            Filter('location.latitude', isGreaterThanOrEqualTo: minLat),
            Filter('location.latitude', isLessThan: maxLat),
            Filter('location.longitude', isGreaterThanOrEqualTo: minLng),
            Filter('location.longitude', isLessThan: maxLng),
            Filter('active', isEqualTo: true),
            Filter('soft_delete', isEqualTo: false),
          ),
        )
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      ads.addAll(querySnapshot.docs
          .map((doc) => MyAdsModel.fromDocumentSnapshot(doc))
          .toList());
    } else {
      hasMoreData.value = false;
    }

    isLoading.value = false;
  }

  void loadMoreAds() {
    if (hasMoreData.value && !isLoading.value) fetchAds();
  }
}
