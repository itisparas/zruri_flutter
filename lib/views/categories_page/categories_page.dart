// lib/views/categories_page/categories_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/controllers/categories_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/constants/app_icons.dart';
import 'package:zruri/core/constants/app_messages.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/models/categories_model.dart';
import 'package:zruri/views/entrypoint/controllers/navigation_controller.dart';

class CategoriesPage extends StatelessWidget {
  final AppIcons appIcons = AppIcons();

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    final CategoriesController categoriesController =
        Get.find<CategoriesController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: categoriesController.refreshCategories,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(
                context,
                navigationController,
                categoriesController,
              ),
              _buildHeader(context, categoriesController),
              _buildSearchSection(categoriesController),
              _buildFeaturedSection(context, categoriesController),
              _buildAllCategoriesSection(context, categoriesController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    NavigationController navigationController,
    CategoriesController categoriesController,
  ) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        onPressed: () {
          if (navigationController.canPop.value) {
            navigationController.goBack();
          } else {
            navigationController.navigateToPage(0);
          }
        },
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
      ),
      title: Text(
        AppMessages.enUs['categoriespage.title'] ?? 'Categories',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
            onPressed: categoriesController.toggleView,
            icon: Icon(
              categoriesController.isGridView.value
                  ? Icons.view_list_outlined
                  : Icons.grid_view_outlined,
              color: Colors.grey[700],
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, categoriesController),
          icon: Icon(Icons.more_vert, color: Colors.grey[700]),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sort',
              child: Row(
                children: [Icon(Icons.sort), SizedBox(width: 8), Text('Sort')],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    CategoriesController categoriesController,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover products by category',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Categories',
                      categoriesController.formattedCount,
                      Icons.apps_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Featured',
                      categoriesController.featuredCategories.length.toString(),
                      Icons.star_outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(CategoriesController categoriesController) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            onChanged: categoriesController.searchCategories,
            decoration: InputDecoration(
              hintText: 'Search categories...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              suffixIcon: Obx(
                () => categoriesController.isSearching
                    ? IconButton(
                        onPressed: categoriesController.clearSearch,
                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                      )
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    CategoriesController categoriesController,
  ) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (categoriesController.featuredCategories.isEmpty)
          return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Featured Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categoriesController.featuredCategories.length,
                itemBuilder: (context, index) {
                  final category =
                      categoriesController.featuredCategories[index];
                  return _buildFeaturedCategoryCard(context, category);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFeaturedCategoryCard(
    BuildContext context,
    CategoriesModel category,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRouteNames().categoryListing(category.id)),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: appIcons.categoriesIcon.containsKey(category.name)
                  ? appIcons.categoriesIcon[category.name]
                  : Icon(Icons.category, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              category.name
                      .replaceAll(RegExp(r'[^\w\s]+'), ' ')
                      .capitalizeFirst ??
                  '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCategoriesSection(
    BuildContext context,
    CategoriesController categoriesController,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.apps, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'All Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    '${categoriesController.filteredCategories.length} categories',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => _buildCategoriesContent(context, categoriesController)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesContent(
    BuildContext context,
    CategoriesController categoriesController,
  ) {
    if (categoriesController.loading.value) {
      return _buildLoadingGrid();
    }

    if (categoriesController.filteredCategories.isEmpty) {
      return _buildEmptyState(categoriesController);
    }

    return categoriesController.isGridView.value
        ? _buildCategoriesGrid(categoriesController)
        : _buildCategoriesList(categoriesController);
  }

  Widget _buildCategoriesGrid(CategoriesController categoriesController) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categoriesController.filteredCategories.length,
      itemBuilder: (context, index) {
        final category = categoriesController.filteredCategories[index];
        return _buildCategoryGridItem(context, category);
      },
    );
  }

  Widget _buildCategoriesList(CategoriesController categoriesController) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoriesController.filteredCategories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = categoriesController.filteredCategories[index];
        return _buildCategoryListItem(context, category);
      },
    );
  }

  Widget _buildCategoryGridItem(
    BuildContext context,
    CategoriesModel category,
  ) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRouteNames().categoryListing(category.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: appIcons.categoriesIcon.containsKey(category.name)
                  ? appIcons.categoriesIcon[category.name]
                  : Icon(
                      Icons.category_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.name
                        .replaceAll(RegExp(r'[^\w\s]+'), ' ')
                        .capitalizeFirst ??
                    '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (category.homepage)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryListItem(
    BuildContext context,
    CategoriesModel category,
  ) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRouteNames().categoryListing(category.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: appIcons.categoriesIcon.containsKey(category.name)
                  ? appIcons.categoriesIcon[category.name]
                  : Icon(
                      Icons.category_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name
                                  .replaceAll(RegExp(r'[^\w\s]+'), ' ')
                                  .capitalizeFirst ??
                              '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (category.homepage)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 9,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CategoriesController categoriesController) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            categoriesController.isSearching
                ? 'No categories found for "${categoriesController.searchQuery.value}"'
                : 'No categories available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (categoriesController.isSearching) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: categoriesController.clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleMenuAction(
    String action,
    CategoriesController categoriesController,
  ) {
    switch (action) {
      case 'sort':
        _showSortOptions(categoriesController);
        break;
      case 'refresh':
        categoriesController.refreshCategories();
        break;
    }
  }

  void _showSortOptions(CategoriesController categoriesController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Alphabetical'),
              onTap: () {
                categoriesController.sortCategories('alphabetical');
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Featured First'),
              onTap: () {
                categoriesController.sortCategories('popular');
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('Form Fields Count'),
              onTap: () {
                categoriesController.sortCategories('form_fields');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
