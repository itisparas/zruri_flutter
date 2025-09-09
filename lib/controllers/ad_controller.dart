import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri/core/routes/app_route_names.dart';

class AdController extends GetxController {
  static AdController instance = Get.find();

  RxBool loading = true.obs;
  RxBool loadingUser = true.obs;
  RxInt currentImageIndex = 0.obs;

  String adId = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Rx<Map<String, dynamic>?> adDetails;
  late Rx<Map<String, dynamic>?> advertiserDetails;

  AdController({required this.adId});

  @override
  void onInit() async {
    // TODO: implement onInit
    await loadAd();
    super.onInit();
  }

  loadAd() async {
    // Get the ad details from Firestore
    // aggregate with users collection to get the user details
    // ads.user = users._id
    await _firestore.collection('ads').doc(adId).get().then((value) {
      if (!value.exists) {
        Get.offAllNamed(AppRouteNames.entrypoint);
        throw Exception('Ad not found.');
      }
      adDetails = value.data().obs;
      loading.value = false;
      loadUser();
      updateCounter();
    }, onError: (e) => throw Exception(e));
  }

  updateCounter() async {
    // Increment the ad view counter
    await _firestore.collection('ads').doc(adId).update({
      'views': FieldValue.increment(1),
    });
  }

  loadUser() async {
    // Get the user details from Firestore
    // aggregate with ads collection to get the ad details
    // ads.user = users._id
    _firestore.collection('users').doc(adDetails.value!['user']).get().then((
      value,
    ) {
      if (!value.exists) {
        Get.offAllNamed(AppRouteNames.entrypoint);
        throw Exception('User not found.');
      }
      advertiserDetails = value.data().obs;
      loadingUser.value = false;
    }, onError: (e) => throw Exception(e));
  }
}
