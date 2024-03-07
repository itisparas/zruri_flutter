import 'dart:developer';

import 'package:get/get.dart';

class ScreenController extends GetxController {
  Rx<int> currentIndex = 0.obs;

  onChange(int index) {
    log(index.toString());
    currentIndex(index);
  }
}
