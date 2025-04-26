import 'package:cloud_firestore/cloud_firestore.dart';

class ListingAdModel {
  String title;
  String price;
  Timestamp createdAt;
  String imageUrl;
  String id;
  String location;
  String description;

  ListingAdModel(
      {this.title = '',
      this.price = '0',
      required this.createdAt,
      this.imageUrl = 'pexels-binyamin-mellish-186077.jpg',
      this.id = '',
      this.location = 'Not available',
      this.description = ''});

  ListingAdModel.fromDocumentSnapshot(DocumentSnapshot snapshot)
      : title = snapshot['title'] ?? '',
        price = snapshot['price'] ?? '0',
        createdAt = snapshot['createdAt'] ?? '',
        imageUrl = snapshot['filepaths'][0],
        id = snapshot.id,
        location = snapshot['location_locality'],
        description = Uri.decodeComponent(snapshot['description']);
}
