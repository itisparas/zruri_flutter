// lib/views/categories_page/modern_categories_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zruri/controllers/categories_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/models/categories_model.dart';
import 'package:zruri/views/entrypoint/controllers/navigation_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernCategoriesPage extends StatelessWidget {
  const ModernCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    final CategoriesController controller = Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildModernSliverAppBar(
              context,
              controller,
              innerBoxIsScrolled,
              navigationController,
            ),
          ],
          body: RefreshIndicator(
            onRefresh: controller.refreshCategories,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                _buildWelcomeHeader(controller),
                _buildSearchSection(controller),
                _buildQuickActions(navigationController),
                _buildFeaturedCategoriesSection(controller),
                _buildAllCategoriesSection(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSliverAppBar(
    BuildContext context,
    CategoriesController controller,
    bool innerBoxIsScrolled,
    NavigationController navigationController,
  ) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () {
          if (navigationController.canPop.value) {
            navigationController.goBack();
          } else {
            navigationController.navigateToPage(0);
          }
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.black87,
          size: 20,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: innerBoxIsScrolled ? 1.0 : 0.0,
          child: const Text(
            'Categories',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary.withOpacity(0.1), Colors.white],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.category_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
            onPressed: controller.toggleView,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                controller.isGridView.value
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                key: ValueKey(controller.isGridView.value),
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, controller),
          icon: Icon(Icons.more_vert_rounded, color: Colors.grey[700]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sort',
              child: Row(
                children: [
                  Icon(Icons.sort_rounded, size: 20),
                  SizedBox(width: 12),
                  Text('Sort Categories'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 12),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(CategoriesController controller) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🇨🇦 Welcome to Canada\'s Marketplace',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buy, sell, rent & find jobs across Canada',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'CAD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(
              () => Row(
                children: [
                  _buildStatChip(
                    'Categories',
                    controller.formattedCount,
                    Icons.category_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    'Featured',
                    controller.featuredCategories.length.toString(),
                    Icons.star_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: -0.2, duration: 600.ms).fadeIn(),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(CategoriesController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: controller.searchCategories,
            decoration: InputDecoration(
              hintText: 'Search categories...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
              suffixIcon: Obx(
                () => controller.isSearching
                    ? IconButton(
                        onPressed: controller.clearSearch,
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey[400],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ).animate().slideX(begin: -0.3, duration: 500.ms).fadeIn(delay: 200.ms),
    );
  }

  Widget _buildQuickActions(NavigationController navigationController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Post an Ad',
                'Sell something',
                Icons.add_circle_outline_rounded,
                Colors.green,
                () => Get.toNamed(AppRouteNames.modernPostAdPage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'My Ads',
                'Manage listings',
                Icons.list_alt_rounded,
                Colors.blue,
                () => navigationController.navigateToPage(3),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.3, duration: 500.ms).fadeIn(delay: 300.ms),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCategoriesSection(CategoriesController controller) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.featuredCategories.isEmpty)
          return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Featured Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.featuredCategories.length,
                itemBuilder: (context, index) {
                  final category = controller.featuredCategories[index];
                  return _buildFeaturedCategoryCard(context, category, index);
                },
              ),
            ),
          ],
        ).animate().slideY(begin: 0.2, duration: 500.ms).fadeIn(delay: 400.ms);
      }),
    );
  }

  Widget _buildFeaturedCategoryCard(
    BuildContext context,
    CategoriesModel category,
    int index,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final color = colors[index % colors.length];

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRouteNames().categoryListing(category.id)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  category.name
                          .replaceAll(RegExp(r'[^\w\s]+'), ' ')
                          .capitalizeFirst ??
                      '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(delay: (index * 100).ms, duration: 400.ms),
    );
  }

  Widget _buildAllCategoriesSection(CategoriesController controller) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.apps_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'All Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.filteredCategories.length}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => _buildCategoriesContent(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesContent(CategoriesController controller) {
    if (controller.loading.value) {
      return _buildLoadingGrid();
    }

    if (controller.filteredCategories.isEmpty) {
      return _buildEmptyState(controller);
    }

    return controller.isGridView.value
        ? _buildCategoriesGrid(controller)
        : _buildCategoriesList(controller);
  }

  Widget _buildCategoriesGrid(CategoriesController controller) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      itemCount: controller.filteredCategories.length,
      itemBuilder: (context, index) {
        final category = controller.filteredCategories[index];
        return _buildCategoryGridItem(context, category, index);
      },
    );
  }

  Widget _buildCategoriesList(CategoriesController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredCategories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = controller.filteredCategories[index];
        return _buildCategoryListItem(context, category, index);
      },
    );
  }

  Widget _buildCategoryGridItem(
    BuildContext context,
    CategoriesModel category,
    int index,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => Get.toNamed(AppRouteNames().categoryListing(category.id)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                _getCategoryIcon(category.name),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              category.name
                      .replaceAll(RegExp(r'[^\w\s]+'), ' ')
                      .capitalizeFirst ??
                  '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (category.homepage) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ).animate().scale(delay: (index * 50).ms, duration: 300.ms),
    );
  }

  Widget _buildCategoryListItem(
    BuildContext context,
    CategoriesModel category,
    int index,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => Get.toNamed(AppRouteNames().categoryListing(category.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                _getCategoryIcon(category.name),
                color: Colors.white,
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
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.formFields.length} fields',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ).animate().slideX(begin: 0.3, delay: (index * 50).ms, duration: 300.ms),
    );
  }

  Widget _buildLoadingGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      itemCount: 8,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
          height: 120,
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
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms);
  }

  Widget _buildEmptyState(CategoriesController controller) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              controller.isSearching
                  ? Icons.search_off_rounded
                  : Icons.category_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            controller.isSearching
                ? 'No categories found'
                : 'No categories available',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            controller.isSearching
                ? 'Try adjusting your search terms'
                : 'Categories will appear here once available',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (controller.isSearching) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.clearSearch,
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms);
  }

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
      'Sports': Icons.sports_basketball_rounded,
      'Books': Icons.menu_book_rounded,
      'Pets': Icons.pets_rounded,
      'Baby & Kids': Icons.child_care_rounded,
    };

    return iconMap[categoryName] ?? Icons.category_rounded;
  }

  void _handleMenuAction(String action, CategoriesController controller) {
    switch (action) {
      case 'sort':
        _showSortOptions(controller);
        break;
      case 'refresh':
        controller.refreshCategories();
        break;
    }
  }

  void _showSortOptions(CategoriesController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.sort_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sort Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSortOption(
              'Alphabetical',
              'Sort A to Z',
              Icons.sort_by_alpha_rounded,
              () {
                controller.sortCategories('alphabetical');
                Get.back();
              },
            ),
            _buildSortOption(
              'Featured First',
              'Show featured categories first',
              Icons.star_rounded,
              () {
                controller.sortCategories('popular');
                Get.back();
              },
            ),
            _buildSortOption(
              'Form Fields Count',
              'Sort by number of fields',
              Icons.format_list_numbered_rounded,
              () {
                controller.sortCategories('form_fields');
                Get.back();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSortOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
