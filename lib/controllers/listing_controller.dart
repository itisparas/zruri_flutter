import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri/models/listing_ad_model.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class ListingController extends GetxController {
  final String genre;
  final String genreId;

  RxList<ListingAdModel> ads = <ListingAdModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMoreData = true.obs;

  RxString selectedSortOption = 'date_desc'.obs;
  RxString selectedFilterOption = 'only_active'.obs;

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
        .where(genre, isEqualTo: genreId)
        .where(
          'location_locality',
          isEqualTo: authController.firebaseUser.value?.location.locality,
        )
        .where('soft_delete', isEqualTo: false);

    // Apply filtering
    if (selectedFilterOption.value == 'only_active') {
      query = query.where('active', isEqualTo: true);
    }

    // Apply sorting
    if (selectedSortOption.value == 'price_asc') {
      query = query.orderBy('price', descending: false);
    } else if (selectedSortOption.value == 'price_desc') {
      query = query.orderBy('price', descending: true);
    } else if (selectedSortOption.value == 'date_desc') {
      query = query.orderBy('createdAt', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: false);
    }

    query = query.limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      ads.addAll(
        querySnapshot.docs
            .map((doc) => ListingAdModel.fromDocumentSnapshot(doc))
            .toList(),
      );
    } else {
      hasMoreData.value = false;
    }

    isLoading.value = false;
  }

  void loadMoreAds() {
    if (hasMoreData.value && !isLoading.value) fetchAds();
  }

  void updateSortOption(String sortOption) {
    selectedSortOption.value = sortOption;
    resetAds();
  }

  void updateFilterOption(String filterOption) {
    selectedFilterOption.value = filterOption;
    resetAds();
  }

  void resetAds() {
    ads.clear();
    lastDocument = null;
    hasMoreData.value = true;
    fetchAds();
  }
}
