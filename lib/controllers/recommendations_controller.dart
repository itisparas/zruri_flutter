import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/models/listing_ad_model.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class RecommendationsController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ListingAdModel> recommendations = <ListingAdModel>[].obs;

  AuthController authController = Get.find<AuthController>();

  RecommendationsController();

  @override
  void onInit() {
    fetchRecommendations();
    super.onInit();
    // Initialize any necessary data or state here
  }

  void fetchRecommendations() async {
    // Logic to fetch recommendations from the server or database
    // This could involve making an API call or querying a local database
    if (isLoading.value) return;

    isLoading.value = true;

    Query query = FirebaseFirestore.instance
    .collection('ads')
    .where('ad_promoted', isEqualTo: true)
    .where('location_locality', isEqualTo: authController.firebaseUser.value?.location.locality)
    .where('soft_delete', isEqualTo: false)
    .orderBy('createdAt', descending: true)
    .limit(5);

    final querySnapshot = await query.get();
    if(querySnapshot.docs.isNotEmpty) {
      recommendations.addAll(querySnapshot.docs.map((doc) => ListingAdModel.fromDocumentSnapshot(doc)).toList());
    }
    isLoading.value = false;
  }
}