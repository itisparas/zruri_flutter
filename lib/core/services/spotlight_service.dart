// services/spotlight_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/models/spotlight_request_model.dart';

class SpotlightService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'spotlight_requests';

  static Future<bool> createSpotlightRequest({
    required String userId,
    required String userName,
    required String userEmail,
    required String adId,
    required String adTitle,
  }) async {
    try {
      final request = SpotlightRequestModel(
        id: '', // Will be auto-generated
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        adId: adId,
        adTitle: adTitle,
        requestDate: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(request.adId)
          .set(request.toMap());

      Get.snackbar(
        'Request Submitted',
        'Your spotlight request has been sent to our team',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit spotlight request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  static Future<List<SpotlightRequestModel>> getUserSpotlightRequests(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('requestDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SpotlightRequestModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching spotlight requests: $e');
      return [];
    }
  }
}
