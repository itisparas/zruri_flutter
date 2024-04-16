import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';

class AdController extends GetxController {
  static AdController instance = Get.find();

  RxBool loading = true.obs;
  RxInt currentImageIndex = 0.obs;

  String adId = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Rx<Map<String, dynamic>?> adDetails;

  AdController({required this.adId});

  @override
  void onInit() {
    // TODO: implement onInit
    loadAd();
    super.onInit();
  }

  loadAd() {
    _firestore.collection('ads').doc(adId).get().then((value) {
      if (!value.exists) {
        Get.offAllNamed(AppRouteNames.entrypoint);
        throw Exception('Ad not found.');
      }
      adDetails = value.data().obs;
      loading.value = false;
    }, onError: (e) => throw Exception(e));
  }
}
