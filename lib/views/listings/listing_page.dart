import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class ListingPage extends StatelessWidget {
  final String genre = Get.parameters['genre'] ?? '';
  final String genreInfo = Get.parameters['genre_info'] ?? '';

  ListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(
              AppDefaults.padding / 2,
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: Text(
                        'Ads',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
