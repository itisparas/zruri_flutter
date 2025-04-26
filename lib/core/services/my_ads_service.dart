import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/models/my_ads_model.dart';

class MyAdsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> activateAd(String id) async {
    await _firestore.collection('ads').doc(id).update({'active': true}).then(
        (value) => true,
        onError: (e) => throw Exception(e));
  }

  Future<void> deactivateAd(String id) async {
    await _firestore.collection('ads').doc(id).update({'active': false}).then(
        (value) => true,
        onError: (e) => throw Exception(e));
  }

  Future<void> deleteAd(String id) async {
    await _firestore
        .collection('ads')
        .doc(id)
        .update({'soft_delete': true}).then((value) => true,
            onError: (e) => throw Exception(e));
  }

  Future<List<MyAdsModel>> getMyAds(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('ads')
          .where('user', isEqualTo: userId)
          .where('soft_delete', isNotEqualTo: true)
          .get(const GetOptions(source: Source.server));

      List<MyAdsModel> myAds = querySnapshot.docs.map((doc) {
        return MyAdsModel.fromDocumentSnapshot(doc);
      }).toList();

      return myAds;
    } catch (e) {
      throw Exception(e);
    }
  }
}
