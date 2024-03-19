import 'package:flutter/material.dart';
import 'package:zruri_flutter/views/home/home.dart';
import 'package:zruri_flutter/views/categories_page/categories_page.dart';
import 'package:zruri_flutter/views/my_ads_page/my_ads_page.dart';
import 'package:zruri_flutter/views/post_ad_page/post_ad_page.dart';
import 'package:zruri_flutter/views/profile/profile.dart';

class BottomBarRoutes {
  static List<Widget> pages = [
    const HomePage(),
    const CategoriesPage(),
    const PostAdPage(),
    const MyAdsPage(),
    Profile()
  ];
}
