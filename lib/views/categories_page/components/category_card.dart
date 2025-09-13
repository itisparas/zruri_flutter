// lib/views/categories_page/components/category_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zruri/core/constants/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final dynamic category;
  final VoidCallback onTap;
  final bool isGridView;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: isGridView ? _buildGridCard() : _buildListCard(),
      ),
    );
  }

  Widget _buildGridCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getCategoryIcon(), color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            category.name.toString().capitalize ?? 'Category',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${category.itemsCount ?? 0} items',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCategoryIcon(), color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name.toString().capitalize ?? 'Category',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.itemsCount ?? 0} items available',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    // Map category names to icons
    final categoryIconMap = {
      'cars': FontAwesomeIcons.car,
      'properties': FontAwesomeIcons.building,
      'electronics': FontAwesomeIcons.mobile,
      'fashion': FontAwesomeIcons.shirt,
      'home': FontAwesomeIcons.house,
      'services': FontAwesomeIcons.bellConcierge,
      'jobs': FontAwesomeIcons.briefcase,
      'events': FontAwesomeIcons.champagneGlasses,
      'sports': FontAwesomeIcons.footballBall,
      'books': FontAwesomeIcons.book,
      'pets': FontAwesomeIcons.paw,
      'music': FontAwesomeIcons.music,
    };

    String categoryName = category.name.toString().toLowerCase();
    return categoryIconMap[categoryName] ?? FontAwesomeIcons.tag;
  }
}

extension StringExtension on String {
  String? get capitalize {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
