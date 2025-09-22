// models/spotlight_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SpotlightRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String adId;
  final String adTitle;
  final DateTime requestDate;
  final String status; // pending, approved, rejected
  final Map<String, dynamic>? metadata;

  SpotlightRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.adId,
    required this.adTitle,
    required this.requestDate,
    this.status = 'pending',
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'adId': adId,
      'adTitle': adTitle,
      'requestDate': requestDate,
      'status': status,
      'metadata': metadata,
    };
  }

  factory SpotlightRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return SpotlightRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      adId: map['adId'] ?? '',
      adTitle: map['adTitle'] ?? '',
      requestDate: (map['requestDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      metadata: map['metadata'],
    );
  }
}
