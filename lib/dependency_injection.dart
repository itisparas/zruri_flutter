import 'package:get/get.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
