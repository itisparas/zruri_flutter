import 'package:cloud_firestore/cloud_firestore.dart';

class MyAdsModel {
  String title;
  String price;
  Timestamp createdAt;
  String imageUrl;
  String id;
  bool active;

  MyAdsModel(
      {this.title = '',
      this.price = '0',
      required this.createdAt,
      this.imageUrl = 'pexels-binyamin-mellish-186077.jpg',
      this.id = '',
      this.active = true});

  MyAdsModel.fromDocumentSnapshot(DocumentSnapshot snapshot)
      : title = snapshot['title'] ?? '',
        price = snapshot['price'] ?? '0',
        createdAt = snapshot['createdAt'] ?? '',
        imageUrl = snapshot['filepaths'][0],
        id = snapshot.id,
        active = snapshot['active'];
}
