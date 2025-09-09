import 'package:get/get.dart';
import 'package:zruri/core/services/get_categories.dart';
import 'package:zruri/models/categories_model.dart';

class CategoriesController extends GetxController {
  static CategoriesController instance = Get.find();

  final GetCategoriesService _categoryService = Get.put(
    GetCategoriesService(),
    permanent: true,
  );

  var categories = <CategoriesModel>[].obs;
  var loading = true.obs;

  @override
  void onInit() {
    _loadCategories();
    super.onInit();
  }

  Future<void> _loadCategories() async {
    try {
      loading.value = true;
      List<CategoriesModel> categoryList = await _categoryService
          .getCategories();
      categories.value = categoryList;
    } catch (e) {
      throw Exception(e);
    } finally {
      loading.value = false;
    }
  }
}
