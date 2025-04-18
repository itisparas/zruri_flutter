import 'package:flutter/material.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class Skeleton extends StatelessWidget {
  final double? height, width;
  final int layer;

  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.layer = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(AppDefaults.padding / 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04 * layer),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppDefaults.radius),
        ),
      ),
    );
  }
}

class CircleSkeleton extends StatelessWidget {
  final double? size;

  const CircleSkeleton({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.04),
        shape: BoxShape.circle,
      ),
    );
  }
}
