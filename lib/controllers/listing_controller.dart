import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/models/my_ads_model.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class ListingController extends GetxController {
  final String genre;
  final String genreId;

  RxList<MyAdsModel> ads = <MyAdsModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMoreData = true.obs;

  final int limit = 10; // Number of items to load per page

  DocumentSnapshot? lastDocument;

  AuthController authController = Get.find<AuthController>();

  ListingController(this.genre, this.genreId);

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  void fetchAds() async {
    if (isLoading.value || !hasMoreData.value) return;

    isLoading.value = true;

    Query query = FirebaseFirestore.instance
        .collection('ads')
        .where(
          Filter.and(
            Filter('location_locality',
                isEqualTo:
                    authController.firebaseUser.value?.location.locality),
            Filter(genre, isEqualTo: genreId),
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
