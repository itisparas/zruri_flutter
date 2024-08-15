import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri_flutter/controllers/search_controller.dart';
import 'package:zruri_flutter/core/components/my_ad_item.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding / 2),
        child: Obx(
          () {
            if (searchController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (searchController.searchResults.isEmpty) {
              return const Center(child: Text('No results found.'));
            } else {
              return ListView.builder(
                itemCount: searchController.searchResults.length,
                itemBuilder: (context, index) {
                  final document = searchController.searchResults[index];
                  return MyAdItem(
                    search_result: true,
                    image: document['filepaths'][0],
                    price: document['price'],
                    title: document['title'],
                    timeline: DateFormat.yMMMd()
                        .format(
                          document['createdAt'].toDate(),
                        )
                        .toString(),
                    id: document.id,
                    active: document['active'],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
