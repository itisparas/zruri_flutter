import 'package:flutter/material.dart';
import 'package:zruri/core/constants/constants.dart';

class BottomAppBarItem extends StatelessWidget {
  final IconData iconName;
  final String name;
  final bool isActive;
  final void Function() onTap;

  const BottomAppBarItem({
    super.key,
    required this.iconName,
    required this.name,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            iconName,
            color: isActive ? AppColors.primary : AppColors.placeholder,
          ),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isActive ? AppColors.primary : AppColors.placeholder,
                ),
          )
        ],
      ),
    );
  }
}
