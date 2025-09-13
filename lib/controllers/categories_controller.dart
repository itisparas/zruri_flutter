// lib/controllers/categories_controller.dart
import 'package:get/get.dart';
import 'package:zruri/core/services/get_categories.dart';
import 'package:zruri/models/categories_model.dart';

class CategoriesController extends GetxController {
  static CategoriesController get instance => Get.find();

  final GetCategoriesService _categoryService = Get.put(
    GetCategoriesService(),
    permanent: true,
  );

  // Core data
  final RxList<CategoriesModel> categories = <CategoriesModel>[].obs;
  final RxList<CategoriesModel> filteredCategories = <CategoriesModel>[].obs;
  final RxList<CategoriesModel> featuredCategories = <CategoriesModel>[].obs;

  // UI state
  final RxBool loading = true.obs;
  final RxBool isGridView = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString currentSortType = 'alphabetical'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      loading.value = true;

      List<CategoriesModel> categoryList = await _categoryService
          .getCategories();

      categories.assignAll(categoryList);
      filteredCategories.assignAll(categoryList);

      // Set featured categories (homepage categories or first 6)
      featuredCategories.assignAll(
        categoryList.where((cat) => cat.homepage).take(6).toList(),
      );

      if (featuredCategories.isEmpty) {
        featuredCategories.assignAll(categoryList.take(6).toList());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }

  // Search functionality
  void searchCategories(String query) {
    searchQuery.value = query.trim().toLowerCase();

    if (searchQuery.value.isEmpty) {
      filteredCategories.assignAll(categories);
    } else {
      filteredCategories.assignAll(
        categories
            .where(
              (category) =>
                  category.name.toLowerCase().contains(searchQuery.value),
            )
            .toList(),
      );
    }
    _applySorting();
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredCategories.assignAll(categories);
    _applySorting();
  }

  // View toggle
  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  // Sorting
  void sortCategories(String sortType) {
    currentSortType.value = sortType;
    _applySorting();
  }

  void _applySorting() {
    List<CategoriesModel> sortedList = List.from(filteredCategories);

    switch (currentSortType.value) {
      case 'alphabetical':
        sortedList.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case 'popular':
        sortedList.sort(
          (a, b) => b.homepage.toString().compareTo(a.homepage.toString()),
        );
        break;
      case 'form_fields':
        sortedList.sort(
          (a, b) => b.formFields.length.compareTo(a.formFields.length),
        );
        break;
    }

    filteredCategories.assignAll(sortedList);
  }

  // Refresh
  Future<void> refreshCategories() async {
    await _loadCategories();
  }

  // Getters
  bool get hasCategories => categories.isNotEmpty;
  bool get hasSearchResults => filteredCategories.isNotEmpty;
  bool get isSearching => searchQuery.value.isNotEmpty;
  int get categoriesCount => categories.length;
  String get formattedCount => categoriesCount > 999
      ? '${(categoriesCount / 1000).toStringAsFixed(1)}K'
      : categoriesCount.toString();
}
