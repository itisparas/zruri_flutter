import 'dart:async';
import 'dart:developer';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zruri_flutter/controllers/my_ads_controller.dart';

class ScreenController extends GetxController {
  Rx<int> currentIndex = 0.obs;
  Rx<bool> isKeyboardVisible = false.obs;

  GetStorage box = GetStorage();

  late StreamSubscription<bool> keyboardSubscription;

  @override
  onInit() {
    box.writeIfNull('currentPage', currentIndex.value);
    if (box.read('currentPage') != 0) {
      onChange(box.read('currentPage'));
    }
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((event) {
      log('Keyboard visible:  $event');
      isKeyboardVisible.value = event;
    });
    super.onInit();
  }

  @override
  onClose() {
    keyboardSubscription.cancel();
    box.erase();
    super.onClose();
  }

  gotoPrevPage() {
    if (box.read('prevPage') != null && box.read('prevPage') != 2) {
      onChange(box.read('prevPage') as int);
    } else {
      onChange(0);
    }
  }

  onChange(int index) {
    Get.delete<MyAdsController>();
    box.write('prevPage', box.read('currentPage') as int? ?? 0);
    box.write('currentPage', index);
    currentIndex(index);
  }
}
