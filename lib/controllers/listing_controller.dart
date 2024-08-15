import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/models/my_ads_model.dart';

class ListingController extends GetxController {
  RxList<MyAdsModel> ads = <MyAdsModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMoreData = true.obs;

  final int limit = 10; // Number of items to load per page

  DocumentSnapshot? lastDocument;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  void fetchAds() async {
    print('fetchAds() triggered.');
    if (isLoading.value || !hasMoreData.value) return;

    isLoading.value = true;

    Query query = FirebaseFirestore.instance
        .collection('ads')
        .orderBy('createdAt', descending: true)
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
