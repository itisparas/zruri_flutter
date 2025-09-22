import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  var searchResults = <DocumentSnapshot>[].obs;
  var isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() async {
    if (searchController.text.length > 3) {
      isLoading.value = true;

      final results = await FirebaseFirestore.instance
          .collection('ads') // Replace with your collection name
          .orderBy('title_lowercase')
          .where(
            Filter.and(
              Filter(
                'title_lowercase',
                isGreaterThanOrEqualTo: searchController.text.toLowerCase(),
              ),
              Filter(
                'title_lowercase',
                isLessThan: '${searchController.text.toLowerCase()}\uf8ff',
              ),
              Filter('active', isEqualTo: true),
              Filter('soft_delete', isEqualTo: false),
            ),
          )
          .get();

      searchResults.value = results.docs;
      isLoading.value = false;
    } else {
      searchResults.clear();
    }
  }
}
