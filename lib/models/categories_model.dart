import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesModel {
  String id;
  bool homepage;
  String name;

  CategoriesModel({
    required this.id,
    required this.homepage,
    required this.name,
  });

  CategoriesModel.fromDocumentSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        homepage = snapshot['homepage'],
        name = snapshot['name'];
}
