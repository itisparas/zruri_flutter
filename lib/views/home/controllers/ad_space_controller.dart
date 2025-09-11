import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri/models/listing_ad_model.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class AdSpaceController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ListingAdModel> adSpaces = <ListingAdModel>[].obs;

  AuthController authController = Get.find<AuthController>();

  AdSpaceController();

  @override
  void onInit() {
    _fetchAdSpaces();
    super.onInit();
  }

  Future<void> _fetchAdSpaces() async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('ads')
          .where('ad_slider', isEqualTo: true)
          .where(
            'location_locality',
            isEqualTo: authController.firebaseUser.value?.location.locality,
          )
          .where('soft_delete', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(5);

      final querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        adSpaces.addAll(
          querySnapshot.docs
              .map((doc) => ListingAdModel.fromDocumentSnapshot(doc))
              .toList(),
        );
      }
      isLoading.value = false;
    } catch (e) {
      throw Exception(e);
    }
  }
}
