// lib/views/entrypoint/components/bottom_app_bar_item.dart
import 'package:flutter/material.dart';
import 'package:zruri/core/constants/app_colors.dart';

class BottomAppBarItem extends StatelessWidget {
  final IconData iconName;
  final String name;
  final bool isActive;
  final void Function() onTap;
  final int? badgeCount;

  const BottomAppBarItem({
    super.key,
    required this.iconName,
    required this.name,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  iconName,
                  color: isActive ? AppColors.primary : AppColors.placeholder,
                  size: 24,
                ),
                // Badge for unread messages
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount! > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? AppColors.primary : AppColors.placeholder,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
