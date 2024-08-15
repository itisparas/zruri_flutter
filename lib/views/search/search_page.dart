import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/controllers/search_controller.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    SearchPageController searchController =
        Get.put<SearchPageController>(SearchPageController());

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController.searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
      body: Obx(() {
        if (searchController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (searchController.searchResults.isEmpty) {
          return const Center(child: Text('No results found.'));
        } else {
          return ListView.builder(
            itemCount: searchController.searchResults.length,
            itemBuilder: (context, index) {
              final document = searchController.searchResults[index];
              return ListTile(
                title: Text(document['title']), // Replace with your field name
              );
            },
          );
        }
      }),
    );
  }
}
