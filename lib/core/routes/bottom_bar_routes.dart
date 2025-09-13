// lib/views/entrypoint/bottom_bar_routes.dart
import 'package:flutter/material.dart';
import 'package:zruri/views/categories_page/categories_page.dart';
import 'package:zruri/views/chat/chat_list_page.dart';
import 'package:zruri/views/home/home.dart';
import 'package:zruri/views/profile/profile.dart';

class BottomBarRoutes {
  static List<Widget> pages = [
    const HomePage(), // 0 - Home
    CategoriesPage(), // 1 - Categories
    ChatListPage(), // 2 - Chats
    Profile(), // 3 - Profile
  ];

  static String getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Categories';
      case 2:
        return 'Chats';
      case 3:
        return 'Profile';
      default:
        return 'Zruri';
    }
  }
}
