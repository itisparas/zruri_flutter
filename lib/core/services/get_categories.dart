import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/models/categories_model.dart';

class GetCategoriesService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoriesModel>> getCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('categories').get();
      return querySnapshot.docs
          .map((doc) => CategoriesModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
