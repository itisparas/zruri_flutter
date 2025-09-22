// lib/views/category_selection_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zruri/controllers/categories_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/models/categories_model.dart';
import 'package:zruri/views/post_ad_page/dynamic_form_page.dart';

class CategorySelectionPage extends StatelessWidget {
  const CategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is initialized here (or via Bindings)
    final CategoriesController categoriesController = Get.put(
      CategoriesController(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (categoriesController.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoriesController.categories.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        return _buildCategoryList(categoriesController);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Select a Category',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildCategoryList(CategoriesController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return _buildCategoryCard(category)
            .animate()
            .fadeIn(duration: 500.ms, delay: (100 * index).ms)
            .slideY(begin: 0.2);
      },
    );
  }

  Widget _buildCategoryCard(CategoriesModel category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to the form page with the selected category
            Get.off(() => const DynamicFormPage(), arguments: category);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.name),
                    size: 24,
                    color: _getCategoryColor(category.name),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name.toString().capitalizeFirst!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to start posting', // Example subtitle
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods copied from the original file for consistent design
  IconData _getCategoryIcon(String categoryName) {
    final iconMap = {
      'Jobs & Employment': Icons.work_rounded,
      'Real Estate - For Sale': Icons.home_rounded,
      'Real Estate - For Rent': Icons.apartment_rounded,
      'Vehicles - Cars': Icons.directions_car_rounded,
      'Services': Icons.build_rounded,
      'Electronics': Icons.devices_rounded,
      'Fashion': Icons.checkroom_rounded,
      'Home & Garden': Icons.home_work_rounded,
    };
    return iconMap[categoryName] ?? Icons.category_rounded;
  }

  Color _getCategoryColor(String categoryName) {
    final colorMap = {
      'Jobs & Employment': Colors.blue,
      'Real Estate - For Sale': Colors.green,
      'Real Estate - For Rent': Colors.orange,
      'Vehicles - Cars': Colors.red,
      'Services': Colors.purple,
      'Electronics': Colors.indigo,
      'Fashion': Colors.pink,
      'Home & Garden': Colors.teal,
    };
    return colorMap[categoryName] ?? AppColors.primary;
  }
}
