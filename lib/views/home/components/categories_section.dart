// lib/views/home/components/categories_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zruri/controllers/categories_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/constants/app_icons.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/models/categories_model.dart';
import 'package:zruri/views/entrypoint/controllers/navigation_controller.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection>
    with TickerProviderStateMixin {
  final AppIcons appIcons = AppIcons();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    final CategoriesController categoriesController = Get.put(
      CategoriesController(),
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(navigationController),
                const SizedBox(height: 20),
                _buildCategoriesContent(categoriesController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(NavigationController navigationController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDefaults.padding / 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.category_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildViewAllButton(navigationController),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(NavigationController navigationController) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        navigationController.navigateToPage(1); // Navigate to Categories page
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View All',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesContent(CategoriesController categoriesController) {
    return Obx(() {
      if (categoriesController.loading.value) {
        return _buildShimmerLoading();
      }

      if (categoriesController.categories.isEmpty) {
        return _buildEmptyState();
      }

      return _buildCategoriesList(categoriesController);
    });
  }

  Widget _buildCategoriesList(CategoriesController categoriesController) {
    // Show only first 8 categories for homepage
    final displayCategories = categoriesController.categories.take(8).toList();

    return SizedBox(
      height: 136,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          return _ModernCategoryItem(
            category: displayCategories[index],
            appIcons: appIcons,
            onTap: () => _onCategoryTap(displayCategories[index]),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No categories available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCategoryTap(CategoriesModel category) {
    HapticFeedback.lightImpact();
    Get.toNamed(
      AppRouteNames().categoryListing(category.id),
      arguments: {'category': category, 'categoryName': category.name},
    );
  }
}

// Modern Category Item Widget
class _ModernCategoryItem extends StatefulWidget {
  final CategoriesModel category;
  final AppIcons appIcons;
  final VoidCallback onTap;

  const _ModernCategoryItem({
    required this.category,
    required this.appIcons,
    required this.onTap,
  });

  @override
  State<_ModernCategoryItem> createState() => _ModernCategoryItemState();
}

class _ModernCategoryItemState extends State<_ModernCategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handlePressStart(),
      onTapUp: (_) => _handlePressEnd(),
      onTapCancel: () => _handlePressEnd(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: AppColors.primary.withOpacity(0.3),
                          //     blurRadius: 12,
                          //     offset: const Offset(0, 6),
                          //     spreadRadius: 0,
                          //   ),
                          // ],
                        ),
                        child:
                            widget.appIcons.categoriesIcon.containsKey(
                              widget.category.name,
                            )
                            ? widget.appIcons.categoriesIcon[widget
                                  .category
                                  .name]
                            : Icon(
                                Icons.category_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                      ),

                      // Featured badge
                      if (widget.category.homepage)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),

                      // Pulse animation for featured categories
                      if (widget.category.homepage)
                        Positioned.fill(
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 2),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(
                                      0.3 * (1 - value),
                                    ),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                            onEnd: () {
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.category.name
                            .replaceAll(RegExp(r'[^\w\s]+'), ' ')
                            .capitalizeFirst ??
                        '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handlePressStart() {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.selectionClick();
  }

  void _handlePressEnd() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }
}
