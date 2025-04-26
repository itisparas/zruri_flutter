import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/models/ad_space_model.dart';

class AdSpaceController extends GetxController {
  final CollectionReference<AdSpaceModel> _adSpaceCollection = FirebaseFirestore
      .instance
      .collection('adspace')
      .withConverter<AdSpaceModel>(
        fromFirestore: (snapshots, _) =>
            AdSpaceModel.fromJson(snapshots.data()!),
        toFirestore: (adSpace, _) => adSpace.toJson(),
      );

  final adSpaces = <AdSpaceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchAdSpaces();
  }

  Future<void> _fetchAdSpaces() async {
    try {
      final QuerySnapshot<AdSpaceModel> querySnapshot =
          await _adSpaceCollection.get();

      adSpaces.value =
          querySnapshot.docs.map((snapshot) => snapshot.data()).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
