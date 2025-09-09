import 'package:flutter/material.dart';
import 'package:zruri/views/categories_page/categories_page.dart';
import 'package:zruri/views/home/home.dart';
import 'package:zruri/views/my_ads_page/my_ads_page.dart';
import 'package:zruri/views/post_ad_page/choose_category_1.dart';
import 'package:zruri/views/profile/profile.dart';

class BottomBarRoutes {
  static List<Widget> pages = [
    const HomePage(),
    CategoriesPage(),
    ChooseCategory1(),
    const MyAdsPage(),
    Profile(),
  ];
}
