import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/models/my_ads_model.dart';

class GetMyAdsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MyAdsModel>> getMyAds(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('ads')
          .where('user', isEqualTo: userId)
          .get(const GetOptions(source: Source.server));

      List<MyAdsModel> myAds = querySnapshot.docs.map((doc) {
        log(doc.data().toString());
        return MyAdsModel.fromDocumentSnapshot(doc);
      }).toList();

      return myAds;
    } catch (e) {
      throw Exception(e);
    }
  }
}
